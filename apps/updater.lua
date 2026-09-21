local U=dofile("/pacificos/ui/widgets.lua")
local Up=dofile("/pacificos/system/updater.lua")
local M={}

function M.run()
  while true do
    local w,h=term.getSize()
    U.clear(); U.header("System Updater")
    U.label(2,3,"PacificOS updates keep user-installed apps intact.",U._muted)

    local info,e=Up.compare()
    if not info then
      U.label(2,6,"Check failed: "..tostring(e),colors.red)
    else
      U.label(2,5,"Installed: "..tostring(info.localVersion),U._text)
      U.label(2,7,"Available: "..tostring(info.remoteVersion),U._text)
      U.label(2,9,info.update and "Update available." or "PacificOS is up to date.",info.update and colors.yellow or colors.lime)
      U.button(2,11,24,2,info.update and "Install Update" or "Check Again",colors.blue)
    end

    U.button(2,h-3,24,2,"Back",colors.gray)
    U.status("Q / Esc / Backspace = back")

    local ev,a,b,c=os.pullEvent()
    if ev=="key" and (a==keys.q or a==keys.escape or a==keys.backspace) then
      return
    elseif ev=="mouse_click" or ev=="monitor_touch" then
      if c>=h-3 and c<h-1 and b>=2 and b<26 then return end
      if c>=11 and c<13 and b>=2 and b<26 and info and info.update then
        U.clear(); U.header("System Updater"); U.label(2,5,"Installing update...",U._accent)
        local ok,err,count=Up.update(info.manifest)
        if ok then
          U.label(2,7,"Updated "..tostring(count).." files.",colors.lime)
          U.label(2,9,"Rebooting into the new version...",colors.lime)
          os.sleep(1)
          os.reboot()
          return
        else
          U.label(2,7,"Update failed:",colors.red)
          U.label(2,8,tostring(err),colors.red)
          U.label(2,10,"Updated before failure: "..tostring(count or 0),colors.yellow)
          U.status("Press any key to return")
          os.pullEvent()
        end
      elseif c>=11 and c<13 and b>=2 and b<26 and info and not info.update then
        -- refresh on next loop
      end
    end
  end
end

return M
