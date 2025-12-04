return {
  name = "go: run",
  builder = function(params)
    local args = { "run" }

    if params.file then
      table.insert(args, vim.fn.expand("%:p"))
    else
      table.insert(args, ".")
    end

    if params.args then
      vim.list_extend(args, params.args)
    end

    return {
      cmd = { "go" },
      args = args,
      components = {
        { "on_output_quickfix", open = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  params = {
    file = {
      type = "boolean",
      default = false,
      optional = true,
      desc = "Run current file only",
    },
    args = {
      type = "list",
      delimiter = " ",
      default = {},
      optional = true,
      desc = "Arguments to pass to the program",
    },
  },
  condition = {
    filetype = { "go" },
  },
}
