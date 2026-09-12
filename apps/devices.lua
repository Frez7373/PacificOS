local U=dofile('/pacificos/ui/widgets.lua'); local D=dofile('/pacificos/system/devices.lua'); local M={}
function M.run()
 while true do
  U.clear(); U.header('Device Manager'); local list=D.list(); local h=select(2,term.getSize())
  for i=1,math.min(#list,h-5) do local d=list[i]; U.label(2,2+i,tostring(d.side)..' | '..tostring(d.type)) end
  U.status('Devices: '..#list..' | Q/Esc: close')
  local e,a=os.pullEvent(); if e=='key' and (a==keys.q or a==keys.escape) then return end
 end
end
return M
