local U=dofile('/pacificos/ui/widgets.lua'); local M={}
function M.run()
  local running=false
  local started=0
  local elapsed=0

  while true do
    local w,h=term.getSize()
    U.clear(); U.header('Stopwatch')

    local shown=elapsed
    if running then shown=elapsed+(os.clock()-started) end
    U.center(5,string.format('%.2f s',shown),colors.cyan)

    local buttons
    if w>=62 then
      U.button(3,8,18,2,running and 'Pause' or 'Start',running and colors.orange or colors.green)
      U.button(23,8,18,2,'Reset',colors.gray)
      U.button(43,8,18,2,'Back',colors.gray)
      buttons={
        {3,8,18,2,'toggle'},{23,8,18,2,'reset'},{43,8,18,2,'back'}
      }
    else
      local bw=math.max(8,math.floor((w-5)/2))
      U.button(2,8,bw,2,running and 'Pause' or 'Start',running and colors.orange or colors.green)
      U.button(3+bw,8,bw,2,'Reset',colors.gray)
      U.button(2,11,bw,2,'Back',colors.gray)
      buttons={
        {2,8,bw,2,'toggle'},{3+bw,8,bw,2,'reset'},{2,11,bw,2,'back'}
      }
    end

    U.status('Q/Esc: back')
    local e,a,b,c=os.pullEvent()

    if e=='key' and (a==keys.q or a==keys.escape) then
      return
    elseif (e=='mouse_click' or e=='monitor_touch') then
      for _,v in ipairs(buttons) do
        if b>=v[1] and b<v[1]+v[3] and c>=v[2] and c<v[2]+v[4] then
          if v[5]=='toggle' then
            if running then
              elapsed=elapsed+(os.clock()-started)
              running=false
            else
              started=os.clock()
              running=true
            end
          elseif v[5]=='reset' then
            elapsed=0
            if running then started=os.clock() end
          elseif v[5]=='back' then
            return
          end
          break
        end
      end
    elseif e=='timer' and running then
      -- redraw below
    end

    if running then os.startTimer(0.1) end
  end
end
return M
