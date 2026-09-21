-- PACIFICOS BIOS 1.8.1
local BIOS = {}
BIOS.version = "1.8.1"
BIOS.root = "/pacificos"

local T = dofile(BIOS.root .. "/ui/theme.lua")

function BIOS.hardware()
  local w, h = term.getSize()
  local peripherals = {}
  for _, name in ipairs(peripheral.getNames()) do
    peripherals[name] = peripheral.getType(name)
  end

  return {
    id = os.getComputerID(),
    label = os.getComputerLabel(),
    w = w,
    h = h,
    color = term.isColor(),
    peripherals = peripherals
  }
end

local function row(y, text, fg, bg)
  local w, h = term.getSize()
  if y < 1 or y > h then return end
  term.setBackgroundColor(bg or T.bg)
  term.setTextColor(fg or T.text)
  term.setCursorPos(1, y)
  write(string.rep(" ", w))
  term.setCursorPos(2, y)
  write(tostring(text or ""):sub(1, math.max(0, w - 2)))
end

local function clear()
  term.setBackgroundColor(T.bg)
  term.setTextColor(T.text)
  term.clear()
  term.setCursorPos(1, 1)
end

local function header(title)
  row(1, "PACIFICOS BIOS - " .. tostring(title or "Setup Utility"), T.textOnBlue, T.dark)
  row(2, "Classic Setup Utility", T.text, T.panel)
end

local function waitBack()
  local _, h = term.getSize()
  row(h, "[B] Back   [Esc] Back", T.text, T.panel)
  while true do
    local e, a = os.pullEvent()
    if e == "key" and (a == keys.b or a == keys.escape or a == keys.backspace) then
      return
    end
    if e == "mouse_click" or e == "monitor_touch" then return end
  end
end

local function hardwareScreen()
  clear()
  header("Hardware")
  local p = BIOS.hardware()

  row(4, "Computer ID: " .. tostring(p.id))
  row(5, "Computer label: " .. tostring(p.label or "not set"))
  row(6, "Terminal: " .. tostring(p.w) .. "x" .. tostring(p.h))
  row(7, "Color support: " .. (p.color and "YES" or "NO"), T.accent)

  row(9, "Detected peripherals", T.text, T.panel)
  local names = {}
  for name in pairs(p.peripherals) do names[#names + 1] = name end
  table.sort(names)

  local y = 10
  if #names == 0 then
    row(y, "None", T.muted)
  else
    for _, name in ipairs(names) do
      if y >= select(2, term.getSize()) - 1 then break end
      row(y, name .. " [" .. tostring(p.peripherals[name]) .. "]", T.text)
      y = y + 1
    end
  end
  waitBack()
end

local function systemScreen()
  clear()
  header("System")

  local craft = "unknown"
  if type(os.version) == "function" then
    local ok, v = pcall(os.version)
    if ok then craft = tostring(v) end
  end

  row(4, "BIOS version: " .. BIOS.version, T.accent)
  row(5, "CraftOS: " .. craft)
  row(6, "Computer uptime: " .. string.format("%.1f s", os.clock()))

  local free, capacity = "unknown", "unknown"
  pcall(function() free = fs.getFreeSpace("/") end)
  pcall(function() capacity = fs.getCapacity("/") end)
  row(8, "Free space: " .. tostring(free))
  row(9, "Capacity: " .. tostring(capacity))
  waitBack()
end

local function selectAction(selected)
  if selected == 1 then return "boot"
  elseif selected == 2 then return "hardware"
  elseif selected == 3 then return "system"
  elseif selected == 4 then os.reboot()
  elseif selected == 5 then os.shutdown()
  end
end

function BIOS.run()
  local items = {
    "Boot PacificOS",
    "Hardware Information",
    "System Information",
    "Restart Computer",
    "Shutdown Computer"
  }
  local selected = 1

  while true do
    clear()
    header("Setup Utility")

    local _, h = term.getSize()
    row(4, "CCI BIOS 1.8.1", T.accent)
    row(5, "Arrow keys + Enter or touchscreen", T.muted)

    local startY = 7
    for i, item in ipairs(items) do
      local y = startY + i - 1
      local selectedRow = i == selected
      row(y, (selectedRow and "> " or "  ") .. item,
        selectedRow and T.textOnBlue or T.text,
        selectedRow and T.dark or T.bg)
    end

    row(math.max(1, h - 2),
      "Complex Computer International (CCI) 2026", T.muted, T.bg)
    row(h, "ENTER = select   ESC = exit BIOS", T.text, T.panel)

    local e, a, b, c = os.pullEvent()

    if e == "key" then
      if a == keys.up then
        selected = math.max(1, selected - 1)
      elseif a == keys.down then
        selected = math.min(#items, selected + 1)
      elseif a == keys.enter then
        local action = selectAction(selected)
        if action == "boot" then return
        elseif action == "hardware" then hardwareScreen()
        elseif action == "system" then systemScreen()
        end
      elseif a == keys.escape or a == keys.q then
        return
      end

    elseif e == "mouse_click" or e == "monitor_touch" then
      local y = c
      if y >= startY and y < startY + #items then
        selected = y - startY + 1
        local action = selectAction(selected)
        if action == "boot" then return
        elseif action == "hardware" then hardwareScreen()
        elseif action == "system" then systemScreen()
        end
      end
    end
  end
end

return BIOS
