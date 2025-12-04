vim.pack.add({
  { src = "https://github.com/jake-stewart/multicursor.nvim" },
})

local status, mc = pcall(require, "multicursor-nvim")
if not status then
  return
end
mc.setup()

local map = require("config.keymaps").map
map({
  -- === 基础操作 ===
  ["multicursor-add-cursor"] = { { "n", "x" }, "mm", mc.addCursor },
  ["multicursor-toggle"] = { { "n", "x" }, "<leader>up", mc.toggleCursor },

  -- === 行操作 (添加) ===
  ["multicursor-add-up"] = {
    { "n", "x" },
    "<up>",
    function()
      mc.lineAddCursor(-1)
    end,
  },
  ["multicursor-add-down"] = {
    { "n", "x" },
    "<down>",
    function()
      mc.lineAddCursor(1)
    end,
  },

  -- === 行操作 (跳过) ===
  ["multicursor-skip-up"] = {
    { "n", "x" },
    "<leader><up>",
    function()
      mc.lineSkipCursor(-1)
    end,
  },
  ["multicursor-skip-down"] = {
    { "n", "x" },
    "<leader><down>",
    function()
      mc.lineSkipCursor(1)
    end,
  },

  -- === 匹配操作 ===
  ["multicursor-match-next"] = {
    { "n", "x" },
    "<C-d>",
    function()
      mc.matchAddCursor(1)
    end,
  },
  ["multicursor-match-prev"] = {
    { "n", "x" },
    "<C-u>",
    function()
      mc.matchAddCursor(-1)
    end,
  },

  -- === 鼠标操作 ===
  ["multicursor-mouse-click"] = { "n", "<c-leftmouse>", mc.handleMouse },
  ["multicursor-mouse-drag"] = { "n", "<c-leftdrag>", mc.handleMouseDrag },
  ["multicursor-mouse-release"] = { "n", "<c-leftrelease>", mc.handleMouseRelease },
})
mc.addKeymapLayer(function(layerSet)
  -- 切换主光标（上一个/下一个）
  layerSet({ "n", "x" }, "[p", mc.prevCursor)
  layerSet({ "n", "x" }, "]p", mc.nextCursor)

  -- 按 ESC：如果禁用光标 → 启用；否则 → 清除所有光标
  layerSet("n", "<esc>", function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)

-- 设置多光标的高亮样式
local hl = vim.api.nvim_set_hl
hl(0, "MultiCursorCursor", { reverse = true }) -- 主光标样式
hl(0, "MultiCursorVisual", { link = "Visual" }) -- 多光标的视觉模式样式
hl(0, "MultiCursorSign", { link = "SignColumn" }) -- 多光标左侧符号栏
hl(0, "MultiCursorMatchPreview", { link = "IncSearch" }) -- 匹配预览样式
hl(0, "MultiCursorDisabledCursor", { reverse = true }) -- 禁用状态的光标
hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
