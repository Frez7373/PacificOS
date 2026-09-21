local U=dofile("/pacificos/ui/widgets.lua")
local M={}

local function parent(path)
  if path=="/" then return "/" end
  local p=fs.getDir(path)
  if p=="" then return "/" end
  return p:sub(1,1)=="/" and p or "/"..p
end

local function prompt(label)
  local w,h=term.getSize()
  U.label(2,h-5,string.rep(" ",math.max(1,w-2)),U._text)
  U.label(2,h-5,label,U._accent)
  term.setCursorPos(2,h-4)
  write("> ")
  return read()
end

local function openFile(path)
  if not fs.exists(path) or fs.isDir(path) then return end
  local ext=path:match("%.([%w]+)$")
  if ext=="lua" or ext=="txt" or ext=="log" or ext=="cfg" then
    local ok,res=pcall(dofile,"/pacificos/apps/editor.lua")
    if ok and type(res)=="table" and type(res.run)=="function" then
      pcall(res.run)
    end
  else
    local h=fs.open(path,"r")
    local data=h and h.readAll() or ""
    if h then h.close() end
    U.clear(); U.header("File Preview")
    local w,hg=term.getSize()
    local lines=0
    for line in (data.."
"):gmatch("(.-)
") do
      lines=lines+1
      if lines<=hg-5 then U.label(2,2+lines,line,U._text) end
    end
    U.label(2,hg-2,"File: "..path,U._muted)
    U.status("Press any key to return")
    os.pullEvent()
  end
end

function M.run()
  local path="/"
  local selected=1

  while true do
    local w,h=term.getSize()
    local list=fs.list(path)
    if selected>#list then selected=#list end
    if selected<1 then selected=1 end
    local rows=math.max(1,h-10)

    U.clear(); U.header("Files")
    U.label(2,3,"Path: "..path,U._muted)

    for i=1,math.min(#list,rows) do
      local n=list[i]
      local p=fs.combine(path,n)
      local prefix=fs.isDir(p) and "[DIR] " or "[FILE] "
      local bg=i==selected and colors.blue or colors.black
      U.button(2,3+i,math.max(15,w-4),1,prefix..n,bg)
    end

    if #list==0 then U.label(3,6,"Directory is empty.",U._muted) end

    local bw=math.max(8,math.floor((w-8)/4))
    local by=h-4
    U.button(2,by,bw,1,"New",colors.blue)
    U.button(3+bw,by,bw,1,"Folder",colors.blue)
    U.button(4+bw*2,by,bw,1,"Rename",colors.gray)
    U.button(5+bw*3,by,bw,1,"Delete",colors.red)
    U.button(2,h-2,bw,1,"Copy",colors.gray)
    U.button(3+bw,h-2,bw,1,"Move",colors.gray)
    U.button(4+bw*2,h-2,bw,1,"Up",colors.gray)
    U.button(5+bw*3,h-2,bw,1,"Back",colors.gray)
    U.status("Up/Down select | Enter opens | N new | Delete remove | Backspace up")

    local e,a,b,c=os.pullEvent()
    if e=="key" then
      if a==keys.q or a==keys.escape then return
      elseif a==keys.up then selected=math.max(1,selected-1)
      elseif a==keys.down then selected=math.min(math.max(1,#list),selected+1)
      elseif a==keys.backspace then path=parent(path); selected=1
      elseif a==keys.enter and list[selected] then
        local p=fs.combine(path,list[selected])
        if fs.isDir(p) then path=p; selected=1 else openFile(p) end
      elseif a==keys.n then
        local n=prompt("New file name:")
        if n and n~="" then local hnd=fs.open(fs.combine(path,n),"w"); if hnd then hnd.close() end end
      elseif a==keys.delete and list[selected] then
        local p=fs.combine(path,list[selected])
        if prompt("Type YES to delete "..list[selected]..":")=="YES" then fs.delete(p); selected=1 end
      end
    elseif e=="mouse_click" or e=="monitor_touch" then
      local x,y=b,c
      local row=y-3
      if row>=1 and row<=math.min(#list,rows) then
        selected=row
        local p=fs.combine(path,list[row])
        if fs.isDir(p) and y>=4 then path=p; selected=1 end
      elseif y==by then
        if x>=2 and x<3+bw then
          local n=prompt("New file name:")
          if n and n~="" then local hnd=fs.open(fs.combine(path,n),"w"); if hnd then hnd.close() end end
        elseif x>=3+bw and x<4+bw*2 then
          local n=prompt("New folder name:")
          if n and n~="" and not fs.exists(fs.combine(path,n)) then fs.makeDir(fs.combine(path,n)) end
        elseif x>=4+bw*2 and x<5+bw*3 and list[selected] then
          local old=list[selected]; local nn=prompt("Rename "..old.." to:")
          if nn and nn~="" then pcall(fs.move,fs.combine(path,old),fs.combine(path,nn)) end
        elseif x>=5+bw*3 and list[selected] then
          if prompt("Type YES to delete "..list[selected]..":")=="YES" then fs.delete(fs.combine(path,list[selected])); selected=1 end
        end
      elseif y==h-2 then
        if x>=2 and x<3+bw and list[selected] then
          local dest=prompt("Copy to path:")
          if dest and dest~="" then pcall(fs.copy,fs.combine(path,list[selected]),dest) end
        elseif x>=3+bw and x<4+bw*2 and list[selected] then
          local dest=prompt("Move to path:")
          if dest and dest~="" then pcall(fs.move,fs.combine(path,list[selected]),dest) end
        elseif x>=4+bw*2 then
          if x<5+bw*3 then path=parent(path); selected=1 else return end
        end
      end
    end
  end
end

return M
