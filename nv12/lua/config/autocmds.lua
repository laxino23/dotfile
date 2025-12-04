-- guide lines for cursorline
local function set_transparent_guides()
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE", underline = true, bold = true })
  vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE", fg = "#ff9e64", bold = true })
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#1f1f1f", fg = "NONE" })
end

set_transparent_guides()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_transparent_guides,
})

-- Set scrolloff to 25% of window height
vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
  callback = function()
    local height = vim.api.nvim_win_get_height(0)
    vim.wo.scrolloff = math.floor(height * 0.25)
  end,
})

-- Set initial value
vim.o.scrolloff = math.floor(vim.o.lines * 0.25)

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", "typescript", "react", "json", "html", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "c", "cpp", "rust" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})
-- Disable auto-comment on o and O
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "o" })
  end,
})
