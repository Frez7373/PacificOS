term.clear(); term.setCursorPos(1,1); term.setTextColor(colors.red)
print('PACIFICOS FACTORY RESET'); print('This removes /pacificos/config.cfg, logs and user data under /pacificos/user.'); print('System recovery files are kept.'); term.setTextColor(colors.white); write('Type RESET to continue: ')
if read()~='RESET' then print('Cancelled.'); os.sleep(1); return end
if fs.exists('/pacificos/config.cfg') then fs.delete('/pacificos/config.cfg') end
if fs.exists('/pacificos/logs') then fs.delete('/pacificos/logs') end
if fs.exists('/pacificos/user') then fs.delete('/pacificos/user') end
print('Factory reset complete.'); os.sleep(1); os.reboot()
