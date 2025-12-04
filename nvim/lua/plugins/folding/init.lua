vim.pack.add({
  { src = "https://github.com/kevinhwang91/promise-async" },
  { src = "https://github.com/kevinhwang91/nvim-ufo" },
  { src = "https://github.com/luukvbaal/statuscol.nvim" },
})

-- ============================================================================
-- 状态栏配置
-- ============================================================================
local builtin = require("statuscol.builtin")
require("statuscol").setup({
  relculright = true,
  segments = {
    -- 诊断符号
    {
      sign = { namespace = { "diagnostic.*" }, maxwidth = 1, auto = true },
      click = "v:lua.ScSa",
    },
    -- 其他符号
    {
      sign = { name = { ".*" }, maxwidth = 1, colwidth = 1, auto = true },
      click = "v:lua.ScSa",
    },
    -- 行号
    { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
    -- 折叠指示器
    { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
  },
})

-- ============================================================================
-- 折叠基础设置
-- ============================================================================
vim.o.foldcolumn = "1" -- 折叠列宽度
vim.o.foldlevel = 99 -- 默认折叠级别
vim.o.foldlevelstart = 99 -- 打开文件时的折叠级别
vim.o.foldenable = true -- 启用折叠

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- 折叠图标
local icons = require("config.ui").icons.fold
vim.opt.fillchars = {
  foldopen = icons.arrow.open,
  foldclose = icons.arrow.close,
  fold = " ",
  foldsep = " ",
  diff = "/",
  eob = " ",
}

-- 折叠高亮配色
vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#6c7086", bg = "NONE" })
vim.api.nvim_set_hl(0, "Folded", { fg = "#a6adc8", bg = "#313244" })
vim.api.nvim_set_hl(0, "UfoCursorFoldedLine", { fg = "#f9e2af", bg = "#45475a", bold = true })

-- ============================================================================
-- UFO 插件配置
-- ============================================================================

-- local handler = function(virtText, lnum, endLnum, width, truncate)
--   local newVirtText = {}
--   local suffix = (" 󰁂 %d "):format(endLnum - lnum)
--   local sufWidth = vim.fn.strdisplaywidth(suffix)
--   local targetWidth = width - sufWidth
--   local curWidth = 0
--   for _, chunk in ipairs(virtText) do
--     local chunkText = chunk[1]
--     local chunkWidth = vim.fn.strdisplaywidth(chunkText)
--     if targetWidth > curWidth + chunkWidth then
--       table.insert(newVirtText, chunk)
--     else
--       chunkText = truncate(chunkText, targetWidth - curWidth)
--       local hlGroup = chunk[2]
--       table.insert(newVirtText, { chunkText, hlGroup })
--       chunkWidth = vim.fn.strdisplaywidth(chunkText)
--       -- str width returned from truncate() may less than 2nd argument, need padding
--       if curWidth + chunkWidth < targetWidth then
--         suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
--       end
--       break
--     end
--     curWidth = curWidth + chunkWidth
--   end
--   table.insert(newVirtText, { suffix, "MoreMsg" })
--   return newVirtText
-- end

local ufo = require("ufo")
ufo.setup({
  -- 折叠提供者选择(优先使用 treesitter,其次使用缩进)
  provider_selector = function(bufnr, filetype, buftype)
    -- return nil -- if want to use lso for provider and fallback indent
    return { "treesitter", "indent" }
  end,

  -- 折叠高亮持续时间
  open_fold_hl_timeout = 150,

  -- 按文件类型自动关闭特定折叠类型
  close_fold_kinds_for_ft = {
    default = { "imports" },
    json = { "array" },
    c = { "region" },
  },

  -- 按文件类型关闭当前行折叠
  close_fold_current_line_for_ft = {
    default = true,
    c = false,
  },

  -- 折叠预览窗口配置
  preview = {
    win_config = {
      border = "rounded",
      winhighlight = "Normal:Folded",
      winblend = 12,
    },
    mappings = {
      scrollU = "<C-u>",
      scrollD = "<C-d>",
      jumpTop = "[",
      jumpBot = "]",
    },
  },

  -- 使用自定义虚拟文本处理函数
  -- fold_virt_text_handler = handler,
  fold_virt_text_handler = require("plugins.folding.utils").handler,
})

-- ============================================================================
-- 快捷键映射
-- ============================================================================
local ufo_keymaps = {
  ["Open-all-folds"] = { "n", "zR", ufo.openAllFolds },
  ["Close-all-folds"] = { "n", "zM", ufo.closeAllFolds },
  ["Open-folds-except-kinds"] = { "n", "zr", ufo.openFoldsExceptKinds },
  ["Close-folds-with"] = { "n", "zm", ufo.closeFoldsWith },
  ["Peek-folded-lines"] = {
    "n",
    "zK",
    function()
      local winid = ufo.peekFoldedLinesUnderCursor()
      if not winid then
        vim.lsp.buf.hover()
      end
    end,
  },
}
local map = require("config.keymaps").map
map(ufo_keymaps, { silent = true })
