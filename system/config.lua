local path='/pacificos/config.cfg'
local function defaults()
 return {version='1.7.2',theme='ocean',hostname='pacificos',autostart=true,network=true,animations=true,sounds=true,notifications=true,show_seconds=false,boot_delay=0.3,default_app='Files'}
end
local data=defaults()
local M={}
local function load()
 if not fs.exists(path) then return end
 local h=fs.open(path,'r'); if not h then return end
 local s=h.readAll(); h.close()
 local ok,t=pcall(textutils.unserialize,s)
 if ok and type(t)=='table' then for k,v in pairs(t) do data[k]=v end end
end
local function save()
 local h=fs.open(path,'w'); if h then h.write(textutils.serialize(data)); h.close() end
end
load()
function M.get(k) return data[k] end
function M.set(k,v) data[k]=v; save() end
function M.all() local t={}; for k,v in pairs(data) do t[k]=v end; return t end
function M.reset() data=defaults(); save() end
return M
