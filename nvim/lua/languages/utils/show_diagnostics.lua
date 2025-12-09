local api = vim.api
local util = vim.lsp.util
local protocol = vim.lsp.protocol
local DiagnosticSeverity = protocol.DiagnosticSeverity

local M = {}

-- Define padding around the text inside the floating window (top, bottom, left, right)
local padding = {
    pad_top = 1,
    pad_bottom = 1,
    pad_right = 3,
    pad_left = 3,
}

--- Adds spaces around the content lines based on the padding configuration.
--- Also adds empty lines at the top and bottom if configured.
local function trim_and_pad(contents, opts)
    opts = opts or {}
    local left_padding = (" "):rep(opts.pad_left or 1)
    local right_padding = (" "):rep(opts.pad_right or 1)
    
    -- Add left/right padding to each line
    for i, line in ipairs(contents) do
        contents[i] = string.format("%s%s%s", left_padding, line:gsub("\r", ""), right_padding)
    end
    
    -- Add top vertical padding
    if opts.pad_top then
        for _ = 1, opts.pad_top do
            table.insert(contents, 1, "")
        end
    end
    
    -- Add bottom vertical padding
    if opts.pad_bottom then
        for _ = 1, opts.pad_bottom do
            table.insert(contents, "")
        end
    end
    return contents
end

--- Calculates the optimal width and height for the floating window based on its content.
--- Handles wrapping if the content exceeds max_width.
local function make_floating_popup_size(contents, opts)
    opts = opts or {}
    local width = opts.width
    local height = opts.height
    local wrap_at = opts.wrap_at
    local max_width = opts.max_width
    local max_height = opts.max_height
    local line_widths = {}

    -- If width is not fixed, calculate it based on the longest line
    if not width then
        width = 0
        for i, line in ipairs(contents) do
            line_widths[i] = vim.fn.strdisplaywidth(line)
            width = math.max(line_widths[i], width)
        end
    end

    -- Cap the width at max_width
    if max_width then
        width = math.min(width, max_width)
        wrap_at = math.min(wrap_at or max_width, max_width)
    end

    -- Calculate height based on wrapping if necessary
    if not height then
        height = #contents
        if wrap_at and width >= wrap_at then
            height = 0
            if vim.tbl_isempty(line_widths) then
                for _, line in ipairs(contents) do
                    local line_width = vim.fn.strdisplaywidth(line)
                    height = height + math.ceil(line_width / wrap_at)
                end
            else
                for i = 1, #contents do
                    height = height + math.max(1, math.ceil(line_widths[i] / wrap_at))
                end
            end
        end
    end

    -- Cap the height at max_height
    if max_height then
        height = math.min(height, max_height)
    end

    return width, height
end

--- Creates and opens the floating window buffer.
--- Sets up cleanup autocommands to close the window when the cursor moves.
local function open_floating_preview(contents, syntax)
    contents = trim_and_pad(contents, padding)
    
    -- Calculate window dimensions
    local width, height = make_floating_popup_size(contents, {
        max_width = 130,
    })

    -- Create a new unlisted scratch buffer
    local floating_bufnr = api.nvim_create_buf(false, true)
    if syntax then
        api.nvim_set_option_value("filetype", syntax, { buf = floating_bufnr })
    end

    -- Create window options (positioning handled by nvim core util)
    local float_option = util.make_floating_popup_options(width, height)
    
    -- Open the window without entering it (enter = false)
    local floating_winnr = api.nvim_open_win(floating_bufnr, false, float_option)
    
    -- Ensure focus stays on the original window
    api.nvim_command("noautocmd wincmd p")

    -- Configure window appearance (transparency, conceal)
    if syntax == "markdown" then
        api.nvim_win_set_var(floating_winnr, "conceallevel", 2)
    end
    api.nvim_win_set_var(floating_winnr, "winblend", 0) -- 0 = opaque, 100 = fully transparent

    -- Set buffer content and make it read-only
    api.nvim_buf_set_lines(floating_bufnr, 0, -1, true, contents)
    api.nvim_buf_set_var(floating_bufnr, "modifiable", false)
    api.nvim_buf_set_var(floating_bufnr, "bufhidden", "wipe")

    -- Auto-close the popup when moving the cursor or entering insert mode
    vim.defer_fn(function()
        api.nvim_command(
            "autocmd CursorMoved,CursorMovedI,BufHidden,InsertCharPre <buffer> lua pcall(vim.api.nvim_win_close, "
                .. floating_winnr
                .. ", true)"
        )
    end, 60) -- Slight delay to prevent immediate closing

    return floating_bufnr, floating_winnr
end

-- Map diagnostic severity levels to highlight group names
local floating_severity_highlight_name = {
    [DiagnosticSeverity.Error] = "DiagnosticError",
    [DiagnosticSeverity.Warning] = "DiagnosticWarn",
    [DiagnosticSeverity.Information] = "DiagnosticInfo",
    [DiagnosticSeverity.Hint] = "DiagnosticHint",
}

--- Main function to display diagnostics for the current line in a custom floating window.
M.show_line_diagnostics = function()
    local bufnr = 0
    local line_nr = api.nvim_win_get_cursor(0)[1] - 1 -- 0-based index
    local lines = {}
    local highlights = {}

    -- Get all diagnostics on the current line
    local line_diagnostics = vim.diagnostic.get(bufnr, { lnum = line_nr })
    if vim.tbl_isempty(line_diagnostics) then
        return
    end

    -- Format the diagnostic messages
    for i, diagnostic in ipairs(line_diagnostics) do
        local prefix = string.format("%d. (%s) ", i, diagnostic.source or "unknown")
        local hiname = floating_severity_highlight_name[diagnostic.severity]
        assert(hiname, "unknown severity: " .. tostring(diagnostic.severity))
        
        local message_lines = vim.split(diagnostic.message, "\n", { trimempty = true })
        
        -- First line includes the prefix (source)
        table.insert(lines, prefix .. message_lines[1])
        table.insert(highlights, { #prefix, hiname })
        
        -- Subsequent lines just have the message
        for j = 2, #message_lines do
            table.insert(lines, message_lines[j])
            table.insert(highlights, { 0, hiname })
        end
    end

    -- Open the window
    local popup_bufnr, winnr = open_floating_preview(lines, "plaintext")
    api.nvim_buf_set_var(popup_bufnr, "buftype", "prompt")

    -- Apply highlighting (coloring) to the text inside the popup
    local ns_id = vim.api.nvim_create_namespace("diagnostics_popup")
    for i, hi in ipairs(highlights) do
        local prefixlen, hiname = unpack(hi)
        
        -- Highlight the source prefix (e.g., "1. (eslint) ")
        vim.highlight.range(
            popup_bufnr,
            ns_id,
            "DiagnosticSourceInfo",
            { i - 1 + padding.pad_top, padding.pad_left },
            { i - 1 + padding.pad_top, padding.pad_left + prefixlen },
            {}
        )
        
        -- Highlight the actual message using the severity color (Error=Red, Warn=Yellow, etc.)
        vim.highlight.range(
            popup_bufnr,
            ns_id,
            hiname,
            { i - 1 + padding.pad_top, prefixlen + padding.pad_left },
            { i - 1 + padding.pad_top, -1 }, -- Highlight to end of line
            {}
        )
    end

    return popup_bufnr, winnr
end

--- Jump to the next diagnostic and immediately show the custom popup.
M.goto_next = function()
    vim.diagnostic.jump({
        count = 1,
        float = false, -- Disable native float so we can show our custom one
    })
    M.show_line_diagnostics()
end

--- Jump to the previous diagnostic and immediately show the custom popup.
M.goto_prev = function()
    vim.diagnostic.jump({
        count = -1,
        float = false,
    })
    M.show_line_diagnostics()
end

--- Custom wrapper for opening diagnostics (used as a fallback or specific call).
M.line = function(opts)
    opts = vim.tbl_deep_extend("error", {
        pos = -1000,
    }, opts or {})
    vim.diagnostic.open_float(opts)
    M.show_line_diagnostics()
end

return M
