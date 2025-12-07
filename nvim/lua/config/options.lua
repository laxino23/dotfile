local o = vim.opt
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- =============================================================================
--  1. UI & Visuals (界面与视觉)
-- =============================================================================
o.number = true -- 显示行号
o.relativenumber = true -- 显示相对行号 (方便上下跳转)
o.cursorline = true -- 高亮当前行
o.signcolumn = "yes" -- 始终显示符号列 (防止文本因诊断图标出现而移动)
o.termguicolors = true -- 启用 24 位真彩色 (RGB)
o.sidescrolloff = 8 -- 侧向滚动时，光标左右保留的上下文列数
o.wrap = true -- 开启自动换行 (原注释为禁用，但 true 是开启，通常代码不换行，文本换行)
o.textwidth = 80 -- 设置文本宽度为 80 字符
o.colorcolumn = "80" -- 在第 80 列显示参考线
o.scrolloff = 8 -- 光标上下移动时，保留的最小上下文行数
o.whichwrap:append("<,>,[,],h,l") -- 允许特定的键在行首/行尾自动换行

-- =============================================================================
--  2. Indentation (缩进配置 - Lua/Web 标准为 2 空格，Python 通常为 4)
-- =============================================================================
o.expandtab = true -- 将 Tab 键转换为空格
o.tabstop = 4 -- 一个 Tab 代表的空格数
o.shiftwidth = 0 -- 自动缩进的宽度 (设为 0 时跟随 tabstop)
o.softtabstop = 4 -- 编辑模式下按 Tab/退格键时视作的空格数
o.smartindent = true -- 开启智能缩进

-- =============================================================================
--  3. Search & Replace (搜索与替换)
-- =============================================================================
o.ignorecase = true -- 搜索时忽略大小写
o.smartcase = true -- ...除非搜索词中包含大写字母
o.inccommand = "split" -- 实时预览替换命令的效果 (例如输入 :%s/foo/bar/ 时)

-- =============================================================================
--  4. System & Performance (系统与性能)
-- =============================================================================
o.clipboard = "unnamedplus" -- 与系统剪贴板同步 (需要安装 xclip 或 wl-clipboard)
o.updatetime = 250 -- 缩短更新时间 (影响 swap 文件写入和 CursorHold 事件触发频率)
o.timeoutlen = 300 -- 缩短组合键序列的等待时间
o.swapfile = false -- 禁用 swap 交换文件 (通常很烦人，有 git 就够了)
o.backup = false -- 禁止生成备份文件
o.encoding = "utf-8" -- Vim 内部编码
o.fileencoding = "utf-8" -- 文件保存编码

-- =============================================================================
--  5. Window Splitting (窗口分割)
-- =============================================================================
o.splitright = true -- 新窗口在当前窗口右侧打开
o.splitbelow = true -- 新窗口在当前窗口下方打开

-- =============================================================================
--  6. History and Undos (历史记录与撤销)
-- =============================================================================
o.undofile = true -- 启用持久化撤销 (重启 Neovim 后仍可撤销)
o.undolevels = 10000 -- 最大撤销记录数
o.undoreload = 10000 -- 重载缓冲区时保存的最大撤销记录数
o.history = 1000 -- 命令行 (:command) 历史记录条数

-- =============================================================================
--  7. Others (其他)
-- =============================================================================
o.completeopt = { "menu", "menuone", "noselect" } -- 代码补全弹窗设置

-- =============================================================================
-- ── Neovide 专属配置 (只有在 Neovide 中启动时才生效) ──
-- =============================================================================
if vim.g.neovide then
  -- 1. 模糊设置 (Blur)
  -- 注意：模糊效果极其依赖系统 compositor。macOS 默认支持，
  -- Windows/Linux 可能需要额外 compositor 配置。
  vim.g.neovide_window_blurred = true

  -- 2. 浮动窗口模糊 (Floating Blur)
  -- 这就是你配置里的 floating_blur_amount
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5

  -- 3. 浮动窗口圆角 (Rounded Corners for Floating Windows)
  -- 你之前的 decoration-rounded = 25 是无效的 TOML 键。
  vim.g.neovide_floating_corner_radius = 0.5 -- 0.0 ~ 1.0 (比例)
  -- other window effects
  vim.g.neovide_scroll_animation_far_lines = 1
  vim.g.neovide_hide_mouse_when_typing = false

  -- 4. 粒子特效 (如果在 TOML 没生效，可以在这里强制开启)
  vim.g.neovide_cursor_vfx_mode = "ripple"
  vim.g.neovide_cursor_trail_size = 1.0

  -- 5. 确保这一项开启，否则透明背景可能看起来很奇怪
  vim.opt.termguicolors = true

  -- 6. padding 设置

  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_left = 10
  vim.g.neovide_padding_right = 10

  -- 7. trasparent
  vim.g.neovide_opacity = 0.8
  vim.g.neovide_normal_opacity = 0.8
end
