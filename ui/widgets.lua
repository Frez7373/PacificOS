local T = dofile("/pacificos/ui/theme.lua")
local W = {}

W._accent = T.accent
W._muted = T.muted
W._text = T.text
W._textOnBlue = T.textOnBlue
W._good = T.good
W._warn = T.warn
W._bad = T.bad

local function clamp(value, low, high)
  value = tonumber(value) or low
  if value < low then return low end
  if value > high then return high end
  return value
end

local function fit(value, width)
  value = tostring(value or "")
  width = math.max(0, math.floor(tonumber(width) or 0))
  if width == 0 then return "" end
  if #value > width then
    if width <= 3 then return value:sub(1, width) end
    return value:sub(1, width - 3) .. "..."
  end
  return value .. string.rep(" ", width - #value)
end

function W.clamp(value, low, high)
  return clamp(value, low, high)
end

function W.clear(bg)
  term.setBackgroundColor(bg or T.bg)
  term.setTextColor(T.text)
  term.clear()
  term.setCursorPos(1, 1)
end

function W.fill(x, y, width, height, bg, fg)
  local screenW, screenH = term.getSize()
  x = math.max(1, math.floor(tonumber(x) or 1))
  y = math.max(1, math.floor(tonumber(y) or 1))
  width = math.max(0, math.floor(tonumber(width) or 0))
  height = math.max(0, math.floor(tonumber(height) or 0))

  if width == 0 or height == 0 or x > screenW or y > screenH then return end
  width = math.min(width, screenW - x + 1)
  height = math.min(height, screenH - y + 1)

  term.setBackgroundColor(bg or T.bg)
  term.setTextColor(fg or T.text)
  for row = 0, height - 1 do
    term.setCursorPos(x, y + row)
    write(string.rep(" ", width))
  end
end

function W.label(x, y, value, fg, width)
  local screenW, screenH = term.getSize()
  x = clamp(x, 1, screenW)
  y = clamp(y, 1, screenH)
  value = tostring(value or "")

  local maxWidth = width and math.floor(width) or (screenW - x + 1)
  maxWidth = math.max(0, math.min(maxWidth, screenW - x + 1))

  term.setTextColor(fg or T.text)
  term.setCursorPos(x, y)
  write(value:sub(1, maxWidth))
end

function W.center(y, value, fg)
  local screenW, screenH = term.getSize()
  y = clamp(y, 1, screenH)
  value = tostring(value or "")
  local shown = value:sub(1, screenW)
  local x = math.max(1, math.floor((screenW - #shown) / 2) + 1)

  term.setTextColor(fg or T.text)
  term.setCursorPos(x, y)
  write(shown)
end

function W.button(x, y, width, height, label, bg, fg)
  if type(height) ~= "number" then
    local oldLabel = height
    local oldBg = label
    local oldFg = bg
    height = 1
    label = oldLabel
    bg = oldBg
    fg = oldFg
  end

  local screenW, screenH = term.getSize()
  x = math.max(1, math.floor(tonumber(x) or 1))
  y = math.max(1, math.floor(tonumber(y) or 1))
  width = math.max(1, math.floor(tonumber(width) or 1))
  height = math.max(1, math.floor(tonumber(height) or 1))
  if x > screenW or y > screenH then return end

  width = math.min(width, screenW - x + 1)
  height = math.min(height, screenH - y + 1)
  label = tostring(label or "")
  bg = bg or T.card
  fg = fg or ((bg == T.dark or bg == T.accent) and T.textOnBlue or T.text)

  W.fill(x, y, width, height, bg, fg)

  local shown = label
  if #shown > width then
    if width <= 3 then shown = shown:sub(1, width)
    else shown = shown:sub(1, width - 3) .. "..." end
  end

  local tx = x + math.max(0, math.floor((width - #shown) / 2))
  local ty = y + math.floor((height - 1) / 2)
  term.setBackgroundColor(bg)
  term.setTextColor(fg)
  term.setCursorPos(tx, ty)
  write(shown)
end

function W.header(title, back)
  local screenW = select(1, term.getSize())
  W.fill(1, 1, screenW, 2, T.dark, T.textOnBlue)

  term.setTextColor(T.textOnBlue)
  term.setCursorPos(2, 1)
  write(fit("PACIFICOS", math.min(14, screenW - 2)))

  term.setBackgroundColor(T.panel)
  term.setTextColor(T.text)
  term.setCursorPos(2, 2)
  write(fit(tostring(title or ""), screenW - 2))

  if back and screenW >= 12 then
    term.setBackgroundColor(T.dark)
    term.setTextColor(T.textOnBlue)
    term.setCursorPos(math.max(1, screenW - 9), 1)
    write("< BACK")
  end
end

function W.top(title)
  W.header(title)
end

function W.bottom(value)
  local screenW, screenH = term.getSize()
  term.setBackgroundColor(T.dark)
  term.setTextColor(T.textOnBlue)
  term.setCursorPos(1, screenH)
  write(fit(value or "", screenW))
end

function W.status(value)
  W.bottom(value)
end

function W.backButton(y)
  local screenW, screenH = term.getSize()
  local buttonY = math.min(tonumber(y) or screenH - 2, screenH - 1)
  local width = math.max(8, math.min(18, screenW - 2))
  if buttonY >= 2 then W.button(2, buttonY, width, 1, "BACK", T.accent2) end
end

function W.backHit(x, y, buttonY, width)
  width = width or 18
  return x >= 2 and x < 2 + width and y >= buttonY and y < buttonY + 1
end

function W.closeEvent(event, key)
  return event == "key" and (key == keys.q or key == keys.escape or key == keys.backspace)
end

function W.wait(message)
  W.status(message or "Press any key to continue")
  os.pullEvent()
end

function W.hit(x, y, width, height, tx, ty)
  return tx >= x and tx < x + width and ty >= y and ty < y + height
end

return W
