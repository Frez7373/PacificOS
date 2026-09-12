local ROOT='/pacificos'
local T=dofile(ROOT..'/ui/theme.lua')
local w,h=term.getSize()
term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.clear()
local function center(y,s,c) term.setTextColor(c or colors.white); term.setCursorPos(math.max(1,math.floor((w-#s)/2)+1),y); write(s) end
center(math.max(2,math.floor(h/2)-5),'PACIFICOS',T.accent)
center(math.max(3,math.floor(h/2)-3),'PacificOS 1.4.0',T.muted)
center(math.max(4,math.floor(h/2)-1),'Complex Computer International (CCI) • 2026',T.text)
local steps={'Hardware','System files','Kernel','Services','Applications','Graphical interface'}
for i,s in ipairs(steps) do local y=math.min(h-3,math.floor(h/2)+i-2); term.setCursorPos(3,y); term.setTextColor(T.muted); write(s..string.rep('.',math.max(1,20-#s))); term.setTextColor(T.good); write(' OK'); os.sleep(0.12) end
if not fs.exists(ROOT..'/kernel.lua') then error('System kernel is missing') end
term.setCursorPos(3,math.min(h-1,math.floor(h/2)+#steps)); term.setTextColor(T.accent); write('Starting PacificOS...'); os.sleep(0.25)
local ok,err=pcall(dofile,ROOT..'/kernel.lua')
if not ok then
 term.setBackgroundColor(colors.black); term.setTextColor(T.bad); term.clear(); term.setCursorPos(2,2); print('PACIFICOS RECOVERY'); print(''); print('Startup failed:'); print(tostring(err)); print(''); print('[R] Recovery   [Q] Shutdown')
 while true do local _,k=os.pullEvent('key'); if k==keys.r then pcall(dofile,ROOT..'/recovery/recovery.lua'); return elseif k==keys.q then os.shutdown(); return end end
end
