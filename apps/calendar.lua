local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

local monthNames = {
  "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December"
}
local week = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"}

local function daysInMonth(year, month)
  local nextMonth = month == 12 and 1 or month + 1
  local nextYear = month == 12 and year + 1 or year
  local t = os.time({year = nextYear, month = nextMonth, day = 1, hour = 12})
  return tonumber(os.date("%d", t - 86400)) or 30
end

local function mondayIndex(year, month)
  local t = os.time({year = year, month = month, day = 1, hour = 12})
  local wday = tonumber(os.date("%w", t)) or 0
  return (wday + 6) % 7
end

function M.run()
  local now = os.date("*t")
  local year, month = now.year, now.month

  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("Calendar", true)

    U.center(4, monthNames[month] .. " " .. tostring(year), U._accent)
    U.label(3, 6, "Today: " .. tostring(now.day) .. " " .. monthNames[now.month] .. " " .. tostring(now.year), U._muted)

    local cell = math.max(4, math.floor((w - 6) / 7))
    local x0 = 3
    for i, name in ipairs(week) do
      U.label(x0 + (i - 1) * cell, 8, name:sub(1, math.min(#name, cell)), U._accent)
    end

    local total = daysInMonth(year, month)
    local offset = mondayIndex(year, month)
    local todayKey = now.year == year and now.month == month and now.day or -1

    for day = 1, total do
      local slot = offset + day - 1
      local col = slot % 7
      local row = math.floor(slot / 7)
      local x = x0 + col * cell
      local y = 9 + row * 2
      if y < h - 3 then
        local bg = day == todayKey and U._accent or U._accent2
        local fg = day == todayKey and U._textOnBlue or U._text
        U.button(x, y, math.max(3, cell - 1), 1, tostring(day), bg, fg)
      end
    end

    U.backButton(h - 2)
    U.status("Left/Right = previous/next month | Q/Esc = back")

    local e, a, b, c = os.pullEvent()
    if U.closeEvent(e, a) then return end
    if e == "key" then
      if a == keys.left then
        month = month - 1
        if month < 1 then month = 12; year = year - 1 end
      elseif a == keys.right then
        month = month + 1
        if month > 12 then month = 1; year = year + 1 end
      end
    elseif e == "mouse_click" or e == "monitor_touch" then
      if U.backHit(b, c, h - 2, 18) then return end
      if c == 8 then
        if b >= x0 + 5 * cell then
          month = month + 1
          if month > 12 then month = 1; year = year + 1 end
        elseif b >= x0 then
          month = month - 1
          if month < 1 then month = 12; year = year - 1 end
        end
      end
    end
    now = os.date("*t")
  end
end

return M
