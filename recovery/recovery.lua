local ROOT = "/pacificos"
local T = dofile(ROOT .. "/ui/theme.lua")

local function clear()
  term.setBackgroundColor(T.bg)
  term.setTextColor(T.text)
  term.clear()
  term.setCursorPos(1, 1)
end

local function diagnostics()
  clear()
  term.setBackgroundColor(T.dark)
  term.setTextColor(T.textOnBlue)
  term.clear()
  term.setCursorPos(2, 1)
  write("PACIFICOS RECOVERY - DIAGNOSTICS")

  term.setBackgroundColor(T.bg)
  term.setTextColor(T.text)
  term.setCursorPos(2, 3)
  print("Computer ID: " .. tostring(os.getComputerID()))
  print("Terminal: " .. select(1, term.getSize()) .. "x" .. select(2, term.getSize()))

  local free, capacity = "unknown", "unknown"
  pcall(function() free = fs.getFreeSpace("/") end)
  pcall(function() capacity = fs.getCapacity("/") end)
  print("Free space: " .. tostring(free))
  print("Capacity: " .. tostring(capacity))

  print("")
  print("Required files:")
  local required = {"boot.lua", "bios.lua", "kernel.lua", "manifest.lua"}
  for _, name in ipairs(required) do
    print("  [" .. (fs.exists(ROOT .. "/" .. name) and "OK" or "MISSING") .. "] " .. name)
  end

  print("")
  print("Peripherals:")
  for _, side in ipairs(peripheral.getNames()) do
    print("  " .. tostring(side) .. " [" .. tostring(peripheral.getType(side)) .. "]")
  end

  print("")
  print("Press any key to return.")
  os.pullEvent()
end

local function startNormal()
  local ok, err = pcall(dofile, ROOT .. "/boot.lua")
  if not ok then
    print("")
    print("Boot failed: " .. tostring(err))
    os.pullEvent()
  end
end

local function startSafe()
  clear()
  print("PACIFICOS SAFE MODE")
  print("")
  print("Third-party desktop applications are disabled.")
  print("System applications remain available.")
  print("")
  _G.PACIFICOS_SAFE_MODE = true
  local ok, err = pcall(dofile, ROOT .. "/kernel.lua")
  _G.PACIFICOS_SAFE_MODE = nil

  if not ok then
    print("")
    print("Safe Mode failed: " .. tostring(err))
    print("")
    print("Press any key.")
    os.pullEvent()
  end
end

local function reinstall()
  clear()
  print("PACIFICOS RECOVERY")
  print("")
  if not http then
    print("HTTP API is unavailable.")
    print("Enable HTTP in CC:Tweaked and try again.")
    os.pullEvent()
    return
  end

  if not shell or not shell.run then
    print("Shell API is unavailable.")
    os.pullEvent()
    return
  end

  print("Downloading official installer...")
  local ok, err = pcall(shell.run, "wget", "run",
    "https://raw.githubusercontent.com/Frez7373/PacificOS/main/installer.lua")
  if not ok then print("Installer error: " .. tostring(err)) end
  print("")
  print("Press any key.")
  os.pullEvent()
end

local items = {
  "Start PacificOS",
  "Safe Mode",
  "System Diagnostics",
  "Factory Reset",
  "Reinstall PacificOS",
  "Shutdown"
}
local selected = 1

while true do
  clear()
  term.setBackgroundColor(T.dark)
  term.setTextColor(T.textOnBlue)
  term.clear()
  term.setCursorPos(2, 1)
  write("PACIFICOS RECOVERY 1.8.0")

  local w, h = term.getSize()
  for i, item in ipairs(items) do
    local y = 4 + i - 1
    local bg = i == selected and T.accent or T.panel
    local fg = i == selected and T.textOnBlue or T.text
    term.setBackgroundColor(bg)
    term.setTextColor(fg)
    term.setCursorPos(2, y)
    write(string.rep(" ", math.max(1, w - 2)))
    term.setCursorPos(3, y)
    write(item:sub(1, math.max(1, w - 3)))
  end

  term.setBackgroundColor(T.dark)
  term.setTextColor(T.textOnBlue)
  term.setCursorPos(2, h)
  write("Up/Down + Enter | Touch | Esc = shutdown")

  local e, a, b, c = os.pullEvent()

  if e == "key" then
    if a == keys.up then
      selected = math.max(1, selected - 1)
    elseif a == keys.down then
      selected = math.min(#items, selected + 1)
    elseif a == keys.enter then
      if selected == 1 then startNormal(); return
      elseif selected == 2 then startSafe(); return
      elseif selected == 3 then diagnostics()
      elseif selected == 4 then pcall(dofile, ROOT .. "/recovery/factory_reset.lua"); return
      elseif selected == 5 then reinstall()
      elseif selected == 6 then os.shutdown()
      end
    elseif a == keys.escape or a == keys.q then
      os.shutdown()
    end
  elseif e == "mouse_click" or e == "monitor_touch" then
    if c >= 4 and c < 4 + #items then
      selected = c - 3
      if selected == 1 then startNormal(); return
      elseif selected == 2 then startSafe(); return
      elseif selected == 3 then diagnostics()
      elseif selected == 4 then pcall(dofile, ROOT .. "/recovery/factory_reset.lua"); return
      elseif selected == 5 then reinstall()
      elseif selected == 6 then os.shutdown()
      end
    end
  end
end
