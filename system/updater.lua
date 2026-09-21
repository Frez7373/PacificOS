local M = {}
local ROOT = "/pacificos"
local BASE = "https://raw.githubusercontent.com/Frez7373/PacificOS/main/"
local STAGE = ROOT .. "/.update_stage"
local BACKUP = ROOT .. "/.update_backup"

local function mkdirs(path)
  local dir = fs.getDir(path)
  if dir == "" then return end
  local current = ""
  for part in string.gmatch(dir, "[^/]+") do
    current = current == "" and part or current .. "/" .. part
    local full = "/" .. current
    if not fs.exists(full) then fs.makeDir(full) end
  end
end

local function removeTree(path)
  if fs.exists(path) then pcall(fs.delete, path) end
end

function M.fetch(path)
  if not http then return nil, "HTTP API is disabled." end
  local response, err = http.get(BASE .. path)
  if not response then return nil, tostring(err or "HTTP request failed.") end

  local code = 200
  if type(response.getResponseCode) == "function" then code = response.getResponseCode() or 200 end
  local body = response.readAll() or ""
  if type(response.close) == "function" then response.close() end

  if code < 200 or code >= 400 then return nil, "HTTP " .. tostring(code) end
  if body == "" then return nil, "Empty response for " .. path end
  return body
end

local function loadManifest(text, source)
  local fn, err = load(text, source, "t", {})
  if not fn then return nil, err end
  local ok, result = pcall(fn)
  if not ok or type(result) ~= "table" then return nil, "Invalid manifest." end
  if type(result.files) ~= "table" then return nil, "Manifest has no files." end
  return result
end

function M.localManifest()
  local path = ROOT .. "/manifest.lua"
  if not fs.exists(path) then return nil, "Local manifest missing." end
  local fn, err = loadfile(path)
  if not fn then return nil, err end
  local ok, result = pcall(fn)
  if ok and type(result) == "table" then return result end
  return nil, "Invalid local manifest."
end

function M.remoteManifest()
  local body, err = M.fetch("manifest.lua")
  if not body then return nil, err end
  return loadManifest(body, "remote-manifest")
end

local function versionParts(value)
  local a, b, c = tostring(value or "0"):match("^(%d+)%.?(%d*)%.?(%d*)")
  return tonumber(a) or 0, tonumber(b) or 0, tonumber(c) or 0
end

local function newer(a, b)
  local a1, a2, a3 = versionParts(a)
  local b1, b2, b3 = versionParts(b)
  if a1 ~= b1 then return a1 > b1 end
  if a2 ~= b2 then return a2 > b2 end
  return a3 > b3
end

function M.compare()
  local localManifest, localErr = M.localManifest()
  local remoteManifest, remoteErr = M.remoteManifest()
  if not remoteManifest then return nil, remoteErr or localErr end

  local localVersion = localManifest and localManifest.version or "0.0.0"
  local remoteVersion = remoteManifest.version or "unknown"

  return {
    localVersion = localVersion,
    remoteVersion = remoteVersion,
    update = newer(remoteVersion, localVersion),
    remoteAheadOrDifferent = remoteVersion ~= localVersion,
    manifest = remoteManifest
  }
end

local function stageFile(path, body)
  local full = STAGE .. "/" .. path
  mkdirs(full)
  local handle = fs.open(full, "w")
  if not handle then return false, "Cannot stage " .. path end
  handle.write(body)
  handle.close()
  return true
end

local function targetPath(path)
  return path == "startup.lua" and "/startup.lua" or ROOT .. "/" .. path
end

local function validateStaged(path)
  if not tostring(path):lower():match("%.lua$") then return true end
  local fn, err = loadfile(STAGE .. "/" .. path)
  if not fn then return false, tostring(err) end
  return true
end


function M.installFile(path, body)
  local target = targetPath(path)
  mkdirs(target)
  local handle = fs.open(target, "w")
  if not handle then return false, "Cannot write " .. path end
  handle.write(body)
  handle.close()
  return true
end

function M.update(manifest)
  if type(manifest) ~= "table" or type(manifest.files) ~= "table" then
    return false, "Manifest has no file list.", 0
  end

  removeTree(STAGE)
  removeTree(BACKUP)
  fs.makeDir(STAGE)
  fs.makeDir(BACKUP)

  local staged = {}
  local downloaded = 0

  for _, path in ipairs(manifest.files) do
    if path ~= "config.cfg" then
      local body, err = M.fetch(path)
      if not body then
        removeTree(STAGE)
        removeTree(BACKUP)
        return false, path .. ": " .. tostring(err), downloaded
      end

      local ok, stageErr = stageFile(path, body)
      if not ok then
        removeTree(STAGE)
        removeTree(BACKUP)
        return false, stageErr, downloaded
      end

      local valid, syntaxErr = validateStaged(path)
      if not valid then
        removeTree(STAGE)
        removeTree(BACKUP)
        return false, path .. ": invalid Lua: " .. tostring(syntaxErr), downloaded
      end

      staged[#staged + 1] = path
      downloaded = downloaded + 1
    end
  end

  local applied = {}
  local count = 0

  local function rollback()
    for i = #applied, 1, -1 do
      local path = applied[i]
      local target = targetPath(path)
      local backup = BACKUP .. "/" .. path
      if fs.exists(target) then pcall(fs.delete, target) end
      if fs.exists(backup) then
        mkdirs(target)
        pcall(fs.move, backup, target)
      end
    end
  end

  for _, path in ipairs(staged) do
    local target = targetPath(path)
    local backup = BACKUP .. "/" .. path

    if fs.exists(target) then
      mkdirs(backup)
      local ok, err = pcall(fs.copy, target, backup)
      if not ok then
        rollback()
        removeTree(STAGE)
        removeTree(BACKUP)
        return false, "Backup failed for " .. path .. ": " .. tostring(err), count
      end
    end

    if fs.exists(target) then
      local deleted, delErr = pcall(fs.delete, target)
      if not deleted then
        rollback()
        removeTree(STAGE)
        removeTree(BACKUP)
        return false, "Cannot replace " .. path .. ": " .. tostring(delErr), count
      end
    end

    mkdirs(target)
    local ok, err = pcall(fs.move, STAGE .. "/" .. path, target)
    if not ok then
      rollback()
      removeTree(STAGE)
      removeTree(BACKUP)
      return false, "Install failed for " .. path .. ": " .. tostring(err), count
    end

    applied[#applied + 1] = path
    count = count + 1
  end

  removeTree(STAGE)
  removeTree(BACKUP)
  return true, nil, count
end

return M
