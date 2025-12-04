local map = require("config.keymaps").map

local function open_buf_in_split(buf_id, key_map, direction)
  local MiniFiles = require("mini.files")
  local function rhs()
    local cur_target = MiniFiles.get_explorer_state().target_window
    if cur_target == nil or MiniFiles.get_fs_entry().fs_type == "directory" then
      return
    end
    local new_target = vim.api.nvim_win_call(cur_target, function()
      vim.cmd(direction .. " split")
      return vim.api.nvim_get_current_win()
    end)
    MiniFiles.set_target_window(new_target)
    MiniFiles.go_in({ close_on_file = true })
  end
  vim.keymap.set(
    "n",
    key_map,
    rhs,
    { buffer = buf_id, desc = "Split " .. string.sub(direction, 12) }
  )
end

vim.pack.add({
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/echasnovski/mini.icons" },
  { src = "https://github.com/echasnovski/mini.ai" },
  { src = "https://github.com/echasnovski/mini.surround" },
  { src = "https://github.com/echasnovski/mini.splitjoin" },
  { src = "https://github.com/echasnovski/mini.trailspace" },
  { src = "https://github.com/echasnovski/mini.files" },
  { src = "https://github.com/echasnovski/mini.clue" },
  { src = "https://github.com/folke/flash.nvim" },
  { src = "https://github.com/windwp/nvim-autopairs" },
})

require("mini.icons").setup({
  file = {
    [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
    ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
    [".go-version"] = { glyph = "", hl = "MiniIconsBlue" },
    [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
    [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
    [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
    [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
    ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
    ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
    ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
    ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
    ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
  },
  filetype = {
    dotenv = { glyph = "", hl = "MiniIconsYellow" },
    gotmpl = { glyph = "󰟓", hl = "MiniIconsGrey" },
    postcss = { glyph = "󰌜", hl = "MiniIconsOrange" },
  },
})
require("mini.icons").mock_nvim_web_devicons()

--------------------------------------------------------------------------------
-- [智能文本对象] Mini.ai
--
-- 使用指南 (核心逻辑: i=内部, a=包含边界):
-- 1. 函数 (Function):
--    - vif / va f: 选中函数体 / 选中整个函数
--    - daf: 删除整个函数
-- 2. 参数 (Argument):
--    - cia: 修改某个参数 (如 `func(foo, bar)` 中修改 foo)
--    - daa: 删除参数及其逗号
-- 3. 自定义对象 (本配置特有):
--    - s (Sub-word): 驼峰/下划线分词操作。
--      例如对 `myLongVariable`: 光标在 Long 上按 `cis` 可修改为 `myShortVariable`
--    - % (File): 整个文件。 `da%` 清空文件, `vi%` 全选。
--    - / (Prompt): 自定义符号。按 `va/` 后输入 `*` 可选中星号包裹的内容。
--------------------------------------------------------------------------------
local ai = require("mini.ai")
ai.setup({
  custom_textobjects = {
    ["?"] = false,
    ["/"] = ai.gen_spec.user_prompt(),
    ["%"] = function() -- 全文件对象
      local from = { line = 1, col = 1 }
      local to = {
        line = vim.fn.line("$"),
        col = math.max(vim.fn.getline("$"):len(), 1),
      }
      return { from = from, to = to }
    end,
    a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
    c = ai.gen_spec.treesitter({ a = "@comment.outer", i = "@comment.inner" }),
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    s = { -- 单词内分词 (驼峰/下划线)
      {
        "%u[%l%d]+%f[^%l%d]",
        "%f[^%s%p][%l%d]+%f[^%l%d]",
        "^[%l%d]+%f[^%l%d]",
        "%f[^%s%p][%a%d]+%f[^%a%d]",
        "^[%a%d]+%f[^%a%d]",
      },
      "^().*()$",
    },
  },
  mappings = {
    around = "a",
    inside = "i",
  },
  n_lines = 500,
})

--------------------------------------------------------------------------------
-- [包围符号] Mini.surround
--------------------------------------------------------------------------------
require("mini.surround").setup({
  mappings = {
    add = "gsa", -- 添加: gsa + 符号 (如 gsa")
    delete = "gsd", -- 删除: gsd + 符号 (如 gsd")
    replace = "gsr", -- 替换: gsr + 旧符号 + 新符号 (如 gsr" ' )
  },
})

--------------------------------------------------------------------------------
-- [代码拆分] Mini.splitjoin
--------------------------------------------------------------------------------
require("mini.splitjoin").setup({
  mappings = { toggle = "gS" }, -- gS 切换单行/多行代码块
})

--------------------------------------------------------------------------------
-- [尾部空格] Mini.trailspace
--------------------------------------------------------------------------------
require("mini.trailspace").setup({
  only_in_normal_buffers = true,
})
map({
  ["Trailspace"] = {
    "n",
    "<leader>ut",
    function()
      require("mini.trailspace").trim()
    end,
  },
})

--------------------------------------------------------------------------------
-- [快捷键提示] Mini.clue
--------------------------------------------------------------------------------
local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "i", keys = "<C-x>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "n", keys = '"' },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "z" },
  },
  clues = {
    { mode = "n", keys = "<leader>a", desc = "+ai" },
    { mode = "n", keys = "<leader>c", desc = "+codes" },
    { mode = "n", keys = "<leader>f", desc = "+find" },
    { mode = "n", keys = "<leader>s", desc = "+search/win split" },
    { mode = "n", keys = "<leader>x", desc = "+diagnostics" },
    { mode = "n", keys = "<leader>g", desc = "+git/go to" },
    { mode = "n", keys = "<leader>gh", desc = "+git" },
    { mode = "n", keys = "<leader>gt", desc = "+go to" },
    { mode = "n", keys = "<leader>u", desc = "+ui" },
    { mode = "n", keys = "<leader>b", desc = "+buffers" },
    { mode = "n", keys = "<leader>d", desc = "+debug" },
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
  window = {
    delay = 200,
    config = function()
      local width = math.min(50, math.floor(vim.o.columns * 0.6))
      return {
        width = width,
        border = "single",
      }
    end,
  },
})

--------------------------------------------------------------------------------
-- [文件管理器] Mini.files
--
-- 核心理念: 像编辑文本 buffer 一样编辑文件系统。
-- 基础操作:
--   - h/j/k/l: 移动光标 (l 进入目录/打开文件, h 返回上一级)
--   - cw: 重命名 (Change Word) -> 输入新名 -> 回车 -> 保存(:w)生效
--   - dd: 剪切/删除行 -> 移动到其他目录 -> p 粘贴 (移动文件)
--   - yy: 复制行 -> p 粘贴 (复制文件)
--   - o:  新建行 -> 输入文件名 (目录以 / 结尾)
--
-- 自定义快捷键 (Autocmd):
--   - g.: 切换显示隐藏文件 (dotfiles)
--   - Ctrl + h/j/k/l: 在对应方向分屏打开当前选中的文件
--   - Ctrl + t: 在新标签页打开文件
--------------------------------------------------------------------------------
require("mini.files").setup({
  mappings = {
    show_help = "?",
    go_in_plus = "<cr>",
    go_out_plus = "-",
  },
  content = {
    filter = function(entry)
      return entry.name ~= ".DS_Store"
    end,
  },
  options = { permanent_delete = false },
})

map({
  ["File explorer"] = {
    "n",
    "<leader>e",
    function()
      local bufname = vim.api.nvim_buf_get_name(0)
      local path = vim.fn.fnamemodify(bufname, ":p")
      if path and vim.uv.fs_stat(path) then
        require("mini.files").open(bufname, false)
      else
        require("mini.files").open()
      end
    end,
  },
})

-- MiniFiles 增强事件 (UI, 快捷键, LSP 重命名)
local minifiles_augroup = vim.api.nvim_create_augroup("MiniFilesUser", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = minifiles_augroup,
  pattern = "MiniFilesWindowOpen",
  callback = function(args)
    local win_id = args.data.win_id
    vim.wo[win_id].winblend = 0
    local config = vim.api.nvim_win_get_config(win_id)
    config.border = "single"
    vim.api.nvim_win_set_config(win_id, config)
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = minifiles_augroup,
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf_id = args.data.buf_id
    -- 快捷键: g. 切换隐藏文件
    vim.keymap.set("n", "g.", function()
      vim.g.show_dotfiles = not vim.g.show_dotfiles
      require("mini.files").refresh({
        content = {
          filter = function(entry)
            return vim.g.show_dotfiles or entry.name:sub(1, 1) ~= "."
          end,
        },
      })
    end, { buffer = buf_id, desc = "Toggle `.`-files" })

    -- 快捷键: 分屏打开
    open_buf_in_split(buf_id, "<C-h>", "topleft vertical")
    open_buf_in_split(buf_id, "<C-j>", "belowright horizontal")
    open_buf_in_split(buf_id, "<C-k>", "topleft horizontal")
    open_buf_in_split(buf_id, "<C-l>", "belowright vertical")
    open_buf_in_split(buf_id, "<C-t>", "tab")
  end,
})

-- 文件重命名时通知 LSP 更新引用
vim.api.nvim_create_autocmd("User", {
  group = minifiles_augroup,
  pattern = "MiniFilesActionRename",
  callback = function(args)
    local changes = {
      files = {
        {
          oldUri = vim.uri_from_fname(args.data.from),
          newUri = vim.uri_from_fname(args.data.to),
        },
      },
    }
    local will_rename_method = vim.lsp.protocol.Methods.workspace_willRenameFiles
    local did_rename_method = vim.lsp.protocol.Methods.workspace_didRenameFiles
    local clients = vim.lsp.get_clients()

    for _, client in ipairs(clients) do
      if client:supports_method(will_rename_method) then
        local res = client:request_sync(will_rename_method, changes, 1000, 0)
        if res and res.result then
          vim.lsp.util.apply_workspace_edit(res.result, client.offset_encoding)
        end
      end
    end

    for _, client in ipairs(clients) do
      if client:supports_method(did_rename_method) then
        client:notify(did_rename_method, changes)
      end
    end
  end,
})

-- Flash Settings
-- Flash trigger will auto when require it
map({
  ["Flash"] = {
    { "n", "x", "o" },
    "s",
    function()
      require("flash").jump()
    end,
  },
  ["Flash Treesitter"] = {
    { "n", "x", "o" },
    "S",
    function()
      require("flash").treesitter()
    end,
  },
  ["Remote Flash"] = {
    "o",
    "r",
    function()
      require("flash").remote()
    end,
  },
  ["Treesitter Search"] = {
    { "o", "x" },
    "R",
    function()
      require("flash").treesitter_search()
    end,
  },
  ["Toggle Flash Search"] = {
    "c",
    "<c-s>",
    function()
      require("flash").toggle()
    end,
  },
})

-- Autopairs Settings
local npairs = require("nvim-autopairs")
local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local ts_conds = require("nvim-autopairs.ts-conds")

npairs.setup({
  check_ts = true, -- Enable Treesitter integration (Essential for your Markdown rules)
  ts_config = {
    lua = { "string" }, -- Don't add pairs in lua string treesitter nodes
    javascript = { "template_string" },
  },
  -- Press <M-e> (Alt+e) to wrap the text after the cursor in brackets/quotes
  fast_wrap = {
    map = "<M-e>",
    chars = { "{", "[", "(", '"', "'" },
    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
    offset = 0,
    end_key = "$",
    keys = "qwertyuiopzxcvbnmasdfghjkl",
    check_comma = true,
    highlight = "Search",
    highlight_grey = "Comment",
  },
})

-- Custom Rules
local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }

-- Rule: Insert space between brackets -> ( | )
npairs.add_rules({
  Rule(" ", " ", "-markdown")
    :with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({
        brackets[1][1] .. brackets[1][2],
        brackets[2][1] .. brackets[2][2],
        brackets[3][1] .. brackets[3][2],
      }, pair)
    end)
    :with_move(cond.none())
    :with_cr(cond.none())
    :with_del(function(opts)
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local context = opts.line:sub(col - 1, col + 2)
      return vim.tbl_contains({
        brackets[1][1] .. "  " .. brackets[1][2],
        brackets[2][1] .. "  " .. brackets[2][2],
        brackets[3][1] .. "  " .. brackets[3][2],
      }, context)
    end),
})

-- Rule: Movement logic for brackets with spaces
for _, bracket in pairs(brackets) do
  npairs.add_rules({
    Rule(bracket[1] .. " ", " " .. bracket[2])
      :with_pair(function()
        return false
      end)
      :with_del(function()
        return false
      end)
      :with_move(function(opts)
        return opts.prev_char:match(".%" .. bracket[2]) ~= nil
      end)
      :use_key(bracket[2]),

    -- Rule: Ignore closing bracket if next char is '$'
    Rule(bracket[1], bracket[2]):with_pair(cond.after_text("$")),

    -- Rule: Backspace logic `()|` -> <BS> -> `|`
    Rule(bracket[1] .. bracket[2], ""):with_pair(function()
      return false
    end):with_cr(function()
      return false
    end),
  })
end

-- Rule: Markdown LaTeX Math ($...$)
-- Only works if text is NOT escaped with \ and IS a math node in Treesitter
npairs.add_rule(Rule("$", "$", "markdown")
  :with_move(function(opts)
    return opts.next_char == opts.char
      and ts_conds.is_ts_node({
        "inline_formula",
        "displayed_equation",
        "math_environment",
      })(opts)
  end)
  :with_pair(ts_conds.is_not_ts_node({
    "inline_formula",
    "displayed_equation",
    "math_environment",
  }))
  :with_pair(cond.not_before_text("\\")))

-- Rule: JSDoc / C-style comments (/** -> */)
npairs.add_rule(
  Rule("/**", "  */"):with_pair(cond.not_after_regex(".-%*/", -1)):set_end_pair_length(3)
)

-- Rule: Markdown Bold (**...**)
npairs.add_rule(Rule("**", "**", "markdown"):with_move(function(opts)
  return cond.after_text("*")(opts) and cond.not_before_text("\\")(opts)
end))

-- Auto-add space in Javascript arrow functions: () => { | }
npairs.add_rules({
  Rule("%(.*%)%s*%=>$", " {  }", { "typescript", "typescriptreact", "javascript" })
    :use_regex(true)
    :set_end_pair_length(2),
})
