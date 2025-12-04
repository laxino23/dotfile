return {
  name = "cpp: compile and run",
  builder = function(params)
    local file = vim.fn.expand("%:p")
    local file_name = vim.fn.expand("%:t:r")
    local output = params.output or file_name
    local std = params.std or "c++17"

    local compile_args = {
      file,
      "-o",
      output,
      "-std=" .. std,
      "-Wall",
      "-Wextra",
    }

    if params.optimization then
      table.insert(compile_args, "-" .. params.optimization)
    end

    if params.debug then
      table.insert(compile_args, "-g")
    end

    return {
      cmd = { params.compiler or "g++" },
      args = compile_args,
      components = {
        { "on_output_quickfix", open = true },
        "on_result_diagnostics",
        {
          "on_complete_callback",
          on_complete = function(task, status)
            if status == "SUCCESS" then
              vim.notify("编译成功! 运行程序...", vim.log.levels.INFO)
              local run_task = require("overseer").new_task({
                cmd = { "./" .. output },
                args = params.run_args or {},
                components = { "default" },
              })
              run_task:start()
            end
          end,
        },
        "default",
      },
    }
  end,
  params = {
    compiler = {
      type = "string",
      default = "g++",
      optional = true,
      desc = "Compiler (g++, clang++, etc.)",
    },
    output = {
      type = "string",
      default = "",
      optional = true,
      desc = "Output executable name",
    },
    std = {
      type = "string",
      default = "c++17",
      optional = true,
      desc = "C++ standard (c++11, c++14, c++17, c++20)",
    },
    optimization = {
      type = "enum",
      choices = { "O0", "O1", "O2", "O3", "Os" },
      default = "O2",
      optional = true,
      desc = "Optimization level",
    },
    debug = {
      type = "boolean",
      default = false,
      optional = true,
      desc = "Include debug symbols",
    },
    run_args = {
      type = "list",
      delimiter = " ",
      default = {},
      optional = true,
      desc = "Arguments to pass when running",
    },
  },
  condition = {
    filetype = { "cpp", "c" },
  },
}
