local U=dofile('/pacificos/ui/widgets.lua')
local M={}
local function parent(path)
  if path=='/' then return '/' end
  local p=fs.getDir(path)
  if p=='' then return '/' end
  return '/'..p:gsub('^/','')
end
local function input(prompt)
  term.setBackgroundColor(colors.black); term.setTextColor(colors.white)
  term.setCursorPos(2,4); term.clearLine(); write(prompt..' ')
  return read()
end
function M.run()
  local path='/'
  while true do
    local w,h=term.getSize(); U.clear(); U.header('Files'); U.label(2,3,'Path: '..path)
    local list=fs.list(path); local rows=math.max(1,h-9)
    for i=1,math.min(#list,rows) do
      local n=list[i]; local p=fs.combine(path,n)
      U.label(3,3+i,(fs.isDir(p) and '[DIR] ' or '[FILE] ')..n,colors.lightGray)
    end
    local bw=math.max(7,math.floor((w-8)/4))
    U.button(2,h-4,bw,1,'New',colors.blue); U.button(3+bw,h-4,bw,1,'Folder',colors.blue)
    U.button(4+bw*2,h-4,bw,1,'Rename',colors.blue); U.button(5+bw*3,h-4,bw,1,'Delete',colors.red)
    U.button(2,h-2,bw,1,'Copy',colors.gray); U.button(3+bw,h-2,bw,1,'Move',colors.gray)
    U.button(4+bw*2,h-2,bw,1,'Up',colors.gray); U.button(5+bw*3,h-2,bw,1,'Back',colors.gray)
    U.status('Open folders with click | Backspace: up | Q/Esc: back')
    local e,a,b,c=os.pullEvent()
    if e=='key' then
      if a==keys.q or a==keys.escape then return elseif a==keys.backspace then path=parent(path) end
    elseif e=='mouse_click' or e=='monitor_touch' then
      local x,y=b,c; local row=y-3
      if row>=1 and row<=math.min(#list,rows) then
        local n=list[row]; local p=fs.combine(path,n); if fs.isDir(p) then path=p end
      elseif y==h-4 then
        if x>=2 and x<3+bw then
          local n=input('New file name:'); if n~='' then local hnd=fs.open(fs.combine(path,n),'w'); if hnd then hnd.close() end end
        elseif x>=3+bw and x<4+bw*2 then
          local n=input('New folder name:'); if n~='' and not fs.exists(fs.combine(path,n)) then fs.makeDir(fs.combine(path,n)) end
        elseif x>=4+bw*2 and x<5+bw*3 then
          local old=input('Rename:'); if old~='' and fs.exists(fs.combine(path,old)) then local nn=input('New name:'); if nn~='' then fs.move(fs.combine(path,old),fs.combine(path,nn)) end end
        elseif x>=5+bw*3 then
          local n=input('Delete:'); if n~='' and fs.exists(fs.combine(path,n)) then fs.delete(fs.combine(path,n)) end
        end
      elseif y==h-2 then
        if x>=2 and x<3+bw then
          local n=input('Copy source:'); if n~='' and fs.exists(fs.combine(path,n)) then local dest=input('Copy to:'); if dest~='' then fs.copy(fs.combine(path,n),dest) end end
        elseif x>=3+bw and x<4+bw*2 then
          local n=input('Move source:'); if n~='' and fs.exists(fs.combine(path,n)) then local dest=input('Move to:'); if dest~='' then fs.move(fs.combine(path,n),dest) end end
        elseif x>=4+bw*2 and x<5+bw*3 then path=parent(path)
        elseif x>=5+bw*3 then return end
      end
    end
  end
end
return M
