local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run()
 local timer=os.startTimer(1)
 while true do
  local w,h=term.getSize(); U.clear(); U.header('Clock'); U.center(5,textutils.formatTime(os.time(),true),colors.cyan); U.center(7,os.date('%Y-%m-%d'),colors.white); U.status('Q/Esc or Back: close')
  local e,a,b,c=os.pullEvent()
  if e=='timer' and a==timer then timer=os.startTimer(1)
  elseif e=='key' and (a==keys.q or a==keys.escape) then return
  elseif (e=='mouse_click' or e=='monitor_touch') and c>=h-1 then return end
 end
end
return M
