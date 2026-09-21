local ROOT="/pacificos"
local DATA=ROOT.."/data"
local USER=ROOT.."/userapps"
local REG=DATA.."/apps.cfg"
local M={}

local function ensure()
  if not fs.exists(DATA) then fs.makeDir(DATA) end
  if not fs.exists(USER) then fs.makeDir(USER) end
end

local function loadRegistry()
  ensure()
  if not fs.exists(REG) then return {} end
  local h=fs.open(REG,"r")
  if not h then return {} end
  local s=h.readAll() or ""
  h.close()
  local ok,t=pcall(textutils.unserialize,s)
  if ok and type(t)=="table" then return t end
  return {}
end

local function saveRegistry(t)
  ensure()
  local h=fs.open(REG,"w")
  if not h then return false,"cannot write registry" end
  h.write(textutils.serialize(t))
  h.close()
  return true
end

local function cleanName(name)
  name=tostring(name or ""):gsub("^%s+",""):gsub("%s+$","")
  name=name:gsub("[%c]","")
  if #name>32 then name=name:sub(1,32) end
  return name
end

local function validRelative(path)
  path=tostring(path or "")
  if path=="" or path:sub(1,1)=="/" then return false end
  if path:find("%.%.",1,true) then return false end
  return path:match("^userapps/[%w%._%-]+%.lua$")~=nil
end

function M.list()
  local data=loadRegistry()
  local out={}
  local changed=false
  for i,e in ipairs(data) do
    if type(e)=="table" and type(e.name)=="string" and type(e.path)=="string" and validRelative(e.path) and fs.exists(ROOT.."/"..e.path) and not fs.isDir(ROOT.."/"..e.path) then
      if e.desktop==nil then e.desktop=true; changed=true end
      out[#out+1]={
        name=e.name,
        path=e.path,
        source=e.source or "unknown",
        desktop=e.desktop~=false
      }
    else
      changed=true
    end
  end
  table.sort(out,function(a,b) return a.name:lower()<b.name:lower() end)
  if changed then saveRegistry(out) end
  return out
end

function M.listDesktop()
  local out={}
  for _,e in ipairs(M.list()) do
    if e.desktop then out[#out+1]=e end
  end
  return out
end

function M.find(name)
  name=tostring(name or ""):lower()
  for _,e in ipairs(M.list()) do
    if e.name:lower()==name then return e end
  end
  return nil
end

function M.register(name,path,source)
  name=cleanName(name)
  if name=="" then return false,"invalid app name" end
  if not validRelative(path) then return false,"invalid app path" end
  if not fs.exists(ROOT.."/"..path) then return false,"app file not found" end

  local data=loadRegistry()
  for _,e in ipairs(data) do
    if type(e)=="table" and tostring(e.name):lower()==name:lower() then
      e.name=name
      e.path=path
      e.source=source or e.source or "unknown"
      e.desktop=true
      return saveRegistry(data)
    end
  end

  data[#data+1]={name=name,path=path,source=source or "unknown",desktop=true}
  return saveRegistry(data)
end

function M.setDesktop(name,value)
  local data=loadRegistry()
  for _,e in ipairs(data) do
    if type(e)=="table" and tostring(e.name):lower()==tostring(name):lower() then
      e.desktop=value and true or false
      return saveRegistry(data)
    end
  end
  return false,"application not found"
end

function M.remove(name)
  local data=loadRegistry()
  local out={}
  local found=nil
  for _,e in ipairs(data) do
    if type(e)=="table" and tostring(e.name):lower()==tostring(name):lower() then
      found=e
    else
      out[#out+1]=e
    end
  end
  if not found then return false,"application not found" end
  if validRelative(found.path) and fs.exists(ROOT.."/"..found.path) then fs.delete(ROOT.."/"..found.path) end
  local ok,err=saveRegistry(out)
  if not ok then return false,err end
  return true
end

return M
