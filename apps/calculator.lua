local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run()
 local expr=''
 while true do
  U.header('Calculator'); term.setCursorPos(2,4); term.setTextColor(colors.white); write('Expression: '..expr); U.button(2,7,18,2,'Calculate',colors.blue); U.button(2,10,18,2,'Back',colors.gray)
  local e,k=os.pullEvent(); if e=='char' then expr=expr..k elseif e=='key' then if k==keys.backspace then expr=expr:sub(1,-2) elseif k==keys.enter then local ok,v=pcall(load,'return '..expr); if ok then local ok2,r=pcall(v); term.setCursorPos(2,14); print('Result: '..tostring(ok2 and r or 'error')) end elseif k==keys.q then return end elseif e=='mouse_click' or e=='monitor_touch' then local _,x,y=e,k,select(2,os.pullEvent) end
  if e=='mouse_click' or e=='monitor_touch' then if k>=7 and k<9 then local f,er=load('return '..expr,'calc','t',{}); if f then local ok,r=pcall(f); term.setCursorPos(2,14); print('Result: '..tostring(ok and r or 'error')) else term.setCursorPos(2,14); print('Error: '..tostring(er)) end elseif k>=10 and k<12 then return end end
 end
end
return M
