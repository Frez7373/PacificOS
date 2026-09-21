local ROOT = "/pacificos"
local T = dofile(ROOT .. "/ui/theme.lua")
local U = dofile(ROOT .. "/ui/widgets.lua")
local C = dofile(ROOT .. "/system/config.lua")
local D = dofile(ROOT .. "/system/devices.lua")
local N = dofile(ROOT .. "/system/network.lua")
local ThirdParty = dofile(ROOT .. "/system/apps.lua")

local builtins = {
  {"Files", "apps/files.lua"},
  {"Settings", "apps/settings.lua"},
  {"Calculator", "apps/calculator2.lua"},
  {"Clock", "apps/clock.lua"},
  {"Calendar", "apps/calendar.lua"},
  {"Network", "apps/network.lua"},
  {"Devices", "apps/devices.lua"},
  {"Editor", "apps/editor.lua"},
  {"Terminal", "apps/terminal.lua"},
  {"Task Manager", "apps/task_manager.lua"},
  {"Updater", "apps/updater.lua"},
  {"App Installer", "apps/installer.lua"},
  {"Antivirus", "apps/antivirus.lua"},
  {"System Info", "apps/system_info.lua"},
  {"System Monitor", "apps/system_monitor.lua"},
  {"Stopwatch", "apps/stopwatch.lua"},
  {"Converter", "apps/converter.lua"},
  {"About", "apps/about.lua"}
}

local kernelPage = 1

local function getApps()
  local result = {}
  for _, app in ipairs(builtins) do
    result[#result + 1] = {name=app[1], path=app[2], builtin=true}
  end

  if not _G.PACIFICOS_SAFE_MODE then
    local ok, list = pcall(ThirdParty.listDesktop)
    if ok and type(list) == "table" then
      for _, app in ipairs(list) do
        if type(app) == "table" and type(app.name) == "string" and type(app.path) == "string" then
          result[#result + 1] = {
            name=app.name, path=app.path, builtin=false, external=true
          }
        end
      end
    end
  end
  return result
end

local function layout()
  local w, h = term.getSize()
  local columns = w >= 76 and 4 or (w >= 50 and 3 or (w >= 31 and 2 or 1))
  local rows = math.max(1, math.floor((h - 8) / 3))
  return math.max(1, columns * rows), columns, rows
end

local function pageCount(apps)
  local perPage = layout()
  return math.max(1, math.ceil(#apps / perPage))
end

local function showAppError(app, err)
  local w, h = term.getSize()
  U.clear()
  U.header("Application Error", true)
  U.label(2, 4, "The application stopped safely.", T.bad)
  U.label(2, 6, "App: " .. tostring(app.name), T.text)
  U.label(2, 7, "Path: " .. tostring(app.path), T.muted)
  U.label(2, 9, tostring(err), T.bad, math.max(1, w - 3))
  U.backButton(h - 2)
  U.status("Enter / Q / Esc / Backspace = return")

  while true do
    local e, a, b, c = os.pullEvent()
    if e == "key" and (a == keys.enter or U.closeEvent(e, a)) then return end
    if (e == "mouse_click" or e == "monitor_touch") and U.backHit(b, c, h - 2, 18) then return end
  end
end

local function runApp(app)
  U.clear()
  U.header(app.name, true)

  local ok, result = pcall(dofile, ROOT .. "/" .. app.path)
  if ok and type(result) == "table" and type(result.run) == "function" then
    ok, result = pcall(result.run)
  elseif ok and type(result) == "function" then
    ok, result = pcall(result)
  elseif ok and result == nil then
    ok = true
  end

  if not ok then showAppError(app, result) end
  term.setBackgroundColor(T.bg)
  term.setTextColor(T.text)
end

local function drawDesktop()
  local apps = getApps()
  local w, h = term.getSize()
  local perPage, columns = layout()
  local pages = pageCount(apps)

  kernelPage = math.max(1, math.min(kernelPage, pages))
  U.clear(T.bg)

  U.fill(1, 1, w, 1, T.dark, T.textOnBlue)
  U.label(2, 1, "PacificOS Desktop", T.textOnBlue, math.max(1, w - 18))
  local right = "ID " .. tostring(os.getComputerID())
  if #right < w - 2 then
    U.label(math.max(1, w - #right + 1), 1, right, T.textOnBlue)
  end

  U.fill(1, 2, w, 1, T.panel, T.text)
  U.label(2, 2, "Start   Programs   System", T.text, math.max(1, w - 2))
  local clock = textutils.formatTime(os.time(), C.get("show_seconds") == true)
  if w >= 28 then U.label(math.max(1, w - #clock + 1), 2, clock, T.text) end

  local gap = 2
  local bw = math.max(9, math.floor((w - 6 - (columns - 1) * gap) / columns))
  local first = (kernelPage - 1) * perPage + 1
  local appBottom = math.max(4, h - 4)

  for offset = 0, perPage - 1 do
    local app = apps[first + offset]
    if not app then break end

    local col = offset % columns
    local row = math.floor(offset / columns)
    local x = 3 + col * (bw + gap)
    local y = 4 + row * 3
    if y + 1 <= appBottom then
      U.button(x, y, bw, 2, app.name, app.external and T.panel or T.card, T.text)
    end
  end

  U.fill(1, h - 2, w, 3, T.panel, T.text)

  if w >= 42 then
    U.button(2, h - 2, 10, 1, "HOME", T.face, T.text)
    U.button(14, h - 2, 10, 1, "< PREV", kernelPage > 1 and T.face or T.panel, T.text)
    U.button(26, h - 2, 10, 1, "NEXT >", kernelPage < pages and T.face or T.panel, T.text)
    U.button(w - 11, h - 2, 10, 1, "POWER", T.face, T.text)
  elseif w >= 25 then
    U.button(2, h - 2, 7, 1, "HOME", T.face, T.text)
    U.button(11, h - 2, 5, 1, "<", kernelPage > 1 and T.face or T.panel, T.text)
    U.button(17, h - 2, 6, 1, "NEXT", kernelPage < pages and T.face or T.panel, T.text)
    U.button(w - 5, h - 2, 4, 1, "OFF", T.face, T.text)
  else
    U.button(2, h - 2, math.max(5, w - 8), 1, "HOME", T.face, T.text)
    U.button(math.max(1, w - 5), h - 2, 4, 1, "OFF", T.face, T.text)
  end

  U.center(h - 1, "Page " .. tostring(kernelPage) .. "/" .. tostring(pages), T.text)

  local net = N.status()
  local networkState = net.opened > 0 and "ONLINE"
    or (#net.modems > 0 and "READY" or "NO MODEM")
  local badge
  if _G.PACIFICOS_SAFE_MODE then
    badge = "SAFE MODE"
  else
    local ok, apps = pcall(ThirdParty.list)
    local count = ok and type(apps) == "table" and #apps or 0
    badge = count > 0 and ("CCI 2026 | " .. count .. " apps") or "CCI 2026"
  end
  local devices = D.list()
  U.label(2, h, badge .. " | Network " .. networkState .. " | Devices " .. tostring(#devices),
    T.text, math.max(1, w - 2))
end

local function hitApp(x, y)
  local apps = getApps()
  local perPage, columns = layout()
  local w, h = term.getSize()
  if y < 4 or y >= h - 4 then return nil end

  local gap = 2
  local bw = math.max(9, math.floor((w - 6 - (columns - 1) * gap) / columns))
  local first = (kernelPage - 1) * perPage + 1

  for offset = 0, perPage - 1 do
    local app = apps[first + offset]
    if app then
      local col = offset % columns
      local row = math.floor(offset / columns)
      local bx = 3 + col * (bw + gap)
      local by = 4 + row * 3
      if U.hit(bx, by, bw, 2, x, y) then return app end
    end
  end
  return nil
end

local function handleNavigation(x, y)
  local w, h = term.getSize()
  if y ~= h - 2 then return false end

  if w >= 42 then
    if x >= 2 and x < 12 then
      kernelPage = 1
      return true
    elseif x >= 14 and x < 24 and kernelPage > 1 then
      kernelPage = kernelPage - 1
      return true
    elseif x >= 26 and x < 36 and kernelPage < pageCount(getApps()) then
      kernelPage = kernelPage + 1
      return true
    elseif x >= w - 11 then
      os.shutdown()
      return true
    end
  elseif w >= 25 then
    if x >= 2 and x < 9 then
      kernelPage = 1
      return true
    elseif x >= 11 and x < 16 and kernelPage > 1 then
      kernelPage = kernelPage - 1
      return true
    elseif x >= 17 and x < 23 and kernelPage < pageCount(getApps()) then
      kernelPage = kernelPage + 1
      return true
    elseif x >= w - 5 then
      os.shutdown()
      return true
    end
  else
    if x >= 2 and x < math.max(2, w - 5) then
      kernelPage = 1
      return true
    elseif x >= w - 5 then
      os.shutdown()
      return true
    end
  end
  return false
end

while true do
  drawDesktop()
  local e, a, b, c = os.pullEvent()

  if e == "mouse_click" or e == "monitor_touch" then
    if not handleNavigation(b, c) then
      local app = hitApp(b, c)
      if app then runApp(app) end
    end
  elseif e == "key" then
    local pages = pageCount(getApps())
    if a == keys.left or a == keys.pageUp then
      kernelPage = math.max(1, kernelPage - 1)
    elseif a == keys.right or a == keys.pageDown then
      kernelPage = math.min(pages, kernelPage + 1)
    elseif a == keys.f12 then
      os.shutdown()
    elseif a == keys.home then
      kernelPage = 1
    end
  elseif e == "term_resize" or e == "monitor_resize" then
    kernelPage = 1
  elseif e == "terminate" then
    return
  end
end
