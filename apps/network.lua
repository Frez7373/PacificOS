local U = dofile("/pacificos/ui/widgets.lua")
local N = dofile("/pacificos/system/network.lua")
local C = dofile("/pacificos/system/config.lua")
local M = {}

function M.run()
  local okSet = pcall(N.setEnabled, C.get("network") ~= false)
  if not okSet then N.enabled = C.get("network") ~= false end
  local notice = "Ready."

  while true do
    local w, h = term.getSize()
    local status = N.status()

    U.clear()
    U.header("Network Manager", true)
    U.label(2, 4, "Network: " .. (status.enabled and "ENABLED" or "DISABLED"), U._accent)
    U.label(2, 5, "Modems: " .. tostring(#status.modems) .. " | Open: " .. tostring(status.opened))

    local y = 7
    for i, side in ipairs(status.modems) do
      if y >= math.max(7, h - 6) then break end
      local isOpen = false
      pcall(function() isOpen = rednet.isOpen(side) end)
      U.label(3, y, tostring(side) .. " [" .. (isOpen and "OPEN" or "CLOSED") .. "]",
        isOpen and U._accent or U._muted)
      y = y + 1
    end

    if #status.modems == 0 then
      U.label(3, 7, "No modem peripherals detected.", U._muted)
    end

    local actionY = math.max(8, h - 5)
    local mainW = math.min(16, math.max(8, w - 3))
    U.button(2, actionY, mainW, 1, status.enabled and "DISABLE" or "ENABLE", U._accent)

    if w >= 38 then
      local secondW = math.min(16, math.max(8, w - 19))
      U.button(20, actionY, secondW, 1, "OPEN MODEMS", U._accent2)
      U.button(2, actionY + 2, math.min(26, w - 3), 1, "BROADCAST", U._accent2)
    else
      U.button(2, actionY + 2, mainW, 1, "BROADCAST", U._accent2)
    end

    U.backButton(h - 2)
    U.label(2, math.max(7, actionY - 1), notice, U._muted, math.max(1, w - 3))
    U.status("E = enable/disable | O = open | B = broadcast | Q/Esc = back")

    local e, a, b, c = os.pullEvent()
    if U.closeEvent(e, a) then return end

    if e == "key" then
      if a == keys.e then
        local enabled = not status.enabled
        C.set("network", enabled)
        local ok, err = N.setEnabled(enabled)
        notice = ok and ("Network " .. (enabled and "enabled." or "disabled.")) or tostring(err)
      elseif a == keys.o then
        C.set("network", true)
        local ok, value = N.setEnabled(true)
        notice = ok and ("Opened " .. tostring(value or 0) .. " modem(s).") or tostring(value)
      elseif a == keys.b then
        local ok, err = N.broadcast({type="ping", from=os.getComputerID(), time=os.clock()}, "pacific")
        notice = ok and "Broadcast sent." or tostring(err)
      elseif a == keys.enter then
        local ok, err = N.broadcast({type="ping", from=os.getComputerID(), time=os.clock()}, "pacific")
        notice = ok and "Broadcast sent." or tostring(err)
      end

    elseif e == "mouse_click" or e == "monitor_touch" then
      if U.backHit(b, c, h - 2, 18) then return end

      if U.hit(2, actionY, mainW, 1, b, c) then
        local enabled = not status.enabled
        C.set("network", enabled)
        local ok, err = N.setEnabled(enabled)
        notice = ok and ("Network " .. (enabled and "enabled." or "disabled.")) or tostring(err)
      elseif w >= 38 and U.hit(20, actionY, math.min(16, math.max(8, w - 19)), 1, b, c) then
        C.set("network", true)
        local ok, value = N.setEnabled(true)
        notice = ok and ("Opened " .. tostring(value or 0) .. " modem(s).") or tostring(value)
      elseif U.hit(2, actionY + 2, math.min(w - 3, w >= 38 and 26 or mainW), 1, b, c) then
        local ok, err = N.broadcast({type="ping", from=os.getComputerID(), time=os.clock()}, "pacific")
        notice = ok and "Broadcast sent." or tostring(err)
      end
    end
  end
end

return M
