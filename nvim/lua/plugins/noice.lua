vim.pack.add({
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/rcarriga/nvim-notify" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  {
    src = "https://github.com/folke/noice.nvim",
    name = "noice",
    version = vim.version.range(">=4.0"),
  },
})

local icons = require("config.ui").icons

vim.opt.cmdheight = 1
vim.opt.shortmess:append("at")
vim.cmd([[
  augroup NoMoreHitEnter
    autocmd!
    " 对启动消息使用 silent redraw
    autocmd VimEnter * silent! redraw!
  augroup END
]])

require("noice").setup({

  ---------------------------------------------------------------------------
  -- CMDLINE
  ---------------------------------------------------------------------------
  cmdline = {
    enabled = true,
    view = "cmdline_popup",

    -- popup 样式
    opts = {
      border = { style = "rounded" },
      win_options = {
        winhighlight = {
          Normal = "NoiceCmdlinePopup",
          FloatBorder = "NoiceCmdlinePopupBorder",
        },
      },
    },

    -------------------------------------------------------------------------
    -- 智能匹配不同命令类型的图标
    -------------------------------------------------------------------------
    format = {
      cmdline = {
        pattern = "^:",
        icon = "󰘳 ",
        lang = "vim",
      },

      -- 搜索
      search_down = { pattern = "^/", icon = " 󰁊", lang = "regex" },
      search_up = { pattern = "^%?", icon = " 󰁅", lang = "regex" },

      -- 文件编辑 :e
      file = {
        pattern = "^:%s*e%s+",
        icon = "󰈔 ",
        lang = "vim",
      },

      -- substitute
      substitute = {
        pattern = "^:%s*s/",
        icon = " ",
        lang = "regex",
      },

      -- shell 命令 :!
      filter = {
        pattern = "^:%s*!",
        icon = " ",
        lang = "bash",
      },

      -- Lua 执行
      lua = {
        pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
        icon = " ",
        lang = "lua",
      },

      -- help
      help = {
        pattern = "^:%s*he?l?p?%s+",
        icon = "󰋖 ",
        lang = "vim",
      },

      -- Git
      git = {
        pattern = "^:%s*git%s+",
        icon = "󰊢 ",
        lang = "git",
      },

      -- Telescope
      telescope = {
        pattern = "^:%s*Telescope%s+",
        icon = " ",
        lang = "vim",
      },

      -- Lazy
      lazy = {
        pattern = "^:%s*Lazy%s*",
        icon = "󰒲 ",
        lang = "vim",
      },

      -- Mason
      mason = {
        pattern = "^:%s*Mason%s*",
        icon = "󰏖 ",
        lang = "vim",
      },

      -- Node
      node = {
        pattern = "^:%s*node%s+",
        icon = " ",
        lang = "bash",
      },

      -- NPM / Yarn / Pnpm
      npm = {
        pattern = "^:%s*npm%s+",
        icon = " ",
        lang = "bash",
      },
      yarn = {
        pattern = "^:%s*yarn%s+",
        icon = " ",
        lang = "bash",
      },
      pnpm = {
        pattern = "^:%s*pnpm%s+",
        icon = " ",
        lang = "bash",
      },

      -- Rust / Cargo
      cargo = {
        pattern = "^:%s*cargo%s+",
        icon = " ",
        lang = "bash",
      },
      rust = {
        pattern = "^:%s*rust%s+",
        icon = " ",
        lang = "bash",
      },

      -- Zig
      zig = {
        pattern = "^:%s*zig%s+",
        icon = " ",
        lang = "bash",
      },

      -- Go
      go = {
        pattern = "^:%s*go%s+",
        icon = " ",
        lang = "bash",
      },

      -- Make
      make = {
        pattern = "^:%s*make%s+",
        icon = " ",
        lang = "bash",
      },

      -- fallback
      input = {},
    },
  },

  ---------------------------------------------------------------------------
  -- POPUPMENU
  ---------------------------------------------------------------------------
  popupmenu = {
    enabled = true,
    backend = "nui",
  },

  ---------------------------------------------------------------------------
  -- MESSAGE SYSTEM
  ---------------------------------------------------------------------------
  messages = {
    enabled = true,
    view = "notify",
    view_error = "notify",
    view_warn = "notify",
    view_history = "messages",
    view_search = "virtualtext",
  },

  ---------------------------------------------------------------------------
  -- NOTIFY
  ---------------------------------------------------------------------------
  notify = {
    enabled = true,
    view = "notify",
  },

  ---------------------------------------------------------------------------
  -- LSP
  ---------------------------------------------------------------------------
  lsp = {
    progress = {
      enabled = true,
      view = "mini",
    },

    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },

    hover = {
      enabled = true,
      silent = true,
      view = "popup",
      opts = { border = "rounded" },
    },

    signature = {
      enabled = false,
    },

    documentation = {
      view = "hover",
      opts = {
        lang = "markdown",
        replace = true,
        render = "plain",
        border = "rounded",
        win_options = {
          concealcursor = "n",
          conceallevel = 3,
        },
      },
    },
  },

  ---------------------------------------------------------------------------
  -- PRESETS
  ---------------------------------------------------------------------------
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = true,
    lsp_doc_border = true,
  },

  ---------------------------------------------------------------------------
  -- VIEWS
  ---------------------------------------------------------------------------
  views = {
    cmdline_popup = {
      position = {
        row = "33%",
        col = "50%",
      },
      size = {
        width = "60%",
        height = "auto",
        max_height = 15,
      },
      border = { style = "rounded" },
    },

    popupmenu = {
      relative = "editor",
      position = {
        row = "66%",
        col = "50%",
      },
      size = {
        width = 60,
        height = 10,
      },
      border = {
        style = "rounded",
      },
      win_options = {
        winhighlight = {
          Normal = "Normal",
          FloatBorder = "NoicePopupBorder",
        },
      },
    },

    mini = {
      border = "rounded",
      timeout = 2000,
      win_options = {
        winblend = 0,
      },
    },

    notify = {
      render = "compact",
      stages = "fade",
      timeout = 3000,
    },

    split = {
      enter = true,
    },
  },

  ---------------------------------------------------------------------------
  -- ROUTES（过滤消息）
  ---------------------------------------------------------------------------
  routes = {
    { filter = { event = "msg_show", find = "written" }, view = "mini" },
    { filter = { event = "msg_show", find = "%d+L, %d+B" }, view = "mini" },
    { filter = { event = "msg_show", find = "more lines?" }, skip = true },
    { filter = { event = "msg_show", find = "fewer lines?" }, skip = true },
    { filter = { event = "lsp", kind = "progress" }, view = "mini" },
  },

  ---------------------------------------------------------------------------
  -- ICONS (NOICE LEVEL)
  ---------------------------------------------------------------------------
  format = {
    level = {
      icons = {
        error = icons.diagnostics.Error,
        warn = icons.diagnostics.Warn,
        info = icons.diagnostics.Info,
        hint = icons.diagnostics.Hint,
      },
    },
  },
})

-------------------------------------------------------------------------------
-- HIGHLIGHT (主题加载后)
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg or "#1e1e2e"
    local fg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).fg or "#cdd6f4"

    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#89b4fa", bg = "none" })
    vim.api.nvim_set_hl(0, "NoicePopupBorder", { fg = "#89b4fa", bg = "none" })
    vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { fg = fg, bg = bg })
    vim.api.nvim_set_hl(0, "NoiceMini", { fg = "#cba6f7", bg = "none" })
    vim.api.nvim_set_hl(0, "NoiceLspProgressTitle", { fg = "#94e2d5", bold = true })
    vim.api.nvim_set_hl(0, "NoiceLspProgressClient", { fg = "#f9e2af" })
  end,
})

vim.api.nvim_exec2("colorscheme catppuccin-mocha", {})

-------------------------------------------------------------------------------
-- NOTIFY SETTINGS
-------------------------------------------------------------------------------
require("notify").setup({
  background_colour = "#00000000",
  fps = 60,
  level = 2,
  minimum_width = 50,
  render = "compact",
  stages = "fade",
  timeout = 3000,
  top_down = true,
  icons = {
    ERROR = icons.diagnostics.Error,
    WARN = icons.diagnostics.Warn,
    INFO = icons.diagnostics.Info,
    HINT = icons.diagnostics.Hint,
    DEBUG = icons.diagnostics.Debug,
  },
})
vim.notify = require("notify")
