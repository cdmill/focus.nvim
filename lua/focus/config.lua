local util = require("focus.util")
local M = {}

---@class (exact) focus.WindowOpts
---@field backdrop? number scale to shade the backdrop of the focus window. Set to 1 to keep the same as Normal
---@field width? number the width of the focus window
---@field height? number the height of the focus window
---@field options? table vim.wo options to apply to focus window

---@class (exact) focus.ZenOpts
---@field opts? table vim.opt options to apply
---@field diagnostics? boolean if false, disables diagnostics in zen mode

---@class (exact) focus.Config
---@field border? string border type for focus window
---@field zindex? number zindex of the focus, should be less than 50
---@field window? focus.WindowOpts options for focus window
---@field auto_zen? boolean if true, auto enable zen mode when entering focus mode
---@field auto_disable_zen? boolean if true, auto disable zen mode when exiting focus mode
---@field auto_disable_narrow? boolean if true, auto disable zen mode when exiting focus mode
---@field zen? focus.ZenOpts options for zen mode
---@field plugins? table plugins to disable/enable in focus mode
---@field on_open? function callback when entering focus window
---@field on_close? function callback when exiting focus window
local defaults = {
  border = "none",
  zindex = 40,
  window = {
    backdrop = 0.9,
    -- height and width can be:
    -- * an asbolute number of cells when > 1
    -- * a percentage of the width / height of the editor when <= 1
    width = 120,
    height = 1,
    -- by default, no options are changed in for the focus window
    options = {},
  },
  auto_zen = false,
  auto_disable_zen = false,
  auto_disable_narrow = false,
  -- by default, the options below are disabled for zen mode
  zen = {
    opts = {
      cmdheight = 0, -- disable cmdline
      cursorline = false, -- disable cursorline
      laststatus = 0, -- disable statusline
      number = false, -- disable number column
      relativenumber = false, -- disable relative numbers
      foldcolumn = "0", -- disable fold column
      signcolumn = "no", -- disable signcolumn
      statuscolumn = " ", -- disbale status column
    },
    diagnostics = false,
  },
  plugins = {
    -- comment the lines to not apply the options
    -- options = {
    --   disable some global vim options (vim.o...) e.g.
    --   ruler = false
    -- },
    -- twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
    -- gitsigns = { enabled = false }, -- disables git signs
    -- tmux = { enabled = false }, -- disables the tmux statusline
    -- diagnostics = { enabled = false }, -- disables diagnostics
    -- todo = { enabled = false }, -- if set to "true", todo-comments.nvim highlights will be disabled
  },
  on_open = function(_win) end,
  on_close = function() end,
}

---@type focus.Config
M.options = nil

function M.colors(options)
  options = options or M.options
  local normal = util.get_hl("Normal") -- returns attrs in decimal
  if normal then
    if normal.bg then
      local bg = util.darken(util.dec2hex(normal.bg), options.window.backdrop)
      util.set_hl("FocusBg", { fg = bg, bg = bg })
    else
      vim.cmd("highlight default link FocusBg Normal")
    end
  end
end

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  M.colors()
  vim.cmd("autocmd ColorScheme * lua require('focus.config').colors()")
  for plugin, plugin_opts in pairs(M.options.plugins) do
    if type(plugin_opts) == "boolean" then
      M.options.plugins[plugin] = { enabled = plugin_opts }
    end
    if M.options.plugins[plugin].enabled == nil then
      M.options.plugins[plugin].enabled = true
    end
  end
  vim.api.nvim_create_user_command(
    "Focus",
    require("focus").toggle,
    { range = 2, nargs = "*" }
  )
  vim.api.nvim_create_user_command("Zen", require("focus").toggle_zen, { nargs = 0 })
  vim.api.nvim_create_user_command(
    "Narrow",
    require("focus").toggle_narrow,
    { range = 2, nargs = 0 }
  )
end

return setmetatable(M, {
  __index = function(_, k)
    if k == "options" then
      M.setup()
    end
    return rawget(M, k)
  end,
})
