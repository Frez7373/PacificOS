local ok, err = pcall(dofile, "/pacificos/boot.lua")
if not ok then
  term.clear(); term.setCursorPos(1,1)
  print("PacificOS startup error")
  print(tostring(err))
  print("")
  print("R = Recovery   Q = Shutdown")
  while true do
    local _, k = os.pullEvent("key")
    if k == keys.r then dofile("/pacificos/recovery/recovery.lua"); break end
    if k == keys.q then os.shutdown(); break end
  end
end
