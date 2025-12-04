local M = {}
-- virt_text for fold line display

M.virt_text = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = (" 󰁂 %d "):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0

  -- 获取首尾行内容和文件类型 (Get first/last line content and filetype)
  local firstLine = vim.fn.getline(lnum)
  local lastLine = vim.fn.getline(endLnum)
  local filetype = vim.bo.filetype

  -- 括号配对定义 (Bracket pairs definition)
  local pairs = {
    ["{"] = "}",
    ["["] = "]",
    ["("] = ")",
  }
  local reverse_pairs = {
    ["}"] = "{",
    ["]"] = "[",
    [")"] = "(",
  }

  -- 需要处理尖括号的语言 (Languages needing angle brackets handling)
  local angle_bracket_langs = {
    rust = true,
    cpp = true,
    java = true,
    typescript = true,
    typescriptreact = true,
    cs = true,
    kotlin = true,
    swift = true,
    scala = true,
  }

  -- 需要处理 JSX 标签的语言 (Languages needing JSX handling)
  local jsx_langs = {
    javascript = true,
    typescript = true,
    javascriptreact = true,
    typescriptreact = true,
    jsx = true,
    tsx = true,
    vue = true,
    svelte = true,
  }

  -- 分析整个折叠区域的括号平衡 (Analyze bracket balance in folded region)
  local stack = {}
  local inString = false
  local stringChar = nil

  for i = lnum, endLnum do
    local line = vim.fn.getline(i)
    local j = 1
    while j <= #line do
      local char = line:sub(j, j)
      local prevChar = j > 1 and line:sub(j - 1, j - 1) or ""

      -- 处理字符串 (Handle strings)
      if (char == '"' or char == "'" or char == "`") and prevChar ~= "\\" then
        if not inString then
          inString = true
          stringChar = char
        elseif char == stringChar then
          inString = false
          stringChar = nil
        end
      end

      if not inString then
        -- 处理普通括号 (Handle normal brackets)
        if pairs[char] then
          table.insert(stack, char)
        elseif reverse_pairs[char] then
          if #stack > 0 and stack[#stack] == reverse_pairs[char] then
            table.remove(stack)
          end
        -- 智能处理尖括号 (Smart angle brackets handling)
        elseif char == "<" then
          local nextChar = j < #line and line:sub(j + 1, j + 1) or ""
          -- JSX 标签
          if
            jsx_langs[filetype] and (nextChar:match("%a") or nextChar == "/" or nextChar == ">")
          then
            table.insert(stack, "<")
          -- 泛型
          elseif angle_bracket_langs[filetype] and nextChar:match("%w") then
            table.insert(stack, "<")
          end
        elseif char == ">" then
          local prevNonSpace = line:sub(1, j - 1):match("(%S)%s*$")
          if #stack > 0 and stack[#stack] == "<" then
            if prevNonSpace == "/" then
              table.remove(stack)
            elseif jsx_langs[filetype] or angle_bracket_langs[filetype] then
              table.remove(stack)
            end
          end
        end
      end

      j = j + 1
    end
  end

  -- 判断是否应该显示完整最后一行 (Determine if full last line should be shown)
  local showFullLastLine = false

  if #stack == 0 then
    showFullLastLine = true
  end

  -- 针对使用 end 关键字的语言 (For 'end' keyword languages)
  local end_keyword_langs = {
    lua = true,
    ruby = true,
    crystal = true,
    elixir = true,
    vim = true,
  }

  if end_keyword_langs[filetype] then
    if
      lastLine:match("end")
      and (
        firstLine:match("function")
        or firstLine:match("^%s*if")
        or firstLine:match("^%s*for")
        or firstLine:match("^%s*while")
        or firstLine:match("^%s*local%s+function")
        or firstLine:match("^%s*do%s*$")
        or firstLine:match("^%s*def%s+")
        or firstLine:match("^%s*class%s+")
        or firstLine:match("^%s*module%s+")
        or firstLine:match("^%s*unless%s+")
        or firstLine:match("^%s*until%s+")
        or firstLine:match("^%s*case%s+")
        or firstLine:match("^%s*begin%s*$")
      )
    then
      showFullLastLine = true
    end
  end

  -- 针对 Rust (For Rust)
  if filetype == "rust" then
    if
      (lastLine:match("}") or lastLine:match("]") or lastLine:match(")"))
      and (
        firstLine:match("fn%s+")
        or firstLine:match("match%s+")
        or firstLine:match("impl%s+")
        or firstLine:match("struct%s+")
        or firstLine:match("enum%s+")
        or firstLine:match("trait%s+")
        or firstLine:match("if%s+")
        or firstLine:match("for%s+")
        or firstLine:match("while%s+")
        or firstLine:match("loop%s*{")
      )
    then
      showFullLastLine = true
    end
  end

  -- 针对 JSX/TSX (For JSX/TSX)
  if jsx_langs[filetype] then
    if firstLine:match("<%w+") and lastLine:match("</%w+>") then
      showFullLastLine = true
    elseif firstLine:match("<%s*>") and lastLine:match("</%s*>") then
      showFullLastLine = true
    end
  end

  -- 针对 C-style 语言 (For C-style languages)
  local c_like_langs = {
    java = true,
    c = true,
    cpp = true,
    cs = true,
    go = true,
    kotlin = true,
    swift = true,
    scala = true,
  }

  if c_like_langs[filetype] then
    if
      lastLine:match("}")
      and (
        firstLine:match("class%s+")
        or firstLine:match("interface%s+")
        or firstLine:match("struct%s+")
        or firstLine:match("enum%s+")
        or firstLine:match("func%s+")
        or firstLine:match("function%s+")
        or firstLine:match("if%s*%(")
        or firstLine:match("for%s*%(")
        or firstLine:match("while%s*%(")
        or firstLine:match("switch%s*%(")
        or firstLine:match("try%s*{")
        or firstLine:match("do%s*{")
      )
    then
      showFullLastLine = true
    end
  end

  if filetype == "python" and #stack == 0 then
    showFullLastLine = false
  end

  local closingPart
  if showFullLastLine then
    local trimmedLastLine = lastLine:gsub("^%s+", "")
    closingPart = " ... " .. trimmedLastLine
  else
    closingPart = " ... "
    for i = #stack, 1, -1 do
      closingPart = closingPart .. pairs[stack[i]]
    end
    local trailingChars = lastLine:match("[,;]%s*$") or ""
    if trailingChars ~= "" then
      closingPart = closingPart .. trailingChars
    end
  end

  if filetype == "python" and #stack == 0 then
    closingPart = " ..."
  end

  -- [UPDATED LOGIC STARTS HERE]
  -- 收集并使用统一的高亮组 (Collect and use unified highlight group)
  local hlGroup = "Folded"
  local bracketHlGroup = nil -- 用于存储括号的高亮 (Store bracket highlight)

  for _, chunk in ipairs(virtText) do
    local chunkText = chunk[1]
    local chunkHl = chunk[2]

    -- 检查当前 chunk 是否包含括号，如果是，捕获其高亮
    -- Check if current chunk contains brackets, if so, capture highlight
    if chunkText:match("[{%(<%[]") then
      bracketHlGroup = chunkHl
    end

    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
      if chunkHl and chunkHl ~= "" then
        hlGroup = chunkHl
      end
    else
      chunkText = truncate(chunkText, targetWidth - curWidth)
      if chunkHl and chunkHl ~= "" then
        hlGroup = chunkHl
      end
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if curWidth + chunkWidth < targetWidth then
        suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
      end
      break
    end
    curWidth = curWidth + chunkWidth
  end

  -- 使用捕获到的括号高亮，如果没找到则使用默认或最后一个 chunk 的高亮
  -- Use captured bracket highlight, otherwise fallback to default/last chunk highlight
  local finalHl = bracketHlGroup or hlGroup

  table.insert(newVirtText, { closingPart, finalHl })
  table.insert(newVirtText, { suffix, "Folded" }) -- suffix 通常保持 Folded 样式 (Suffix usually stays Folded)

  return newVirtText
end

return M
