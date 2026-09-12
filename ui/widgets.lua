local T=dofile('/pacificos/ui/theme.lua')
local W={}
function W.clear(bg) term.setBackgroundColor(bg or T.bg); term.clear(); term.setCursorPos(1,1) end
function W.fill(x,y,w,h,bg) term.setBackgroundColor(bg or T.bg); for i=0,h-1 do term.setCursorPos(x,y+i); write(string.rep(' ',math.max(0,w))) end end
function W.button(x,y,w,h,label,bg,fg) W.fill(x,y,w,h,bg or T.card); term.setTextColor(fg or T.text); term.setCursorPos(x+math.max(0,math.floor((w-#label)/2)),y+math.floor((h-1)/2)); write(label) end
function W.hit(x,y,w,h,tx,ty) return tx>=x and tx<x+w and ty>=y and ty<y+h end
function W.top(title) local w=select(1,term.getSize()); term.setBackgroundColor(T.panel); term.setTextColor(T.text); term.setCursorPos(1,1); write(' PACIFICOS  '..title..string.rep(' ',math.max(0,w-#title-11))) end
function W.bottom(text) local w,h=term.getSize(); term.setBackgroundColor(T.dark); term.setTextColor(T.muted); term.setCursorPos(1,h); write(string.sub(text or '',1,w)..string.rep(' ',math.max(0,w-#(text or '')))) end
function W.center(y,text,fg) local w=select(1,term.getSize()); term.setTextColor(fg or T.text); term.setCursorPos(math.max(1,math.floor((w-#text)/2)+1),y); write(text) end
return W
