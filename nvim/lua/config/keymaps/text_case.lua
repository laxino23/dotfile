return function(map)
  local M = {}

  -- =============================================================================
  -- Logic: Case Conversion / 逻辑：大小写转换
  -- =============================================================================

  local IGNORE_KEYWORDS = {
    lua = {
      "local",
      "function",
      "return",
      "end",
      "if",
      "then",
      "else",
      "elseif",
      "for",
      "while",
      "do",
      "repeat",
      "until",
      "break",
      "in",
      "true",
      "false",
      "nil",
    },
    python = {
      "def",
      "class",
      "return",
      "import",
      "from",
      "if",
      "elif",
      "else",
      "for",
      "while",
      "try",
      "except",
      "finally",
      "with",
      "as",
      "pass",
      "lambda",
      "None",
      "True",
      "False",
    },
    typescript = {
      "const",
      "let",
      "var",
      "function",
      "class",
      "interface",
      "type",
      "enum",
      "import",
      "export",
      "return",
      "if",
      "else",
      "switch",
      "case",
      "default",
      "try",
      "catch",
      "finally",
      "async",
      "await",
      "new",
      "this",
      "super",
    },
    javascript = {
      "const",
      "let",
      "var",
      "function",
      "class",
      "import",
      "export",
      "return",
      "if",
      "else",
      "async",
      "await",
    },
    rust = {
      "fn",
      "let",
      "mut",
      "pub",
      "struct",
      "enum",
      "impl",
      "use",
      "mod",
      "crate",
      "match",
      "if",
      "else",
      "loop",
      "while",
      "for",
      "return",
      "break",
      "continue",
      "const",
      "static",
      "type",
      "trait",
      "where",
      "unsafe",
      "async",
      "await",
    },
    swift = {
      "func",
      "var",
      "let",
      "class",
      "struct",
      "enum",
      "extension",
      "protocol",
      "init",
      "deinit",
      "return",
      "if",
      "else",
      "guard",
      "switch",
      "case",
      "default",
      "for",
      "in",
      "while",
      "repeat",
      "break",
      "continue",
      "try",
      "catch",
      "throw",
    },
    html = { "div", "span", "class", "id", "style", "script", "body", "head", "html" },
    css = { "color", "background", "margin", "padding", "font", "border", "display" },
  }

  IGNORE_KEYWORDS.ts = IGNORE_KEYWORDS.typescript
  IGNORE_KEYWORDS.js = IGNORE_KEYWORDS.javascript
  IGNORE_KEYWORDS.rs = IGNORE_KEYWORDS.rust

  local function capitalize(word)
    return word:sub(1, 1):upper() .. word:sub(2):lower()
  end
  local function lowercase(word)
    return word:lower()
  end

  local function is_keyword(word, ft)
    local list = IGNORE_KEYWORDS[ft]
    if not list then
      return false
    end
    for _, kw in ipairs(list) do
      if kw == word then
        return true
      end
    end
    return false
  end

  local function tokenize(text)
    local words = {}
    local current_word = ""
    for i = 1, #text do
      local char = text:sub(i, i)
      if char == "_" or char == "-" then
        if #current_word > 0 then
          table.insert(words, lowercase(current_word))
          current_word = ""
        end
      elseif char:match("%u") then
        if #current_word > 0 then
          table.insert(words, lowercase(current_word))
        end
        current_word = char
      elseif char:match("%d") then
        if #current_word > 0 and not current_word:match("^%d+$") then
          table.insert(words, lowercase(current_word))
          current_word = ""
        end
        current_word = current_word .. char
      else
        if #current_word > 0 and current_word:match("^%d+$") then
          table.insert(words, lowercase(current_word))
          current_word = ""
        end
        current_word = current_word .. char
      end
    end
    if #current_word > 0 then
      table.insert(words, lowercase(current_word))
    end
    return words
  end

  local function detect_case(text)
    local first_delim = nil
    local has_upper_after_start = false
    for i = 1, #text do
      local char = text:sub(i, i)
      if char == "_" then
        if not first_delim then
          first_delim = "_"
        end
      elseif char == "-" then
        if not first_delim then
          first_delim = "-"
        end
      elseif char:match("%u") and i > 1 then
        has_upper_after_start = true
        if not first_delim then
          return "camel"
        end
      end
    end
    if first_delim == "_" then
      return "snake"
    elseif first_delim == "-" then
      return "kebab"
    elseif has_upper_after_start then
      return "camel"
    else
      return "snake"
    end
  end

  local function convert_to_case(words, case_type)
    if case_type == "snake" then
      return table.concat(words, "_")
    elseif case_type == "kebab" then
      return table.concat(words, "-")
    elseif case_type == "camel" then
      local result = words[1]
      for i = 2, #words do
        result = result .. capitalize(words[i])
      end
      return result
    end
    return table.concat(words, "")
  end

  local function next_case(current)
    if current == "snake" then
      return "camel"
    elseif current == "camel" then
      return "kebab"
    else
      return "snake"
    end
  end

  M.cycle_case = function()
    local mode = vim.fn.mode()
    if not (mode:match("[vV]") or mode == "\22") then
      if vim.fn.getpos("'<")[2] == 0 then
        vim.notify("请先选中文件并在 Visual 模式下使用", vim.log.levels.WARN)
        return
      end
    end

    local p1 = vim.fn.getpos("v")
    local p2 = vim.fn.getpos(".")
    local start_pos, end_pos
    if p1[2] < p2[2] or (p1[2] == p2[2] and p1[3] <= p2[3]) then
      start_pos, end_pos = p1, p2
    else
      start_pos, end_pos = p2, p1
    end

    local start_line, start_col = start_pos[2], start_pos[3]
    local end_line, end_col = end_pos[2], end_pos[3]

    if start_line == 0 or end_line == 0 then
      return
    end

    if start_line ~= end_line then
      vim.notify("目前仅支持单行选中", vim.log.levels.WARN)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      return
    end

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)
    if #lines == 0 then
      return
    end

    local line_content = lines[1]
    if mode == "V" then
      start_col = 1
      end_col = #line_content
    else
      end_col = math.min(end_col, #line_content)
    end

    local text_selection = line_content:sub(start_col, end_col)
    local ft = vim.bo.filetype

    local new_selection = text_selection:gsub("([%w_%-]+)", function(word)
      if is_keyword(word, ft) then
        return word
      end
      if word:match("^%d+$") then
        return word
      end
      local words = tokenize(word)
      if #words == 0 then
        return word
      end
      return convert_to_case(words, next_case(detect_case(word)))
    end)

    vim.api.nvim_buf_set_text(
      0,
      start_line - 1,
      start_col - 1,
      start_line - 1,
      start_col - 1 + #text_selection,
      { new_selection }
    )

    local new_end_col = start_col + #new_selection - 1
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    vim.schedule(function()
      vim.api.nvim_win_set_cursor(0, { start_line, start_col - 1 })
      local v_cmd = (mode == "V") and "V" or "v"
      vim.cmd("normal! " .. v_cmd)
      vim.api.nvim_win_set_cursor(0, { start_line, new_end_col - 1 })
    end)
  end

  -- =============================================================================
  -- Keymaps / 按键映射
  -- =============================================================================

  map({
    ["cycle-variable-case"] = { "x", "<leader>uu", M.cycle_case },
  }, { silent = true })
end
