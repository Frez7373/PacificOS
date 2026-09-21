local M = {}

local PROTECTED = {
  ["/"] = true,
  ["/startup.lua"] = true,
  ["/pacificos"] = true,
  ["/pacificos/boot.lua"] = true,
  ["/pacificos/bios.lua"] = true,
  ["/pacificos/kernel.lua"] = true,
  ["/pacificos/system"] = true,
  ["/pacificos/ui"] = true,
  ["/pacificos/recovery"] = true
}

function M.isProtected(path)
  if type(path) ~= "string" then return true end
  path = fs.combine("/", path)
  if PROTECTED[path] then return true end
  if path:sub(1, 15) == "/pacificos/system" then return true end
  if path:sub(1, 9) == "/pacificos/ui" then return true end
  if path:sub(1, 19) == "/pacificos/recovery" then return true end
  if path == "/pacificos/boot.lua" or path == "/pacificos/bios.lua" or path == "/pacificos/kernel.lua" then return true end
  return false
end

function M.stats(path)
  path = path or "/pacificos"
  local fileCount, dirCount, used = 0, 0, 0

  local function scan(current)
    if fs.isDir(current) then
      dirCount = dirCount + 1
      for _, name in ipairs(fs.list(current)) do
        scan(fs.combine(current, name))
      end
    else
      fileCount = fileCount + 1
      local size
      local ok = pcall(function() size = fs.getSize(current) end)
      if ok and type(size) == "number" then
        used = used + size
      else
        local handle = fs.open(current, "r")
        if handle then
          used = used + #(handle.readAll() or "")
          handle.close()
        end
      end
    end
  end

  scan(path)
  return {files = fileCount, directories = dirCount, bytes = used}
end

function M.safeDelete(path)
  if M.isProtected(path) then return false, "protected system path" end
  if not fs.exists(path) then return false, "not found" end
  if fs.isReadOnly(path) then return false, "read-only" end
  local ok, err = pcall(fs.delete, path)
  return ok, ok and nil or err
end

function M.read(path)
  if not fs.exists(path) or fs.isDir(path) then return nil, "not a file" end
  local handle, err = fs.open(path, "r")
  if not handle then return nil, err or "open failed" end
  local data = handle.readAll() or ""
  handle.close()
  return data
end

local function makeParent(path)
  local dir = fs.getDir(path)
  if dir ~= "" and not fs.exists(dir) then
    fs.makeDir(dir)
  end
end

function M.write(path, data)
  if M.isProtected(path) then return false, "protected system path" end
  makeParent(path)
  local handle, err = fs.open(path, "w")
  if not handle then return false, err or "cannot open" end
  handle.write(tostring(data or ""))
  handle.close()
  return true
end

return M
