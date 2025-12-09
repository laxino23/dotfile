local home = os.getenv("HOME")

local function getOS()
    if jit then
        return jit.os
    end
    local fh, _ = assert(io.popen("uname -o 1>/dev/null", "r"))
    if fh then
        Osname = fh:read()
    end
    return Osname or "Windows"
end

local os_name = getOS()
local os

if os_name == "OSX" then
    os = "mac"
elseif os_name == "Linux" then
    os = "linux"
elseif os_name == "Windows" then
    os = "unsuported"
else
    os = "other"
end

local global = {
    os = os,
    custom_path = home .. "/.config/nvim",
    cache_path = home .. "/.cache/nvim",
    packer_path = home .. "/.local/share/nvim/site",
    snapshot_path = home .. "/.config/nvim/.snapshots",
    modules_path = home .. "/.config/nvim/lua/modules",
    global_config = home .. "/.config/nvim/lua/config/global",
    custom_config = home .. "/.config/nvim/lua/config/custom",
    home = home,
    mason_path = home .. "/.local/share/nvim/mason",
    efm = {
        filetypes = {},
        settings = { languages = {} },
    },
}

_G.global = global
if global.os == "unsuported" then
    print("Your OS is not supported!")
else
    local fns = require("core.fns")
    local lazy = require("core.lazy")
    vim.g.mapleader = " "
    vim.g.maplocalleader = ","
    vim.keymap.set("n", " ", "", { noremap = true })
    vim.keymap.set("x", " ", "", { noremap = true })

    local snapshot = fns.read_file(global.cache_path .. "/.snapshot")
    if type(snapshot) == "table" then
        _G.SNAPSHOT = snapshot.snapshot
    else
        _G.SNAPSHOT = "default"
    end
    _G.SETTINGS = {}
    local function read_file_default(path, default)
        local val = fns.read_file(path)
        if val == nil then
            return default
        else
            return val
        end
    end
    _G.THEME = read_file_default(_G.global.custom_path .. "/.configs/custom/.theme", "custom-darker")
    _G.KEYSHELPER = read_file_default(_G.global.custom_path .. "/.configs/custom/.keyshelper", true)
    fns.configs()
    lazy.is_lazy()
    lazy.load()
end

return global
