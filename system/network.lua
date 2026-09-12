local M={enabled=true}
local function modems()
  local t={}
  for _,s in ipairs(peripheral.getNames()) do if peripheral.getType(s)=="modem" then t[#t+1]=s end end
  return t
end
function M.list() return modems() end
function M.open(channel)
  if not M.enabled then return false,"network disabled" end
  local m=modems()[1]; if not m then return false,"no modem" end
  rednet.open(m); return true
end
function M.close() pcall(rednet.close) end
function M.status() return {enabled=M.enabled,modems=modems(),isOpen=rednet.isOpen and rednet.isOpen()} end
function M.setEnabled(v) M.enabled=v; if not v then M.close() end end
function M.send(id,msg,protocol) if not M.enabled then return false,"disabled" end; return rednet.send(id,msg,protocol) end
function M.broadcast(msg,protocol) if not M.enabled then return false,"disabled" end; return rednet.broadcast(msg,protocol) end
function M.receive(timeout,protocol) if not M.enabled then return nil end; return rednet.receive(protocol,timeout) end
return M
