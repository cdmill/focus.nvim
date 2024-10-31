local M = {}

function M.gitsigns(state, disable)
  local gs = require("gitsigns")
  local config = require("gitsigns.config").config
  if disable then
    state.signcolumn = config.signcolumn
    state.numhl = config.numhl
    state.linehl = config.linehl
    config.signcolumn = false
    config.numhl = false
    config.linehl = false
  else
    config.signcolumn = state.signcolumn
    config.numhl = state.numhl
    config.linehl = state.linehl
  end
  gs.refresh()
end

function M.options(state, disable, opts)
  for key, value in pairs(opts) do
    if key ~= "enabled" then
      if disable then
        state[key] = vim.o[key]
        vim.o[key] = value
      else
        vim.o[key] = state[key]
      end
    end
  end
end

function M.twilight(state, disable)
  if disable then
    state.enabled = require("twilight.view").enabled
    require("twilight").enable()
  else
    if not state.enabled then
      require("twilight").disable()
    end
  end
end

function M.tmux(state, disable, opts)
  if not vim.env.TMUX then
    return
  end
  if disable then
    local function get_tmux_opt(option)
      local option_raw = vim.fn.system([[tmux show -w ]] .. option)
      if option_raw == "" then
        option_raw = vim.fn.system([[tmux show -g ]] .. option)
      end
      local opt = vim.split(vim.trim(option_raw), " ")[2]
      return opt
    end
    state.status = get_tmux_opt("status")
    state.pane = get_tmux_opt("pane-border-status")

    vim.fn.system([[tmux set -w pane-border-status off]])
    vim.fn.system([[tmux set status off]])
    vim.fn.system([[tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z]])
  else
    if type(state.pane) == "string" then
      vim.fn.system(string.format([[tmux set -w pane-border-status %s]], state.pane))
    else
      vim.fn.system([[tmux set -uw pane-border-status]])
    end
    vim.fn.system(string.format([[tmux set status %s]], state.status))
    vim.fn.system([[tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z]])
  end
end

function M.diagnostics(state, disable)
  if disable then
    vim.diagnostic.enable(false)
  else
    vim.diagnostic.enable(true)
  end
end

function M.todo(state, disable)
  if disable then
    state.todo = require("todo-comments.highlight").enabled
    require("todo-comments").disable()
  else
    if state.todo then
      require("todo-comments").enable()
    end
  end
end

return M
