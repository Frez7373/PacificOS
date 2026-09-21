-- PacificOS 1.8.1 boot
local ROOT = "/pacificos"
local T = dofile(ROOT .. "/ui/theme.lua")
local C = dofile(ROOT .. "/system/config.lua")

local function showError(title, message)
  term.setBackgroundColor(T.bg)
  term.setTextColor(T.text)
  term.clear()
  term.setCursorPos(2, 2)
  term.setTextColor(T.bad)
  print(title)
  term.setTextColor(T.text)
  print("")
  print(tostring(message))
  print("")
  term.setTextColor(T.text)
  print("[R] Recovery    [Q] Shutdown")

  while true do
    local e, k = os.pullEvent()
    if e == "key" and k == keys.r then
      local ok, err = pcall(dofile, ROOT .. "/recovery/recovery.lua")
      if not ok then print(""); print(tostring(err)) end
      return
    elseif e == "key" and k == keys.q then
      os.shutdown()
      return
    end
  end
end

local function runBIOS()
  local ok, bios = pcall(dofile, ROOT .. "/bios.lua")
  if not ok or type(bios) ~= "table" or type(bios.run) ~= "function" then
    showError("PACIFICOS BIOS ERROR", bios or "bios.lua does not provide BIOS.run().")
    return
  end

  local okRun, err = pcall(bios.run)
  if not okRun then showError("PACIFICOS BIOS ERROR", err) end
end

local function waitForBIOS()
  local w, h = term.getSize()
  term.setBackgroundColor(T.bg)
  term.setTextColor(T.text)
  term.clear()

  term.setBackgroundColor(T.dark)
  term.setTextColor(T.textOnBlue)
  term.setCursorPos(1, 1)
  write(string.rep(" ", w))
  term.setCursorPos(2, 1)
  write("PACIFICOS 1.8.1")

  term.setBackgroundColor(T.bg)
  term.setTextColor(T.text)
  term.setCursorPos(2, 4)
  write("Press ] quickly to enter BIOS")
  term.setCursorPos(2, 5)
  write("BIOS window: 1.5 seconds")
  term.setCursorPos(2, 7)
  term.setTextColor(T.muted)
  write("Complex Computer International (CCI) 2026")

  term.setCursorPos(2, math.max(1, h - 1))
  term.setTextColor(T.muted)
  write("Starting PacificOS...")

  local timer = os.startTimer(1.5)
  while true do
    local e, a = os.pullEvent()
    if e == "char" and a == "]" then
      runBIOS()
      return
    elseif e == "key" and keys.rightBracket and a == keys.rightBracket then
      runBIOS()
      return
    elseif e == "timer" and a == timer then
      return
    end
  end
end

waitForBIOS()

local w, h = term.getSize()
term.setBackgroundColor(T.bg)
term.setTextColor(T.text)
term.clear()

local function center(y, text, fg)
  text = tostring(text or "")
  local shown = text:sub(1, w)
  local x = math.max(1, math.floor((w - #shown) / 2) + 1)
  term.setCursorPos(x, math.max(1, y))
  term.setTextColor(fg or T.text)
  write(shown)
end

local function progress(y, percent)
  local barWidth = math.max(12, math.min(w - 6, 42))
  local filled = math.floor(barWidth * percent / 100)

  term.setCursorPos(math.max(1, math.floor((w - barWidth) / 2)), y)
  term.setBackgroundColor(T.panel)
  write(string.rep(" ", barWidth))
  term.setCursorPos(math.max(1, math.floor((w - barWidth) / 2)), y)
  term.setBackgroundColor(T.dark)
  write(string.rep(" ", filled))
  term.setBackgroundColor(T.bg)
end

local centerY = math.max(4, math.floor(h / 2) - 5)
center(centerY, "PACIFICOS", T.accent)
center(centerY + 2, "PacificOS 1.8.1", T.text)
center(centerY + 4, "Complex Computer International (CCI)", T.text)
center(centerY + 5, "2026", T.muted)

local steps = {
  "Power-on diagnostics",
  "Hardware detection",
  "System files",
  "Kernel",
  "Services",
  "Applications",
  "Graphical interface"
}

local animation = C.get("animations") ~= false
local stepDelay = tonumber(C.get("boot_delay")) or 0.2
if stepDelay < 0 then stepDelay = 0 end
if stepDelay > 2 then stepDelay = 2 end
if not animation then stepDelay = 0 end

for i, step in ipairs(steps) do
  local percent = math.floor((i - 1) * 100 / #steps)
  progress(math.min(h - 4, centerY + 7), percent)

  term.setCursorPos(2, math.min(h - 2, centerY + 9))
  term.setTextColor(T.text)
  write(step:sub(1, math.max(1, w - 12)))

  term.setTextColor(T.accent)
  term.setCursorPos(math.max(1, w - 6), math.min(h - 2, centerY + 9))
  write(string.format("%3d%%", percent))

  if stepDelay > 0 then os.sleep(stepDelay) end
end

progress(math.min(h - 4, centerY + 7), 100)
term.setTextColor(T.accent)
term.setCursorPos(2, math.min(h - 2, centerY + 9))
write("SYSTEM READY")
if animation then os.sleep(math.min(0.15, stepDelay > 0 and stepDelay or 0.15)) end

if not fs.exists(ROOT .. "/kernel.lua") then
  showError("PACIFICOS STARTUP ERROR", "System kernel is missing.")
  return
end

local ok, err = pcall(dofile, ROOT .. "/kernel.lua")
if not ok then showError("PACIFICOS STARTUP ERROR", err) end
