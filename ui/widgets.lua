local T=dofile('/pacificos/ui/theme.lua')
local W={}

local function fit(text,w)
 text=tostring(text or '')
 if w<=0 then return '' end
 if #text>w then return string.sub(text,1,w) end
 return text..string.rep(' ',w-#text)
end

function W.clear(bg)
 term.setBackgroundColor(bg or T.bg)
 term.setTextColor(T.text)
 term.clear()
 term.setCursorPos(1,1)
end

function W.fill(x,y,w,h,bg,fg)
 w=math.max(0,math.floor(w or 0)); h=math.max(0,math.floor(h or 0))
 term.setBackgroundColor(bg or T.bg)
 if fg then term.setTextColor(fg) end
 for i=0,h-1 do
  term.setCursorPos(x,y+i)
  write(string.rep(' ',w))
 end
end

function W.button(x,y,w,h,label,bg,fg)
 label=tostring(label or '')
 w=math.max(1,math.floor(w or 1)); h=math.max(1,math.floor(h or 1))
 W.fill(x,y,w,h,bg or T.card)
 term.setTextColor(fg or T.text)
 local tx=x+math.max(0,math.floor((w-#label)/2))
 local ty=y+math.floor((h-1)/2)
 term.setCursorPos(tx,ty)
 write(string.sub(label,1,w))
end

function W.hit(x,y,w,h,tx,ty)
 return tx>=x and tx<x+w and ty>=y and ty<y+h
end

function W.top(title)
 local w=select(1,term.getSize())
 title=tostring(title or '')
 term.setBackgroundColor(T.panel)
 term.setTextColor(T.text)
 term.setCursorPos(1,1)
 write(fit(' PACIFICOS  '..title,w))
end

-- Backward-compatible API used by older PacificOS apps.
function W.header(title)
 W.top(title)
end

function W.bottom(text)
 local w,h=term.getSize()
 text=tostring(text or '')
 term.setBackgroundColor(T.dark)
 term.setTextColor(T.muted)
 term.setCursorPos(1,h)
 write(fit(text,w))
end

function W.status(text)
 W.bottom(text)
end

function W.center(y,text,fg)
 local w=select(1,term.getSize())
 text=tostring(text or '')
 term.setTextColor(fg or T.text)
 term.setCursorPos(math.max(1,math.floor((w-#text)/2)+1),y)
 write(string.sub(text,1,w))
end

function W.label(x,y,text,fg)
 local w=select(1,term.getSize())
 text=tostring(text or '')
 term.setCursorPos(math.max(1,x),math.max(1,y))
 term.setTextColor(fg or T.text)
 write(string.sub(text,1,math.max(0,w-x+1)))
end

return W
