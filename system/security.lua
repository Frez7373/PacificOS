local M = {}

function M.confirm(message, keyword)
  term.setTextColor(colors.yellow)
  print(tostring(message or "Confirm this action"))
  term.setTextColor(colors.white)
  write("Type " .. tostring(keyword or "YES") .. ": ")
  local input = read()
  return input == (keyword or "YES")
end

function M.log(message)
  local dir = "/pacificos/logs"
  if not fs.exists(dir) then fs.makeDir(dir) end
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
    or path == "/pacificos/system"
    or path == "/pacificos/ui"
    or path == "/pacificos/recovery"
    or path == "/pacificos/kernel.lua"
    or path == "/pacificos/boot.lua"
    or path == "/pacificos/bios.lua"
    or path:sub(1, 16) == "/pacificos/system/"
    or path:sub(1, 13) == "/pacificos/ui/"
    or path:sub(1, 19) == "/pacificos/recovery/"
end

function M.isUserPath(path)
  path = fs.combine("/", tostring(path or ""))
  return path == "/pacificos/user" or path:sub(1, 16) == "/pacificos/user/"
end

return M
