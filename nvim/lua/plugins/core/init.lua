local fns = require "core.fns"

local plugins = {}
local plugins_snapshot = {}

-- local file_content = fns.read_file(_G.global.custom_path .. "/.snapshots/" .. _G.SNAPSHOT)
-- if file_content ~= nil then
--     plugins_snapshot = file_content
-- end

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- DEPENDENCIES -------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local dependencies_config = require("plugins.core.config.dependencies")

plugins["nvim-lua/popup.nvim"] = {
    -- commit = fns.get_commit("popup.nvim", plugins_snapshot),
    lazy = true,
}

plugins["nvim-tree/nvim-web-devicons"] = {
    -- commit = fns.get_commit("nvim-web-devicons", plugins_snapshot),
    lazy = true,
    opts = dependencies_config.nvim_web_devicons.opts,
}

plugins["MunifTanjim/nui.nvim"] = {
    -- commit = fns.get_commit("nui.nvim", plugins_snapshot),
    lazy = true,
    config = dependencies_config.nui_nvim.config,
}

plugins["junegunn/fzf"] = {
    -- commit = fns.get_commit("fzf", plugins_snapshot),
    build = "./install --bin",
    lazy = false,
}

plugins["mxsdev/nvim-dap-vscode-js"] = {
    -- commit = fns.get_commit("nvim-dap-vscode-js", plugins_snapshot),
    lazy = true,
}

plugins["jbyuki/one-small-step-for-vimkind"] = {
    -- commit = fns.get_commit("one-small-step-for-vimkind", plugins_snapshot),
    lazy = true,
}

plugins["rafamadriz/friendly-snippets"] = {
    -- commit = fns.get_commit("friendly-snippets", plugins_snapshot),
    lazy = true,
}

plugins["L3MON4D3/LuaSnip"] = {
    -- commit = fns.get_commit("LuaSnip", plugins_snapshot),
    build = "make install_jsregexp",
    lazy = true,
}

plugins["niuiic/blink-cmp-rg.nvim"] = {
    -- commit = fns.get_commit("blink-cmp-rg", plugins_snapshot),
    lazy = true,
}

plugins["moyiz/blink-emoji.nvim"] = {
    -- commit = fns.get_commit("blink-emoji", plugins_snapshot),
    lazy = true,
}

plugins["xzbdmw/colorful-menu.nvim"] = {
    -- commit = fns.get_commit("colorful-menu.nvim", plugins_snapshot),
    lazy = true,
}

plugins["kkharji/sqlite.lua"] = {
    -- commit = fns.get_commit("sqlite.lua", plugins_snapshot),
    lazy = false,
}

plugins["nvim-neotest/nvim-nio"] = {
    -- commit = fns.get_commit("nvim-nio", plugins_snapshot),
    lazy = true,
}

plugins["nvim-neotest/neotest-plenary"] = {
    -- commit = fns.get_commit("neotest-plenary", plugins_snapshot),
    lazy = true,
}

plugins["olimorris/neotest-phpunit"] = {
    -- commit = fns.get_commit("neotest-phpunit", plugins_snapshot),
    lazy = true,
}

plugins["rouge8/neotest-rust"] = {
    -- commit = fns.get_commit("neotest-rust", plugins_snapshot),
    lazy = true,
}

plugins["nvim-neotest/neotest-go"] = {
    -- commit = fns.get_commit("neotest-go", plugins_snapshot),
    lazy = true,
}

plugins["nvim-neotest/neotest-python"] = {
    -- commit = fns.get_commit("neotest-python", plugins_snapshot),
    lazy = true,
}

plugins["jfpedroza/neotest-elixir"] = {
    -- commit = fns.get_commit("neotest-elixir", plugins_snapshot),
    lazy = true,
}

plugins["sidlatau/neotest-dart"] = {
    -- commit = fns.get_commit("neotest-dart", plugins_snapshot),
    lazy = true,
}

plugins["igorlfs/nvim-dap-view"] = {
    -- commit = fns.get_commit("nvim-dap-view", plugins_snapshot),
    lazy = true,
}

plugins["jbyuki/one-small-step-for-vimkind"] = {
    -- commit = fns.get_commit("one-small-step-for-vimkind", plugins_snapshot),
    lazy = true,
}

plugins["mxsdev/nvim-dap-vscode-js"] = {
    -- commit = fns.get_commit("nvim-dap-vscode-js", plugins_snapshot),
    lazy = true,
}

plugins["tpope/vim-dadbod"] = {
    -- commit = fns.get_commit("vim-dadbod", plugins_snapshot),
}

plugins["kristijanhusak/vim-dadbod-completion"] = {
    -- commit = fns.get_commit("vim-dadbod-completion", plugins_snapshot),
    lazy = true,
}

plugins["pbogut/vim-dadbod-ssh"] = {
    -- commit = fns.get_commit("vim-dadbod-ssh", plugins_snapshot),
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local ui_config = require("plugins.core.config.ui")

plugins["folke/snacks.nvim"] = {
    -- commit = fns.get_commit("snacks.nvim", plugins_snapshot),
    opts = ui_config.snacks_nvim.opts,
}

plugins["OXY2DEV/ui.nvim"] = {
    -- commit = fns.get_commit("ui.nvim", plugins_snapshot),
    config = ui_config.ui_nvim.config,
}

plugins["s1n7ax/nvim-window-picker"] = {
    -- commit = fns.get_commit("nvim-window-picker", plugins_snapshot),
    cmd = ui_config.nvim_window_picker.cmd,
    keys = ui_config.nvim_window_picker.keys,
    opts = ui_config.nvim_window_picker.opts,
}

plugins["sindrets/winshift.nvim"] = {
    -- commit = fns.get_commit("winshift.nvim", plugins_snapshot),
    cmd = ui_config.winshift_nvim.cmd,
    keys = ui_config.winshift_nvim.keys,
    opts = ui_config.winshift_nvim.opts,
}

plugins["nvim-mini/mini.files"] = {
    -- commit = fns.get_commit("mini.files", plugins_snapshot),
    cmd = ui_config.mini_files.cmd,
    keys = ui_config.mini_files.keys,
    opts = ui_config.mini_files.opts,
}

plugins["A7Lavinraj/fyler.nvim"] = {
    -- commit = fns.get_commit("fyler.nvim", plugins_snapshot),
    cmd = ui_config.fyler_nvim.cmd,
    keys = ui_config.fyler_nvim.keys,
    opts = ui_config.fyler_nvim.opts,
}

plugins["folke/which-key.nvim"] = {
    -- commit = fns.get_commit("which-key.nvim", plugins_snapshot),
    cond = function()
        return _G.LVIM_KEYSHELPER
    end,
    config = ui_config.which_key_nvim.config,
}

plugins["prichrd/netrw.nvim"] = {
    -- commit = fns.get_commit("netrw.nvim", plugins_snapshot),
    opts = ui_config.netrw_nvim.opts,
}

plugins["nvim-neo-tree/neo-tree.nvim"] = {
    -- commit = fns.get_commit("neo-tree.nvim", plugins_snapshot),
    cmd = ui_config.neo_tree_nvim.cmd,
    keys = ui_config.neo_tree_nvim.keys,
    opts = ui_config.neo_tree_nvim.opts,
}

plugins["stevearc/oil.nvim"] = {
    -- commit = fns.get_commit("oil.nvim", plugins_snapshot),
    cmd = ui_config.oil_nvim.cmd,
    keys = ui_config.oil_nvim.keys,
    opts = ui_config.oil_nvim.opts,
}

plugins["rebelot/heirline.nvim"] = {
    priority = 50,
    -- commit = fns.get_commit("heirline.nvim", plugins_snapshot),
    config = ui_config.heirline_nvim.config,
}

plugins["lvim-tech/lvim-shell"] = {
    -- commit = fns.get_commit("lvim-shell", plugins_snapshot),
    config = ui_config.lvim_shell.config,
}

plugins["CRAG666/betterTerm.nvim"] = {
    -- commit = fns.get_commit("betterTerm.nvim", plugins_snapshot),
    opts = ui_config.better_term_nvim.opts,
}

plugins["gbprod/stay-in-place.nvim"] = {
    -- commit = fns.get_commit("stay-in-place.nvim", plugins_snapshot),
    opts = ui_config.stay_in_place_nvim.opts,
}

plugins["HiPhish/rainbow-delimiters.nvim"] = {
    -- commit = fns.get_commit("rainbow-delimiters.nvim", plugins_snapshot),
    config = ui_config.rainbow_delimiters_nvim.config,
}

plugins["lukas-reineke/indent-blankline.nvim"] = {
    -- -- commit = fns.get_commit("indent-blankline.nvim", plugins_snapshot),
    config = ui_config.indent_blankline_nvim.config,
}


-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- EDITOR -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local editor_config = require("plugins.core.config.editor")

plugins["lvim-tech/lvim-space"] = {
    -- commit = fns.get_commit("lvim-space", plugins_snapshot),
    opts = editor_config.lvim_space.opts,
}

plugins["lvim-tech/lvim-control-center"] = {
    -- commit = fns.get_commit("lvim-control-center", plugins_snapshot),
    opts = editor_config.lvim_control_center.opts,
}

plugins["mrjones2014/smart-splits.nvim"] = {
    -- commit = fns.get_commit("smart-splits.nvim", plugins_snapshot),
    keys = editor_config.smart_splits.keys,
    opts = editor_config.smart_splits.opts,
}

plugins["ibhagwan/fzf-lua"] = {
    -- commit = fns.get_commit("fzf-lua", plugins_snapshot),
    cmd = editor_config.fzf_lua.cmd,
    keys = editor_config.fzf_lua.keys,
    opts = editor_config.fzf_lua.opts,
}

plugins["lvim-tech/lvim-linguistics"] = {
    -- commit = fns.get_commit("lvim-linguistics", plugins_snapshot),
    opts = editor_config.lvim_linguistics.opts,
}

plugins["mangelozzi/rgflow.nvim"] = {
    -- commit = fns.get_commit("rgflow.nvim", plugins_snapshot),
    keys = editor_config.rgflow_nvim.keys,
    opts = editor_config.rgflow_nvim.opts,
}

plugins["gcmt/vessel.nvim"] = {
    -- commit = fns.get_commit("vessel.nvim", plugins_snapshot),
    opts = editor_config.vessel_nvim.opts,
}

plugins["sahilsehwag/macrobank.nvim"] = {
    -- commit = fns.get_commit("macrobank.nvim", plugins_snapshot),
    cmd = editor_config.macrobank_nvim.cmd,
    keys = editor_config.macrobank_nvim.keys,
    opts = editor_config.macrobank_nvim.opts,
}

plugins["kevinhwang91/nvim-hlslens"] = {
    -- commit = fns.get_commit("nvim-hlslens", plugins_snapshot),
    opts = editor_config.nvim_hlslens.opts,
}

plugins["kevinhwang91/nvim-bqf"] = {
    -- commit = fns.get_commit("nvim-bqf", plugins_snapshot),
    opts = editor_config.nvim_bqf.opts,
}

plugins["stevearc/quicker.nvim"] = {
    -- commit = fns.get_commit("quicker.nvim", plugins_snapshot),
    event = "FileType qf",
    opts = editor_config.quicker_nvim.opts,
}

plugins["lvim-tech/lvim-qf-loc"] = {
    -- commit = fns.get_commit("lvim-qf-loc", plugins_snapshot),
    cmd = editor_config.lvim_qf_loc.cmd,
    keys = editor_config.lvim_qf_loc.keys,
    opts = editor_config.lvim_qf_loc.opts,
}

plugins["nanozuki/tabby.nvim"] = {
    -- commit = fns.get_commit("tabby.nvim", plugins_snapshot),
    opts = editor_config.tabby_nvim.opts,
}

plugins["monaqa/dial.nvim"] = {
    -- commit = fns.get_commit("dial.nvim", plugins_snapshot),
    keys = editor_config.dial_nvim.keys,
    config = editor_config.dial_nvim.config,
}

plugins["lvim-tech/lvim-move"] = {
    -- commit = fns.get_commit("lvim-move", plugins_snapshot),
    opts = editor_config.lvim_move.opts,
}

plugins["mistweaverco/kulala.nvim"] = {
    -- commit = fns.get_commit("kulala.nvim", plugins_snapshot),
    ft = { "http", "rest" },
    config = editor_config.kulala_nvim.config,
}

plugins["arjunmahishi/flow.nvim"] = {
    -- commit = fns.get_commit("flow.nvim", plugins_snapshot),
    cmd = editor_config.flow_nvim.cmd,
    keys = editor_config.flow_nvim.keys,
    opts = editor_config.flow_nvim.opts,
}

plugins["coffebar/transfer.nvim"] = {
    -- commit = fns.get_commit("transfer.nvim", plugins_snapshot),
    cmd = editor_config.transfer_nvim.cmd,
    keys = editor_config.transfer_nvim.keys,
    opts = editor_config.transfer_nvim.opts,
}

plugins["ALameLlama/compiler.nvim"] = {
    -- commit = fns.get_commit("compiler.nvim", plugins_snapshot),
    branch = "feat/add-support-for-native-nvim-selector",
    cmd = editor_config.compiler_nvim.cmd,
    keys = editor_config.compiler_nvim.keys,
    opts = editor_config.compiler_nvim.opts,
}

plugins["stevearc/overseer.nvim"] = {
    -- -- commit = fns.get_commit("overseer.nvim", plugins_snapshot),
    -- branch = "stevearc-rewrite",
    cmd = editor_config.overseer_nvim.cmd,
    keys = editor_config.overseer_nvim.keys,
    opts = editor_config.overseer_nvim.opts,
}

plugins["MagicDuck/grug-far.nvim"] = {
    -- commit = fns.get_commit("grug-far.nvim", plugins_snapshot),
    cmd = editor_config.grug_far_nvim.cmd,
    keys = editor_config.grug_far_nvim.keys,
    opts = editor_config.grug_far_nvim.opts,
}

plugins["gabrielpoca/replacer.nvim"] = {
    -- commit = fns.get_commit("replacer.nvim", plugins_snapshot),
    cmd = editor_config.replacer_nvim.cmd,
    keys = editor_config.replacer_nvim.keys,
    opts = editor_config.replacer_nvim.opts,
}

plugins["numToStr/Comment.nvim"] = {
    -- commit = fns.get_commit("Comment.nvim", plugins_snapshot),
    opts = editor_config.comment_nvim.opts,
}

plugins["ton/vim-bufsurf"] = {
    -- commit = fns.get_commit("vim-bufsurf", plugins_snapshot),
    config = editor_config.vim_bufsurf.config,
}

plugins["danymat/neogen"] = {
    -- commit = fns.get_commit("neogen", plugins_snapshot),
    cmd = editor_config.neogen.cmd,
    opts = editor_config.neogen.opts,
}

plugins["uga-rosa/ccc.nvim"] = {
    -- commit = fns.get_commit("uga-rosa/ccc.nvim", plugins_snapshot),
    cmd = editor_config.ccc_nvim.cmd,
    keys = editor_config.ccc_nvim.keys,
    opts = editor_config.ccc_nvim.opts,
}

plugins["brenoprata10/nvim-highlight-colors"] = {
    -- commit = fns.get_commit("brenoprata10/nvim-highlight-colors", plugins_snapshot),
    opts = editor_config.nvim_highlight_colors.opts,
}

plugins["folke/flash.nvim"] = {
    -- commit = fns.get_commit("flash.nvim", plugins_snapshot),
    keys = editor_config.flash_nvim.keys,
    opts = editor_config.flash_nvim.opts,
}

plugins["folke/todo-comments.nvim"] = {
    -- commit = fns.get_commit("todo-comments.nvim", plugins_snapshot),
    cmd = editor_config.todo_comments_nvim.cmd,
    opts = editor_config.todo_comments_nvim.opts,
}

plugins["renerocksai/calendar-vim"] = {
    -- commit = fns.get_commit("calendar-vim", plugins_snapshot),
    cmd = editor_config.calendar_vim.cmd,
    keys = editor_config.calendar_vim.keys,
    config = editor_config.calendar_vim.config,
}
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- GIT ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local version_control_config = require("plugins.core.config.git")

plugins["wintermute-cell/gitignore.nvim"] = {
    -- commit = fns.get_commit("gitignore.nvim", plugins_snapshot),
}

plugins["NeogitOrg/neogit"] = {
    -- commit = fns.get_commit("neogit", plugins_snapshot),
    cmd = version_control_config.neogit.cmd,
    keys = version_control_config.neogit.keys,
    opts = version_control_config.neogit.opts,
}

plugins["lvim-tech/mini.diff"] = {
    -- commit = fns.get_commit("mini.diff", plugins_snapshot),
    opts = version_control_config.mini_diff.opts,
}

plugins["tanvirtin/vgit.nvim"] = {
    -- commit = fns.get_commit("vgit.nvim", plugins_snapshot),
    opts = version_control_config.vgit.opts,
    config = version_control_config.vgit.config,
}

plugins["sindrets/diffview.nvim"] = {
    -- commit = fns.get_commit("diffview.nvim", plugins_snapshot),
    cmd = version_control_config.diffview_nvim.cmd,
    keys = version_control_config.diffview_nvim.keys,
    opts = version_control_config.diffview_nvim.opts,
}

plugins["y3owk1n/time-machine.nvim"] = {
    -- commit = fns.get_commit("time-machine", plugins_snapshot),
    cmd = version_control_config.time_machine_nvim.cmd,
    keys = version_control_config.time_machine_nvim.keys,
    opts = version_control_config.time_machine_nvim.opts,
}
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- LANGUAGES ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local languages_config = require("plugins.core.config.languages")

plugins["mason-org/mason.nvim"] = {
    -- commit = fns.get_commit("mason.nvim", plugins_snapshot),
    build = ":MasonUpdate",
    opts = languages_config.mason.opts,
}

plugins["nvim-neotest/neotest"] = {
    -- commit = fns.get_commit("neotest", plugins_snapshot),
    cmd = languages_config.neotest.cmd,
    keys = languages_config.neotest.keys,
    opts = languages_config.neotest.opts,
}

plugins["chrisgrieser/nvim-rip-substitute"] = {
    -- commit = fns.get_commit("nvim-rip-substitute", plugins_snapshot),
    cmd = languages_config.nvim_rip_substitute.cmd,
    keys = languages_config.nvim_rip_substitute.keys,
    opts = languages_config.nvim_rip_substitute.opts,
}

plugins["DNLHC/glance.nvim"] = {
    -- commit = fns.get_commit("glance.nvim", plugins_snapshot),
    keys = languages_config.glance_nvim.keys,
    opts = languages_config.glance_nvim.opts,
}

plugins["folke/trouble.nvim"] = {
    -- commit = fns.get_commit("trouble.nvim", plugins_snapshot),
    cmd = languages_config.trouble_nvim.cmd,
    keys = languages_config.trouble_nvim.keys,
    opts = languages_config.trouble_nvim.opts,
}

plugins["mfussenegger/nvim-jdtls"] = {
    -- commit = fns.get_commit("nvim-jdtls", plugins_snapshot),
    ft = "java",
}

plugins["scalameta/nvim-metals"] = {
    -- commit = fns.get_commit("nvim-metals", plugins_snapshot),
    ft = { "scala", "sbt" },
}

plugins["nvim-flutter/flutter-tools.nvim"] = {
    -- commit = fns.get_commit("flutter-tools.nvim", plugins_snapshot),
    ft = "dart",
    opts = languages_config.flutter_tools_nvim.opts,
}

plugins["jsongerber/nvim-px-to-rem"] = {
    -- commit = fns.get_commit("nvim-px-to-rem", plugins_snapshot),
    ft = {
        "css",
        "scss",
        "less",
        "astro",
    },
    cmd = languages_config.nvim_px_to_rem.cmd,
    keys = languages_config.nvim_px_to_rem.keys,
    opts = languages_config.nvim_px_to_rem.opts,
}

plugins["kosayoda/nvim-lightbulb"] = {
    -- commit = fns.get_commit("nvim-lightbulb", plugins_snapshot),
    opts = languages_config.nvim_lightbulb.opts,
}

plugins["nvim-treesitter/nvim-treesitter"] = {
    -- commit = fns.get_commit("nvim-treesitter", plugins_snapshot),
    lazy = false,
    branch = "main",
    build = ":TSUpdate",
    config = languages_config.nvim_treesitter.config,
}

plugins["nvim-treesitter/nvim-treesitter-context"] = {
    -- commit = fns.get_commit("nvim-treesitter-context", plugins_snapshot),
    opts = languages_config.nvim_treesitter_context.opts,
}

plugins["j-hui/fidget.nvim"] = {
    -- commit = fns.get_commit("fidget.nvim", plugins_snapshot),
    opts = languages_config.fidget_nvim.opts,
}

plugins["SmiteshP/nvim-navic"] = {
    -- commit = fns.get_commit("nvim-navic", plugins_snapshot),
    opts = languages_config.nvim_navic.opts,
}

plugins["hedyhli/outline.nvim"] = {
    -- commit = fns.get_commit("outline.nvim", plugins_snapshot),
    cmd = languages_config.outline.cmd,
    keys = languages_config.outline.keys,
    opts = languages_config.outline.opts,
}

plugins["mfussenegger/nvim-dap"] = {
    -- commit = fns.get_commit("nvim-dap", plugins_snapshot),
    cmd = languages_config.nvim_dap.cmd,
    keys = languages_config.nvim_dap.keys,
    config = languages_config.nvim_dap.config,
}

plugins["lvim-tech/vim-dadbod-ui"] = {
    -- commit = fns.get_commit("vim-dadbod-ui", plugins_snapshot),
    cmd = languages_config.vim_dadbod_ui.cmd,
    keys = languages_config.vim_dadbod_ui.keys,
    init = languages_config.vim_dadbod_ui.init,
}

plugins["lvim-tech/nvim-dbee"] = {
    -- commit = fns.get_commit("nvim-dbee", plugins_snapshot),
    build = function()
        require("dbee").install()
    end,
    cmd = languages_config.nvim_dbee.cmd,
    keys = languages_config.nvim_dbee.keys,
    opts = languages_config.nvim_dbee.opts,
}

plugins["vuki656/package-info.nvim"] = {
    -- commit = fns.get_commit("package-info.nvim", plugins_snapshot),
    event = "BufReadPost package.json",
    opts = languages_config.package_info_nvim.opts,
}

plugins["Saecki/crates.nvim"] = {
    -- commit = fns.get_commit("crates.nvim", plugins_snapshot),
    event = "BufReadPost Cargo.toml",
    opts = languages_config.crates_nvim.opts,
}

plugins["lvim-tech/pubspec-assist.nvim"] = {
    -- commit = fns.get_commit("pubspec-assist.nvim", plugins_snapshot),
    event = "BufReadPost pubspec.yaml",
    opts = languages_config.pubspec_assist_nvim.opts,
}

plugins["dhruvasagar/vim-table-mode"] = {
    -- commit = fns.get_commit("dhruvasagar/vim-table-mode", plugins_snapshot),
    ft = { "markdown", "text" },
}

plugins["iamcco/markdown-preview.nvim"] = {
    -- commit = fns.get_commit("markdown-preview.nvim", plugins_snapshot),
    -- build = "cd app && npm install",
    build = "cd app && yarn install; git restore app/yarn.lock",
    ft = { "md", "markdown" },
    cmd = languages_config.markdown_preview_nvim.cmd,
    keys = languages_config.markdown_preview_nvim.keys,
}

plugins["OXY2DEV/markview.nvim"] = {
    -- commit = fns.get_commit("markview-nvim", plugins_snapshot),
    ft = { "md", "markdown", "Avante" },
    opts = languages_config.markview_nvim.opts,
}

plugins["OXY2DEV/helpview.nvim"] = {
    -- commit = fns.get_commit("markview-nvim", plugins_snapshot),
    opts = languages_config.helpview_nvim.opts,
}

plugins["lervag/vimtex"] = {
    -- commit = fns.get_commit("vimtex", plugins_snapshot),
    config = languages_config.vimtex.config,
}

plugins["nvim-orgmode/orgmode"] = {
    -- commit = fns.get_commit("orgmode", plugins_snapshot),
    ft = "org",
    opts = languages_config.orgmode.opts,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- COMPLETION ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local completion_config = require("plugins.core.config.completion")
plugins["Saghen/blink.cmp"] = {
    -- commit = fns.get_commit("blink.cmp", plugins_snapshot),
    event = "VeryLazy",
    build = "cargo build --release",
    opts = completion_config.blink_cmp.opts,
}
plugins["nvim-mini/mini.ai"] = {
    -- -- commit = fns.get_commit("mini.ai", plugins_snapshot),
    config = completion_config.mini_ai.config,
}

plugins["windwp/nvim-autopairs"] = {
    -- -- commit = fns.get_commit("nvim-autopairs", plugins_snapshot),
    config = completion_config.nvim_autopairs.config,
}

plugins["windwp/nvim-ts-autotag"] = {
    -- -- commit = fns.get_commit("nvim-ts-autotag", plugins_snapshot),
    opts = completion_config.nvim_ts_autotag.opts,
}

plugins["kylechui/nvim-surround"] = {
    -- -- commit = fns.get_commit("nvim-surround", plugins_snapshot),
    opts = completion_config.nvim_surround.opts,
}

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- THEMES ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

local themes_config = require("plugins.core.config.themes")

plugins["catppuccin/nvim"] = {
    -- commit = fns.get_commit("catppuccine", plugins_snapshot),
    priority = 1000,
    config = themes_config.catppuccin.config,
}

plugins["lvim-tech/lvim-colorscheme"] = {
    -- commit = fns.get_commit("lvim-colorscheme", plugins_snapshot),
    priority = 1000,
    config = themes_config.lvim_colorscheme.config,
}

plugins["ribru17/bamboo.nvim"] = {
    -- commit = fns.get_commit("bamboo", plugins_snapshot),
    priority = 1000,
    config = themes_config.bamboo.config,
}
return plugins
