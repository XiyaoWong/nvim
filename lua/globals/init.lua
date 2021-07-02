_G.wxy = {}

_G.HOME = os.getenv("HOME") .. "/"
_G.OS = vim.loop.os_uname().sysname
_G.IS_MAC = OS == "Darwin"
_G.IS_LINUX = OS == "Linux"
_G.IS_WINDOWS = OS:find("Windows")
_G.CONFIG_PATH = vim.fn.stdpath("config") .. "/"
_G.CACHE_PATH = HOME .. "/.cache/nvim/"
_G.DATA_PATH = vim.fn.stdpath("data") .. "/site/"

require("globals.keybind")
require("globals.autocmd")
require("globals.highlight")
require("globals.utils")
