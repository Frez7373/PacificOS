-- PACIFICOS_BIOS_KEY_170
local ROOT='/pacificos'
local T=dofile(ROOT..'/ui/theme.lua')

local function runBIOS()
  local ok,bios=pcall(dofile,ROOT..'/bios.lua')
  if not ok then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.red)
    term.clear()
    term.setCursorPos(2,2)
    print('PACIFICOS BIOS ERROR')
    print('')
    print(tostring(bios))
    print('')
    print('Press any key to continue boot.')
    os.pullEvent()
    return
  end

  if type(bios)~='table' or type(bios.run)~='function' then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.red)
    term.clear()
    term.setCursorPos(2,2)
    print('PACIFICOS BIOS ERROR')
    print('')
    print('bios.lua does not provide BIOS.run().')
    print('')
    print('Press any key to continue boot.')
    os.pullEvent()
    return
  end

  local ok2,err=pcall(bios.run)
  if not ok2 then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.red)
    term.clear()
    term.setCursorPos(2,2)
    print('PACIFICOS BIOS ERROR')
    print('')
    print(tostring(err))
    print('')
    print('Press any key to continue boot.')
    os.pullEvent()
  end
end

local function biosHotkey()
  local w,h=term.getSize()
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  term.setCursorPos(1,1)
  term.setTextColor(T.accent)
  write('PACIFICOS')
  term.setTextColor(T.muted)
  term.setCursorPos(1,3)
  write('Press ] to enter BIOS')
  term.setCursorPos(1,4)
  write('BIOS key window: 1.5 seconds')
  term.setTextColor(T.text)
  term.setCursorPos(1,math.min(h,6))
  write('Complex Computer International (CCI) 2026')

  local timer=os.startTimer(1.5)
  while true do
    local e,a=os.pullEvent()
    if e=='char' and a==']' then
      runBIOS()
      return
    elseif e=='key' and keys.rightBracket and a==keys.rightBracket then
      runBIOS()
      return
    elseif e=='timer' and a==timer then
      return
    end
  end
end

biosHotkey()

local w,h=term.getSize()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
local function center(y,s,c)
 term.setTextColor(c or colors.white)
 term.setCursorPos(math.max(1,math.floor((w-#s)/2)+1),math.max(1,y))
 write(string.sub(s,1,w))
end
local function bar(y,done,total)
 local bw=math.max(12,math.min(w-6,40)); local filled=math.floor(bw*done/total)
 local x=math.floor((w-bw)/2)
 term.setCursorPos(math.max(1,x),y); term.setBackgroundColor(T.dark); write(string.rep(' ',bw))
 term.setCursorPos(math.max(1,x),y); term.setBackgroundColor(T.accent); write(string.rep(' ',filled))
 term.setBackgroundColor(colors.black)
end

local cy=math.max(4,math.floor(h/2)-5)
center(cy,'PACIFICOS',T.accent)
center(cy+2,'PacificOS 1.7.0',T.muted)
center(cy+4,'Complex Computer International (CCI)',T.text)
center(cy+5,'© 2026 CCI',T.muted)

local steps={'Power-on diagnostics','Hardware detection','System files','Kernel','Services','Applications','Graphical interface'}
for i,s in ipairs(steps) do
 local y=math.min(h-4,cy+7)
 bar(y,i-1,#steps)
 term.setTextColor(T.muted); term.setCursorPos(3,math.min(h-2,y+2)); write(string.sub(s,1,math.max(1,w-12)))
 term.setTextColor(T.good); term.setCursorPos(math.max(1,w-8),math.min(h-2,y+2)); write(string.format('%3d%%',math.floor((i-1)*100/#steps)))
 os.sleep(0.12)
end
bar(math.min(h-4,cy+7),#steps,#steps)
term.setTextColor(T.good); term.setCursorPos(3,math.min(h-2,cy+9)); write('SYSTEM READY')
os.sleep(0.25)

if not fs.exists(ROOT..'/kernel.lua') then error('System kernel is missing') end
local ok,err=pcall(dofile,ROOT..'/kernel.lua')
if not ok then
 term.setBackgroundColor(colors.black); term.setTextColor(T.bad); term.clear(); term.setCursorPos(2,2)
 print('PACIFICOS RECOVERY'); print(''); print('Startup failed:'); print(tostring(err)); print(''); print('[R] Recovery   [Q] Shutdown')
 while true do
  local _,k=os.pullEvent('key')
  if k==keys.r then pcall(dofile,ROOT..'/recovery/recovery.lua'); return end
  if k==keys.q then os.shutdown(); return end
 end
end
