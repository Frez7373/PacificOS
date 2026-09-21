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
  local r = 1
  for i = 2, n do r = r * i end
  return r
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
for key, _ in pairs(env) do
  allowed[key] = true
end

local function evaluate(input, answer)
  local s = tostring(input or "")
  s = s:gsub("%s+", ""):gsub("×", "*"):gsub("÷", "/")
  s = s:gsub("ANS", "ans")

  if s == "" then return nil, "Expression is empty." end
  if s:find("[^%d%+%-%*/%%%^%(%)%.,%a_]") then
    return nil, "Unsupported character."
  end

  for name in s:gmatch("([%a_][%w_]*)%s*%(") do
    if name ~= "ans" and not allowed[name] then
      return nil, "Unknown function: " .. name
    end
  end

  s = s:gsub("([%a_][%w_]*)", function(name)
    if name == "ans" then return "ans" end
    if allowed[name] then return name end
    return "BAD"
  end)
  if s:find("BAD", 1, true) then return nil, "Unknown name." end

  local scope = {}
  for k, v in pairs(env) do scope[k] = v end
  scope.ans = tonumber(answer) or 0

  local fn, err = load("return " .. s, "calculator", "t", scope)
  if not fn then return nil, "Invalid expression: " .. tostring(err) end

  local ok, value = pcall(fn)
  if not ok then return nil, tostring(value) end
  if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
    return nil, "Result is not finite."
  end

  return value
end

local function buttonList()
  return {
    {"7", "7"}, {"8", "8"}, {"9", "9"}, {"/", "/"},
    {"4", "4"}, {"5", "5"}, {"6", "6"}, {"*", "*"},
    {"1", "1"}, {"2", "2"}, {"3", "3"}, {"-", "-"},
    {"0", "0"}, {".", "."}, {"(", "("}, {"+", "+"},
    {"pi", "pi"}, {"e", "e"}, {")", ")"}, {"^", "^"},
    {"sqrt", "sqrt("}, {"sin", "sin("}, {"cos", "cos("}, {"tan", "tan("},
    {"log", "log("}, {"ln", "ln("}, {"fact", "fact("}, {"Clear", "CLEAR"}
  }
end

local function pressButton(action, state)
  if action == "CLEAR" then
    state.expr = ""
    return
  end
  state.expr = state.expr .. action
end

function M.run()
  local state = {expr = "", result = nil, error = nil, history = {}}
  local buttons = buttonList()

  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("Calculator", true)

    U.label(2, 4, "Expression", U._muted)
    U.fill(2, 5, math.max(1, w - 3), 1, U._accent, U._textOnBlue)
    U.label(3, 5, state.expr ~= "" and state.expr or "0", U._textOnBlue)

    if state.result ~= nil then
      U.label(2, 6, "=", U._muted)
      U.label(4, 6, tostring(state.result), U._accent)
    elseif state.error then
      U.label(4, 6, state.error, U._bad)
    end

    local cols = w >= 46 and 4 or 3
    local gap = 1
    local bw = math.max(7, math.floor((w - 2 - (cols - 1) * gap) / cols))
    local startY = 8
    local buttonHeight = 1

    for i, item in ipairs(buttons) do
      local col = (i - 1) % cols
      local row = math.floor((i - 1) / cols)
      local x = 2 + col * (bw + gap)
      local y = startY + row * 2
      if y < h - 4 then
        local bg = item[2] == "CLEAR" and U._bad or U._accent2
        if item[2] == "CLEAR" then bg = colors.red end
        U.button(x, y, bw, buttonHeight, item[1], bg)
      end
    end

    local historyY = h - 4
    U.label(2, historyY, "History", U._muted)
    local visible = 0
    for i = #state.history, 1, -1 do
      if historyY + 1 + visible >= h then break end
      U.label(3, historyY + 1 + visible, state.history[i], U._muted)
      visible = visible + 1
      if visible >= 3 then break end
    end

    U.status("Keyboard works too | Enter = calculate | Backspace = edit | Q/Esc = back")

    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.backspace then
        state.expr = state.expr:sub(1, -2)
        state.error = nil
      elseif a == keys.enter then
        local value, err = evaluate(state.expr, state.result)
        if value ~= nil then
          state.result = value
          state.error = nil
          state.history[#state.history + 1] = state.expr .. " = " .. tostring(value)
        else
          state.error = err
        end
      end
    elseif e == "char" then
      state.expr = state.expr .. a
      state.error = nil
    elseif e == "mouse_click" or e == "monitor_touch" then
      for i, item in ipairs(buttons) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x = 2 + col * (bw + gap)
        local y = startY + row * 2
        if y < h - 4 and U.hit(x, y, bw, buttonHeight, b, c) then
          if item[2] == "CLEAR" then
            pressButton("CLEAR", state)
          else
            pressButton(item[2], state)
          end
          state.error = nil
          break
        end
      end

      local calcY = 8 + math.ceil(#buttons / cols) * 2
      if c == h - 3 and U.backHit(b, c, h - 3, math.min(18, w - 2)) then return end
    end
  end
end

return M
