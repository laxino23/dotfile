-- Load the utils module
-- 加载工具模块
local utils = require("config.keymaps.utils")

-- Create a local alias for the map function FROM UTILS
-- 从 UTILS 中获取 map 函数别名 (Corrected)
local map = utils.map

-- ============================================================================
-- Basic Operations / 基础操作
-- ============================================================================

map({
  ["save"] = { "n", "<leader>ww", ":w<CR>" },
  ["save-and-quit"] = { "n", "<leader>wq", ":wq<CR>" },
  ["just-quit"] = { "n", "<leader>we", ":q<CR>" },
  ["update-and-source"] = { "n", "<leader>o", ":update<CR> :source<CR>" },
}, { silent = true })

-- ============================================================================
-- Line Movement / 行移动
-- ============================================================================

local lineMovement = utils.lineMovement

map({
  ["move-selection-down"] = {
    "x",
    "<M-Down>",
    function()
      lineMovement.move_visual_selection("down")
    end,
  },
  ["move-selection-up"] = {
    "x",
    "<M-Up>",
    function()
      lineMovement.move_visual_selection("up")
    end,
  },
  ["move-line-down"] = {
    "n",
    "<M-Down>",
    function()
      lineMovement.move_normal_selection("down")
    end,
  },
  ["move-line-up"] = {
    "n",
    "<M-Up>",
    function()
      lineMovement.move_normal_selection("up")
    end,
  },
}, { silent = true })

-- ============================================================================
-- Better Cursor Movement / 更好的光标移动
-- ============================================================================

map({
  ["move-cursor-down"] = { { "n", "x", "v" }, "j", "v:count == 0 ? 'gj' : 'j'" },
  ["move-cursor-up"] = { { "n", "x", "v" }, "k", "v:count == 0 ? 'gk' : 'k'" },
}, { expr = true, silent = true })

-- ============================================================================
-- Comment Functions / 注释功能
-- ============================================================================

local comment = utils.comment

map({
  ["comment-line"] = { "n", "gcc", comment.comment_line },
  ["comment-above"] = { "n", "gcO", comment.comment("above") },
  ["comment-below"] = { "n", "gco", comment.comment("below") },
  ["comment-end"] = { "n", "gcA", comment.comment("end") },
}, { silent = true })

-- ============================================================================
-- Insert Empty Lines / 插入空行
-- ============================================================================

map({
  ["new-empty-line-below"] = { "n", "<M-o>", "o<Esc>" },
  ["new-empty-line-above"] = { "n", "<M-O>", "O<Esc>" },
}, { silent = true })

-- ============================================================================
-- Better Paste / 更好的粘贴
-- ============================================================================

map({
  ["paste-without-yank"] = { "x", "p", '"_dP' },
  ["delete-without-yank"] = { { "n", "v" }, "D", '"_d' },
}, { silent = true, remap = false })

-- ============================================================================
-- Window Navigation / 窗口导航
-- ============================================================================

map({
  ["window-left"] = { "n", "<C-h>", "<C-w>h" },
  ["window-down"] = { "n", "<C-j>", "<C-w>j" },
  ["window-up"] = { "n", "<C-k>", "<C-w>k" },
  ["window-right"] = { "n", "<C-l>", "<C-w>l" },
}, { silent = true })

-- ============================================================================
-- Window Split / 窗口分裂
-- ============================================================================

map({
  ["split-vertically"] = { { "n", "v" }, "<leader>sv", ":vsplit<CR>" },
  ["split-horizontally"] = { { "n", "v" }, "<leader>sh", ":split<CR>" },
}, { silent = true })

-- ============================================================================
-- Window Resizing / 窗口大小调整
-- ============================================================================

map({
  ["resize-left"] = { "n", "<C-Left>", ":vertical resize -2<CR>" },
  ["resize-right"] = { "n", "<C-Right>", ":vertical resize +2<CR>" },
  ["resize-up"] = { "n", "<C-Up>", ":resize +2<CR>" },
  ["resize-down"] = { "n", "<C-Down>", ":resize -2<CR>" },
}, { silent = true })

-- ============================================================================
-- Buffer Navigation / 缓冲区导航
-- ============================================================================

map({
  ["next-buffer"] = { "n", "<leader>bl", ":bnext<CR>" },
  ["prev-buffer"] = { "n", "<leader>bh", ":bprevious<CR>" },
  ["close-buffer"] = { "n", "<leader>bc", ":bdelete<CR>" },
}, { silent = true })

-- ============================================================================
-- Better Indenting / 更好的缩进
-- ============================================================================

map({
  ["indent-left"] = { "v", "<", "<gv" },
  ["indent-right"] = { "v", ">", ">gv" },
}, { silent = true })

-- ============================================================================
-- Search and Replace / 搜索与替换
-- ============================================================================

map({
  ["clear-search-highlight"] = { "n", "<Esc>", ":noh<CR>" },
  ["search-and-replace"] = { "n", "<leader>sr", ":%s//g<Left><Left>" },
  ["search-and-replace-word"] = { "n", "<leader>sw", ":%s/<C-r><C-w>//g<Left><Left>" },
}, { silent = false })

-- ============================================================================
-- Quick Navigation / 快速导航
-- ============================================================================

map({
  ["start-of-line"] = { { "n", "v" }, "H", "^" },
  ["end-of-line"] = { { "n", "v" }, "L", "$" },
}, { silent = true })

-- ============================================================================
-- Center Screen After Jumps / 跳转后居中屏幕
-- ============================================================================

map({
  ["next-search-centered"] = { "n", "n", "nzzzv" },
  ["prev-search-centered"] = { "n", "N", "Nzzzv" },
  ["half-page-down-centered"] = { "n", "<C-d>", "<C-d>zz" },
  ["half-page-up-centered"] = { "n", "<C-u>", "<C-u>zz" },
}, { silent = true })

-- ============================================================================
-- Quick Fix & Location List
-- ============================================================================

map({
  ["quickfix-next"] = { "n", "]q", ":cnext<CR>" },
  ["quickfix-prev"] = { "n", "[q", ":cprev<CR>" },
  ["location-next"] = { "n", "]l", ":lnext<CR>" },
  ["location-prev"] = { "n", "[l", ":lprev<CR>" },
}, { silent = true })

-- ============================================================================
-- Terminal Mode / 终端模式
-- ============================================================================

map({
  ["terminal-escape"] = { "t", "<Esc>", "<C-\\><C-n>" },
  ["terminal-window-left"] = { "t", "<C-h>", "<C-\\><C-n><C-w>h" },
  ["terminal-window-down"] = { "t", "<C-j>", "<C-\\><C-n><C-w>j" },
  ["terminal-window-up"] = { "t", "<C-k>", "<C-\\><C-n><C-w>k" },
  ["terminal-window-right"] = { "t", "<C-l>", "<C-\\><C-n><C-w>l" },
}, { silent = true })

-- ============================================================================
-- Other Customization / 其他自定义
-- ============================================================================

local action = utils.action

vim.keymap.set("n", "u", "<Nop>", { noremap = true, silent = true })

map({
  ["undo"] = { { "n", "i", "v", "t", "c" }, "<C-z>", action.undo },
  ["redo"] = { { "n", "i", "v", "t", "c" }, "<C-r>", action.redo },
}, { silent = true })

map({
  ["left-arrow-visual-select"] = { "n", "<Left>", "vh" },
  ["right-arrow-visual-select"] = { "n", "<Right>", "vl" },
}, { silent = true })

local line_manage = utils.line_manage

map({
  ["insert-above-three-lines"] = {
    "n",
    "<leader>op",
    function()
      line_manage.insert_lines("up")
    end,
  },
  ["insert-below-three-lines"] = {
    "n",
    "<leader>oo",
    function()
      line_manage.insert_lines("down")
    end,
  },
  ["join-lines"] = { { "n", "v" }, "J", line_manage.join_lines },
}, { silent = true })
