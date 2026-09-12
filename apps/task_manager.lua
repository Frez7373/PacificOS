local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run() while true do U.header('Task Manager'); term.setCursorPos(2,3); print('PacificOS uses cooperative application sessions.'); term.setCursorPos(2,5); print('This keeps failed apps isolated with pcall.'); term.setCursorPos(2,7); print('Memory: '..tostring(collectgarbage('count'))..' KB'); U.status('Q close'); local e,a=os.pullEvent(); if e=='key' and a==keys.q then return end end end
return M
