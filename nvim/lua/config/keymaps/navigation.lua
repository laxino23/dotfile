return function(map)
  -- =============================================================================
  -- Keymaps: Navigation / 映射：导航
  -- =============================================================================

  -- Standard Silent Maps
  map({
    -- Windows
    ["window-left"] = { "n", "<C-h>", "<C-w>h" },
    ["window-down"] = { "n", "<C-j>", "<C-w>j" },
    ["window-up"] = { "n", "<C-k>", "<C-w>k" },
    ["window-right"] = { "n", "<C-l>", "<C-w>l" },
    ["split-vertically"] = { { "n", "v" }, "<leader>sv", ":vsplit<CR>" },
    ["split-horizontally"] = { { "n", "v" }, "<leader>sh", ":split<CR>" },
    ["resize-left"] = { "n", "<C-Left>", ":vertical resize -2<CR>" },
    ["resize-right"] = { "n", "<C-Right>", ":vertical resize +2<CR>" },
    ["resize-up"] = { "n", "<C-Up>", ":resize +2<CR>" },
    ["resize-down"] = { "n", "<C-Down>", ":resize -2<CR>" },

    -- Buffers
    ["next-buffer"] = { "n", "<leader>bl", ":bnext<CR>" },
    ["prev-buffer"] = { "n", "<leader>bh", ":bprevious<CR>" },
    ["close-buffer"] = { "n", "<leader>bc", ":bdelete<CR>" },

    -- Quick Navigation
    ["start-of-line"] = { { "n", "v" }, "H", "^" },
    ["end-of-line"] = { { "n", "v" }, "L", "$" },

    -- Quickfix & Location Lists
    ["quickfix-next"] = { "n", "]q", ":cnext<CR>" },
    ["quickfix-prev"] = { "n", "[q", ":cprev<CR>" },
    ["location-next"] = { "n", "]l", ":lnext<CR>" },
    ["location-prev"] = { "n", "[l", ":lprev<CR>" },

    -- Clear Search
    ["clear-search-highlight"] = { "n", "<Esc>", ":noh<CR>" },
  }, { silent = true })

  -- Non-Silent Maps (Search & Replace)
  -- Passing silent = false inside the specific opts overrides the default { silent = true }
  -- 在特定选项中传递 silent = false 会覆盖默认的 { silent = true }
  map({
    ["search-and-replace"] = { "n", "<leader>sr", ":%s//g<Left><Left>", silent = false },
    ["search-and-replace-word"] = {
      "n",
      "<leader>sw",
      ":%s/<C-r><C-w>//g<Left><Left>",
      silent = false,
    },
  }, { silent = true })
end
