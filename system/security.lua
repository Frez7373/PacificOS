local M={}
function M.confirm(message)
  term.setTextColor(colors.yellow); print(message); term.setTextColor(colors.white); write("Type YES: ")
  local s=read(); return s=="YES"
end
function M.log(message)
  if not fs.exists("/pacificos/logs") then fs.makeDir("/pacificos/logs") end
  local h=fs.open("/pacificos/logs/system.log","a"); if h then h.writeLine(os.date("%Y-%m-%d %H:%M:%S").." "..tostring(message)); h.close() end
end
function M.safe(path)
  return path=="/pacificos" or path=="/startup.lua" or path:sub(1,10)=="/pacificos/" and (path:find("/system/") or path:find("/ui/") or path=="/pacificos/kernel.lua")
end
return M
