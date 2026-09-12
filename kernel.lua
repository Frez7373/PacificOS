local ROOT='/pacificos'
local T=dofile(ROOT..'/ui/theme.lua'); local U=dofile(ROOT..'/ui/widgets.lua'); local C=dofile(ROOT..'/system/config.lua'); local D=dofile(ROOT..'/system/devices.lua'); local N=dofile(ROOT..'/system/network.lua')
local apps={
 {'Files','apps/files.lua'},{'Settings','apps/settings.lua'},{'Calculator','apps/calculator2.lua'},{'Clock','apps/clock.lua'},
 {'Calendar','apps/calendar.lua'},{'Network','apps/network.lua'},{'Devices','apps/devices.lua'},{'Editor','apps/editor.lua'},
 {'Terminal','apps/terminal.lua'},{'Task Manager','apps/task_manager.lua'},{'Updater','apps/updater.lua'},{'Antivirus','apps/antivirus.lua'},
 {'System Info','apps/system_info.lua'},{'System Monitor','apps/system_monitor.lua'},{'Stopwatch','apps/stopwatch.lua'},{'Converter','apps/converter.lua'},{'About','apps/about.lua'}
}
local page=1
local function pageSize()
 local w,h=term.getSize(); local cols=w>=80 and 4 or (w>=55 and 3 or 2); local rows=math.max(1,math.floor((h-10)/3)); return cols*rows,cols,rows
end
local function runApp(a)
 term.setBackgroundColor(T.bg); term.clear(); term.setCursorPos(1,1)
 local ok,m=pcall(dofile,ROOT..'/'..a[2])
 if ok and type(m)=='table' and type(m.run)=='function' then ok,m=pcall(m.run) end
 if not ok then term.setBackgroundColor(T.bg); term.setTextColor(T.bad); term.clear(); term.setCursorPos(2,3); print('Application crashed'); print(''); print(tostring(m)); print(''); print('Press any key to return.'); os.pullEvent('key') end
end
local function draw()
 local w,h=term.getSize(); local count,cols,rows=pageSize(); local totalPages=math.max(1,math.ceil(#apps/count)); if page>totalPages then page=totalPages end
 U.clear(T.bg); U.fill(1,1,w,3,T.panel); U.label(2,2,'PACIFICOS',T.text); U.label(math.max(1,w-22),2,textutils.formatTime(os.time(),true)..' ID '..os.getComputerID(),T.muted)
 U.label(2,5,'Welcome back',T.accent); U.label(2,6,tostring(C.get('hostname')),T.muted)
 local bw=math.max(10,math.floor((w-6-(cols-1)*2)/cols)); local first=(page-1)*count+1
 for i=0,count-1 do local idx=first+i; local a=apps[idx]; if not a then break end; local col=i%cols; local row=math.floor(i/cols); local x=3+col*(bw+2); local y=8+row*3; U.button(x,y,bw,2,a[1],T.card) end
 U.fill(1,h-3,w,3,T.panel); U.button(2,h-2,10,1,'< PREV',page>1 and T.card or T.dark); U.button(14,h-2,12,1,'NEXT >',page<totalPages and T.card or T.dark); U.button(w-15,h-2,13,1,'SHUTDOWN',T.card)
 U.label(math.floor(w/2)-8,h-2,'Page '..page..'/'..totalPages,T.muted); U.label(2,h-1,'Network '..(#N.list()>0 and 'ONLINE' or 'OFFLINE')..' | Devices '..#D.list(),T.muted)
end
local function hitApp(x,y)
 local count,cols,rows=pageSize(); local w,h=term.getSize(); local bw=math.max(10,math.floor((w-6-(cols-1)*2)/cols)); if y<8 or y>=h-3 then return end
 local col=math.floor((x-3)/(bw+2)); local row=math.floor((y-8)/3); if col<0 or col>=cols or row<0 or row>=rows then return end
 local idx=(page-1)*count+row*cols+col+1; local a=apps[idx]; if a and x>=3+col*(bw+2) and x<3+col*(bw+2)+bw and y>=8+row*3 and y<10+row*3 then return a end
end
while true do
 draw(); local e,a,b,c=os.pullEvent(); local w,h=term.getSize()
 if e=='mouse_click' or e=='monitor_touch' then
  if c>=h-3 and c<h then
    if b>=2 and b<12 and page>1 then page=page-1 elseif b>=14 and b<26 then local count=pageSize(); local total=math.max(1,math.ceil(#apps/count)); if page<total then page=page+1 end elseif b>=w-15 then os.shutdown() end
  else local app=hitApp(b,c); if app then runApp(app) end end
 elseif e=='key' then
  if a==keys.f12 then os.shutdown() elseif a==keys.left then page=math.max(1,page-1) elseif a==keys.right then local count=pageSize(); page=math.min(math.max(1,math.ceil(#apps/count)),page+1) elseif a==keys.f1 then runApp(apps[1]) end
 elseif e=='terminate' then return end
end
