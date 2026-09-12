local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run()
 local timer=os.startTimer(1)
 while true do
  U.header('Clock'); local w,h=term.getSize(); term.setCursorPos(2,5); term.setTextColor(colors.cyan); print(textutils.formatTime(os.time(),true)); term.setTextColor(colors.white); term.setCursorPos(2,7); print(os.date('%Y-%m-%d')); U.status('Q close')
  local e,a,b,c=os.pullEvent(); if e=='timer' and a==timer then timer=os.startTimer(1) elseif e=='key' and a==keys.q then return elseif (e=='mouse_click' or e=='monitor_touch') and c>=h-1 then return end
 end
end
return M
