local U = dofile("/pacificos/ui/widgets.lua")
local C = dofile("/pacificos/system/config.lua")
local N = dofile("/pacificos/system/network.lua")
local M = {}

local sections = {"General", "Appearance", "Network", "Security", "System", "Reset"}

local function toggle(key)
  C.set(key, not (C.get(key) == true))
end

local function prompt(label)
  local _, h = term.getSize()
  U.label(2, h - 3, label, U._accent)
  term.setCursorPos(2, h - 2)
  write("> ")
  return read()
end

local function button(y, label, width)
  local w, h = term.getSize()
  width = math.max(7, math.min(width or 28, w - 3))
  if y < 3 or y >= h then return end
  U.button(2, y, width, 1, label, U._accent)
end

function M.run()
  local section = 1

  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("Settings", true)

    local cols = w >= 70 and 6 or (w >= 45 and 3 or 2)
    local gap = 1
    local tabW = math.max(8, math.floor((w - 2 - (cols - 1) * gap) / cols))
    local tabRows = math.ceil(#sections / cols)

    for i, name in ipairs(sections) do
      local col = (i - 1) % cols
      local row = math.floor((i - 1) / cols)
      local x = 2 + col * (tabW + gap)
      local y = 3 + row * 2
      U.button(x, y, math.min(tabW, w - x + 1), 1, name,
        i == section and U._accent or U._accent2)
    end

    local top = 4 + tabRows * 2
    local buttonW = math.min(30, w - 3)

    if section == 1 then
      U.label(2, top, "Hostname: " .. tostring(C.get("hostname") or "pacificos"), U._accent)
      button(top + 2, "CHANGE HOSTNAME", buttonW)
      U.label(2, top + 4, "Default app: " .. tostring(C.get("default_app") or "Files"), U._text)
      button(top + 6, "SET DEFAULT = FILES", buttonW)
    elseif section == 2 then
      U.label(2, top, "Theme: PACIFIC BLUE", U._accent)
      U.label(2, top + 2, "Animations: " .. (C.get("animations") and "ON" or "OFF"))
      button(top + 3, "TOGGLE ANIMATIONS", buttonW)
      U.label(2, top + 5, "Sounds preference: " .. (C.get("sounds") and "ON" or "OFF"))
      button(top + 6, "TOGGLE SOUNDS", buttonW)
      U.label(2, top + 8, "Clock seconds: " .. (C.get("show_seconds") and "ON" or "OFF"))
      button(top + 9, "TOGGLE SECONDS", buttonW)
    elseif section == 3 then
      local status = N.status()
      U.label(2, top, "Network: " .. (C.get("network") and "ENABLED" or "DISABLED"), U._accent)
      U.label(2, top + 2, "Modems: " .. tostring(#status.modems) .. " | Open: " .. tostring(status.opened))
      button(top + 3, "TOGGLE NETWORK", buttonW)
      button(top + 5, "OPEN ALL MODEMS", buttonW)
      button(top + 7, "CLOSE MODEMS", buttonW)
    elseif section == 4 then
      U.label(2, top, "Notifications: " .. (C.get("notifications") and "ENABLED" or "DISABLED"), U._accent)
      U.label(2, top + 2, "Preferences are stored locally.", U._muted)
      button(top + 4, "TOGGLE NOTIFICATIONS", buttonW)
    elseif section == 5 then
      local delay = tonumber(C.get("boot_delay")) or 0.2
      U.label(2, top, string.format("Boot delay: %.1f s", delay), U._accent)
      button(top + 2, "TOGGLE AUTO START", buttonW)
      U.label(2, top + 4, "Auto start: " .. (C.get("autostart") and "ON" or "OFF"))
      if w >= 38 then
        local small = math.floor((w - 5) / 2)
        U.button(2, top + 6, small, 1, "DELAY -0.2", U._accent2)
        U.button(3 + small, top + 6, small, 1, "DELAY +0.2", U._accent2)
      else
        button(top + 6, "DELAY -0.2", buttonW)
        button(top + 7, "DELAY +0.2", buttonW)
      end
    elseif section == 6 then
      U.label(2, top, "Restore preferences to defaults.", U._warn)
      U.label(2, top + 2, "This does not delete apps or files.", U._muted)
      button(top + 4, "RESET SETTINGS", buttonW)
    end

    U.backButton(h - 2)
    U.status("Touch a tab | Left/Right = section | Q/Esc/Backspace = back")

    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.left then section = math.max(1, section - 1)
      elseif a == keys.right then section = math.min(#sections, section + 1)
      end
    elseif e == "mouse_click" or e == "monitor_touch" then
      local selected
      if c >= 3 and c < 3 + tabRows * 2 and b >= 2 then
        local col = math.floor((b - 2) / (tabW + gap))
        local row = math.floor((c - 3) / 2)
        local index = row * cols + col + 1
        local left = 2 + col * (tabW + gap)
        if col >= 0 and col < cols and index <= #sections and b >= left and b < left + tabW then
          selected = index
        end
      end

      if selected then
        section = selected
      elseif U.backHit(b, c, h - 2, 18) then
        return
      elseif section == 1 and U.hit(2, top + 2, buttonW, 1, b, c) then
        local value = tostring(prompt("Hostname:") or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if value ~= "" then C.set("hostname", value) end
      elseif section == 1 and U.hit(2, top + 6, buttonW, 1, b, c) then
        C.set("default_app", "Files")
      elseif section == 2 and U.hit(2, top + 3, buttonW, 1, b, c) then
        toggle("animations")
      elseif section == 2 and U.hit(2, top + 6, buttonW, 1, b, c) then
        toggle("sounds")
      elseif section == 2 and U.hit(2, top + 9, buttonW, 1, b, c) then
        toggle("show_seconds")
      elseif section == 3 and U.hit(2, top + 3, buttonW, 1, b, c) then
        local enabled = not (C.get("network") == true)
        C.set("network", enabled)
        N.setEnabled(enabled)
      elseif section == 3 and U.hit(2, top + 5, buttonW, 1, b, c) then
        C.set("network", true)
        N.setEnabled(true)
        N.open()
      elseif section == 3 and U.hit(2, top + 7, buttonW, 1, b, c) then
        N.close()
      elseif section == 4 and U.hit(2, top + 4, buttonW, 1, b, c) then
        toggle("notifications")
      elseif section == 5 and U.hit(2, top + 2, buttonW, 1, b, c) then
        toggle("autostart")
      elseif section == 5 and w >= 38 and c == top + 6 then
        local small = math.floor((w - 5) / 2)
        if b >= 2 and b < 2 + small then
          C.set("boot_delay", math.max(0, (tonumber(C.get("boot_delay")) or 0.2) - 0.2))
        elseif b >= 3 + small and b < 3 + small + small then
          C.set("boot_delay", math.min(2, (tonumber(C.get("boot_delay")) or 0.2) + 0.2))
        end
      elseif section == 5 and w < 38 and U.hit(2, top + 6, buttonW, 1, b, c) then
        C.set("boot_delay", math.max(0, (tonumber(C.get("boot_delay")) or 0.2) - 0.2))
      elseif section == 5 and w < 38 and U.hit(2, top + 7, buttonW, 1, b, c) then
        C.set("boot_delay", math.min(2, (tonumber(C.get("boot_delay")) or 0.2) + 0.2))
      elseif section == 6 and U.hit(2, top + 4, buttonW, 1, b, c) then
        C.reset()
      end
    end
  end
end

return M
