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

local function getApps()
  local result = {}
  for _, app in ipairs(builtins) do
    result[#result + 1] = {
      name = app[1],
      path = app[2],
      builtin = true
    }
  end

  if not _G.PACIFICOS_SAFE_MODE then
    for _, app in ipairs(ThirdParty.listDesktop()) do
      result[#result + 1] = {
        name = app.name,
        path = app.path,
        builtin = false,
        external = true
      }
    end
  end

  return result
end

local function layout()
  local w, h = term.getSize()
  local columns = w >= 76 and 4 or (w >= 50 and 3 or (w >= 31 and 2 or 1))
  local rows = math.max(1, math.floor((h - 7) / 3))
  return columns * rows, columns, rows
end

local function pageCount(apps)
  local perPage = layout()
  return math.max(1, math.ceil(#apps / perPage))
end

local function showAppError(app, err)
  local w, h = term.getSize()

  U.clear(T.bg)
  U.header("Application Error", true)
  U.label(2, 4, "The application stopped safely.", T.bad)
  U.label(2, 6, "App: " .. tostring(app.name), T.text)
  U.label(2, 7, "Path: " .. tostring(app.path), T.muted)
  U.label(2, 9, tostring(err), T.bad, math.max(1, w - 3))
  U.backButton(math.min(12, h - 2))
  U.status("Enter / Back = return")

  while true do
    local e, a, b, c = os.pullEvent()

    if e == "key" and (
      a == keys.enter or
      a == keys.q or
      a == keys.escape or
      a == keys.backspace
    ) then
      return
    end

    if (e == "mouse_click" or e == "monitor_touch")
      and U.backHit(b, c, math.min(12, h - 2), 18) then
      return
    end
  end
end

local function runApp(app)
  U.clear(T.bg)
  U.header(app.name, true)

  local ok, result = pcall(dofile, ROOT .. "/" .. app.path)

  if ok and type(result) == "table" and type(result.run) == "function" then
    ok, result = pcall(result.run)
  elseif ok and type(result) == "function" then
    ok, result = pcall(result)
  end

  if not ok then
    showAppError(app, result)
  end
end

local function drawDesktop()
  local apps = getApps()
  local w, h = term.getSize()
  local perPage, columns = layout()
  local pages = pageCount(apps)

  kernelPage = math.max(1, math.min(kernelPage or 1, pages))

  U.clear(T.bg)
  U.fill(1, 1, w, 2, T.dark, T.textOnBlue)

  U.label(2, 1, "PACIFICOS", T.textOnBlue)
  U.label(2, 2, tostring(C.get("hostname") or "pacificos"), T.text)

  local clock = textutils.formatTime(os.time(), C.get("show_seconds") == true)
  local right = clock .. "  ID " .. tostring(os.getComputerID())
  U.label(math.max(1, w - #right + 1), 1, right, T.textOnBlue)

  local badge
  if _G.PACIFICOS_SAFE_MODE then
    badge = "SAFE MODE"
  else
    local count = #ThirdParty.list()
    badge = count > 0 and ("CCI 2026 | " .. count .. " apps") or "CCI 2026"
  end
  U.label(math.max(1, w - #badge + 1), 2, badge, T.text)

  local gap = 2
  local bw = math.max(
    9,
    math.floor((w - 6 - (columns - 1) * gap) / columns)
  )
  local first = (kernelPage - 1) * perPage + 1

  for offset = 0, perPage - 1 do
    local app = apps[first + offset]
    if not app then
      break
    end

    local col = offset % columns
    local row = math.floor(offset / columns)
    local x = 3 + col * (bw + gap)
    local y = 4 + row * 3

    U.button(
      x,
      y,
      bw,
      2,
      app.name,
      app.external and T.card2 or T.card,
      app.external and T.textOnBlue or T.text
    )
  end

  local buttonY = math.max(4, h - 3)
  local pageY = math.max(3, h - 2)

  if w >= 42 then
    U.button(
      2,
      buttonY,
      10,
      1,
      "< PREV",
      kernelPage > 1 and T.card or T.panel
    )
    U.button(
      14,
      buttonY,
      12,
      1,
      "NEXT >",
      kernelPage < pages and T.card or T.panel
    )
    U.button(w - 11, buttonY, 10, 1, "POWER", T.card)
  elseif w >= 25 then
    U.button(
      2,
      buttonY,
      5,
      1,
      "<",
      kernelPage > 1 and T.card or T.panel
    )
    U.button(
      8,
      buttonY,
      7,
      1,
      "NEXT",
      kernelPage < pages and T.card or T.panel
    )
    U.button(w - 6, buttonY, 5, 1, "OFF", T.card)
  end

  U.center(pageY, "Page " .. kernelPage .. "/" .. pages, T.muted)

  local net = N.status()
  local networkState =
    net.opened > 0 and "ONLINE"
    or (#net.modems > 0 and "READY" or "NO MODEM")

  U.status(
    "Network " .. networkState ..
    " | Devices " .. tostring(#D.list()) ..
    " | Left/Right = pages"
  )
end

local function hitApp(x, y)
  local apps = getApps()
  local perPage, columns = layout()
  local w, h = term.getSize()

  if y < 4 or y >= h - 3 then
    return nil
  end

  local gap = 2
  local bw = math.max(
    9,
    math.floor((w - 6 - (columns - 1) * gap) / columns)
  )
  local first = (kernelPage - 1) * perPage + 1

  for offset = 0, perPage - 1 do
    local app = apps[first + offset]

    if app then
      local col = offset % columns
      local row = math.floor(offset / columns)
      local bx = 3 + col * (bw + gap)
      local by = 4 + row * 3

      if U.hit(bx, by, bw, 2, x, y) then
        return app
      end
    end
  end

  return nil
end

local function handleNavigation(x, y)
  local w, h = term.getSize()
  local buttonY = math.max(4, h - 3)

  if y < buttonY or y >= buttonY + 1 then
    return false
  end

  if w >= 42 then
    if x >= 2 and x < 12 then
      kernelPage = math.max(1, kernelPage - 1)
      return true
    elseif x >= 14 and x < 26 then
      kernelPage = math.min(pageCount(getApps()), kernelPage + 1)
      return true
    elseif x >= w - 11 then
      os.shutdown()
      return true
    end
  elseif w >= 25 then
    if x >= 2 and x < 7 then
      kernelPage = math.max(1, kernelPage - 1)
      return true
    elseif x >= 8 and x < 15 then
      kernelPage = math.min(pageCount(getApps()), kernelPage + 1)
      return true
    elseif x >= w - 6 then
      os.shutdown()
      return true
    end
  end

  return false
end

local kernelPage = 1

while true do
  drawDesktop()

  local e, a, b, c = os.pullEvent()

  if e == "mouse_click" or e == "monitor_touch" then
    local x, y = b, c

    if not handleNavigation(x, y) then
      local app = hitApp(x, y)
      if app then
        runApp(app)
      end
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

  elseif e == "term_resize" then
    kernelPage = 1

  elseif e == "terminate" then
    return
  end
end
