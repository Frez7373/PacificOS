local M = {}

local PROTECTED = {
  ["/"] = true,
  ["/startup.lua"] = true,
  ["/pacificos"] = true,
  ["/pacificos/boot.lua"] = true,
  ["/pacificos/bios.lua"] = true,
  ["/pacificos/kernel.lua"] = true,
  ["/pacificos/manifest.lua"] = true,
  ["/pacificos/apps"] = true,
  ["/pacificos/system"] = true,
  ["/pacificos/ui"] = true,
  ["/pacificos/recovery"] = true
}

local function isPrefix(path, prefix)
  return path == prefix or path:sub(1, #prefix + 1) == prefix .. "/"
end

function M.isProtected(path)
  if type(path) ~= "string" then return true end
  path = fs.combine("/", path)
  if PROTECTED[path] then return true end
  if isPrefix(path, "/pacificos/apps") then return true end
  if isPrefix(path, "/pacificos/system") then return true end
  if isPrefix(path, "/pacificos/ui") then return true end
  if isPrefix(path, "/pacificos/recovery") then return true end
  return false
end

function M.stats(path)
  path = path or "/pacificos"
  local files, directories, bytes = 0, 0, 0

  local function scan(current)
    if fs.isDir(current) then
      directories = directories + 1
      for _, name in ipairs(fs.list(current)) do scan(fs.combine(current, name)) end
      return
    end

    files = files + 1
    local size = nil
    local ok = pcall(function() size = fs.getSize(current) end)
    if ok and type(size) == "number" then
      bytes = bytes + size
    else
      local handle = fs.open(current, "r")
      if handle then
        bytes = bytes + #(handle.readAll() or "")
        handle.close()
      end
    end
  end

  if fs.exists(path) then scan(path) end
  return {files=files, directories=directories, bytes=bytes}
end

function M.safeDelete(path)
  if M.isProtected(path) then return false, "protected system path" end
  if not fs.exists(path) then return false, "not found" end
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

function M.write(path, data)
  if M.isProtected(path) then return false, "protected system path" end
  local dir = fs.getDir(path)
  if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
  local handle, err = fs.open(path, "w")
  if not handle then return false, err or "cannot open" end
  handle.write(tostring(data or ""))
  handle.close()
  return true
end

return M
