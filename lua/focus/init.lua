local config = require("focus.config")
local view = require("focus.view")

local M = {}

M.setup = config.setup
M.toggle = view.toggle
M.toggle_zen = view.toggle_zen
M.open = view.open
M.close = view.close

function M.reset()
  M.close()
  require("plenary.reload").reload_module("focus")
  require("focus").toggle()
end

return M
