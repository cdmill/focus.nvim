local util = require("focus.util")
local M = {}
M.state = {}
M.area = {}
local active = false

function M.is_active()
  return active
end

function M.on_open()
  M.state["opts"] = {
    foldenable = vim.wo.foldenable,
    foldmethod = vim.wo.foldmethod,
    foldminlines = vim.wo.foldminlines,
    foldtext = vim.wo.foldtext,
    fillchars = vim.wo.fillchars,
  }
  M.state["hl"] = {
    Folded = util.get_hl("Folded"),
  }
end

function M.on_close()
  for k, v in pairs(M.state["opts"]) do
    vim.opt[k] = v
  end
  for k, v in pairs(M.state["hl"]) do
    util.set_hl(k, v)
  end
end

function M.foldtext()
  return ""
end

function M.normalize(line, mode)
  local pline = (
    mode == "head" and vim.fn.foldclosed(line) or vim.fn.foldclosedend(line)
  )
  return (pline > 0 and pline or line)
end

function M.focus(hd, tl)
  M.area = { head = hd, tail = tl }
  M.on_open()
  local head = M.normalize(hd, "head")
  local tail = M.normalize(tl, "tail")
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
  vim.wo.fillchars = (vim.o.fillchars ~= "" and vim.o.fillchars .. "," or "")
    .. "fold: "
  active = true
end

function M.unfocus()
  M.on_close()
  vim.cmd("normal! zE")
  active = false
end

function M.toggle()
  if M.is_active() then
    M.unfocus()
  else
    M.focus()
  end
end

return M
