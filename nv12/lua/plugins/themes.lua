vim.pack.add({
  { src = "https://github.com/catppuccin/nvim" },
  { src = "https://github.com/maxmx03/fluoromachine.nvim" },
})

local fm = require("fluoromachine")

fm.setup({
  glow = true,
  theme = "fluoromachine",
  transparent = false,
  brightness = 0.05,
})

require("catppuccin").setup({
  transparent_background = true,
  term_colors = true,
  integrations = {
    aerial = true,
    diffview = true,
    mini = {
      enabled = true,
      indentscope_color = "sky",
    },
    noice = true,
    overseer = true,
    telescope = {
      enabled = true,
      style = "nvchad",
    },
    treesitter = true,
    gitsigns = true,
    flash = true,
    blink_cmp = true,
    mason = true,
    snacks = true,
  },
  highlight_overrides = {
    mocha = function(mocha)
      return {
        CursorLineNr = { fg = mocha.yellow },
        FlashCurrent = { bg = mocha.peach, fg = mocha.base },
        FlashMatch = { bg = mocha.red, fg = mocha.base },
        FlashLabel = { bg = mocha.teal, fg = mocha.base },
        NormalFloat = { bg = mocha.base },
        FloatBorder = { bg = mocha.base },
        FloatTitle = { bg = mocha.base },
        RenderMarkdownCode = { bg = mocha.crust },
        Pmenu = { bg = mocha.base },
      }
    end,
  },
})
vim.cmd("colorscheme catppuccin")
-- vim.cmd.colorscheme("fluoromachine")
vim.cmd.hi("statusline guibg=NONE")
vim.cmd.hi("Comment gui=none")
