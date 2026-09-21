local U = dofile("/pacificos/ui/widgets.lua")
local T = dofile("/pacificos/ui/theme.lua")

local M = {
  windows = {},
  active = nil,
  next = 0
}

local function normalizeWindow(v)
  local w, h = term.getSize()
  v.x = math.max(1, math.min(v.x or 2, math.max(1, w - 8)))
  v.y = math.max(3, math.min(v.y or 3, math.max(3, h - 6)))
  v.w = math.max(14, math.min(v.w or w - 8, w - v.x + 1))
  v.h = math.max(5, math.min(v.h or h - 6, h - v.y + 1))
  return v
end

local function drawFrame(win)
  local title = " " .. tostring(win.title or "Window") .. " "
  U.fill(win.x, win.y, win.w, win.h, T.face, T.text)

  -- Thin classic shadow.
  if win.x + win.w <= select(1, term.getSize()) then
    U.fill(win.x + win.w, win.y + 1, 1, win.h, T.shadow, T.text)
  end
  if win.y + win.h <= select(2, term.getSize()) then
    U.fill(win.x + 1, win.y + win.h, math.max(1, win.w), 1, T.shadow, T.text)
  end

  -- Blue caption bar.
  U.fill(win.x, win.y, win.w, 1, T.dark, T.textOnBlue)
  term.setTextColor(T.textOnBlue)
  term.setCursorPos(win.x + 1, win.y)
  write(title:sub(1, math.max(1, win.w - 7)))

  if win.w >= 6 then
    term.setBackgroundColor(T.dark)
    term.setTextColor(T.textOnBlue)
    term.setCursorPos(win.x + win.w - 4, win.y)
    write("[X]")
  end
end

function M.add(title, draw, click)
  M.next = M.next + 1
  local id = M.next
  local w, h = term.getSize()

  local win = normalizeWindow({
    id = id,
    title = tostring(title or "Window"),
    draw = draw,
    click = click,
    x = 2 + ((id - 1) % 3) * 4,
    y = 3 + ((id - 1) % 2) * 2,
    w = math.max(20, w - 8),
    h = math.max(8, h - 6),
    min = false
  })

  M.windows[#M.windows + 1] = win
  M.active = id
  return id
end

function M.close(id)
  for i, win in ipairs(M.windows) do
    if win.id == id then
      table.remove(M.windows, i)
      break
    end
  end
  M.active = M.windows[#M.windows] and M.windows[#M.windows].id or nil
end

function M.minimize(id)
  for _, win in ipairs(M.windows) do
    if win.id == id then
      win.min = true
      return
    end
  end
end

function M.restore(id)
  for _, win in ipairs(M.windows) do
    if win.id == id then
      win.min = false
      M.active = id
      return
    end
  end
end

function M.draw()
  for _, win in ipairs(M.windows) do
    if not win.min then
      drawFrame(win)
      if type(win.draw) == "function" then
        pcall(win.draw, win)
      end
    end
  end
end

function M.event(event, a, b, c)
  if event ~= "mouse_click" and event ~= "monitor_touch" then
    return false
  end

  for i = #M.windows, 1, -1 do
    local win = M.windows[i]

    if not win.min
      and b >= win.x and b < win.x + win.w
      and c >= win.y and c < win.y + win.h then

      M.active = win.id

      -- Caption close button.
      if c == win.y and b >= win.x + win.w - 5 then
        M.close(win.id)
        return true
      end

      if type(win.click) == "function" then
        pcall(win.click, win, a, b, c)
      end
      return true
    end
  end

  return false
end

return M
