local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

function M.run()
  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("About PacificOS", true)

    U.center(4, "PACIFICOS 1.8.0", U._accent)
    U.center(6, "A stable, touch-friendly OS for CC:Tweaked.", U._text)
    U.center(8, "Complex Computer International (CCI)", U._accent)
    U.center(9, "2026", U._muted)

    U.label(3, 11, "Built-in services", U._accent)
    U.label(5, 12, "Desktop, BIOS, Recovery, Updater")
    U.label(5, 13, "Files, Editor, Calculator, Network")
    U.label(5, 14, "Devices, Monitor, Antivirus, App Installer")

    U.label(3, math.min(16, h - 4), "Third-party apps are stored separately in userapps.", U._muted)
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
