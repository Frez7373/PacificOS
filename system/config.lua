local path="/pacificos/config.cfg"
local defaults={version="1.0.0",theme="ocean",hostname="pacificos",autostart=true}
local M={}
local function load()
  if not fs.exists(path) then return end
  local h=fs.open(path,"r"); local s=h.readAll(); h.close()
  local ok,t=pcall(textutils.unserialize,s); if ok and type(t)=="table" then for k,v in pairs(t) do defaults[k]=v end end
end
local function save() local h=fs.open(path,"w"); h.write(textutils.serialize(defaults)); h.close() end
load()
function M.get(k) return defaults[k] end
function M.set(k,v) defaults[k]=v; save() end
function M.all() local t={}; for k,v in pairs(defaults) do t[k]=v end; return t end
return M
