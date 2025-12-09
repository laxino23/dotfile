local M = {}

--- Opens an FZF picker to select a running system process.
--- Designed to be used as a custom `pickProcess` handler in nvim-dap.
--- NOTE: This must be called within a coroutine (which nvim-dap does automatically).
M.fzf_process_picker = function()
    -- Get the list of all system processes using nvim-dap's utility
    local process_list = require("dap.utils").get_processes()
    local items = {}
    local processes = {}

    -- Format the process list for display (PID: Name)
    for _, p in pairs(process_list) do
        local display = string.format("%d: %s", p.pid, p.name)
        table.insert(items, display)
        -- Map the display string back to the PID for retrieval later
        processes[display] = p.pid
    end

    -- Get the current coroutine (nvim-dap runs this function inside one)
    local co = coroutine.running()
    
    if co then
        -- Open FZF Lua to pick a process
        require("fzf-lua").fzf_exec(items, {
            prompt = "Select process> ",
            actions = {
                ["default"] = function(selected)
                    -- This callback runs when the user selects an item
                    if #selected > 0 then
                        local pid = processes[selected[1]]
                        -- Resume the paused DAP coroutine with the selected PID
                        coroutine.resume(co, pid)
                    else
                        -- Resume with nil if nothing valid was selected
                        coroutine.resume(co, nil)
                    end
                end,
            },
        })
        -- Pause execution here and wait for the user to pick an item in FZF.
        -- The coroutine.resume() above will restart execution from this point.
        return coroutine.yield()
    else
        print("Error: Failed to create coroutine. This function must be run inside a dap configuration context.")
        return nil
    end
end

--- Scans the current directory for local DAP configuration files
--- and loads them, effectively enabling project-specific debug settings.
M.dap_local = function()
    -- Priority list of config files to look for
    local config_paths = { "./.nvim-dap/nvim-dap.lua", "./.nvim-dap.lua", "./.nvim/nvim-dap.lua" }
    
    -- Safety check: ensure nvim-dap is actually installed
    if not pcall(require, "dap") then
        vim.notify("Not found DAP plugin!", vim.log.levels.ERROR, {
            title = "My IDE",
        })
        return
    end

    local project_config = ""
    -- Loop through paths to find the first existing config file
    for _, p in ipairs(config_paths) do
        local f = io.open(p)
        if f ~= nil then
            f:close()
            project_config = p
            break
        end
    end

    -- If no local config is found, notify the user and exit
    if project_config == "" then
        vim.notify(
            "You can define DAP configuration in './.nvim-dap/nvim-dap.lua', './.nvim-dap.lua', './.nvim/nvim-dap.lua'",
            vim.log.levels.INFO,
            {
                title = "My IDE",
            }
        )
        return
    end

    vim.notify("Found DAP configuration at " .. project_config, vim.log.levels.INFO, {
        title = "My IDE",
    })

    -- Clear existing global DAP adapters and configurations.
    -- This prevents old configs from other projects polluting the current session.
    require("dap").adapters = (function()
        return {}
    end)()
    
    require("dap").configurations = (function()
        return function() end -- Reset configurations to an empty state
    end)()

    -- Source the found local configuration file
    vim.cmd(":luafile " .. project_config)
end

return M
