local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

local categories = {
  Length = {
    units = {
      mm = 0.001, cm = 0.01, m = 1, km = 1000,
      in = 0.0254, ft = 0.3048, yd = 0.9144, mi = 1609.344
    }
  },
  Mass = {
    units = {
      mg = 0.000001, g = 0.001, kg = 1, lb = 0.45359237, oz = 0.0283495231
    }
  },
  Time = {
    units = {
      ms = 0.001, s = 1, min = 60, h = 3600, day = 86400
    }
  }
}

local function convert(category, value, fromUnit, toUnit)
  local entry = categories[category]
  if not entry or not entry.units[fromUnit] or not entry.units[toUnit] then
    return nil, "Unknown unit."
  end
  return value * entry.units[fromUnit] / entry.units[toUnit]
end

local function promptConversion(category)
  local w, h = term.getSize()
  U.clear()
  U.header("Converter - " .. category, true)

  local unitText = {}
  for name, _ in pairs(categories[category].units) do unitText[#unitText + 1] = name end
  table.sort(unitText)

  U.label(2, 4, "Units: " .. table.concat(unitText, ", "), U._muted)
  U.label(2, 6, "Enter: amount from_unit to_unit")
  U.label(2, 7, "Example: 10 km mi")
  term.setCursorPos(2, 9)
  write("> ")
  local input = read()

  if not input or input == "" then return end
  if input == "q" or input == "exit" then return "back" end

  local amount, fromUnit, toUnit = input:match("^%s*([%-%d%.]+)%s+(%S+)%s+(%S+)%s*$")
  amount = tonumber(amount)

  if not amount then
    U.label(2, 11, "Invalid number.", U._bad)
    U.status("Press Enter to return")
    os.pullEvent("key")
    return
  end

  local result, err = convert(category, amount, fromUnit, toUnit)
  if not result then
    U.label(2, 11, err, U._bad)
  else
    U.label(2, 11, tostring(amount) .. " " .. fromUnit .. " = " .. tostring(result) .. " " .. toUnit, U._accent)
  end

  U.status("Press any key for categories")
  os.pullEvent()
end

function M.run()
  local selected = 1
  local names = {"Length", "Mass", "Time", "Back"}

  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("Unit Converter", true)
    U.label(2, 4, "Choose a category.", U._muted)

    for i, name in ipairs(names) do
      local y = 6 + (i - 1) * 2
      local bg = i == selected and U._accent or U._accent2
      U.button(2, y, math.min(28, w - 3), 1, name, bg)
    end

    U.status("Up/Down = select | Enter = open | Q/Esc = back")
    local e, a, b, c = os.pullEvent()
    if e == "key" then
      if U.closeEvent(e, a) then return end
      if a == keys.up then selected = math.max(1, selected - 1)
      elseif a == keys.down then selected = math.min(#names, selected + 1)
      elseif a == keys.enter then
        if names[selected] == "Back" then return end
        local result = promptConversion(names[selected])
        if result == "back" then return end
      end
    elseif e == "mouse_click" or e == "monitor_touch" then
      for i, name in ipairs(names) do
        local y = 6 + (i - 1) * 2
        if U.hit(2, y, math.min(28, w - 3), 1, b, c) then
          if name == "Back" then return end
          local result = promptConversion(name)
          if result == "back" then return end
          break
        end
      end
    end
  end
end

return M
