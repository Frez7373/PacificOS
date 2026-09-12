local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run()
 while true do
  U.header('Clock'); local w,h=term.getSize(); term.setCursorPos(2,5); term.setTextColor(colors.cyan); print(textutils.formatTime(os.time(),true)); term.setTextColor(colors.white); term.setCursorPos(2,7); print(os.date('%Y-%m-%d')); U.status('Q or touch to close'); local e,a,b,c=os.pullEvent('timer'); end
end
return M
