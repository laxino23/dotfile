local M = {}

M.icons = {
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
    Enummember = " ",
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
    Typeparameter = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
  },

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
  ft = {
    octo = "",
  },
  dap = {
    Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = " ",
    BreakpointCondition = " ",
    BreakpointRejected = { " ", "DiagnosticError" },
    LogPoint = ".>",
  },
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
    debug = "󰠠 ",
  },
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },
  fold = {
    open = "",
    close = "",
    chevron = { open = "", close = "" },
    arrow = { open = "", close = "" },
    triangle = { open = "▼", close = "▶" },
    plus_minus = { open = "", close = "" },
  },
}

M.rainbow_colors = {
  red = "#E82424",
  orange = "#cc6d00",
  yellow = "#de9800",
  green = "#5e857a",
  cyan = "#4e8ca2",
  blue = "#4d699b",
  purple = "#957FB8",
}

M.cmp_draw = {
  mini = {
    kind_icon = {
      text = function(ctx)
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
        if vim.tbl_contains({ "Path" }, ctx.source_name) then
          local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
          if dev_icon then
            icon = dev_icon
          end
        else
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
