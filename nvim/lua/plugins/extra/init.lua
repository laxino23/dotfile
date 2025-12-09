local fns = require("core.fns")

-- local plugins_snapshot = {}
-- local file_content = fns.read_file(_G.global.custom_path .. "/.snapshots/" .. _G.SNAPSHOT)
-- if file_content ~= nil then
    -- plugins_snapshot = file_content
-- end

local plugins = {}

-- You can disable of any default Module (Plug-in)
-- plugins["folke/noice.nvim"] = false

-- You can rewrite of settings of any of default Module (Plug-in)
-- plugins["folke/noice.nvim"] = {
--     -- your code
-- }

-- You can add new Module (Plug-in)
-- plugins["name_of_your/plugin"] = {
--     your code
-- }

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- DEPENDENCIES -------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local dependencies_config = require("plugins.extra.config.dependencies")

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- UI -----------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local ui_config = require("plugins.extra.config.ui")

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- EDITOR -------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local editor_config = require("plugins.extra.config.editor")

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- GIT ----------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local version_control_config = require("plugins.extra.config.git")

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- LANGUAGES ----------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local languages_config = require("plugins.extra.config.languages")

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- COMPLETION ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local completion_config = require("plugins.extra.config.completion")

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- THEMES ---------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- local themes_config = require("plugins.extra.config.themes")

return plugins

