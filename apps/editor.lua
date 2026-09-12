local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run()
 while true do
  U.clear(); U.header('Text Editor')
  U.label(2,4,'File path:')
  term.setCursorPos(2,5); write('> '); local p=read()
  if not p or p=='' then return end
  if p=='q' or p=='exit' then return end
  local old=''; if fs.exists(p) and not fs.isDir(p) then local h=fs.open(p,'r'); old=h.readAll() or ''; h.close() end
  U.label(2,7,'Enter lines. Commands: .SAVE  .CANCEL  .EXIT')
  if old~='' then U.label(2,9,'Existing file loaded; save replaces its contents.') end
  local lines={}
  while true do
    term.setCursorPos(2,11); write('> '); local s=read()
    if s=='.SAVE' then
      local h=fs.open(p,'w'); if not h then U.label(2,13,'Cannot write file.'); os.pullEvent('key'); break end
      h.write(table.concat(lines,'\n')); h.close(); U.label(2,13,'Saved: '..p); os.pullEvent('key'); return
    elseif s=='.CANCEL' or s=='.EXIT' then return
    else lines[#lines+1]=s end
  end
 end
end
return M
