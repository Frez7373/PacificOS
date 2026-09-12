local U=dofile('/pacificos/ui/widgets.lua')
local M={}

function M.run()
 while true do
  local w,h=term.getSize()
  U.clear()
  U.header('System Information')
  local free='Unknown'
  pcall(function() free=tostring(fs.getFreeSpace('/')) end)
  local label=os.getComputerLabel()
  local lines={
   'PacificOS 1.5.0',
   'Made by Complex Computer International (CCI)',
   'Copyright CCI 2026',
   'Computer ID: '..tostring(os.getComputerID()),
   'Computer label: '..tostring(label or 'Not set'),
   'Terminal: '..w..'x'..h,
   'CraftOS: '..tostring(os.version()),
   'Free storage: '..free..' bytes',
   'Peripherals: '..tostring(#peripheral.getNames())
  }
  local maxLines=math.max(1,h-7)
  for i=1,math.min(#lines,maxLines) do U.label(3,3+i,lines[i],i<=3 and U._accent or U._text) end
  U.button(3,h-3,20,2,'Back',colors.gray)
  U.status('Q / Esc / Backspace = close')
  local e,a,b,c=os.pullEvent()
  if e=='key' and (a==keys.q or a==keys.escape or a==keys.backspace) then return
  elseif (e=='mouse_click' or e=='monitor_touch') and c>=h-3 and c<h-1 and b>=3 and b<23 then return end
 end
end
return M
