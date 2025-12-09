local M = {}

M.set_keymaps_ft = function()
    require "config.keymaps_ft.netrw"()
    require "config.keymaps_ft.dart"()
    require "config.keymaps_ft.tex"()
end

return M
