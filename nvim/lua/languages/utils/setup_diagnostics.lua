local fidget = require("fidget")
local icons = require("config.ui.icons")

local M = {}

-- Create a group for LSP progress autocommands to prevent duplication
local group = vim.api.nvim_create_augroup("LspProgressNotify", { clear = false })
local virtualdiagnostic

-- Determine the style of virtual diagnostics (text, lines, or both) 
-- based on global settings.
if _G.SETTINGS.virtualdiagnostic == "text-and-lines" then
    virtualdiagnostic = { text = true, lines = true }
elseif _G.SETTINGS.virtualdiagnostic == "text" then
    virtualdiagnostic = { text = true, lines = false }
elseif _G.SETTINGS.virtualdiagnostic == "lines" then
    virtualdiagnostic = { text = false, lines = true }
else
    virtualdiagnostic = { text = false, lines = false }
end

-- Helper to check if any diagnostic display is enabled
local is_empty = not virtualdiagnostic or next(virtualdiagnostic) == nil

-- Main configuration table for vim.diagnostic
local config_diagnostic = {
    -- Show virtual text (at the end of the line) with a dot prefix if enabled
    virtual_text = (not is_empty and virtualdiagnostic.text) and { prefix = icons.common.dot } or false,
    -- Show virtual lines (multiline messages below the code) if enabled
    virtual_lines = not is_empty and virtualdiagnostic.lines or false,
    update_in_insert = false, -- Do not update diagnostics while typing in insert mode
    underline = true,         -- Underline the error/warning location
    severity_sort = true,     -- Sort diagnostics by severity (Error > Warn > Info > Hint)
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.warn,
            [vim.diagnostic.severity.INFO] = icons.diagnostics.info,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.hint,
        },
    },
}

--- Initialize diagnostic configuration and UI signs
M.init_diagnostics = function()
    -- Apply the config defined above
    vim.diagnostic.config(config_diagnostic)

    -- Define the gutter signs (icons) for each diagnostic severity
    vim.fn.sign_define("DiagnosticSignError", {
        text = icons.diagnostics.error,
        texthl = "DiagnosticError",
    })
    vim.fn.sign_define("DiagnosticSignWarn", {
        text = icons.diagnostics.warn,
        texthl = "DiagnosticWarn",
    })
    vim.fn.sign_define("DiagnosticSignHint", {
        text = icons.diagnostics.hint,
        texthl = "DiagnosticHint",
    })
    vim.fn.sign_define("DiagnosticSignInfo", {
        text = icons.diagnostics.info,
        texthl = "DiagnosticInfo",
    })

    -- Configure LSP progress display based on user settings
    if _G.SETTINGS.lspprogress == "fidget" then
        -- Use 'fidget.nvim' plugin for progress
        fidget.progress.suppress(false)
        fidget.notification.suppress(false)
        M.disable_lsp_progress() -- Disable our manual notifier
    elseif _G.SETTINGS.lspprogress == "notify" then
        -- Use 'vim.notify' (or nvim-notify) for progress
        fidget.progress.suppress(true)
        fidget.notification.suppress(true)
        M.enable_lsp_progress() -- Enable our manual notifier
    else
        -- Disable all progress notifications
        fidget.progress.suppress(true)
        fidget.notification.suppress(true)
        M.disable_lsp_progress()
    end
end

--- Highlight references to the symbol under the cursor (if supported by server)
M.document_highlight = function(client, bufnr)
    if client.server_capabilities.documentHighlightProvider then
        -- Highlight references when cursor stops moving
        vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            group = group,
            callback = function()
                -- Iterate clients to find the one that supports highlighting
                for _, c in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                    if c.server_capabilities.documentHighlightProvider then
                        vim.lsp.buf.document_highlight()
                        break
                    end
                end
            end,
        })

        -- Clear highlights when cursor moves
        vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = bufnr,
            group = group,
            callback = function()
                for _, c in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
                    if c.server_capabilities.documentHighlightProvider then
                        vim.lsp.buf.clear_references()
                        break
                    end
                end
            end,
        })
    end
end

--- Set up auto-formatting on file save
M.document_auto_format = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                if _G.SETTINGS.autoformat == true then
                    vim.lsp.buf.format()
                end
            end,
            group = "MyIDE",
        })
    end
end

--- Enable Inlay Hints (if supported and enabled in settings)
M.inlay_hint = function(client, bufnr)
    if
        vim.lsp.inlay_hint ~= nil
        and client.server_capabilities.inlayHintProvider
        and _G.SETTINGS.inlayhint == true
    then
        -- Schedule enablement to ensure buffer is fully loaded
        vim.schedule(function()
            vim.lsp.inlay_hint.enable(true, { bufnr })
        end)
    end
end

--- Manual implementation of LSP progress notifications using vim.notify
--- This is used when 'fidget.nvim' is not desired.
M.enable_lsp_progress = function()
    vim.api.nvim_clear_autocmds({ group = group })

    -- Table to track progress tokens per client
    ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
    local progress = vim.defaulttable()

    vim.api.nvim_create_autocmd("LspProgress", {
        group = group,
        ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
            
            if not client or type(value) ~= "table" then
                return
            end

            -- Find or create the progress entry for this token
            local p = progress[client.id]
            for i = 1, #p + 1 do
                if i == #p + 1 or p[i].token == ev.data.params.token then
                    -- Update the message string
                    p[i] = {
                        token = ev.data.params.token,
                        msg = ("[%3d%%] %s%s"):format(
                            value.kind == "end" and 100 or value.percentage or 100,
                            value.title or "",
                            value.message and (" **%s**"):format(value.message) or ""
                        ),
                        done = value.kind == "end",
                    }
                    break
                end
            end

            -- Filter out completed tasks and prepare the notification message
            local msg = {} ---@type string[]
            progress[client.id] = vim.tbl_filter(function(v)
                return table.insert(msg, v.msg) or not v.done
            end, p)

            -- Spinner animation frames
            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            
            -- Display the notification using standard vim.notify
            vim.notify(table.concat(msg, "\n"), "info", {
                id = "lsp_progress",
                title = client.name,
                opts = function(notif)
                    -- Set icon: Checkmark if done, Spinner if running based on time
                    notif.icon = #progress[client.id] == 0 and " "
                        or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                end,
            })
        end,
    })
end

--- Disable the manual LSP progress autocommands
M.disable_lsp_progress = function()
    vim.api.nvim_clear_autocmds({ group = group })
end

local cached_capabilities = nil

--- Get LSP Client Capabilities (and integrate with blink.cmp if available)
M.get_capabilities = function()
    if cached_capabilities then
        return cached_capabilities
    end

    -- Start with default Neovim client capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- Try to extend capabilities with blink.cmp (autocompletion plugin)
    local ok, enhanced_capabilities = pcall(require, "blink.cmp")
    if ok and enhanced_capabilities and type(enhanced_capabilities.get_lsp_capabilities) == "function" then
        enhanced_capabilities = enhanced_capabilities.get_lsp_capabilities(capabilities)
        cached_capabilities = enhanced_capabilities
        return enhanced_capabilities
    end

    return capabilities
end

--- Register LSP Keymaps
--- @param client table The LSP client object
--- @param bufnr number The buffer number
M.keymaps = function(client, bufnr)
    -- Helper to set keymaps only if the server supports the specific capability
    local function buf_set_keymap(mode, lhs, command, desc, capability_check)
        if not capability_check or capability_check(client) then
            vim.keymap.set(mode, lhs, command, {
                buffer = bufnr,
                desc = desc,
            })
        end
    end

    -- --- Basic Navigation ---
    
    -- Go to definition
    buf_set_keymap("n", "gd", "<cmd>LspDefinition<CR>", "Go to definition", function(c)
        return c.server_capabilities.definitionProvider
    end)

    -- Go to declaration
    buf_set_keymap("n", "gD", "<cmd>LspDeclaration<CR>", "Go to declaration", function(c)
        return c.server_capabilities.declarationProvider
    end)

    -- Go to type definition (e.g. struct definition)
    buf_set_keymap("n", "gt", "<cmd>LspTypeDefinition<CR>", "Go to type definition", function(c)
        return c.server_capabilities.typeDefinitionProvider
    end)

    -- Go to implementation (e.g. interface implementation)
    buf_set_keymap("n", "gi", "<cmd>LspImplementation<CR>", "Go to implementation", function(c)
        return c.server_capabilities.implementationProvider
    end)

    -- Find all references to the symbol
    buf_set_keymap("n", "gr", "<cmd>LspReferences<CR>", "Find references", function(c)
        return c.server_capabilities.referencesProvider
    end)

    -- --- Information ---

    -- Show hover documentation (like a tooltip)
    buf_set_keymap("n", "K", "<cmd>LspHover<CR>", "Show hover information", function(c)
        return c.server_capabilities.hoverProvider
    end)

    -- Show function signature help (arguments)
    buf_set_keymap("i", "<C-k>", "<cmd>LspSignatureHelp<CR>", "Show signature help", function(c)
        return c.server_capabilities.signatureHelpProvider
    end)

    -- --- Actions & Editing ---

    -- Rename symbol (refactoring)
    buf_set_keymap("n", "ge", "<cmd>LspRename<CR>", "Rename symbol", function(c)
        return c.server_capabilities.renameProvider
    end)

    -- Code Actions (quick fixes)
    buf_set_keymap("n", "ga", "<cmd>LspCodeAction<CR>", "Code action", function(c)
        return c.server_capabilities.codeActionProvider
    end)

    -- Format entire document
    buf_set_keymap("n", "gf", "<cmd>LspFormat<CR>", "Format document", function(c)
        return c.server_capabilities.documentFormattingProvider
    end)

    -- Format selected range
    buf_set_keymap("v", "gF", "<cmd>LspRangeFormat<CR>", "Format selection", function(c)
        return c.server_capabilities.documentRangeFormattingProvider
    end)

    -- --- Structure ---

    -- Document symbols (outline of current file)
    buf_set_keymap("n", "gs", "<cmd>LspDocumentSymbol<CR>", "Document symbols", function(c)
        return c.server_capabilities.documentSymbolProvider
    end)

    -- Workspace symbols (search symbols across project)
    buf_set_keymap("n", "gS", "<cmd>LspWorkspaceSymbol<CR>", "Workspace symbols", function(c)
        return c.server_capabilities.workspaceSymbolProvider
    end)

    -- --- Diagnostics (Manual Navigation) ---
    -- These do not require specific server capabilities
    buf_set_keymap("n", "dc", "<cmd>LspShowDiagnosticCurrent<CR>", "Show line diagnostics")
    buf_set_keymap("n", "dn", "<cmd>LspShowDiagnosticNext<CR>", "Next diagnostic")
    buf_set_keymap("n", "dp", "<cmd>LspShowDiagnosticPrev<CR>", "Previous diagnostic")

    -- --- Advanced Features ---

    -- Run CodeLens (actionable context within code)
    buf_set_keymap("n", "gL", "<cmd>LspCodeLensRun<CR>", "Run CodeLens", function(c)
        return c.server_capabilities.codeLensProvider
    end)

    -- Call Hierarchy (who calls this function? / who does this function call?)
    buf_set_keymap("n", "glc", "<cmd>LspIncomingCalls<CR>", "Incoming calls", function(c)
        return c.server_capabilities.callHierarchyProvider
    end)

    buf_set_keymap("n", "glC", "<cmd>LspOutgoingCalls<CR>", "Outgoing calls", function(c)
        return c.server_capabilities.callHierarchyProvider
    end)

    -- Document Highlight (manual triggers)
    buf_set_keymap("n", "ghr", "<cmd>LspDocumentHighlight<CR>", "Highlight references", function(c)
        return c.server_capabilities.documentHighlightProvider
    end)

    buf_set_keymap("n", "ghc", "<cmd>LspClearReferences<CR>", "Clear highlights", function(c)
        return c.server_capabilities.documentHighlightProvider
    end)

    -- --- Workspace Management ---
    
    buf_set_keymap("n", "goa", "<cmd>LspAddToWorkspaceFolder<CR>", "Add folder to workspace", function(c)
        return c.server_capabilities.workspace and c.server_capabilities.workspace.workspaceFolders
    end)

    buf_set_keymap("n", "gor", "<cmd>LspRemoveWorkspaceFolder<CR>", "Remove folder from workspace", function(c)
        return c.server_capabilities.workspace and c.server_capabilities.workspace.workspaceFolders
    end)

    buf_set_keymap("n", "gol", "<cmd>LspListWorkspaceFolders<CR>", "List workspace folders", function(c)
        return c.server_capabilities.workspace and c.server_capabilities.workspace.workspaceFolders
    end)

    -- Debug Adapter Protocol (Custom command for local debug config)
    buf_set_keymap("n", "<Leader>dp", "<cmd>DAPLocal<CR>", "Start local debugging")
end

return M
