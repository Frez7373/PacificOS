# PacificOS

**PacificOS 1.8.0** is a modern, touch-friendly desktop operating system for CC:Tweaked.

## Install

Enable the CC:Tweaked HTTP API and run:

```lua
wget run https://raw.githubusercontent.com/Frez7373/PacificOS/main/installer.lua
```

The bootstrap installer downloads the current stable system into `/pacificos`, uses a staging area and rollback backup, preserves the existing PacificOS configuration, and installs `/startup.lua`.

## Interface

- White-and-blue PacificOS theme
- Responsive layout for different terminal sizes
- Mouse and monitor touch support
- Keyboard navigation
- Stable desktop pagination with Previous/Next/Power controls
- BIOS entry with the `]` key during startup
- Recovery environment and Safe Mode
- Boot animation controlled from Settings

## Built-in applications

- **Files** — folder navigation, scrolling, create, rename, copy, move, delete, preview and editor integration
- **Text Editor** — line-based editing with add/edit/delete/save and protected system files
- **Calculator** — Basic and Scientific pages, history, ANS, trigonometry, powers, logarithms, factorial, gcd/lcm and more
- **Clock** — live clock, date and computer uptime
- **Calendar** — real month calendar with leap years and touch/keyboard month navigation
- **Converter** — length, mass and time conversions
- **Network Manager** — modem detection, enable/disable, open all modems and broadcast test
- **Device Manager** — peripheral list and method details
- **System Information** — terminal, CraftOS, storage and peripheral information
- **System Monitor** — live uptime, memory, storage and network status
- **Task Manager** — current session and memory diagnostics
- **Antivirus** — Lua syntax scanning for system and user applications
- **App Installer** — WGET/Pastebin installation, syntax validation, desktop shortcuts and uninstall
- **System Updater** — version check, staged update and rollback
- **Terminal** — direct CC:Tweaked shell commands
- **Settings** — persistent hostname, appearance, network, notification and boot options
- **About** — CCI information

## Third-party applications

PacificOS stores installed third-party applications under `/pacificos/userapps/` and their registry in `/pacificos/data/apps.cfg`.

The App Installer supports:

- **WGET** — direct HTTP/HTTPS Lua URL
- **PASTEBIN** — Pastebin code or raw URL
- Lua syntax validation before installation
- Launching apps which return `run()` or normal Lua programs
- Desktop shortcut hide/show
- Uninstall

Third-party applications are arbitrary Lua code. Install only applications you trust.

## Recovery

Recovery includes:

- Normal startup
- **Safe Mode**, which disables third-party desktop applications
- System diagnostics
- Factory Reset
- Reinstall from the official GitHub installer
- Shutdown

Factory Reset removes local settings, logs, installed third-party applications, app registry data and temporary installer/update files while keeping the PacificOS system, boot and recovery files.

## Architecture

PacificOS does **not** use Lua `require()`. Internal components use CC:Tweaked-compatible file loading.

Applications run in guarded cooperative sessions. PacificOS catches application failures and returns to the desktop instead of claiming unsupported process or memory isolation.

## Credits

**Complex Computer International (CCI) — 2026**

Repository: https://github.com/Frez7373/PacificOS
