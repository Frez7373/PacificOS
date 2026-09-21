-- PacificOS 1.7.0 installer
local BASE="https://raw.githubusercontent.com/Frez7373/PacificOS/main/"
local ROOT="/pacificos"
local VERSION="1.7.0"
local CACHE="20260921-170"
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
    if not fs.exists("/"..cur) then fs.makeDir("/"..cur) end
  end
end

local function get(path)
  if not http then return nil,"HTTP API is disabled." end
  local url=BASE..path.."?pacificos="..CACHE
  local r,e=http.get(url)
  if not r then return nil,e or "HTTP request failed." end
  local code=r.getResponseCode and r.getResponseCode() or 200
  local body=r.readAll() or ""
  r.close()
  if code>=400 then return nil,"HTTP "..tostring(code) end
  return body
end

local function writeFile(path,body)
  local full=ROOT.."/"..path
  if path=="startup.lua" then full="/startup.lua" end
  mkdirs(full)
  local h=fs.open(full,"w")
  if not h then return false,"Cannot write "..full end
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
print("Fresh download mode: "..CACHE)
print("")

if not http then
  print("HTTP API is disabled.")
  return
end

if not fs.exists(ROOT) then fs.makeDir(ROOT) end

for i,path in ipairs(files) do
  write(string.format("[%02d/%02d] %-34s ",i,#files,path))
  local body,e=get(path)
  if not body then print("FAILED"); print(tostring(e)); return end

  if path=="ui/widgets.lua" and not body:find("PACIFICOS_WIDGET_COMPAT_161",1,true) then
    print("FAILED")
    print("The server returned an old widgets.lua.")
    print("Please retry; fresh-cache protection prevented an unsafe reboot.")
    return
  end

  if path=="boot.lua" and not body:find("PACIFICOS_BIOS_KEY_170",1,true) then
    print("FAILED")
    print("The server returned an old boot.lua.")
    print("Please retry; fresh-cache protection prevented an unsafe reboot.")
    return
  end

  if path=="bios.lua" and not body:find("PACIFICOS_BIOS_170",1,true) then
    print("FAILED")
    print("The server returned an old bios.lua.")
    print("Please retry; fresh-cache protection prevented an unsafe reboot.")
    return
  end

  local ok,werr=writeFile(path,body)
  if not ok then print("FAILED"); print(tostring(werr)); return end
  print("OK")
end

local startup='local ok,err=pcall(dofile,"/pacificos/boot.lua")\nif not ok then term.clear();term.setCursorPos(1,1);print("PACIFICOS RECOVERY");print("");print("Startup failed:");print(tostring(err));print("");print("[R] Recovery   [Q] Shutdown");while true do local e,k=os.pullEvent();if e=="key" and k==keys.r then dofile("/pacificos/recovery/recovery.lua");return elseif e=="key" and k==keys.q then os.shutdown();return end end end\n'
local ok,err=writeFile("startup.lua",startup)
if not ok then print("FAILED: "..tostring(err)); return end

print("")
print("All "..#files.." PacificOS files downloaded.")
print("Critical UI compatibility check: PASSED")
print("BIOS hotkey check: PASSED")
print("PacificOS "..VERSION.." installed successfully.")
print("Rebooting...")
os.sleep(1)
os.reboot()
