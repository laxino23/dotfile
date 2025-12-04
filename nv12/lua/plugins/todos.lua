vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/folke/todo-comments.nvim" },
  { src = "https://github.com/folke/trouble.nvim" },
})

-- =============================================================================
-- 1. Setup Trouble (The Viewer)
-- 1. 设置 Trouble (查看器)
-- =============================================================================
require("trouble").setup({
  -- Custom modes configuration
  -- 自定义模式配置
  modes = {
    -- Configure a dedicated 'todo' mode
    -- 配置专用的 'todo' 模式
    todo = {
      mode = "todo", -- Inherit from the built-in todo source / 继承内置的 todo 源
      auto_close = false, -- Auto close when jumping? / 跳转后自动关闭？

      -- Customize the layout for todos (optional)
      -- 自定义 todo 的布局（可选）
      preview = {
        type = "float",
        relative = "editor",
        border = "rounded",
        title = "Preview / 预览",
        title_pos = "center",
        position = { 0, -2 },
        size = { width = 0.3, height = 0.3 },
        zindex = 200,
      },

      -- Filter options: You can filter by severity or keywords here if you want
      -- 过滤选项：你可以在这里按严重程度或关键字过滤
      -- filter = { tag = { "TODO", "FIX", "FIXME" } },
    },
  },

  -- Icons configuration (Optional)
  -- 图标配置（可选）
  icons = {
    indent = {
      top = "│ ",
      middle = "├╴",
      last = "└╴",
      fold_open = " ",
      fold_closed = " ",
      ws = "  ",
    },
    folder_closed = " ",
    folder_open = " ",
    kinds = {
      Todo = " ",
    },
  },
})

-- =============================================================================
-- 2. Setup Todo-Comments (The Scanner)
-- 2. 设置 Todo-Comments (扫描器)
-- =============================================================================
require("todo-comments").setup({
  signs = true,
  -- Keywords configuration
  -- 关键字配置
  keywords = {
    FIX = {
      icon = " ",
      color = "error",
      alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
    },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "warning" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
  },
})

-- =============================================================================
-- 3. Integration Keymaps
-- 3. 集成按键映射
-- =============================================================================

local map = vim.keymap.set

-- Open Trouble with the "todo" mode we defined above
-- 使用我们上面定义的 "todo" 模式打开 Trouble
map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo (Trouble)" })

-- Filter specific keywords (e.g., only Fix/Bugs)
-- 过滤特定关键字（例如，仅查看 Fix/Bugs）
map(
  "n",
  "<leader>xT",
  "<cmd>Trouble todo toggle filter.tag=FIX<cr>",
  { desc = "Fix/Bugs (Trouble)" }
)

-- Jump to next/prev todo (handled by todo-comments directly)
-- 跳转到 下一个/上一个 todo（由 todo-comments 直接处理）
map("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next Todo" })
map("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Prev Todo" })
