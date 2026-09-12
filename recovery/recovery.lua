local ROOT='/pacificos'
local function reset() term.clear(); term.setCursorPos(1,1) end
local items={'Start PacificOS','Safe Mode','System Diagnostics','Factory Reset','Reinstall PacificOS','Shutdown'}
while true do
 reset(); print('PACIFICOS RECOVERY 1.0.0'); print('')
 for i,v in ipairs(items) do print(i..'. '..v) end
 print(''); write('Select: '); local n=tonumber(read())
 if n==1 then dofile(ROOT..'/boot.lua'); return
 elseif n==2 then dofile(ROOT..'/kernel.lua'); return
 elseif n==3 then print('Computer ID: '..os.getComputerID()); print('Terminal: '..select(1,term.getSize())..'x'..select(2,term.getSize())); print('Free space: '..tostring(fs.getFreeSpace('/'))); print('Peripherals:'); for _,s in ipairs(peripheral.getNames()) do print(' - '..s..' ['..tostring(peripheral.getType(s))..']') end; print(''); print('Press Enter.'); read()
 elseif n==4 then dofile(ROOT..'/recovery/factory_reset.lua')
 elseif n==5 then if http then shell.run('wget','run','https://raw.githubusercontent.com/Frez7373/PacificOS/main/installer.lua') else print('HTTP disabled'); read() end
 elseif n==6 then os.shutdown() end
end
