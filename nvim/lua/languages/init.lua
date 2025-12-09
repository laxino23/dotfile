-- =============================================================================
-- Description: Sets up autocommands to automatically attach LSP clients to 
--              buffers when files are opened, based on filetype configuration.
-- =============================================================================

local lsp_manager = require("languages.lsp_manager")
local group = vim.api.nvim_create_augroup("MyLSPEnable", { clear = true })

local M = {}

-- Attempts to attach appropriate LSP clients to a specific buffer.
-- Checks against global configs and disabled lists before attaching.
local function attach_lsp_to_buffer(bufnr)
    -- Validate buffer existence
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return end
    
    local ft = vim.bo[bufnr].filetype
    if not ft or ft == "" then return end

    -- Identify which servers support this filetype
    local matches = {}
    for key, filetypes in pairs(_G.file_types or {}) do
        if vim.tbl_contains(filetypes, ft) then
            table.insert(matches, key)
        end
    end

    -- Ensure each matching server is running (unless disabled)
    for _, match in ipairs(matches) do
        if
            not lsp_manager.is_server_disabled_globally(match)
            and not lsp_manager.is_server_disabled_for_buffer(match, bufnr)
        then
            lsp_manager.ensure_lsp_for_buffer(match, bufnr)
        end
    end

    -- Special handling for EFM (General Purpose Language Server)
    -- Checks if EFM is configured for this filetype
    if
        (_G.efm_configs and _G.efm_configs[ft])
        or (_G.global and _G.global.efm and _G.global.efm.filetypes and vim.tbl_contains(_G.global.efm.filetypes, ft))
    then
        if
            not lsp_manager.is_server_disabled_globally("efm")
            and not lsp_manager.is_server_disabled_for_buffer("efm", bufnr)
        then
            lsp_manager.ensure_lsp_for_buffer("efm", bufnr)
        end
    end
end

-- Initializes the auto-commands for LSP attachment.
M.init = function()
    -- Defer execution to avoid slowing down Neovim startup
    vim.defer_fn(function()
        -- Trigger on FileType detection
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            callback = function(args)
                local bufnr = args.buf
                attach_lsp_to_buffer(bufnr)
            end,
        })

        -- Trigger on Buffer Entry (double-check mechanism)
        vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
            group = group,
            callback = function(args)
                local bufnr = args.buf
                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        attach_lsp_to_buffer(bufnr)
                    end
                end, 100)
            end,
        })

        -- Command to manually re-attach LSPs to the current buffer
        vim.api.nvim_create_user_command("LspReattach", function()
            local bufnr = vim.api.nvim_get_current_buf()
            attach_lsp_to_buffer(bufnr)
        end, {})

        -- Memory Management: Stop LSPs from old projects when directory changes
        vim.api.nvim_create_autocmd("DirChanged", {
            pattern = "*",
            callback = function()
                vim.defer_fn(function()
                    require("languages.lsp_manager").stop_servers_for_old_project()
                    vim.cmd("Fidget clear") -- Clear notification UI
                end, 5000)
            end,
            desc = "Stops LSP servers from other projects when directory is changed",
        })

        -- Initial sweep: Attach to all currently open buffers
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype ~= "" then
                attach_lsp_to_buffer(bufnr)
            end
        end
    end, 100)
end

M.lsp_enable = function() return true end

-- Helper to find which keys in _G.file_types match a specific filetype
M.find_matching_keys = function(ft)
    if not ft or ft == "" then return {} end
    local matches = {}
    for key, filetypes in pairs(_G.file_types or {}) do
        if vim.tbl_contains(filetypes, ft) then
            table.insert(matches, key)
        end
    end
    return matches
end

M.setup = M.init

return M
