local U = dofile("/pacificos/ui/widgets.lua")
local Security = dofile("/pacificos/system/security.lua")
local M = {}

local function loadLines(path)
  local lines = {}
  if not fs.exists(path) or fs.isDir(path) then return lines end
  local handle = fs.open(path, "r")
  if not handle then return lines end
  while true do
    local line = handle.readLine()
    if line == nil then break end
    lines[#lines + 1] = line
  end
  handle.close()
  return lines
end

local function saveLines(path, lines)
  if Security.isProtected(path) then
    return false, "Protected system file."
  end
  local dir = fs.getDir(path)
  if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
  local handle, err = fs.open(path, "w")
  if not handle then return false, err or "Cannot open file." end
  handle.write(table.concat(lines, "
"))
  if #lines > 0 then handle.write("
") end
  handle.close()
  return true
end

local function prompt(title, default)
  local w, h = term.getSize()
  U.fill(2, h - 3, math.max(1, w - 3), 1, U._accent)
  U.label(2, h - 3, title, U._text)
  term.setCursorPos(2, h - 2)
  write("> ")
  local value = read()
  if value == "" and default ~= nil then return default end
  return value
end

function M.run(targetPath)
  local path = targetPath

  if not path then
    U.clear()
    U.header("Text Editor", true)
    U.label(2, 4, "File path:", U._muted)
    term.setCursorPos(2, 6)
    write("> ")
    path = read()
    if not path or path == "" or path == "q" then return end
  end

  path = fs.combine("/", path)
  local lines = loadLines(path)
  local selected = 1
  local notice = "Loaded " .. tostring(#lines) .. " lines."

  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("Editor", true)
    U.label(2, 3, path, U._accent)

    local visible = math.max(1, h - 9)
    if selected > math.max(1, #lines) then selected = math.max(1, #lines) end

    if #lines == 0 then
      U.label(3, 6, "File is empty. Use Add to insert the first line.", U._muted)
    else
      local first = math.max(1, selected - math.floor(visible / 2))
      local last = math.min(#lines, first + visible - 1)
      first = math.max(1, last - visible + 1)

      local y = 5
      for i = first, last do
        local prefix = (i == selected) and ">" or " "
        local text = string.format("%s %03d  %s", prefix, i, lines[i] or "")
        U.button(2, y, math.max(12, w - 3), 1, text, i == selected and U._accent or U._accent2,
          i == selected and colors.white or U._text)
        y = y + 1
      end
    end

    local toolbarY = h - 3
    if w >= 45 then
      U.button(2, toolbarY, 8, 1, "ADD", U._accent)
      U.button(11, toolbarY, 8, 1, "EDIT", U._accent2)
      U.button(20, toolbarY, 8, 1, "DELETE", colors.red)
      U.button(29, toolbarY, 8, 1, "SAVE", U._accent)
      U.button(38, toolbarY, 8, 1, "BACK", U._accent2)
    else
      U.button(2, toolbarY, 7, 1, "ADD", U._accent)
      U.button(10, toolbarY, 7, 1, "EDIT", U._accent2)
      U.button(18, toolbarY, 7, 1, "DEL", colors.red)
      U.button(26, toolbarY, 7, 1, "SAVE", U._accent)
      if w >= 36 then U.button(34, toolbarY, math.min(7, w - 33), 1, "BACK", U._accent2) end
    end

    U.status((notice or "") .. " | Up/Down select | Q/Esc back")

    local function action(name)
      if name == "ADD" then
        local value = prompt("New line text:")
        if value ~= nil then
          local index = (#lines == 0) and 1 or selected + 1
          table.insert(lines, index, value)
          selected = index
          notice = "Line added."
        end
      elseif name == "EDIT" then
        if #lines == 0 then
          notice = "Nothing to edit."
        else
          local value = prompt("Replace line " .. tostring(selected) .. ":")
          if value ~= nil then
            lines[selected] = value
            notice = "Line " .. tostring(selected) .. " changed."
          end
        end
      elseif name == "DELETE" then
        if #lines == 0 then
          notice = "Nothing to delete."
        else
          if prompt("Type YES to delete line " .. tostring(selected) .. ":") == "YES" then
            table.remove(lines, selected)
            selected = math.min(selected, math.max(1, #lines))
            notice = "Line deleted."
          else
            notice = "Delete cancelled."
          end
        end
      elseif name == "SAVE" then
        local ok, err = saveLines(path, lines)
        notice = ok and ("Saved " .. tostring(#lines) .. " lines.") or tostring(err)
      elseif name == "BACK" then
        return "back"
      end
    end

    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.up then selected = math.max(1, selected - 1)
      elseif a == keys.down then selected = math.min(math.max(1, #lines), selected + 1)
      elseif a == keys.enter then
        local r = action("EDIT")
        if r == "back" then return end
      elseif a == keys.n then
        local r = action("ADD")
        if r == "back" then return end
      elseif a == keys.delete then
        local r = action("DELETE")
        if r == "back" then return end
      elseif a == keys.s then
        local r = action("SAVE")
        if r == "back" then return end
      end
    elseif e == "mouse_click" or e == "monitor_touch" then
      local y = c
      local visible = math.max(1, h - 9)
      if #lines > 0 and y >= 5 and y < 5 + visible then
        local first = math.max(1, selected - math.floor(visible / 2))
        local last = math.min(#lines, first + visible - 1)
        first = math.max(1, last - visible + 1)
        local index = first + (y - 5)
        if index <= #lines then selected = index end
      elseif y == toolbarY then
        local ranges
        if w >= 45 then
          ranges = {{2,10,"ADD"},{11,19,"EDIT"},{20,28,"DELETE"},{29,37,"SAVE"},{38,46,"BACK"}}
        else
          ranges = {{2,9,"ADD"},{10,17,"EDIT"},{18,25,"DELETE"},{26,33,"SAVE"},{34,w+1,"BACK"}}
        end
        for _, r in ipairs(ranges) do
          if b >= r[1] and b < r[2] and r[1] <= w then
            if action(r[3]) == "back" then return end
            break
          end
        end
      end
    end
  end
end

return M
