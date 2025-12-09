local options = require "config.options"
local keymaps = require "config.keymaps"
local keymaps_ft = require "config.keymaps_ft"
local core_fts = require "languages.lsp.core.file_types"
local extra_fts = require "languages.lsp.extra.file_types"
local fns = require "core.fns"

-- setup auto group for unifying auto cmd
local group = vim.api.nvim_create_augroup("MyIDE", {
	clear = true,
})

local configs = {}

-- fill up configs
configs["options"] = function()
	options.global()
end

configs["keymaps"] = function()
	keymaps.global()
    keymaps_ft.set_keymaps_ft()
end

configs["custom_config"] = function()
    vim.deprecate = function() end

    vim.api.nvim_create_user_command(
        "EditorConfigCreate",
        "lua require'core.fns'.copy_file(_G.global.custom_path .. '/.configs/templates/.editorconfig', vim.fn.getcwd() .. '/.editorconfig')",
        { desc = "Create .editorconfig file from template" }
    )
    
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        -- get all color from the current colorscheme 
        callback = function()
            local color_base = fns.get_highlight("Folded")
            local bg = color_base.bg
            local bg_dark = fns.blend(bg, 0.8, "#000000")
            local bg_float = fns.get_highlight("NormalFloat").bg
            local gray = fns.get_highlight("NonText").fg
            local fg = gray
            local fg_light = fns.blend(fg, 0.4, "#FFFFFF")
            local blue = fns.get_highlight("Function").fg
            local green = fns.get_highlight("String").fg
            local orange = fns.get_highlight("Constant").fg
            local red = fns.get_highlight("DiagnosticError").fg
            local cyan = fns.get_highlight("Special").fg
            local purple = fns.get_highlight("Statement").fg
            local diag_error = fns.get_highlight("DiagnosticError").fg
            local diag_warn = fns.get_highlight("DiagnosticWarn").fg
            local diag_hint = fns.get_highlight("DiagnosticHint").fg
            local diag_info = fns.get_highlight("DiagnosticInfo").fg
            local blue_bh = fns.blend(blue, 0.1, bg)
            local blue_bl = fns.blend(blue, 0.3, bg)
            local green_bh = fns.blend(green, 0.1, bg)
            local green_bl = fns.blend(green, 0.3, bg)
            local orange_bh = fns.blend(orange, 0.1, bg)
            local orange_bl = fns.blend(orange, 0.3, bg)
            local red_bh = fns.blend(red, 0.1, bg)
            local red_bl = fns.blend(red, 0.3, bg)
            local cyan_bh = fns.blend(cyan, 0.1, bg)
            local cyan_bl = fns.blend(cyan, 0.3, bg)
            local purple_bh = fns.blend(purple, 0.1, bg)
            local purple_bl = fns.blend(purple, 0.3, bg)

            local function get_hl_fg(name)
                if not name then
                    return nil
                end
                if vim.api.nvim_get_hl then
                    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                    if ok and hl then
                        local col = hl.fg or hl["foreground"]
                        if col then
                            if type(col) == "number" then
                                return string.format("#%06x", col)
                            elseif type(col) == "string" then
                                return col
                            end
                        end
                    end
                end
                local id = vim.fn.hlID(name)
                if id ~= 0 then
                    local synfg = vim.fn.synIDattr(vim.fn.synIDtrans(id), "fg#")
                    if synfg ~= "" then
                        return synfg
                    end
                end
                return nil
            end
            -- get highlight foreground
            local git_add = get_hl_fg("MiniDiffSignAdd") or get_hl_fg("GitSignsAdd") or get_hl_fg("DiffAdd")
            local git_change = get_hl_fg("MiniDiffSignChange") or get_hl_fg("GitSignsChange") or get_hl_fg("DiffText")
            local git_delete = get_hl_fg("MiniDiffSignDelete") or get_hl_fg("GitSignsDelete") or get_hl_fg("DiffDelete")

            -- set global colors associated with the current colorscheme
            _G.COLORS = {
                bg = vim.o.background == "dark" and bg or fg,
                bg_dark = vim.o.background == "dark" and bg_dark or fg_light,
                bg_float = bg_float,
                fg = vim.o.background == "dark" and fg or bg,
                fg_light = vim.o.background == "dark" and fg_light or bg_dark,
                gray = gray,
                blue = blue,
                green = green,
                orange = orange,
                red = red,
                cyan = cyan,
                purple = purple,
                blue_bh = blue_bh,
                blue_bl = blue_bl,
                green_bh = green_bh,
                green_bl = green_bl,
                orange_bh = orange_bh,
                orange_bl = orange_bl,
                red_bh = red_bh,
                red_bl = red_bl,
                cyan_bh = cyan_bh,
                cyan_bl = cyan_bl,
                purple_bh = purple_bh,
                purple_bl = purple_bl,
                diag_error = diag_error,
                diag_warn = diag_warn,
                diag_hint = diag_hint,
                diag_info = diag_info,
                git_add = git_add or green,
                git_change = git_change or orange,
                git_delete = git_delete or red,
            }
            -- set peripheral colors
            vim.api.nvim_set_hl(0, "WinBar", { bg = _G.COLORS.bg_dark, fg = _G.COLORS.fg })
            vim.api.nvim_set_hl(0, "WinBarNC", { bg = _G.COLORS.bg_dark, fg = _G.COLORS.fg })
            -- require("modules.core.config.ui").heirline_nvim.config()
            -- require("modules.core.config.ui").ui_nvim.config()
        end,
        group = group,
    })

    vim.api.nvim_create_user_command("SortLuaTable", fns.sort_lua_table, {})
    vim.api.nvim_create_user_command("CommandOutput", fns.command_output, {
        desc = "Execute command and show output in window",
    })

    vim.keymap.set(
        "n",
        "<Leader>co",
        fns.command_output,
        { noremap = true, silent = true, desc = "Execute command with output window" }
    )
end

configs["base_events"] = function()
    vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
        pattern = {
            "markdown",
        },
        callback = function()
            vim.opt_local.foldtext = "v:lua.md_fold_text()"
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.conceallevel = 2
            vim.opt_local.wrap = false
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.colorcolumn = "0"
            vim.opt_local.cursorcolumn = false
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "text",
            "markdown",
            "org",
        },
        callback = function()
            vim.opt_local.listchars = "tab:  ,nbsp: ,trail: ,space: ,extends:→,precedes:←"
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "c",
            "cpp",
            "dart",
            "haskell",
            "objc",
            "objcpp",
            "ruby",
            "markdown",
            "org",
        },
        callback = function()
            vim.opt_local.tabstop = 2
            vim.opt_local.shiftwidth = 2
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "NeogitStatus",
            "Outline",
            "calendar",
            "dapui_breakpoints",
            "dapui_scopes",
            "dapui_stacks",
            "dapui_watches",
            "git",
            "netrw",
            "org",
            "toggleterm",
            "fyler",
            "Fyler",
            "neo-tree",
            "time-machine-list",
        },
        callback = function()
            vim.schedule(function()
                vim.opt_local.number = false
                vim.opt_local.relativenumber = false
                vim.opt_local.cursorcolumn = false
                vim.opt_local.colorcolumn = "0"
            end)
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = "*",
        callback = function()
            if fns.is_helm() then
                vim.bo.filetype = "helm"
            end
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "helm",
        callback = function()
            vim.bo.commentstring = "{{/* %s */}}"
        end,
        group = group,
    })
end

configs["base_languages"] = function()
    vim.keymap.del("n", "grn")
    vim.keymap.del({ "n", "v" }, "gra")
    vim.keymap.del("n", "grr")
    vim.keymap.del("n", "gri")
    vim.keymap.del("n", "gO")
    vim.keymap.del("i", "<C-s>")
    _G.file_types = fns.merge(core_fts, extra_fts)
end

configs["base_commands"] = function()
    vim.api.nvim_create_user_command("CloseFloatWindows", 'lua require("core.fns").close_float_windows()', {})
    vim.api.nvim_create_user_command("FocusFloatWindow", 'lua require("core.fns").focus_float_window()', {})
    vim.api.nvim_create_user_command("SetGlobalPath", 'lua require("core.fns").set_global_path()', {})
    vim.api.nvim_create_user_command("SetWindowPath", 'lua require("core.fns").set_window_path()', {})
    vim.api.nvim_create_user_command("SudoWrite", 'lua require("core.fns").sudo_write()', {})
    vim.api.nvim_create_user_command("Quit", 'lua require("core.ext.quite").quit()', {})
    vim.api.nvim_create_user_command("Save", function()
        vim.schedule(function()
            pcall(function()
                vim.cmd("w")
            end)
        end)
    end, {})

    require("core.ext.gxplus").setup()
    vim.keymap.set("n", "gx", "<cmd>GxPlus<CR>", { silent = true, desc = "GxPlus" })
end

-- export configs
return configs
