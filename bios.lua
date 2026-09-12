local BIOS = {}
BIOS.version = "1.0.0"
BIOS.root = "/pacificos"
function BIOS.hardware()
  local p = {id=os.getComputerID(), label=os.getComputerLabel(), w=select(1,term.getSize()), h=select(2,term.getSize()), peripherals={}}
  for _,s in ipairs(peripheral.getNames()) do p.peripherals[s] = peripheral.getType(s) end
  return p
end
function BIOS.safeRun(fn,...)
  return pcall(fn,...)
end
return BIOS
