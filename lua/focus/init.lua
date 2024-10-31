local config = require("focus.config")
local foc = require("focus.views.focus")
local zen = require("focus.views.zen")
local narrow = require("focus.views.narrow")

local M = {}

M.setup = config.setup
M.toggle = foc.toggle
M.open = foc.open
M.close = foc.close
M.toggle_zen = function(opts)
  if foc.is_open() then
    if not zen.is_active() then
      opts.args = "zen"
    end
    if narrow.is_active() then
      opts.line1 = narrow.area.head
      opts.line2 = narrow.area.tail
    end
    foc.close()
    foc.open(opts)
  else
    zen.toggle(opts)
  end
end

function M.reset()
  M.close()
  require("plenary.reload").reload_module("focus")
  require("focus").toggle()
end

return M
