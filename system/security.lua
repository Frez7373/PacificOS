local M = {}

local function isPrefix(path, prefix)
  return path == prefix or path:sub(1, #prefix + 1) == prefix .. "/"
end

function M.confirm(message, keyword)
  keyword = keyword or "YES"
  term.setTextColor(colors.yellow)
  print(tostring(message or "Confirm this action"))
  term.setTextColor(colors.white)
  write("Type " .. keyword .. ": ")
  return read() == keyword
end

function M.log(message)
  local dir = "/pacificos/logs"
  if not fs.exists(dir) then pcall(fs.makeDir, dir) end
  local handle = fs.open(dir .. "/system.log", "a")
  if handle then
    handle.writeLine(os.date("%Y-%m-%d %H:%M:%S") .. " " .. tostring(message))
    handle.close()
  end
end

function M.isProtected(path)
  path = fs.combine("/", tostring(path or ""))
  return path == "/"
    or path == "/startup.lua"
    or path == "/pacificos"
    or path == "/pacificos/manifest.lua"
    or isPrefix(path, "/pacificos/apps")
    or isPrefix(path, "/pacificos/system")
    or isPrefix(path, "/pacificos/ui")
    or isPrefix(path, "/pacificos/recovery")
    or path == "/pacificos/kernel.lua"
    or path == "/pacificos/boot.lua"
    or path == "/pacificos/bios.lua"
end

function M.isUserPath(path)
  path = fs.combine("/", tostring(path or ""))
  return isPrefix(path, "/pacificos/user") or isPrefix(path, "/pacificos/userapps")
end

return M
