vim.pack.add({
  { src = "https://github.com/catppuccin/nvim" },
  { src = "https://github.com/maxmx03/fluoromachine.nvim" },
  { src = "https://github.com/ribru17/bamboo.nvim" },
})

-- Bamboo Theme
local bamboo_opts = {
  style = "multiplex",
  transparent = true,

  -- lualine = {
  --   transparent = true,
  -- },

  code_style = {
    comments = { italic = true },
    conditionals = { italic = true },
    keywords = {},
    functions = {},
    namespaces = { italic = true },
    parameters = { italic = true },
    strings = {},
    variables = {},
  },

  colors = {
    bg0 = "#333333",
    red = "#CB4251",
    aqua = "#0fb9e0",
    lime = "#2ed592",
    green = "#2ed563",
    orange = "#F37A2E",
    yellow = "#EADD61",
    blue = "#38D0EF",
    pink = "#f45ab4",
    cyan = "#37c3b5",
    purple = "#be9af7",
    grey = "#888888",
    fg = "#e0e0e0",
    bg1 = "#2a2a2a",
  },

  highlights = {
    Comment = { fg = "#6D90A8", fmt = "italic" },
    ["@comment"] = { link = "Comment" },

    PmenuMatch = { bg = "#555555", fg = "#FFB870", fmt = "bold" },
    PmenuMatchSel = { bold = true, sp = "#333333" },

    FloatTitle = { fg = "#CB4251", fmt = "bold" },
    FloatBorder = { fg = "#3B38A0" },

    Type = { fg = "#EADD61", fmt = "bold" },

    TablineFill = { fg = "#888888", bg = "#333333" },
    MiniTablineFill = { fg = "#888888", bg = "#333333" },
    MiniTablineHidden = { fg = "#e0e0e0", bg = "#2a2a2a" },

    ["@keyword.import"] = { fg = "#2ed592", fmt = "bold" },
    ["@keyword.export"] = { fg = "#2ed592", fmt = "bold" },

    ["@lsp.typemod.enum"] = { fg = "#61AEFF", fmt = "bold" },
    ["@lsp.typemod.enumMember"] = { fg = "#9EC410", fmt = "bold" },
    ["@lsp.typemod.enum.rust"] = { fg = "#61AEFF", fmt = "bold" },
    ["@lsp.typemod.enumMember.rust"] = { fg = "#9EC410", fmt = "bold" },

    ["@lsp.type.modifier"] = { link = "@keyword.modifier" },
    ["@lsp.type.interface"] = { fg = "#D4A017", fmt = "bold,italic" },

    BlinkCmpMenu = { bg = "#333333" },
    BlinkCmpDoc = { bg = "#333333" },

    SnacksPickerMatch = { link = "PmenuMatch" },

    BlinkIndentRed = { link = "RainbowDelimiterRed" },
    BlinkIndentOrange = { link = "RainbowDelimiterOrange" },
    BlinkIndentYellow = { link = "RainbowDelimiterYellow" },
    BlinkIndentGreen = { link = "RainbowDelimiterGreen" },
    BlinkIndentCyan = { link = "RainbowDelimiterCyan" },
    BlinkIndentBlue = { link = "RainbowDelimiterBlue" },
    BlinkIndentViolet = { link = "RainbowDelimiterViolet" },

    BlinkIndentRedUnderline = { link = "RainbowDelimiterRed" },
    BlinkIndentOrangeUnderline = { link = "RainbowDelimiterOrange" },
    BlinkIndentYellowUnderline = { link = "RainbowDelimiterYellow" },
    BlinkIndentGreenUnderline = { link = "RainbowDelimiterGreen" },
    BlinkIndentCyanUnderline = { link = "RainbowDelimiterCyan" },
    BlinkIndentBlueUnderline = { link = "RainbowDelimiterBlue" },
    BlinkIndentVioletUnderline = { link = "RainbowDelimiterViolet" },
  },
}

require("bamboo").setup(bamboo_opts)

-- Fluoromachine
local fm = require("fluoromachine")

fm.setup({
  glow = true,
  theme = "fluoromachine",
  transparent = true,
  brightness = 0.05,
})

-- Catppuccin
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

-- Apply colorscheme
vim.defer_fn(function()
  -- vim.cmd("colorscheme catppuccin")
  -- vim.cmd("colorscheme fluoromachine")
  vim.cmd("colorscheme bamboo")
end, 20)

vim.cmd.hi("statusline guibg=NONE")
vim.cmd.hi("Comment gui=none")
