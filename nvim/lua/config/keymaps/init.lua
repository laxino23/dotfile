local map = require("core.fns").keymaps
local M = {}

M.global = function()
    require("config.keymaps.movement")(map)
    require("config.keymaps.comment")(map)
    require("config.keymaps.text_case")(map)
    require("config.keymaps.editor")(map)
    require("config.keymaps.navigation")(map)
    require("config.keymaps.terminal")(map)
end

return M
