#!/usr/bin/env bash
set -uo pipefail

choices="  Lock
  Logout
  Reboot
  Shutdown"

choice="$(printf '%b\n' "$choices" | rofi -dmenu -theme onedark -p 'System' -no-custom -i)"

case "$choice" in
  *Lock) i3lock -c 282c34 -u ;;
  *Logout) i3-msg exit ;;
  *Reboot) systemctl reboot ;;
  *Shutdown) systemctl poweroff ;;
esac
