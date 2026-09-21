local U = dofile("/pacificos/ui/widgets.lua")
local D = dofile("/pacificos/system/devices.lua")
local N = dofile("/pacificos/system/network.lua")
local C = dofile("/pacificos/system/config.lua")
local M = {}

local function bytes(value)
  if value == "unlimited" then return "unlimited" end
  value = tonumber(value)
  if not value then return "unknown" end
  if value >= 1024 * 1024 then return string.format("%.1f MB", value / 1024 / 1024) end
  if value >= 1024 then return string.format("%.1f KB", value / 1024) end
  return tostring(value) .. " B"
end

function M.run()
  local timer = os.startTimer(0.5)
  while true do
    local w, h = term.getSize()
    local dev = D.list()
    local net = N.status()
    local used = 0
    local capacity = "unknown"

    local ok, stats = pcall(function()
      local FS = dofile("/pacificos/system/filesystem.lua")
      return FS.stats("/pacificos")
    end)
    if ok and type(stats) == "table" then used = stats.bytes or 0 end
    pcall(function() capacity = fs.getCapacity("/") end)

    U.clear()
    U.header("System Monitor", true)
    U.label(2, 4, "Live system status", U._accent)
    U.label(2, 5, "Computer ID: " .. tostring(os.getComputerID()))
    U.label(2, 6, "Uptime: " .. string.format("%.1f s", os.clock()))
    U.label(2, 7, "Memory: " .. string.format("%.1f KB", collectgarbage("count")))
    U.label(2, 8, "PacificOS files: " .. bytes(used))
    U.label(2, 9, "Disk capacity: " .. bytes(capacity))
    U.label(2, 10, "Network: " .. (net.opened > 0 and "ONLINE" or "OFFLINE"))
    U.label(2, 11, "Peripherals: " .. tostring(#dev))
    U.label(2, 12, "Theme: Pacific Blue")

    local y = 14
    for i = 1, math.min(#dev, math.max(1, h - 16)) do
      local d = dev[i]
      U.label(3, y, tostring(d.side) .. " | " .. tostring(d.type), U._muted)
      y = y + 1
    end

    U.backButton(h - 2)
    U.status("Live refresh | Q/Esc/Backspace = back")

    local e, a, b, c = os.pullEvent()
    if e == "timer" and a == timer then
      timer = os.startTimer(0.5)
    elseif U.closeEvent(e, a) then
      return
    elseif (e == "mouse_click" or e == "monitor_touch") and U.backHit(b, c, h - 2, 18) then
      return
    end
  end
end

return M
