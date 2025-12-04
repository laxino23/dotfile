vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/whoissethdaniel/mason-tool-installer.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/nvimdev/lspsaga.nvim" },
})

-- =============================================================================
-- 1. Capabilities Setup (CRUCIAL FOR UFO)
--    能力配置 (UFO 必需) - 必须放在任何服务器配置之前！
-- =============================================================================
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Enable Folding Range capabilities for nvim-ufo
-- 启用 nvim-ufo 所需的折叠范围能力
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

-- =============================================================================
-- 2. Basic Setup (Mason & Lspsaga)
-- =============================================================================
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("lspsaga").setup({
  symbol_in_winbar = { enable = true, separator = " › " },
  lightbulb = { enable = true, sign = true, virtual_text = false },
  ui = { border = "rounded", code_action = "💡" },
  scroll_preview = { scroll_down = "<C-f>", scroll_up = "<C-b>" },
  diagnostic = {
    show_code_action = true,
    show_source = true,
    jump_num_shortcut = true,
    max_width = 0.7,
    max_height = 0.6,
    text_hl_follow = true,
    border_follow = true,
    extend_relatedInformation = false,
    show_layout = "float",
    diagnostic_only_current = false,
    keys = {
      exec_action = "o",
      quit = "q",
      toggle_or_jump = "<CR>",
      quit_in_show = { "q", "<ESC>" },
    },
  },
})

-- =============================================================================
-- 3. Specific Server Configurations (vim.lsp.config)
-- =============================================================================

-- [Lua] lua_ls
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
    })
  end,
  settings = {
    Lua = {
      codeLens = { enable = true },
      hint = { enable = true, semicolon = "Disable" },
      diagnostics = { globals = { "vim", "Snacks", "MiniIcons" } },
    },
  },
})

-- [Python] pyright
vim.lsp.config("pyright", {
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- [Rust] rust_analyzer
vim.lsp.config("rust_analyzer", {
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      diagnostics = { enable = true },
      lens = { enable = true },
      checkOnSave = { command = "clippy" },
    },
  },
})

-- [C/C++] clangd
vim.lsp.config("clangd", {
  capabilities = capabilities,
  cmd = { "clangd", "--offset-encoding=utf-16" },
})
-- all other lspconfig with fold capabilities
vim.lsp.config("*", {
  capabilities = capabilities,
})

-- =============================================================================
-- 4. Mason-LSPConfig (Auto Start)
-- =============================================================================
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "ts_ls",
    "html",
    "cssls",
    "jsonls",
    "yamlls",
    "marksman",
    "gopls",
    "rust_analyzer",
    "clangd",
    "bashls",
    "ruby_lsp",
    "intelephense",
    "nil_ls",
    "terraformls",
    "sqlls",
  },
  -- This will start servers using the configs defined above (including the merged '*' capabilities)
  automatic_enable = true,
})

-- =============================================================================
-- 5. Mason Tool Installer
-- =============================================================================
require("mason-tool-installer").setup({
  ensure_installed = {
    "stylua",
    "prettier",
    "black",
    "isort",
    "shfmt",
    "clang-format",
    "taplo",
    "sql-formatter",
    "xmlformatter",
    "cmakelang",
    "goimports",
  },
  auto_update = true,
  run_on_start = true,
  start_delay = 3000,
})

-- =============================================================================
-- 6. Helper Functions
-- =============================================================================
local function jump_to_current_function_start()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
  if not responses then
    return
  end
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1] - 1
  local function find_symbol(symbols)
    for _, s in ipairs(symbols) do
      local range = s.range or (s.location and s.location.range)
      if range and line >= range.start.line and line <= range["end"].line then
        if s.children then
          local child = find_symbol(s.children)
          if child then
            return child
          end
        end
        return s
      end
    end
  end
  for _, resp in pairs(responses) do
    local sym = find_symbol(resp.result or {})
    if sym and sym.range then
      vim.api.nvim_win_set_cursor(0, { sym.range.start.line + 1, 0 })
      return
    end
  end
end

local function jump_to_current_function_end()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
  if not responses then
    return
  end
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1] - 1
  local function find_symbol(symbols)
    for _, s in ipairs(symbols) do
      local range = s.range or (s.location and s.location.range)
      if range and line >= range.start.line and line <= range["end"].line then
        if s.children then
          local child = find_symbol(s.children)
          if child then
            return child
          end
        end
        return s
      end
    end
  end
  for _, resp in pairs(responses) do
    local sym = find_symbol(resp.result or {})
    if sym and sym.range then
      vim.api.nvim_win_set_cursor(0, { sym.range["end"].line + 1, 0 })
      return
    end
  end
end

-- =============================================================================
-- 7. LspAttach Keymaps
-- =============================================================================
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(event)
    local function map(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("K", "<cmd>Lspsaga hover_doc<CR>", "Hover Documentation")
    map("gr", "<cmd>Lspsaga finder<CR>", "Finder (Refs/Def)")
    map("<leader>ca", "<cmd>Lspsaga code_action<CR>", "Code Action")
    map("<leader>rn", "<cmd>Lspsaga rename<CR>", "Rename")
    map("]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", "Next Diagnostic")
    map("[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Prev Diagnostic")
    map("]E", function()
      require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, "Next Error")
    map("[E", function()
      require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, "Prev Error")
    map("<leader>ldl", "<cmd>Lspsaga show_line_diagnostics<CR>", "Show Line Diagnostics")
    map("<leader>ldw", "<cmd>Lspsaga show_cursor_dagnostics<CR>", "Show Cursor Diagnostics")
    map("<leader>ldb", "<cmd>Lspsaga show_buf_diagnostics<CR>", "Show Buffer Diagnostics")
    map("<leader>ldd", "<cmd>Lspsaga show_workspace_diagnostics<CR>", "Show Workspace Diagnostics")

    map("gtd", function()
      if package.loaded["snacks"] then
        require("snacks").picker.lsp_definitions()
      else
        vim.lsp.buf.definition()
      end
    end, "Goto Definition")

    map("[f", jump_to_current_function_start, "Jump to function start")
    map("]f", jump_to_current_function_end, "Jump to function end")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
      end, "Toggle Inlay Hints")
    end
  end,
})
