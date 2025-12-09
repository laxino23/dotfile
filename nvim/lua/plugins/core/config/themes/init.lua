local icons = require("config.ui.icons")

return {
    catppuccin = {
        config = function()
            local catppuccin_status_ok, catppuccin = pcall(require, "catppuccin")
            if not catppuccin_status_ok then
                return
            end

            catppuccin.setup({
                flavour = "auto",
                background = {
                    light = "latte",
                    dark = "mocha",
                },
                transparent_background = false,
                float = {
                    transparent = false,
                    solid = false,
                },
                show_end_of_buffer = false,
                term_colors = false,
                dim_inactive = {
                    enabled = false,
                    shade = "dark",
                    percentage = 0.15,
                },
                no_italic = false,
                no_bold = false,
                no_underline = false,
                styles = {
                    comments = { "italic" },
                    conditionals = { "italic" },
                    loops = {},
                    functions = {},
                    keywords = {},
                    strings = {},
                    variables = {},
                    numbers = {},
                    booleans = {},
                    properties = {},
                    types = {},
                    operators = {},
                },
                lsp_styles = {
                    virtual_text = {
                        errors = { "italic" },
                        hints = { "italic" },
                        warnings = { "italic" },
                        information = { "italic" },
                        ok = { "italic" },
                    },
                    underlines = {
                        errors = { "underline" },
                        hints = { "underline" },
                        warnings = { "underline" },
                        information = { "underline" },
                        ok = { "underline" },
                    },
                    inlay_hints = {
                        background = true,
                    },
                },
                color_overrides = {},
                custom_highlights = {},
                default_integrations = true,
                auto_integrations = false,
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    notify = false,
                    mini = {
                        enabled = true,
                        indentscope_color = "",
                    },
                },
            })
            vim.cmd("colorscheme " .. _G.THEME)
        end
    },

    lvim_colorscheme = {
        config = function()
            local lvim_colorscheme_status_ok, lvim_colorscheme = pcall(require, "lvim-colorscheme")
            if not lvim_colorscheme_status_ok then
                return
            end

            lvim_colorscheme.setup({
                cache = false,
                transparent = false,
                dim_active = true,
                styles = {
                    floats = "dark",
                    sidebars = "dark",
                },
                on_highlights = function(hl, c)
                    hl.FloatBorder = {
                        bg = c.bg_float,
                        fg = c.bg_float,
                    }
                end,
            })
            vim.cmd("colorscheme " .. _G.THEME)
        end,
    },

    bamboo = {
        config = function()
            local bamboo_status_ok, bamboo = pcall(require, "bamboo")
            if not bamboo_status_ok then
                return
            end
            bamboo.setup({
            style = "multiplex", -- Choose between 'vulgaris' (regular), 'multiplex' (greener), and 'light'
              transparent = vim.g.transparent,
              lualine = {
                transparent = true, -- lualine center bar transparency
              },
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
                yellow = "#EADD61", --"#f0be42",
                blue = "#38D0EF",
                pink = "#f45ab4",
                cyan = "#37c3b5",
                purple = "#be9af7",
              },
              highlights = {
                Comment = { fg = "#6D90A8", fmt = "italic" },
                ["@comment"] = { link = "Comment" },
                PmenuMatch = { bg = "#555555", fg = "#FFB870", fmt = "bold" },
                PmenuMatchSel = { bold = true, sp = "bg0" },
                FloatTitle = { fg = "$red", fmt = "bold" },
                FloatBorder = { fg = "#3B38A0" },
                Type = { fg = "$yellow", fmt = "bold" },
                TablineFill = { fg = "$grey", bg = "bg0" },
                MiniTablineFill = { fg = "$grey", bg = "bg0" },
                MiniTablineHidden = { fg = "$fg", bg = "$bg1" },
                ["@keyword.import"] = { fg = "#2ed592", fmt = "bold" },
                ["@keyword.export"] = { fg = "#2ed592", fmt = "bold" },

                ["@lsp.typemod.enum"] = { fg = "#61AEFF", fmt = "bold" },
                ["@lsp.typemod.enumMember"] = { fg = "#9EC410", fmt = "bold" },
                ["@lsp.typemod.enum.rust"] = { fg = "#61AEFF", fmt = "bold" },
                ["@lsp.typemod.enumMember.rust"] = { fg = "#9EC410", fmt = "bold" },

                ["@lsp.type.modifier"] = { link = "@keyword.modifier" },
                ["@lsp.type.interface"] = { fg = "#D4A017", fmt = "bold,italic" },

                BlinkCmpMenu = { bg = "$bg0" },
                BlinkCmpDoc = { bg = "$bg0" },

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
  })
            vim.cmd("colorscheme " .. _G.THEME)
        end,
    },
}
