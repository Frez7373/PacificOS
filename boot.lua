-- PacificOS 1.9.0 boot
local ROOT = "/pacificos"
local C = dofile(ROOT .. "/system/config.lua")

local BOOT_BLUE = colors.blue
local BOOT_WHITE = colors.white
local BOOT_BLACK = colors.black
local BOOT_GRAY = colors.gray
local BOOT_RED = colors.red

local function setSafe(bg, fg)
  pcall(term.setBackgroundColor, bg)
  pcall(term.setTextColor, fg)
end

local function showError(title, message)
  local w, h = term.getSize()
  setSafe(BOOT_WHITE, BOOT_BLACK)
  term.clear()
  term.setCursorPos(1, 1)
  term.setTextColor(BOOT_RED)
  term.setCursorPos(2, math.min(3, h))
  print(tostring(title))
  term.setTextColor(BOOT_BLACK)
  if h >= 5 then print(""); print(tostring(message)) else print(tostring(message)) end
  if h >= 7 then
    print("")
    print("[R] Recovery    [Q] Shutdown")
  end

  while true do
    local e, key = os.pullEvent()
    if e == "key" and key == keys.r then
      local ok = pcall(dofile, ROOT .. "/recovery/recovery.lua")
      if not ok then os.shutdown() end
      return
    elseif e == "key" and (key == keys.q or key == keys.escape) then
      os.shutdown()
      return
    end
  end
end

local function runBIOS()
  local ok, bios = pcall(dofile, ROOT .. "/bios.lua")
  if not ok or type(bios) ~= "table" or type(bios.run) ~= "function" then
    showError("PACIFICOS BIOS ERROR", bios or "bios.lua is invalid.")
    return
  end
  local okRun, err = pcall(bios.run)
  if not okRun then showError("PACIFICOS BIOS ERROR", err) end
end

local function waitForBIOS()
  local w, h = term.getSize()
  setSafe(BOOT_WHITE, BOOT_BLACK)
  term.clear()

  setSafe(BOOT_BLUE, BOOT_WHITE)
  term.setCursorPos(1, 1)
  write(string.rep(" ", w))
  term.setCursorPos(2, 1)
  write(("PACIFICOS 1.9.0"):sub(1, math.max(1, w - 1)))

  setSafe(BOOT_WHITE, BOOT_BLACK)
  term.setCursorPos(2, math.min(4, h))
  write("Press ] quickly to enter BIOS")
  term.setCursorPos(2, math.min(5, h))
  write("BIOS window: 1.5 seconds")
  if h >= 7 then
    term.setCursorPos(2, h - 1)
    term.setTextColor(BOOT_GRAY)
    write("Complex Computer International (CCI) 2026")
  end

  local timer = os.startTimer(1.5)
  while true do
    local e, a = os.pullEvent()
    if e == "char" and a == "]" then runBIOS(); return
    elseif e == "key" and keys.rightBracket and a == keys.rightBracket then runBIOS(); return
    elseif e == "timer" and a == timer then return end
  end
end

waitForBIOS()

local w, h = term.getSize()
setSafe(BOOT_WHITE, BOOT_BLACK)
term.clear()

local function center(y, text, fg)
  local shown = tostring(text or ""):sub(1, math.max(1, w))
  local x = math.max(1, math.floor((w - #shown) / 2) + 1)
  y = math.max(1, math.min(h, math.floor(tonumber(y) or 1)))
  term.setCursorPos(x, y)
  term.setTextColor(fg or BOOT_BLACK)
  write(shown)
end

local function progress(y, percent)
  local barWidth = math.max(8, math.min(math.max(8, w - 6), 42))
  local filled = math.floor(barWidth * math.max(0, math.min(100, percent)) / 100)
  y = math.max(1, math.min(h, math.floor(tonumber(y) or 1)))

  local x = math.max(1, math.floor((w - barWidth) / 2) + 1)
  term.setCursorPos(x, y)
  setSafe(BOOT_GRAY, BOOT_GRAY)
  write(string.rep(" ", barWidth))
  term.setCursorPos(x, y)
  setSafe(BOOT_BLUE, BOOT_WHITE)
  write(string.rep(" ", filled))
  setSafe(BOOT_WHITE, BOOT_BLACK)
end

local centerY = math.max(4, math.floor(h / 2) - 5)
center(centerY, "PACIFICOS", BOOT_BLUE)
center(centerY + 2, "PacificOS 1.9.0", BOOT_BLACK)
center(centerY + 4, "Complex Computer International (CCI)", BOOT_BLACK)
center(centerY + 5, "2026", BOOT_GRAY)

local steps = {
  "Power-on diagnostics","Hardware detection","System files",
  "Kernel","Services","Applications","Graphical interface"
}
local animation = C.get("animations") ~= false
local stepDelay = tonumber(C.get("boot_delay")) or 0.2
stepDelay = math.max(0, math.min(2, stepDelay))
if not animation then stepDelay = 0 end

for i, step in ipairs(steps) do
  local percent = math.floor((i - 1) * 100 / #steps)
  progress(math.min(h - 4, centerY + 7), percent)
  term.setTextColor(BOOT_BLACK)
  term.setCursorPos(2, math.min(h, math.max(1, centerY + 9)))
  write(tostring(step):sub(1, math.max(1, w - 12)))
  if w >= 7 then
    term.setCursorPos(math.max(1, w - 5), math.min(h, math.max(1, centerY + 9)))
    term.setTextColor(BOOT_BLUE)
    write(string.format("%3d%%", percent))
  end
  if stepDelay > 0 then os.sleep(stepDelay) end
end

progress(math.min(h - 4, centerY + 7), 100)
term.setTextColor(BOOT_BLUE)
term.setCursorPos(2, math.min(h, math.max(1, centerY + 9)))
write("SYSTEM READY")
if animation then os.sleep(math.min(0.15, stepDelay > 0 and stepDelay or 0.15)) end

if not fs.exists(ROOT .. "/kernel.lua") then
  showError("PACIFICOS STARTUP ERROR", "System kernel is missing.")
  return
end

local ok, err = pcall(dofile, ROOT .. "/kernel.lua")
if not ok then showError("PACIFICOS STARTUP ERROR", err) end
