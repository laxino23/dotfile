local icons = require "config.ui.icons"

return {
        blink_cmp = {
                opts = function()
                    local ls = require("luasnip")
                    ls.config.set_config({
                        enable_autosnippets = true,
                        store_selection_keys = "<Tab>",
                    })
                    require("luasnip.loaders.from_vscode").load({
                        paths = { vim.fn.stdpath("config") .. "/snippets/vscode" },
                    })
                    require("luasnip.loaders.from_lua").load({
                        paths = { vim.fn.stdpath("config") .. "/snippets/lua" },
                    })
                    return {
                        enabled = function()
                            local disabled = false
                            local success, node = pcall(vim.treesitter.get_node)
                            disabled = disabled or (vim.bo.buftype == "prompt")
                            disabled = disabled or (vim.bo.filetype == "typr")
                            disabled = disabled or (vim.bo.filetype == "lvim-space-search-input")
                            disabled = disabled or (vim.bo.filetype == "lvim-space-tabs-input")
                            disabled = disabled or (vim.fn.reg_recording() ~= "")
                            disabled = disabled or (vim.fn.reg_executing() ~= "")
                            disabled = disabled
                                or (
                                    success
                                    and node ~= nil
                                    and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type())
                                )
                            disabled = disabled or vim.g.__ui_cmdline_active == true
                            disabled = disabled or vim.g.__ui_confirm_msg ~= nil
                            disabled = disabled or vim.g.__ui_list_msg ~= nil
                            local ok_ft, ft = pcall(function()
                                return vim.bo.filetype
                            end)
                            if ok_ft and (ft == nil or ft == "") then
                                disabled = true
                            end
                            return not disabled
                        end,
                        sources = {
                            default = { "lsp", "path", "snippets", "buffer", "dadbod", "ripgrep", "emoji" },
                            providers = {
                                lsp = {
                                    name = "lsp",
                                    module = "blink.cmp.sources.lsp",
                                    fallbacks = { "buffer" },
                                    score_offset = 90,
                                },
                                path = {
                                    name = "Path",
                                    module = "blink.cmp.sources.path",
                                    score_offset = 25,
                                    fallbacks = { "buffer" },
                                    opts = {
                                        trailing_slash = false,
                                        label_trailing_slash = true,
                                        get_cwd = function(ctx)
                                            return vim.fn.expand(("#%d:p:h"):format(ctx.bufnr))
                                        end,
                                        show_hidden_files_by_default = true,
                                    },
                                },
                                buffer = {
                                    name = "Buffer",
                                    module = "blink.cmp.sources.buffer",
                                    max_items = 3,
                                    min_keyword_length = 3,
                                    score_offset = 15,
                                },
                                snippets = {
                                    name = "snippets",
                                    enabled = true,
                                    max_items = 8,
                                    min_keyword_length = 2,
                                    module = "blink.cmp.sources.snippets",
                                    score_offset = 85,
                                },
                                ripgrep = {
                                    module = "blink-cmp-rg",
                                    name = "Ripgrep",
                                    opts = {
                                        prefix_min_len = 3,
                                        get_command = function(_, prefix)
                                            return {
                                                "rg",
                                                "--no-config",
                                                "--json",
                                                "--word-regexp",
                                                "--ignore-case",
                                                "--",
                                                prefix .. "[\\w_-]+",
                                                vim.fs.root(0, ".git") or vim.fn.getcwd(),
                                            }
                                        end,
                                        get_prefix = function(context)
                                            return context.line:sub(1, context.cursor[2]):match("[%w_-]+$") or ""
                                        end,
                                    },
                                },
                                emoji = {
                                    module = "blink-emoji",
                                    name = "Emoji",
                                    score_offset = 15,
                                    opts = { insert = true },
                                },
                                dadbod = {
                                    name = "Dadbod",
                                    module = "vim_dadbod_completion.blink",
                                },
                            },
                        },
                        appearance = {
                            kind_icons = icons.cmp.lsp_symbols,
                        },
                        completion = {
                            accept = { auto_brackets = { enabled = true } },
                            trigger = {
                                show_on_insert_on_trigger_character = false,
                            },
                            menu = {
                                border = "padded",
                                draw = {
                                    padding = 2,
                                    gap = 1,
                                    treesitter = { "lsp" },
                                    columns = {
                                        { "kind_icon" },
                                        { "label", "label_description", gap = 1 },
                                        { "kind" },
                                        { "source_name" },
                                    },
                                    components = {
                                        label = {
                                            text = require("colorful-menu").blink_components_text,
                                            highlight = require("colorful-menu").blink_components_highlight,
                                        },
                                        source_name = {
                                            text = function(ctx)
                                                local name = ctx.source_name
                                                if name == "lsp" then
                                                    return "[" .. string.upper(name) .. "]"
                                                end
                                                return "[" .. name:sub(1, 1):upper() .. name:sub(2) .. "]"
                                            end,
                                            highlight = function(ctx)
                                                local source = ctx.source_name
                                                if source == "lsp" then
                                                    return "BlinkCmpSourceLSP"
                                                elseif source == "Buffer" then
                                                    return "BlinkCmpSourceBuffer"
                                                elseif source == "Path" then
                                                    return "BlinkCmpSourcePath"
                                                else
                                                    return "BlinkCmpSource"
                                                end
                                            end,
                                        },
                                    },
                                },
                                cmdline_position = function()
                                    if vim.g.ui_cmdline_pos ~= nil then
                                        local pos = vim.g.ui_cmdline_pos
                                        return { pos[1] - 1, pos[2] }
                                    end
                                    local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
                                    return { vim.o.lines - height - 1, 0 }
                                end,
                            },
                            documentation = {
                                auto_show = true,
                                auto_show_delay_ms = 10,
                                treesitter_highlighting = true,
                                window = { border = "padded" },
                            },
                            ghost_text = { enabled = true },
                        },
                        signature = { window = { border = "padded" } },
                        keymap = {
                            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                            ["<C-e>"] = { "hide", "fallback" },
                            ["<CR>"] = { "accept", "fallback" },
                            ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                            ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                            ["<Down>"] = { "select_next", "fallback" },
                            ["<Up>"] = { "select_prev", "fallback" },
                            ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
                            ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
                            ["<C-h>"] = { "scroll_documentation_down", "fallback" },
                            ["<C-l>"] = { "scroll_documentation_up", "fallback" },
                            ["<C-d>"] = { "scroll_documentation_down", "fallback" },
                            ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                        },
                        cmdline = {
                            completion = { menu = { auto_show = true } },
                            keymap = {
                                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                                ["<C-e>"] = { "hide", "fallback" },
                                ["<CR>"] = { "accept", "fallback" },
                                ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                                ["<Down>"] = { "select_next", "fallback" },
                                ["<Up>"] = { "select_prev", "fallback" },
                                ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
                                ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
                                ["<C-h>"] = { "scroll_documentation_down", "fallback" },
                                ["<C-l>"] = { "scroll_documentation_up", "fallback" },
                            },
                            sources = function()
                                local type = vim.fn.getcmdtype()
                                if type == "/" or type == "?" then
                                    return { "buffer" }
                                else
                                    return { "cmdline", "path" }
                                end
                            end,
                        },
                    }
                end,
            },

    mini_ai = {
        config = function()
            local mini_ai_ok, ai = pcall(require, "mini.ai")
            if not mini_ai_ok then
                return
            end

            ai.setup({
                custom_textobjects = {
                    ["?"] = false,
                    ["/"] = ai.gen_spec.user_prompt(),
                    ["%"] = function()
                      local from = { line = 1, col = 1 }
                      local to = { line = vim.fn.line("$"), col = math.max(vim.fn.getline("$"):len(), 1) }
                      return { from = from, to = to }
                    end,
                    a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
                    c = ai.gen_spec.treesitter({ a = "@comment.outer", i = "@comment.inner" }),
                    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
                    s = {
                      {
                        "%u[%l%d]+%f[^%l%d]",
                        "%f[^%s%p][%l%d]+%f[^%l%d]",
                        "^[%l%d]+%f[^%l%d]",
                        "%f[^%s%p][%a%d]+%f[^%a%d]",
                        "^[%a%d]+%f[^%a%d]",
                      },
                      "^().*()$",
                    },
                  },
                mappings = { around = "a", inside = "i" },
                n_lines = 500,
            })
        end,
    },

    nvim_ts_autotag = {
        opts = {},
    },

    nvim_surround = {
        opts = {},
    },

    nvim_autopairs = {
        config = function()
            local npairs_ok, npairs = pcall(require, "nvim-autopairs")
            if not npairs_ok then
                return
            end

            local Rule = require("nvim-autopairs.rule")
            local cond = require("nvim-autopairs.conds")
            local ts_conds = require("nvim-autopairs.ts-conds")

            local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }

            npairs.setup({
              check_ts = true,
              map_bs = false,
              ts_config = { lua = { "string" }, javascript = { "template_string" } },
              fast_wrap = {
                map = "<M-e>",
                chars = { "{", "[", "(", '"', "'" },
                pattern = [=[[%'%"%)%>%]%)%}%,]]=],
                offset = 0,
                end_key = "$",
                keys = "qwertyuiopzxcvbnmasdfghjkl",
                check_comma = true,
                highlight = "Search",
                highlight_grey = "Comment",
              },
            })

            npairs.add_rules({
            Rule(" ", " ", "-markdown")
                :with_pair(function(opts)
                  local pair = opts.line:sub(opts.col - 1, opts.col)
                  return vim.tbl_contains({
                    brackets[1][1] .. brackets[1][2],
                    brackets[2][1] .. brackets[2][2],
                    brackets[3][1] .. brackets[3][2],
                  }, pair)
                end)
                :with_move(cond.none())
                :with_cr(cond.none())
                :with_del(function(opts)
                  local col = vim.api.nvim_win_get_cursor(0)[2]
                  local context = opts.line:sub(col - 1, col + 2)
                  return vim.tbl_contains({
                    brackets[1][1] .. "  " .. brackets[1][2],
                    brackets[2][1] .. "  " .. brackets[2][2],
                    brackets[3][1] .. "  " .. brackets[3][2],
                  }, context)
                end),
            })

            for _, bracket in pairs(brackets) do
              npairs.add_rules({
                Rule(bracket[1] .. " ", " " .. bracket[2])
                  :with_pair(function()
                    return false
                  end)
                  :with_del(function()
                    return false
                  end)
                  :with_move(function(opts)
                    return opts.prev_char:match(".%" .. bracket[2]) ~= nil
                  end)
                  :use_key(bracket[2]),
                Rule(bracket[1], bracket[2]):with_pair(cond.after_text("$")),
                Rule(bracket[1] .. bracket[2], ""):with_pair(function()
                  return false
                end):with_cr(function()
                  return false
                end),
              })
            end

            npairs.add_rule(Rule("$", "$", "markdown")
              :with_move(function(opts)
                return opts.next_char == opts.char
                  and ts_conds.is_ts_node({ "inline_formula", "displayed_equation", "math_environment" })(opts)
              end)
              :with_pair(
                ts_conds.is_not_ts_node({ "inline_formula", "displayed_equation", "math_environment" })
              )
              :with_pair(cond.not_before_text("\\")))

            npairs.add_rule(
              Rule("/**", " */"):with_pair(cond.not_after_regex(".-%*/", -1)):set_end_pair_length(3)
            )

            npairs.add_rule(Rule("**", "**", "markdown"):with_move(function(opts)
              return cond.after_text("*")(opts) and cond.not_before_text("\\")(opts)
            end))

            npairs.add_rules({
              Rule("%(.*%)%s*%=>$", " {  }", { "typescript", "typescriptreact", "javascript" })
                :use_regex(true)
                :set_end_pair_length(2),
            })
        end,
    },

}

