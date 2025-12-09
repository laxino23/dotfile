local icons = require "config.ui.icons"

return {
    nvim_web_devicons = {
        opts = {},
    },

    nui_nvim = {
        config = function()
            -- Helper function to format prompt text
            -- 辅助函数：格式化提示文本
            local function get_prompt_text(prompt, default_prompt)
                local prompt_text = prompt or default_prompt
                -- Remove trailing colon and add spacing
                -- 移除末尾的冒号并添加空格
                if prompt_text:sub(-1) == ":" then
                    prompt_text = " " .. prompt_text:sub(1, -2) .. " "
                end
                return prompt_text
            end

            -- Import nui.nvim components
            -- 导入 nui.nvim 组件
            local Input = require("nui.input")
            local Menu = require("nui.menu")
            local Text = require("nui.text")
            local event = require("nui.utils.autocmd").event

            -- 1. Override vim.ui.input (used for LSP rename, search & replace, etc.)
            -- 1. 覆盖 vim.ui.input（用于 LSP 重命名、搜索替换等）
            local function override_ui_input()
                -- Calculate popup width based on prompt and default value length
                -- 根据提示和默认值长度计算弹窗宽度
                local calculate_popup_width = function(default, prompt)
                    local result = 40
                    if prompt ~= nil then
                        result = #prompt + 40
                    end
                    if default ~= nil then
                        if #default + 40 > result then
                            result = #default + 40
                        end
                    end
                    return result
                end
                
                -- Extend nui.input to create custom UIInput class
                -- 扩展 nui.input 创建自定义 UIInput 类
                local UIInput = Input:extend("UIInput")
                function UIInput:init(opts, on_done)
                    -- Clean prompt text and get default value
                    -- 清理提示文本并获取默认值
                    local border_top_text = get_prompt_text(string.gsub(opts.prompt, "\n", ""), "Input")
                    local default_value = opts.default and tostring(string.gsub(opts.default, "\n", "")) or ""

                    -- Initialize parent Input with popup configuration
                    -- 使用弹窗配置初始化父类 Input
                    UIInput.super.init(self, {
                        relative = "cursor",  -- Position relative to cursor
                        position = { row = 2, col = 1 },  -- Offset from cursor
                        size = {
                            width = calculate_popup_width(default_value, border_top_text),
                        },
                        border = {
                            highlight = "FloatBorder",  -- Border highlight group
                            style = "rounded",  -- Rounded corners
                            text = {
                                top = Text(border_top_text, "FloatTitle"),  -- Title text
                                top_align = "center",  -- Center-aligned title
                            },
                        },
                        win_options = {
                            -- Apply floating window highlight groups
                            -- 应用浮动窗口高亮组
                            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
                        },
                    }, {
                        prompt = icons.common.separator .. " ",  -- Input prompt symbol
                        default_value = default_value,
                        on_close = function() on_done(nil) end,  -- Cancel callback
                        on_submit = function(value) on_done(value) end,  -- Submit callback
                    })

                    -- Close popup when buffer loses focus (e.g., mouse click away)
                    -- 当缓冲区失去焦点时关闭弹窗（如鼠标点击其他地方）
                    self:on(event.BufLeave, function() on_done(nil) end, { once = true })
                    -- Close popup on Escape key
                    -- 按 Escape 键关闭弹窗
                    self:map("n", "<Esc>", function() on_done(nil) end, { noremap = true, nowait = true })
                end

                -- Track current input UI instance to prevent multiple overlapping popups
                -- 追踪当前输入 UI 实例以防止多个弹窗重叠
                local input_ui
                vim.ui.input = function(opts, on_confirm)
                    assert(type(on_confirm) == "function", "missing on_confirm function")
                    -- Prevent opening multiple input popups simultaneously
                    -- 防止同时打开多个输入弹窗
                    if input_ui then
                        return
                    end
                    input_ui = UIInput(opts, function(value)
                        if input_ui then input_ui:unmount() end
                        on_confirm(value)
                        input_ui = nil
                    end)
                    input_ui:mount()
                end
            end

            -- 2. Override vim.ui.select (used for code actions, LSP selection menus, etc.)
            -- 2. 覆盖 vim.ui.select（用于代码操作、LSP 选择菜单等）
            local function override_ui_select()
                -- Helper function to control cursor visibility in menu
                -- 辅助函数：控制菜单中光标的可见性
                local function set_cursor_blend(blend)
                    vim.cmd("hi Cursor blend=" .. (tonumber(blend) or 0))
                end
                
                -- Extend nui.menu to create custom UISelect class
                -- 扩展 nui.menu 创建自定义 UISelect 类
                local UISelect = Menu:extend("UISelect")
                function UISelect:init(items, opts, on_done)
                    -- Get prompt text and menu configuration
                    -- 获取提示文本和菜单配置
                    local border_top_text = get_prompt_text(opts.prompt, "Select Item")
                    local kind = opts.kind or "unknown"  -- Menu kind (e.g., "codeaction")
                    local format_item = opts.format_item or function(item) return tostring(item.__raw_item or item) end

                    -- Basic popup configuration (centered in editor by default)
                    -- 基本弹窗配置（默认在编辑器中居中）
                    local popup_options = {
                        relative = "editor",  -- Position relative to entire editor
                        position = "50%",  -- Center position
                        border = {
                            highlight = "FloatBorder",
                            style = "rounded",
                            text = {
                                top = Text(border_top_text, "FloatTitle"),
                                top_align = "center",
                            },
                        },
                        win_options = {
                            -- Highlight current selection with Visual highlight
                            -- 使用 Visual 高亮当前选中项
                            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual",
                        },
                        zindex = 999,  -- Ensure menu appears on top
                    }

                    -- For code actions, show menu near cursor instead of center
                    -- 对于代码操作，在光标附近显示菜单而不是居中
                    if kind == "codeaction" then
                        popup_options.relative = "cursor"
                        popup_options.position = { row = 2, col = 1 }
                    end

                    -- Calculate max dimensions based on relative positioning
                    -- 根据相对定位计算最大尺寸
                    local max_width = popup_options.relative == "editor" and vim.o.columns - 4 or vim.api.nvim_win_get_width(0) - 4
                    local max_height = popup_options.relative == "editor" and math.floor(vim.o.lines * 80 / 100) or vim.api.nvim_win_get_height(0)

                    -- Build menu items list
                    -- 构建菜单项列表
                    local menu_items = {}
                    for index, item in ipairs(items) do
                        -- Normalize item to table format
                        -- 将项目标准化为表格式
                        if type(item) ~= "table" then item = { __raw_item = item } end
                        item.index = index
                        -- Truncate text if exceeds max width
                        -- 如果超过最大宽度则截断文本
                        local item_text = string.sub(format_item(item), 0, max_width)
                        table.insert(menu_items, Menu.item(item_text, item, { hl_group = "NormalFloat" }))
                    end

                    -- Menu-specific options
                    -- 菜单特定选项
                    local menu_options = {
                        min_width = vim.api.nvim_strwidth(border_top_text),
                        max_width = max_width,
                        max_height = max_height,
                        lines = menu_items,
                        on_close = function() on_done(nil, nil) end,  -- Cancel callback
                        on_submit = function(item) on_done(item.__raw_item or item, item.index) end,  -- Selection callback
                    }

                    -- Initialize parent Menu with configurations
                    -- 使用配置初始化父类 Menu
                    UISelect.super.init(self, popup_options, menu_options)
                    -- Close menu when buffer loses focus and restore cursor
                    -- 当缓冲区失去焦点时关闭菜单并恢复光标
                    self:on(event.BufLeave, function()
                        on_done(nil, nil)
                        set_cursor_blend(0)  -- Make cursor visible again
                    end, { once = true })
                end

                -- Track current select UI instance to prevent multiple overlapping menus
                -- 追踪当前选择 UI 实例以防止多个菜单重叠
                local select_ui
                vim.ui.select = function(items, opts, on_choice)
                    assert(type(on_choice) == "function", "missing on_choice function")
                    -- Prevent opening multiple selection menus simultaneously
                    -- 防止同时打开多个选择菜单
                    if select_ui then return end
                    select_ui = UISelect(items, opts, function(item, index)
                        if select_ui then select_ui:unmount() end
                        on_choice(item, index)
                        select_ui = nil
                    end)
                    select_ui:mount()
                    set_cursor_blend(100)  -- Hide cursor inside menu for cleaner look
                end
            end

            -- Execute both overrides to enhance Neovim's UI
            -- 执行两个覆盖以增强 Neovim 的 UI
            override_ui_input()
            override_ui_select()
    end,
},}

-- vim: foldmethod=indent foldlevel=1}
