local U=dofile('/pacificos/ui/widgets.lua')
local Up=dofile('/pacificos/system/updater.lua')
local M={}
function M.run()
 while true do
  local w,h=term.getSize(); U.clear(); U.header('Updater')
  local v,e=Up.version()
  U.label(2,4,'Installed version: 1.5.0')
  U.label(2,6,'Remote version: '..tostring(v or e))
  U.label(2,8,'Channel: stable')
  U.button(2,10,24,2,'Check again',colors.blue)
  U.button(2,h-3,24,2,'Back',colors.gray)
  U.status('Q / Esc / Backspace = back')
  local ev,a,b,c=os.pullEvent()
  if ev=='key' and (a==keys.q or a==keys.escape or a==keys.backspace) then return
  elseif (ev=='mouse_click' or ev=='monitor_touch') and c>=h-3 and c<h-1 and b>=2 and b<26 then return end
 end
end
return M
