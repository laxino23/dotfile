local M = {}

-- =============================================================================
-- Keymap Utility / 按键映射工具
-- =============================================================================

---Batch register key mappings from a configuration table.
---批量注册配置表中的按键映射。
---@param config table<string, table>
---@param opts table|nil
---@return nil
M.map = function(config, opts)
  opts = opts or {}

  for name, map_def in pairs(config) do
    -- Replace hyphens with spaces for description
    local desc = name:gsub("-", " ")
    local mode = map_def[1]
    local lhs = map_def[2]
    local rhs = map_def[3]

    local specific_opts = {}
    for k, v in pairs(map_def) do
      if type(k) ~= "number" then
        specific_opts[k] = v
      end
    end

    local final_opts = vim.tbl_deep_extend("force", opts, specific_opts, { desc = desc })
    vim.keymap.set(mode, lhs, rhs, final_opts)
  end
end

-- =============================================================================
-- Line & Fold Movement / 行与折叠移动
-- =============================================================================

M.lineMovement = {}

local function get_visual_unit(line_num)
  local fold_start = vim.fn.foldclosed(line_num)
  if fold_start ~= -1 then
    return fold_start, vim.fn.foldclosedend(line_num)
  else
    return line_num, line_num
  end
end

M.lineMovement.move_normal_selection = function(direction)
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
    local prev_start = vim.fn.foldclosed(prev_line)
    -- local prev_end = (prev_start ~= -1) and vim.fn.foldclosedend(prev_line) or prev_line

    vim.cmd(start_line .. "," .. end_line .. "m " .. (prev_start - 1))

    local new_start = prev_start
    local new_end = new_start + (end_line - start_line)
    vim.cmd(new_start .. "," .. new_end .. "=")

    local adjust = start_line - prev_start
    vim.fn.cursor(cur - adjust, vim.fn.col("."))
  end
end

M.lineMovement.move_visual_selection = function(direction)
  vim.cmd("normal! \27")
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

-- =============================================================================
-- Commenting / 注释功能
-- =============================================================================

M.comment = {}

M.comment.comment = function(pos)
  return function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local total_lines = vim.api.nvim_buf_line_count(0)
    local commentstring = vim.bo.commentstring
    local cmt = commentstring:gsub("%%s", "")
    local index = commentstring:find("%%s")

    local target_line
    if pos == "below" then
      target_line = (row == total_lines) and vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
        or vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
    else
      target_line = vim.api.nvim_get_current_line()
    end

    if pos == "end" then
      if target_line:find("%S") then
        cmt = " " .. cmt
        index = index + 1
      end
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { target_line .. cmt })
      vim.api.nvim_win_set_cursor(0, { row, #target_line + index - 2 })
    else
      local line_start = target_line:find("%S") or (#target_line + 1)
      local indent = target_line:sub(1, line_start - 1)

      if pos == "above" then
        vim.api.nvim_buf_set_lines(0, row - 1, row - 1, true, { indent .. cmt })
        vim.api.nvim_win_set_cursor(0, { row, #indent + index - 2 })
      elseif pos == "below" then
        vim.api.nvim_buf_set_lines(0, row, row, true, { indent .. cmt })
        vim.api.nvim_win_set_cursor(0, { row + 1, #indent + index - 2 })
      end
    end
    vim.api.nvim_feedkeys("a", "n", false)
  end
end

M.comment.comment_line = function()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  if not line:find("%S") then
    local commentstring = vim.bo.commentstring
    local cmt = commentstring:gsub("%%s", "")
    local indent_width = vim.fn.indent(row)
    local indent_str = (" "):rep(indent_width)
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { indent_str .. cmt })
    vim.api.nvim_win_set_cursor(0, { row, #indent_str + #cmt })
    vim.cmd("startinsert!")
  else
    require("vim._comment").toggle_lines(row, row, { row, 0 })
  end
end

-- =============================================================================
-- Line Management / 行管理
-- =============================================================================

M.line_manage = {}

M.line_manage.join_lines = function()
  local v_count = vim.v.count1 + 1
  local mode = vim.api.nvim_get_mode().mode
  local keys = (mode == "n") and (v_count .. "J") or "J"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

M.line_manage.insert_lines = function(direction)
  local line = vim.api.nvim_get_current_line()
  local indent = line:match("^%s*") or ""
  local lines = { "", "", "" }
  local row = vim.api.nvim_win_get_cursor(0)[1]

  if direction == "up" then
    vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, lines)
    vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  else
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    vim.api.nvim_win_set_cursor(0, { row + 2, 0 })
  end
  vim.cmd("startinsert")
  if #indent > 0 then
    vim.api.nvim_put({ indent }, "c", false, true)
  end
end

-- =============================================================================
-- Action (Undo/Redo)
-- =============================================================================

M.action = {}

M.action.undo = function()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "n" or mode == "i" or mode == "v" then
    vim.cmd("undo")
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end
end

M.action.redo = function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  vim.cmd("redo")
end

return M
