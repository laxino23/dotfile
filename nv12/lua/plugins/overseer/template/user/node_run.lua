return {
  name = "node: run file",
  builder = function(params)
    local file = vim.fn.expand("%:p")
    local args = { file }

    if params.args then
      vim.list_extend(args, params.args)
    end

    return {
      cmd = { params.runtime or "node" },
      args = args,
      components = {
        { "on_output_quickfix", open = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  params = {
    runtime = {
      type = "string",
      default = "node",
      optional = true,
      desc = "Runtime (node, bun, deno)",
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
    filetype = { "javascript", "typescript" },
  },
}
