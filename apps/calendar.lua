local U=dofile("/pacificos/ui/widgets.lua")
local M={}

local days={"Mon","Tue","Wed","Thu","Fri","Sat","Sun"}

function M.run()
  while true do
    local w,h=term.getSize()
    U.clear(); U.header("Calendar")
    local day=tonumber(os.day() or 0) or 0
    local time=textutils.formatTime(os.time(),true)
    U.center(3,"WORLD DAY "..day,U._accent)
    U.center(4,time,U._text)
    U.label(3,6,"7-day cycle",U._muted)

    local cell=math.max(5,math.floor((w-6)/7))
    local x0=3
    for i,name in ipairs(days) do
      local x=x0+(i-1)*cell
      U.button(x,8,cell-1,1,name,colors.gray)
    end

    local current=((day%7)+7)%7
    for i=1,7 do
      local x=x0+(i-1)*cell
      local bg=(i-1==current) and colors.blue or colors.black
      U.button(x,10,cell-1,2,tostring(day-current+i-1),bg)
    end

    U.label(3,13,"The highlighted day is today.",U._muted)
    U.button(3,h-3,20,2,"Back",colors.gray)
    U.status("Q / Esc / Backspace = close")
    local e,a,b,c=os.pullEvent()
    if e=="key" and (a==keys.q or a==keys.escape or a==keys.backspace) then return
    elseif (e=="mouse_click" or e=="monitor_touch") and c>=h-3 and c<h-1 and b>=3 and b<23 then return end
  end
end

return M
