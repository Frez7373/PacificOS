local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run()
 local path='/'
 while true do
  U.header('Files'); local w,h=term.getSize(); term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.setCursorPos(2,3); print('Path: '..path)
  local list=fs.list(path); local page=math.min(#list,h-7)
  for i=1,page do local n=list[i]; term.setCursorPos(3,3+i); print((fs.isDir(fs.combine(path,n)) and '[DIR] ' or '      ')..n) end
  U.status('Click item to open | Backspace: parent | Q: close')
  local e,k,x,y=os.pullEvent()
  if e=='mouse_click' or e=='monitor_touch' then
    if y>=4 and y<4+page then local n=list[y-3]; local p=fs.combine(path,n); if fs.isDir(p) then path=p end end
  elseif e=='key' and k==keys.backspace then path=fs.getDir(path); if path=='' then path='/' end elseif e=='key' and k==keys.q then return end
 end
end
return M
