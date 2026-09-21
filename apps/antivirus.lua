local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

local function scanTree(root, includeUserApps)
  local result = {
    files = 0,
    lua = 0,
    bad = 0,
    skipped = 0,
    errors = {}
  }

  local function visit(path)
    if fs.isDir(path) then
      for _, name in ipairs(fs.list(path)) do
        if includeUserApps or not path:match("/userapps$") then
          visit(fs.combine(path, name))
        end
      end
      return
    end

    result.files = result.files + 1
    if not path:lower():match("%.lua$") then return end
    result.lua = result.lua + 1

    local fn, err = loadfile(path)
    if not fn then
      result.bad = result.bad + 1
      if #result.errors < 5 then
        result.errors[#result.errors + 1] = fs.combine("/", path) .. ": " .. tostring(err)
      end
    else
      result.skipped = result.skipped
    end
  end

  visit(root)
  return result
end

local function showResult(kind)
  U.clear()
  U.header("Antivirus Scan", true)
  U.label(2, 4, "Scan type: " .. kind, U._accent)
  U.label(2, 6, "Checking Lua syntax and readable system files...", U._muted)

  local full = kind == "Full"
  local root = "/pacificos"
  local result = scanTree(root, full)

  U.label(2, 9, "Files checked: " .. result.files)
  U.label(2, 10, "Lua files: " .. result.lua)
  U.label(2, 11, "Syntax errors: " .. result.bad, result.bad == 0 and U._accent or U._bad)

  if result.bad == 0 then
    U.label(2, 13, "No Lua syntax errors were found.", U._accent)
  else
    U.label(2, 13, "Problem files:", U._bad)
    local y = 14
    for _, line in ipairs(result.errors) do
      if y >= select(2, term.getSize()) - 2 then break end
      U.label(3, y, line, U._bad)
      y = y + 1
    end
  end

  U.status("Press any key to return. No files are deleted automatically.")
  os.pullEvent()
end

function M.run()
  local selected = 1
  local items = {"Quick Scan", "Full Scan", "Back"}

  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("Pacific Antivirus", true)
    U.label(2, 4, "Checks Lua syntax. It does not pretend to detect every possible threat.", U._muted)

    for i, item in ipairs(items) do
      local bg = i == selected and U._accent or U._accent2
      local menuY = 7 + (i - 1) * 2
      if menuY < h - 2 then
        U.button(2, menuY, math.min(30, w - 3), 1, item, bg)
      end
    end

    U.backButton(h - 2)
    U.status("Up/Down = select | Enter = run | Q/Esc = back")

    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.up then selected = math.max(1, selected - 1)
      elseif a == keys.down then selected = math.min(#items, selected + 1)
      elseif a == keys.enter then
        if selected == 1 then showResult("Quick")
        elseif selected == 2 then showResult("Full")
        else return end
      end
    elseif e == "mouse_click" or e == "monitor_touch" then
      if U.backHit(b, c, h - 2, 18) then return end
      for i = 1, #items do
        local by = 7 + (i - 1) * 2
        if by < h - 2 and U.hit(2, by, math.min(30, w - 3), 1, b, c) then
          if i == 1 then showResult("Quick")
          elseif i == 2 then showResult("Full")
          else return end
          break
        end
      end
    end
  end
end

return M
