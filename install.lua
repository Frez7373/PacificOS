-- PacificOS 1.8.1 installer
local BASE = "https://raw.githubusercontent.com/Frez7373/PacificOS/main/"
local ROOT = "/pacificos"
local STAGE = ROOT .. "/.installer_stage"
local BACKUP = ROOT .. "/.installer_backup"
local VERSION = "1.8.1"

local files = {
  "startup.lua","boot.lua","bios.lua","kernel.lua","manifest.lua",
  "system/module.lua","system/config.lua","system/filesystem.lua","system/devices.lua",
  "system/network.lua","system/security.lua","system/updater.lua","system/apps.lua",
  "ui/theme.lua","ui/widgets.lua","ui/windows.lua",
  "apps/about.lua","apps/antivirus.lua","apps/calculator.lua","apps/calculator2.lua",
  "apps/calendar.lua","apps/clock.lua","apps/converter.lua","apps/devices.lua",
  "apps/editor.lua","apps/files.lua","apps/installer.lua","apps/network.lua",
  "apps/settings.lua","apps/stopwatch.lua","apps/system_info.lua",
  "apps/system_monitor.lua","apps/task_manager.lua","apps/terminal.lua","apps/updater.lua",
  "recovery/recovery.lua","recovery/factory_reset.lua"
}

local function clearPath(path)
  if fs.exists(path) then pcall(fs.delete, path) end
end

local function ensureDir(path)
  local dir = fs.getDir(path)
  if dir == "" then return end

  local current = ""
  for part in string.gmatch(dir, "[^/]+") do
    current = current == "" and part or current .. "/" .. part
    local full = "/" .. current
    if not fs.exists(full) then fs.makeDir(full) end
  end
end

local function targetPath(path)
  if path == "startup.lua" then return "/startup.lua" end
  return ROOT .. "/" .. path
end

local function stagePath(path)
  return STAGE .. "/" .. path
end

local function fetch(path)
  if not http then return nil, "HTTP API is disabled." end

  local response, err = http.get(BASE .. path)
  if not response then return nil, tostring(err or "HTTP request failed.") end

  local code = 200
  if type(response.getResponseCode) == "function" then
    code = response.getResponseCode() or 200
  end

  local body = response.readAll() or ""
  if type(response.close) == "function" then response.close() end

  if code < 200 or code >= 400 then
    return nil, "HTTP " .. tostring(code)
  end
  if body == "" then
    return nil, "Empty response."
  end

  return body
end

local function write(path, body)
  ensureDir(path)
  local handle, err = fs.open(path, "w")
  if not handle then return false, tostring(err or "Cannot open file.") end
  handle.write(body)
  handle.close()
  return true
end

local function rollback(applied)
  for i = #applied, 1, -1 do
    local path = applied[i]
    local target = targetPath(path)
    local backup = BACKUP .. "/" .. path

    if fs.exists(target) then clearPath(target) end
    if fs.exists(backup) then
      ensureDir(target)
      pcall(fs.move, backup, target)
    end
  end
end

term.setBackgroundColor(colors.white)
term.setTextColor(colors.black)
term.clear()
term.setCursorPos(1, 1)

print("PACIFICOS " .. VERSION .. " INSTALLER")
print("Complex Computer International (CCI) - 2026")
print("")

if not http then
  print("ERROR: HTTP API is disabled.")
  print("Enable HTTP in CC:Tweaked and run the installer again.")
  return
end

if fs.exists(ROOT) and not fs.isDir(ROOT) then
  print("ERROR: " .. ROOT .. " exists as a file.")
  return
end

if not fs.exists(ROOT) then fs.makeDir(ROOT) end

clearPath(STAGE)
clearPath(BACKUP)
fs.makeDir(STAGE)
fs.makeDir(BACKUP)

print("Downloading and staging " .. #files .. " files...")

for i, path in ipairs(files) do
  write(string.format("[%02d/%02d] %-34s ", i, #files, path))
  local body, err = fetch(path)
  if not body then
    print("FAILED")
    print(tostring(err))
    clearPath(STAGE)
    clearPath(BACKUP)
    return
  end

  local ok, writeErr = write(stagePath(path), body)
  if not ok then
    print("FAILED")
    print(tostring(writeErr))
    clearPath(STAGE)
    clearPath(BACKUP)
    return
  end
  print("OK")
end

print("")
print("Creating rollback backup...")

for _, path in ipairs(files) do
  local target = targetPath(path)
  if fs.exists(target) and not fs.isDir(target) then
    local backup = BACKUP .. "/" .. path
    ensureDir(backup)
    local ok, err = pcall(fs.copy, target, backup)
    if not ok then
      print("Backup failed for " .. path .. ": " .. tostring(err))
      clearPath(STAGE)
      clearPath(BACKUP)
      return
    end
  end
end

local applied = {}
for _, path in ipairs(files) do
  local target = targetPath(path)
  local staged = stagePath(path)

  if fs.exists(target) then clearPath(target) end
  ensureDir(target)

  local ok, err = pcall(fs.move, staged, target)
  if not ok then
    print("")
    print("INSTALL FAILED: " .. path)
    print(tostring(err))
    print("Rolling back...")
    rollback(applied)
    clearPath(STAGE)
    clearPath(BACKUP)
    print("Rollback complete.")
    return
  end

  applied[#applied + 1] = path
end

clearPath(STAGE)
clearPath(BACKUP)

print("")
print("PacificOS " .. VERSION .. " installed successfully.")
print("System files updated safely with rollback support.")
print("Third-party apps and config are preserved.")
print("Rebooting...")
os.sleep(1)
os.reboot()
