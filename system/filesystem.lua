local M={}
function M.stats(path)
  local used=0
  local function scan(p)
    if fs.isDir(p) then for _,n in ipairs(fs.list(p)) do scan(fs.combine(p,n)) end else local h=fs.open(p,"r"); if h then used=used+#(h.readAll() or ""); h.close() end end
  end
  scan(path or "/pacificos")
  return used
end
function M.safeDelete(path)
  if path=="/" or path=="/pacificos" or path=="/startup.lua" then return false,"protected" end
  if not fs.exists(path) then return false,"not found" end
  fs.delete(path); return true
end
function M.read(path)
  if not fs.exists(path) or fs.isDir(path) then return nil,"not a file" end
  local h=fs.open(path,"r"); local s=h.readAll(); h.close(); return s
end
function M.write(path,data)
  local d=fs.getDir(path); if d~="" and not fs.exists(d) then fs.makeDir(d) end
  local h=fs.open(path,"w"); if not h then return false,"cannot open" end; h.write(data); h.close(); return true
end
return M
