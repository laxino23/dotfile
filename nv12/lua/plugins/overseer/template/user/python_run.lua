return {
  name = "python: run file",
  builder = function(params)
    local file = vim.fn.expand("%:p")
    local args = { file }

    if params.args then
      vim.list_extend(args, params.args)
    end

    return {
      cmd = { params.interpreter or "python3" },
      args = args,
      components = {
        { "on_output_quickfix", open = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  params = {
    interpreter = {
      type = "string",
      default = "python3",
      optional = true,
      desc = "Python interpreter (python3, python, etc.)",
    },
    args = {
      type = "list",
      delimiter = " ",
      default = {},
      optional = true,
      desc = "Arguments to pass to the script",
    },
  },
  condition = {
    filetype = { "python" },
  },
}
