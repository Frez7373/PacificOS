local U=dofile('/pacificos/ui/widgets.lua'); local C=dofile('/pacificos/system/config.lua'); local M={}
local sections={'General','Appearance','Network','Security','System','Reset'}
local function toggle(k) C.set(k,not C.get(k)) end
function M.run()
 local section=1
 while true do
  local w,h=term.getSize(); U.clear(); U.header('Settings')
  for i,s in ipairs(sections) do U.button(2+(i-1)*math.max(8,math.floor((w-4)/#sections)),3,math.max(7,math.floor((w-4)/#sections)),1,s,i==section and colors.blue or colors.gray) end
  if section==1 then
    U.label(3,6,'Hostname: '..tostring(C.get('hostname'))); U.label(3,8,'Default app: '..tostring(C.get('default_app')))
    U.button(3,10,24,2,'Change Hostname',colors.blue); U.button(3,13,24,2,'Default: Files',colors.gray)
  elseif section==2 then
    U.label(3,6,'Theme: '..tostring(C.get('theme'))); U.label(3,8,'Animations: '..tostring(C.get('animations'))); U.label(3,10,'Sounds: '..tostring(C.get('sounds'))); U.label(3,12,'Show seconds: '..tostring(C.get('show_seconds')))
    U.button(3,14,24,2,'Toggle animations',colors.blue); U.button(29,14,24,2,'Toggle sounds',colors.blue); U.button(3,17,24,2,'Toggle seconds',colors.blue)
  elseif section==3 then
    U.label(3,6,'Network: '..(C.get('network') and 'Enabled' or 'Disabled')); U.label(3,8,'Wireless/wired status is detected automatically.')
    U.button(3,10,24,2,'Toggle Network',colors.blue)
  elseif section==4 then
    U.label(3,6,'Notifications: '..tostring(C.get('notifications'))); U.label(3,8,'Configuration is stored locally in /pacificos/config.cfg.')
    U.button(3,10,24,2,'Toggle notifications',colors.blue)
  elseif section==5 then
    U.label(3,6,'Boot delay: '..tostring(C.get('boot_delay'))..'s'); U.label(3,8,'Auto start: '..tostring(C.get('autostart')))
    U.button(3,10,24,2,'Toggle autostart',colors.blue); U.button(3,13,24,2,'Boot delay 0.3s',colors.gray)
  elseif section==6 then
    U.label(3,6,'Reset all PacificOS preferences to factory defaults.',colors.yellow); U.button(3,9,28,2,'Reset Settings',colors.red)
  end
  U.button(3,h-3,18,1,'Back',colors.gray); U.status('Q/Esc: close settings | Click a section')
  local e,a,b,c=os.pullEvent()
  if e=='key' then if a==keys.q or a==keys.escape then return end
  elseif e=='mouse_click' or e=='monitor_touch' then
    local x,y=b,c
    local tabW=math.max(8,math.floor((w-4)/#sections)); local tab=math.floor((x-2)/tabW)+1
    if y==3 and tab>=1 and tab<=#sections then section=tab
    elseif section==1 and y>=10 and y<12 and x>=3 and x<27 then term.setCursorPos(3,10); term.clearLine(); write('Hostname: '); local s=read(); if s~='' then C.set('hostname',s) end
    elseif section==2 and y>=14 and y<16 then if x>=3 and x<27 then toggle('animations') elseif x>=29 and x<53 then toggle('sounds') end
    elseif section==2 and y>=17 and y<19 and x>=3 and x<27 then toggle('show_seconds')
    elseif section==3 and y>=10 and y<12 and x>=3 and x<27 then toggle('network')
    elseif section==4 and y>=10 and y<12 and x>=3 and x<27 then toggle('notifications')
    elseif section==5 and y>=10 and y<12 and x>=3 and x<27 then toggle('autostart')
    elseif section==5 and y>=13 and y<15 and x>=3 and x<27 then C.set('boot_delay',(C.get('boot_delay') or 0.3)==0.3 and 0 or 0.3)
    elseif section==6 and y>=9 and y<11 and x>=3 and x<31 then C.reset()
    elseif y>=h-3 and x>=3 and x<21 then return end
  end
 end
end
return M
