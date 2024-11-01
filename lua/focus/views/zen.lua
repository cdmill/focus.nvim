local config = require("focus.config")
local plugins = require("focus.plugins")
local M = {}

M.win = nil
--- @type FocusOptions
M.opts = nil
M.state = nil
M.active = false

function M.is_active()
  return M.active
end

function M.activate()
  for k, v in pairs(M.opts.zen.opts) do
    local opt = vim.fn.getwinvar(M.win, "&" .. k)
    -- Annoying workaround for some global opts exptecting different values when
    -- enabling/disabling
    M.state[k] = (
      (type(opt) == "number" and type(M.opts.zen.opts[k]) ~= "number")
        and (opt == 1 and true or false)
      or opt
    )

    vim.opt[k] = v
  end
  if M.opts.zen.diagnostics == false then
    pcall(plugins["diagnostics"], {}, true)
  end
  M.active = true
end

function M.deactivate()
  if M.state then
    for k, _ in pairs(M.opts.zen.opts) do
      vim.opt[k] = M.state[k]
    end
    if M.opts.zen.diagnostics == false then
      pcall(plugins["diagnostics"], {}, false)
    end
    M.active = false
  end
end

---@param opts table
local function setup(opts)
  opts = vim.tbl_deep_extend("force", {}, config.options, opts or {})
  M.opts = opts
  M.state = {}
  M.win = vim.api.nvim_get_current_win()
end

---@param opts table
function M.toggle(opts)
  if M.active then
    M.deactivate()
  else
    if not M.state then
      setup(opts)
    end
    M.activate()
  end
end

return M
