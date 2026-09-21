local ROOT = "/pacificos"

term.setBackgroundColor(colors.black)
term.setTextColor(colors.red)
term.clear()
term.setCursorPos(1, 1)

print("PACIFICOS FACTORY RESET 1.8.0")
print("")
print("This will remove:")
print(" - settings and logs")
print(" - installed third-party apps")
print(" - application registry and user data")
print("")
print("System, BIOS, boot and recovery files will be kept.")
print("")
term.setTextColor(colors.white)
write("Type RESET to continue: ")

if read() ~= "RESET" then
  print("")
  print("Cancelled.")
  os.sleep(1)
  return
end

local paths = {
  ROOT .. "/config.cfg",
  ROOT .. "/logs",
  ROOT .. "/data",
  ROOT .. "/user",
  ROOT .. "/userapps",
  ROOT .. "/.installer_tmp.lua",
  ROOT .. "/.update_stage",
  ROOT .. "/.update_backup"
}

for _, path in ipairs(paths) do
  if fs.exists(path) then pcall(fs.delete, path) end
end

term.setTextColor(colors.lime)
print("")
print("Factory reset complete.")
print("Rebooting...")
os.sleep(1)
os.reboot()
