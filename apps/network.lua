local U=dofile('/pacificos/ui/widgets.lua'); local N=dofile('/pacificos/system/network.lua'); local M={}
function M.run()
 while true do
  U.clear(); U.header('Network Manager'); local s=N.status(); U.label(2,3,'Enabled: '..tostring(s.enabled)); U.label(2,4,'Modems: '..#s.modems)
  for i,m in ipairs(s.modems) do U.label(2,5+i,tostring(m)) end
  U.status('B: broadcast test | Q/Esc: close')
  local e,a=os.pullEvent()
  if e=='key' and (a==keys.q or a==keys.escape) then return
  elseif e=='key' and a==keys.b then local ok=N.broadcast({type='ping'},'pacific'); U.label(2,math.min(10,select(2,term.getSize())-2),'Broadcast: '..tostring(ok),colors.lime); os.pullEvent('key') end
 end
end
return M
