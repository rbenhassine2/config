# polybar status bar

`polybar` replaces i3's built-in bar. Config: `~/.config/polybar/config.ini`.

## Launch script

`~/.local/bin/polybar-launch.sh` kills any existing polybar and starts it on the
**current primary monitor** (detected via `xrandr`). It is re-run by
`displays.sh` and the watchdog after every display switch, so the bar always
follows the active screen.

## Modules

- **workspaces** (left) - i3 workspaces with Nerd Font icons; focused/urgent colored.
- **title** (center) - focused window title.
- **cpu** - percentage, 2s interval.
- **temperature** - CPU package temp (`x86_pkg_temp`, thermal-zone 11); turns
  the warning color at 80C.
- **memory** - used / total.
- **filesystem** - free space on `/`.
- **network** - `enp12s0` ethernet IP.
- **pulseaudio** - volume percentage; shows "muted" when muted.
- **battery** - charge percentage, charging/full states.
- **date** - `%a %d %b %Y %H:%M`.

## Fonts

Uses `Hurmit Nerd Font Mono` so workspace icons and glyphs render. The tray
(right side) hosts nm-applet, blueman-applet, copyq, etc.
