vim.opt.runtimepath:append(vim.fn.stdpath("config") .. "/lua")

-- Make sure to load the plugin if it is in 'opt' (pack/core/opt)
-- 如果插件位于 'opt' 目录，请确保先加载它
vim.cmd("packadd overseer.nvim")

local overseer = require("overseer")

overseer.setup({
  -- CRITICAL FIX: Disable auto DAP setup to prevent the "listeners nil" error
  -- 关键修复：禁用自动 DAP 设置，以防止 "listeners nil" 错误导致崩溃
  dap = false,

  -- 任务模板来源
  templates = { "builtin", "user" },

  -- 策略配置
  strategy = {
    "toggleterm",
    -- Note: Ensure these options are valid for your version of toggleterm/overseer
    -- 注意：确保这些选项对于您的 toggleterm/overseer 版本是有效的
    direction = "horizontal",
    highlights = nil,
    auto_scroll = true,
    close_on_exit = false,
    quit_on_exit = "never",
    open_on_start = true,
    hidden = false,
  },

  -- 组件别名
  component_aliases = {
    default = {
      { "display_duration", detail_level = 2 },
      "on_output_summarize",
      "on_exit_set_status",
      { "on_complete_notify", statuses = { "FAILURE" } },
      "on_complete_dispose",
    },
  },

  -- 任务列表配置
  task_list = {
    direction = "bottom",
    min_height = 10,
    max_height = 25,
    default_detail = 1,
    bindings = {
      ["?"] = "ShowHelp",
      ["<CR>"] = "RunAction",
      ["<C-e>"] = "Edit",
      ["o"] = "Open",
      ["<C-v>"] = "OpenVsplit",
      ["<C-s>"] = "OpenSplit",
      ["<C-f>"] = "OpenFloat",
      ["<C-q>"] = "OpenQuickFix",
      ["p"] = "TogglePreview",
      ["<C-l>"] = "IncreaseDetail",
      ["<C-h>"] = "DecreaseDetail",
      ["L"] = "IncreaseAllDetail",
      ["H"] = "DecreaseAllDetail",
      ["["] = "DecreaseWidth",
      ["]"] = "IncreaseWidth",
      ["{"] = "PrevTask",
      ["}"] = "NextTask",
      ["<C-k>"] = "ScrollOutputUp",
      ["<C-j>"] = "ScrollOutputDown",
      ["q"] = "Close",
    },
  },
})

-- Manually enable DAP after setup to bypass the initialization bug
-- 在 setup 之后手动启用 DAP，以绕过初始化 bug
local has_dap, _ = pcall(require, "dap")
if has_dap then
  -- Safely try to enable DAP integration
  -- 安全地尝试启用 DAP 集成
  pcall(overseer.enable_dap)
end

-- 全局快捷键设置
local opts = { noremap = true, silent = true }

vim.keymap.set(
  "n",
  "<leader>or",
  "<cmd>OverseerRun<cr>",
  vim.tbl_extend("force", opts, { desc = "Overseer: Run task" })
)
vim.keymap.set(
  "n",
  "<leader>ot",
  "<cmd>OverseerToggle<cr>",
  vim.tbl_extend("force", opts, { desc = "Overseer: Toggle task list" })
)
vim.keymap.set(
  "n",
  "<leader>oi",
  "<cmd>OverseerInfo<cr>",
  vim.tbl_extend("force", opts, { desc = "Overseer: Task info" })
)
vim.keymap.set(
  "n",
  "<leader>ob",
  "<cmd>OverseerBuild<cr>",
  vim.tbl_extend("force", opts, { desc = "Overseer: Build task" })
)
vim.keymap.set(
  "n",
  "<leader>oq",
  "<cmd>OverseerQuickAction<cr>",
  vim.tbl_extend("force", opts, { desc = "Overseer: Quick action" })
)
vim.keymap.set(
  "n",
  "<leader>oa",
  "<cmd>OverseerTaskAction<cr>",
  vim.tbl_extend("force", opts, { desc = "Overseer: Task action" })
)

-- 重新运行最后一个任务
vim.keymap.set("n", "<leader>ol", function()
  -- Try to restart the most recent task
  -- 尝试重启最近的任务
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify("没有找到任务 (No tasks found)", vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], "restart")
  end
end, vim.tbl_extend("force", opts, { desc = "Overseer: Restart last task" }))

-- 清除已完成的任务
vim.keymap.set("n", "<leader>oc", function()
  local tasks = overseer.list_tasks()
  for _, task in ipairs(tasks) do
    if task.status == "SUCCESS" or task.status == "FAILURE" then
      task:dispose()
    end
  end
end, vim.tbl_extend("force", opts, { desc = "Overseer: Clear completed tasks" }))
