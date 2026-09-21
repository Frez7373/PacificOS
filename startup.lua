-- PacificOS 1.8.0 startup
local ROOT = "/pacificos"

local ok, err = pcall(dofile, ROOT .. "/boot.lua")
if ok then return end

term.setBackgroundColor(colors.white)
term.setTextColor(colors.red)
term.clear()
term.setCursorPos(2, 2)

print("PACIFICOS STARTUP ERROR")
print("")
term.setTextColor(colors.black)
print(tostring(err))
print("")
print("R = Recovery   Q = Shutdown")

while true do
  local e, key = os.pullEvent()
  if e == "key" and key == keys.r then
    local recoveryOk, recoveryErr = pcall(dofile, ROOT .. "/recovery/recovery.lua")
    if not recoveryOk then
      term.setTextColor(colors.red)
      print("")
      print("Recovery failed:")
      print(tostring(recoveryErr))
      print("")
      print("Press any key to shutdown.")
      os.pullEvent()
      os.shutdown()
    end
    return
  elseif e == "key" and key == keys.q then
    os.shutdown()
    return
  end
end
