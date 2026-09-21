local U = dofile("/pacificos/ui/widgets.lua")
local C = dofile("/pacificos/system/config.lua")
local N = dofile("/pacificos/system/network.lua")
local M = {}

local sections = {"GEN","APP","NET","SEC","SYS","RST"}

local function trim(value)
  return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function prompt(label)
  local _, h = term.getSize()
  U.label(2, math.max(4, h - 3), label, U._accent)
  term.setCursorPos(2, math.max(5, h - 2))
  write("> ")
  return read()
end

local function sectionName(index)
  local names = {"General","Appearance","Network","Security","System","Reset"}
  return names[index]
end

local function actionList(section)
  if section == 1 then return {"CHANGE HOSTNAME","DEFAULT FILES"} end
  if section == 2 then return {"ANIMATIONS","SOUNDS","SECONDS"} end
  if section == 3 then return {"TOGGLE NETWORK","OPEN MODEMS","CLOSE MODEMS"} end
  if section == 4 then return {"NOTIFICATIONS"} end
  if section == 5 then return {"DELAY -0.2","DELAY +0.2","RESET BOOT DELAY"} end
  if section == 6 then return {"RESET SETTINGS"} end
  return {}
end

local function activate(section, action)
  if section == 1 then
    if action == 1 then
      local value = trim(prompt("Hostname:"))
      if value ~= "" then C.set("hostname", value); return "Hostname saved." end
      return "Cancelled."
    elseif action == 2 then
      C.set("default_app", "Files")
      return "Default app set to Files."
    end
  elseif section == 2 then
    if action == 1 then
      C.set("animations", not (C.get("animations") == true))
      return "Animations " .. (C.get("animations") and "enabled." or "disabled.")
    elseif action == 2 then
      C.set("sounds", not (C.get("sounds") == true))
      return "Sounds " .. (C.get("sounds") and "enabled." or "disabled.")
    elseif action == 3 then
      C.set("show_seconds", not (C.get("show_seconds") == true))
      return "Seconds " .. (C.get("show_seconds") and "enabled." or "disabled.")
    end
  elseif section == 3 then
    if action == 1 then
      local enabled = not (C.get("network") == true)
      C.set("network", enabled)
      local ok, err = N.setEnabled(enabled)
      return ok and ("Network " .. (enabled and "enabled." or "disabled.")) or tostring(err)
    elseif action == 2 then
      C.set("network", true)
      local ok, value = N.setEnabled(true)
      return ok and ("Opened " .. tostring(value or 0) .. " modem(s).") or tostring(value)
    elseif action == 3 then
      N.close()
      return "Modems closed."
    end
  elseif section == 4 and action == 1 then
    C.set("notifications", not (C.get("notifications") == true))
    return "Notifications " .. (C.get("notifications") and "enabled." or "disabled.")
  elseif section == 5 then
    local delay = tonumber(C.get("boot_delay")) or 0.2
    if action == 1 then
      C.set("boot_delay", math.max(0, delay - 0.2))
    elseif action == 2 then
      C.set("boot_delay", math.min(2, delay + 0.2))
    elseif action == 3 then
      C.set("boot_delay", 0.2)
    end
    return "Boot delay: " .. string.format("%.1f s", tonumber(C.get("boot_delay")) or 0.2)
  elseif section == 6 and action == 1 then
    C.reset()
    return "Settings restored to defaults."
  end
  return "No action."
end

function M.run()
  local section = 1
  local selected = 1
  local notice = "Use Left/Right for sections, Up/Down for actions."

  while true do
    local w, h = term.getSize()
    local actions = actionList(section)
    if selected > #actions then selected = math.max(1, #actions) end
    if selected < 1 then selected = 1 end

    U.clear()
    U.header("Settings", true)

    local closeX = math.max(1, w - 3)
    local tabW = math.max(3, math.floor((math.max(6, w - 6)) / #sections))
    for i, name in ipairs(sections) do
      local x = 2 + (i - 1) * tabW
      local width = math.min(tabW, w - x + 1)
      U.button(x, 3, width, 1, name, i == section and U._accent or U._accent2)
    end
    if w >= 6 then
      U.button(closeX - 1, 3, 4, 1, "X", U._accent2)
    end

    U.label(2, 5, sectionName(section), U._accent)
    if section == 1 then
      U.label(2, 6, "Hostname: " .. tostring(C.get("hostname") or "pacificos"))
      U.label(2, 7, "Default app: " .. tostring(C.get("default_app") or "Files"), U._muted)
    elseif section == 2 then
      U.label(2, 6, "Theme: Windows Classic / Pacific Blue", U._text)
      U.label(2, 7, "Appearance settings", U._muted)
    elseif section == 3 then
      local status = N.status()
      U.label(2, 6, "Network: " .. (C.get("network") and "ENABLED" or "DISABLED"), U._text)
      U.label(2, 7, "Modems: " .. tostring(#status.modems) .. " | Open: " .. tostring(status.opened), U._muted)
    elseif section == 4 then
      U.label(2, 6, "Notifications: " .. (C.get("notifications") and "ENABLED" or "DISABLED"), U._text)
      U.label(2, 7, "Local notification preference.", U._muted)
    elseif section == 5 then
      U.label(2, 6, "Boot delay: " .. string.format("%.1f s", tonumber(C.get("boot_delay")) or 0.2), U._text)
      U.label(2, 7, "Auto start stays enabled for normal boot.", U._muted)
    elseif section == 6 then
      U.label(2, 6, "Restore PacificOS preferences.", U._warn)
      U.label(2, 7, "Files, apps and user data are not deleted.", U._muted)
    end

    local actionY = 9
    for i, name in ipairs(actions) do
      if actionY + i - 1 < h - 2 then
        U.button(2, actionY + i - 1, math.min(30, w - 3), 1, name,
          i == selected and U._accent or U._accent2,
          i == selected and U._textOnBlue or U._text)
      end
    end

    U.status(notice .. " | Q/Esc/Backspace = back")
    local e, a, b, c = os.pullEvent()

    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.left then
        section = math.max(1, section - 1)
        selected = 1
      elseif a == keys.right then
        section = math.min(#sections, section + 1)
        selected = 1
      elseif a == keys.up then
        selected = math.max(1, selected - 1)
      elseif a == keys.down then
        selected = math.min(math.max(1, #actions), selected + 1)
      elseif a == keys.enter and #actions > 0 then
        notice = activate(section, selected)
      elseif a == keys.one then
        section, selected = 1, 1
      elseif a == keys.two then
        section, selected = 2, 1
      elseif a == keys.three then
        section, selected = 3, 1
      elseif a == keys.four then
        section, selected = 4, 1
      elseif a == keys.five then
        section, selected = 5, 1
      elseif a == keys.six then
        section, selected = 6, 1
      end

    elseif e == "mouse_click" or e == "monitor_touch" then
      if U.backHit(b, c, h - 2, 18) then return end
      if w >= 6 and U.hit(closeX - 1, 3, 4, 1, b, c) then return end

      local tab = math.floor((b - 2) / tabW) + 1
      if c == 3 and tab >= 1 and tab <= #sections then
        local x0 = 2 + (tab - 1) * tabW
        if b >= x0 and b < x0 + tabW then
          section, selected = tab, 1
        end
      elseif c >= actionY and c < actionY + #actions then
        local index = c - actionY + 1
        if index <= #actions then
          selected = index
          notice = activate(section, selected)
        end
      end
    end
  end
end

return M
