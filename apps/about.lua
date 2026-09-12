local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run()
 while true do
  U.header('About')
  term.setCursorPos(2,4); print('PacificOS 1.2.0')
  term.setCursorPos(2,5); print('Modern CC:Tweaked operating system')
  term.setCursorPos(2,7); print('Stable event-driven user interface.')
  term.setCursorPos(2,9); print('Compatible with legacy PacificOS apps.')
  U.status('Q close')
  local e,a=os.pullEvent()
  if e=='key' and a==keys.q then return end
 end
end
return M
