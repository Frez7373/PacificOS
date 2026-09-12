local ROOT = "/pacificos"
local function center(y, text)
  local w = select(1, term.getSize()); term.setCursorPos(math.max(1, math.floor((w - #text) / 2) + 1), y); write(text)
end
term.setBackgroundColor(colors.black); term.setTextColor(colors.white); term.clear()
local w,h = term.getSize()
center(math.max(2, math.floor(h/2)-3), "PACIFICOS")
center(math.max(3, math.floor(h/2)-1), "Initializing system...")
local checks = {"Checking hardware...", "Checking system files...", "Loading kernel...", "Loading services...", "Starting graphical interface..."}
for i,msg in ipairs(checks) do
  term.setCursorPos(2, math.max(5, math.floor(h/2)+i-1)); print("["..i.."/"..#checks.."] "..msg)
  os.sleep(0.15)
end
if not fs.exists(ROOT .. "/kernel.lua") then error("kernel.lua is missing") end
local ok, err = pcall(dofile, ROOT .. "/kernel.lua")
if not ok then
  term.setBackgroundColor(colors.black); term.setTextColor(colors.red); term.clear(); term.setCursorPos(1,1)
  print("PACIFICOS BOOT ERROR"); print(""); print(tostring(err)); print(""); print("R Recovery   Q Shutdown")
  while true do
    local _,k = os.pullEvent("key")
    if k == keys.r then dofile(ROOT .. "/recovery/recovery.lua"); break end
    if k == keys.q then os.shutdown(); break end
  end
end
