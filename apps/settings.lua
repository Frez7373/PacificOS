local U=dofile('/pacificos/ui/widgets.lua')
local C=dofile('/pacificos/system/config.lua')
local M={}
local sections={'General','Appearance','Network','Security','System','Reset'}
local function toggle(k) C.set(k,not not (not C.get(k))) end
local function button(x,y,w,label,active) if y+1<term.getSize() then U.button(x,y,w,2,label,active and colors.blue or colors.gray) end end
local function sectionAt(x,y,w)
 if w<70 then
  if x>=2 and x<24 and y>=3 and y<3+#sections*2 then return math.floor((y-3)/2)+1 end
 else
  local tabW=math.max(7,math.floor((w-4)/#sections))
  if y>=3 and y<5 then return math.floor((x-2)/tabW)+1 end
 end
end
function M.run()
 local section=1
 while true do
  local w,h=term.getSize(); U.clear(); U.header('Settings  |  '..sections[section])
  local top=6
  if w<70 then
   for i,s in ipairs(sections) do U.button(2,3+(i-1)*2,20,1,s,i==section and colors.blue or colors.gray) end
   top=5
  else
   local tabW=math.max(7,math.floor((w-4)/#sections))
   for i,s in ipairs(sections) do U.button(2+(i-1)*tabW,3,tabW,1,s,i==section and colors.blue or colors.gray) end
  end
  local x=w<70 and 26 or 3
  if section==1 then
   U.label(x,top,'Hostname: '..tostring(C.get('hostname') or 'pacificos'))
   U.label(x,top+2,'Default application: '..tostring(C.get('default_app') or 'Files'))
   if w>=55 then button(x,top+4,24,'Change Hostname',true); button(x,top+7,24,'Default: Files',false) end
  elseif section==2 then
   U.label(x,top,'Theme: '..tostring(C.get('theme') or 'ocean'))
   U.label(x,top+2,'Animations: '..(C.get('animations') and 'On' or 'Off'))
   U.label(x,top+4,'Sounds: '..(C.get('sounds') and 'On' or 'Off'))
   U.label(x,top+6,'Show seconds: '..(C.get('show_seconds') and 'On' or 'Off'))
   button(x,top+8,24,'Toggle Animations',true); button(x,top+11,24,'Toggle Sounds',true)
  elseif section==3 then
   U.label(x,top,'Network: '..(C.get('network') and 'Enabled' or 'Disabled'))
   U.label(x,top+2,'Modems are detected automatically.')
   button(x,top+4,24,'Toggle Network',true)
  elseif section==4 then
   U.label(x,top,'Notifications: '..(C.get('notifications') and 'Enabled' or 'Disabled'))
   U.label(x,top+2,'Security preferences are stored locally.')
   button(x,top+4,28,'Toggle Notifications',true)
  elseif section==5 then
   U.label(x,top,'Boot delay: '..tostring(C.get('boot_delay') or 0.3)..'s')
   U.label(x,top+2,'Auto start: '..(C.get('autostart') and 'Enabled' or 'Disabled'))
   button(x,top+4,24,'Toggle Auto Start',true); button(x,top+7,24,'Toggle Boot Delay',false)
  elseif section==6 then
   U.label(3,top,'Restore all PacificOS preferences to defaults.',colors.yellow)
   button(3,top+3,28,'Reset Settings',true)
  end
  button(3,h-4,20,'Back',false); U.status('Q / Esc / Backspace = close | Arrows = sections')
  local e,a,b,c=os.pullEvent()
  if e=='key' then
   if a==keys.q or a==keys.escape or a==keys.backspace then return
   elseif a==keys.left then section=math.max(1,section-1)
   elseif a==keys.right then section=math.min(#sections,section+1)
   end
  elseif e=='mouse_click' or e=='monitor_touch' then
   local x0,y=b,c; local selected=sectionAt(x0,y,w)
   if selected and selected>=1 and selected<=#sections then section=selected
   elseif y>=h-4 and y<h-2 and x0>=3 and x0<23 then return
   elseif section==1 and w>=55 and y>=top+4 and y<top+6 and x0>=x and x0<x+24 then
    term.setCursorPos(x,top+6); term.clearLine(); write('Hostname: '); local s=read(); if s and s~='' then C.set('hostname',s) end
   elseif section==1 and w>=55 and y>=top+7 and y<top+9 and x0>=x and x0<x+24 then C.set('default_app','Files')
   elseif section==2 and y>=top+8 and y<top+10 and x0>=x and x0<x+24 then toggle('animations')
   elseif section==2 and y>=top+11 and y<top+13 and x0>=x and x0<x+24 then toggle('sounds')
   elseif section==3 and y>=top+4 and y<top+6 and x0>=x and x0<x+24 then toggle('network')
   elseif section==4 and y>=top+4 and y<top+6 and x0>=x and x0<x+28 then toggle('notifications')
   elseif section==5 and y>=top+4 and y<top+6 and x0>=x and x0<x+24 then toggle('autostart')
   elseif section==5 and y>=top+7 and y<top+9 and x0>=x and x0<x+24 then C.set('boot_delay',(tonumber(C.get('boot_delay')) or 0.3)==0.3 and 0 or 0.3)
   elseif section==6 and y>=top+3 and y<top+5 and x0>=3 and x0<31 then C.reset()
   end
  end
 end
end
return M
