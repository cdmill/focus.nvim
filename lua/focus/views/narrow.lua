local util = require("focus.util")
local M = {}
M.state = {}
M.range = {}
M.active = false

function M.is_active()
  return M.active
end

function M.can_toggle()
  return M.range.head ~= nil and M.range.tail ~= nil
end

function M.on_open()
  M.state["opts"] = {
    foldenable = vim.o.foldenable,
    foldmethod = vim.o.foldmethod,
    foldminlines = vim.o.foldminlines,
    foldtext = vim.o.foldtext,
  }
  M.state["hl"] = {
    Folded = util.get_hl("Folded"),
  }
end

function M.on_close()
  if not M.is_active() then
    return
  end

  for key, value in pairs(M.state["opts"]) do
    vim.opt[key] = value
  end
  for key, value in pairs(M.state["hl"]) do
    util.set_hl(key, value)
  end
end

function M.foldtext()
  return ""
end

--- If the starting or ending line of narrow is a fold, returns the line number of the
--- first/last line in that fold. Otherwise, returns the original line number
---@param line number
---@param mode string
---@return number
function M.normalize(line, mode)
  local pline = (
    mode == "head" and vim.fn.foldclosed(line) or vim.fn.foldclosedend(line)
  )
  return (pline > 0 and pline or line)
end

function M.focus(hd, tl)
  if hd and tl then
    M.range = { head = hd, tail = tl }
  end
  M.on_open()
  local head = M.normalize(M.range.head, "head")
  local tail = M.normalize(M.range.tail, "tail")
  local curr_pos = vim.fn.getpos(".")

  local bg = util.get_hl("Normal").bg or "NONE"
  util.set_hl("Folded", { fg = bg, bg = bg })

  vim.wo.foldenable = true
  vim.wo.foldmethod = "manual"
  vim.wo.foldminlines = 0

  vim.cmd("normal! zE")

  if head > 1 then
    vim.cmd([[execute '1,' (]] .. head .. [[ - 1) 'fold']])
  end

  if tail < vim.fn.line("$") then
    vim.cmd([[execute (]] .. tail .. [[ + 1) ',$' 'fold']])
  end

  vim.wo.foldtext = "v:lua.require('focus.views.narrow').foldtext()"
  vim.fn.setpos(".", curr_pos)
  vim.cmd("normal! zz")
  M.active = true
end

function M.unfocus()
  if vim.wo.foldmethod == "manual" then
    vim.cmd("normal! zE")
  end
  M.on_close()
  M.active = false
end

---@param opts table options recieved from `nvim_create_user_command`
function M.toggle(opts)
  if M.is_active() then
    M.unfocus()
    if opts.line1 ~= opts.line2 then
      M.focus(opts.line1, opts.line2)
    end
  else
    if opts.line1 ~= opts.line2 then
      M.focus(opts.line1, opts.line2)
    else
      util.warn("Please provide a range to activate narrow focus")
    end
  end
end

return M
