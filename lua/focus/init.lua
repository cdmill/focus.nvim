local config = require("focus.config")
local util = require("focus.util")
local focus = require("focus.views.focus")
local zen = require("focus.views.zen")
local narrow = require("focus.views.narrow")

local M = {}

M.setup = config.setup
M.toggle = focus.toggle
M.open = focus.open
M.close = focus.close

M.toggle_narrow = function(opts)
  if
    not focus.is_open()
    and not narrow.can_toggle()
    and opts.line1 == nil
    and opts.line2 == nil
  then
    util.warn("Please provide a range to activate narrow focus")
  else
    narrow.toggle(opts)
  end
end

M.toggle_zen = function(opts)
  if focus.is_open() then
    if not zen.is_active() then
      opts.args = "zen"
    end
    if narrow.is_active() then
      opts.line1 = narrow.range.head
      opts.line2 = narrow.range.tail
    end
    M.close()
    M.open(opts)
  else
    zen.toggle(opts)
  end
end

function M.reset(opts)
  M.close()
  require("plenary.reload").reload_module("focus")
  require("focus").toggle(opts)
end

return M
