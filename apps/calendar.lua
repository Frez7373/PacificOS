local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

local months = {
  "January","February","March","April","May","June",
  "July","August","September","October","November","December"
}
local week = {"Mo","Tu","We","Th","Fr","Sa","Su"}

local function isLeap(year)
  return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

local function daysInMonth(year, month)
  local days = {31,28,31,30,31,30,31,31,30,31,30,31}
  if month == 2 and isLeap(year) then return 29 end
  return days[month]
end

local function mondayIndex(year, month)
  local y = year
  local m = month
  if m < 3 then y = y - 1; m = m + 12 end
  local k = y % 100
  local j = math.floor(y / 100)
  local h = (1 + math.floor(13 * (m + 1) / 5) + k + math.floor(k / 4) + math.floor(j / 4) + 5 * j) % 7
  return (h + 5) % 7
end

local function changeMonth(year, month, delta)
  month = month + delta
  if month < 1 then month = 12; year = year - 1 end
  if month > 12 then month = 1; year = year + 1 end
  return year, month
end

local function footer(w, h)
  local y = math.max(1, h - 2)
  local small = w < 28
  local bw = small and math.max(5, math.floor((w - 4) / 3)) or 8
  local gap = 1
  local xPrev = 2
  local xNext = xPrev + bw + gap
  local xBack = small and (xNext + bw + gap) or math.max(1, w - bw + 1)
  local backW = small and math.max(5, w - xBack + 1) or bw

  U.button(xPrev, y, bw, 1, small and "<" or "< PREV", U._accent2)
  U.button(xNext, y, bw, 1, small and ">" or "NEXT >", U._accent2)
  if xBack <= w then U.button(xBack, y, backW, 1, "BACK", U._accent) end

  return y, xPrev, bw, xNext, xBack, backW
end

function M.run()
  local now = os.date("*t")
  local year, month = now.year, now.month

  while true do
    local w, h = term.getSize()
    local offset = mondayIndex(year, month)
    local total = daysInMonth(year, month)

    U.clear()
    U.header("Calendar", true)
    U.center(4, months[month] .. " " .. tostring(year), U._accent)
    U.label(2, 6, "Today: " .. tostring(now.day) .. " " .. months[now.month] .. " " .. tostring(now.year), U._muted)

    local cell = math.max(3, math.floor((w - 6) / 7))
    local x0 = 3
    for i, name in ipairs(week) do
      U.label(x0 + (i - 1) * cell, 8, name:sub(1, math.min(#name, cell)), U._accent)
    end

    local footerY = h - 2
    for day = 1, total do
      local slot = offset + day - 1
      local col = slot % 7
      local row = math.floor(slot / 7)
      local x = x0 + col * cell
      local y = 9 + row
      if y < footerY then
        local today = day == now.day and month == now.month and year == now.year
        U.button(x, y, math.max(2, cell - 1), 1, tostring(day),
          today and U._accent or U._accent2,
          today and U._textOnBlue or U._text)
      end
    end

    local navY, xPrev, bw, xNext, xBack, backW = footer(w, h)
    U.status("Left/Right = month | Prev/Next or touch | Q/Esc = back")

    local e, a, b, c = os.pullEvent()
    if U.closeEvent(e, a) then return end

    if e == "key" then
      if a == keys.left then
        year, month = changeMonth(year, month, -1)
      elseif a == keys.right then
        year, month = changeMonth(year, month, 1)
      end
    elseif e == "mouse_click" or e == "monitor_touch" then
      if U.hit(xPrev, navY, bw, 1, b, c) then
        year, month = changeMonth(year, month, -1)
      elseif U.hit(xNext, navY, bw, 1, b, c) then
        year, month = changeMonth(year, month, 1)
      elseif xBack <= w and U.hit(xBack, navY, backW, 1, b, c) then
        return
      end
    end

    now = os.date("*t")
  end
end

return M
