# PacificOS

**PacificOS 1.0.0** is a modern, touch-first desktop environment and operating-system layer for CC:Tweaked.

## Install

Enable the HTTP API and run:

```lua
wget run https://raw.githubusercontent.com/Frez7373/PacificOS/main/installer.lua
```

The installer creates `/pacificos`, installs `/startup.lua`, and reboots.

## Recovery

During boot, press `R` after a boot failure, or run:

```text
/pacificos/recovery/recovery.lua
```

Recovery includes normal start, safe mode, diagnostics, factory reset, reinstall and shutdown.

## Included

- Boot animation and guarded startup
- Custom module loader; no Lua `require()`
- Event-driven desktop
- Adaptive layout based on `term.getSize()`
- Mouse and monitor-touch activation
- Settings
- File Manager
- Text Editor
- Calculator
- Clock and Calendar
- Network Manager
- Device Manager
- Terminal
- Task Manager diagnostics
- Updater
- Pacific Antivirus scan UI
- System Information and About
- Factory reset and recovery
- System logging helpers
- Modem/peripheral discovery

## Design goals

PacificOS favors stability over pretending CC:Tweaked has kernel facilities it does not provide. Applications are run behind `pcall`, hardware is discovered dynamically, and the GUI waits on events instead of spinning continuously.

## Important limitation

CC:Tweaked does not expose true protected processes, memory protection, hardware interrupts, or a full multitasking kernel to Lua programs. PacificOS 1.0 therefore uses cooperative application sessions rather than claiming to provide a native process scheduler. A future release can add a more advanced cooperative window compositor without changing the low-level compatibility layer.

## Repository

https://github.com/Frez7373/PacificOS
