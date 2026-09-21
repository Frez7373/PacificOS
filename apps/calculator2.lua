local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

local function round(n)
  n = tonumber(n or 0)
  if n >= 0 then return math.floor(n + 0.5) end
  return math.ceil(n - 0.5)
end

local function factorial(n)
  n = math.floor(tonumber(n) or -1)
  if n < 0 or n > 170 then return nil end
  local result = 1
  for i = 2, n do result = result * i end
  return result
end

local function gcd(a, b)
  a = math.floor(math.abs(tonumber(a) or 0))
  b = math.floor(math.abs(tonumber(b) or 0))
  while b ~= 0 do a, b = b, a % b end
  return a
end

local env = {
  pi = math.pi,
  e = math.exp(1),
  sqrt = math.sqrt,
  abs = math.abs,
  floor = math.floor,
  ceil = math.ceil,
  round = round,
  sin = function(x) return math.sin(math.rad(x)) end,
  cos = function(x) return math.cos(math.rad(x)) end,
  tan = function(x) return math.tan(math.rad(x)) end,
  asin = function(x) return math.deg(math.asin(x)) end,
  acos = function(x) return math.deg(math.acos(x)) end,
  atan = function(x) return math.deg(math.atan(x)) end,
  deg = math.deg,
  rad = math.rad,
  log = math.log,
  ln = math.log,
  log10 = function(x) return math.log(x) / math.log(10) end,
  exp = math.exp,
  pow = math.pow,
  fact = factorial,
  gcd = gcd,
  lcm = function(a, b)
    local g = gcd(a, b)
    if g == 0 then return 0 end
    return math.abs(a * b) / g
  end,
  max = math.max,
  min = math.min,
  clamp = function(x, a, b) return math.max(a, math.min(b, x)) end
}

local allowed = {}
for key, _ in pairs(env) do allowed[key] = true end

local function evaluate(input, answer)
  local expression = tostring(input or ""):gsub("%s+", ""):gsub("×", "*"):gsub("÷", "/")
  expression = expression:gsub("ANS", "ans")

  if expression == "" then return nil, "Enter an expression." end
  if expression:find("[^%d%+%-%*/%%%^%(%)%.,%a_]") then
    return nil, "Unsupported character."
  end

  for name in expression:gmatch("([%a_][%w_]*)%s*%(") do
    if name ~= "ans" and not allowed[name] then
      return nil, "Unknown function: " .. name
    end
  end

  expression = expression:gsub("([%a_][%w_]*)", function(name)
    if name == "ans" or allowed[name] then return name end
    return "BAD"
  end)

  if expression:find("BAD", 1, true) then return nil, "Unknown name." end

  local scope = {}
  for k, v in pairs(env) do scope[k] = v end
  scope.ans = tonumber(answer) or 0

  local fn, err = load("return " .. expression, "calculator", "t", scope)
  if not fn then return nil, "Invalid expression: " .. tostring(err) end

  local ok, value = pcall(fn)
  if not ok then return nil, tostring(value) end
  if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
    return nil, "Result is not finite."
  end

  return value
end

local basic = {
  {"7","7"},{"8","8"},{"9","9"},{"DEL","DEL"},
  {"4","4"},{"5","5"},{"6","6"},{"÷","/"},
  {"1","1"},{"2","2"},{"3","3"},{"×","*"},
  {"0","0"},{".","."},{"-","-"},{"+","+"},
  {"(","("},{")",")"},{"^","^"},{"=","="},
  {"pi","pi"},{"e","e"},{"ANS","ans"},{"CLEAR","CLEAR"}
}

local scientific = {
  {"sqrt","sqrt("},{"sin","sin("},{"cos","cos("},{"tan","tan("},
  {"asin","asin("},{"acos","acos("},{"atan","atan("},{"log","log("},
  {"ln","ln("},{"log10","log10("},{"exp","exp("},{"pow","pow("},
  {"fact","fact("},{"gcd","gcd("},{"lcm","lcm("},{"clamp","clamp("},
  {"abs","abs("},{"round","round("},{"floor","floor("},{"ceil","ceil("},
  {"max","max("},{"min","min("},{"deg","deg("},{"rad","rad("}
}

local function press(item, state)
  local action = item[2]
  if action == "CLEAR" then
    state.expr = ""
    state.error = nil
  elseif action == "DEL" then
    state.expr = state.expr:sub(1, -2)
    state.error = nil
  elseif action == "=" then
    local value, err = evaluate(state.expr, state.result)
    if value ~= nil then
      state.result = value
      state.history[#state.history + 1] = state.expr .. " = " .. tostring(value)
      state.error = nil
    else
      state.error = err
    end
  else
    state.expr = state.expr .. action
    state.error = nil
  end
end

function M.run()
  local state = {expr = "", result = nil, error = nil, history = {}, mode = "Basic"}

  while true do
    local w, h = term.getSize()
    local items = state.mode == "Basic" and basic or scientific

    U.clear()
    U.header("Calculator", true)

    U.button(2, 3, 12, 1, state.mode == "Basic" and "BASIC" or "SCIENTIFIC", U._accent)
    U.label(16, 3, "ANS = last result", U._muted)

    U.label(2, 5, "Expression", U._muted)
    U.fill(2, 6, math.max(1, w - 3), 1, U._accent, U._textOnBlue)
    U.label(3, 6, state.expr == "" and "0" or state.expr, U._textOnBlue)

    if state.result ~= nil then
      U.label(2, 7, "Result:", U._muted)
      U.label(10, 7, tostring(state.result), U._accent)
    elseif state.error then
      U.label(2, 7, state.error, U._bad, math.max(1, w - 3))
    end

    local cols = 4
    local gap = 1
    local bw = math.max(7, math.floor((w - 2 - (cols - 1) * gap) / cols))
    local startY = 9

    for i, item in ipairs(items) do
      local col = (i - 1) % cols
      local row = math.floor((i - 1) / cols)
      local x = 2 + col * (bw + gap)
      local y = startY + row * 2
      if y < h - 4 then
        local bg = item[2] == "CLEAR" and colors.red or (item[2] == "=" and U._accent or U._accent2)
        local fg = item[2] == "CLEAR" or item[2] == "=" and colors.white or U._text
        U.button(x, y, bw, 1, item[1], bg, fg)
      end
    end

    local switchY = h - 3
    U.button(2, switchY, 14, 1, state.mode == "Basic" and "SCIENTIFIC" or "BASIC", U._accent)
    U.button(17, switchY, math.min(20, w - 18), 1, "BACK", U._accent2)

    local historyY = h - 6
    U.label(math.max(1, w - 28), historyY, "Recent", U._muted, math.min(26, w - 2))
    local hy = historyY + 1
    local shown = 0
    for i = #state.history, 1, -1 do
      if hy >= h - 3 then break end
      U.label(math.max(1, w - 28), hy, state.history[i], U._muted, math.min(26, w - 2))
      hy = hy + 1
      shown = shown + 1
      if shown >= 3 then break end
    end

    U.status("Keyboard: numbers/operators | Enter = result | Q/Esc = back")

    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.backspace then
        state.expr = state.expr:sub(1, -2)
        state.error = nil
      elseif a == keys.enter then
        press({"=","="}, state)
      end
    elseif e == "char" then
      if a == "," then a = "." end
      state.expr = state.expr .. a
      state.error = nil
    elseif e == "mouse_click" or e == "monitor_touch" then
      if U.hit(2, 3, 12, 1, b, c) or U.hit(2, switchY, 14, 1, b, c) then
        state.mode = state.mode == "Basic" and "Scientific" or "Basic"
      elseif U.hit(17, switchY, math.max(1, math.min(20, w - 18)), 1, b, c) then
        return
      else
        for i, item in ipairs(items) do
          local col = (i - 1) % cols
          local row = math.floor((i - 1) / cols)
          local x = 2 + col * (bw + gap)
          local y = startY + row * 2
          if y < h - 4 and U.hit(x, y, bw, 1, b, c) then
            press(item, state)
            break
          end
        end
      end
    end
  end
end

return M
