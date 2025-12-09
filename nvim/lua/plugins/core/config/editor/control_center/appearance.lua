local fns = require("core.fns")
local data = require("lvim-control-center.persistence.data")
local icons = require("config.ui.icons")

local function is_control_center_focused(win)
    if not win or not vim.api.nvim_win_is_valid(win) then
        return false
    end
    return vim.api.nvim_get_current_win() == win
end

return {
    name = "appearance",
    label = "Appearance",
    icon = icons.common.palette,
    settings = {
        {
            name = "colorscheme",
            label = "Colorscheme",
            type = "select",
            options = { "bamboo", "lvim-darker", "lvim-everforest", "lvim-gruvbox", "lvim-kanagawa", "lvim-light" },
            default = "bamboo",
            break_load = true,
            get = function()
                if _G.THEME ~= nil then
                    return _G.THEME
                else
                    return "lvim-darker"
                end
            end,
            set = function(val, _)
                _G.THEME = val
                vim.cmd("colorscheme " .. val)
                fns.write_file(_G.global.custom_path .. "/.configs/custom/.theme", _G.THEME)
                ---@diagnostic disable-next-line: undefined-field
                if _G.CONTROL_CENTER_WIN and is_control_center_focused(_G.CONTROL_CENTER_WIN) then
                    vim.cmd("hi Cursor blend=100")
                else
                    vim.cmd("hi Cursor blend=0")
                end
                data.save("colorscheme", val)
            end,
        },
        {
            name = "floatheight",
            label = "Float height",
            type = "select",
            options = { 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0 },
            default = 0.4,
            get = function()
                return _G.SETTINGS and _G.SETTINGS["floatheight"] or 0.4
            end,
            set = function(val, on_init)
                _G.SETTINGS["floatheight"] = val
                if not on_init then
                    data.save("floatheight", val)
                end
            end,
        },
    },
}