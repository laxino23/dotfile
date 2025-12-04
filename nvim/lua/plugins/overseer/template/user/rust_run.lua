return {
  name = "rust: cargo run",
  builder = function(params)
    local args = { "run" }

    -- 添加 release 模式
    if params.release then
      table.insert(args, "--release")
    end

    -- 添加 features
    if params.features and params.features ~= "" then
      table.insert(args, "--features")
      table.insert(args, params.features)
    end

    -- 添加 bin 目标
    if params.bin and params.bin ~= "" then
      table.insert(args, "--bin")
      table.insert(args, params.bin)
    end

    -- 分隔符
    table.insert(args, "--")

    -- 添加程序参数
    if params.args then
      for _, arg in ipairs(params.args) do
        table.insert(args, arg)
      end
    end

    return {
      cmd = { "cargo" },
      args = args,
      components = {
        { "on_output_quickfix", open = true, set_diagnostics = true },
        "on_result_diagnostics",
        { "on_complete_notify", statuses = { "FAILURE" } },
        "default",
      },
      cwd = vim.fn.getcwd(),
    }
  end,
  params = {
    release = {
      type = "boolean",
      default = false,
      optional = true,
      desc = "Build with release optimizations",
    },
    features = {
      type = "string",
      default = "",
      optional = true,
      desc = "Comma-separated list of features",
    },
    bin = {
      type = "string",
      default = "",
      optional = true,
      desc = "Name of the bin target to run",
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
    filetype = { "rust" },
    callback = function()
      return vim.fn.filereadable("Cargo.toml") == 1
    end,
  },
}
