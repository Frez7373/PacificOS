-- PACIFICOS_WIDGET_COMPAT_161
local T=dofile("/pacificos/ui/theme.lua")
local W={}
W._accent=T.accent
W._muted=T.muted
W._text=T.text

local function fit(text,w)
  text=tostring(text or "")
  w=tonumber(w) or 0
  if w<=0 then return "" end
  if #text>w then
    if w<=3 then return string.rep(".",w) end
    return text:sub(1,w-3).."..."
  end
  return text..string.rep(" ",w-#text)
end

function W.clear(bg)
  term.setBackgroundColor(bg or T.bg)
  term.setTextColor(T.text)
  term.clear()
  term.setCursorPos(1,1)
end

function W.fill(x,y,w,h,bg,fg)
  x=math.max(1,math.floor(tonumber(x) or 1))
  y=math.max(1,math.floor(tonumber(y) or 1))
  w=math.max(0,math.floor(tonumber(w) or 0))
  h=math.max(0,math.floor(tonumber(h) or 0))
  if w<=0 or h<=0 then return end
  term.setBackgroundColor(bg or T.bg)
  if fg then term.setTextColor(fg) end
  for i=0,h-1 do
    term.setCursorPos(x,y+i)
    write(string.rep(" ",w))
  end
end

function W.button(x,y,w,h,label,bg,fg)
  -- Accept both the current signature:
  -- button(x,y,w,h,label,bg,fg)
  -- and the old PacificOS signature:
  -- button(x,y,w,label,bg)
  if type(h)~="number" then
    local oldLabel=h
    local oldBg=label
    local oldFg=bg
    h=1
    label=oldLabel
    bg=oldBg
    fg=oldFg
  end

  x=math.max(1,math.floor(tonumber(x) or 1))
  y=math.max(1,math.floor(tonumber(y) or 1))
  w=math.max(1,math.floor(tonumber(w) or 1))
  h=math.max(1,math.floor(tonumber(h) or 1))
  label=tostring(label or "")

  W.fill(x,y,w,h,bg or T.card)
  term.setTextColor(fg or T.text)

  local shown=string.sub(label,1,w)
  local tx=x+math.max(0,math.floor((w-#shown)/2))
  local ty=y+math.floor((h-1)/2)

  term.setCursorPos(tx,ty)
  write(shown)
end

function W.hit(x,y,w,h,tx,ty)
  return tx>=x and tx<x+w and ty>=y and ty<y+h
end

function W.top(title)
  local w=select(1,term.getSize())
  title=tostring(title or "")
  term.setBackgroundColor(T.panel)
  term.setTextColor(T.text)
  term.setCursorPos(1,1)
  write(fit(" PACIFICOS  "..title,w))
end

function W.header(title)
  W.top(title)
end

function W.bottom(text)
  local w,h=term.getSize()
  text=tostring(text or "")
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
  text=tostring(text or "")
  term.setTextColor(fg or T.text)
  term.setCursorPos(math.max(1,math.floor((w-#text)/2)+1),math.max(1,y))
  write(string.sub(text,1,w))
end

function W.label(x,y,text,fg)
  local w=select(1,term.getSize())
  text=tostring(text or "")
  x=math.max(1,math.floor(tonumber(x) or 1))
  y=math.max(1,math.floor(tonumber(y) or 1))
  term.setCursorPos(x,y)
  term.setTextColor(fg or T.text)
  write(string.sub(text,1,math.max(0,w-x+1)))
end

return W
