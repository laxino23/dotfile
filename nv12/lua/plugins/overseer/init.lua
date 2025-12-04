vim.pack.add({
  { src = "https://github.com/stevearc/overseer.nvim" },
})

require("plugins.overseer.config")

-- 设置文件类型快捷键
local function setup_rust_keymaps()
  local opts = { buffer = true, noremap = true, silent = true }
  vim.keymap.set(
    "n",
    "<localleader>r",
    "<cmd>OverseerRun rust: cargo run<cr>",
    vim.tbl_extend("force", opts, { desc = "Cargo run" })
  )
  vim.keymap.set(
    "n",
    "<localleader>t",
    "<cmd>OverseerRun rust: cargo test<cr>",
    vim.tbl_extend("force", opts, { desc = "Cargo test" })
  )
  vim.keymap.set(
    "n",
    "<localleader>b",
    "<cmd>!cargo build<cr>",
    vim.tbl_extend("force", opts, { desc = "Cargo build" })
  )
  vim.keymap.set(
    "n",
    "<localleader>c",
    "<cmd>!cargo check<cr>",
    vim.tbl_extend("force", opts, { desc = "Cargo check" })
  )
  vim.keymap.set(
    "n",
    "<localleader>l",
    "<cmd>!cargo clippy<cr>",
    vim.tbl_extend("force", opts, { desc = "Cargo clippy" })
  )
end

local function setup_python_keymaps()
  local opts = { buffer = true, noremap = true, silent = true }
  vim.keymap.set(
    "n",
    "<localleader>r",
    "<cmd>OverseerRun python: run file<cr>",
    vim.tbl_extend("force", opts, { desc = "Run Python file" })
  )
  vim.keymap.set(
    "n",
    "<localleader>t",
    "<cmd>!python3 -m pytest %<cr>",
    vim.tbl_extend("force", opts, { desc = "Run pytest" })
  )
  vim.keymap.set(
    "n",
    "<localleader>d",
    "<cmd>!python3 -m pdb %<cr>",
    vim.tbl_extend("force", opts, { desc = "Debug with pdb" })
  )
end

local function setup_cpp_keymaps()
  local opts = { buffer = true, noremap = true, silent = true }
  vim.keymap.set(
    "n",
    "<localleader>r",
    "<cmd>OverseerRun cpp: compile and run<cr>",
    vim.tbl_extend("force", opts, { desc = "Compile and run" })
  )
  vim.keymap.set("n", "<localleader>b", function()
    local file = vim.fn.expand("%:t:r")
    vim.cmd("!g++ -std=c++17 -Wall % -o " .. file)
  end, vim.tbl_extend("force", opts, { desc = "Compile only" }))
end

local function setup_go_keymaps()
  local opts = { buffer = true, noremap = true, silent = true }
  vim.keymap.set(
    "n",
    "<localleader>r",
    "<cmd>OverseerRun go: run<cr>",
    vim.tbl_extend("force", opts, { desc = "Go run" })
  )
  vim.keymap.set(
    "n",
    "<localleader>t",
    "<cmd>!go test<cr>",
    vim.tbl_extend("force", opts, { desc = "Go test" })
  )
  vim.keymap.set(
    "n",
    "<localleader>b",
    "<cmd>!go build<cr>",
    vim.tbl_extend("force", opts, { desc = "Go build" })
  )
end

local function setup_javascript_keymaps()
  local opts = { buffer = true, noremap = true, silent = true }
  vim.keymap.set(
    "n",
    "<localleader>r",
    "<cmd>OverseerRun node: run file<cr>",
    vim.tbl_extend("force", opts, { desc = "Run with Node" })
  )
  vim.keymap.set(
    "n",
    "<localleader>t",
    "<cmd>!npm test<cr>",
    vim.tbl_extend("force", opts, { desc = "Run npm test" })
  )
  vim.keymap.set(
    "n",
    "<localleader>d",
    "<cmd>!npm run dev<cr>",
    vim.tbl_extend("force", opts, { desc = "Run dev server" })
  )
end

-- 创建 autocmd
local augroup = vim.api.nvim_create_augroup("OverseerFiletypeKeymaps", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "rust",
  callback = setup_rust_keymaps,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "python",
  callback = setup_python_keymaps,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "cpp", "c" },
  callback = setup_cpp_keymaps,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "go",
  callback = setup_go_keymaps,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = setup_javascript_keymaps,
})
