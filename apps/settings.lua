local U=dofile('/pacificos/ui/widgets.lua')
local C=dofile('/pacificos/system/config.lua')
local M={}
local sections={'General','Appearance','Network','Security','System','Reset'}

local function toggle(k)
  C.set(k,not not (not C.get(k)))
end

local function safeButton(x,y,w,label,active)
  local sw,sh=term.getSize()
  w=math.max(1,math.min(tonumber(w) or 20,sw-x+1))
  if y>=2 and y+1<sh and x<=sw then
    U.button(x,y,w,2,label,active and colors.blue or colors.gray)
  end
end

function M.run()
  local section=1
  while true do
    local w,h=term.getSize()
    U.clear()
    U.header('Settings  |  '..sections[section])

    local tabCols
    if w>=70 then tabCols=6
    elseif w>=42 then tabCols=3
    else tabCols=2 end

    local tabGap=1
    local tabW=math.max(8,math.floor((w-2-(tabCols-1)*tabGap)/tabCols))
    local tabRows=math.ceil(#sections/tabCols)

    for i,s in ipairs(sections) do
      local col=(i-1)%tabCols
      local row=math.floor((i-1)/tabCols)
      local x=2+col*(tabW+tabGap)
      local y=3+row*2
      U.button(x,y,math.min(tabW,w-x+1),1,s,i==section and colors.blue or colors.gray)
    end

    local top=3+tabRows*2+1
    local x=2
    local buttonW=math.min(28,math.max(8,w-3))

    if section==1 then
      U.label(x,top,'Hostname: '..tostring(C.get('hostname') or 'pacificos'))
      U.label(x,top+2,'Default app: '..tostring(C.get('default_app') or 'Files'))
      safeButton(x,top+4,buttonW,'Change Hostname',true)
      safeButton(x,top+7,buttonW,'Default: Files',false)
    elseif section==2 then
      U.label(x,top,'Theme: '..tostring(C.get('theme') or 'ocean'))
      U.label(x,top+2,'Animations: '..(C.get('animations') and 'On' or 'Off'))
      U.label(x,top+4,'Sounds: '..(C.get('sounds') and 'On' or 'Off'))
      U.label(x,top+6,'Seconds: '..(C.get('show_seconds') and 'On' or 'Off'))
      safeButton(x,top+8,buttonW,'Toggle Animations',true)
      safeButton(x,top+11,buttonW,'Toggle Sounds',true)
    elseif section==3 then
      U.label(x,top,'Network: '..(C.get('network') and 'Enabled' or 'Disabled'))
      U.label(x,top+2,'Modems detected automatically.')
      safeButton(x,top+4,buttonW,'Toggle Network',true)
    elseif section==4 then
      U.label(x,top,'Notifications: '..(C.get('notifications') and 'Enabled' or 'Disabled'))
      U.label(x,top+2,'Preferences are stored locally.')
      safeButton(x,top+4,buttonW,'Toggle Notifications',true)
    elseif section==5 then
      U.label(x,top,'Boot delay: '..tostring(C.get('boot_delay') or 0.3)..'s')
      U.label(x,top+2,'Auto start: '..(C.get('autostart') and 'Enabled' or 'Disabled'))
      safeButton(x,top+4,buttonW,'Toggle Auto Start',true)
      safeButton(x,top+7,buttonW,'Toggle Boot Delay',false)
    elseif section==6 then
      U.label(x,top,'Restore PacificOS preferences to defaults.',colors.yellow)
      safeButton(x,top+3,buttonW,'Reset Settings',true)
    end

    safeButton(2,h-2,math.min(20,w-2),'Back',false)
    U.status('Q / Esc / Backspace = close | Left/Right = sections')

    local e,a,b,c=os.pullEvent()
    if e=='key' then
      if a==keys.q or a==keys.escape or a==keys.backspace then return
      elseif a==keys.left then section=math.max(1,section-1)
      elseif a==keys.right then section=math.min(#sections,section+1)
      end
    elseif e=='mouse_click' or e=='monitor_touch' then
      local x0,y=b,c
      local selected=nil

      if y>=3 and y<3+tabRows*2 and x0>=2 then
        local col=math.floor((x0-2)/(tabW+tabGap))
        local row=math.floor((y-3)/2)
        if col>=0 and col<tabCols and row>=0 and row<tabRows then
          local i=row*tabCols+col+1
          local left=2+col*(tabW+tabGap)
          if x0>=left and x0<left+tabW and i<=#sections then selected=i end
        end
      end

      if selected then
        section=selected
      elseif y>=h-2 and y<h and x0>=2 and x0<2+math.min(20,w-2) then
        return
      elseif section==1 and y>=top+4 and y<top+6 and x0>=x and x0<x+buttonW then
        term.setCursorPos(x,math.min(h-1,top+6))
        term.clearLine()
        write('Hostname: ')
        local s=read()
        if s and s~='' then C.set('hostname',s) end
      elseif section==1 and y>=top+7 and y<top+9 and x0>=x and x0<x+buttonW then
        C.set('default_app','Files')
      elseif section==2 and y>=top+8 and y<top+10 and x0>=x and x0<x+buttonW then
        toggle('animations')
      elseif section==2 and y>=top+11 and y<top+13 and x0>=x and x0<x+buttonW then
        toggle('sounds')
      elseif section==3 and y>=top+4 and y<top+6 and x0>=x and x0<x+buttonW then
        toggle('network')
      elseif section==4 and y>=top+4 and y<top+6 and x0>=x and x0<x+buttonW then
        toggle('notifications')
      elseif section==5 and y>=top+4 and y<top+6 and x0>=x and x0<x+buttonW then
        toggle('autostart')
      elseif section==5 and y>=top+7 and y<top+9 and x0>=x and x0<x+buttonW then
        C.set('boot_delay',(tonumber(C.get('boot_delay')) or 0.3)==0.3 and 0 or 0.3)
      elseif section==6 and y>=top+3 and y<top+5 and x0>=x and x0<x+buttonW then
        C.reset()
      end
    end
  end
end

return M
