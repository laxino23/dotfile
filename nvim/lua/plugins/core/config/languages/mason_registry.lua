-- =============================================================================
-- Mason Auto-Install - Compatible with Your Existing LSP System
-- Works with your lsp_manager and lsp_installer
-- =============================================================================

local M = {}

-- Mason registry for checking available packages
local mason_registry = require("mason-registry")

-- Track what we've already attempted to install this session
local install_attempted = {}
local install_queue = {}
local is_processing = false

---Check if a Mason package is installed
---@param package_name string
---@return boolean
local function is_installed(package_name)
    local ok, pkg = pcall(mason_registry.get_package, package_name)
    return ok and pkg:is_installed()
end

---Queue a package for installation
---@param package_name string
---@param tool_type string "lsp"|"dap"|"linter"|"formatter"
local function queue_install(package_name, tool_type)
    -- Skip if already attempted or already installed
    if install_attempted[package_name] or is_installed(package_name) then
        return
    end
    
    install_attempted[package_name] = true
    table.insert(install_queue, { name = package_name, type = tool_type })
end

---Process installation queue
local function process_queue()
    if is_processing or #install_queue == 0 then
        return
    end
    
    is_processing = true
    
    local item = table.remove(install_queue, 1)
    local package_name = item.name
    local tool_type = item.type
    
    -- Check if package exists in Mason registry
    local ok, pkg = pcall(mason_registry.get_package, package_name)
    if not ok then
        vim.notify(
            string.format("[Mason Auto] Package '%s' not found in registry", package_name),
            vim.log.levels.WARN
        )
        is_processing = false
        vim.defer_fn(process_queue, 100)
        return
    end
    
    -- Install if not already installed
    if not pkg:is_installed() then
        vim.notify(
            string.format("[Mason Auto] Installing %s: %s", tool_type, package_name),
            vim.log.levels.INFO
        )
        
        pkg:install():once("closed", function()
            if pkg:is_installed() then
                vim.notify(
                    string.format("[Mason Auto] ✓ Installed: %s", package_name),
                    vim.log.levels.INFO
                )
                
                -- CRITICAL: After installation, trigger your existing LSP system
                if tool_type == "lsp" then
                    vim.schedule(function()
                        local current_buf = vim.api.nvim_get_current_buf()
                        vim.defer_fn(function()
                            -- Use your existing LspReattach command
                            vim.cmd("silent! LspReattach")
                        end, 1000)
                    end)
                end
            else
                vim.notify(
                    string.format("[Mason Auto] ✗ Failed to install: %s", package_name),
                    vim.log.levels.ERROR
                )
            end
            
            is_processing = false
            -- Continue processing queue
            vim.defer_fn(process_queue, 500)
        end)
    else
        is_processing = false
        vim.defer_fn(process_queue, 100)
    end
end

-- =============================================================================
-- COMPREHENSIVE MASON PACKAGE MAPPINGS
-- =============================================================================

---Map your LSP keys to Mason package names (based on your lua.lua pattern)
local lsp_key_to_mason = {
    -- From your file_types configuration
    ["angular"] = "angular-language-server",
    ["astro"] = "astro-language-server",
    ["cmake"] = "cmake-language-server",
    ["cpp"] = "clangd",
    ["css"] = "css-lsp",
    ["d"] = "serve-d",
    ["emmet"] = "emmet-ls",
    ["go"] = "gopls",
    ["helm"] = "helm-ls",
    ["html"] = "html-lsp",
    ["json"] = "json-lsp",
    ["jsts"] = "typescript-language-server",
    ["kotlin"] = "kotlin-language-server",
    ["latex"] = "texlab",
    ["lua"] = "lua-language-server",
    ["markdown"] = "marksman",
    ["nginx"] = "nginx-language-server",
    ["ocaml"] = "ocaml-lsp",
    ["perl"] = "perlnavigator",
    ["php"] = "intelephense",
    ["python"] = "pyright",
    ["r"] = "r-languageserver",
    ["rust"] = "rust-analyzer",
    ["scala"] = "metals",
    ["shell"] = "bash-language-server",
    ["sql"] = "sqls",
    ["stylelint"] = "stylelint-lsp",
    ["tailwind"] = "tailwindcss-language-server",
    ["toml"] = "taplo",
    ["vim"] = "vim-language-server",
    ["vue"] = "vue-language-server",
    ["xml"] = "lemminx",
    ["yaml"] = "yaml-language-server",
    ["zig"] = "zls",
}

---Map filetype to common formatters (like stylua in your lua.lua)
local filetype_formatters = {
    ["lua"] = { "stylua" },
    ["javascript"] = { "prettier", "prettierd", "biome" },
    ["typescript"] = { "prettier", "prettierd", "biome" },
    ["javascriptreact"] = { "prettier", "prettierd", "biome" },
    ["typescriptreact"] = { "prettier", "prettierd", "biome" },
    ["json"] = { "prettier", "prettierd", "biome" },
    ["jsonc"] = { "prettier", "prettierd", "biome" },
    ["html"] = { "prettier", "prettierd" },
    ["css"] = { "prettier", "prettierd", "stylelint" },
    ["scss"] = { "prettier", "prettierd", "stylelint" },
    ["less"] = { "prettier", "prettierd", "stylelint" },
    ["markdown"] = { "prettier", "prettierd", "mdformat" },
    ["yaml"] = { "prettier", "prettierd", "yamlfmt" },
    ["python"] = { "black", "autopep8", "isort", "ruff" },
    ["sh"] = { "shfmt", "beautysh" },
    ["bash"] = { "shfmt", "beautysh" },
    ["zsh"] = { "shfmt", "beautysh" },
    ["go"] = { "gofumpt", "goimports" },
    ["rust"] = { "rust-analyzer" },
    ["c"] = { "clang-format" },
    ["cpp"] = { "clang-format" },
    ["php"] = { "php-cs-fixer" },
    ["ruby"] = { "rubyfmt", "rufo" },
    ["toml"] = { "taplo" },
    ["sql"] = { "sql-formatter", "sqlfluff" },
    ["java"] = { "google-java-format" },
    ["kotlin"] = { "ktlint", "ktfmt" },
    ["tex"] = { "latexindent" },
    ["xml"] = { "xmlformatter" },
}

---Map filetype to common linters
local filetype_linters = {
    ["javascript"] = { "eslint_d", "eslint-lsp" },
    ["typescript"] = { "eslint_d", "eslint-lsp" },
    ["javascriptreact"] = { "eslint_d", "eslint-lsp" },
    ["typescriptreact"] = { "eslint_d", "eslint-lsp" },
    ["python"] = { "pylint", "flake8", "mypy", "ruff" },
    ["sh"] = { "shellcheck" },
    ["bash"] = { "shellcheck" },
    ["zsh"] = { "shellcheck" },
    ["css"] = { "stylelint" },
    ["scss"] = { "stylelint" },
    ["less"] = { "stylelint" },
    ["dockerfile"] = { "hadolint" },
    ["markdown"] = { "markdownlint", "vale", "write-good" },
    ["sql"] = { "sqlfluff" },
    ["yaml"] = { "yamllint" },
    ["php"] = { "phpcs", "phpstan" },
    ["ruby"] = { "rubocop" },
    ["go"] = { "golangci-lint", "revive", "staticcheck" },
    ["lua"] = { "luacheck", "selene" },
    ["json"] = { "jsonlint" },
    ["html"] = { "htmlhint" },
    ["c"] = { "cpplint" },
    ["cpp"] = { "cpplint" },
    ["java"] = { "checkstyle" },
}

---Map filetype to DAP adapters
local filetype_dap = {
    ["python"] = "debugpy",
    ["javascript"] = "js-debug-adapter",
    ["typescript"] = "js-debug-adapter",
    ["javascriptreact"] = "js-debug-adapter",
    ["typescriptreact"] = "js-debug-adapter",
    ["go"] = "delve",
    ["rust"] = "codelldb",
    ["c"] = "codelldb",
    ["cpp"] = "codelldb",
    ["java"] = "java-debug-adapter",
    ["kotlin"] = "kotlin-debug-adapter",
    ["php"] = "php-debug-adapter",
    ["sh"] = "bash-debug-adapter",
    ["bash"] = "bash-debug-adapter",
    ["lua"] = nil, -- You have custom nlua adapter
}

-- =============================================================================
-- AUTO-INSTALL LOGIC
-- =============================================================================

---Install LSP dependencies for a filetype (like lsp_dependencies in your lua.lua)
---@param ft string
local function install_lsp_for_filetype(ft)
    if not _G.file_types then
        return
    end
    
    -- Find matching LSP servers from _G.file_types
    for lsp_key, filetypes in pairs(_G.file_types) do
        if vim.tbl_contains(filetypes, ft) then
            local mason_name = lsp_key_to_mason[lsp_key]
            if mason_name then
                queue_install(mason_name, "lsp")
            end
        end
    end
end

---Install formatters for a filetype
---@param ft string
local function install_formatters_for_filetype(ft)
    local formatters = filetype_formatters[ft]
    if not formatters then
        return
    end
    
    for _, formatter in ipairs(formatters) do
        queue_install(formatter, "formatter")
    end
end

---Install linters for a filetype
---@param ft string
local function install_linters_for_filetype(ft)
    local linters = filetype_linters[ft]
    if not linters then
        return
    end
    
    for _, linter in ipairs(linters) do
        queue_install(linter, "linter")
    end
end

---Install EFM if configured for this filetype
---@param ft string
local function install_efm_for_filetype(ft)
    -- Always ensure EFM is installed since it's used for formatters
    if (_G.efm_configs and _G.efm_configs[ft]) or
       (_G.global and _G.global.efm and _G.global.efm.filetypes and 
        vim.tbl_contains(_G.global.efm.filetypes, ft)) then
        queue_install("efm", "lsp")
    end
end

---Install DAP adapter for a filetype
---@param ft string
local function install_dap_for_filetype(ft)
    local dap_adapter = filetype_dap[ft]
    if dap_adapter then
        queue_install(dap_adapter, "dap")
    end
end

---Auto-install all tools for current buffer
M.auto_install_for_buffer = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end
    
    local ft = vim.bo[bufnr].filetype
    if not ft or ft == "" then
        return
    end
    
    -- Install LSP servers
    install_lsp_for_filetype(ft)
    
    -- Install formatters (like stylua for lua)
    install_formatters_for_filetype(ft)
    
    -- Install linters
    install_linters_for_filetype(ft)
    
    -- Install EFM if configured
    install_efm_for_filetype(ft)
    
    -- Install DAP adapter
    install_dap_for_filetype(ft)
    
    -- Start processing queue
    vim.defer_fn(process_queue, 100)
    
    -- IMPORTANT: Trigger your existing LSP attachment after a delay
    -- This ensures newly installed servers get picked up
    vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
            -- Use your existing LspReattach command
            vim.cmd("silent! LspReattach")
        end
    end, 2000)
end

---Setup auto-installation hooks
M.setup = function(opts)
    opts = opts or {}
    
    -- Wait for Mason registry to be ready
    mason_registry.refresh(function()
        -- Create autocommand group
        local group = vim.api.nvim_create_augroup("MasonAutoInstall", { clear = true })
        
        -- Auto-install on FileType detection (like your lsp_attach does)
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            callback = function(args)
                -- Defer to not block buffer opening
                vim.defer_fn(function()
                    M.auto_install_for_buffer(args.buf)
                end, 500)
            end,
        })
        
        -- Also trigger on BufEnter for existing buffers
        vim.api.nvim_create_autocmd("BufEnter", {
            group = group,
            callback = function(args)
                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(args.buf) then
                        M.auto_install_for_buffer(args.buf)
                    end
                end, 1000)
            end,
        })
        
        -- Check all currently open buffers after startup
        vim.defer_fn(function()
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype ~= "" then
                    M.auto_install_for_buffer(bufnr)
                end
            end
        end, 2000)
    end)
    
    -- User commands
    vim.api.nvim_create_user_command("MasonAutoInstall", function()
        M.auto_install_for_buffer()
        vim.notify("[Mason Auto] Checking tools for current buffer", vim.log.levels.INFO)
    end, { desc = "Install Mason tools for current buffer" })
    
    vim.api.nvim_create_user_command("MasonAutoInstallAll", function()
        -- Trigger for all open buffers
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype ~= "" then
                M.auto_install_for_buffer(bufnr)
            end
        end
        vim.notify("[Mason Auto] Checking tools for all buffers", vim.log.levels.INFO)
    end, { desc = "Install Mason tools for all open buffers" })
    
    vim.notify("[Mason Auto] Setup complete - will auto-install on buffer open", vim.log.levels.INFO)
end

return M
