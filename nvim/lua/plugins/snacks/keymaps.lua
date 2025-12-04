return {
  -- ==========================================
  -- 📁 文件导航 (File Navigation)
  -- ==========================================
  ["Explorer"] = {
    mode = "n",
    lhs = "<leader>se",
    rhs = function()
      -- 动态加载布局配置，防止启动循环依赖
      local ui = require("plugins.snacks.layouts")
      Snacks.explorer({ layout = ui.right })
    end,
    desc = "文件资源管理器 (Explorer)",
  },
  ["Smart-Find"] = {
    mode = "n",
    lhs = "<leader>ss",
    rhs = function()
      local ui = require("plugins.snacks.layouts")
      Snacks.picker.smart({
        hidden = true, -- 包含隐藏文件
        filter = { cwd = true }, -- 限制在当前目录
        preview = function()
          return false
        end, -- 关闭预览以提高速度
        layout = ui.dropdown_pick,
      })
    end,
    desc = "智能文件查找 (Smart Find)",
  },
  ["Buffers"] = {
    mode = "n",
    lhs = "bb",
    rhs = function()
      local ui = require("plugins.snacks.layouts")
      Snacks.picker.buffers({
        sort_lastused = true, -- 按最近使用排序
        current = false, -- 不显示当前 buffer
        layout = ui.dropdown_pick,
      })
    end,
    desc = "切换缓冲区 (Buffers)",
  },
  ["Recent-Files"] = {
    mode = "n",
    lhs = "<leader>fr",
    rhs = function()
      Snacks.picker.recent()
    end,
    desc = "最近打开的文件 (Recent)",
  },
  ["Resume-Picker"] = {
    mode = "n",
    lhs = "<leader>sr",
    rhs = function()
      Snacks.picker.resume()
    end,
    desc = "恢复上次搜索 (Resume)",
  },
  ["Config-Files"] = {
    mode = "n",
    lhs = "<leader>fc",
    rhs = function()
      Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
    end,
    desc = "查找 Neovim 配置文件",
  },
  ["Projects"] = {
    mode = "n",
    lhs = "<leader>fp",
    rhs = function()
      Snacks.picker.projects()
    end,
    desc = "查找项目 (Projects)",
  },
  ["Git-Files"] = {
    mode = "n",
    lhs = "<leader>ghf",
    rhs = function()
      Snacks.picker.git_files()
    end,
    desc = "查找 Git 文件",
  },

  -- ==========================================
  -- 🔍 搜索与 Grep (Search & Grep)
  -- ==========================================
  ["Grep-Word-Project"] = {
    mode = { "n", "x", "v" },
    lhs = "<leader>sw",
    rhs = function()
      Snacks.picker.grep_word({ filter = { cwd = true } })
    end,
    desc = "搜索光标下的词 (当前项目)",
  },
  ["Grep-Word-Buffer"] = {
    mode = { "n", "x", "v" },
    lhs = "<leader>sW",
    rhs = function()
      Snacks.picker.grep_word({
        filter = { cwd = true },
        buffers = true, -- 仅在打开的 Buffer 中搜索
        dirs = { vim.fn.expand("%:p") },
      })
    end,
    desc = "搜索光标下的词 (仅当前文件)",
  },
  ["Live-Grep-Project"] = {
    mode = "n",
    lhs = "<leader>sg",
    rhs = function()
      Snacks.picker.grep({ filter = { cwd = true } })
    end,
    desc = "全局正则搜索 (Live Grep - 项目)",
  },
  ["Live-Grep-Global"] = {
    mode = "n",
    lhs = "<leader>sG",
    rhs = function()
      Snacks.picker.grep()
    end,
    desc = "全局正则搜索 (Live Grep - 全局)",
  },
  ["Search-Lines"] = {
    mode = "n",
    lhs = "<leader>st",
    rhs = function()
      local ui = require("plugins.snacks.layouts")
      Snacks.picker.lines({ layout = ui.ivy_border })
    end,
    desc = "搜索当前文件行 (Lines)",
  },
  ["Command-History"] = {
    mode = "n",
    lhs = "<leader>sC",
    rhs = function()
      Snacks.picker.command_history()
    end,
    desc = "命令历史记录",
  },
  ["Diagnostics-Buffer"] = {
    mode = "n",
    lhs = "<leader>sD",
    rhs = function()
      Snacks.picker.diagnostics_buffer()
    end,
    desc = "当前文件诊断 (Diagnostics Buffer)",
  },
  ["Diagnostics-Project"] = {
    mode = "n",
    lhs = "<leader>sd",
    rhs = function()
      Snacks.picker.diagnostics()
    end,
    desc = "项目诊断 (Diagnostics Project)",
  },

  -- ==========================================
  -- 🧠 LSP 与 符号 (LSP & Symbols)
  -- ==========================================
  ["LSP-References"] = {
    mode = "n",
    lhs = "gtr",
    rhs = function()
      Snacks.picker.lsp_references()
    end,
    desc = "查找引用 (References)",
  },
  ["LSP-Definitions"] = {
    mode = "n",
    lhs = "gtd",
    rhs = function()
      Snacks.picker.lsp_definitions()
    end,
    desc = "查找定义 (Definitions)",
  },
  ["LSP-Implementations"] = {
    mode = "n",
    lhs = "gti",
    rhs = function()
      Snacks.picker.lsp_implementations()
    end,
    desc = "查找实现 (Implementations)",
  },
  ["LSP-Type-Definitions"] = {
    mode = "n",
    lhs = "gtt",
    rhs = function()
      Snacks.picker.lsp_type_definitions()
    end,
    desc = "查找类型定义 (Type Definitions)",
  },
  ["Workspace-Symbols"] = {
    mode = "n",
    lhs = "<leader>fS",
    rhs = function()
      Snacks.picker.lsp_workspace_symbols()
    end,
    desc = "查找工作区符号 (Workspace Symbols)",
  },
  ["Buffer-Symbols"] = {
    mode = "n",
    lhs = "<leader>fs",
    rhs = function()
      -- 智能逻辑：检查是否有 LSP 支持 Document Symbols
      -- 如果有则用 LSP，否则回退用 Treesitter
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      local has_lsp = false
      for _, client in ipairs(clients) do
        if client.server_capabilities.documentSymbolProvider then
          has_lsp = true
          break
        end
      end

      if has_lsp then
        Snacks.picker.lsp_symbols({ layout = "dropdown", tree = true })
      else
        Snacks.picker.treesitter()
      end
    end,
    desc = "查找当前文件符号 (Symbols)",
  },

  -- ==========================================
  -- 🛠️ 编辑器工具 (Editor Utils)
  -- ==========================================
  ["Commands"] = {
    mode = "n",
    lhs = "<leader>sc",
    rhs = function()
      Snacks.picker.commands()
    end,
    desc = "命令面板 (Commands)",
  },
  ["Keymaps"] = {
    mode = "n",
    lhs = "<leader>fk",
    rhs = function()
      Snacks.picker.keymaps({ layout = "dropdown" })
    end,
    desc = "查找快捷键 (Keymaps)",
  },
  ["Marks"] = {
    mode = "n",
    lhs = "<leader>sx",
    rhs = function()
      Snacks.picker.marks()
    end,
    desc = "查找标记 (Marks)",
  },
  ["Help-Tags"] = {
    mode = "n",
    lhs = "<leader>fh",
    rhs = function()
      Snacks.picker.help({ layout = "dropdown" })
    end,
    desc = "查找帮助文档 (Help)",
  },
  ["Highlights"] = {
    mode = "n",
    lhs = "<leader>fH",
    rhs = function()
      Snacks.picker.highlights()
    end,
    desc = "查找高亮组 (Highlights)",
  },
  ["Icons"] = {
    mode = "n",
    lhs = "<leader>fi",
    rhs = function()
      Snacks.picker.icons()
    end,
    desc = "查找图标 (Icons)",
  },
  ["Layouts"] = {
    mode = "n",
    lhs = "<leader>fL",
    rhs = function()
      Snacks.picker.picker_layouts()
    end,
    desc = "切换 Picker 布局",
  },
  ["Search-History"] = {
    mode = "n",
    lhs = "<leader>f/",
    rhs = function()
      Snacks.picker.search_history()
    end,
    desc = "搜索历史记录",
  },
  ["Jumplist"] = {
    mode = "n",
    lhs = "<leader>fj",
    rhs = function()
      Snacks.picker.jumps()
    end,
    desc = "跳转列表 (Jumplist)",
  },
  ["Registers"] = {
    mode = "n",
    lhs = '<leader>f"',
    rhs = function()
      Snacks.picker.registers()
    end,
    desc = "查看寄存器 (Registers)",
  },
  ["Colorschemes"] = {
    mode = "n",
    lhs = "<leader>uC",
    rhs = function()
      Snacks.picker.colorschemes()
    end,
    desc = "切换配色方案 (Colorschemes)",
  },

  -- ==========================================
  -- 📋 待办事项与任务 (Todo & Tasks)
  -- ==========================================
  ["Smart-Todo"] = {
    mode = "n",
    lhs = "<leader>sn",
    rhs = function()
      -- 智能逻辑：如果是 Markdown 文件，搜索 '- [ ]' 复选框
      -- 否则搜索代码中的 TODO/FIXME 标签
      if vim.bo.filetype == "markdown" then
        Snacks.picker.grep_buffers({
          finder = "grep",
          format = "file",
          prompt = "Task  ",
          search = "^\\s*- \\[ \\]", -- 正则匹配未完成的任务
          regex = true,
          live = false,
          args = { "--no-ignore" },
          on_show = function()
            vim.cmd.stopinsert()
          end,
          buffers = false,
          supports_live = false,
          layout = "ivy",
        })
      else
        Snacks.picker.grep({
          prompt = "Todo  ",
          search = "\\b(TODO|FIX|FIXME|NOTE|PERF|HACK|WARNING|XXX):",
          regex = true,
          live = false,
          hidden = false,
          layout = "select",
        })
      end
    end,
    desc = "查找待办事项 (Todo/Tasks)",
  },

  -- ==========================================
  -- 🔔 通知与列表 (Notifications & Lists)
  -- ==========================================
  ["Dismiss-Notify"] = {
    mode = "n",
    lhs = "<leader>xn",
    rhs = function()
      Snacks.notifier.hide()
    end,
    desc = "关闭所有通知",
  },
  ["History-Notify"] = {
    mode = "n",
    lhs = "<leader>sh",
    rhs = function()
      Snacks.picker.notifications()
    end,
    desc = "通知历史记录",
  },
  ["Quickfix"] = {
    mode = "n",
    lhs = "<leader>sf",
    rhs = function()
      Snacks.picker.qflist()
    end,
    desc = "Quickfix 列表",
  },
  ["Loclist"] = {
    mode = "n",
    lhs = "<leader>sl",
    rhs = function()
      Snacks.picker.loclist()
    end,
    desc = "位置列表 (Location List)",
  },

  -- ==========================================
  -- 🐙 Git 集成
  -- ==========================================
  ["LazyGit"] = {
    mode = "n",
    lhs = "<leader>ghg",
    rhs = function()
      Snacks.lazygit({ cwd = Snacks.git.get_root() })
    end,
    desc = "打开 LazyGit",
  },
  ["Git-Blame"] = {
    mode = "n",
    lhs = "<leader>ghb",
    rhs = function()
      Snacks.git.blame_line()
    end,
    desc = "Git Blame (当前行)",
  },
  ["Git-Status"] = {
    mode = "n",
    lhs = "<leader>ghs",
    rhs = function()
      Snacks.picker.git_status()
    end,
    desc = "Git 状态 (Status)",
  },
  ["Git-Log"] = {
    mode = "n",
    lhs = "<leader>ghl",
    rhs = function()
      Snacks.picker.git_log()
    end,
    desc = "Git 日志 (Log)",
  },
  ["Git-Log-File"] = {
    mode = "n",
    lhs = "<leader>ghL",
    rhs = function()
      Snacks.picker.git_log_file()
    end,
    desc = "Git 日志 (当前文件)",
  },
  ["Git-Diff"] = {
    mode = "n",
    lhs = "<leader>ghd",
    rhs = function()
      Snacks.picker.git_diff()
    end,
    desc = "Git 差异 (Diff)",
  },
  ["Git-Browse"] = {
    mode = "n",
    lhs = "<leader>ghB",
    rhs = function()
      Snacks.gitbrowse()
    end,
    desc = "在浏览器打开 Git (Git Browse)",
  },

  -- ==========================================
  -- 🔧 杂项工具 (Misc Utils)
  -- ==========================================
  ["Buf-Delete"] = {
    mode = "n",
    lhs = "<leader>bc",
    rhs = function()
      Snacks.bufdelete.delete()
    end,
    desc = "删除当前 Buffer",
  },
  ["Buf-Delete-Other"] = {
    mode = "n",
    lhs = "<leader>bC",
    rhs = function()
      Snacks.bufdelete.other()
    end,
    desc = "删除其他 Buffer",
  },
  ["Zen-Mode"] = {
    mode = "n",
    lhs = "<leader>z",
    rhs = function()
      Snacks.zen()
    end,
    desc = "切换禅模式 (Zen Mode)",
  },
  ["Image-Hover"] = {
    mode = "n",
    lhs = "<leader>K",
    rhs = function()
      Snacks.image.hover()
    end,
    desc = "悬停显示图片",
  },
  ["Rename"] = {
    mode = "n",
    lhs = "<leader>cR",
    rhs = function()
      Snacks.rename.rename_file()
    end,
    desc = "重命名文件 (Rename File)",
  },

  -- ==========================================
  -- 🔘 界面开关 (Toggles - u for UI)
  -- ==========================================
  ["Toggle-Spell"] = {
    mode = "n",
    lhs = "<leader>us",
    rhs = function()
      Snacks.toggle.option("spell", { name = "Spelling" }):toggle()
    end,
    desc = "开关拼写检查",
  },
  ["Toggle-Wrap"] = {
    mode = "n",
    lhs = "<leader>uw",
    rhs = function()
      Snacks.toggle.option("wrap", { name = "Wrap" }):toggle()
    end,
    desc = "开关自动换行",
  },
  ["Toggle-RelNum"] = {
    mode = "n",
    lhs = "<leader>uL",
    rhs = function()
      Snacks.toggle.option("relativenumber", { name = "Relative Number" }):toggle()
    end,
    desc = "开关相对行号",
  },
  ["Toggle-LineNum"] = {
    mode = "n",
    lhs = "<leader>ul",
    rhs = function()
      Snacks.toggle.line_number():toggle()
    end,
    desc = "开关行号",
  },
  ["Toggle-Diagnostics"] = {
    mode = "n",
    lhs = "<leader>ud",
    rhs = function()
      Snacks.toggle.diagnostics():toggle()
    end,
    desc = "开关诊断信息",
  },
  ["Toggle-Treesitter"] = {
    mode = "n",
    lhs = "<leader>uT",
    rhs = function()
      Snacks.toggle.treesitter():toggle()
    end,
    desc = "开关 Treesitter",
  },
  ["Toggle-InlayHints"] = {
    mode = "n",
    lhs = "<leader>uh",
    rhs = function()
      Snacks.toggle.inlay_hints():toggle()
    end,
    desc = "开关内联提示 (Inlay Hints)",
  },
  ["Toggle-Indent"] = {
    mode = "n",
    lhs = "<leader>ug",
    rhs = function()
      Snacks.toggle.indent():toggle()
    end,
    desc = "开关缩进参考线",
  },
  ["Toggle-Dim"] = {
    mode = "n",
    lhs = "<leader>uD",
    rhs = function()
      Snacks.toggle.dim():toggle()
    end,
    desc = "开关背景变暗 (Dim)",
  },
  ["Toggle-DarkBg"] = {
    mode = "n",
    lhs = "<leader>ub",
    rhs = function()
      Snacks.toggle
        .option("background", { off = "light", on = "dark", name = "Dark Background" })
        :toggle()
    end,
    desc = "切换深色背景",
  },
  ["Toggle-Conceal"] = {
    mode = "n",
    lhs = "<leader>uc",
    rhs = function()
      Snacks.toggle
        .option("conceallevel", {
          off = 0,
          on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
        })
        :toggle()
    end,
    desc = "开关隐藏字符 (Conceal)",
  },
}
