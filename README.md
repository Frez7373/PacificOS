# PacificOS

**PacificOS 1.6.0** is a modern, touch-friendly desktop operating system for CC:Tweaked.

## Install

Enable the CC:Tweaked HTTP API and run:

```lua
wget run https://raw.githubusercontent.com/Frez7373/PacificOS/main/installer.lua
```

The installer installs the current PacificOS files into `/pacificos`, installs `/startup.lua`, and reboots.

## Third-party applications

PacificOS 1.6 adds a built-in **App Installer**.

From the desktop open **App Installer** and choose:

- **WGET** — paste a direct HTTP/HTTPS URL to a Lua application.
- **PASTEBIN** — enter a Pastebin code or Pastebin URL.
- The downloaded Lua is syntax-checked before installation.
- The installer stores third-party apps in `/pacificos/userapps/`.
- Installed apps are registered in `/pacificos/data/apps.cfg`.
- Every new app is automatically added to the PacificOS desktop.
- The installer can launch, hide/show a desktop shortcut, and uninstall apps.
- A failed third-party application is isolated with `pcall` so its error returns to the desktop instead of crashing the whole launcher.

An installed application should either return a table containing `run()` or behave as a normal CC:Tweaked Lua program.

## Built-in features

- Guarded boot screen and recovery
- Adaptive desktop for normal computers, advanced computers and monitor touch
- Reliable desktop pagination
- Settings and local configuration
- File Manager with create, rename, copy, move and delete
- Calculator with trigonometry, powers, factorial, gcd/lcm and more
- Clock and calendar
- Network and device tools
- Text editor and terminal
- Task Manager diagnostics
- Working system updater
- Antivirus UI
- System information
- Factory reset and recovery

PacificOS does **not** use Lua `require()`. Its internal modules use CC:Tweaked-compatible file loading.

## Important limitation

CC:Tweaked does not provide true protected processes or native memory isolation for Lua applications. PacificOS therefore uses guarded cooperative application sessions rather than claiming full process isolation.

## Repository

https://github.com/Frez7373/PacificOS
