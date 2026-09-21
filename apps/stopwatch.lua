local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

local function formatTime(seconds)
  seconds = math.max(0, seconds)
  local minutes = math.floor(seconds / 60)
  local whole = math.floor(seconds % 60)
  local centi = math.floor((seconds - math.floor(seconds)) * 100)
  return string.format("%02d:%02d.%02d", minutes, whole, centi)
end

function M.run()
  local running = false
  local elapsed = 0
  local started = 0
  local laps = {}
  local timer

  local function current()
    if running then return elapsed + (os.clock() - started) end
    return elapsed
  end

  local function toggle()
    if running then
      elapsed = current()
      running = false
      timer = nil
    else
      started = os.clock()
      running = true
      timer = os.startTimer(0.1)
    end
  end

  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("Stopwatch", true)
    U.center(5, formatTime(current()), U._accent)
    U.center(6, running and "RUNNING" or "PAUSED", running and U._accent or U._muted)

    local y = 8
    if w >= 54 then
      U.button(2, y, 14, 2, running and "PAUSE" or "START", U._accent)
      U.button(17, y, 14, 2, "LAP", U._accent2)
      U.button(32, y, 14, 2, "RESET", U._accent2)
      U.button(47, y, math.min(10, w - 46), 2, "BACK", U._accent2)
    else
      local bw = math.max(8, math.floor((w - 5) / 2))
      U.button(2, y, bw, 1, running and "PAUSE" or "START", U._accent)
      U.button(3 + bw, y, bw, 1, "LAP", U._accent2)
      U.button(2, y + 2, bw, 1, "RESET", U._accent2)
      U.button(3 + bw, y + 2, bw, 1, "BACK", U._accent2)
    end

    U.label(2, y + 4, "Laps", U._muted)
    local lineY = y + 5
    for i = #laps, math.max(1, #laps - 4), -1 do
      if laps[i] and lineY < h - 2 then
        U.label(3, lineY, string.format("%02d  %s", i, formatTime(laps[i])))
        lineY = lineY + 1
      end
    end

    U.status("Space = start/pause | L = lap | R = reset | Q/Esc = back")

    local e, a, b, c = os.pullEvent()
    if e == "timer" and running and a == timer then
      timer = os.startTimer(0.1)
    elseif e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.space then toggle()
      elseif a == keys.l then laps[#laps + 1] = current()
      elseif a == keys.r then elapsed = 0; started = os.clock(); laps = {} end
    elseif e == "mouse_click" or e == "monitor_touch" then
      if w >= 54 then
        if U.hit(2, y, 14, 2, b, c) then toggle()
        elseif U.hit(17, y, 14, 2, b, c) then laps[#laps + 1] = current()
        elseif U.hit(32, y, 14, 2, b, c) then elapsed = 0; started = os.clock(); laps = {}
        elseif U.hit(47, y, math.min(10, w - 46), 2, b, c) then return
        end
      else
        local bw = math.max(8, math.floor((w - 5) / 2))
        if U.hit(2, y, bw, 1, b, c) then toggle()
        elseif U.hit(3 + bw, y, bw, 1, b, c) then laps[#laps + 1] = current()
        elseif U.hit(2, y + 2, bw, 1, b, c) then elapsed = 0; started = os.clock(); laps = {}
        elseif U.hit(3 + bw, y + 2, bw, 1, b, c) then return
        end
      end
    end
  end
end

return M
