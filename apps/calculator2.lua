local U=dofile('/pacificos/ui/widgets.lua'); local M={}
local function calc(s)
 local a,op,b=s:match('^%s*(-?[%d%.]+)%s*([%+%-%*/])%s*(-?[%d%.]+)%s*$'); a=tonumber(a); b=tonumber(b)
 if not a or not b then return nil,'Use: number operator number' end
 if op=='+' then return a+b elseif op=='-' then return a-b elseif op=='*' then return a*b elseif op=='/' then if b==0 then return nil,'division by zero' end; return a/b end
end
function M.run()
 while true do
  U.header('Calculator'); term.setCursorPos(2,4); write('Expression: '); local s=read(); if s=='q' or s=='exit' then return end
  local r,e=calc(s); term.setCursorPos(2,6); print(r and ('Result: '..r) or ('Error: '..e)); U.status('Press Enter for another expression'); os.pullEvent('key')
 end
end
return M
