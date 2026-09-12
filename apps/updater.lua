local U=dofile('/pacificos/ui/widgets.lua'); local Up=dofile('/pacificos/system/updater.lua'); local M={}
function M.run()
 while true do
  U.clear(); U.header('Updater'); local v,e=Up.version(); U.label(2,4,'Installed version: 1.3.0'); U.label(2,6,'Remote version: '..tostring(v or e)); U.button(2,9,24,2,'Check again',colors.blue); U.button(2,12,24,2,'Back',colors.gray); U.status('Q/Esc: back')
  local ev,a,b,c=os.pullEvent()
  if ev=='key' and (a==keys.q or a==keys.escape) then return
  elseif (ev=='mouse_click' or ev=='monitor_touch') and c>=12 and c<14 and b>=2 and b<26 then return end
 end
end
return M
