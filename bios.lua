local BIOS = {}
BIOS.version = "1.9.0"
BIOS.root = "/pacificos"

local T = dofile(BIOS.root .. "/ui/theme.lua")

local function row(y, text, fg, bg)
  local w, h = term.getSize()
  y = math.max(1, math.min(h, math.floor(tonumber(y) or 1)))
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
  row(h, "B / Esc = Back", T.text, T.panel)
  while true do
    local e, a = os.pullEvent()
    if e == "key" and (a == keys.b or a == keys.escape or a == keys.backspace) then return end
    if e == "mouse_click" or e == "monitor_touch" then return end
  end
end

local function hardwareScreen()
  clear()
  header("Hardware")
  local w, h = term.getSize()
  row(4, "Computer ID: " .. tostring(os.getComputerID()))
  row(5, "Computer label: " .. tostring(os.getComputerLabel() or "not set"))
  row(6, "Terminal: " .. tostring(w) .. "x" .. tostring(h))
  row(7, "Color support: " .. (term.isColor() and "YES" or "NO"), T.accent)

  row(9, "Detected peripherals", T.text, T.panel)
  local names = {}
  for _, name in ipairs(peripheral.getNames()) do names[#names+1] = name end
  table.sort(names)

  local y = 10
  if #names == 0 then
    row(y, "None", T.muted)
  else
    for _, name in ipairs(names) do
      if y >= h - 1 then break end
      row(y, name .. " [" .. tostring(peripheral.getType(name)) .. "]", T.text)
      y = y + 1
    end
  end
  waitBack()
end

local function systemScreen()
  clear()
  header("System")
  row(4, "BIOS version: " .. BIOS.version, T.accent)
  local craft = "unknown"
  local ok, value = pcall(os.version)
  if ok then craft = tostring(value) end
  row(5, "CraftOS: " .. craft)

  local free = "unknown"
  local capacity = "unknown"
  pcall(function() free = fs.getFreeSpace("/") end)
  pcall(function() capacity = fs.getCapacity("/") end)
  row(7, "Free space: " .. tostring(free))
  row(8, "Capacity: " .. tostring(capacity))
  row(9, "Uptime: " .. string.format("%.1f s", os.clock()))
  waitBack()
end

function BIOS.run()
  local items = {"Boot PacificOS","Hardware Information","System Information","Restart Computer","Shutdown Computer"}
  local selected = 1

  while true do
    clear()
    header("Setup Utility")
    local w, h = term.getSize()
    row(4, "CCI BIOS 1.9.0", T.accent)
    row(5, "Arrow keys + Enter or touchscreen", T.muted)

    local startY = 7
    for i, item in ipairs(items) do
      local y = startY + i - 1
      row(y, (i == selected and "> " or "  ") .. item,
        i == selected and T.textOnBlue or T.text,
        i == selected and T.dark or T.bg)
    end

    row(math.max(1, h - 2), "Complex Computer International (CCI) 2026", T.muted, T.bg)
    row(h, "ENTER = select   ESC = exit BIOS", T.text, T.panel)

    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if a == keys.up then selected = math.max(1, selected - 1)
      elseif a == keys.down then selected = math.min(#items, selected + 1)
      elseif a == keys.enter then
        if selected == 1 then return
        elseif selected == 2 then hardwareScreen()
        elseif selected == 3 then systemScreen()
        elseif selected == 4 then os.reboot()
        elseif selected == 5 then os.shutdown()
        end
      elseif a == keys.escape or a == keys.q then
        return
      end
    elseif e == "mouse_click" or e == "monitor_touch" then
      if c >= startY and c < startY + #items and b >= 1 then
        selected = c - startY + 1
        if selected == 1 then return
        elseif selected == 2 then hardwareScreen()
        elseif selected == 3 then systemScreen()
        elseif selected == 4 then os.reboot()
        elseif selected == 5 then os.shutdown()
        end
      end
    end
  end
end

return BIOS
