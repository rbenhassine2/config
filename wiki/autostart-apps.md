# Autostart apps & services

Everything that starts with your session, and how it is launched.

## i3 `exec` lines (`.config/i3/mystuff`)

`exec` (not `exec_always`) is used deliberately: commands run on i3 start and
on `i3 restart`, but **not** on `i3 reload` - this avoids spawning duplicate
daemons when you reload the config.

| Command | Purpose |
| --- | --- |
| `nm-applet` | NetworkManager tray |
| `xss-lock --transfer-sleep-lock -- i3lock --nofork` | lock on suspend / idle |
| `picom --config ~/.config/picom/picom.conf` | compositor |
| `dunst` | notifications |
| `copyq` | clipboard history tray |
| `blueman-applet` | Bluetooth tray |
| `xset s 300; xset s blank; xset dpms 600 600 600` | idle lock timers |
| `~/.local/bin/polybar-launch.sh` | status bar |
| `feh --bg-fill ~/Pictures/wallpapers/onedark.png` | wallpaper |
| `~/.local/bin/autotiling` | auto split orientation |
| `~/.local/bin/boot-display.sh` | enable external display if connected |
| `kitty --class scratchpad` | hidden scratchpad terminal |
| `google-chrome`, `brave-browser` | browsers on their workspaces |

## systemd user services

| Service | Purpose |
| --- | --- |
| `display-watch.service` | display fallback watchdog (see [displays.md](displays.md)) |

## dex / XDG autostart

`dex --autostart --environment i3` runs any `.desktop` files in `~/.config/autostart`.
