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
    U.label(2, 4, "Setting: " .. (status.enabled and "ENABLED" or "DISABLED"), U._accent)
    U.label(2, 5, "Modems: " .. tostring(#status.modems) .. " | Open: " .. tostring(status.opened), U._text)

    local y = 7
    if #status.modems == 0 then
      U.label(3, y, "No modem peripherals detected.", U._muted)
    else
      for i, side in ipairs(status.modems) do
        local open = false
        pcall(function() open = rednet.isOpen(side) end)
        U.label(3, y, tostring(side) .. "  [" .. (open and "OPEN" or "CLOSED") .. "]", open and U._accent or U._muted)
        y = y + 1
      end
    end

    local buttonY = h - 5
    U.button(2, buttonY, math.min(16, w - 3), 1, status.enabled and "DISABLE" or "ENABLE", U._accent)
    if w >= 38 then
      U.button(20, buttonY, 16, 1, "OPEN MODEMS", U._accent2)
      U.button(2, buttonY + 2, 16, 1, "BROADCAST TEST", U._accent2)
      U.backButton(h - 2)
    else
      U.button(2, buttonY + 2, math.min(16, w - 3), 1, "BROADCAST", U._accent2)
      U.backButton(h - 1)
    end

    U.label(2, h - 3, notice, U._muted, math.max(1, w - 3))
    U.status("Q/Esc/Backspace = back")

    local e, a, b, c = os.pullEvent()
    if U.closeEvent(e, a) then return end
    if e == "mouse_click" or e == "monitor_touch" then
      if U.backHit(b, c, (w >= 38) and h - 2 or h - 1, 18) then return end
      if U.hit(2, buttonY, math.min(16, w - 3), 1, b, c) then
        local enabled = not status.enabled
        C.set("network", enabled)
        local ok, err = N.setEnabled(enabled)
        notice = ok and (enabled and "Network enabled." or "Network disabled.") or tostring(err)
      elseif w >= 38 and U.hit(20, buttonY, 16, 1, b, c) then
        local ok, err = N.open()
        notice = ok and ("Opened " .. tostring(err) .. " modem(s).") or tostring(err)
      elseif U.hit(2, buttonY + 2, math.min(16, w - 3), 1, b, c) then
        local ok, err = N.broadcast({type = "ping", from = os.getComputerID(), time = os.clock()}, "pacific")
        notice = ok and "Broadcast sent on protocol pacific." or tostring(err)
      end
    end
  end
end

return M
