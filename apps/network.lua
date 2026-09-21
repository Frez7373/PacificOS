local U = dofile("/pacificos/ui/widgets.lua")
local N = dofile("/pacificos/system/network.lua")
local C = dofile("/pacificos/system/config.lua")
local M = {}

function M.run()
  N.setEnabled(C.get("network") ~= false)
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
      if y >= h - 8 then break end
      local isOpen = false
      pcall(function() isOpen = rednet.isOpen(side) end)
      U.label(3, y, tostring(side) .. "  [" .. (isOpen and "OPEN" or "CLOSED") .. "]",
        isOpen and U._accent or U._muted)
      y = y + 1
    end

    if #status.modems == 0 then
      U.label(3, 7, "No modem peripherals detected.", U._muted)
    end

    local actionY = math.max(9, h - 6)
    local buttonW = math.min(16, w - 3)
    U.button(2, actionY, buttonW, 1, status.enabled and "DISABLE" or "ENABLE", U._accent)

    if w >= 38 then
      U.button(20, actionY, math.min(16, w - 19), 1, "OPEN MODEMS", U._accent2)
      U.button(2, actionY + 2, math.min(26, w - 3), 1, "BROADCAST TEST", U._accent2)
      U.backButton(h - 2)
    else
      U.button(2, actionY + 2, buttonW, 1, "BROADCAST", U._accent2)
      U.backButton(h - 2)
    end

    U.label(2, math.max(7, actionY - 1), notice, U._muted, math.max(1, w - 3))
    U.status("Q/Esc/Backspace = back")

    local e, a, b, c = os.pullEvent()
    if U.closeEvent(e, a) then return end

    if e == "mouse_click" or e == "monitor_touch" then
      if U.backHit(b, c, h - 2, 18) then return end

      if U.hit(2, actionY, buttonW, 1, b, c) then
        local enabled = not status.enabled
        C.set("network", enabled)
        local ok, err = N.setEnabled(enabled)
        notice = ok and (enabled and "Network enabled." or "Network disabled.") or tostring(err)
      elseif w >= 38 and U.hit(20, actionY, math.min(16, w - 19), 1, b, c) then
        local ok, err = N.open()
        notice = ok and ("Opened " .. tostring(err) .. " modem(s).") or tostring(err)
      elseif U.hit(2, actionY + 2, math.min(26, w - 3), 1, b, c) then
        local ok, err = N.broadcast({
          type = "ping",
          from = os.getComputerID(),
          time = os.clock()
        }, "pacific")
        notice = ok and "Broadcast sent." or tostring(err)
      end
    end
  end
end

return M
