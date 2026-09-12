local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run() term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.clear(); term.setCursorPos(1,1); print('PacificOS Terminal'); print('Type exit to return.'); while true do term.write('> '); local s=read(); if s=='exit' or s=='quit' then return end; if s~='' then local ok,err=pcall(function() shell.run(s) end); if not ok then print('Error: '..tostring(err)) end end end end
return M
