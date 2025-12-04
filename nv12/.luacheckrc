-- .luacheckrc
std = "luajit"
globals = {
  "vim", -- The most important one for Neovim
  "Snacks", -- Since you use snacks.nvim
}

-- Don't complain about unused arguments (common in callback functions)
ignore = { "212" }

-- Folders to include (lints your init.lua, lua folder, ftplugins, etc.)
include_files = {
  "**/*.lua",
}

-- Exclude vendor folders if you ever add them
exclude_files = {
  "lua/vendor/**/*.lua",
}
