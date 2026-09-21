local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

function M.run()
  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("About PacificOS", true)

    U.center(4, "PACIFICOS 1.9.0", U._accent)
    U.center(5, "Windows Classic inspired interface.", U._text)
    U.center(7, "Complex Computer International (CCI)", U._accent)
    U.center(8, "2026", U._muted)

    U.label(2, math.min(10, h - 3), "System components", U._accent)
    if h >= 13 then
      U.label(3, 11, "Desktop / BIOS / Recovery / Updater", U._text)
      U.label(3, 12, "Files / Editor / Calculator / Network", U._text)
    elseif h >= 10 then
      U.label(3, 11, "Desktop / BIOS / Recovery / Apps", U._text)
    end

    U.backButton(h - 2)
    U.status("Q / Esc / Backspace = close")
    local e, a, b, c = os.pullEvent()
    if U.closeEvent(e, a) then return end
    if (e == "mouse_click" or e == "monitor_touch") and U.backHit(b, c, h - 2, 18) then
      return
    end
  end
end

return M
