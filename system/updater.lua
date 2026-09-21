local M={}
local ROOT="/pacificos"
local BASE="https://raw.githubusercontent.com/Frez7373/PacificOS/main/"

local function mkdirs(path)
  local dir=fs.getDir(path)
  if dir=="" then return end
  local cur=""
  for part in string.gmatch(dir,"[^/]+") do
    cur=cur=="" and part or cur.."/"..part
    if not fs.exists("/"..cur) then fs.makeDir("/"..cur) end
  end
end

function M.fetch(path)
  if not http then return nil,"HTTP API is disabled." end
  local r,e=http.get(BASE..path)
  if not r then return nil,e or "HTTP request failed." end
  local code=r.getResponseCode and r.getResponseCode() or 200
  local s=r.readAll() or ""
  r.close()
  if code>=400 then return nil,"HTTP "..tostring(code) end
  return s
end

local function loadManifest(text,source)
  local f,e=load(text,source,"t",{})
  if not f then return nil,e end
  local ok,t=pcall(f)
  if not ok or type(t)~="table" then return nil,"Invalid manifest." end
  return t
end

function M.localManifest()
  if not fs.exists(ROOT.."/manifest.lua") then return nil,"Local manifest missing." end
  local f,e=loadfile(ROOT.."/manifest.lua")
  if not f then return nil,e end
  local ok,t=pcall(f)
  if ok and type(t)=="table" then return t end
  return nil,"Invalid local manifest."
end

function M.remoteManifest()
  local s,e=M.fetch("manifest.lua")
  if not s then return nil,e end
  return loadManifest(s,"remote-manifest")
end

function M.compare()
  local localM=M.localManifest()
  local remoteM,e=M.remoteManifest()
  if not remoteM then return nil,e end
  return {
    localVersion=localM and localM.version or "0.0.0",
    remoteVersion=remoteM.version or "unknown",
    update=(localM and localM.version or "")~=(remoteM.version or ""),
    manifest=remoteM
  }
end

function M.installFile(path,body)
  local full
  if path=="startup.lua" then
    full="/startup.lua"
  else
    full=ROOT.."/"..path
  end
  mkdirs(full)
  local h=fs.open(full,"w")
  if not h then return false,"Cannot write "..path end
  h.write(body)
  h.close()
  return true
end

function M.update(manifest)
  if type(manifest)~="table" or type(manifest.files)~="table" then return false,"Manifest has no file list." end
  local errors={}
  local done=0
  for _,path in ipairs(manifest.files) do
    local body,e=M.fetch(path)
    if not body then
      errors[#errors+1]=path..": "..tostring(e)
      break
    end
    local ok,werr=M.installFile(path,body)
    if not ok then
      errors[#errors+1]=path..": "..tostring(werr)
      break
    end
    done=done+1
  end
  if #errors>0 then return false,table.concat(errors," | "),done end
  return true,nil,done
end

return M
