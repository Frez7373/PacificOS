local BASE='https://raw.githubusercontent.com/Frez7373/PacificOS/main/'
local ROOT='/pacificos'
local files={'boot.lua','bios.lua','kernel.lua','startup.lua','system/module.lua','system/config.lua','system/filesystem.lua','system/devices.lua','system/network.lua','system/security.lua','system/updater.lua','ui/theme.lua','ui/widgets.lua','ui/windows.lua','apps/settings.lua','apps/files.lua','apps/editor.lua','apps/task_manager.lua','apps/terminal.lua','apps/network.lua','apps/devices.lua','apps/updater.lua','apps/antivirus.lua','apps/calculator2.lua','apps/clock.lua','apps/calendar.lua','apps/system_info.lua','apps/about.lua','recovery/recovery.lua','recovery/factory_reset.lua','manifest.lua'}
local function mkdirs(p)
 local cur=''
 for x in string.gmatch(p,'[^/]+') do
  cur=cur=='' and x or cur..'/'..x
  if not fs.exists('/'..cur) then fs.makeDir('/'..cur) end
 end
end
local function get(u)
 local r,e=http.get(u)
 if not r then return nil,e or 'HTTP failed' end
 local s=r.readAll(); r.close(); return s
end

term.clear(); term.setCursorPos(1,1)
print('PACIFICOS 1.2.0 INSTALLER')
print('Repairing/updating system files...')
print('')
if not http then print('HTTP API is disabled. Enable HTTP in CC:Tweaked settings.'); return end
if not fs.exists(ROOT) then fs.makeDir(ROOT) end
for i,p in ipairs(files) do
 write(string.format('[%02d/%02d] %s ',i,#files,p))
 local body,e=get(BASE..p)
 if not body then print('FAILED'); print(e); return end
 local full=ROOT..'/'..p
 mkdirs(fs.getDir(full))
 local h=fs.open(full,'w')
 if not h then print('FAILED: cannot write'); return end
 h.write(body); h.close(); print('OK')
end
local h=fs.open('/startup.lua','w')
if not h then print('FAILED: cannot write /startup.lua'); return end
h.write("local ok,err=pcall(dofile,'/pacificos/boot.lua')\nif not ok then term.clear();term.setCursorPos(1,1);print('PacificOS startup error');print(tostring(err));print('Press R for recovery or Q to shutdown.');while true do local _,k=os.pullEvent('key');if k==keys.r then dofile('/pacificos/recovery/recovery.lua');return elseif k==keys.q then os.shutdown();return end end end\n")
h.close()
print('')
print('PacificOS 1.2.0 installed.')
print('Rebooting...')
os.sleep(1)
os.reboot()
