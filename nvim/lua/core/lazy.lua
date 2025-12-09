local fns = require("core.fns")
local icons = require("config.ui.icons")

local lazy_pack = {}

lazy_pack.is_lazy = function()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out, "WarningMsg" },
                { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
        end
    end

    vim.opt.rtp:prepend(lazypath)
end

lazy_pack.load = function()
    local repos = {}
    local core_plugins = require("plugins.core")
    local extra_plugins = require("plugins.extra")
    local plugins = fns.merge(core_plugins, extra_plugins)

    for repo, conf in pairs(plugins) do
        if conf ~= false then
            repos[#repos + 1] = vim.tbl_extend("force", { repo }, conf)
        end
    end

    require("lazy").setup(repos, {
        install = {
            missing = true,
            colorscheme = { _G.THEME, "hamamax" },
        },

        ui = {
            size = {
                width = 0.95,
                height = 0.95,
            },
            border = "none",
            icons = icons.lazy,
        },
    })
end

return lazy_pack
