-- PacificOS 1.7.4 installer
local BASE="https://raw.githubusercontent.com/Frez7373/PacificOS/main/"
local ROOT="/pacificos"
local VERSION="1.7.4"

local files={
  "boot.lua","bios.lua","kernel.lua","manifest.lua",
  "system/module.lua","system/config.lua","system/filesystem.lua","system/devices.lua","system/network.lua","system/security.lua","system/updater.lua","system/apps.lua",
  "ui/theme.lua","ui/widgets.lua","ui/windows.lua",
  "apps/settings.lua","apps/files.lua","apps/editor.lua","apps/task_manager.lua","apps/terminal.lua","apps/network.lua","apps/devices.lua","apps/updater.lua","apps/antivirus.lua","apps/calculator2.lua","apps/clock.lua","apps/calendar.lua","apps/system_info.lua","apps/system_monitor.lua","apps/stopwatch.lua","apps/converter.lua","apps/about.lua","apps/installer.lua",
  "recovery/recovery.lua","recovery/factory_reset.lua"
}

local function mkdirs(path)
  local dir=fs.getDir(path)
  if dir=="" then return end
  local cur=""
  for part in string.gmatch(dir,"[^/]+") do
    cur=cur=="" and part or cur.."/"..part
    if not fs.exists("/"..cur) then
      fs.makeDir("/"..cur)
    end
  end
end

local function get(path)
  if not http then
    return nil,"HTTP API is disabled in CC:Tweaked."
  end

  local url=BASE..path
  local response,err=http.get(url)

  if not response then
    return nil,tostring(err or "HTTP request failed")
  end

  local code=200
  if type(response.getResponseCode)=="function" then
    code=response.getResponseCode() or 200
  end

  if code<200 or code>=400 then
    local body=""
    if type(response.readAll)=="function" then
      body=response.readAll() or ""
    end
    if type(response.close)=="function" then response.close() end
    return nil,"HTTP "..tostring(code).." for "..url
  end

  local body=response.readAll() or ""
  response.close()

  if body=="" then
    return nil,"Empty response from "..url
  end

  return body
end

local function writeFile(path,body)
  local full=ROOT.."/"..path
  if path=="startup.lua" then
    full="/startup.lua"
  end

  mkdirs(full)

  local h=fs.open(full,"w")
  if not h then
    return false,"Cannot write "..full
  end

  h.write(body)
  h.close()
  return true
end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)

print("PACIFICOS "..VERSION.." INSTALLER")
print("Complex Computer International (CCI) - 2026")
print("")
print("Direct GitHub Raw download mode")
print("")

if not http then
  print("ERROR: HTTP API is disabled.")
  print("Enable HTTP in CC:Tweaked and run the installer again.")
  return
end

if fs.exists(ROOT) and not fs.isDir(ROOT) then
  print("ERROR: "..ROOT.." exists but is not a directory.")
  print("Remove that file and run the installer again.")
  return
end

if not fs.exists(ROOT) then
  fs.makeDir(ROOT)
end

for i,path in ipairs(files) do
  write(string.format("[%02d/%02d] %-36s ",i,#files,path))

  local body,err=get(path)
  if not body then
    print("FAILED")
    print("Download error:")
    print(tostring(err))
    print("")
    print("URL:")
    print(BASE..path)
    print("")
    print("Installation stopped safely.")
    print("Nothing was rebooted.")
    return
  end

  local ok,werr=writeFile(path,body)
  if not ok then
    print("FAILED")
    print(tostring(werr))
    return
  end

  print("OK")
end

local startup=[[
local ok,err=pcall(dofile,"/pacificos/boot.lua")
if not ok then
  term.clear()
  term.setCursorPos(1,1)
  print("PACIFICOS RECOVERY")
  print("")
  print("Startup failed:")
  print(tostring(err))
  print("")
  print("[R] Recovery   [Q] Shutdown")
  while true do
    local e,k=os.pullEvent()
    if e=="key" and k==keys.r then
      dofile("/pacificos/recovery/recovery.lua")
      return
    elseif e=="key" and k==keys.q then
      os.shutdown()
      return
    end
  end
end
]]

local ok,err=writeFile("startup.lua",startup)
if not ok then
  print("FAILED")
  print(tostring(err))
  return
end

print("")
print("All "..#files.." PacificOS files downloaded.")
print("Installer: OK")
print("BIOS: included")
print("Desktop navigation: included")
print("PacificOS "..VERSION.." installed successfully.")
print("Rebooting...")
os.sleep(1)
os.reboot()
