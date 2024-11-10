local config = require("focus.config")
local plugins = require("focus.plugins")
local M = {}

M.win = nil
--- @type focus.Config
M.opts = nil
M.state = nil
M.active = false

function M.is_active()
  return M.active
end

--- Disables plugins/opts when entering zen mode. Saves the state before disabling
---@private
function M.activate()
  for key, value in pairs(M.opts.zen.opts) do
    local opt = vim.fn.getwinvar(M.win, "&" .. key)
    -- Annoying workaround for some global opts expecting different types when
    -- enabling/disabling
    if type(opt) == "number" and type(M.opts.zen.opts[key]) ~= "number" then
      M.state[key] = opt == 1 and true or opt == 0 and false
    else
      M.state[key] = opt
    end
    vim.opt[key] = value
  end
  if M.opts.zen.diagnostics == false then
    pcall(plugins["diagnostics"], {}, true)
  end
  M.active = true
end

--- Restores state to values from before entering focus mode
---@private
function M.deactivate()
  if not M.is_active() then
    return
  end

  for key, _ in pairs(M.opts.zen.opts) do
    vim.opt[key] = M.state[key]
  end
  if M.opts.zen.diagnostics == false then
    pcall(plugins["diagnostics"], {}, false)
  end
  M.active = false
end

---@param opts table options recieved from `nvim_create_user_command`
---@private
local function setup(opts)
  opts = vim.tbl_deep_extend("force", {}, config.options, opts or {})
  M.opts = opts
  M.state = {}
  M.win = vim.api.nvim_get_current_win()
end

---@param opts table options recieved from `nvim_create_user_command`
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
