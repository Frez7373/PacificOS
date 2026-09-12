local ROOT='/pacificos'
local T=dofile(ROOT..'/ui/theme.lua'); local U=dofile(ROOT..'/ui/widgets.lua'); local C=dofile(ROOT..'/system/config.lua'); local D=dofile(ROOT..'/system/devices.lua'); local N=dofile(ROOT..'/system/network.lua')
local apps={{'Files','apps/files.lua'},{'Settings','apps/settings.lua'},{'Calculator','apps/calculator2.lua'},{'Clock','apps/clock.lua'},{'Calendar','apps/calendar.lua'},{'Network','apps/network.lua'},{'Devices','apps/devices.lua'},{'Editor','apps/editor.lua'},{'Terminal','apps/terminal.lua'},{'Task Manager','apps/task_manager.lua'},{'Updater','apps/updater.lua'},{'Antivirus','apps/antivirus.lua'},{'System Info','apps/system_info.lua'},{'About','apps/about.lua'}}
local function runApp(a)
 term.setBackgroundColor(T.bg); term.clear(); term.setCursorPos(1,1)
 local ok,m=pcall(dofile,ROOT..'/'..a[2])
 if ok and type(m)=='table' and type(m.run)=='function' then ok,m=pcall(m.run) end
 if not ok then term.setBackgroundColor(T.bg); term.setTextColor(T.bad); term.clear(); term.setCursorPos(2,3); print('Application crashed'); print(''); print(tostring(m)); print(''); print('Press any key to return.'); os.pullEvent('key') end
end
local function draw(startOpen)
 local w,h=term.getSize(); U.clear(T.bg)
 term.setBackgroundColor(T.panel); U.fill(1,1,w,3,T.panel); term.setCursorPos(2,2); term.setTextColor(T.text); write('PACIFICOS')
 term.setTextColor(T.muted); term.setCursorPos(math.max(1,w-17),2); write(textutils.formatTime(os.time(),true)..'  ID '..os.getComputerID())
 term.setTextColor(T.accent); term.setCursorPos(2,5); write('Welcome back')
 term.setTextColor(T.muted); term.setCursorPos(2,6); write(tostring(C.get('hostname')))
 local cols=w>=70 and 4 or (w>=48 and 3 or 2); local bw=math.max(10,math.floor((w-6-(cols-1)*2)/cols)); local y=8
 for i,a in ipairs(apps) do local col=(i-1)%cols; local row=math.floor((i-1)/cols); local x=3+col*(bw+2); local yy=y+row*3; if yy<h-5 then U.button(x,yy,bw,2,a[1],T.card) end end
 U.fill(1,h-3,w,3,T.panel); U.button(2,h-2,12,1,'MENU',T.card); term.setCursorPos(16,h-2); term.setTextColor(T.muted); write('Network '..(#N.list()>0 and 'ONLINE' or 'OFFLINE')..'  |  Devices '..#D.list())
 if startOpen then U.fill(2,h-15,28,12,T.panel); term.setTextColor(T.text); term.setCursorPos(4,h-14); write('APPLICATIONS'); local yy=h-12; for i=1,math.min(#apps,8) do U.button(4,yy,23,1,apps[i][1],T.card); yy=yy+1 end end
end
local function hitApp(x,y)
 local w=select(1,term.getSize()); local cols=w>=70 and 4 or (w>=48 and 3 or 2); local bw=math.max(10,math.floor((w-6-(cols-1)*2)/cols)); if y<8 then return end
 local col=math.floor((x-3)/(bw+2)); local row=math.floor((y-8)/3); if col<0 or col>=cols or row<0 then return end
 local i=row*cols+col+1; local a=apps[i]; if a and x>=3+col*(bw+2) and x<3+col*(bw+2)+bw and y>=8+row*3 and y<10+row*3 then return a end
end
local menu=false
while true do
 draw(menu); local e,a,b,c=os.pullEvent()
 if e=='mouse_click' or e=='monitor_touch' then
  if b>=2 and b<=13 and c==select(2,term.getSize())-2 then menu=not menu
  elseif menu and b>=4 and b<=27 and c>=select(2,term.getSize())-12 and c<select(2,term.getSize())-4 then local idx=c-(select(2,term.getSize())-12); if idx>=1 and idx<=#apps then menu=false; runApp(apps[idx]) end
  else local app=hitApp(b,c); if app then runApp(app) end end
 elseif e=='key' and a==keys.f12 then os.shutdown() elseif e=='key' and a==keys.f1 then runApp(apps[1]) elseif e=='terminate' then return end
end
