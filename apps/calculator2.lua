local U=dofile('/pacificos/ui/widgets.lua')
local M={}
local allowed={sqrt=true,abs=true,floor=true,ceil=true,round=true,sin=true,cos=true,tan=true,asin=true,acos=true,atan=true,log=true,exp=true,pow=true,fact=true,max=true,min=true}
local function fact(n)
  n=math.floor(n or 0); if n<0 or n>170 then return nil end
  local r=1; for i=2,n do r=r*i end; return r
end
local env={sqrt=math.sqrt,abs=math.abs,floor=math.floor,ceil=math.ceil,sin=function(x)return math.sin(math.rad(x))end,cos=function(x)return math.cos(math.rad(x))end,tan=function(x)return math.tan(math.rad(x))end,asin=function(x)return math.deg(math.asin(x))end,acos=function(x)return math.deg(math.acos(x))end,atan=function(x)return math.deg(math.atan(x))end,log=math.log,exp=math.exp,pow=math.pow,fact=fact,max=math.max,min=math.min,pi=math.pi,e=math.exp(1)}
local function evaluate(s)
  s=s:gsub('%s+',''):gsub('×','*'):gsub('÷','/')
  if s=='' then return nil,'Enter an expression.' end
  if s:find('[^%d%+%-%*/%%%^%(%)%.,%a_]') then return nil,'Unsupported character.' end
  for name in s:gmatch('([%a_][%w_]*)%s*%(') do if not allowed[name] then return nil,'Unknown function: '..name end end
  s=s:gsub('(%a[%w_]*)',function(name) if name=='pi' or name=='e' or allowed[name] then return name else return 'BAD' end end)
  if s:find('BAD') then return nil,'Unknown name.' end
  s=s:gsub('%^','^')
  local f,e=load('return '..s,'calculator','t',env)
  if not f then return nil,'Invalid expression: '..tostring(e) end
  local ok,r=pcall(f)
  if not ok then return nil,tostring(r) end
  if type(r)~='number' then return nil,'Result is not a number.' end
  if r~=r or r==math.huge or r==-math.huge then return nil,'Result is not finite.' end
  return r
end
function M.run()
  local history={}
  while true do
    local w,h=term.getSize(); U.clear(); U.header('Calculator')
    U.label(2,3,'Expression: +  -  *  /  %  ^  ( )')
    U.label(2,4,'Functions: sqrt abs floor ceil round sin cos tan asin acos atan log exp')
    U.label(2,5,'Constants: pi, e   Trig uses degrees')
    U.button(2,7,12,2,'Calculate',colors.blue); U.button(16,7,12,2,'Clear',colors.gray); U.button(30,7,12,2,'Help',colors.gray)
    local y=10; U.label(2,y,'History',colors.cyan); y=y+1
    for i=math.max(1,#history-5),#history do U.label(3,y,history[i],colors.lightGray); y=y+1 end
    U.status('Enter expression after Calculate | Q/Esc: back')
    local e,a,b,c=os.pullEvent()
    if e=='key' then
      if a==keys.q or a==keys.escape then return
      elseif a==keys.enter then
        term.setCursorPos(2,6); write('> '); local s=read(); local r,er=evaluate(s); if r then history[#history+1]=s..' = '..tostring(r) else history[#history+1]=s..' -> ERROR' end
      end
    elseif e=='mouse_click' or e=='monitor_touch' then
      if c>=7 and c<9 and b>=2 and b<14 then
        term.setCursorPos(2,6); term.clearLine(); write('> '); local s=read(); local r,er=evaluate(s); if r then history[#history+1]=s..' = '..tostring(r) else history[#history+1]=s..' -> '..tostring(er) end
      elseif c>=7 and c<9 and b>=16 and b<28 then history={}
      elseif c>=7 and c<9 and b>=30 and b<42 then
        term.setCursorPos(2,17); term.clearLine(); write('Examples: 2+3*4 | sqrt(81) | sin(30) | 5^3 | fact(6)'); os.pullEvent('key')
      end
    end
  end
end
return M
