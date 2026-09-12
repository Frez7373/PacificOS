local T=dofile('/pacificos/ui/theme.lua')
local W={}
function W.fill(x,y,w,h,bg)
 term.setBackgroundColor(bg or T.bg)
 for i=0,h-1 do term.setCursorPos(x,y+i); write(string.rep(' ',w)) end
end
function W.button(x,y,w,h,label,bg)
 term.setBackgroundColor(bg or T.panel); term.setTextColor(T.text)
 for i=0,h-1 do term.setCursorPos(x,y+i); write(string.rep(' ',w)) end
 term.setCursorPos(x+math.max(0,math.floor((w-#label)/2)),y+math.floor(h/2)); write(label)
end
function W.hit(x,y,w,h,tx,ty) return tx>=x and tx<x+w and ty>=y and ty<y+h end
function W.header(title)
 local w=select(1,term.getSize()); term.setBackgroundColor(T.panel); term.setTextColor(T.text); term.setCursorPos(1,1); write(' PacificOS | '..title..string.rep(' ',math.max(0,w-#title-14)))
end
function W.status(text)
 local w,h=term.getSize(); term.setBackgroundColor(T.dark); term.setTextColor(T.text); term.setCursorPos(1,h); write((text or '')..string.rep(' ',math.max(0,w-#(text or ''))))
end
return W
