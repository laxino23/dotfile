-- 注意路径修正：引用同级目录下的 layouts.lua
local ui = require("plugins.snacks.layouts")
-- 引用全局配置下的 ui.lua
local icons = require("config.ui")

return {
  enabled = true,
  prompt = " ",
  ui_select = true,

  -- 布局引用
  layout = {
    cycle = false,
    layout = ui.dropdown.layout,
  },

  matcher = {
    cwd_bonus = true,
    frecency = true,
    history_bonus = true,
  },

  formatters = {
    file = {
      filename_first = true,
      truncate = 60,
    },
    severity = {
      icons = true,
      level = true,
      pos = "left",
    },
  },

  -- 窗口内按键 (Input/List)
  win = {
    input = {
      keys = {
        ["<Esc>"] = { "close", mode = { "n", "i" } },
        ["<a-s>"] = { "flash", mode = { "n", "i" } },
        ["s"] = { "flash" },
      },
    },
    list = {
      keys = {
        ["<c-j>"] = "list_down",
        ["<c-k>"] = "list_up",
        ["<c-n>"] = "list_down",
        ["<c-p>"] = "list_up",
        -- Send results to Trouble / 将结果发送到 Trouble
        ["<c-t>"] = "trouble_open",
      },
    },
  },
  actions = {
    -- Define the custom Flash action
    -- 定义自定义 Flash 动作
    flash = function(picker)
      require("flash").jump({
        pattern = "^",
        label = { after = { 0, 0 } },
        search = {
          mode = "search",
          exclude = {
            function(win)
              return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
            end,
          },
        },
        action = function(match)
          -- Select item after jump / 跳转后选中
          local idx = picker.list:row2idx(match.pos[1])
          picker.list:_move(idx, true, true)
        end,
      })
    end,
  },
  -- 图标
  icons = {
    kinds = icons.icons.lspkind_kind_icons,
  },
}
