local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run()
 local running=false; local started=0; local elapsed=0
 while true do
  local w,h=term.getSize(); U.clear(); U.header('Stopwatch')
  local shown=elapsed; if running then shown=elapsed+(os.clock()-started) end
  U.center(5,string.format('%.2f s',shown),colors.cyan)
  U.button(3,8,18,2,running and 'Pause' or 'Start',running and colors.orange or colors.green)
  U.button(23,8,18,2,'Reset',colors.gray); U.button(43,8,18,2,'Back',colors.gray)
  U.status('Q/Esc: back')
  local e,a,b,c=os.pullEvent()
  if e=='key' and (a==keys.q or a==keys.escape) then return
  elseif (e=='mouse_click' or e=='monitor_touch') and c>=8 and c<10 then
    if b>=3 and b<21 then if running then elapsed=shown; running=false else started=os.clock(); running=true end
    elseif b>=23 and b<41 then elapsed=0; if running then started=os.clock() end
    elseif b>=43 and b<62 then return end
  elseif e=='timer' then end
  if running then os.startTimer(0.1) end
 end
end
return M
