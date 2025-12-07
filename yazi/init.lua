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

require("restore"):setup({
	-- Set the position for confirm and overwrite prompts.
	-- Don't forget to set height: `h = xx`
	-- https://yazi-rs.github.io/docs/plugins/utils/#ya.input
	position = { "center", w = 70, h = 40 }, -- Optional

	-- Show confirm prompt before restore.
	-- NOTE: even if set this to false, overwrite prompt still pop up
	show_confirm = true, -- Optional

	-- Suppress success notification when all files or folder are restored.
	suppress_success_notification = true, -- Optional

	-- colors for confirm and overwrite prompts
	theme = { -- Optional
		-- Default using style from your flavor or theme.lua -> [confirm] -> title.
		-- If you edit flavor or theme.lua you can add more style than just color.
		-- Example in theme.lua -> [confirm]: title = { fg = "blue", bg = "green"  }
		title = "blue", -- Optional. This value has higher priority than flavor/theme.lua

		-- Default using style from your flavor or theme.lua -> [confirm] -> content
		-- Sample logic as title above
		header = "green", -- Optional. This value has higher priority than flavor/theme.lua

		-- header color for overwrite prompt
		-- Default using color "yellow"
		header_warning = "yellow", -- Optional
		-- Default using style from your flavor or theme.lua -> [confirm] -> list
		-- Sample logic as title and header above
		list_item = { odd = "blue", even = "blue" }, -- Optional. This value has higher priority than flavor/theme.lua
	},
})
