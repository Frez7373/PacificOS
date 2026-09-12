local M={enabled=true}
local function modems() local t={} for _,s in ipairs(peripheral.getNames()) do if peripheral.getType(s)=='modem' then t[#t+1]=s end end return t end
function M.list() return modems() end
function M.open() if not M.enabled then return false,'network disabled' end local m=modems()[1]; if not m then return false,'no modem' end local ok,e=pcall(rednet.open,m); return ok,ok and nil or e end
function M.close() for _,m in ipairs(modems()) do pcall(rednet.close,m) end end
function M.status() local opened=0; for _,m in ipairs(modems()) do local ok,v=pcall(rednet.isOpen,m); if ok and v then opened=opened+1 end end return {enabled=M.enabled,modems=modems(),opened=opened} end
function M.setEnabled(v) M.enabled=v; if not v then M.close() end end
function M.send(id,msg,protocol) if not M.enabled then return false,'disabled' end; return pcall(rednet.send,id,msg,protocol) end
function M.broadcast(msg,protocol) if not M.enabled then return false,'disabled' end; return pcall(rednet.broadcast,msg,protocol) end
function M.receive(timeout,protocol) if not M.enabled then return nil end; return rednet.receive(protocol,timeout) end
return M
