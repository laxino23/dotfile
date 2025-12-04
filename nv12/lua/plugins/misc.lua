-- 1. 插件安装
vim.pack.add({
  { src = "https://github.com/folke/persistence.nvim", name = "persistence.nvim" },
  { src = "https://github.com/folke/ts-comments.nvim", name = "ts-comments.nvim" },
  { src = "https://github.com/windwp/nvim-ts-autotag", name = "nvim-ts-autotag" },
  { src = "https://github.com/max397574/better-escape.nvim", name = "better-escape.nvim" },
  { src = "https://github.com/gen740/SmoothCursor.nvim", name = "SmoothCursor.nvim" },
  { src = "https://github.com/mcauley-penney/visual-whitespace.nvim" },
  { src = "https://github.com/lukas-reineke/virt-column.nvim", name = "virt-column.nvim" },
  { src = "https://github.com/NStefan002/screenkey.nvim", name = "screenkey.nvim" },
  { src = "https://github.com/arnamak/stay-centered.nvim", name = "stay-centered.nvim" },
  { src = "https://github.com/sphamba/smear-cursor.nvim", name = "smear-cursor.nvim" },
})

-- 定义懒加载组，防止重复触发
local lazy_group = vim.api.nvim_create_augroup("ConfigLazyLoad", { clear = true })

-- 2. 核心功能 (Session) - 稍微延迟加载以不阻塞 UI
vim.defer_fn(function()
  local persistence = require("persistence")
  persistence.setup({
    dir = vim.fn.stdpath("state") .. "/sessions/",
    need = 0,
    branch = true,
  })
  -- 快捷键定义 (这些本身就是懒加载，因为只有按下才会执行 function)
  vim.keymap.set("n", "<leader>qs", function()
    persistence.load()
  end, { desc = "Restore Session" })
  vim.keymap.set("n", "<leader>ql", function()
    persistence.load({ last = true })
  end, { desc = "Restore Last Session" })
  vim.keymap.set("n", "<leader>qd", function()
    persistence.stop()
  end, { desc = "Don't Save Current Session" })
end, 100) -- 延迟 100ms

-- 3. 编辑模式懒加载 (InsertEnter)
vim.api.nvim_create_autocmd("InsertEnter", {
  group = lazy_group,
  once = true, -- 确保只运行一次
  callback = function()
    -- [快速退出] better-escape.nvim
    require("better_escape").setup({
      timeout = 300,
      default_mappings = false,
      mappings = {
        i = { j = { k = "<Esc>", j = "<Esc>" } },
      },
    })
  end,
})

require("nvim-ts-autotag").setup({})

-- 4. 文件打开懒加载 (BufReadPost, BufNewFile)
-- 只有打开真实文件时才加载视觉特效
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = lazy_group,
  once = true,
  callback = function()
    -- [TS 注释]
    require("ts-comments").setup({})

    -- [可视空格]
    require("visual-whitespace").setup({})

    -- [虚拟对齐线]
    require("virt-column").setup({ char = "", virtcolumn = "80" })

    -- [居中显示]
    -- require("stay-centered").setup({ skip_filetypes = {} })

    -- [平滑光标] SmoothCursor
    require("smoothcursor").setup({
      type = "default",
      autostart = true,
      fancy = {
        enable = true,
        head = { cursor = ">", texthl = "SmoothCursor", linehl = nil },
        body = {
          { cursor = "󰝥", texthl = "SmoothCursorRed" },
          { cursor = "󰝥", texthl = "SmoothCursorOrange" },
          { cursor = "●", texthl = "SmoothCursorYellow" },
          { cursor = "●", texthl = "SmoothCursorGreen" },
          { cursor = "•", texthl = "SmoothCursorAqua" },
          { cursor = ".", texthl = "SmoothCursorBlue" },
          { cursor = ".", texthl = "SmoothCursorPurple" },
        },
        tail = { cursor = nil, texthl = "SmoothCursor" },
      },
      disabled_filetypes = {
        "render-markdown",
        "CodeCompanion",
        "oil",
        "snacks_picker_input",
        "fzf",
      },
    })

    -- [拖尾光标] smear-cursor
    require("smear_cursor").setup({
      -- [1. Fast Response / 快速响应]
      -- High stiffness makes the cursor snappy, not "floaty"
      stiffness = 0.8, -- Default 0.6. Increased for speed.
      trailing_stiffness = 0.6, -- Default 0.3. Tail follows closely.
      distance_stop_animating = 0.5, -- Stop calculating sooner to save CPU.
      time_interval = 10, -- Refresh every 10ms (High framerate).

      -- [2. Colors / 颜色]
      -- A vibrant Purple (#a020f0). On transparent backgrounds,
      -- as this fades out, it often creates a cool blue/violet gradient effect.
      cursor_color = "#a020f0",

      -- [3. Particles / 粒子效果]
      particles_enabled = true,

      -- "Not blocking words" tuning:
      -- We reduce the count and lifetime so particles vanish before obscuring text.
      particles_per_second = 200, -- Keep count moderate (Default is often higher).
      particle_max_lifetime = 400, -- Die quickly (400ms) so text underneath is revealed.
      particle_gravity = -20, -- Float gently upwards.
      particle_velocity_from_cursor = 0.3, -- Don't explode too far out.

      -- [4. Transparency / 透明背景]
      -- This is CRITICAL for transparent backgrounds to avoid black boxes.
      -- Note: Requires a font like "Cascadia Code" or "Symbols Nerd Font".
      legacy_computing_symbols_support = true,

      -- [5. General / 通用]
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
      hide_target_hack = false, -- Keep the real cursor visible for precision.
    })
  end,
})

-- 5. 命令懒加载 (On Demand)
-- Screenkey 只有在真正需要演示时才加载
-- 创建一个用户命令，输入 :ScreenkeyToggle 时才加载插件并启动
vim.api.nvim_create_user_command("ScreenkeyToggle", function()
  -- 检查插件是否已加载，未加载则配置
  if not package.loaded["screenkey"] then
    require("screenkey").setup({
      win_opts = {
        row = vim.o.lines - vim.o.cmdheight - 1,
        col = vim.o.columns - 1,
        relative = "editor",
        anchor = "SE",
        width = 20,
        height = 2,
        border = "single",
        title = "Screenkey",
        title_pos = "center",
        style = "minimal",
        focusable = false,
        noautocmd = true,
      },
      hl_groups = {
        ["screenkey.hl.key"] = { link = "Type" },
        ["screenkey.hl.map"] = { link = "Keyword" },
        ["screenkey.hl.sep"] = { link = "Normal" },
      },
    })
  end
  -- 切换开关
  require("screenkey").toggle()
end, {})

vim.keymap.set("n", "<leader>uk", ":ScreenkeyToggle<CR>", { desc = "Screenkey Toggle" })
