local U=dofile('/pacificos/ui/widgets.lua'); local D=dofile('/pacificos/system/devices.lua'); local M={}
function M.run() while true do U.header('Device Manager'); local list=D.list(); for i=1,math.min(#list,select(2,term.getSize())-5) do local d=list[i]; term.setCursorPos(2,2+i); print(d.side..' | '..tostring(d.type)) end; U.status('Devices: '..#list..'   Q to close'); local e,a=os.pullEvent(); if e=='key' and a==keys.q then return end end end
return M
