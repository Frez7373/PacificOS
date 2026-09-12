local U=dofile('/pacificos/ui/widgets.lua'); local D=dofile('/pacificos/system/devices.lua'); local N=dofile('/pacificos/system/network.lua'); local M={}
function M.run()
 while true do
  local w,h=term.getSize(); U.clear(); U.header('System Monitor')
  U.label(3,4,'Computer ID: '..os.getComputerID()); U.label(3,5,'Label: '..tostring(os.getComputerLabel() or '-')); U.label(3,6,'Computer uptime: '..string.format('%.1f s',os.clock()))
  local dev=D.list(); U.label(3,8,'Devices: '..#dev); local y=9
  for i=1,math.min(#dev,math.max(1,h-13)) do U.label(5,y,dev[i]); y=y+1 end
  U.label(3,h-3,'Network peripherals: '..#N.list())
  U.status('Q/Esc: back'); local e,k=os.pullEvent('key'); if k==keys.q or k==keys.escape then return end
 end
end
return M
