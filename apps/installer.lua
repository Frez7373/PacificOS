local U=dofile("/pacificos/ui/widgets.lua")
local Apps=dofile("/pacificos/system/apps.lua")
local M={}

local ROOT="/pacificos"
local TEMP=ROOT.."/.installer_tmp.lua"

local function clearTemp()
  if fs.exists(TEMP) then fs.delete(TEMP) end
end

local function trim(s)
  return tostring(s or ""):gsub("^%s+",""):gsub("%s+$","")
end

local function safeFile(name)
  local s=trim(name):gsub("[^%w%._%-]","_")
  s=s:gsub("_+","_")
  if s=="" then s="app" end
  if not s:lower():match("%.lua$") then s=s..".lua" end
  return s:sub(1,48)
end

local function writeHttp(url,path)
  if not http then return false,"HTTP API is disabled." end
  local r,e=http.get(url)
  if not r then return false,e or "HTTP request failed." end
  local code=r.getResponseCode and r.getResponseCode() or 200
  local body=r.readAll() or ""
  r.close()
  if code>=400 then return false,"HTTP "..tostring(code) end
  local h=fs.open(path,"w")
  if not h then return false,"Cannot write downloaded file." end
  h.write(body); h.close()
  return true
end

local function downloadWget(url)
  clearTemp()
  if shell and shell.run then
    local ok=pcall(shell.run,"wget",url,TEMP)
    if ok and fs.exists(TEMP) and not fs.isDir(TEMP) then return true end
  end
  return writeHttp(url,TEMP)
end

local function pastebinUrl(code)
  if code:match("^https?://") then
    if code:find("pastebin.com/raw/",1,true) then return code end
    local id=code:match("pastebin.com/([%w]+)")
    if id then return "https://pastebin.com/raw/"..id end
  end
  code=code:gsub("[^%w]","")
  if code=="" then return nil end
  return "https://pastebin.com/raw/"..code
end

local function downloadPastebin(code)
  clearTemp()
  code=trim(code)
  local url=pastebinUrl(code)
  if not url then return false,"Invalid Pastebin code." end
  if shell and shell.run and not code:match("^https?://") then
    local id=code:gsub("[^%w]","")
    local ok=pcall(shell.run,"pastebin","get",id,TEMP)
    if ok and fs.exists(TEMP) and not fs.isDir(TEMP) then return true end
  end
  return writeHttp(url,TEMP)
end

local function validateLua()
  local fn,err=loadfile(TEMP)
  if not fn then return false,"Lua syntax error: "..tostring(err) end
  return true
end

local function install(sourceLabel,okDownload)
  if not okDownload then clearTemp(); return end
  local valid,err=validateLua()
  if not valid then clearTemp(); return false,err end

  U.clear(); U.header("Installer")
  U.label(2,4,"Downloaded from: "..sourceLabel,U._muted)
  U.label(2,6,"Application name:")
  term.setCursorPos(2,7); write("> ")
  local name=trim(read())
  if name=="" then clearTemp(); return false,"Installation cancelled." end

  local existing=Apps.find(name)
  if existing then
    U.label(2,9,"An app with this name is already installed.",colors.yellow)
    U.label(2,10,"Replace it? Type YES to continue.")
    term.setCursorPos(2,11); write("> ")
    if read()~="YES" then clearTemp(); return false,"Installation cancelled." end
    Apps.remove(name)
  end

  local file=safeFile(name)
  local relative="userapps/"..file
  local target=ROOT.."/"..relative
  if fs.exists(target) then
    local base=file:gsub("%.lua$","")
    local n=2
    repeat
      file=base.."_"..n..".lua"
      relative="userapps/"..file
      target=ROOT.."/"..relative
      n=n+1
    until not fs.exists(target)
  end

  fs.move(TEMP,target)
  local ok,regErr=Apps.register(name,relative,sourceLabel)
  if not ok then
    if fs.exists(target) then fs.delete(target) end
    return false,regErr
  end
  return true,"Installed. The app was added to the desktop."
end

local function installWget()
  U.clear(); U.header("Install from WGET")
  U.label(2,4,"Direct URL to a .lua application:")
  term.setCursorPos(2,5); write("> ")
  local url=trim(read())
  if url=="" then return end
  if not url:match("^https?://") then
    U.label(2,7,"URL must start with http:// or https://.",colors.red)
    os.pullEvent("key"); return
  end
  U.label(2,7,"Downloading...")
  local ok,err=downloadWget(url)
  if ok then ok,err=install(url,true) end
  if not ok then U.label(2,9,"Error: "..tostring(err),colors.red); os.pullEvent("key") end
end

local function installPastebin()
  U.clear(); U.header("Install from Pastebin")
  U.label(2,4,"Pastebin code or raw URL:")
  term.setCursorPos(2,5); write("> ")
  local code=trim(read())
  if code=="" then return end
  U.label(2,7,"Downloading...")
  local ok,err=downloadPastebin(code)
  if ok then ok,err=install(code,true) end
  if not ok then U.label(2,9,"Error: "..tostring(err),colors.red); os.pullEvent("key") end
end

function M.run()
  local selected=1
  while true do
    local w,h=term.getSize()
    local list=Apps.list()
    if selected>#list then selected=#list end
    if selected<1 then selected=1 end

    U.clear(); U.header("App Installer")
    U.label(2,3,"Install third-party Lua apps with WGET or Pastebin.",U._muted)

    local rows=math.max(1,h-13)
    for i=1,math.min(#list,rows) do
      local e=list[i]
      local mark=e.desktop and "[DESKTOP]" or "[HIDDEN ]"
      U.button(2,4+i-1,math.max(8,w-4),1,mark.." "..e.name,(i==selected) and colors.blue or colors.gray)
    end

    if #list==0 then U.label(3,6,"No third-party applications installed.",U._muted) end

    local cols=(w>=42) and 3 or 2
    local gap=1
    local bw=math.max(8,math.floor((w-2-(cols-1)*gap)/cols))
    local startY=h-5
    local labels={"WGET","PASTEBIN","LAUNCH","DESKTOP","UNINSTALL","BACK"}

    for i,label in ipairs(labels) do
      local col=(i-1)%cols
      local row=math.floor((i-1)/cols)
      local x=2+col*(bw+gap)
      local y=startY+row*2
      if x+bw-1<=w and y<h then
        local bg=(label=="UNINSTALL") and colors.red or (label=="BACK" and colors.gray or colors.blue)
        if label=="LAUNCH" then bg=colors.green end
        U.button(x,y,bw,1,label,bg)
      end
    end

    U.status("Up/Down select | Enter launch | D desktop | Delete uninstall | Q/Esc back")

    local e,a,b,c=os.pullEvent()
    if e=="key" then
      if a==keys.q or a==keys.escape or a==keys.backspace then clearTemp(); return
      elseif a==keys.up then selected=math.max(1,selected-1)
      elseif a==keys.down then selected=math.min(math.max(1,#list),selected+1)
      elseif a==keys.enter then
        local app=list[selected]
        if app then
          U.clear()
          local ok,res=pcall(dofile,ROOT.."/"..app.path)
          if ok and type(res)=="table" and type(res.run)=="function" then ok,res=pcall(res.run) end
          if not ok then U.label(2,5,"Application crashed:",colors.red); U.label(2,7,tostring(res),colors.red); U.status("Press any key to return"); os.pullEvent() end
        end
      elseif a==keys.d then
        local app=list[selected]; if app then Apps.setDesktop(app.name,not app.desktop) end
      elseif a==keys.delete then
        local app=list[selected]
        if app then
          U.label(2,startY+6,"Delete "..app.name.."? Type YES",colors.yellow)
          term.setCursorPos(2,startY+7); write("> ")
          if read()=="YES" then Apps.remove(app.name) end
        end
      elseif a==keys.one then installWget()
      elseif a==keys.two then installPastebin()
      end
    elseif e=="mouse_click" or e=="monitor_touch" then
      local x,y=b,c
      local row=y-3
      if row>=1 and row<=math.min(#list,rows) then
        selected=row
      else
        for i,label in ipairs(labels) do
          local col=(i-1)%cols
          local rr=math.floor((i-1)/cols)
          local bx=2+col*(bw+gap)
          local by=startY+rr*2
          if x>=bx and x<bx+bw and y>=by and y<by+1 then
            if label=="WGET" then
              installWget()
            elseif label=="PASTEBIN" then
              installPastebin()
            elseif label=="LAUNCH" then
              local app=list[selected]
              if app then
                U.clear()
                local ok,res=pcall(dofile,ROOT.."/"..app.path)
                if ok and type(res)=="table" and type(res.run)=="function" then ok,res=pcall(res.run) end
                if not ok then U.label(2,5,"Application crashed:",colors.red); U.label(2,7,tostring(res),colors.red); U.status("Press any key to return"); os.pullEvent() end
              end
            elseif label=="DESKTOP" then
              local app=list[selected]; if app then Apps.setDesktop(app.name,not app.desktop) end
            elseif label=="UNINSTALL" then
              local app=list[selected]
              if app then
                U.label(2,startY+6,"Delete "..app.name.."? Type YES",colors.yellow)
                term.setCursorPos(2,startY+7); write("> ")
                if read()=="YES" then Apps.remove(app.name) end
              end
            elseif label=="BACK" then
              clearTemp(); return
            end
            break
          end
        end
      end
    end
  end
end

return M
