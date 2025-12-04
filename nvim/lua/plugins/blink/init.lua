local source = require("plugins.blink.source").source

vim.pack.add({
  { src = "https://github.com/archie-judd/blink-cmp-words" },
  { src = "https://github.com/saghen/blink.compat", version = "main" },
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },
  { src = "https://github.com/saghen/blink.cmp", version = "v1.7.0" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
})

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  group = vim.api.nvim_create_augroup("SetupCompletion", { clear = true }),
  once = true,
  callback = function()
    require("blink.compat").setup({ impersonate_nvim_cmp = true })

    require("supermaven-nvim").setup({
      disable_inline_completion = true,
      disable_keymaps = true,
      keymaps = {
        accept_suggestion = "<C-a>",
        accept_word = "<C-w>",
        -- Removed Esc to avoid conflicts
      },
      color = { suggestion_color = "#ffffff", cterm = 244 },
      log_level = "info",
    })
    require("luasnip.loaders.from_vscode").load()
    require("luasnip.loaders.from_vscode").load({
      paths = { vim.fn.stdpath("config") .. "/snippets" }, -- 你的自定义片段路径
    })
    require("blink.cmp").setup({
      completion = {
        documentation = { auto_show = true, window = { border = "single", scrollbar = false } },
        menu = {
          border = "single",
          auto_show = true,
          auto_show_delay_ms = 0,
        },
        list = {
          cycle = {
            from_top = true,
          },
        },
      },
      snippets = { preset = "luasnip" },

      -- 1. INSERT MODE KEYMAPS
      keymap = {
        preset = "none",
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
      },

      signature = { enabled = true, window = { border = "single" } },

      -- 2. CMDLINE CONFIGURATION
      cmdline = {
        completion = {
          menu = { auto_show = true },
        },
        -- KEYMAPS MUST BE DEFINED HERE FOR CMDLINE
        keymap = {
          preset = "cmdline",
          -- [Enter Logic]
          -- If menu is open: select first item & accept (do not execute command)
          -- If menu is closed: fallback (execute command)
          ["<CR>"] = { "select_and_accept", "fallback" },

          -- [Esc Logic]
          -- If menu is open: close menu (stay in cmdline)
          -- If menu is closed: fallback (exit cmdline)
          ["<Esc>"] = { "cancel", "fallback" },

          -- [Tab Logic for Cmdline]
          ["<Tab>"] = { "show", "select_next", "fallback" },
          ["<S-Tab>"] = { "select_prev", "fallback" },
        },
        sources = function()
          local type = vim.fn.getcmdtype()
          if type == "/" or type == "?" then
            return { "buffer" }
          end
          if type == ":" then
            return { "cmdline", "path" }
          end
          return {}
        end,
      },
      sources = source,
    })
  end,
})
