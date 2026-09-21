local U = dofile("/pacificos/ui/widgets.lua")
local C = dofile("/pacificos/system/config.lua")
local N = dofile("/pacificos/system/network.lua")
local M = {}

local sections = {"General", "Appearance", "Network", "Security", "System", "Reset"}

local function toggle(key)
  C.set(key, not (C.get(key) == true))
end

local function actionButton(x, y, w, label)
  local screenW, screenH = term.getSize()
  if y < 3 or y >= screenH then return end
  w = math.max(7, math.min(w, screenW - x + 1))
  U.button(x, y, w, 1, label, U._accent)
end

local function prompt(label)
  local _, h = term.getSize()
  U.label(2, h - 3, label, U._accent)
  term.setCursorPos(2, h - 2)
  write("> ")
  return read()
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
      U.button(x, y, math.min(tabW, w - x + 1), 1, name, i == section and U._accent or U._accent2)
    end

    local top = 4 + tabRows * 2
    local buttonW = math.min(30, w - 3)

    if section == 1 then
      U.label(2, top, "Hostname: " .. tostring(C.get("hostname") or "pacificos"), U._accent)
      U.label(2, top + 2, "Default app: " .. tostring(C.get("default_app") or "Files"), U._text)
      actionButton(2, top + 4, buttonW, "Change Hostname")
      actionButton(2, top + 6, buttonW, "Default app = Files")
    elseif section == 2 then
      U.label(2, top, "Theme: Pacific Blue", U._accent)
      U.label(2, top + 2, "Animations: " .. (C.get("animations") and "ON" or "OFF"))
      U.label(2, top + 3, "Sounds preference: " .. (C.get("sounds") and "ON" or "OFF"))
      U.label(2, top + 4, "Clock seconds: " .. (C.get("show_seconds") and "ON" or "OFF"))
      actionButton(2, top + 6, buttonW, "Toggle Animations")
      actionButton(2, top + 8, buttonW, "Toggle Sounds")
      actionButton(2, top + 10, buttonW, "Toggle Seconds")
    elseif section == 3 then
      local status = N.status()
      U.label(2, top, "Network setting: " .. (C.get("network") and "ENABLED" or "DISABLED"), U._accent)
      U.label(2, top + 2, "Modems: " .. tostring(#status.modems) .. " | Open: " .. tostring(status.opened))
      actionButton(2, top + 4, buttonW, "Toggle Network")
      actionButton(2, top + 6, buttonW, "Open All Modems")
      actionButton(2, top + 8, buttonW, "Close Modems")
    elseif section == 4 then
      U.label(2, top, "Notifications: " .. (C.get("notifications") and "ENABLED" or "DISABLED"), U._accent)
      U.label(2, top + 2, "Third-party apps run from /pacificos/userapps.", U._muted)
      actionButton(2, top + 4, buttonW, "Toggle Notifications")
    elseif section == 5 then
      local delay = tonumber(C.get("boot_delay")) or 0.2
      U.label(2, top, "Boot delay: " .. tostring(delay) .. " s", U._accent)
      U.label(2, top + 2, "Auto start: " .. (C.get("autostart") and "ENABLED" or "DISABLED"))
      actionButton(2, top + 4, buttonW, "Toggle Auto Start")
      actionButton(2, top + 6, buttonW, "Boot Delay +0.2 s")
      actionButton(2, top + 8, buttonW, "Boot Delay -0.2 s")
    elseif section == 6 then
      U.label(2, top, "Restore preferences only. Apps and files are not deleted.", U._warn)
      actionButton(2, top + 3, buttonW, "Reset Settings")
    end

    U.backButton(h - 2)
    U.status("Left/Right = sections | Q/Esc/Backspace = close")

    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.left then section = math.max(1, section - 1)
      elseif a == keys.right then section = math.min(#sections, section + 1)
      elseif a == keys.enter then
        -- Enter on the section tabs intentionally does nothing.
      elseif a == keys.n then toggle("notifications")
      end
    elseif e == "mouse_click" or e == "monitor_touch" then
      local selected = nil
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
      elseif section == 1 then
        if U.hit(2, top + 4, buttonW, 1, b, c) then
          local name = prompt("Hostname:")
          name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
          if name ~= "" then C.set("hostname", name) end
        elseif U.hit(2, top + 6, buttonW, 1, b, c) then
          C.set("default_app", "Files")
        end
      elseif section == 2 then
        if U.hit(2, top + 6, buttonW, 1, b, c) then toggle("animations")
        elseif U.hit(2, top + 8, buttonW, 1, b, c) then toggle("sounds")
        elseif U.hit(2, top + 10, buttonW, 1, b, c) then toggle("show_seconds") end
      elseif section == 3 then
        if U.hit(2, top + 4, buttonW, 1, b, c) then
          local enabled = not (C.get("network") == true)
          C.set("network", enabled)
          N.setEnabled(enabled)
        elseif U.hit(2, top + 6, buttonW, 1, b, c) then
          N.open()
          C.set("network", true)
        elseif U.hit(2, top + 8, buttonW, 1, b, c) then
          N.close()
        end
      elseif section == 4 then
        if U.hit(2, top + 4, buttonW, 1, b, c) then toggle("notifications") end
      elseif section == 5 then
        if U.hit(2, top + 4, buttonW, 1, b, c) then
          toggle("autostart")
        elseif U.hit(2, top + 6, buttonW, 1, b, c) then
          C.set("boot_delay", math.min(2, (tonumber(C.get("boot_delay")) or 0.2) + 0.2))
        elseif U.hit(2, top + 8, buttonW, 1, b, c) then
          C.set("boot_delay", math.max(0, (tonumber(C.get("boot_delay")) or 0.2) - 0.2))
        end
      elseif section == 6 then
        if U.hit(2, top + 3, buttonW, 1, b, c) then C.reset() end
      end
    end
  end
end

return M
