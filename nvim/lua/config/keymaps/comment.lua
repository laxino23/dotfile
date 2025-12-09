local filetype_comment_patterns = {
  lua = "^%s*%-%-",
  python = "^%s*#",
  javascript = "^%s*//",
  typescript = "^%s*//",
  c = "^%s*//",
  cpp = "^%s*//",
  rust = "^%s*//",
  go = "^%s*//",
  java = "^%s*//",
  vim = '^%s*"',
  sql = "^%s*%-%-",
  sh = "^%s*#",
  bash = "^%s*#",
}

local filetype_block_comment_patterns = {
  lua = { start = "^%s*%-%-%s*%[%[", ending = "%]%]%s*$" },
  python = { start = '^%s*"""', ending = '"""%s*$' },
  c = { start = "^%s*/%*", ending = "%*/%s*$" },
  cpp = { start = "^%s*/%*", ending = "%*/%s*$" },
  java = { start = "^%s*/%*", ending = "%*/%s*$" },
  javascript = { start = "^%s*/%*", ending = "%*/%s*$" },
  typescript = { start = "^%s*/%*", ending = "%*/%s*$" },
  rust = { start = "^%s*/%*", ending = "%*/%s*$" },
  css = { start = "^%s*/%*", ending = "%*/%s*$" },
  html = { start = "^%s*<!%-%-", ending = "%--%>%s*$" },
}

local lsp_annotation_patterns = {
  lua = "^%s*%-%-%-@",
  python = "^%s*#%s*:type",
  typescript = "^%s*//%s*@",
  javascript = "^%s*//%s*@",
}


return function(map)
  local M = {}

  -- =============================================================================
  -- Logic: Commenting / 逻辑：注释
  -- =============================================================================

  -- Insert comment at specific position
  M.comment = function(pos)
    return function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      local total_lines = vim.api.nvim_buf_line_count(0)
      local commentstring = vim.bo.commentstring
      local cmt = commentstring:gsub("%%s", "")
      local index = commentstring:find("%%s")

      -- Check if current line is folded
      local fold_start = vim.fn.foldclosed(row)
      local fold_end = vim.fn.foldclosedend(row)
      local is_folded = fold_end ~= -1

      -- If folded, adjust the target row
      local actual_row = row
      if is_folded then
        if pos == "below" then
          actual_row = fold_end
        elseif pos == "above" then
          actual_row = fold_start
        end
      end

      local target_line
      if pos == "below" then
        target_line = (actual_row == total_lines)
            and vim.api.nvim_buf_get_lines(0, actual_row - 1, actual_row, true)[1]
          or vim.api.nvim_buf_get_lines(0, actual_row, actual_row + 1, true)[1]
      elseif pos == "above" then
        target_line = vim.api.nvim_buf_get_lines(0, actual_row - 1, actual_row, true)[1]
      else
        target_line = vim.api.nvim_get_current_line()
      end

      local line_start = target_line:find("%S") or (#target_line + 1)
      local indent = target_line:sub(1, line_start - 1)
      local cursor_row, cursor_col

      if pos == "end" then
        if target_line:find("%S") then
          cmt = " " .. cmt
          index = index + 1
        end
        vim.api.nvim_buf_set_lines(0, actual_row - 1, actual_row, false, { target_line .. cmt })
        cursor_row = actual_row
        cursor_col = #target_line + index - 2
      elseif pos == "above" then
        vim.api.nvim_buf_set_lines(0, actual_row - 1, actual_row - 1, true, { indent .. cmt })
        cursor_row = actual_row
        cursor_col = #indent + index - 2

        -- If was folded, recreate the fold (now shifted down by 1)
        if is_folded then
          vim.cmd(string.format("%d,%dfold", fold_start + 1, fold_end + 1))
        end
      elseif pos == "below" then
        vim.api.nvim_buf_set_lines(0, actual_row, actual_row, true, { indent .. cmt })
        cursor_row = actual_row + 1
        cursor_col = #indent + index - 2

        -- If was folded, recreate the fold (same range)
        if is_folded then
          vim.cmd(string.format("%d,%dfold", fold_start, fold_end))
        end
      end

      vim.api.nvim_win_set_cursor(0, { cursor_row, cursor_col })
      vim.api.nvim_feedkeys("a", "n", false)
    end
  end

  -- Toggle single line comment
  M.comment_line = function()
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

  -- Toggle comment for line or fold
  M.toggle_fold_or_line = function()
    local current_line = vim.fn.line(".")
    local fold_start = vim.fn.foldclosed(current_line)

    if fold_start == -1 then
      M.comment_line()
      return
    end

    local fold_end = vim.fn.foldclosedend(current_line)
    local filetype = vim.bo.filetype

    vim.cmd("normal! zo")

    local line_comment = vim.bo.commentstring:gsub("%%s.*", ""):gsub("%s+$", "")
    local line_pattern = filetype_comment_patterns[filetype]
    local lsp_pattern = lsp_annotation_patterns[filetype]

    if not line_pattern then
      local comment_chars = line_comment:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
      line_pattern = "^%s*" .. comment_chars
    end

    local has_uncommented = false
    for i = fold_start, fold_end do
      local line = vim.fn.getline(i)
      if not (lsp_pattern and line:match(lsp_pattern)) then
        if not line:match(line_pattern) then
          has_uncommented = true
          break
        end
      end
    end

    if has_uncommented then
      for i = fold_start, fold_end do
        local line = vim.fn.getline(i)
        if not (lsp_pattern and line:match(lsp_pattern)) then
          local indent = line:match("^%s*") or ""
          local content = line:sub(#indent + 1)
          local new_line
          if content == "" or content:match("^%s*$") then
            new_line = indent .. line_comment
          else
            new_line = indent .. line_comment .. " " .. content
          end
          vim.fn.setline(i, new_line)
        end
      end
      vim.fn.cursor(fold_start, 1)
      vim.cmd("normal! zc")
    else
      for i = fold_start, fold_end do
        local line = vim.fn.getline(i)
        if not (lsp_pattern and line:match(lsp_pattern)) then
          if line:match(line_pattern) then
            local new_line = line:gsub(line_pattern .. "%s?", "", 1)
            vim.fn.setline(i, new_line)
          end
        end
      end
      vim.cmd(string.format("silent! %d,%d normal! ==", fold_start, fold_end))
      vim.defer_fn(function()
        vim.fn.cursor(fold_start, 1)
        pcall(function()
          vim.cmd("normal! zc")
        end)
      end, 50)
    end
  end

  -- Smart Toggle
  M.smart_toggle = function()
    local mode = vim.fn.mode()

    -- === 1. VISUAL MODE Logic ===
    if mode:match("[vV]") or mode == "\22" then
      vim.cmd("normal! \27")
      local start_line = vim.fn.line("'<")
      local end_line = vim.fn.line("'>")
      local filetype = vim.bo.filetype
      local line_comment = vim.bo.commentstring:gsub("%%s.*", ""):gsub("%s+$", "")
      local line_pattern = filetype_comment_patterns[filetype]
      local lsp_pattern = lsp_annotation_patterns[filetype]

      if not line_pattern then
        local comment_chars = line_comment:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
        line_pattern = "^%s*" .. comment_chars
      end

      local fold_ranges = {}
      local non_fold_lines = {}
      local processed_lines = {}

      for lnum = start_line, end_line do
        if not processed_lines[lnum] then
          local fold_start = vim.fn.foldclosed(lnum)
          if fold_start ~= -1 then
            local fold_end = vim.fn.foldclosedend(lnum)
            table.insert(fold_ranges, { start = fold_start, ending = fold_end })
            for i = fold_start, fold_end do
              processed_lines[i] = true
            end
          else
            table.insert(non_fold_lines, lnum)
            processed_lines[lnum] = true
          end
        end
      end

      local has_uncommented = false
      for _, fold_range in ipairs(fold_ranges) do
        vim.fn.cursor(fold_range.start, 1)
        vim.cmd("normal! zo")
        for i = fold_range.start, fold_range.ending do
          local line = vim.fn.getline(i)
          if not (lsp_pattern and line:match(lsp_pattern)) then
            if not line:match(line_pattern) then
              has_uncommented = true
              break
            end
          end
        end
        vim.fn.cursor(fold_range.start, 1)
        vim.cmd("normal! zc")
        if has_uncommented then
          break
        end
      end

      if not has_uncommented then
        for _, lnum in ipairs(non_fold_lines) do
          local line = vim.fn.getline(lnum)
          if vim.trim(line) ~= "" then
            if not (lsp_pattern and line:match(lsp_pattern)) then
              if not line:match(line_pattern) then
                has_uncommented = true
                break
              end
            end
          end
        end
      end

      if has_uncommented then
        -- COMMENT
        for _, fold_range in ipairs(fold_ranges) do
          vim.fn.cursor(fold_range.start, 1)
          vim.cmd("normal! zo")
          for i = fold_range.start, fold_range.ending do
            local line = vim.fn.getline(i)
            if not (lsp_pattern and line:match(lsp_pattern)) then
              local indent = line:match("^%s*") or ""
              local content = line:sub(#indent + 1)
              vim.fn.setline(i, indent .. line_comment .. " " .. content)
            end
          end
          vim.fn.cursor(fold_range.start, 1)
          vim.cmd("normal! zc")
        end
        for _, lnum in ipairs(non_fold_lines) do
          local line = vim.fn.getline(lnum)
          if vim.trim(line) ~= "" and not (lsp_pattern and line:match(lsp_pattern)) then
            local indent = line:match("^%s*") or ""
            local content = line:sub(#indent + 1)
            vim.fn.setline(lnum, indent .. line_comment .. " " .. content)
          end
        end
      else
        -- UNCOMMENT
        for _, fold_range in ipairs(fold_ranges) do
          vim.fn.cursor(fold_range.start, 1)
          vim.cmd("normal! zo")
          for i = fold_range.start, fold_range.ending do
            local line = vim.fn.getline(i)
            if not (lsp_pattern and line:match(lsp_pattern)) and line:match(line_pattern) then
              vim.fn.setline(i, line:gsub(line_pattern .. "%s?", "", 1))
            end
          end
          vim.cmd(string.format("silent! %d,%d normal! ==", fold_range.start, fold_range.ending))
          vim.defer_fn(function()
            vim.fn.cursor(fold_range.start, 1)
            pcall(function()
              vim.cmd("normal! zc")
            end)
          end, 50)
        end
        for _, lnum in ipairs(non_fold_lines) do
          local line = vim.fn.getline(lnum)
          if not (lsp_pattern and line:match(lsp_pattern)) and line:match(line_pattern) then
            vim.fn.setline(lnum, line:gsub(line_pattern .. "%s?", "", 1))
          end
        end
      end
      return
    end

    -- === 2. NORMAL MODE Logic ===
    local current_line = vim.fn.line(".")
    local fold_start = vim.fn.foldclosed(current_line)
    if fold_start ~= -1 then
      M.toggle_fold_or_line()
    else
      M.comment_line()
    end
  end

  -- =============================================================================
  -- Keymaps / 按键映射
  -- =============================================================================

  map({
    ["smart-comment-toggle-normal"] = { "n", "gcc", M.smart_toggle },
    ["smart-comment-toggle-visual"] = { "x", "gc", M.smart_toggle },
    ["comment-above"] = { "n", "gcO", M.comment("above") },
    ["comment-below"] = { "n", "gco", M.comment("below") },
    ["comment-end"] = { "n", "gcA", M.comment("end") },
  }, { silent = true })
end
