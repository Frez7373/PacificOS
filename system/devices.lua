local M={}
local function snapshot()
  local t={}
  for _,side in ipairs(peripheral.getNames()) do
    t[#t+1]={side=side,type=peripheral.getType(side),name=side}
  end
  return t
end
function M.list() return snapshot() end
function M.find(kind)
  local out={}; for _,d in ipairs(snapshot()) do if d.type==kind then out[#out+1]=d end end; return out
end
function M.has(kind) return #M.find(kind)>0 end
return M
