local U=dofile('/pacificos/ui/widgets.lua')
local M={}
function M.run()
 while true do
  U.clear(); U.header('About PacificOS')
  U.label(3,5,'PacificOS 1.4.0',colors.cyan)
  U.label(3,7,'A full operating system for CC:Tweaked.')
  U.label(3,9,'Designed and developed by')
  U.label(3,10,'Complex Computer International (CCI)',colors.white)
  U.label(3,12,'© 2026 CCI',colors.lightGray)
  U.label(3,14,'Built for stability, devices and real use.',colors.lightGray)
  U.button(3,18,20,2,'Back',colors.gray)
  U.status('Q / Esc = close')
  local e,a,b,c=os.pullEvent()
  if e=='key' and (a==keys.q or a==keys.escape or a==keys.backspace) then return
  elseif (e=='mouse_click' or e=='monitor_touch') and b>=3 and b<23 and c>=18 and c<20 then return end
 end
end
return M
