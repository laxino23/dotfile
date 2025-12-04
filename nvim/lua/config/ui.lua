local M = {}

M.icons = {
  -- Standard LSP Kind Icons
  -- 标准 LSP 类型图标
  default_kind_icons = {
    Array = "",
    Boolean = "󰨙",
    Class = "",
    Collapsed = "",
    Color = "",
    Component = "󰅴",
    Constant = "",
    Constructor = "",
    Control = "",
    Copilot = "",
    Enum = "",
    EnumMember = "",
    Event = "",
    Field = "",
    File = "",
    Folder = "",
    Fragment = "󰩦",
    Function = "",
    Interface = "",
    Key = "",
    Keyword = "",
    Macro = "󰁥",
    Method = "",
    Module = "",
    Namespace = "󰦮",
    Null = "",
    Number = "󰎠",
    Object = "",
    Operator = "",
    Package = "",
    Parameter = "",
    Property = "",
    Reference = "",
    Snippet = "",
    StaticMethod = "󰰑",
    String = "",
    Struct = "",
    Text = "",
    TypeAlias = "",
    TypeParameter = "",
    Unit = "",
    Value = "󰎠",
    Variable = "",
  },

  -- Icons specifically for mini.nvim
  -- 专为 mini.nvim 适配的图标
  mini_kind_icons = {
    Copilot = " ",
    Codeium = "󰘦 ",
    Array = " ",
    Boolean = " ",
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Enum = " ",
    EnumMember = " ", -- Fixed capitalization (修复了大小写)
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    ["Function"] = " ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = " ",
    Module = " ",
    Namespace = " ",
    Null = " ",
    Number = " ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = " ",
    String = " ",
    Struct = " ",
    Text = " ",
    TypeParameter = " ", -- Fixed capitalization (修复了大小写)
    Unit = " ",
    Value = " ",
    Variable = " ",
  },

  -- Icons for lazy.nvim
  -- lazy.nvim 插件管理器图标
  lazy_kind_icons = {
    Array = " ",
    Boolean = "󰨙 ",
    Class = " ",
    Codeium = "󰘦 ",
    Color = " ",
    Control = " ",
    Collapsed = " ",
    Constant = "󰏿 ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = "󰊕 ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = " ",
    Module = " ",
    Namespace = "󰦮 ",
    Null = " ",
    Number = "󰎠 ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = "󱄽 ",
    String = " ",
    Struct = "󰆼 ",
    Supermaven = " ",
    TabNine = "󰏚 ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = "󰀫 ",
  },

  -- Icons for lspkind plugin
  -- lspkind 插件图标
  lspkind_kind_icons = {
    String = " ",
    Object = " ",
    Array = " ",
    Boolean = "󰨙 ",
    Text = "󰉿",
    Number = "󰎠 ",
    Method = "󰊕",
    Function = "󰊕",
    Constructor = "",
    Field = "󰜢",
    Variable = "󰀫",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Namespace = "󰦮 ",
    Property = "󰜢",
    Unit = "󰑭",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "󱄽 ",
    Color = "󰏘",
    File = "󰈙",
    Reference = "󰈇",
    Folder = "󰉋",
    EnumMember = "",
    Constant = " ",
    Struct = "󰙅",
    Event = "",
    Operator = "󰆕",
    TypeParameter = " ",
    Codeium = "󰚩",
    Copilot = "",
    Control = "",
    Collapsed = "",
    Component = "󰅴",
    Fragment = "󰩦",
    Key = "",
    Macro = "󰁥",
    Null = "",
    Package = "",
    Parameter = "",
    StaticMethod = "󰰑",
    TypeAlias = "",
  },

  -- Miscellaneous UI elements
  -- 杂项 UI 元素
  misc = {
    dots = "󰇘",
    bug = "",
    dashed_bar = "┊",
    ellipsis = "…",
    git = "",
    palette = "󰏘",
    robot = "󰚩",
    search = "",
    terminal = "",
    toolbox = "󰦬",
    vertical_bar = "│",
  },

  -- Filetype specific icons
  -- 特定文件类型的图标
  ft = {
    octo = "",
  },

  -- Debug Adapter Protocol (DAP) icons
  -- 调试适配器协议 (DAP) 图标
  dap = {
    Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = " ",
    BreakpointCondition = " ",
    BreakpointRejected = { " ", "DiagnosticError" },
    LogPoint = ".>",
  },

  -- Diagnostic signs
  -- 诊断标志 (错误、警告等)
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
    debug = "󰠠 ",
  },

  -- Git integration icons
  -- Git 集成图标
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },

  -- Code folding icons
  -- 代码折叠图标
  fold = {
    open = "",
    close = "",
    omit = "󰇘",
    lines = "󱞡", -- "󱞢"
    chevron = { open = "", close = "" },
    arrow = { open = "", close = "" },
    triangle = { open = "▼", close = "▶" },
    plus_minus = { open = "", close = "" },
  },

  -- Mason package manager icons
  -- Mason 包管理器图标
  mason = {
    package_installed = "",
    package_pending = "",
    package_uninstalled = "",
  },
}

-- Rainbow bracket colors
-- 彩虹括号颜色配置
M.rainbow_colors = {
  red = "#FF5555",
  orange = "#FFB86C",
  yellow = "#F1FA8C",
  green = "#50FA7B",
  cyan = "#8BE9FD",
  blue = "#0079FF",
  purple = "#BD93F9",
}

-- Custom draw functions for completion menu (Blink.cmp or Custom nvim-cmp)
-- 补全菜单的自定义绘制函数
M.cmp_draw = {
  mini = {
    kind_icon = {
      text = function(ctx)
        -- Retrieve icon from mini.icons
        -- 从 mini.icons 获取图标
        local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
        return kind_icon
      end,
      highlight = function(ctx)
        local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
        return hl
      end,
    },
    kind = {
      text = function(ctx)
        return "[" .. ctx.kind .. "]"
      end,
      highlight = function(ctx)
        local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
        return hl
      end,
    },
  },
  lspkind = {
    kind_icon = {
      text = function(ctx)
        local icon = ctx.kind_icon
        -- Check if source is a file path
        -- 检查来源是否为文件路径
        if vim.tbl_contains({ "Path" }, ctx.source_name) then
          local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
          if dev_icon then
            icon = dev_icon
          end
        else
          -- Use lspkind symbol
          -- 使用 lspkind 符号
          icon = require("lspkind").symbolic(ctx.kind, {
            mode = "symbol",
          })
        end
        return icon .. ctx.icon_gap
      end,
      highlight = function(ctx)
        local hl = ctx.kind_hl
        if vim.tbl_contains({ "Path" }, ctx.source_name) then
          local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
          if dev_icon then
            hl = dev_hl
          end
        end
        return hl
      end,
    },
    kind = {
      text = function(ctx)
        return "[" .. ctx.kind .. "]"
      end,
      highlight = function(ctx)
        local hl = ctx.kind_hl
        if vim.tbl_contains({ "Path" }, ctx.source_name) then
          local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
          if dev_icon then
            hl = dev_hl
          end
        end
        return hl
      end,
    },
  },
}

return M
