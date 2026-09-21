local U = dofile("/pacificos/ui/widgets.lua")
local M = {}

local function runCommand(command)
  if not shell or not shell.run then
    return false, "CC:Tweaked shell API is unavailable."
  end
  local ok, result = pcall(shell.run, command)
  return ok, ok and nil or tostring(result)
end

function M.run()
  local history = {}
  local notice = "Ready."

  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("Terminal", true)

    U.label(2, 4, "Direct CC:Tweaked shell", U._accent)
    U.label(2, 5, "Commands execute in the current computer session.", U._muted)

    local y = 7
    for i = math.max(1, #history - 4), #history do
      U.label(2, y, history[i], U._muted, math.max(1, w - 3))
      y = y + 1
    end

    U.label(2, math.min(h - 4, 14), notice, U._muted, math.max(1, w - 3))
    term.setCursorPos(2, math.min(h - 2, 16))
    term.setTextColor(U._accent)
    write("> ")
    local command = read()

    if command == nil then return end
    command = tostring(command)
    if command == "exit" or command == "quit" or command == ":q" then return end

    if command ~= "" then
      history[#history + 1] = "$ " .. command
      if command == "clear" then
        -- The next loop clears the screen.
      else
        local ok, err = runCommand(command)
        if not ok then
          history[#history + 1] = "! " .. tostring(err)
        end
      end
    end
  end
end

return M
