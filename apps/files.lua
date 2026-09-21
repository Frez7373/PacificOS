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
    if ok and type(res)=="table" and type(res.run)=="function" then pcall(res.run) end
  else
    local h=fs.open(path,"r")
    local data=h and h.readAll() or ""
    if h then h.close() end
    U.clear(); U.header("File Preview")
    local _,hg=term.getSize()
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

local function toolRect(x,y,w,h,action)
  return {x=x,y=y,w=w,h=h,action=action}
end

local function drawToolbar(w,h)
  local labels={"New","Folder","Rename","Delete","Copy","Move","Up","Back"}
  local cols=(w>=42) and 4 or 3
  local rows=math.ceil(#labels/cols)
  local gap=1
  local bw=math.max(7,math.floor((w-2-(cols-1)*gap)/cols))
  local startY=h-(rows*2+1)
  local buttons={}
  for i,label in ipairs(labels) do
    local col=(i-1)%cols
    local row=math.floor((i-1)/cols)
    local x=2+col*(bw+gap)
    local y=startY+row*2
    if x+bw-1<=w then
      U.button(x,y,bw,1,label,label=="Delete" and colors.red or colors.gray)
      buttons[#buttons+1]=toolRect(x,y,bw,1,label)
    end
  end
  return buttons
end

local function inside(r,x,y)
  return x>=r.x and x<r.x+r.w and y>=r.y and y<r.y+r.h
end

local function doTool(action,path,list,selected,promptFn)
  local item=list[selected]
  local full=item and fs.combine(path,item) or nil

  if action=="New" then
    local n=promptFn("New file name:")
    if n and n~="" then
      local h=fs.open(fs.combine(path,n),"w")
      if h then h.close() end
    end
  elseif action=="Folder" then
    local n=promptFn("New folder name:")
    if n and n~="" and not fs.exists(fs.combine(path,n)) then fs.makeDir(fs.combine(path,n)) end
  elseif action=="Rename" and full then
    local nn=promptFn("Rename "..item.." to:")
    if nn and nn~="" then pcall(fs.move,full,fs.combine(path,nn)) end
  elseif action=="Delete" and full then
    if promptFn("Type YES to delete "..item..":")=="YES" then fs.delete(full) end
  elseif action=="Copy" and full then
    local dest=promptFn("Copy to path:")
    if dest and dest~="" then pcall(fs.copy,full,dest) end
  elseif action=="Move" and full then
    local dest=promptFn("Move to path:")
    if dest and dest~="" then pcall(fs.move,full,dest) end
  elseif action=="Up" then
    return "up"
  elseif action=="Back" then
    return "back"
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

    local narrow=w<42
    local toolbarRows=narrow and 3 or 2
    local rows=math.max(1,h-(toolbarRows*2+5))

    U.clear(); U.header("Files")
    U.label(2,3,"Path: "..path,U._muted)

    for i=1,math.min(#list,rows) do
      local n=list[i]
      local p=fs.combine(path,n)
      local prefix=fs.isDir(p) and "[DIR] " or "[FILE] "
      local bg=i==selected and colors.blue or colors.black
      U.button(2,3+i,math.max(10,w-4),1,prefix..n,bg)
    end

    if #list==0 then U.label(3,6,"Directory is empty.",U._muted) end

    local buttons=drawToolbar(w,h)
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
        doTool("New",path,list,selected,prompt)
      elseif a==keys.delete and list[selected] then
        doTool("Delete",path,list,selected,prompt)
      end
    elseif e=="mouse_click" or e=="monitor_touch" then
      local x,y=b,c
      local row=y-3
      if row>=1 and row<=math.min(#list,rows) then
        selected=row
        local p=fs.combine(path,list[row])
        if fs.isDir(p) then path=p; selected=1 end
      else
        for _,r in ipairs(buttons) do
          if inside(r,x,y) then
            local result=doTool(r.action,path,list,selected,prompt)
            if result=="up" then path=parent(path); selected=1
            elseif result=="back" then return end
            break
          end
        end
      end
    end
  end
end

return M
