return {
  name = "rust: cargo test",
  builder = function(params)
    local args = { "test" }

    if params.release then
      table.insert(args, "--release")
    end

    if params.test_name and params.test_name ~= "" then
      table.insert(args, params.test_name)
    end

    if params.nocapture then
      table.insert(args, "--")
      table.insert(args, "--nocapture")
    end

    return {
      cmd = { "cargo" },
      args = args,
      components = {
        { "on_output_quickfix", open = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  params = {
    release = {
      type = "boolean",
      default = false,
      optional = true,
      desc = "Use release mode",
    },
    test_name = {
      type = "string",
      default = "",
      optional = true,
      desc = "Specific test name to run",
    },
    nocapture = {
      type = "boolean",
      default = false,
      optional = true,
      desc = "Show println! output",
    },
  },
  condition = {
    filetype = { "rust" },
  },
}
