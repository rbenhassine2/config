#!/usr/bin/env bash
set -uo pipefail

case "${1:-}" in
  up) pactl set-sink-volume @DEFAULT_SINK@ +10% ;;
  down) pactl set-sink-volume @DEFAULT_SINK@ -10% ;;
  mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
  *) echo "usage: $0 {up|down|mute}" >&2; exit 1 ;;
esac

vol="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oE '[0-9]+%' | head -n1)"
muted="$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -oE 'yes|no' | head -n1)"

if [ "$muted" = "yes" ]; then
  msg="Volume muted"
elif [ -n "$vol" ]; then
  msg="Volume: $vol"
else
  msg="Volume"
fi

if command -v dunstify >/dev/null 2>&1; then
  dunstify -r 9999 -a volume "$msg" 2>/dev/null
elif command -v notify-send >/dev/null 2>&1; then
  notify-send -a volume "$msg" 2>/dev/null
fi
