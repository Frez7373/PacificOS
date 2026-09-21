local U=dofile("/pacificos/ui/widgets.lua")
local M={}

local allowed={
  sqrt=true,abs=true,floor=true,ceil=true,round=true,
  sin=true,cos=true,tan=true,asin=true,acos=true,atan=true,
  sec=true,csc=true,cot=true,deg=true,rad=true,
  log=true,ln=true,log10=true,exp=true,pow=true,
  fact=true,max=true,min=true,gcd=true,lcm=true,clamp=true
}

local function fact(n)
  n=math.floor(n or 0)
  if n<0 or n>170 then return nil end
  local r=1
  for i=2,n do r=r*i end
  return r
end

local function round(n)
  n=tonumber(n or 0)
  if n>=0 then return math.floor(n+0.5) end
  return math.ceil(n-0.5)
end

local function gcd(a,b)
  a=math.floor(math.abs(a or 0)); b=math.floor(math.abs(b or 0))
  while b~=0 do a,b=b,a%b end
  return a
end

local env={
  sqrt=math.sqrt,abs=math.abs,floor=math.floor,ceil=math.ceil,round=round,
  sin=function(x)return math.sin(math.rad(x))end,
  cos=function(x)return math.cos(math.rad(x))end,
  tan=function(x)return math.tan(math.rad(x))end,
  sec=function(x)return 1/math.cos(math.rad(x))end,
  csc=function(x)return 1/math.sin(math.rad(x))end,
  cot=function(x)return 1/math.tan(math.rad(x))end,
  asin=function(x)return math.deg(math.asin(x))end,
  acos=function(x)return math.deg(math.acos(x))end,
  atan=function(x)return math.deg(math.atan(x))end,
  deg=math.deg,rad=math.rad,
  log=math.log,ln=math.log,
  log10=function(x)return math.log(x)/math.log(10) end,
  exp=math.exp,pow=math.pow,fact=fact,
  max=math.max,min=math.min,gcd=gcd,
  lcm=function(a,b)local g=gcd(a,b);if g==0 then return 0 end;return math.abs(a*b)/g end,
  clamp=function(x,a,b)return math.max(a,math.min(b,x))end,
  pi=math.pi,e=math.exp(1)
}

local function evaluate(s)
  s=tostring(s or ""):gsub("%s+",""):gsub("×","*"):gsub("÷","/")
  if s=="" then return nil,"Enter an expression." end
  if s:find("[^%d%+%-%*/%%%^%(%)%.,%a_]") then return nil,"Unsupported character." end
  for name in s:gmatch("([%a_][%w_]*)%s*%(") do
    if not allowed[name] then return nil,"Unknown function: "..name end
  end
  s=s:gsub("(%a[%w_]*)",function(name)
    if name=="pi" or name=="e" or allowed[name] then return name end
    return "BAD"
  end)
  if s:find("BAD",1,true) then return nil,"Unknown name." end
  local f,err=load("return "..s,"calculator","t",env)
  if not f then return nil,"Invalid expression: "..tostring(err) end
  local ok,r=pcall(f)
  if not ok then return nil,tostring(r) end
  if type(r)~="number" or r~=r or r==math.huge or r==-math.huge then return nil,"Result is not finite." end
  return r
end

local function calculate(history)
  term.setCursorPos(2,6); term.clearLine(); write("> ")
  local s=read()
  local r,err=evaluate(s)
  if r then history[#history+1]=s.." = "..tostring(r)
  else history[#history+1]=s.." -> "..tostring(err) end
end

local function buttonLayout(w)
  if w>=46 then
    return {
      {2,7,12,2,"Calculate","calculate"},
      {16,7,12,2,"Clear","clear"},
      {30,7,12,2,"Help","help"}
    }
  end

  local gap=1
  local bw=math.max(8,math.floor((w-3)/2))
  return {
    {2,7,bw,2,"Calculate","calculate"},
    {2+bw+gap,7,bw,2,"Clear","clear"},
    {2,10,bw,2,"Help","help"}
  }
end

local function hit(button,x,y)
  return x>=button[1] and x<button[1]+button[3] and y>=button[2] and y<button[2]+button[4]
end

function M.run()
  local history={}
  while true do
    local w,h=term.getSize()
    U.clear(); U.header("Calculator")
    U.label(2,3,"Operators: + - * / % ^ ( )")
    U.label(2,4,"Functions: sqrt abs round sin cos tan sec csc cot")
    U.label(2,5,"More: asin acos atan deg rad log ln log10 exp pow fact gcd lcm clamp")

    local buttons=buttonLayout(w)
    for _,b in ipairs(buttons) do U.button(b[1],b[2],b[3],b[4],b[5],b[5]=="Calculate" and colors.blue or colors.gray) end

    local historyY=14
    if w<46 then historyY=14 end
    U.label(2,historyY,"History",U._accent)
    local y=historyY+1
    for i=math.max(1,#history-3),#history do
      if y>=h then break end
      U.label(3,y,history[i],U._muted)
      y=y+1
    end

    U.status("Enter = calculate | Q/Esc = back")
    local e,a,b,c=os.pullEvent()
    if e=="key" then
      if a==keys.q or a==keys.escape then return
      elseif a==keys.enter then calculate(history) end
    elseif e=="mouse_click" or e=="monitor_touch" then
      for _,button in ipairs(buttons) do
        if hit(button,b,c) then
          if button[6]=="calculate" then calculate(history)
          elseif button[6]=="clear" then history={}
          elseif button[6]=="help" then
            U.label(2,17,"Examples: 2+3*4 | sqrt(81) | sin(30) | round(2.6)",U._muted)
            os.pullEvent()
          end
          break
        end
      end
    end
  end
end

return M
