local BASE="https://raw.githubusercontent.com/Frez7373/PacificOS/main/"
local ROOT="/pacificos"
local VERSION="1.6.0"
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

local function get(url)
  if not http then return nil,"HTTP API is disabled. Enable HTTP in CC:Tweaked settings." end
  local r,e=http.get(url)
  if not r then return nil,e or "HTTP request failed." end
  local code=r.getResponseCode and r.getResponseCode() or 200
  local body=r.readAll() or ""
  r.close()
  if code>=400 then return nil,"HTTP "..tostring(code) end
  return body
end

term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.clear(); term.setCursorPos(1,1)
print("PACIFICOS "..VERSION.." INSTALLER")
print("Complex Computer International (CCI) - 2026")
print("")

if not http then
  print("HTTP API is disabled.")
  print("Enable HTTP in CC:Tweaked settings and run the installer again.")
  return
end

if not fs.exists(ROOT) then fs.makeDir(ROOT) end

for i,path in ipairs(files) do
  write(string.format("[%02d/%02d] %-34s ",i,#files,path))
  local body,e=get(BASE..path)
  if not body then
    print("FAILED")
    print(tostring(e))
    return
  end
  local full=ROOT.."/"..path
  mkdirs(full)
  local h=fs.open(full,"w")
  if not h then print("FAILED: cannot write "..full); return end
  h.write(body); h.close()
  print("OK")
end

local h=fs.open("/startup.lua","w")
if not h then print("FAILED: cannot write /startup.lua"); return end
h.write('local ok,err=pcall(dofile,"/pacificos/boot.lua")\nif not ok then term.clear();term.setCursorPos(1,1);print("PacificOS startup error");print(tostring(err));print("");print("R = Recovery   Q = Shutdown");while true do local e,k=os.pullEvent("key");if k==keys.r then dofile("/pacificos/recovery/recovery.lua");return elseif k==keys.q then os.shutdown();return end end end\n')
h.close()

print("")
print("PacificOS "..VERSION.." installed successfully.")
print("Rebooting...")
os.sleep(1)
os.reboot()
