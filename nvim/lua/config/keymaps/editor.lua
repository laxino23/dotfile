return function(map)
  local M = {}

  -- =============================================================================
  -- Logic: Editor Actions / 逻辑：编辑操作
  -- =============================================================================

  M.undo = function()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "n" or mode == "i" or mode == "v" then
      vim.cmd("undo")
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    end
  end

  M.redo = function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    vim.cmd("redo")
  end

  M.join_lines = function()
    local v_count = vim.v.count1 + 1
    local mode = vim.api.nvim_get_mode().mode
    local keys = (mode == "n") and (v_count .. "J") or "J"
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
  end

  M.insert_lines = function(direction)
    local row = vim.api.nvim_win_get_cursor(0)[1]

    -- Check if current line is folded
    local fold_start = vim.fn.foldclosed(row)
    local fold_end = vim.fn.foldclosedend(row)
    local is_folded = fold_end ~= -1

    -- If folded, move to the edge of the fold first
    if is_folded then
      if direction == "up" then
        vim.api.nvim_win_set_cursor(0, { fold_start, 0 })
      else -- down
        vim.api.nvim_win_set_cursor(0, { fold_end, 0 })
      end
    end

    -- Use native o/O commands to insert lines (respects folds naturally)
    if direction == "up" then
      -- Insert 3 lines above using O
      vim.cmd("normal! O")
      vim.cmd("normal! O")
      vim.cmd("normal! O")
      -- Move to middle line
      vim.cmd("normal! j")
    else -- down
      -- Insert 3 lines below using o
      vim.cmd("normal! o")
      vim.cmd("normal! o")
      vim.cmd("normal! o")
      -- Move to middle line
      vim.cmd("normal! k")
    end

    -- Already in insert mode from o/O, just need to position cursor at start
    vim.cmd("startinsert")
  end

  -- =============================================================================
  -- Keymaps / 按键映射
  -- =============================================================================

  vim.keymap.set("n", "u", "<Nop>", { noremap = true, silent = true })

  map({
    ["undo"] = { { "n", "i", "v", "t", "c" }, "<C-z>", M.undo },
    ["redo"] = { { "n", "i", "v", "t", "c" }, "<C-r>", M.redo },
    ["paste-without-yank"] = { "x", "p", '"_dP' },
    ["delete-without-yank"] = { { "n", "v" }, "d", '"_d' },
    ["cut"] = { { "n", "v" }, "D", "d" },
    ["indent-left"] = { "v", "<", "<gv" },
    ["indent-right"] = { "v", ">", ">gv" },
    ["insert-above-three-lines"] = {
      "n",
      "<leader>op",
      function()
        M.insert_lines("up")
      end,
    },
    ["insert-below-three-lines"] = {
      "n",
      "<leader>oo",
      function()
        M.insert_lines("down")
      end,
    },
    ["join-lines"] = { { "n", "v" }, "J", M.join_lines },
    ["new-empty-line-below"] = { "n", "<M-o>", "o<Esc>" },
    ["new-empty-line-above"] = { "n", "<M-O>", "O<Esc>" },
  }, { silent = true })

map({
  ["save"] = { "n", "<leader>ww", ":w<CR>" },
  ["save-and-quit"] = { "n", "<leader>wq", ":wq<CR>" },
  ["just-quit"] = { "n", "<leader>we", ":q<CR>" },
  ["update-and-source"] = { "n", "<leader>o", ":update<CR> :source<CR>" },
}, { silent = true })

end
