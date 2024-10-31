local M = {}
M.bg = "#000000"
M.fg = "#ffffff"

function M.get_hl(group)
  return vim.api.nvim_get_hl(0, { name = group })
end

function M.set_hl(group, color)
  if color.link then
    if color.force then
      vim.cmd("highlight! link " .. group .. " " .. color.link)
    else
      vim.api.nvim_set_hl(0, group, {
        link = color.link,
      })
    end
  else
    if color.style then
      for _, style in ipairs(color.style) do
        color[style] = true
      end
    end
    color.style = nil
    vim.api.nvim_set_hl(0, group, color)
  end
end

function M.dec2hex(dec)
  return string.format("#%06x", dec)
end

local function hex2rbg(hex_str)
  local hex = "[abcdef0-9][abcdef0-9]"
  local pat = "^#(" .. hex .. ")(" .. hex .. ")(" .. hex .. ")$"
  hex_str = string.lower(hex_str)

  assert(
    string.find(hex_str, pat) ~= nil,
    "hex_to_rgb: invalid hex_str: " .. tostring(hex_str)
  )

  local r, g, b = string.match(hex_str, pat)
  return { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) }
end

function M.blend(fg, bg, alpha)
  bg = hex2rbg(bg)
  fg = hex2rbg(fg)

  local blendChannel = function(i)
    local ret = (alpha * fg[i] + ((1 - alpha) * bg[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end

  return string.format(
    "#%02X%02X%02X",
    blendChannel(1),
    blendChannel(2),
    blendChannel(3)
  )
end

function M.darken(hex, amount, bg)
  return M.blend(hex, bg or M.bg, math.abs(amount))
end

function M.lighten(hex, amount, fg)
  return M.blend(hex, fg or M.fg, math.abs(amount))
end

function M.log(msg, hl)
  vim.api.nvim_echo({ { "Focus: ", hl }, { msg } }, true, {})
end

function M.warn(msg)
  M.log(msg, "WarningMsg")
end

function M.error(msg)
  M.log(msg, "ErrorMsg")
end

return M
