-- PACIFICOS_BIOS_170
local BIOS={}
BIOS.version='1.7.0'
BIOS.root='/pacificos'

function BIOS.hardware()
  local w,h=term.getSize()
  local p={
    id=os.getComputerID(),
    label=os.getComputerLabel(),
    w=w,
    h=h,
    color=term.isColor(),
    peripherals={}
  }

  for _,name in ipairs(peripheral.getNames()) do
    p.peripherals[name]=peripheral.getType(name)
  end
  return p
end

local function clear()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  term.setCursorPos(1,1)
end

local function drawText(y,text,colorValue)
  local w=select(1,term.getSize())
  y=math.max(1,math.floor(tonumber(y) or 1))
  term.setCursorPos(1,y)
  term.setTextColor(colorValue or colors.white)
  write(string.sub(tostring(text or ''),1,math.max(1,w)))
end

local function header(title)
  local w=select(1,term.getSize())
  term.setBackgroundColor(colors.blue)
  term.setTextColor(colors.white)
  term.setCursorPos(1,1)
  write(string.rep(' ',w))
  term.setCursorPos(2,1)
  write(string.sub('PACIFICOS BIOS',1,math.max(1,w-1)))

  if title and title~='' and w>20 then
    local x=math.min(w-#title,20)
    x=math.max(2,x)
    term.setCursorPos(x,1)
    write(string.sub(title,1,math.max(1,w-x+1)))
  end

  term.setBackgroundColor(colors.black)
end

local function backScreen()
  drawText(select(2,term.getSize()),'[B] Back   [Enter]/[Esc] Back',colors.lightGray)
  while true do
    local e,a=os.pullEvent()
    if e=='key' and (a==keys.b or a==keys.enter or a==keys.escape or a==keys.backspace) then
      return
    elseif e=='mouse_click' or e=='monitor_touch' then
      return
    end
  end
end

local function hardwareScreen()
  clear()
  header('Hardware')

  local p=BIOS.hardware()
  drawText(3,'Computer ID: '..tostring(p.id))
  drawText(4,'Computer Label: '..tostring(p.label or 'none'))
  drawText(5,'Terminal: '..tostring(p.w)..'x'..tostring(p.h)..'  Color: '..(p.color and 'YES' or 'NO'))
  drawText(7,'Detected peripherals:',colors.cyan)

  local names={}
  for name,_ in pairs(p.peripherals) do
    names[#names+1]=name
  end
  table.sort(names)

  local _,h=term.getSize()
  if #names==0 then
    drawText(8,'none',colors.lightGray)
  else
    local y=8
    for _,name in ipairs(names) do
      if y>=h-2 then
        drawText(y,'...',colors.lightGray)
        break
      end
      drawText(y,name..'  ['..tostring(p.peripherals[name])..']',colors.lightGray)
      y=y+1
    end
  end

  backScreen()
end

local function systemScreen()
  clear()
  header('System')

  local version='unknown'
  if type(os.version)=='function' then
    local ok,value=pcall(os.version)
    if ok then version=tostring(value) end
  end

  drawText(3,'PacificOS BIOS version: '..BIOS.version)
  drawText(4,'CC:Tweaked version: '..version)
  drawText(5,'OS uptime: '..string.format('%.1f seconds',os.clock()))

  local ok,free=pcall(fs.getFreeSpace,'/')
  if ok and free then
    drawText(7,'Free filesystem space: '..tostring(free)..' bytes')
  end

  backScreen()
end

function BIOS.safeRun(fn,...)
  return pcall(fn,...)
end

local function activate(selected,items)
  if selected==1 then return 'boot'
  elseif selected==2 then return 'hardware'
  elseif selected==3 then return 'system'
  elseif selected==4 then os.reboot()
  elseif selected==5 then os.shutdown()
  end
end

function BIOS.run()
  local selected=1
  local items={
    'Boot PacificOS',
    'Hardware Information',
    'System Information',
    'Restart Computer',
    'Shutdown Computer'
  }

  while true do
    clear()
    header('Setup Utility')

    local w,h=term.getSize()
    drawText(3,'CCI BIOS 1.7.0',colors.cyan)
    drawText(4,'Use Up/Down + Enter, or click an option.',colors.lightGray)

    local startY=6
    for i,item in ipairs(items) do
      local y=startY+i-1
      term.setCursorPos(3,y)
      term.setBackgroundColor(i==selected and colors.blue or colors.gray)
      term.setTextColor(colors.white)
      write(string.rep(' ',math.max(1,w-4)))
      term.setCursorPos(4,y)
      write(string.sub(item,1,math.max(1,w-5)))
      term.setBackgroundColor(colors.black)
    end

    drawText(math.min(h-1,startY+#items+1),'PacificOS by Complex Computer International (CCI) 2026',colors.lightGray)
    drawText(h,'[Esc] Exit BIOS',colors.lightGray)

    local e,a,b,c=os.pullEvent()
    if e=='key' then
      if a==keys.up then
        selected=math.max(1,selected-1)
      elseif a==keys.down then
        selected=math.min(#items,selected+1)
      elseif a==keys.enter then
        local action=activate(selected,items)
        if action=='boot' then return
        elseif action=='hardware' then hardwareScreen()
        elseif action=='system' then systemScreen()
        end
      elseif a==keys.escape or a==keys.q then
        return
      end
    elseif e=='mouse_click' or e=='monitor_touch' then
      local x,y=b or 1,c or 1
      if x>=3 and y>=startY and y<startY+#items then
        selected=y-startY+1
        local action=activate(selected,items)
        if action=='boot' then return
        elseif action=='hardware' then hardwareScreen()
        elseif action=='system' then systemScreen()
        end
      end
    end
  end
end

return BIOS
