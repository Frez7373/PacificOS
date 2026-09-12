local W=dofile('/pacificos/ui/widgets.lua')
local M={windows={},active=nil,next=0}
function M.add(title,draw,click)
 M.next=M.next+1; local id=M.next; M.windows[#M.windows+1]={id=id,title=title,draw=draw,click=click,x=2+(id-1)%3*4,y=3+(id-1)%2*2,w=math.max(20,select(1,term.getSize())-8),h=math.max(8,select(2,term.getSize())-6),min=false}; M.active=id; return id
end
function M.close(id) for i,v in ipairs(M.windows) do if v.id==id then table.remove(M.windows,i); break end end; M.active=M.windows[#M.windows] and M.windows[#M.windows].id end
function M.draw() for _,v in ipairs(M.windows) do if not v.min and v.draw then pcall(v.draw,v) end end end
function M.event(e,a,b,c)
 if e=='mouse_click' or e=='monitor_touch' then
  for i=#M.windows,1,-1 do local v=M.windows[i]; if not v.min and a and b>=v.x and b<v.x+v.w and c>=v.y and c<v.y+v.h then M.active=v.id; if v.click then pcall(v.click,v,a,b,c) end; return true end end
 end
 return false
end
return M
