local U=dofile('/pacificos/ui/widgets.lua'); local M={}
local units={['cm']=0.01,['m']=1,['km']=1000,['in']=0.0254,['ft']=0.3048,['mi']=1609.344,['g']=0.001,['kg']=1,['lb']=0.45359237}
function M.run()
 while true do
  U.clear(); U.header('Unit Converter'); U.label(2,4,'Supported: cm m km in ft mi g kg lb'); U.label(2,6,'Enter: amount unit to_unit (example: 10 km mi)')
  term.setCursorPos(2,8); write('> '); local s=read(); if not s or s=='q' or s=='exit' then return end
  local n,a,b=s:match('^%s*([%-%d%.]+)%s+(%a+)%s+(%a+)%s*$'); n=tonumber(n)
  local r,e
  if not n or not units[a] or not units[b] then e='Unknown value or unit.' else r=n*units[a]/units[b] end
  if r then U.label(2,10,tostring(n)..' '..a..' = '..tostring(r)..' '..b,colors.lime) else U.label(2,10,'Error: '..e,colors.red) end
  U.status('Press Enter for another conversion | Q/Esc: back')
  local ev,k=os.pullEvent('key'); if k==keys.q or k==keys.escape then return end
 end
end
return M
