local U = dofile("/pacificos/ui/widgets.lua")
local D = dofile("/pacificos/system/devices.lua")
local M = {}

local function showDevice(device)
  local w, h = term.getSize()
  U.clear()
  U.header("Device Details", true)

  U.label(2, 4, "Side: " .. tostring(device.side), U._accent)
  U.label(2, 5, "Type: " .. tostring(device.type), U._text)

  local methods = {}
  if peripheral.getMethods then
    local ok, list = pcall(peripheral.getMethods, device.side)
    if ok and type(list) == "table" then methods = list end
  end

  U.label(2, 7, "Available methods: " .. tostring(#methods), U._muted)
  local y = 8
  for i = 1, math.min(#methods, h - 10) do
    U.label(4, y, tostring(methods[i]), U._text)
    y = y + 1
  end

  U.backButton(h - 2)
  U.status("Press any key or Back to return")
  while true do
    local e, a, b, c = os.pullEvent()
    if U.closeEvent(e, a) then return end
    if (e == "mouse_click" or e == "monitor_touch") and U.backHit(b, c, h - 2, 18) then
      return
    end
    if e == "key" then return end
  end
end

function M.run()
  local selected = 1

  while true do
    local w, h = term.getSize()
    local list = D.list()
    if selected > #list then selected = math.max(1, #list) end

    U.clear()
    U.header("Device Manager", true)
    U.label(2, 4, "Detected peripherals: " .. tostring(#list), U._accent)

    local rows = math.max(1, h - 8)
    for i = 1, math.min(#list, rows) do
      local d = list[i]
      local text = tostring(d.side) .. "  |  " .. tostring(d.type)
      U.button(2, 5 + i - 1, math.max(12, w - 3), 1, text, i == selected and U._accent or U._accent2)
    end

    if #list == 0 then
      U.label(3, 7, "No peripherals detected.", U._muted)
    end

    U.backButton(h - 2)
    U.status("Up/Down = select | Enter = details | R = refresh | Q/Esc = back")

    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.up then selected = math.max(1, selected - 1)
      elseif a == keys.down then selected = math.min(math.max(1, #list), selected + 1)
      elseif a == keys.enter and list[selected] then showDevice(list[selected])
      elseif a == keys.r then end
    elseif e == "mouse_click" or e == "monitor_touch" then
      if U.backHit(b, c, h - 2, 18) then
        return
      end
      local row = c - 4
      if row >= 1 and row <= math.min(#list, rows) then
        selected = row
        if U.hit(2, 4 + row, math.max(12, w - 3), 1, b, c) then
          showDevice(list[row])
        end
      end
    end
  end
end

return M
