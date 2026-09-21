local U = dofile("/pacificos/ui/widgets.lua")
local Apps = dofile("/pacificos/system/apps.lua")
local M = {}

local ROOT = "/pacificos"
local TEMP = ROOT .. "/.installer_tmp.lua"

local function clearTemp()
  if fs.exists(TEMP) then pcall(fs.delete, TEMP) end
end

local function trim(value)
  return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function safeFileName(name)
  local result = trim(name):gsub("[^%w%._%-]", "_"):gsub("_+", "_")
  if result == "" then result = "app" end
  if not result:lower():match("%.lua$") then result = result .. ".lua" end
  return result:sub(1, 48)
end

local function httpGet(url, path)
  if not http then return false, "HTTP API is disabled." end
  local response, err = http.get(url)
  if not response then return false, tostring(err or "HTTP request failed.") end

  local code = 200
  if type(response.getResponseCode) == "function" then code = response.getResponseCode() or 200 end
  local body = response.readAll() or ""
  if type(response.close) == "function" then response.close() end

  if code < 200 or code >= 400 then return false, "HTTP " .. tostring(code) end
  if body == "" then return false, "Downloaded file is empty." end

  local handle = fs.open(path, "w")
  if not handle then return false, "Cannot write temporary file." end
  handle.write(body)
  handle.close()
  return true
end

local function pastebinUrl(value)
  value = trim(value)
  if value:match("^https?://") then
    if value:find("pastebin.com/raw/", 1, true) then return value end
    local id = value:match("pastebin.com/([%w]+)")
    if id then return "https://pastebin.com/raw/" .. id end
  end
  local id = value:gsub("[^%w]", "")
  if id == "" then return nil end
  return "https://pastebin.com/raw/" .. id
end

local function download(source)
  clearTemp()
  if source.kind == "wget" then
    if not source.url:match("^https?://") then return false, "URL must start with http:// or https://." end
    return httpGet(source.url, TEMP)
  end

  local url = pastebinUrl(source.code)
  if not url then return false, "Invalid Pastebin code or URL." end
  return httpGet(url, TEMP)
end

local function validate()
  local fn, err = loadfile(TEMP)
  if not fn then return false, "Lua syntax error: " .. tostring(err) end
  return true
end

local function prompt(label, y)
  local w, h = term.getSize()
  y = y or (h - 2)
  U.label(2, y - 1, label, U._accent, math.max(1, w - 3))
  term.setCursorPos(2, y)
  write("> ")
  return read()
end

local function install(sourceLabel)
  local valid, err = validate()
  if not valid then clearTemp(); return false, err end

  U.clear()
  U.header("Install Application", true)
  U.label(2, 4, "Source: " .. sourceLabel, U._muted)
  U.label(2, 6, "Only install Lua code you trust.", U._warn)

  local name = trim(prompt("Application name:", 8))
  if name == "" then clearTemp(); return false, "Installation cancelled." end

  local existing = Apps.find(name)
  if existing then
    local confirm = trim(prompt("Replace existing app? Type YES:", 10))
    if confirm ~= "YES" then clearTemp(); return false, "Installation cancelled." end
    Apps.remove(name)
  end

  local file = safeFileName(name)
  local relative = "userapps/" .. file
  local target = ROOT .. "/" .. relative
  local base = file:gsub("%.lua$", "")
  local n = 2
  while fs.exists(target) do
    file = base .. "_" .. tostring(n) .. ".lua"
    relative = "userapps/" .. file
    target = ROOT .. "/" .. relative
    n = n + 1
  end

  if not fs.exists(ROOT .. "/userapps") then fs.makeDir(ROOT .. "/userapps") end
  local ok, moveErr = pcall(fs.move, TEMP, target)
  if not ok then
    clearTemp()
    return false, "Cannot install application: " .. tostring(moveErr)
  end

  local regOk, regErr = Apps.register(name, relative, sourceLabel)
  if not regOk then
    if fs.exists(target) then fs.delete(target) end
    return false, tostring(regErr)
  end

  return true, "Installed and added to the desktop."
end

local function installWget()
  U.clear()
  U.header("Install from WGET", true)
  local url = trim(prompt("Direct .lua URL:", 7))
  if url == "" then return end

  local ok, err = download({kind = "wget", url = url})
  if ok then ok, err = install(url) end

  U.label(2, 12, ok and tostring(err) or tostring(err), ok and U._accent or U._bad)
  U.status("Press any key to return")
  os.pullEvent()
end

local function installPastebin()
  U.clear()
  U.header("Install from Pastebin", true)
  local code = trim(prompt("Pastebin code or raw URL:", 7))
  if code == "" then return end

  local ok, err = download({kind = "pastebin", code = code})
  if ok then ok, err = install(code) end

  U.label(2, 12, tostring(err), ok and U._accent or U._bad)
  U.status("Press any key to return")
  os.pullEvent()
end

local function launch(app)
  if not app then return end
  U.clear()
  local ok, result = pcall(dofile, ROOT .. "/" .. app.path)
  if ok and type(result) == "table" and type(result.run) == "function" then
    ok, result = pcall(result.run)
  elseif ok and type(result) == "function" then
    ok, result = pcall(result)
  end
  if not ok then
    U.clear()
    U.header("Application Error")
    U.label(2, 5, tostring(result), U._bad)
    U.status("Press any key")
    os.pullEvent()
  end
end

function M.run()
  local selected = 1
  while true do
    local w, h = term.getSize()
    local list = Apps.list()
    if selected > #list then selected = math.max(1, #list) end

    U.clear()
    U.header("App Installer", true)
    U.label(2, 4, "Install trusted Lua apps using WGET or Pastebin.", U._muted)

    local rows = math.max(1, h - 12)
    if #list == 0 then
      U.label(3, 7, "No third-party apps installed.", U._muted)
    else
      for i = 1, math.min(#list, rows) do
        local app = list[i]
        local mark = app.desktop and "DESKTOP" or "HIDDEN"
        U.button(2, 5 + i - 1, math.max(12, w - 3), 1, mark .. " | " .. app.name,
          i == selected and U._accent or U._accent2,
          i == selected and colors.white or U._text)
      end
    end

    local by = h - 6
    local bw = math.max(8, math.floor((w - 3) / 2))
    U.button(2, by, bw, 1, "WGET", U._accent)
    U.button(3 + bw, by, bw, 1, "PASTEBIN", U._accent)
    U.button(2, by + 2, bw, 1, "LAUNCH", U._accent2)
    U.button(3 + bw, by + 2, bw, 1, "DESKTOP", U._accent2)
    U.status("Up/Down = select | Enter = launch | Del = uninstall | Q/Esc = back")

    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if U.closeEvent(e, a) then clearTemp(); return end
      if a == keys.up then selected = math.max(1, selected - 1)
      elseif a == keys.down then selected = math.min(math.max(1, #list), selected + 1)
      elseif a == keys.enter then launch(list[selected])
      elseif a == keys.d and list[selected] then Apps.setDesktop(list[selected].name, not list[selected].desktop)
      elseif a == keys.delete and list[selected] then
        if prompt("Type YES to uninstall " .. list[selected].name .. ":", h - 4) == "YES" then Apps.remove(list[selected].name) end
      elseif a == keys.one then installWget()
      elseif a == keys.two then installPastebin()
      end
    elseif e == "mouse_click" or e == "monitor_touch" then
      local row = c - 4
      if row >= 1 and row <= math.min(#list, rows) then
        selected = row
        if U.hit(2, 4 + row, math.max(12, w - 3), 1, b, c) then launch(list[selected]) end
      elseif U.hit(2, by, bw, 1, b, c) then installWget()
      elseif U.hit(3 + bw, by, bw, 1, b, c) then installPastebin()
      elseif U.hit(2, by + 2, bw, 1, b, c) then launch(list[selected])
      elseif U.hit(3 + bw, by + 2, bw, 1, b, c) and list[selected] then
        Apps.setDesktop(list[selected].name, not list[selected].desktop)
      end
    end
  end
end

return M
