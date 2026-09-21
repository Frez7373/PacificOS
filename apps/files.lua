local U = dofile("/pacificos/ui/widgets.lua")
local Security = dofile("/pacificos/system/security.lua")
local FS = dofile("/pacificos/system/filesystem.lua")
local M = {}

local function parent(path)
  path = fs.combine("/", path)
  if path == "/" then return "/" end
  local dir = fs.getDir(path)
  return dir == "" and "/" or fs.combine("/", dir)
end

local function prompt(label)
  local _, h = term.getSize()
  U.label(2, math.max(3, h - 3), label, U._accent)
  term.setCursorPos(2, math.max(4, h - 2))
  write("> ")
  return read()
end

local function editFile(path)
  local ok, mod = pcall(dofile, "/pacificos/apps/editor.lua")
  if not ok or type(mod) ~= "table" or type(mod.run) ~= "function" then
    return false, "Editor could not be loaded."
  end
  local okRun, err = pcall(mod.run, path)
  return okRun, okRun and nil or err
end

local function previewFile(path)
  local data, err = FS.read(path)
  if not data then return false, err end

  local lines = {}
  for line in (data .. "\n"):gmatch("(.-)\n") do lines[#lines + 1] = line end
  local scroll = 1

  while true do
    local w, h = term.getSize()
    local maxLines = math.max(1, h - 7)
    scroll = math.max(1, math.min(scroll, math.max(1, #lines - maxLines + 1)))

    U.clear()
    U.header("Preview", true)
    U.label(2, 3, path, U._accent)
    for i = 1, maxLines do
      local index = scroll + i - 1
      if index > #lines then break end
      U.label(2, 4 + i, lines[index], U._text, math.max(1, w - 3))
    end

    U.backButton(h - 2)
    U.status("Up/Down scroll | Enter/Q/Esc = close")
    local e, a, b, c = os.pullEvent()
    if U.closeEvent(e, a) or (e == "key" and a == keys.enter) then return true end
    if (e == "mouse_click" or e == "monitor_touch") and U.backHit(b, c, h - 2, 18) then
      return true
    end
    if e == "key" and a == keys.up then
      scroll = math.max(1, scroll - 1)
    elseif e == "key" and a == keys.down then
      scroll = math.min(math.max(1, #lines - maxLines + 1), scroll + 1)
    end
  end
end

local function makeName(name)
  name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  -- CC:Tweaked paths are slash-separated. Reject path separators here:
  -- a file/folder name must stay inside the current directory.
  name = name:gsub("[<>:\"|%?%*]", "_")
  name = name:gsub("[/\\]", "_")
  if name == "" or name == "." or name == ".." then return nil end
  return name
end

local function destination(value, item)
  value = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if value == "" then return nil end
  local target = fs.combine("/", value)
  if fs.isDir(target) then target = fs.combine(target, item) end
  return target
end

local function canCreate(target)
  return not Security.isProtected(target)
end

local function doAction(action, path, list, selected)
  local item = list[selected]
  local full = item and fs.combine(path, item) or nil

  if action == "New file" then
    local name = makeName(prompt("New file name:"))
    if not name then return "Invalid name." end
    local target = fs.combine(path, name)
    if not canCreate(target) then return "Protected system path." end
    if fs.exists(target) then return "File already exists." end

    local handle = fs.open(target, "w")
    if not handle then return "Cannot create file." end
    handle.close()
    return "File created."

  elseif action == "New folder" then
    local name = makeName(prompt("New folder name:"))
    if not name then return "Invalid name." end
    local target = fs.combine(path, name)
    if not canCreate(target) then return "Protected system path." end
    if fs.exists(target) then return "Folder already exists." end

    local ok, err = pcall(fs.makeDir, target)
    return ok and "Folder created." or tostring(err)

  elseif action == "Rename" and full then
    if Security.isProtected(full) then return "Protected system path." end
    local name = makeName(prompt("Rename to:"))
    if not name then return "Invalid name." end

    local target = fs.combine(path, name)
    if Security.isProtected(target) then return "Protected system path." end
    if fs.exists(target) then return "Target already exists." end

    local ok, err = pcall(fs.move, full, target)
    return ok and "Renamed." or tostring(err)

  elseif action == "Delete" and full then
    if Security.isProtected(full) then return "Protected system path." end
    if prompt("Type YES to delete " .. item .. ":") ~= "YES" then return "Delete cancelled." end

    local ok, err = FS.safeDelete(full)
    return ok and "Deleted." or tostring(err)

  elseif action == "Copy" and full then
    if Security.isProtected(full) then return "Protected system path." end
    local target = destination(prompt("Copy to path:"), item)
    if not target then return "Copy cancelled." end
    if Security.isProtected(target) then return "Protected destination." end
    if fs.exists(target) then return "Target already exists." end

    local ok, err = pcall(fs.copy, full, target)
    return ok and "Copied." or tostring(err)

  elseif action == "Move" and full then
    if Security.isProtected(full) then return "Protected system path." end
    local target = destination(prompt("Move to path:"), item)
    if not target then return "Move cancelled." end
    if Security.isProtected(target) then return "Protected destination." end
    if fs.exists(target) then return "Target already exists." end

    local ok, err = pcall(fs.move, full, target)
    return ok and "Moved." or tostring(err)

  elseif action == "Up" then
    return "up"

  elseif action == "Back" then
    return "back"

  elseif action == "Edit" and full then
    if fs.isDir(full) then return "Select a file first." end
    local ok, err = editFile(full)
    return ok and "Editor closed." or tostring(err)

  elseif action == "Open" and full then
    if fs.isDir(full) then return "open-dir" end

    local ext = full:match("%.([%w]+)$")
    local editable = {lua=true, txt=true, cfg=true, log=true, md=true}
    if ext and editable[ext:lower()] then
      local ok, err = editFile(full)
      return ok and "Editor closed." or tostring(err)
    end

    local ok, err = previewFile(full)
    return ok and "Preview closed." or tostring(err)
  end

  return "Select a file or folder first."
end

local function toolbar(w, h)
  local labels
  if w >= 34 then
    labels = {"Open","Edit","New","Folder","Rename","Delete","Copy","Move","Up","Back"}
  elseif w >= 25 then
    labels = {"Open","Edit","New","Delete","Rename","Copy","Move","Up"}
  else
    labels = {"Open","New","Edit","Delete","Up"}
  end

  local cols
  if w >= 34 then cols = 5
  elseif w >= 25 then cols = 4
  else cols = 3 end

  local rows = math.ceil(#labels / cols)
  local gap = 1
  local bw = math.max(5, math.floor((w - 2 - (cols - 1) * gap) / cols))
  local startY = math.max(5, h - rows * 2 - 3)
  local result = {}

  for i, label in ipairs(labels) do
    local col = (i - 1) % cols
    local row = math.floor((i - 1) / cols)
    local x = 2 + col * (bw + gap)
    local y = startY + row * 2
    if x <= w and y < h - 1 then
      local buttonW = math.min(bw, w - x + 1)
      local bg = label == "Delete" and colors.red or (label == "Back" and U._accent2 or U._accent)
      U.button(x, y, buttonW, 1, label, bg)
      result[#result + 1] = {x=x, y=y, w=buttonW, h=1, action=label}
    end
  end

  return result, startY
end

function M.run()
  local path = "/"
  local selected = 1
  local scroll = 1
  local notice = "Select a file or folder."

  while true do
    local w, h = term.getSize()
    local list = fs.list(path)
    table.sort(list, function(a,b) return a:lower() < b:lower() end)

    local buttons, toolbarY = toolbar(w, h)
    local rows = math.max(1, toolbarY - 4)
    local maxScroll = math.max(1, #list - rows + 1)

    if selected > #list then selected = math.max(1, #list) end
    if #list == 0 then selected = 1 end
    if selected < scroll then scroll = selected end
    if selected > scroll + rows - 1 then scroll = selected - rows + 1 end
    scroll = math.max(1, math.min(scroll, maxScroll))

    U.clear()
    U.header("Files", true)
    U.label(2, 3, "Path: " .. path, U._accent)
    if w >= 24 then
      local countText = tostring(#list) .. " items"
      U.label(math.max(1, w - #countText + 1), 3, countText, U._muted)
    end

    if #list == 0 then
      U.label(3, 6, "This directory is empty.", U._muted)
    else
      for i = scroll, math.min(#list, scroll + rows - 1) do
        local y = 4 + (i - scroll)
        local name = list[i]
        local full = fs.combine(path, name)
        local marker = fs.isDir(full) and "[DIR] " or "      "
        local bg = i == selected and U._accent or U._accent2
        local fg = i == selected and colors.white or U._text
        U.button(2, y, math.max(12, w - 3), 1, marker .. name, bg, fg)
      end
    end

    U.label(2, math.max(4, toolbarY - 1), notice, U._muted, math.max(1, w - 3))
    U.status("Up/Down select | Enter open | N new | F folder | R rename | Del delete | C copy | M move | Backspace up")

    local e, a, b, c = os.pullEvent()

    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.up then
        selected = math.max(1, selected - 1)
      elseif a == keys.down then
        selected = math.min(math.max(1, #list), selected + 1)
      elseif a == keys.backspace then
        path = parent(path)
        selected, scroll = 1, 1
      elseif a == keys.enter and list[selected] then
        local action = doAction("Open", path, list, selected)
        if action == "open-dir" then
          path = fs.combine(path, list[selected])
          selected, scroll = 1, 1
        else
          notice = action
        end
      elseif a == keys.n then
        notice = doAction("New file", path, list, selected)
      elseif a == keys.f then
        notice = doAction("New folder", path, list, selected)
      elseif a == keys.r then
        notice = doAction("Rename", path, list, selected)
      elseif a == keys.delete and list[selected] then
        notice = doAction("Delete", path, list, selected)
      elseif a == keys.c and list[selected] then
        notice = doAction("Copy", path, list, selected)
      elseif a == keys.m and list[selected] then
        notice = doAction("Move", path, list, selected)
      end

    elseif e == "mouse_click" or e == "monitor_touch" then
      local clickedList = false
      local row = c - 3
      if row >= 1 and row <= math.min(#list, rows) then
        local index = scroll + row - 1
        if index <= #list then
          selected = index
          clickedList = true
          local action = doAction("Open", path, list, selected)
          if action == "open-dir" then
            path = fs.combine(path, list[selected])
            selected, scroll = 1, 1
          else
            notice = action
          end
        end
      end

      if not clickedList then
        if U.backHit(b, c, h - 2, 18) then
          return
        end
        for _, r in ipairs(buttons) do
          if U.hit(r.x, r.y, r.w, r.h, b, c) then
            local action = doAction(r.action, path, list, selected)
            if action == "up" then
              path = parent(path)
              selected, scroll = 1, 1
            elseif action == "back" then
              return
            elseif action == "open-dir" and list[selected] then
              path = fs.combine(path, list[selected])
              selected, scroll = 1, 1
            else
              notice = action
            end
            break
          end
        end
      end
    end
  end
end

return M
