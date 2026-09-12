local U=dofile('/pacificos/ui/widgets.lua'); local C=dofile('/pacificos/system/config.lua')
local M={}
function M.run()
 while true do
  U.header('Settings'); local w,h=term.getSize(); term.setBackgroundColor(colors.black); term.setTextColor(colors.white)
  term.setCursorPos(2,3); print('Network: '..(C.get('network')==false and 'Disabled' or 'Enabled'))
  term.setCursorPos(2,4); print('Hostname: '..tostring(C.get('hostname')))
  U.button(2,6,22,2,'Toggle Network',colors.blue); U.button(2,9,22,2,'Change Hostname',colors.blue); U.button(2,12,22,2,'Back',colors.gray)
  local e,_,x,y=os.pullEvent(); if e=='mouse_click' or e=='monitor_touch' then
   if y>=6 and y<8 then C.set('network',not (C.get('network')==false))
   elseif y>=9 and y<11 then term.setCursorPos(2,15); write('Hostname: '); local s=read(); if s~='' then C.set('hostname',s) end
   elseif y>=12 and y<14 then return end
  elseif e=='key' and x==keys.q then return end
 end
end
return M
