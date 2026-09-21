local U = dofile("/pacificos/ui/widgets.lua")
local Security = dofile("/pacificos/system/security.lua")
local FS = dofile("/pacificos/system/filesystem.lua")
local M = {}

local function parent(path)
  path = fs.combine("/", path)
  if path == "/" then return "/" end
  local dir = fs.getDir(path)
  if dir == "" then return "/" end
  return fs.combine("/", dir)
end

local function prompt(label)
  local _, h = term.getSize()
  U.label(2, h - 3, label, U._accent)
  term.setCursorPos(2, h - 2)
  write("> ")
  return read()
end

local function readable(path)
  return not fs.isDir(path)
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

  local scroll = 1
  while true do
    local w, h = term.getSize()
    local lines = {}
    for line in (data .. "
"):gmatch("(.-)
") do
      lines[#lines + 1] = line
    end
    local maxLines = math.max(1, h - 7)
    if scroll > math.max(1, #lines - maxLines + 1) then
      scroll = math.max(1, #lines - maxLines + 1)
    end

    U.clear()
    U.header("Preview", true)
    U.label(2, 3, path, U._accent)

    for i = 1, maxLines do
      local index = scroll + i - 1
      if index > #lines then break end
      U.label(2, 4 + i, lines[index], U._text)
    end

    U.status("Up/Down scroll | Q/Esc/Enter = close")
    local e, a = os.pullEvent()
    if U.closeEvent(e, a) or (e == "key" and a == keys.enter) then return true end
    if e == "key" and a == keys.up then scroll = math.max(1, scroll - 1)
    elseif e == "key" and a == keys.down then scroll = math.min(math.max(1, #lines - maxLines + 1), scroll + 1)
    end
  end
end

local function makeName(name)
  name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  name = name:gsub("[<>:"|%?%*]", "_")
  if name == "" or name == "." or name == ".." then return nil end
  return name
end

local function doAction(action, path, list, selected)
  local item = list[selected]
  local full = item and fs.combine(path, item) or nil

  if action == "New file" then
    local name = makeName(prompt("New file name:"))
    if name then
      local target = fs.combine(path, name)
      if fs.exists(target) then return "File already exists." end
      local h = fs.open(target, "w")
      if not h then return "Cannot create file." end
      h.close()
      return "File created."
    end
  elseif action == "New folder" then
    local name = makeName(prompt("New folder name:"))
    if name then
      local target = fs.combine(path, name)
      if fs.exists(target) then return "Folder already exists." end
      local ok, err = pcall(fs.makeDir, target)
      return ok and "Folder created." or tostring(err)
    end
  elseif action == "Rename" and full then
    if Security.isProtected(full) then return "Protected system path." end
    local name = makeName(prompt("Rename to:"))
    if name then
      local target = fs.combine(path, name)
      if fs.exists(target) then return "Target already exists." end
      local ok, err = pcall(fs.move, full, target)
      return ok and "Renamed." or tostring(err)
    end
  elseif action == "Delete" and full then
    if Security.isProtected(full) then return "Protected system path." end
    local answer = prompt("Type YES to delete " .. item .. ":")
    if answer == "YES" then
      local ok, err = FS.safeDelete(full)
      return ok and "Deleted." or tostring(err)
    end
    return "Delete cancelled."
  elseif action == "Copy" and full then
    if Security.isProtected(full) then return "Protected system path." end
    local destination = prompt("Copy to path (directory or file):")
    if destination and destination ~= "" then
      destination = fs.combine("/", destination)
      if fs.isDir(destination) then destination = fs.combine(destination, item) end
      local ok, err = pcall(fs.copy, full, destination)
      return ok and "Copied." or tostring(err)
    end
  elseif action == "Move" and full then
    if Security.isProtected(full) then return "Protected system path." end
    local destination = prompt("Move to path (directory or file):")
    if destination and destination ~= "" then
      destination = fs.combine("/", destination)
      if fs.isDir(destination) then destination = fs.combine(destination, item) end
      local ok, err = pcall(fs.move, full, destination)
      return ok and "Moved." or tostring(err)
    end
  elseif action == "Up" then
    return "up"
  elseif action == "Back" then
    return "back"
  elseif action == "Edit" and full and readable(full) then
    local ok, err = editFile(full)
    return ok and "Editor closed." or tostring(err)
  elseif action == "Open" and full then
    if fs.isDir(full) then return "open-dir" end
    local ext = full:match("%.([%w]+)$")
    if ext and (ext:lower() == "lua" or ext:lower() == "txt" or ext:lower() == "cfg" or ext:lower() == "log" or ext:lower() == "md") then
      local ok, err = editFile(full)
      return ok and "Editor closed." or tostring(err)
    end
    local ok, err = previewFile(full)
    return ok and "Preview closed." or tostring(err)
  end

  return "Nothing changed."
end

local function toolbar(w, h)
  local labels = {"Open", "Edit", "New file", "New folder", "Rename", "Delete", "Copy", "Move", "Up", "Back"}
  local cols = w >= 60 and 5 or (w >= 38 and 3 or 2)
  local rows = math.ceil(#labels / cols)
  local gap = 1
  local bw = math.max(7, math.floor((w - 2 - (cols - 1) * gap) / cols))
  local startY = h - rows * 2 - 2
  local result = {}

  for i, label in ipairs(labels) do
    local col = (i - 1) % cols
    local row = math.floor((i - 1) / cols)
    local x = 2 + col * (bw + gap)
    local y = startY + row * 2
    if x <= w and y < h then
      local buttonW = math.min(bw, w - x + 1)
      local bg = label == "Delete" and colors.red or (label == "Back" and U._accent2 or U._accent)
      U.button(x, y, buttonW, 1, label, bg)
      result[#result + 1] = {x = x, y = y, w = buttonW, h = 1, action = label}
    end
  end

  return result, startY
end

function M.run()
  local path = "/"
  local selected = 1
  local notice = "Select a file or folder."

  while true do
    local w, h = term.getSize()
    local list = fs.list(path)
    table.sort(list, function(a, b) return a:lower() < b:lower() end)
    if selected > #list then selected = math.max(1, #list) end

    local buttons, toolbarY = toolbar(w, h)
    local rows = math.max(1, toolbarY - 5)

    U.clear()
    U.header("Files", true)
    U.label(2, 3, "Path: " .. path, U._accent)
    U.label(math.max(1, w - 15), 3, tostring(#list) .. " items", U._muted)

    if #list == 0 then
      U.label(3, 6, "This directory is empty.", U._muted)
    else
      for i = 1, math.min(#list, rows) do
        local name = list[i]
        local full = fs.combine(path, name)
        local marker = fs.isDir(full) and "[DIR] " or "      "
        local bg = i == selected and U._accent or U._accent2
        local fg = i == selected and colors.white or U._text
        U.button(2, 4 + i - 1, math.max(12, w - 3), 1, marker .. name, bg, fg)
      end
    end

    U.label(2, math.max(4, toolbarY - 1), notice, U._muted, math.max(1, w - 3))
    U.status("Up/Down = select | Enter/Open | N new | R rename | Del delete | Backspace up")

    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.up then selected = math.max(1, selected - 1)
      elseif a == keys.down then selected = math.min(math.max(1, #list), selected + 1)
      elseif a == keys.backspace then
        path = parent(path)
        selected = 1
      elseif a == keys.enter and list[selected] then
        local action = doAction("Open", path, list, selected)
        if action == "open-dir" then
          path = fs.combine(path, list[selected])
          selected = 1
        else
          notice = action
        end
      elseif a == keys.n then
        notice = doAction("New file", path, list, selected)
      elseif a == keys.r then
        notice = doAction("Rename", path, list, selected)
      elseif a == keys.delete and list[selected] then
        notice = doAction("Delete", path, list, selected)
      elseif a == keys.c and list[selected] then
        notice = doAction("Copy", path, list, selected)
      elseif a == keys.m and list[selected] then
        notice = doAction("Move", path, list, selected)
      elseif a == keys.f then
        notice = doAction("New folder", path, list, selected)
      end
    elseif e == "mouse_click" or e == "monitor_touch" then
      local row = c - 3
      if row >= 1 and row <= math.min(#list, rows) then
        selected = row
        if U.hit(2, 3 + row, math.max(12, w - 3), 1, b, c) then
          local action = doAction("Open", path, list, selected)
          if action == "open-dir" then
            path = fs.combine(path, list[selected])
            selected = 1
          else
            notice = action
          end
        end
      else
        for _, button in ipairs(buttons) do
          if U.hit(button.x, button.y, button.w, button.h, b, c) then
            local action = doAction(button.action, path, list, selected)
            if action == "up" then path = parent(path); selected = 1
            elseif action == "back" then return
            elseif action == "open-dir" then
              path = fs.combine(path, list[selected]); selected = 1
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
