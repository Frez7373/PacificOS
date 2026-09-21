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
  return ({"General","Appearance","Network","Security","System","Reset"})[index]
end

local function actionList(section)
  if section == 1 then return {"CHANGE HOSTNAME","DEFAULT FILES"} end
  if section == 2 then return {"ANIMATIONS","SOUNDS","SECONDS"} end
  if section == 3 then return {"TOGGLE NETWORK","OPEN MODEMS","CLOSE MODEMS"} end
  if section == 4 then return {"NOTIFICATIONS"} end
  if section == 5 then return {"DELAY -0.2","DELAY +0.2","RESET DELAY"} end
  if section == 6 then return {"RESET SETTINGS"} end
  return {}
end

local function activate(section, action)
  if section == 1 then
    if action == 1 then
      local value = trim(prompt("Hostname:"))
      if value == "" then return "Cancelled." end
      C.set("hostname", value)
      return "Hostname saved."
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
      delay = math.max(0, delay - 0.2)
    elseif action == 2 then
      delay = math.min(2, delay + 0.2)
    elseif action == 3 then
      delay = 0.2
    end
    C.set("boot_delay", delay)
    return "Boot delay: " .. string.format("%.1f s", delay)
  elseif section == 6 and action == 1 then
    C.reset()
    return "Settings restored to defaults."
  end
  return "No action."
end

function M.run()
  local section = 1
  local selected = 1
  local notice = "Left/Right sections | Up/Down actions | Enter select."

  while true do
    local w, h = term.getSize()
    local actions = actionList(section)
    selected = math.max(1, math.min(selected, math.max(1, #actions)))

    U.clear()
    U.header("Settings", true)

    local closeX = math.max(1, w - 3)
    local tabArea = math.max(6, w - 6)
    local tabW = math.max(3, math.floor(tabArea / #sections))

    for i, name in ipairs(sections) do
      local x = 2 + (i - 1) * tabW
      local width = math.min(tabW, w - x + 1)
      if width >= 1 then
        U.button(x, 3, width, 1, name, i == section and U._accent or U._accent2)
      end
    end
    if w >= 6 then U.button(closeX - 1, 3, 4, 1, "X", U._accent2) end

    U.label(2, 5, sectionName(section), U._accent)

    if section == 1 then
      U.label(2, 6, "Hostname: " .. tostring(C.get("hostname") or "pacificos"))
      U.label(2, 7, "Default app: " .. tostring(C.get("default_app") or "Files"), U._muted)
    elseif section == 2 then
      U.label(2, 6, "Theme: Windows Classic / Pacific Blue")
      U.label(2, 7, "Toggle appearance options below.", U._muted)
    elseif section == 3 then
      local status = N.status()
      U.label(2, 6, "Network: " .. (C.get("network") and "ENABLED" or "DISABLED"))
      U.label(2, 7, "Modems: " .. tostring(#status.modems) .. " | Open: " .. tostring(status.opened), U._muted)
    elseif section == 4 then
      U.label(2, 6, "Notifications: " .. (C.get("notifications") and "ENABLED" or "DISABLED"))
      U.label(2, 7, "Local notification preference.", U._muted)
    elseif section == 5 then
      U.label(2, 6, "Boot delay: " .. string.format("%.1f s", tonumber(C.get("boot_delay")) or 0.2))
      U.label(2, 7, "Automatic startup remains enabled.", U._muted)
    elseif section == 6 then
      U.label(2, 6, "Restore PacificOS preferences.", U._warn)
      U.label(2, 7, "Apps and files are not deleted.", U._muted)
    end

    local actionY = 9
    for i, name in ipairs(actions) do
      local y = actionY + i - 1
      if y < h then
        U.button(2, y, math.min(30, w - 3), 1, name,
          i == selected and U._accent or U._accent2,
          i == selected and U._textOnBlue or U._text)
      end
    end

    -- A dedicated visible exit control keeps Settings usable on 39x13 screens.
    if h >= 12 and w >= 8 then
      U.button(w - 9, h - 2, 8, 1, "BACK", U._accent2)
    end
    U.status(notice .. " | 1-6 = section | Q/Esc = back")

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
      elseif a == keys.one then section, selected = 1, 1
      elseif a == keys.two then section, selected = 2, 1
      elseif a == keys.three then section, selected = 3, 1
      elseif a == keys.four then section, selected = 4, 1
      elseif a == keys.five then section, selected = 5, 1
      elseif a == keys.six then section, selected = 6, 1
      end

    elseif e == "mouse_click" or e == "monitor_touch" then
      if h >= 12 and w >= 8 and U.hit(w - 9, h - 2, 8, 1, b, c) then return end
      if w >= 6 and U.hit(closeX - 1, 3, 4, 1, b, c) then return end

      if c == 3 and b >= 2 then
        local tab = math.floor((b - 2) / tabW) + 1
        if tab >= 1 and tab <= #sections then
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
