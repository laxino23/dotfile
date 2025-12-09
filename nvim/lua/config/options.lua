require("config.ui.fold")

local M = {}

M.global = function()
	local o = vim.opt
	
	-- =============================================================================
	-- Global Variables (全局变量配置)
	-- =============================================================================
	vim.g.gitblame_enabled = 0
	vim.g.gitblame_highlight_group = "CursorLine"
	vim.g.netrw_banner = 0
	vim.g.netrw_hide = 1
	vim.g.netrw_browse_split = 0
	vim.g.netrw_altv = 1
	vim.g.netrw_liststyle = 1
	vim.g.netrw_winsize = 20
	vim.g.netrw_keepdir = 1
	vim.g.netrw_list_hide = "(^|ss)\zs.S+"
	vim.g.netrw_localcopydircmd = "cp -r"

	-- =============================================================================
	-- UI & Visuals (界面与视觉)
	-- =============================================================================
	o.number = true -- 显示行号
	o.relativenumber = true -- 显示相对行号 (方便上下跳转)
	o.cursorline = true -- 高亮当前行
	o.cursorcolumn = true
	o.signcolumn = "yes" -- 始终显示符号列 (防止文本因诊断图标出现而移动)
	o.termguicolors = true -- 启用 24 位真彩色 (RGB)
	o.scrolloff = 8 -- 光标上下移动时，保留的最小上下文行数
	o.sidescrolloff = 8 -- 侧向滚动时，光标左右保留的上下文列数
	o.wrap = true -- 开启自动换行
	o.linebreak = true
	o.textwidth = 80 -- 设置文本宽度为 80 字符
	o.colorcolumn = "80" -- 在第 80 列显示参考线
	o.whichwrap = "h,l,<,>,[,],~"
	o.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor/lCursor,r-cr:hor20,o:hor50"
	o.showmode = false
	o.ruler = false
	o.list = true
	o.showtabline = 1
	o.showcmd = false
	o.cmdheight = 0
	o.cmdwinheight = 5
	o.laststatus = 3
	o.display = "lastline"
	o.showbreak = "↳  "
	o.listchars = "tab:  ,nbsp: ,trail: ,space: ,extends:→,precedes:←"
	o.pumblend = 0
	o.winblend = 0
	o.pumheight = 15
	o.helpheight = 12
	o.previewheight = 12
	o.winwidth = 30
	o.winminwidth = 10
	o.equalalways = false
	o.conceallevel = 2
	o.breakindentopt = "shift:2,min:20"

	-- =============================================================================
	-- Indentation (缩进配置)
	-- =============================================================================
	o.expandtab = true -- 将 Tab 键转换为空格
	o.tabstop = 4 -- 一个 Tab 代表的空格数
	o.shiftwidth = 0 -- 自动缩进的宽度 (设为 0 时跟随 tabstop)
	o.softtabstop = 4 -- 编辑模式下按 Tab/退格键时视作的空格数
	o.smartindent = true -- 开启智能缩进
	o.smarttab = true
	o.shiftround = true
	o.autoindent = true
	o.breakindentopt = "shift:2,min:20"

	-- =============================================================================
	-- Search & Replace (搜索与替换)
	-- =============================================================================
	o.ignorecase = true -- 搜索时忽略大小写
	o.smartcase = true -- ...除非搜索词中包含大写字母
	o.infercase = true
	o.incsearch = true
	o.wrapscan = true
	o.inccommand = "split" -- 实时预览替换命令的效果
	o.grepformat = "%f:%l:%c:%m"
	o.grepprg = "rg --hidden --vimgrep --smart-case --"

	-- =============================================================================
	-- System & Performance (系统与性能)
	-- =============================================================================
	o.clipboard = "unnamedplus" -- 与系统剪贴板同步
	o.updatetime = 250 -- 缩短更新时间
	o.timeoutlen = 300 -- 缩短组合键序列的等待时间
	o.redrawtime = 1500
	o.swapfile = false -- 禁用 swap 交换文件
	o.backup = false -- 禁止生成备份文件
	o.writebackup = false
	o.encoding = "utf-8" -- Vim 内部编码
	o.fileencoding = "utf-8" -- 文件保存编码
	o.fileformats = "unix,mac,dos"
	o.directory = _G.global.cache_path .. "/swag/"
	o.backupdir = _G.global.cache_path .. "/backup/"
	o.viewdir = _G.global.cache_path .. "/view/"
	o.backupskip = "/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*,*/shm/*,/private/var/*,.vault.vim"
	o.wildignorecase = true
	o.wildignore = ".git,.hg,.svn,*.pyc,*.o,*.out,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**"

	-- =============================================================================
	-- Window Splitting (窗口分割)
	-- =============================================================================
	o.splitright = true -- 新窗口在当前窗口右侧打开
	o.splitbelow = true -- 新窗口在当前窗口下方打开
	o.splitkeep = "screen"
	o.switchbuf = "useopen"

	-- =============================================================================
	-- History and Undos (历史记录与撤销)
	-- =============================================================================
	o.undofile = true -- 启用持久化撤销
	o.undolevels = 10000 -- 最大撤销记录数
	o.undoreload = 10000 -- 重载缓冲区时保存的最大撤销记录数
	o.undodir = _G.global.cache_path .. "/undo/"
	o.history = 1000 -- 命令行历史记录条数
	o.shada = "!,'300,<50,@100,s1000,h,c"

	-- =============================================================================
	-- Folding (折叠配置)
	-- =============================================================================
	o.foldenable = true
	o.foldlevelstart = 99
	o.foldmethod = "indent"
	o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	o.foldtext = "v:lua.fold_text()"
	o.fillchars = {
		diff = "╱",
		eob = " ",
		fold = "─",
	}

	-- =============================================================================
	-- Diff Options (差异比较配置)
	-- =============================================================================
	o.diffopt = {
		"internal",
		"filler",
		"closeoff",
		"context:100",
		"algorithm:histogram",
		"linematch:100",
		"indent-heuristic",
		"vertical",
	}

	-- =============================================================================
	-- Others (其他)
	-- =============================================================================
	o.completeopt = { "menu", "menuone", "noselect" } -- 代码补全弹窗设置
	o.complete = ".,w,b,k"
	o.nrformats:append("alpha")
	o.exrc = true
	o.secure = true
	o.shortmess = "ltToOCFI"
	o.mouse = "nv"
	o.mousemodel = "extend"
	o.errorbells = true
	o.visualbell = true
	o.hidden = true
	o.magic = true
	o.virtualedit = "block"
	o.viewoptions = "folds,cursor,curdir,slash,unix"
	o.sessionoptions = "curdir,help,tabpages,winsize"
	o.breakat = [[\ \	;:,!?]]
	o.startofline = false
	o.backspace = "indent,eol,start"
	o.jumpoptions = "stack"
	o.synmaxcol = 2500
	o.formatoptions = "1jcroql"

	-- =============================================================================
	-- Neovide 专属配置 (只有在 Neovide 中启动时才生效)
	-- =============================================================================
	if vim.g.neovide then
		-- 模糊设置 (Blur)
		vim.g.neovide_window_blurred = true

		-- 浮动窗口模糊 (Floating Blur)
		vim.g.neovide_floating_blur_amount_x = 2.0
		vim.g.neovide_floating_blur_amount_y = 2.0
		vim.g.neovide_floating_shadow = true
		vim.g.neovide_floating_z_height = 10
		vim.g.neovide_light_angle_degrees = 45
		vim.g.neovide_light_radius = 5

		-- 浮动窗口圆角 (Rounded Corners for Floating Windows)
		vim.g.neovide_floating_corner_radius = 0.5 -- 0.0 ~ 1.0 (比例)
		
		-- other window effects
		vim.g.neovide_scroll_animation_far_lines = 1
		vim.g.neovide_hide_mouse_when_typing = false

		-- 粒子特效
		vim.g.neovide_cursor_vfx_mode = "ripple"
		vim.g.neovide_cursor_trail_size = 1.0

		-- padding 设置
		vim.g.neovide_padding_top = 10
		vim.g.neovide_padding_bottom = 10
		vim.g.neovide_padding_left = 10
		vim.g.neovide_padding_right = 10

		-- transparent
		vim.g.neovide_opacity = 0.5
		vim.g.neovide_normal_opacity = 0.5

		-- enable opts to meta
		vim.g.neovide_input_macos_option_key_is_meta = "both"
	end
end

return M
