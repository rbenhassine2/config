#!/usr/bin/env bash
set -uo pipefail

sleep 2

ext="$(xrandr --query 2>/dev/null | awk '/ connected /{print $1}' | grep -vE '^(eDP|LVDS|DSI)-' | head -n1)"
[ -n "$ext" ] || exit 0

exec "$HOME/.local/bin/displays.sh" external
