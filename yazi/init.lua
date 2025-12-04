require("augment-command"):setup({
	smooth_scrolling = true,
	scroll_delay = 0.02, -- Adjust this number: smaller = faster, larger = slower
	wraparound_file_navigation = true, -- Optional: Loops from bottom back to top
})
-- Displays Git file status (added, modified, untracked) as a "linemode" in the file list,

-- 1. Define Git Styles and Signs
-- 定义 Git 样式和图标
-- Git (ギット) のスタイルとアイコンを定義する
th.git = th.git or {}

-- 1.1 Signs (Text) / 文本图标
th.git.modified_sign = "M" -- Modified
th.git.added_sign = "A" -- Added
th.git.untracked_sign = "U" -- Untracked
th.git.deleted_sign = "D" -- Deleted
th.git.ignored_sign = "I" -- Ignored

-- 1.2 Styles (Colors) / 样式 (颜色)
th.git.modified = ui.Style():fg("blue") -- Blue
th.git.added = ui.Style():fg("green") -- Green
th.git.untracked = ui.Style():fg("magenta") -- Magenta
th.git.deleted = ui.Style():fg("red") -- Red
th.git.ignored = ui.Style():fg("white"):dim() -- Dimmed

-- 2. Setup the plugin (Must be called AFTER configuration)
-- 初始化插件 (必须在配置之后调用)
-- 設定の後にプラグインをセットアップする
require("git"):setup()
-- Enable full border UI
-- 启用全边框 UI 界面
require("full-border"):setup()
