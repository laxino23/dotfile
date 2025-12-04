vim.pack.add({
  {
    src = "https://github.com/folke/snacks.nvim",
    name = "snacks.nvim",
    version = "main",
  },
}, {
  load = false,
})

local ok_1, picker_config = pcall(require, "plugins.snacks.picker")
if not ok_1 then
  vim.notify("Snacks Picker 配置加载失败: " .. tostring(picker_config), vim.log.levels.WARN)
  picker_config = {}
end

local ok_2, indent_config = pcall(require, "plugins.indent")
if not ok_2 then
  vim.notify("Snacks Indent 配置加载失败: " .. tostring(indent_config), vim.log.levels.WARN)
  indent_config = {}
end

local opts = {
  -- Picker and Indent
  picker = picker_config,
  indent = {
    indent = indent_config.indent,
    animate = indent_config.animate,
    scope = indent_config.scope,
    chunk = indent_config.chunk,
  },

  -- Other Configs
  explorer = { enabled = true, replace_netrw = false },
  image = { enabled = true },
  dim = { enabled = false },
  zen = { enabled = true },
  scroll = { enabled = false },
  input = { enabled = true },
  words = { enabled = true },
  statuscolumn = {
    left = { "mark", "sign" },
    right = { "fold", "git" },
    folds = { open = true, git_hl = true },
  },
  notifier = { enabled = false },
  toggle = { enabled = true },
  lazygit = { enabled = false },
  terminal = { enabled = true },
  gitbrowse = { enabled = true },
  dashboard = { enabled = true },
}

vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    require("snacks").setup(opts)
  end,
  once = true,
})

local keys_ok, keys_module = pcall(require, "plugins.snacks.keymaps")
if keys_ok and type(keys_module) == "table" then
  for name, map in pairs(keys_module) do
    local mode = map.mode or map[1] or "n"
    local lhs = map.lhs or map[2]
    local rhs = map.rhs or map[3]
    local desc = map.desc

    if lhs and rhs then
      vim.keymap.set(mode, lhs, rhs, {
        desc = desc or name,
        silent = true,
      })
    end
  end
else
  vim.notify("Snacks Keymaps 加载失败", vim.log.levels.WARN)
end
