local T = dofile("/pacificos/ui/theme.lua")
local W = {}

W._accent = T.accent
W._muted = T.muted
W._text = T.text
W._good = T.good
W._warn = T.warn
W._bad = T.bad

local function clamp(v, lo, hi)
  v = tonumber(v) or lo
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

local function fit(s, width)
  s = tostring(s or "")
  width = math.max(0, math.floor(tonumber(width) or 0))
  if width == 0 then return "" end
  if #s > width then
    if width <= 3 then return s:sub(1, width) end
    return s:sub(1, width - 3) .. "..."
  end
  return s .. string.rep(" ", width - #s)
end

function W.clamp(v, lo, hi)
  return clamp(v, lo, hi)
end

function W.clear(bg)
  term.setBackgroundColor(bg or T.bg)
  term.setTextColor(T.text)
  term.clear()
  term.setCursorPos(1, 1)
end

function W.fill(x, y, width, height, bg, fg)
  x = math.max(1, math.floor(tonumber(x) or 1))
  y = math.max(1, math.floor(tonumber(y) or 1))
  width = math.max(0, math.floor(tonumber(width) or 0))
  height = math.max(0, math.floor(tonumber(height) or 0))
  if width == 0 or height == 0 then return end

  term.setBackgroundColor(bg or T.bg)
  term.setTextColor(fg or T.text)

  local _, screenH = term.getSize()
  for i = 0, height - 1 do
    if y + i <= screenH then
      term.setCursorPos(x, y + i)
      write(string.rep(" ", width))
    end
  end
end

function W.label(x, y, value, fg, width)
  local screenW, screenH = term.getSize()
  x = clamp(x, 1, screenW)
  y = clamp(y, 1, screenH)
  value = tostring(value or "")
  local maxWidth = width and math.floor(width) or (screenW - x + 1)
  maxWidth = math.max(0, math.min(maxWidth, screenW - x + 1))

  term.setBackgroundColor(term.getBackgroundColor and select(1, term.getBackgroundColor()) or T.bg)
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
  -- Backwards-compatible signature: button(x,y,w,label,bg)
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
    if width <= 3 then
      shown = shown:sub(1, width)
    else
      shown = shown:sub(1, width - 3) .. "..."
    end
  end

  local tx = x + math.max(0, math.floor((width - #shown) / 2))
  local ty = y + math.floor((height - 1) / 2)
  term.setBackgroundColor(bg)
  term.setTextColor(fg)
  term.setCursorPos(tx, ty)
  write(shown)
end

function W.outline(x, y, width, height, fg)
  if width < 2 or height < 2 then return end
  fg = fg or T.border
  term.setTextColor(fg)
  term.setBackgroundColor(T.bg)

  term.setCursorPos(x, y)
  write("+" .. string.rep("-", width - 2) .. "+")
  for row = y + 1, y + height - 2 do
    term.setCursorPos(x, row)
    write("|")
    term.setCursorPos(x + width - 1, row)
    write("|")
  end
  term.setCursorPos(x, y + height - 1)
  write("+" .. string.rep("-", width - 2) .. "+")
end

function W.header(title, back)
  local screenW = select(1, term.getSize())
  W.fill(1, 1, screenW, 2, T.dark, T.textOnBlue)
  term.setTextColor(T.textOnBlue)
  term.setCursorPos(2, 1)
  write(fit("PACIFICOS", math.min(14, screenW - 2)))

  local titleText = tostring(title or "")
  if titleText ~= "" then
    term.setBackgroundColor(T.panel)
    term.setTextColor(T.text)
    term.setCursorPos(2, 2)
    write(fit(titleText, screenW - 2))
  end

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
  local _, screenH = term.getSize()
  y = math.min(tonumber(y) or screenH - 2, screenH - 1)
  local width = math.min(18, select(1, term.getSize()) - 2)
  if y >= 2 then
    W.button(2, y, math.max(8, width), 1, "Back", T.card)
  end
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

function W.lines(text, x, y, width, maxLines, fg)
  local count = 0
  width = math.max(1, math.floor(width or (select(1, term.getSize()) - x + 1)))
  for line in tostring(text or ""):gmatch("[^\n]*") do
    if line == "" and count > 0 and count >= maxLines then break end
    if count >= maxLines then break end
    W.label(x, y + count, line, fg, width)
    count = count + 1
  end
  return count
end

return W
