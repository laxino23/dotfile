-- CodeLens is a ghost_text like above the functions, classes, or others
-- that you can do actions with
--[[
    Run | Debug  |  3 References --> this part!!
    fn calculate_data() {
        // ... function body
    }
--]]

local M = {}

-- Backup the original vim.lsp.codelens functions globally.
-- We do this so we can restore them when re-enabling CodeLens,
-- or replace them with empty functions (no-ops) when disabling.
if not _G.orig_codelens_display then
    _G.orig_codelens_display = vim.lsp.codelens.display
end
if not _G.orig_codelens_refresh then
    _G.orig_codelens_refresh = vim.lsp.codelens.refresh
end
if not _G.orig_codelens_clear then
    _G.orig_codelens_clear = vim.lsp.codelens.clear
end

--- Check if CodeLens should be enabled based on a global settings table.
--- Returns false if the setting is missing or explicitly false.
M.is_codelens_enabled = function()
    if _G.SETTINGS and _G.SETTINGS["codelens"] ~= nil then
        return _G.SETTINGS["codelens"]
    end
    return false
end

--- Manually clear all CodeLens virtual text/extmarks from all buffers.
--- This iterates through namespaces to find any containing "codelens" and clears them.
M.clear_all_codelens = function()
    for name, id in pairs(vim.api.nvim_get_namespaces()) do
        -- this will only clear the thing related with codelens namespaces
        if type(name) == "string" and name:lower():find("codelens") then
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf) then
                    vim.api.nvim_buf_clear_namespace(buf, id, 0, -1)
                end
            end
        end
    end
    vim.cmd("redraw!")
end

--- Refresh CodeLens for all valid buffers.
--- Triggered manually or by config changes.
M.refresh_all_codelens = function()
    if M.is_codelens_enabled() then
        vim.lsp.codelens.refresh()
        -- Iterate over buffers to trigger events that might force a redraw/update
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" then
                vim.cmd("doautocmd BufEnter")
            end
        end
        vim.cmd("redraw!")
    end
end

--- Setup autocommands to automatically refresh CodeLens.
--- Refreshes on LspAttach, TextChanged, and TextChangedI (Insert mode).
M.setup_codelens_autocmds = function()
    local group = vim.api.nvim_create_augroup("AutoCodeLens", { clear = true })
    vim.api.nvim_create_autocmd({ "LspAttach", "TextChanged", "TextChangedI" }, {
        callback = function()
            -- Debounce the refresh slightly (100ms) to avoid performance hits while typing
            vim.defer_fn(function()
                if M.is_codelens_enabled() then
                    vim.lsp.codelens.refresh()
                end
            end, 100)
        end,
        group = group,
    })
    return group
end

--- execute the CodeLens on the current line.
--- If none is found on the exact line, it searches for the closest one.
M.lsp_code_lens_run = function()
    if not M.is_codelens_enabled() then
        vim.notify("CodeLens is disabled", vim.log.levels.WARN)
        return
    end

    local pos = vim.api.nvim_win_get_cursor(0)
    local line = pos[1] - 1 -- API uses 0-based indexing for lines
    local lenses = vim.lsp.codelens.get(0) or {}
    local found = false

    -- 1. Try to find a lens exactly on the current line
    for _, lens in ipairs(lenses) do
        if lens.range.start.line == line then
            vim.lsp.codelens.run()
            found = true
            break
        end
    end

    -- 2. If not found, find the closest lens to the cursor
    if not found then
        local closest_lens = nil
        local min_distance = math.huge
        for _, lens in ipairs(lenses) do
            local distance = math.abs(lens.range.start.line - line)
            if distance < min_distance then
                min_distance = distance
                closest_lens = lens
            end
        end
        
        -- Move cursor to the closest lens and run it
        if closest_lens then
            vim.api.nvim_win_set_cursor(0, { closest_lens.range.start.line + 1, closest_lens.range.start.character })
            vim.lsp.codelens.run()
            found = true
        end
    end

    -- 3. Notify user if absolutely nothing was found
    if not found then
        if #lenses == 0 then
            vim.notify("No CodeLens found in this buffer", vim.log.levels.WARN)
        else
            vim.notify("No CodeLens on current line", vim.log.levels.INFO)
        end
    end
end

--- Enable or Disable CodeLens logic.
--- @param val boolean: true to enable, false to disable
M.set_codelens_enabled = function(val)
    -- Ensure backups exist before modifying
    if not _G.orig_codelens_display then
        _G.orig_codelens_display = vim.lsp.codelens.display
    end
    if not _G.orig_codelens_refresh then
        _G.orig_codelens_refresh = vim.lsp.codelens.refresh
    end
    if not _G.orig_codelens_clear then
        _G.orig_codelens_clear = vim.lsp.codelens.clear
    end

    if val then
        -- ENABLE: Restore the original Neovim functions
        vim.lsp.codelens.display = _G.orig_codelens_display
        vim.lsp.codelens.refresh = _G.orig_codelens_refresh
        vim.lsp.codelens.clear = _G.orig_codelens_clear
        
        -- Schedule an immediate refresh
        vim.schedule(function()
            vim.lsp.codelens.refresh()
        end)
        
        -- Re-register autocommands if missing
        if not (M.group and type(M.group) == "number") then
            M.group = M.setup_codelens_autocmds()
        end
    else
        -- DISABLE: Replace Neovim functions with empty no-ops.
        -- This prevents LSP from trying to display lenses even if it sends data.
        vim.lsp.codelens.display = function() end
        vim.lsp.codelens.refresh = function() end
        vim.lsp.codelens.clear = function() end

        -- Clear existing visual indicators
        for name, id in pairs(vim.api.nvim_get_namespaces()) do
            if type(name) == "string" and name:lower():find("codelens") then
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_clear_namespace(buf, id, 0, -1)
                    end
                end
            end
        end
        vim.cmd("redraw!")

        -- Remove the autocommands to stop background processing
        if M.group and type(M.group) == "number" then
            pcall(vim.api.nvim_clear_autocmds, { group = M.group })
            M.group = nil
        end
    end
end

--- Initial Setup function
M.setup = function()
    -- Initialize backups
    if not _G.orig_codelens_display then
        _G.orig_codelens_display = vim.lsp.codelens.display
    end
    if not _G.orig_codelens_refresh then
        _G.orig_codelens_refresh = vim.lsp.codelens.refresh
    end
    if not _G.orig_codelens_clear then
        _G.orig_codelens_clear = vim.lsp.codelens.clear
    end

    -- Apply initial state based on global settings
    if M.is_codelens_enabled() then
        vim.lsp.codelens.display = _G.orig_codelens_display
        vim.lsp.codelens.refresh = _G.orig_codelens_refresh
        vim.lsp.codelens.clear = _G.orig_codelens_clear
        M.group = M.setup_codelens_autocmds()
    else
        -- Apply "disabled" state (no-ops) immediately if disabled
        vim.lsp.codelens.display = function() end
        vim.lsp.codelens.refresh = function() end
        vim.lsp.codelens.clear = function() end
        if M.group and type(M.group) == "number" then
            pcall(vim.api.nvim_clear_autocmds, { group = M.group })
            M.group = nil
        end
        M.clear_all_codelens()
    end

    -- Map Double-Left-Click to run CodeLens
    vim.keymap.set("n", "<2-LeftMouse>", function()
        if not M.is_codelens_enabled() then
            -- Pass through the click if disabled
            vim.api.nvim_input("<2-LeftMouse>")
            return
        end
        
        local pos = vim.api.nvim_win_get_cursor(0)
        local line = pos[1] - 1
        local lenses = vim.lsp.codelens.get(0) or {}
        
        -- Check if user clicked exactly on a line with a lens
        for _, lens in ipairs(lenses) do
            if lens.range.start.line == line then
                vim.lsp.codelens.run()
                return
            end
        end
        
        -- If no lens clicked, behave like a normal double click
        vim.api.nvim_input("<2-LeftMouse>")
    end, { noremap = true, silent = true })

    -- Create user command to run the lens
    vim.api.nvim_create_user_command("LspCodeLensRun", function()
        M.lsp_code_lens_run()
    end, {})
end

return M
