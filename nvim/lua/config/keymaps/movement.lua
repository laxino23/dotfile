return function(map)
  local M = {}

  -- =============================================================================
  -- Logic: Line & Fold Movement / 逻辑：行与折叠移动
  -- =============================================================================

  -- Get visual selection range including folds
  -- 获取包含折叠的视觉选区范围
  local function get_visual_unit(line_num)
    local fold_start = vim.fn.foldclosed(line_num)
    if fold_start ~= -1 then
      return fold_start, vim.fn.foldclosedend(line_num)
    else
      return line_num, line_num
    end
  end

  M.move_normal_line_v = function(direction)
    local cur = vim.fn.line(".")
    local start_line, end_line
    local fold_start = vim.fn.foldclosed(cur)

    if fold_start ~= -1 then
      start_line = fold_start
      end_line = vim.fn.foldclosedend(cur)
    else
      start_line = cur
      end_line = cur
    end

    if direction == "down" then
      if end_line == vim.fn.line("$") then
        return
      end
      local next_line = end_line + 1
      local next_start = vim.fn.foldclosed(next_line)
      local next_end = (next_start ~= -1) and vim.fn.foldclosedend(next_line) or next_line
      vim.cmd(start_line .. "," .. end_line .. "m " .. next_end)
      vim.cmd(start_line .. "," .. end_line .. "=")
      local adjust = next_end - end_line
      vim.fn.cursor(cur + adjust, vim.fn.col("."))
    elseif direction == "up" then
      if start_line == 1 then
        return
      end
      local prev_line = start_line - 1
      local prev_start_fold = vim.fn.foldclosed(prev_line)
      local prev_start = (prev_start_fold ~= -1) and prev_start_fold or prev_line

      -- Calculate destination: prev_start - 1, ensuring it's >= 0
      local dest = math.max(0, prev_start - 1)
      vim.cmd(start_line .. "," .. end_line .. "m " .. dest)

      local new_start = prev_start
      local new_end = new_start + (end_line - start_line)
      vim.cmd(new_start .. "," .. new_end .. "=")

      local adjust = start_line - prev_start
      vim.fn.cursor(cur - adjust, vim.fn.col("."))
    end
  end

  M.move_visual_line_v = function(direction)
    vim.cmd("normal! \27") -- Exit visual mode to get marks
    local s_start = vim.fn.line("'<")
    local s_end = vim.fn.line("'>")
    local total_lines = vim.api.nvim_buf_line_count(0)
    local new_start, new_end

    if direction == "down" then
      local target_line_idx = s_end + 1
      if target_line_idx > total_lines then
        vim.cmd("normal! gv")
        return
      end
      local t_start, t_end = get_visual_unit(target_line_idx)
      local offset = t_end - t_start + 1

      vim.cmd(string.format("%d,%d move %d", s_start, s_end, t_end))
      new_start = s_start + offset
      new_end = s_end + offset
    elseif direction == "up" then
      local target_line_idx = s_start - 1
      if target_line_idx < 1 then
        vim.cmd("normal! gv")
        return
      end
      local t_start, t_end = get_visual_unit(target_line_idx)
      local offset = t_end - t_start + 1

      vim.cmd(string.format("%d,%d move %d", s_start, s_end, t_start - 1))
      new_start = s_start - offset
      new_end = s_end - offset
    end

    vim.api.nvim_win_set_cursor(0, { new_start, 0 })
    vim.cmd("normal! V")
    if new_end > new_start then
      vim.cmd("normal! " .. new_end .. "G")
    end
  end

  M.move_visual_word_h = function(direction)
    -- Exit visual mode to capture marks
    vim.cmd("normal! \27")

    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2]
    local start_col = start_pos[3]
    local end_col = end_pos[3]

    -- Only support single-line horizontal movement
    if start_line ~= end_pos[2] then
      vim.cmd("normal! gv")
      return
    end

    local line = vim.fn.getline(start_line)
    local line_len = #line

    if direction == "left" then
      -- Can't move if at start of line
      if start_col <= 1 then
        vim.cmd("normal! gv")
        return
      end

      -- Get selected text
      local selected_text = line:sub(start_col, end_col)
      -- Get char before selection
      local char_before = line:sub(start_col - 1, start_col - 1)
      -- Build new line
      local before = line:sub(1, start_col - 2)
      local after = line:sub(end_col + 1)
      local new_line = before .. selected_text .. char_before .. after

      vim.fn.setline(start_line, new_line)

      -- Reselect at new position
      local new_start_col = start_col - 1
      local new_end_col = end_col - 1

      vim.fn.setpos("'<", { 0, start_line, new_start_col, 0 })
      vim.fn.setpos("'>", { 0, start_line, new_end_col, 0 })
      vim.cmd("normal! gv")
    elseif direction == "right" then
      -- Can't move if at end of line
      if end_col >= line_len then
        vim.cmd("normal! gv")
        return
      end

      local selected_text = line:sub(start_col, end_col)
      local char_after = line:sub(end_col + 1, end_col + 1)
      local before = line:sub(1, start_col - 1)
      local after = line:sub(end_col + 2)
      local new_line = before .. char_after .. selected_text .. after

      vim.fn.setline(start_line, new_line)

      local new_start_col = start_col + 1
      local new_end_col = end_col + 1

      vim.fn.setpos("'<", { 0, start_line, new_start_col, 0 })
      vim.fn.setpos("'>", { 0, start_line, new_end_col, 0 })
      vim.cmd("normal! gv")
    end
  end

  M.move_normal_word_h = function(direction)
    -- Select word under cursor (inner word)
    vim.cmd("normal! viw")
    -- Now move the selection
    M.move_visual_word_h(direction)
  end

  -- =============================================================================
  -- Keymaps / 按键映射
  -- =============================================================================

  map({
    ["move-selection-down"] = {
      "x",
      "<M-j>",
      function()
        M.move_visual_line_v("down")
      end,
    },
    ["move-selection-up"] = {
      "x",
      "<M-k>",
      function()
        M.move_visual_line_v("up")
      end,
    },
    ["move-line-down"] = {
      "n",
      "<M-j>",
      function()
        M.move_normal_line_v("down")
      end,
    },
    ["move-line-up"] = {
      "n",
      "<M-k>",
      function()
        M.move_normal_line_v("up")
      end,
    },
    ["move-selection-left"] = {
      "x",
      "<M-h>",
      function()
        M.move_visual_word_h("left")
      end,
    },
    ["move-selection-right"] = {
      "x",
      "<M-l>",
      function()
        M.move_visual_word_h("right")
      end,
    },
    ["move-word-left"] = {
      "n",
      "<M-h>",
      function()
        M.move_normal_word_h("left")
      end,
    },
    ["move-word-right"] = {
      "n",
      "<M-l>",
      function()
        M.move_normal_word_h("right")
      end,
    },

    -- Better Cursor Movement
    ["move-cursor-down"] = { { "n", "x", "v" }, "j", "v:count == 0 ? 'gj' : 'j'" },
    ["move-cursor-up"] = { { "n", "x", "v" }, "k", "v:count == 0 ? 'gk' : 'k'" },

    -- Center Screen After Jumps
    ["next-search-centered"] = { "n", "n", "nzzzv" },
    ["prev-search-centered"] = { "n", "N", "Nzzzv" },
    ["half-page-down-centered"] = { "n", "<C-d>", "<C-d>zz" },
    ["half-page-up-centered"] = { "n", "<C-u>", "<C-u>zz" },

    -- Arrow Selection
    ["left-arrow-visual-select"] = { "n", "<Left>", "vh" },
    ["right-arrow-visual-select"] = { "n", "<Right>", "vl" },
  }, { silent = true })

  -- Expr mappings need explicit definition if map function handles standard silent only
  -- 表达式映射通常需要显式定义
  vim.keymap.set(
    { "n", "x", "v" },
    "j",
    "v:count == 0 ? 'gj' : 'j'",
    { expr = true, silent = true }
  )
  vim.keymap.set(
    { "n", "x", "v" },
    "k",
    "v:count == 0 ? 'gk' : 'k'",
    { expr = true, silent = true }
  )
end
