-- 1. Install conform.nvim via vim.pack / 通过 vim.pack 安装 conform.nvim
vim.pack.add({
  { src = "https://github.com/stevearc/conform.nvim" },
})

-- 2. Setup conform with formatters / 配置 conform 及其格式化工具
require("conform").setup({
  formatters_by_ft = {
    -- Lua
    lua = { "stylua" },

    -- Python
    python = { "isort", "black" },

    -- JavaScript/TypeScript (Web Stack)
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    vue = { "prettierd", "prettier", stop_after_first = true },
    svelte = { "prettierd", "prettier", stop_after_first = true },

    -- Web Development (HTML/CSS/JSON/YAML)
    html = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    scss = { "prettierd", "prettier", stop_after_first = true },
    less = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    jsonc = { "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    graphql = { "prettierd", "prettier", stop_after_first = true },

    -- Markdown
    markdown = { "prettierd", "prettier", stop_after_first = true },
    ["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },

    -- Configuration Files (TOML, XML) / 配置文件
    toml = { "taplo" }, -- Added TOML support via taplo / 通过 taplo 添加 TOML 支持
    xml = { "xmlformat" },

    -- Go
    go = { "goimports", "gofmt" },

    -- Rust
    rust = { "rustfmt", lsp_format = "fallback" },

    -- Swift (Added based on your profile) / Swift (根据你的资料添加)
    swift = { "swift_format" },

    -- C/C++
    c = { "clang_format" },
    cpp = { "clang_format" },
    cmake = { "cmake_format" },

    -- Shell
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },

    -- Ruby
    ruby = { "rubocop" },

    -- PHP
    php = { "php_cs_fixer" },

    -- Nix
    nix = { "nixpkgs_fmt" },

    -- Terraform
    terraform = { "terraform_fmt" },
    hcl = { "terraform_fmt" },

    -- SQL
    sql = { "sql_formatter" },

    -- Run codespell on all files / 对所有文件运行拼写检查
    -- Note: Be careful, this might change variable names if they look like typos
    -- 注意：请小心，这可能会修改看起来像拼写错误的变量名
    ["*"] = { "codespell" },

    -- Trim whitespace on filetypes without other formatters
    -- 对没有其他格式化工具的文件类型去除尾部空格
    ["_"] = { "trim_whitespace" },
  },

  -- Default format options / 默认格式化选项
  default_format_opts = {
    lsp_format = "fallback",
    timeout_ms = 3000,
  },

  -- Format on save configuration with toggle support
  -- 保存时格式化配置，支持切换开关
  format_on_save = function(bufnr)
    -- Disable autoformat if toggled off / 如果开关关闭则禁用自动格式化
    if vim.g.disable_autoformat then
      return
    end
    return {
      lsp_format = "fallback",
      timeout_ms = 1000,
    }
  end,

  -- Logging configuration / 日志配置
  log_level = vim.log.levels.WARN,

  -- Notifications / 通知
  notify_on_error = true,
  notify_no_formatters = false,

  -- Custom formatter configurations / 自定义格式化工具配置
  formatters = {
    -- Customize shfmt for shell scripts
    shfmt = {
      prepend_args = { "-i", "2", "-ci" }, -- 2 space indent, indent switch cases
    },

    -- Customize clang-format
    clang_format = {
      prepend_args = { "--style=Google" },
    },

    -- Customize taplo (TOML) if needed
    taplo = {
      -- args = { "format", "-" },
    },
  },
})

-- Command to toggle format-on-save / 切换保存时格式化的命令
vim.api.nvim_create_user_command("FormatToggle", function()
  if vim.g.disable_autoformat then
    vim.g.disable_autoformat = false
    vim.notify("Format on save enabled / 保存时格式化已启用", vim.log.levels.INFO)
  else
    vim.g.disable_autoformat = true
    vim.notify("Format on save disabled / 保存时格式化已禁用", vim.log.levels.WARN)
  end
end, { desc = "Toggle format on save" })

-- Format command for range formatting / 范围格式化命令
vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true, desc = "Format code" })

-- Helper function for keymap / 按键映射的辅助函数
local formatbuf = function()
  require("conform").format({
    lsp_format = "fallback",
    async = false,
    timeout_ms = 3000,
  })
end

-- Load your keymap utility / 加载你的按键映射工具
-- Ensure "config.keymaps" exists in your path / 确保路径中存在 "config.keymaps"
local map = require("config.keymaps").map

map({
  ["Format current buffer"] = { { "n", "v" }, "<leader>lf", formatbuf },
  ["Formatter info"] = { "n", "<leader>fi", "<cmd>ConformInfo<cr>" },
  ["Toggle format on save"] = { "n", "<leader>lt", "<cmd>FormatToggle<cr>" },
}, { silent = true })
