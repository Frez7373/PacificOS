local U=dofile('/pacificos/ui/widgets.lua')
local C=dofile('/pacificos/system/config.lua')
local M={}
local sections={'General','Appearance','Network','Security','System','Reset'}

local function toggle(k) C.set(k,not C.get(k)) end
local function button(x,y,w,label,active) U.button(x,y,w,2,label,active and colors.blue or colors.gray) end

function M.run()
 local section=1
 while true do
  local w,h=term.getSize()
  U.clear()
  U.header('Settings  |  '..sections[section])

  local tabW=math.max(10,math.floor((w-4)/#sections))
  for i,s in ipairs(sections) do
   local x=2+(i-1)*tabW
   U.button(x,3,math.min(tabW-1,w-x+1),2,s,i==section and colors.blue or colors.gray)
  end

  if section==1 then
   U.label(3,7,'Hostname: '..tostring(C.get('hostname') or 'pacificos'))
   U.label(3,9,'Default application: '..tostring(C.get('default_app') or 'Files'))
   button(3,11,24,'Change Hostname',true)
   button(3,14,24,'Default: Files',false)
  elseif section==2 then
   U.label(3,7,'Theme: '..tostring(C.get('theme') or 'ocean'))
   U.label(3,9,'Animations: '..tostring(C.get('animations') and 'On' or 'Off'))
   U.label(3,11,'Sounds: '..tostring(C.get('sounds') and 'On' or 'Off'))
   U.label(3,13,'Show seconds: '..tostring(C.get('show_seconds') and 'On' or 'Off'))
   button(3,15,24,'Toggle Animations',true)
   button(29,15,24,'Toggle Sounds',true)
   button(3,18,24,'Toggle Seconds',true)
  elseif section==3 then
   U.label(3,7,'Network: '..(C.get('network') and 'Enabled' or 'Disabled'))
   U.label(3,9,'Modems are detected automatically by PacificOS.')
   button(3,11,24,'Toggle Network',true)
  elseif section==4 then
   U.label(3,7,'Notifications: '..(C.get('notifications') and 'Enabled' or 'Disabled'))
   U.label(3,9,'Security preferences are stored locally.')
   button(3,11,28,'Toggle Notifications',true)
  elseif section==5 then
   U.label(3,7,'Boot delay: '..tostring(C.get('boot_delay') or 0.3)..'s')
   U.label(3,9,'Auto start: '..(C.get('autostart') and 'Enabled' or 'Disabled'))
   button(3,11,24,'Toggle Auto Start',true)
   button(3,14,24,'Toggle Boot Delay',false)
  elseif section==6 then
   U.label(3,7,'Restore all PacificOS preferences to defaults.',colors.yellow)
   button(3,10,28,'Reset Settings',true)
  end

  button(3,h-4,20,'Back',false)
  U.status('Tap a control | Q / Esc = close')
  local e,a,b,c=os.pullEvent()
  if e=='key' then
   if a==keys.q or a==keys.escape or a==keys.backspace then return
   elseif a==keys.left then section=math.max(1,section-1)
   elseif a==keys.right then section=math.min(#sections,section+1)
   end
  elseif e=='mouse_click' or e=='monitor_touch' then
   local x,y=b,c
   if y>=3 and y<5 then
    local idx=math.floor((x-2)/tabW)+1
    if idx>=1 and idx<=#sections then section=idx end
   elseif y>=h-4 and x>=3 and x<23 then
    return
   elseif section==1 and y>=11 and y<13 and x>=3 and x<27 then
    term.setCursorPos(3,11); term.clearLine(); write('Hostname: '); local s=read(); if s and s~='' then C.set('hostname',s) end
   elseif section==1 and y>=14 and y<16 and x>=3 and x<27 then
    C.set('default_app','Files')
   elseif section==2 and y>=15 and y<17 and x>=3 and x<27 then toggle('animations')
   elseif section==2 and y>=15 and y<17 and x>=29 and x<53 then toggle('sounds')
   elseif section==2 and y>=18 and y<20 and x>=3 and x<27 then toggle('show_seconds')
   elseif section==3 and y>=11 and y<13 and x>=3 and x<27 then toggle('network')
   elseif section==4 and y>=11 and y<13 and x>=3 and x<31 then toggle('notifications')
   elseif section==5 and y>=11 and y<13 and x>=3 and x<27 then toggle('autostart')
   elseif section==5 and y>=14 and y<16 and x>=3 and x<27 then C.set('boot_delay',(C.get('boot_delay') or 0.3)==0.3 and 0 or 0.3)
   elseif section==6 and y>=10 and y<12 and x>=3 and x<31 then C.reset()
   end
  end
 end
end
return M
