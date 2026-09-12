local ROOT='/pacificos'
local T=dofile(ROOT..'/ui/theme.lua')
local U=dofile(ROOT..'/ui/widgets.lua')
local C=dofile(ROOT..'/system/config.lua')
local D=dofile(ROOT..'/system/devices.lua')
local N=dofile(ROOT..'/system/network.lua')
local apps={
 {name='Files',path='apps/files.lua'}, {name='Settings',path='apps/settings.lua'}, {name='Calculator',path='apps/calculator.lua'},
 {name='Clock',path='apps/clock.lua'}, {name='Calendar',path='apps/calendar.lua'}, {name='Network',path='apps/network.lua'},
 {name='Devices',path='apps/devices.lua'}, {name='Editor',path='apps/editor.lua'}, {name='Terminal',path='apps/terminal.lua'},
 {name='Task Manager',path='apps/task_manager.lua'}, {name='Updater',path='apps/updater.lua'}, {name='Antivirus',path='apps/antivirus.lua'},
 {name='System Info',path='apps/system_info.lua'}, {name='About',path='apps/about.lua'} }
local running={}; local nextPid=0
local function launch(a)
 nextPid=nextPid+1; local pid=nextPid; running[pid]={pid=pid,name=a.name,state='running'}
 local ok,err=pcall(dofile,ROOT..'/'..a.path)
 if ok and type(err)=='table' and err.run then
   local ok2,e2=pcall(err.run,{pid=pid,name=a.name})
   if not ok2 then running[pid].state='crashed'; running[pid].error=tostring(e2) end
 elseif not ok then running[pid].state='crashed'; running[pid].error=tostring(err) end
 running[pid].state='closed'
end
local function desktop()
 local w,h=term.getSize(); term.setBackgroundColor(T.bg); term.setTextColor(T.text); term.clear()
 term.setBackgroundColor(T.panel); term.setCursorPos(1,1); write(' PACIFICOS')
 term.setCursorPos(math.max(1,w-8),1); write(textutils.formatTime(os.time(),true))
 term.setBackgroundColor(T.bg)
 term.setCursorPos(2,3); term.setTextColor(T.accent); write('Welcome to PacificOS')
 term.setTextColor(T.text); term.setCursorPos(2,4); write(C.get('hostname')..'  |  ID '..os.getComputerID())
 local cols=math.max(1,math.floor((w-4)/18)); local y=7
 for i,a in ipairs(apps) do
   local col=(i-1)%cols; local row=math.floor((i-1)/cols); local x=2+col*18; local yy=y+row*3
   if yy<h-2 then U.button(x,yy,16,2,a.name,T.panel) end
 end
 U.status('Network: '..(#N.list()>0 and 'modem detected' or 'offline')..'   Devices: '..#D.list()..'   Touch/click an app')
end
local function hitApp(x,y)
 local w,h=term.getSize(); local cols=math.max(1,math.floor((w-4)/18)); local col=math.floor((x-2)/18); local row=math.floor((y-7)/3); local i=row*cols+col+1; local a=apps[i]; if a and x>=2+col*18 and x<18+col*18 and y>=7+row*3 and y<9+row*3 then return a end end
term.setTextColor(T.text)
while true do
 desktop()
 local e,a,b,c=os.pullEvent()
 if e=='mouse_click' or e=='monitor_touch' then local app=hitApp(b,c); if app then launch(app) end
 elseif e=='key' and a==keys.f1 then launch(apps[1])
 elseif e=='key' and a==keys.f12 then os.shutdown()
 elseif e=='terminate' then break
 end
end
