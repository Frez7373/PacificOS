local ROOT="/pacificos"
local T=dofile(ROOT.."/ui/theme.lua")
local U=dofile(ROOT.."/ui/widgets.lua")
local C=dofile(ROOT.."/system/config.lua")
local D=dofile(ROOT.."/system/devices.lua")
local N=dofile(ROOT.."/system/network.lua")
local ThirdParty=dofile(ROOT.."/system/apps.lua")

local builtins={
  {"Files","apps/files.lua"},
  {"Settings","apps/settings.lua"},
  {"Calculator","apps/calculator2.lua"},
  {"Clock","apps/clock.lua"},
  {"Calendar","apps/calendar.lua"},
  {"Network","apps/network.lua"},
  {"Devices","apps/devices.lua"},
  {"Editor","apps/editor.lua"},
  {"Terminal","apps/terminal.lua"},
  {"Task Manager","apps/task_manager.lua"},
  {"Updater","apps/updater.lua"},
  {"App Installer","apps/installer.lua"},
  {"Antivirus","apps/antivirus.lua"},
  {"System Info","apps/system_info.lua"},
  {"System Monitor","apps/system_monitor.lua"},
  {"Stopwatch","apps/stopwatch.lua"},
  {"Converter","apps/converter.lua"},
  {"About","apps/about.lua"}
}

local function getApps()
  local result={}
  for _,a in ipairs(builtins) do
    result[#result+1]={name=a[1],path=a[2],builtin=true}
  end
  for _,a in ipairs(ThirdParty.listDesktop()) do
    result[#result+1]={name=a.name,path=a.path,builtin=false,external=true}
  end
  return result
end

local function layout()
  local w,h=term.getSize()
  local cols=w>=80 and 4 or (w>=55 and 3 or (w>=38 and 2 or 1))
  local rows=math.max(1,math.floor((h-10)/3))
  return cols*rows,cols,rows
end

local function runApp(app)
  term.setBackgroundColor(T.bg)
  term.setTextColor(T.text)
  term.clear()
  term.setCursorPos(1,1)

  local ok,res=pcall(dofile,ROOT.."/"..app.path)
  if ok and type(res)=="table" and type(res.run)=="function" then
    ok,res=pcall(res.run)
  elseif ok and type(res)=="function" then
    ok,res=pcall(res)
  end

  if not ok then
    term.setBackgroundColor(T.bg); term.setTextColor(T.bad); term.clear(); term.setCursorPos(2,2)
    print("Application crashed")
    print("")
    print(tostring(res))
    print("")
    print("Press any key to return to the desktop.")
    os.pullEvent()
  end
end

local function draw()
  local apps=getApps()
  local w,h=term.getSize()
  local perPage,cols,rows=layout()
  local pages=math.max(1,math.ceil(#apps/perPage))
  local page=math.max(1,math.min(kernelPage or 1,pages))
  kernelPage=page

  U.clear(T.bg)
  U.fill(1,1,w,3,T.panel)
  U.label(2,2,"PACIFICOS",T.text)
  local clock=textutils.formatTime(os.time(),C.get("show_seconds") and true or false)
  local right=clock.."  ID "..tostring(os.getComputerID())
  U.label(math.max(1,w-#right),2,right,T.muted)

  U.label(2,5,"Welcome back",T.accent)
  U.label(2,6,tostring(C.get("hostname") or "pacificos"),T.muted)
  local third=#ThirdParty.list()
  local badge="CCI 2026"
  if third>0 then badge=badge.." | "..third.." installed"
  end
  U.label(math.max(1,w-#badge),6,badge,T.muted)

  local gap=2
  local bw=math.max(10,math.floor((w-6-(cols-1)*gap)/cols))
  local first=(page-1)*perPage+1
  for i=0,perPage-1 do
    local idx=first+i
    local app=apps[idx]
    if not app then break end
    local col=i%cols
    local row=math.floor(i/cols)
    local x=3+col*(bw+gap)
    local y=8+row*3
    local bg=app.external and T.panel2 or T.card
    U.button(x,y,bw,2,app.name,bg)
  end

  local fy=math.max(1,h-2)
  local prevW=12
  local nextW=12
  local shutW=14
  if w>=42 then
    U.button(2,fy,prevW,"",T.dark)
    U.button(2,fy,prevW,"< PREV",kernelPage>1 and T.card or T.dark)
    local nx=math.max(prevW+4,math.floor((w-nextW)/2))
    U.button(nx,fy,nextW,"NEXT >",kernelPage<pages and T.card or T.dark)
    U.button(math.max(nx+nextW+2,w-shutW+1),fy,shutW,"SHUTDOWN",T.card)
    U.center(fy,"Page "..kernelPage.."/"..pages,T.muted)
  else
    U.center(fy,"Page "..kernelPage.."/"..pages,T.muted)
  end
  U.label(2,h,"Network "..(#N.list()>0 and "AVAILABLE" or "OFFLINE").." | Devices "..tostring(#D.list()),T.muted)
end

local function hitApp(x,y)
  local apps=getApps()
  local perPage,cols,rows=layout()
  local w,h=term.getSize()
  local gap=2
  local bw=math.max(10,math.floor((w-6-(cols-1)*gap)/cols))
  if y<8 or y>=h-3 then return nil end
  for i=0,perPage-1 do
    local idx=(kernelPage-1)*perPage+i+1
    local app=apps[idx]
    if app then
      local col=i%cols
      local row=math.floor(i/cols)
      local bx=3+col*(bw+gap)
      local by=8+row*3
      if U.hit(bx,by,bw,2,x,y) then return app end
    end
  end
  return nil
end

local kernelPage=1
while true do
  draw()
  local e,a,b,c=os.pullEvent()
  local w,h=term.getSize()

  if e=="mouse_click" or e=="monitor_touch" then
    local x,y=b,c
    local fy=math.max(1,h-2)
    if y>=fy and y<h then
      local prevW=12
      local nextW=12
      local shutW=14
      if w>=42 then
        local nx=math.max(prevW+4,math.floor((w-nextW)/2))
        if x>=2 and x<2+prevW then kernelPage=math.max(1,kernelPage-1)
        elseif x>=nx and x<nx+nextW then
          local total=math.ceil(#getApps()/layout())
          kernelPage=math.min(math.max(1,total),kernelPage+1)
        elseif x>=w-shutW+1 then os.shutdown() end
      end
    else
      local app=hitApp(x,y)
      if app then runApp(app) end
    end
  elseif e=="key" then
    local apps=getApps()
    if a==keys.f12 then os.shutdown()
    elseif a==keys.left then kernelPage=math.max(1,kernelPage-1)
    elseif a==keys.right or a==keys.pageDown then
      kernelPage=math.min(math.max(1,math.ceil(#apps/layout())),kernelPage+1)
    elseif a==keys.pageUp then kernelPage=math.max(1,kernelPage-1)
    elseif a==keys.f1 and apps[1] then runApp(apps[1])
    elseif a==keys.f2 and apps[2] then runApp(apps[2])
    elseif a==keys.f3 and apps[3] then runApp(apps[3])
    end
  elseif e=="terminate" then
    return
  end
end
