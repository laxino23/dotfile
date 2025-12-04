local M = {}

local icons = require("config.ui").icons.fold

-- Comment patterns for different filetypes
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
-- Block comment signs for different filetypes
local filetype_block_comment_patterns = {
  lua = {
    start = "^%s*%-%-%[%[",
    ending = "%]%]%s*$",
  },
  python = {
    start = '^%s*"""',
    ending = '"""%s*$',
  },
  c = {
    start = "^%s*/%*",
    ending = "%*/%s*$",
  },
  cpp = {
    start = "^%s*/%*",
    ending = "%*/%s*$",
  },
  java = {
    start = "^%s*/%*",
    ending = "%*/%s*$",
  },
  javascript = {
    start = "^%s*/%*",
    ending = "%*/%s*$",
  },
  typescript = {
    start = "^%s*/%*",
    ending = "%*/%s*$",
  },
  rust = {
    start = "^%s*/%*",
    ending = "%*/%s*$",
  },
  css = {
    start = "^%s*/%*",
    ending = "%*/%s*$",
  },
  html = {
    start = "^%s*<!%-%-",
    ending = "%--%>%s*$",
  },
}
-- LSP annotation patterns (like ---@param, ---@return, etc.)
local lsp_annotation_patterns = {
  lua = "^%s*%-%-%-@", -- Lua annotations like ---@param, ---@return
  python = "^%s*#%s*:type", -- Python type hints
  typescript = "^%s*//%s*@", -- TSDoc annotations
  javascript = "^%s*//%s*@", -- JSDoc annotations
}

-- Check if a line is a comment based on its text
-- This function determines whether a given line of code is a comment line
-- by matching it against the comment pattern for the specified filetype.
-- 该函数通过匹配指定文件类型的注释模式来判断给定的代码行是否为注释行。
---@param line_text string The text of the line to check. 要检查的行文本。
---@param filetype string The filetype of the buffer. 缓冲区的文件类型。
---@return boolean Whether the line is a comment. 该行是否为注释。
local function is_comment_line(line_text, filetype)
  local pattern = filetype_comment_patterns[filetype]
  if not pattern then
    return false
  end
  return line_text:match(pattern) ~= nil
end

-- Check if a line is an LSP annotation
-- This function checks if a line contains LSP annotations like type hints or
-- documentation tags for the given filetype.
-- 该函数检查一行是否包含LSP注解，如类型提示或文档标签，针对给定的文件类型。
---@param line_text string The text of the line to check. 要检查的行文本。
---@param filetype string The filetype of the buffer. 缓冲区的文件类型。
---@return boolean Whether the line is an LSP annotation. 该行是否为LSP注解。
local function is_lsp_annotation(line_text, filetype)
  local pattern = lsp_annotation_patterns[filetype]
  if not pattern then
    return false
  end
  return line_text:match(pattern) ~= nil
end

-- Check if the fold starts with a block comment sign
-- This function verifies if the first line of a fold starts with
-- a block comment opener for the specified filetype.
-- 该函数验证折叠的第一行是否以指定文件类型的块注释开头符号开始。
---@param bufnr integer The buffer number. 缓冲区编号。
---@param lnum integer The starting line number (1-indexed). 开始行号（1-based）。
---@param filetype string The filetype of the buffer. 缓冲区的文件类型。
---@return boolean Whether the fold starts with a block comment. 折叠是否以块注释开头。
local function starts_with_block_comment(bufnr, lnum, filetype)
  local patterns = filetype_block_comment_patterns[filetype]
  if not patterns then
    return false
  end
  local first_line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  if not first_line then
    return false
  end
  return first_line:match(patterns.start) ~= nil
end

-- Check if the fold ends with a block comment sign
-- This function verifies if the last line of a fold
-- ends with a block comment closer for the specified filetype.
-- 该函数验证折叠的最后一行是否以指定文件类型的块注释结束符号结束。
---@param bufnr integer The buffer number. 缓冲区编号。
---@param endLnum integer The ending line number (1-indexed). 结束行号（1-based）。
---@param filetype string The filetype of the buffer. 缓冲区的文件类型。
---@return boolean Whether the fold ends with a block comment. 折叠是否以块注释结束。
local function ends_with_block_comment(bufnr, endLnum, filetype)
  local patterns = filetype_block_comment_patterns[filetype]
  if not patterns then
    return false
  end
  local last_line = vim.api.nvim_buf_get_lines(bufnr, endLnum - 1, endLnum, false)[1]
  if not last_line then
    return false
  end
  return last_line:match(patterns.ending) ~= nil
end

-- Check if entire folded block is a comment block
-- This function determines if the entire folded range is a comment block,
-- either in block style or line-by-line comments, and checks for LSP annotations.
-- 该函数判断整个折叠范围是否为注释块，包括块风格或逐行注释，并检查LSP注解。
---@param bufnr integer The buffer number. 缓冲区编号。
---@param lnum integer The starting line number (1-indexed). 开始行号（1-based）。
---@param endLnum integer The ending line number (1-indexed). 结束行号（1-based）。
---@param filetype string The filetype of the buffer. 缓冲区的文件类型。
---@return boolean is_comment Whether the block is a comment. 该块是否为注释。
---@return boolean is_block_style Whether it's a block-style comment. 是否为块风格注释。
local function is_comment_block(bufnr, lnum, endLnum, filetype)
  -- First check if it's a block comment (--[[ ]] style)
  if
    starts_with_block_comment(bufnr, lnum, filetype)
    and ends_with_block_comment(bufnr, endLnum, filetype)
  then
    return true, true -- is_comment, is_block_style
  end
  -- Check if all lines are LSP annotations (treat as special comment block)
  local first_line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  if first_line and is_lsp_annotation(first_line, filetype) then
    return true, false -- is_comment, not block_style
  end
  -- Sample a few lines from the block to check if all are comments
  local lines_to_check = { lnum, math.floor((lnum + endLnum) / 2), endLnum }
  for _, line_num in ipairs(lines_to_check) do
    local line = vim.api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)[1]
    if not line or not is_comment_line(line, filetype) then
      return false, false
    end
  end
  return true, false -- is_comment, not block_style
end

-- Remove comment signs from a text string
-- This function strips comment prefixes and decorators from a text string based on the filetype.
-- 该函数根据文件类型从文本字符串中去除注释前缀和装饰符。
---@param text string The text to process. 要处理的文本。
---@param filetype string The filetype of the buffer. 缓冲区的文件类型。
---@return string The cleaned text without comment signs. 去除注释符号后的清洁文本。
local function remove_comment_sign_from_text(text, filetype)
  local trimmed = vim.trim(text)
  -- Remove single-line comment signs
  if filetype == "lua" then
    trimmed = trimmed:gsub("^%-%-%-+%s*", "") -- Handle --- for annotations
    trimmed = trimmed:gsub("^%-%-+%s*", "")
  elseif filetype == "python" or filetype == "sh" or filetype == "bash" then
    trimmed = trimmed:gsub("^#+%s*", "")
  elseif
    filetype == "javascript"
    or filetype == "typescript"
    or filetype == "c"
    or filetype == "cpp"
    or filetype == "rust"
    or filetype == "go"
    or filetype == "java"
  then
    trimmed = trimmed:gsub("^//+%s*@?", "") -- Handle // and //@
  elseif filetype == "vim" then
    trimmed = trimmed:gsub('^"+%s*', "")
  elseif filetype == "sql" then
    trimmed = trimmed:gsub("^%-%-+%s*", "")
  elseif filetype == "html" or filetype == "xml" then
    trimmed = trimmed:gsub("^<!%-%-+%s*", ""):gsub("%s*%-%-+>$", "")
  elseif filetype == "css" or filetype == "scss" then
    trimmed = trimmed:gsub("^/%*+%s*", ""):gsub("%s*%*+/$", "")
  end
  -- Remove common comment decorators
  trimmed = trimmed:gsub("^[%*=%-]+%s*", "")
  trimmed = vim.trim(trimmed)
  return trimmed
end

-- Remove comment signs from virtual text chunks (only from chunks with Comment highlight)
-- This function processes virtual text chunks,
-- removing comment signs only from the first comment-highlighted chunk.
-- 该函数处理虚拟文本块，仅从第一个注释高亮块中去除注释符号。
---@param virt_text table The virtual text chunks to process. 要处理的虚拟文本块。
---@param filetype string The filetype of the buffer. 缓冲区的文件类型。
---@return table The processed virtual text chunks. 处理后的虚拟文本块。
local function remove_comment_from_virt_text(virt_text, filetype)
  local result = {}
  local found_comment = false
  for _, chunk in ipairs(virt_text) do
    local text = chunk[1]
    local hl_group = chunk[2]
    -- Only process comment chunks, and only remove sign from the first one
    if type(hl_group) == "string" and hl_group:match("Comment") then
      if not found_comment then
        text = remove_comment_sign_from_text(text, filetype)
        found_comment = true
      end
    end
    if text ~= "" then
      table.insert(result, { text, hl_group })
    end
  end
  return result
end

-- Get the last line virtual text using ctx.get_fold_virt_text
-- This function retrieves the virtual text for
-- the last line of a fold, optionally removing comment signs.
-- 该函数使用ctx.get_fold_virt_text获取折叠最后一行的虚拟文本，可选去除注释符号。
---@param ctx table The context object provided by the fold handler. 折叠处理程序提供的上下文对象。
---@param endLnum integer The ending line number (1-indexed). 结束行号（1-based）。
---@param filetype string The filetype of the buffer. 缓冲区的文件类型。
---@param remove_comment_sign boolean Whether to remove comment signs. 是否去除注释符号。
---@return table The virtual text chunks for the last line. 最后一行虚拟文本块。
local function get_last_line_virt_text(ctx, endLnum, filetype, remove_comment_sign)
  -- Check if ctx.get_fold_virt_text is available
  if not ctx or not ctx.get_fold_virt_text then
    -- Fallback: get raw text from buffer
    local last_line = vim.api.nvim_buf_get_lines(ctx.bufnr, endLnum - 1, endLnum, false)[1]
    if not last_line or last_line == "" then
      return {}
    end
    local text = vim.trim(last_line)
    if remove_comment_sign then
      text = remove_comment_sign_from_text(text, filetype)
    end
    if text ~= "" then
      return { { text, "Normal" } }
    end
    return {}
  end
  -- Use ctx.get_fold_virt_text
  local last_line_virt_text = ctx.get_fold_virt_text(endLnum)
  if not last_line_virt_text or #last_line_virt_text == 0 then
    return {}
  end
  -- Remove comment signs if requested
  if remove_comment_sign then
    return remove_comment_from_virt_text(last_line_virt_text, filetype)
  else
    return last_line_virt_text
  end
end

-- Extract trailing comment from virtual text chunks
-- This function separates the main virtual text from any trailing comment chunks.
-- 该函数从虚拟文本块中分离主体文本和任何尾随注释块。
---@param virtText table The virtual text chunks to process. 要处理的虚拟文本块。
---@return table result The main virtual text without trailing comments. 去除尾随注释的主体虚拟文本。
---@return table|nil comment_chunks The trailing comment chunks, or nil if none. 尾随注释块，或nil如果没有。
local function extract_trailing_comment(virtText)
  local result = {}
  local comment_chunks = {}
  local in_comment = false
  local has_non_comment = false
  for _, chunk in ipairs(virtText) do
    local hl_group = chunk[2]
    if in_comment then
      table.insert(comment_chunks, chunk)
    else
      if type(hl_group) == "string" and hl_group:match("Comment") then
        if has_non_comment then
          -- 这是尾随注释，开始移除
          in_comment = true
          table.insert(comment_chunks, chunk)
        else
          -- 这是整行注释或前导注释，保留在 result 中
          table.insert(result, chunk)
        end
      else
        -- 非注释部分
        has_non_comment = true
        table.insert(result, chunk)
      end
    end
  end
  return result, (#comment_chunks > 0 and comment_chunks or nil)
end

-- Main fold virtual text handler
-- This is the primary handler for generating
-- virtual text for folded lines, handling comments, separators, and fold indicators.
-- 这是生成折叠行虚拟文本的主要处理程序，处理注释、分隔符和折叠指示器。
M.handler = function(virtText, lnum, endLnum, width, truncate, ctx)
  local newVirtText = {}
  local filetype = vim.bo[ctx.bufnr].filetype
  -- Calculate how many lines are folded
  local fold_lines = endLnum - lnum
  local suffix = string.format(" %s %d lines", icons.lines or "󰁂", fold_lines)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  -- Check if this is a comment block and what style
  local is_comment, is_block_style = is_comment_block(ctx.bufnr, lnum, endLnum, filetype)
  -- Handle first line (already in virtText)
  -- Remove trailing comments if present for non-comment blocks
  local first_line_text
  if not is_comment then
    first_line_text = extract_trailing_comment(virtText)
  else
    -- 对于注释块，也移除注释符号，以保持一致
    first_line_text = remove_comment_from_virt_text(virtText, filetype)
  end
  -- Calculate space for content
  local targetWidth = width - sufWidth
  local curWidth = 0
  -- Add first line content
  for _, chunk in ipairs(first_line_text) do
    local chunkText = chunk[1]
    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
    if targetWidth > curWidth + chunkWidth then
      table.insert(newVirtText, chunk)
      curWidth = curWidth + chunkWidth
    else
      -- Truncate this chunk to fit
      chunkText = truncate(chunkText, targetWidth - curWidth)
      local hlGroup = chunk[2]
      table.insert(newVirtText, { chunkText, hlGroup })
      chunkWidth = vim.fn.strdisplaywidth(chunkText)
      curWidth = curWidth + chunkWidth
      break
    end
  end
  -- Add separator icon (omit indicator)
  local separator = string.format(" %s ", icons.omit or "⋯")
  local sepWidth = vim.fn.strdisplaywidth(separator)
  table.insert(newVirtText, { separator, "UfoFoldedEllipsis" })
  -- Add last line content if there's more than one line
  if fold_lines > 0 then
    -- For block comments (--[[ ]]), skip the last line (closing bracket)
    local skip_last_line = is_block_style
    if not skip_last_line then
      -- Use endLnum directly - ctx.get_fold_virt_text expects 1-indexed line numbers
      local last_line_chunks = get_last_line_virt_text(
        ctx,
        endLnum, -- endLnum is already 1-indexed
        filetype,
        is_comment -- Remove comment signs if it's a comment block
      )
      if last_line_chunks and #last_line_chunks > 0 then
        -- Calculate remaining space more accurately
        local used_width = curWidth + sepWidth + sufWidth
        local remaining_space = width - used_width
        if remaining_space > 5 then
          -- Add last line chunks
          local last_line_width = 0
          for _, chunk in ipairs(last_line_chunks) do
            local text = chunk[1]
            local hl = chunk[2]
            local text_width = vim.fn.strdisplaywidth(text)
            if last_line_width + text_width > remaining_space then
              -- Truncate and add
              text = truncate(text, remaining_space - last_line_width)
              if text ~= "" then
                table.insert(newVirtText, { text, hl })
              end
              break
            else
              table.insert(newVirtText, chunk)
              last_line_width = last_line_width + text_width
            end
          end
        end
      end
    end
  end
  -- Add fold line count suffix
  table.insert(newVirtText, { suffix, "MoreMsg" })
  return newVirtText
end

return M
