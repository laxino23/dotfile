---@param names table
local function use(names)
  for _, name in ipairs(names) do
    require("plugins." .. name)
  end
end

use({
  "treesitter",
  "themes",
  "conform",
  "blink",
  "lsp",
  "mini",
  "misc",
  "snacks",
  "indent",
  "heirline",
  "overseer",
  "noice",
  "multicursor",
  "folding",
})
