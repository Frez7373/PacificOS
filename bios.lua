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

local function line(text,color)
  local w=select(1,term.getSize())
  term.setTextColor(color or colors.white)
  write(string.sub(tostring(text or ''),1,math.max(1,w)))
end

local function header(title)
  local w=select(1,term.getSize())
  term.setBackgroundColor(colors.blue)
  term.setTextColor(colors.white)
  term.setCursorPos(1,1)
  write(string.rep(' ',w))
  term.setCursorPos(2,1)
  write('PACIFICOS BIOS')
  if title and title~='' then
    local x=math.max(20,w-#title-1)
    term.setCursorPos(x,1)
    write(string.sub(title,1,w-x+1))
  end
  term.setBackgroundColor(colors.black)
end

local function waitAny()
  while true do
    local e=os.pullEvent()
    if e=='key' or e=='mouse_click' or e=='monitor_touch' then return end
  end
end

local function hardwareScreen()
  clear()
  header('Hardware Information')

  local p=BIOS.hardware()
  local y=3
  line('Computer ID: '..tostring(p.id),colors.white); y=y+1
  line('Computer Label: '..tostring(p.label or 'none'),colors.white); y=y+1
  line('Terminal: '..tostring(p.w)..'x'..tostring(p.h)..'  Color: '..(p.color and 'YES' or 'NO'),colors.white); y=y+2

  line('Detected peripherals:',colors.cyan); y=y+1
  local names={}
  for name,_ in pairs(p.peripherals) do names[#names+1]=name end
  table.sort(names)

  if #names==0 then
    line('  none',colors.lightGray)
  else
    for _,name in ipairs(names) do
      if y>=select(2,term.getSize())-2 then
        line('  ...',colors.lightGray)
        break
      end
      line('  '..name..'  ['..tostring(p.peripherals[name])..']',colors.lightGray)
      y=y+1
    end
  end

  local _,h=term.getSize()
  term.setCursorPos(1,h)
  line('[B] Back   [Enter]/[Esc] Back',colors.lightGray)
  while true do
    local e,a=os.pullEvent()
    if e=='key' and (a==keys.b or a==keys.enter or a==keys.escape or a==keys.backspace) then return end
  end
end

local function systemScreen()
  clear()
  header('System Information')

  local _,h=term.getSize()
  line('PacificOS BIOS version: '..BIOS.version); 
  term.setCursorPos(1,4)
  line('ComputerCraft/CC:Tweaked: '..tostring(os.version and os.version() or 'unknown'))
  term.setCursorPos(1,5)
  line('OS uptime: '..string.format('%.1f seconds',os.clock()))

  local ok,free=pcall(fs.getFreeSpace,'/')
  if ok and free then
    term.setCursorPos(1,7)
    line('Free filesystem space: '..tostring(free)..' bytes')
  end

  term.setCursorPos(1,h)
  line('[B] Back   [Enter]/[Esc] Back',colors.lightGray)
  while true do
    local e,a=os.pullEvent()
    if e=='key' and (a==keys.b or a==keys.enter or a==keys.escape or a==keys.backspace) then return end
  end
end

function BIOS.safeRun(fn,...)
  return pcall(fn,...)
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

    term.setCursorPos(2,3)
    line('CCI BIOS 1.7.0',colors.cyan)
    term.setCursorPos(2,4)
    line('Use Up/Down + Enter, or click an option.',colors.lightGray)

    local startY=6
    for i,item in ipairs(items) do
      local y=startY+(i-1)
      term.setCursorPos(3,y)
      term.setBackgroundColor(i==selected and colors.blue or colors.gray)
      term.setTextColor(colors.white)
      write(string.rep(' ',math.max(1,w-4)))
      term.setCursorPos(4,y)
      write(string.sub(item,1,math.max(1,w-5)))
      term.setBackgroundColor(colors.black)
    end

    term.setCursorPos(2,math.min(h, startY+#items+2))
    line('PacificOS by Complex Computer International (CCI) 2026',colors.lightGray)
    term.setCursorPos(2,h)
    line('[Esc] Exit BIOS',colors.lightGray)

    local e,a,b=os.pullEvent()
    if e=='key' then
      if a==keys.up then selected=math.max(1,selected-1)
      elseif a==keys.down then selected=math.min(#items,selected+1)
      elseif a==keys.enter then
        if selected==1 then return
        elseif selected==2 then hardwareScreen()
        elseif selected==3 then systemScreen()
        elseif selected==4 then os.reboot()
        elseif selected==5 then os.shutdown()
        end
      elseif a==keys.escape or a==keys.q then
        return
      end
    elseif e=='mouse_click' or e=='monitor_touch' then
      local x,y=b or 1,a or 1
      if y>=startY and y<startY+#items and x>=3 then
        selected=y-startY+1
        if selected==1 then return
        elseif selected==2 then hardwareScreen()
        elseif selected==3 then systemScreen()
        elseif selected==4 then os.reboot()
        elseif selected==5 then os.shutdown()
        end
      end
    end
  end
end

return BIOS
