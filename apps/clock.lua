local U = dofile("/pacificos/ui/widgets.lua")
local C = dofile("/pacificos/system/config.lua")
local M = {}

function M.run()
  local timer = os.startTimer(0.2)

  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("Clock", true)

    local time = textutils.formatTime(os.time(), C.get("show_seconds") == true)
    local date = os.date("%A, %d %B %Y")
    local uptime = string.format("%.1f s", os.clock())

    U.center(math.max(5, math.floor(h / 2) - 2), time, U._accent)
    U.center(math.max(7, math.floor(h / 2)), date, U._text)
    U.center(math.max(9, math.floor(h / 2) + 2), "Computer uptime: " .. uptime, U._muted)

    U.backButton(h - 2)
    U.status("Q / Esc / Backspace = close")

    local e, a, b, c = os.pullEvent()
    if e == "timer" then
      timer = os.startTimer(0.2)
    elseif U.closeEvent(e, a) then
      return
    elseif (e == "mouse_click" or e == "monitor_touch") and U.backHit(b, c, h - 2, 18) then
      return
    end
  end
end

return M
