local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run()
 while true do
  U.clear(); U.header('Terminal'); U.label(2,3,'Commands are executed through the CC:Tweaked shell.'); U.status('Type exit/quit or press Q/Esc to return.')
  term.setCursorPos(2,5); write('> '); local s=read()
  if s=='exit' or s=='quit' or s=='q' then return end
  if s~='' then
    local ok,err=pcall(function() shell.run(s) end)
    if not ok then term.setCursorPos(2,7); term.setTextColor(colors.red); print('Error: '..tostring(err)); os.pullEvent('key') end
  end
 end
end
return M
