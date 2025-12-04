local ls = require("luasnip")
local s = ls.snippet
-- local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("lua", {
  s(
    "autocmd",
    fmt(
      [[
    vim.api.nvim_create_autocmd("{event}", {{
      pattern = "{pattern}",
      callback = function()
        {body}
      end,
    }})
  ]],
      {
        event = i(1, "ColorScheme"),
        pattern = i(2, "*"),
        body = i(0),
      }
    )
  ),
})
