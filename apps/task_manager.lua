local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

local function runningProgram()
  if shell and shell.getRunningProgram then
    local ok, value = pcall(shell.getRunningProgram)
    if ok then return value or "PacificOS kernel" end
  end
  return "PacificOS kernel"
end

local function taskCount()
  if multishell and multishell.getCount then
    local ok, value = pcall(multishell.getCount)
    if ok and value then return value end
  end
  return 1
end

function M.run()
  local timer = os.startTimer(0.5)

  while true do
    local w, h = term.getSize()
    local program = runningProgram()
    local tasks = taskCount()

    U.clear()
    U.header("Task Manager", true)
    U.label(2, 4, "Session status", U._accent)
    U.label(2, 6, "Running program: " .. tostring(program))
    U.label(2, 7, "Task sessions: " .. tostring(tasks))
    U.label(2, 8, "Memory: " .. string.format("%.1f KB", collectgarbage("count")))
    U.label(2, 9, "Uptime: " .. string.format("%.1f s", os.clock()))

    U.label(2, 11, "Apps run in guarded sessions; crashes return", U._muted)
    U.label(2, 12, "to the desktop. Lua code is not sandboxed.", U._muted)
    U.label(2, 13, "No OS-level process or memory isolation.", U._muted)

    U.backButton(h - 2)
    U.status("Live refresh | Q/Esc/Backspace = back")

    local e, a, b, c = os.pullEvent()
    if e == "timer" and a == timer then
      timer = os.startTimer(0.5)
    elseif U.closeEvent(e, a) then
      return
    elseif (e == "mouse_click" or e == "monitor_touch") and U.backHit(b, c, h - 2, 18) then
      return
    end
  end
end

return M
