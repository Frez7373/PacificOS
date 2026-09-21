local U = dofile("/pacificos/ui/widgets.lua")
local Up = dofile("/pacificos/system/updater.lua")
local M = {}

local function showMessage(title, message, color)
  local w, h = term.getSize()
  U.clear()
  U.header(title, true)
  U.label(2, 5, message, color or U._text, math.max(1, w - 3))
  U.status("Press any key to return")
  os.pullEvent()
end

function M.run()
  while true do
    local w, h = term.getSize()
    U.clear()
    U.header("System Updater", true)
    U.label(2, 4, "Checks the official PacificOS GitHub manifest.", U._muted)

    local info, err = Up.compare()
    if not info then
      U.label(2, 7, "Update check failed:", U._bad)
      U.label(2, 8, tostring(err), U._bad, math.max(1, w - 3))
      U.label(2, 10, "Check HTTP access and try again.", U._muted)
      U.backButton(h - 2)
      U.status("Q/Esc/Backspace = back")
    else
      U.label(2, 6, "Installed: " .. tostring(info.localVersion), U._text)
      U.label(2, 7, "Available: " .. tostring(info.remoteVersion), U._accent)

      if info.update then
        U.label(2, 9, "A newer PacificOS release is available.", U._warn)
        U.button(2, 11, math.min(28, w - 3), 2, "INSTALL UPDATE", U._accent)
      elseif info.remoteAheadOrDifferent then
        U.label(2, 9, "Versions differ, but the remote version is not newer.", U._muted)
      else
        U.label(2, 9, "PacificOS is up to date.", U._accent)
      end

      U.backButton(h - 2)
      U.status("Enter = install when available | Q/Esc/Backspace = back")
    end

    local e, a, b, c = os.pullEvent()
    if U.closeEvent(e, a) then return end
    if (e == "mouse_click" or e == "monitor_touch") and U.backHit(b, c, h - 2, 18) then
      return
    end

    if info and info.update then
      local requested = e == "key" and a == keys.enter
      requested = requested or ((e == "mouse_click" or e == "monitor_touch") and U.hit(2, 11, math.min(28, w - 3), 2, b, c))
      if requested then
        U.clear()
        U.header("System Updater")
        U.label(2, 5, "Downloading and staging the update...", U._accent)
        local ok, updateErr, count = Up.update(info.manifest)
        if ok then
          U.label(2, 7, "Updated " .. tostring(count or 0) .. " files.", U._accent)
          U.label(2, 8, "User apps and user data were preserved.", U._text)
          U.label(2, 10, "Rebooting...", U._muted)
          os.sleep(1)
          os.reboot()
          return
        else
          showMessage("Update Failed", tostring(updateErr) .. " | Applied: " .. tostring(count or 0), U._bad)
        end
      end
    end
  end
end

return M
