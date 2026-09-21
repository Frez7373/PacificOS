local U=dofile("/pacificos/ui/widgets.lua")
local M={}
function M.run()
  while true do
    local w,h=term.getSize()
    U.clear(); U.header("About PacificOS")
    U.label(3,5,"PacificOS 1.6.0",colors.cyan)
    U.label(3,7,"A modern operating system for CC:Tweaked.")
    U.label(3,9,"Designed and developed by")
    U.label(3,10,"Complex Computer International (CCI)",colors.white)
    U.label(3,12,"CCI 2026",colors.lightGray)
    U.label(3,14,"Third-party apps can be installed with WGET or Pastebin.",colors.lightGray)
    U.button(3,h-3,20,2,"Back",colors.gray)
    U.status("Q / Esc / Backspace = close")
    local e,a,b,c=os.pullEvent()
    if e=="key" and (a==keys.q or a==keys.escape or a==keys.backspace) then return
    elseif (e=="mouse_click" or e=="monitor_touch") and b>=3 and b<23 and c>=h-3 and c<h-1 then return end
  end
end
return M
