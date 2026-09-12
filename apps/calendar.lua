local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run() while true do U.header('Calendar'); term.setCursorPos(2,4); print('Day: '..os.day()); term.setCursorPos(2,5); print('Time: '..textutils.formatTime(os.time(),true)); U.button(2,9,18,2,'Back',colors.gray); local e,a,b,c=os.pullEvent(); if (e=='mouse_click' or e=='monitor_touch') and c>=9 and c<11 then return end; if e=='key' and a==keys.q then return end end end
return M
