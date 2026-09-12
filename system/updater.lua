local M={base="https://raw.githubusercontent.com/Frez7373/PacificOS/main/"}
function M.fetch(path)
  local r,e=http.get(M.base..path); if not r then return nil,e end; local s=r.readAll(); r.close(); return s
end
function M.install(path)
  local body,e=M.fetch(path); if not body then return false,e end
  local full="/pacificos/"..path; local d=fs.getDir(full); if d~="" and not fs.exists(d) then fs.makeDir(d) end
  local h=fs.open(full,"w"); if not h then return false,"write failed" end; h.write(body); h.close(); return true
end
function M.version() local s,e=M.fetch("manifest.lua"); if not s then return nil,e end; local f,er=load(s,"manifest","t",{}); if not f then return nil,er end; local ok,t=pcall(f); if ok and type(t)=="table" then return t.version,t end; return nil,"invalid manifest" end
return M
