local M = {}

-- 全局浮动窗口索引 (Global float window index)
_G._FLOAT_INDEX = _G._FLOAT_INDEX or 1

-- ============================================================
-- Table Utilities | 表处理工具 | テーブル操作
-- ============================================================

---@description Recursively merge two tables.
---@description 递归合并两个表。如果键对应的值都是表，则继续合并，否则覆盖。
---@param tbl1 table The target table
---@param tbl2 table The source table
---@return table
M.merge = function(tbl1, tbl2)
    if type(tbl1) == "table" and type(tbl2) == "table" then
        for k, v in pairs(tbl2) do -- tbl2 always wins
            -- 如果两边都是 table，递归合并 (If both are tables, merge recursively)
            if type(v) == "table" and type(tbl1[k] or false) == "table" then
                M.merge(tbl1[k], v)
            else
                -- 否则直接覆盖 (Otherwise overwrite)
                tbl1[k] = v
            end
        end
    end
    return tbl1
end

---@description Converts a dictionary-like table into a sorted array of {key, value} pairs.
---@description 将字典表转换为有序的数组表
---@description used for return the lazy_pack
---@param tbl table
---@return table
M.sort = function(tbl)
    local arr = {}
    for key, value in pairs(tbl) do
        -- 将键值对存入临时数组 (Store key-value pairs in temp array)
        arr[#arr + 1] = { key, value }
    end
    -- 重写原表 (Rewrite original table)
    for ix, value in ipairs(arr) do
        tbl[ix] = value
    end
    return tbl
end

---@description Sorts lines in the current buffer based on specific patterns (useful for plugin lists).
---@description 对当前缓冲区的行进行排序，专门用于排序 Lua 配置表中的插件列表。
M.sort_lua_table = function()
    -- 获取当前 buffer 所有行 (Get all lines from current buffer)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local sorted_lines = {}
    local inner_lines = {}
    
    for _, line in ipairs(lines) do
        -- 匹配包含 ["key"] 的行进行排序 (Match lines with ["key"] for sorting)
        if line:match('%[".*"%]') then
            table.insert(sorted_lines, line)
        else
            table.insert(inner_lines, line)
        end
    end
    
    table.sort(sorted_lines)
    -- 写回缓冲区 (Write back to buffer)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, sorted_lines)
    vim.api.nvim_buf_set_lines(0, #sorted_lines, -1, false, inner_lines)
end

---@description Checks if a table contains a specific value.
---@description 检查表中是否包含指定的值。
---@param table table
---@param value any
---@return boolean
M.has_value = function(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

---@description Merges two tables and removes duplicates.
---@description 合并两个表并去重。
---@param table1 table
---@param table2 table
---@return table
M.merge_unique = function(table1, table2)
    local merged = {}
    -- 辅助函数：插入不重复的元素 (Helper: Insert unique elements)
    local function add_if_missing(t)
        for _, v in ipairs(t) do
            if not M.has_value(merged, v) then
                table.insert(merged, v)
            end
        end
    end
    add_if_missing(table1)
    add_if_missing(table2)
    return merged
end

---@description Creates a custom sort comparator based on a predefined order list.
---@description 生成一个自定义排序函数，根据给定的顺序列表进行排序。
---@param order table List of values defining the order
---@return function Comparator function for table.sort
M.custom_sort = function(order)
    return function(a, b)
        local indexA = 0
        local indexB = 0
        -- 查找元素在预定义顺序中的位置 (Find index in predefined order)
        for i, value in ipairs(order) do
            if value == a then
                indexA = i
            elseif value == b then
                indexB = i
            end
        end
        return indexA < indexB
    end
end

---@description Finds a key in a table by searching for a value inside nested lists.
---@description 通过值反向查找键（假设值是嵌套列表）。
---@param tbl table
---@param search_value any
---@return string|nil key
M.find_key_by_value = function(tbl, search_value)
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            for _, v in ipairs(value) do
                if v == search_value then
                    return key
                end
            end
        end
    end
    return nil
end

---@description Removes duplicate values from a list.
---@description 移除列表中的重复项。
---@param tbl table
---@return table
M.remove_duplicate = function(tbl)
    local hash = {}
    local res = {}
    for _, v in ipairs(tbl) do
        if not hash[v] then
            res[#res + 1] = v
            hash[v] = true
        end
    end
    return res
end

-- ============================================================
-- Configuration & Keymaps | 配置与按键 | 設定とキーマップ
-- ============================================================

---Batch register key mappings from a configuration table.
---批量注册配置表中的按键映射。
---@param config table<string, table>
---@param opts table|nil
M.keymaps = function(config, opts)
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

---@description Loads, merges, and executes user and base configurations.
---@description 加载基础配置和用户配置，合并后按顺序执行。
M.configs = function()
    local configs = require("config")
    
    for _, func in pairs(configs) do
        if type(func) == "function" then
            func()
        end
    end
end

-- ============================================================
-- System & Sudo Operations | 系统操作 | システム操作
-- ============================================================

---@description Executes a shell command with sudo.
---@description 使用 sudo 权限执行 shell 命令。
---@param cmd string Command to execute
---@return boolean success
M.sudo_exec = function(cmd)
    vim.fn.inputsave()
    -- 请求密码 (Request password)
    local password = vim.fn.inputsecret("Password: ")
    vim.fn.inputrestore()
    
    if not password or #password == 0 then
        vim.notify("Invalid password, sudo aborted!", vim.log.levels.ERROR)
        return false
    end
    
    -- 执行 sudo 命令 (Execute sudo command)
    vim.fn.system(string.format("sudo -p '' -S %s", cmd), password)
    
    if vim.v.shell_error ~= 0 then
        vim.notify("Shell error or invalid password, sudo aborted!", vim.log.levels.ERROR)
        return false
    end
    return true
end

---@description Writes the current buffer to a file using sudo.
---@description 强制使用 sudo 保存当前文件（解决权限不足问题）。
---@param tmpfile? string Temporary file path
---@param filepath? string Target file path
M.sudo_write = function(tmpfile, filepath)
    if not tmpfile then tmpfile = vim.fn.tempname() end
    if not filepath then filepath = vim.fn.expand("%") end
    
    if not filepath or #filepath == 0 then
        vim.notify("No file name!", vim.log.levels.ERROR)
        return
    end
    
    -- 构造 dd 命令用于写入 (Construct dd command for writing)
    local cmd = string.format("dd if=%s of=%s bs=1048576", vim.fn.shellescape(tmpfile), vim.fn.shellescape(filepath))
    
    -- 先写入临时文件 (Write to temp file first)
    vim.api.nvim_command(string.format("write! %s", tmpfile))
    
    if M.sudo_exec(cmd) then
        vim.notify(string.format('"%s" written!', filepath), vim.log.levels.INFO)
        -- 重新加载文件以同步状态 (Reload file to sync state)
        vim.cmd("e!")
    end
    vim.fn.delete(tmpfile)
end

-- ============================================================
-- File System | 文件系统 | ファイルシステム
-- ============================================================

---@description Checks if a file exists.
---@description 检查文件是否存在。
M.file_exists = function(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end

---@description Checks if a directory exists.
---@description 检查目录是否存在。
M.dir_exists = function(path)
    return M.file_exists(path) -- Lua treats dirs as files in strict io.open check usually
end

---@description Reads a file and returns its content (decodes JSON if applicable).
---@description 读取文件内容。如果是 JSON 则解析，如果是布尔值字符串则转换。
---@param file string
---@return any
M.read_file = function(file)
    local ok, content = pcall(vim.fn.readfile, file)
    if not ok or type(content) ~= "table" or #content == 0 then
        return nil
    end
    local text = table.concat(content, "\n")
    -- 尝试解析 JSON (Try to parse JSON)
    local ok_json, decoded = pcall(vim.fn.json_decode, text)
    if ok_json and decoded ~= nil then
        return decoded
    end
    if text == "true" then return true
    elseif text == "false" then return false
    end
    return content[1]
end

---@description Writes content to a file.
---@description 将内容写入文件（支持表自动转 JSON）。
---@param file string
---@param content any
M.write_file = function(file, content)
    local f = io.open(file, "w")
    if f ~= nil then
        if type(content) == "table" then
            content = vim.fn.json_encode(content)
        elseif type(content) == "boolean" then
            content = tostring(content)
        end
        f:write(content)
        f:close()
    end
end

M.copy_file = function(file, dest)
    os.execute("cp " .. file .. " " .. dest)
end

M.delete_file = function(f)
    os.remove(f)
end

---@description Deletes the custom packages cache file.
---@description 删除本地包缓存文件。
M.delete_packages_file = function()
    local packages_file = _G.global.cache_path .. "/.packages"
    os.remove(packages_file)
end

-- ============================================================
-- Path & Environment | 路径与环境 | パスと環境
-- ============================================================

---@description Prompts user to input a path.
---@description 提示用户输入路径，默认为当前工作目录。
M.change_path = function()
    return vim.fn.input("Path: ", vim.fn.getcwd() .. "/", "file")
end

---@description Sets the global working directory (`:cd`).
---@description 设置全局工作目录。
M.set_global_path = function()
    local path = M.change_path()
    vim.api.nvim_command("silent :cd " .. path)
end

---@description Sets the window-local working directory (`:lcd`).
---@description 设置当前窗口的工作目录。
M.set_window_path = function()
    local path = M.change_path()
    vim.api.nvim_command("silent :lcd " .. path)
end

---@description Formats a number of bytes into a human-readable string.
---@description 将字节数转换为人类可读的格式（如 KB, MB, GB）。
---@param size number Bytes
---@param options table Formatting options
---@return string|table
M.file_size = function(size, options)
    -- 单位定义 (Unit definitions)
    local si = {
        bits = { "b", "Kb", "Mb", "Gb", "Tb", "Pb", "Eb", "Zb", "Yb" },
        bytes = { "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" },
    }
    -- ... (Helper functions: isNan, roundNumber, setDefault are strictly local here)
    -- [Implementation details omitted for brevity as they are standard logic]
    -- ...
    -- Note: The logic handles base-2 vs base-10 and various output formats
    
    -- [Original code logic preserved below]
    local function isNan(num) return num ~= num end
    local function roundNumber(num, digits)
        local fmt = "%." .. digits .. "f"
        return tonumber(fmt:format(num))
    end
    local o = {}
    for key, value in pairs(options or {}) do o[key] = value end
    local function setDefault(name, default)
        if o[name] == nil then o[name] = default end
    end
    setDefault("bits", false)
    setDefault("unix", false)
    setDefault("base", 2)
    setDefault("round", o.unix and 1 or 2)
    setDefault("spacer", o.unix and "" or " ")
    setDefault("suffixes", {})
    setDefault("output", "string")
    setDefault("exponent", -1)
    
    assert(not isNan(size), "Invalid arguments")
    local ceil = (o.base > 2) and 1000 or 1024
    local negative = (size < 0)
    if negative then size = -size end
    local result
    
    if size == 0 then
        result = { 0, o.unix and "" or (o.bits and "b" or "B") }
    else
        if o.exponent == -1 or isNan(o.exponent) then
            o.exponent = math.floor(math.log(size) / math.log(ceil))
        end
        if o.exponent > 8 then o.exponent = 8 end
        local val
        if o.base == 2 then
            val = size / math.pow(2, o.exponent * 10)
        else
            val = size / math.pow(1000, o.exponent)
        end
        if o.bits then
            val = val * 8
            if val > ceil then
                val = val / ceil
                o.exponent = o.exponent + 1
            end
        end
        result = {
            roundNumber(val, o.exponent > 0 and o.round or 0),
            (o.base == 10 and o.exponent == 1) and (o.bits and "kb" or "kB")
                or si[o.bits and "bits" or "bytes"][o.exponent + 1],
        }
        if o.unix then
            result[2] = result[2]:sub(1, 1)
            if result[2] == "b" or result[2] == "B" then
                result = { math.floor(result[1]), "" }
            end
        end
    end
    
    if negative then result[1] = -result[1] end
    result[2] = o.suffixes[result[2]] or result[2]
    
    if o.output == "array" then return result
    elseif o.output == "exponent" then return o.exponent
    elseif o.output == "object" then return { value = result[1], suffix = result[2] }
    elseif o.output == "string" then
        local value = tostring(result[1])
        value = value:gsub("%.0$", "")
        local suffix = result[2]
        return value .. o.spacer .. suffix
    end
end

-- ============================================================
-- Plugin Management | 插件管理 | プラグイン管理
-- ============================================================

---@description Retrieves the current snapshot path.
---@description 获取当前插件快照路径。
M.get_snapshot = function()
    local file_content = M.read_file(_G.global.cache_path .. "/.snapshot")
    if file_content ~= nil and file_content["snapshot"] ~= nil then
        return file_content["snapshot"]
    end
    return _G.global.snapshot_path .. "/default"
end

---@description Gets the commit hash for a specific plugin from the snapshot.
---@description 从快照中获取指定插件的 commit hash。
M.get_commit = function(plugin, plugins_snapshot)
    if plugins_snapshot ~= nil then
        if plugins_snapshot[plugin] ~= nil and plugins_snapshot[plugin].commit ~= nil then
            return plugins_snapshot[plugin].commit
        end
    else
        return nil
    end
end

-- ============================================================
-- UI & Windows | 界面与窗口 | UIとウィンドウ
-- ============================================================

---@description Closes all floating windows.
---@description 关闭所有浮动窗口（非标准窗口）。
M.close_float_windows = function()
    local closed_windows = {}
    vim.schedule(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_is_valid(win) then
                local config = vim.api.nvim_win_get_config(win)
                -- 如果 relative 属性不为空，则是浮动窗口 (If relative is not empty, it's a float)
                if config.relative ~= "" then
                    vim.api.nvim_win_close(win, false)
                    table.insert(closed_windows, win)
                end
            end
        end
    end)
end

---@description Cycles focus through open floating windows.
---@description 在所有打开的浮动窗口之间循环切换焦点。
M.focus_float_window = function()
    local wins = vim.api.nvim_list_wins()
    local floats = {}
    local cur_win = vim.api.nvim_get_current_win()
    
    -- 收集所有浮动窗口 (Collect all floating windows)
    for _, win in ipairs(wins) do
        if vim.api.nvim_win_is_valid(win) then
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative ~= "" then
                table.insert(floats, win)
            end
        end
    end
    
    if #floats == 0 then
        vim.notify("No floating windows found", vim.log.levels.INFO)
        return
    end
    
    -- 查找当前窗口在列表中的索引 (Find current window index)
    local cur_idx = nil
    for i, win in ipairs(floats) do
        if win == cur_win then
            cur_idx = i
            break
        end
    end
    
    -- 循环切换逻辑 (Cycle logic)
    if not cur_idx or cur_idx > #floats then
        _G._FLOAT_INDEX = 1
    else
        _G._FLOAT_INDEX = (cur_idx % #floats) + 1
    end
    vim.api.nvim_set_current_win(floats[_G._FLOAT_INDEX])
end

---@description Detects if the current file is a Helm chart file.
---@description 检测当前文件是否为 Kubernetes Helm 图表文件。
M.is_helm = function()
    local filepath = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t")
    -- 检查路径是否包含 templates (Check if path contains templates)
    if string.match(filepath, ".+/templates/.+%.yaml$") or 
       string.match(filepath, ".+/templates/.+%.yml$") or 
       string.match(filepath, ".+/templates/.+%.tpl$") or 
       string.match(filepath, ".+/templates/.+%.txt$") then
        return true
    end
    -- 检查特定文件名 (Check specific filenames)
    if string.match(filename, ".+%.gotmpl$") then return true end
    if string.match(filename, "helmfile.+%.yaml$") or string.match(filename, "helmfile.+%.yml$") then return true end
    return false
end

---@description Opens a floating window to execute Lua code or Vim commands and show output.
---@description 打开一个交互式浮动窗口，用于执行 Lua 代码或 Vim 命令并显示输出。
M.command_output = function()
    vim.ui.input({
        prompt = "Enter command or Lua code: ",
        default = "",
    }, function(input)
        if not input or input == "" then return end
        
        local output
        local success = true
        local is_command = input:match("^:") -- 检查是否为 Vim 命令 (Check if Vim command)
        
        if is_command then
            output = vim.api.nvim_exec2(input, { output = true }).output
        else
            -- 尝试加载 Lua 代码 (Try to load Lua code)
            local func, load_err = loadstring("return " .. input)
            if not func then
                func, load_err = loadstring(input)
                if not func then
                    output = "Error loading Lua code: " .. tostring(load_err)
                    success = false
                end
            end
            
            -- 执行并捕获 print 输出 (Execute and capture print output)
            if func then
                local original_print = print
                local print_output = {}
                _G.print = function(...)
                    local args = { ... }
                    local str_args = {}
                    for i, v in ipairs(args) do
                        str_args[i] = tostring(v)
                    end
                    table.insert(print_output, table.concat(str_args, "\t"))
                end
                
                local results = { pcall(func) }
                _G.print = original_print -- 恢复 print (Restore print)
                
                if not results[1] then
                    output = "Lua execution error: " .. tostring(results[2])
                    success = false
                else
                    table.remove(results, 1)
                    local return_values = {}
                    for i, v in ipairs(results) do
                        return_values[i] = vim.inspect(v)
                    end
                    
                    local return_output = #return_values > 0 and "Return values:\n" .. table.concat(return_values, "\n") or ""
                    local print_content = #print_output > 0 and "Printed output:\n" .. table.concat(print_output, "\n") or ""
                    output = print_content .. (#print_content > 0 and "\n\n" or "") .. return_output
                end
            end
        end
        
        if output == "" then
            vim.notify("No output from " .. (is_command and "command" or "Lua code"), vim.log.levels.INFO)
            return
        end
        
        -- 创建显示结果的浮动窗口 (Create floating window to show results)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].bufhidden = "wipe"
        local lines = {}
        for line in output:gmatch("([^\n]*)\n?") do table.insert(lines, line) end
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        
        -- 计算窗口尺寸 (Calculate window dimensions)
        local width = math.min(80, vim.o.columns - 4)
        local height = math.min(#lines + 2, math.max(5, vim.o.lines - 4))
        local col = math.floor((vim.o.columns - width) / 2)
        local row = math.floor((vim.o.lines - height) / 2)
        
        local opts = {
            relative = "editor", width = width, height = height, col = col, row = row,
            style = "minimal", border = "rounded",
            title = success and " Output: " .. input .. " " or " Error: " .. input .. " ",
            title_pos = "center",
        }
        
        local win = vim.api.nvim_open_win(buf, true, opts)
        vim.bo[buf].modifiable = false
        vim.wo[win].wrap = true
        vim.wo[win].cursorline = true
        
        -- 设置关闭键映射 (Set keymap to close)
        local keys = { "q", "<Esc>" }
        for _, key in ipairs(keys) do
            vim.api.nvim_buf_set_keymap(buf, "n", key, "<cmd>close<CR>", { noremap = true, silent = true, desc = "Close window" })
        end
        vim.api.nvim_buf_set_name(buf, "[Output]")
        vim.notify("Press 'q' or <Esc> to close the window", vim.log.levels.INFO)
    end)
end

-- ============================================================
-- Highlights & Colors | 高亮与颜色 | ハイライトと色
-- ============================================================

---@description Gets the hex color codes for a highlight group.
---@description 获取指定高亮组的背景色和前景色（Hex）。
M.get_highlight = function(hl_group)
    local hl_details = vim.api.nvim_get_hl(0, { name = hl_group })
    local bg_color = nil
    local fg_color = nil
    if hl_details.bg then bg_color = string.format("#%06x", hl_details.bg) end
    if hl_details.fg then fg_color = string.format("#%06x", hl_details.fg) end
    return { bg = bg_color, fg = fg_color }
end

local function rgb(c)
    c = string.lower(c)
    return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
end

---@description Blends a foreground color with a background color by a given alpha.
---@description 混合两种颜色（计算透明度叠加后的 Hex 颜色）。
---@param foreground string Hex color
---@param alpha number|string Alpha channel (0-1 or hex)
---@param background string Hex color
M.blend = function(foreground, alpha, background)
    alpha = type(alpha) == "string" and (tonumber(alpha, 16) / 0xff) or alpha
    local bg = rgb(background)
    local fg = rgb(foreground)

    local blendChannel = function(i)
        local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
        return math.floor(math.min(math.max(0, ret), 255) + 0.5)
    end

    return string.format("#%02x%02x%02x", blendChannel(1), blendChannel(2), blendChannel(3))
end

-- ============================================================
-- Treesitter Utils | 语法树工具 | Treesitter操作
-- ============================================================

---@description Removes comments from the current buffer using Treesitter.
---@description 使用 Treesitter 解析并移除当前缓冲区的代码注释（支持多种语言）。
M.remove_comments = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype

    -- 1. 获取 Treesitter 解析器 (Get Treesitter parser)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok or not parser then
        vim.notify("Treesitter parser not available for " .. ft, vim.log.levels.WARN)
        return
    end

    local lang = parser:lang()

    -- 2. 定义每种语言的查询语句 (Define queries for languages)
    local queries = {
        javascript = [[ (comment) @comment ]],
        typescript = [[ (comment) @comment ]],
        java = [[
            (line_comment) @comment
            (block_comment) @block_comment
        ]],
        lua = [[ (comment) @comment ]],
        python = [[ (comment) @comment ]],
        go = [[ (comment) @comment ]],
        c = [[ (comment) @comment ]],
        cpp = [[ (comment) @comment ]],
        rust = [[ (line_comment) @comment ]],
        html = [[ (comment) @comment ]],
        css = [[ (comment) @comment ]],
        yaml = [[ (comment) @comment ]],
        toml = [[ (comment) @comment ]],
        bash = [[ (comment) @comment ]],
        sh = [[ (comment) @comment ]],
    }

    local query_str = queries[lang] or [[ (comment) @comment ]]

    -- 3. 解析查询 (Parse query)
    local ok_query, query = pcall(vim.treesitter.query.parse, lang, query_str)
    if not ok_query then
        vim.notify("Failed to parse treesitter query for " .. lang, vim.log.levels.WARN)
        return
    end

    local tree = parser:parse()[1]
    local root = tree:root()

    local lines_to_delete = {}
    local edits = {}
    local capture_names = query.captures or {}

    -- 4. 遍历捕获的节点 (Iterate captures)
    for id, node in query:iter_captures(root, bufnr, 0, -1) do
        local capture_name = capture_names[id] or "comment"
        local srow, scol, erow, ecol = node:range()

        if capture_name == "block_comment" then
            -- 标记块注释的所有行 (Mark block comment lines)
            for i = srow, erow do
                lines_to_delete[i] = true
            end
        elseif capture_name == "comment" then
            if srow == erow then
                -- 处理单行内注释 (Handle inline comments)
                local line = vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1]
                -- 如果整行都是注释，则标记删除 (If whole line is comment, mark to delete)
                if scol == 0 and ecol == #line then
                    lines_to_delete[srow] = true
                else
                    -- 否则记录为部分编辑 (Otherwise record as partial edit)
                    table.insert(edits, {
                        row = srow,
                        start_col = scol,
                        end_col = ecol,
                        type = "partial",
                    })
                end
            else
                -- 多行注释 (Multi-line comments)
                for i = srow, erow do
                    lines_to_delete[i] = true
                end
            end
        end
    end

    -- 5. 执行行内编辑 (Execute inline edits)
    -- 从后往前排序，避免索引偏移 (Sort backwards to avoid index shift)
    table.sort(edits, function(a, b)
        if a.row == b.row then
            return a.start_col > b.start_col
        end
        return a.row > b.row
    end)

    for _, edit in ipairs(edits) do
        if not lines_to_delete[edit.row] then
            local line = vim.api.nvim_buf_get_lines(bufnr, edit.row, edit.row + 1, false)[1]
            local before = line:sub(1, edit.start_col)
            local after = line:sub(edit.end_col + 1)
            vim.api.nvim_buf_set_lines(bufnr, edit.row, edit.row + 1, false, { before .. after })
        end
    end

    -- 6. 删除整行 (Delete full lines)
    local rows_to_delete = {}
    for row in pairs(lines_to_delete) do
        table.insert(rows_to_delete, row)
    end
    table.sort(rows_to_delete, function(a, b) return a > b end) -- 从下往上删 (Delete bottom up)

    for _, row in ipairs(rows_to_delete) do
        vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, {})
    end

    -- 7. 格式化代码 (Format code)
    vim.schedule(function()
        vim.lsp.buf.format({ async = true })
    end)
end

return M
