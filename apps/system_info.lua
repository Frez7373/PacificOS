local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

local function safeCall(fn, fallback)
  local ok, value = pcall(fn)
  return ok and value ~= nil and value or fallback
end

local function formatBytes(value)
  if value == "unlimited" then return "unlimited" end
  value = tonumber(value)
  if not value then return "unknown" end
  local units = {"B", "KB", "MB", "GB"}
  local index = 1
  while value >= 1024 and index < #units do
    value = value / 1024
    index = index + 1
  end
  return string.format("%.1f %s", value, units[index])
end

function M.run()
  while true do
    local w, h = term.getSize()
    local label = safeCall(os.getComputerLabel, "Not set")
    local craftos = safeCall(os.version, "Unknown")
    local free = safeCall(function() return fs.getFreeSpace("/") end, "unknown")
    local capacity = safeCall(function() return fs.getCapacity("/") end, "unknown")
    local devices = peripheral.getNames()

    U.clear()
    U.header("System Information", true)
    U.label(2, 4, "PacificOS 1.8.0", U._accent)
    U.label(2, 5, "Complex Computer International (CCI) 2026", U._text)
    U.label(2, 7, "Computer ID: " .. tostring(os.getComputerID()))
    U.label(2, 8, "Computer label: " .. tostring(label))
    U.label(2, 9, "Terminal: " .. tostring(w) .. " x " .. tostring(h))
    U.label(2, 10, "CraftOS: " .. tostring(craftos))
    U.label(2, 11, "Storage free: " .. formatBytes(free))
    U.label(2, 12, "Storage capacity: " .. formatBytes(capacity))
    U.label(2, 13, "Peripherals: " .. tostring(#devices))

    local y = 15
    for i = 1, math.min(#devices, h - 18) do
      U.label(4, y, tostring(devices[i]) .. " [" .. tostring(peripheral.getType(devices[i])) .. "]", U._muted)
      y = y + 1
    end

    U.backButton(h - 2)
    U.status("Q / Esc / Backspace = close")

    local e, a, b, c = os.pullEvent()
    if U.closeEvent(e, a) then return end
    if (e == "mouse_click" or e == "monitor_touch") and U.backHit(b, c, h - 2, 18) then
      return
    end
  end
end

return M
