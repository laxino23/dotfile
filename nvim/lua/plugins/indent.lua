-- Load plugins via vim.pack / 通过 vim.pack 加载插件
vim.pack.add({
  { src = "https://github.com/saghen/blink.indent", load = false },
  { src = "https://github.com/HiPhish/rainbow-delimiters.nvim", load = false },
})

-- Shared configuration / 共享配置
local rainbow_filetypes = {
  "html",
  "clojure",
  "query",
  "scheme",
  "lisp",
  "commonlisp",
  "php",
  "javascriptreact",
  "typescriptreact",
  "rust",
  "go",
  "lua",
}

-- Initialize blink.indent / 初始化 blink.indent
local function init_blink_indent()
  vim.cmd.packadd("blink.indent")
  require("blink.indent").setup({
    blocked = {
      buftypes = { include_defaults = true },
      filetypes = {
        include_defaults = true,
        "snacks_picker_input",
        "snacks_picker_list",
        "snacks_picker_preview",
        "snacks_terminal",
        "mason",
        "lazy",
        "fzf",
        "oil",
      },
    },
    static = {
      enabled = false,
      char = "",
      priority = 1,
      -- Sync with Rainbow Colors / 与彩虹色同步
      highlights = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    },
    scope = {
      enabled = true,
      char = "║",
      priority = 1000,
      highlights = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
      underline = { enabled = false },
    },
  })
end

-- Initialize rainbow-delimiters / 初始化 rainbow-delimiters
local function init_rainbow_delimiters()
  vim.cmd.packadd("rainbow-delimiters.nvim")
  local rainbow_delimiters = require("rainbow-delimiters")
  require("rainbow-delimiters.setup").setup({
    query = {
      [""] = "rainbow-delimiters",
      javascript = "rainbow-delimiters",
      tsx = "rainbow-delimiters",
      commonlisp = "rainbow-delimiters",
      scheme = "rainbow-delimiters",
      query = function(bufnr)
        local is_nofile = vim.bo[bufnr].buftype == "nofile"
        return is_nofile and rainbow_delimiters.strategy["blocks"]
          or rainbow_delimiters.strategy["global"]
      end,
      clojure = "rainbow-delimiters",
      html = "rainbow-delimiters",
      lua = "rainbow-delimiters",
      go = "rainbow-delimiters",
      rust = "rainbow-delimiters",
    },
  })
end

-- Lazy Load Triggers / 懒加载触发器
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  once = true,
  callback = function()
    vim.defer_fn(init_blink_indent, 100)
  end,
})

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  once = true,
  callback = function()
    if vim.tbl_contains(rainbow_filetypes, vim.bo.filetype) then
      init_rainbow_delimiters()
    end
  end,
})

-- =============================================================================
-- 2. RETURN VALUE: Configuration for Snacks.nvim
-- 2. 返回值：Snacks.nvim 的配置
-- =============================================================================

-- This table is meant to be passed to require("snacks").setup()
-- 这个表旨在传递给 require("snacks").setup()
local M = {}
M.indent = {
  enabled = false,
  only_current = false,
  only_scope = true,
  char = "",
  hl = {
    "SnacksIndentRed",
    "SnacksIndentYellow",
    "SnacksIndentBlue",
    "SnacksIndentOrange",
    "SnacksIndentGreen",
    "SnacksIndentViolet",
    "SnacksIndentCyan",
  },
}
M.scope = {
  enabled = false,
  char = "║",
  underline = true,
  only_current = true,
  hl = {
    "SnacksIndentScopeRed",
    "SnacksIndentScopeYellow",
    "SnacksIndentScopeBlue",
    "SnacksIndentScopeOrange",
    "SnacksIndentScopeGreen",
    "SnacksIndentScopeViolet",
    "SnacksIndentScopeCyan",
  },
}
M.chunk = {
  enabled = true,
  char = {
    corner_top = "╭",
    corner_bottom = "╰",
    horizontal = "─",
    vertical = "│",
    arrow = "",
  },
  only_current = true,
  hl = {
    "SnacksIndentChunkRed",
    "SnacksIndentChunkYellow",
    "SnacksIndentChunkBlue",
    "SnacksIndentChunkOrange",
    "SnacksIndentChunkGreen",
    "SnacksIndentChunkViolet",
    "SnacksIndentChunkCyan",
  },
}
M.animate = {
  enabled = vim.fn.has("nvim-0.10") == 1,
  style = "out",
  easing = "linear",
  duration = {
    step = 20, -- ms per step
    total = 500, -- maximum duration
  },
}
return M
