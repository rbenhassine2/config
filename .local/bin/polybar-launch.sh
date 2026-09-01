#!/usr/bin/env bash
set -uo pipefail

command -v polybar >/dev/null 2>&1 || exit 0

pkill -x polybar 2>/dev/null
for _ in $(seq 1 20); do
  pgrep -x polybar >/dev/null 2>&1 || break
  sleep 0.1
done

monitor="$(xrandr --query 2>/dev/null | awk '/ connected primary /{print $1; exit}')"
[ -z "$monitor" ] && monitor="$(xrandr --query 2>/dev/null | awk '/ connected /{print $1; exit}')"
[ -z "$monitor" ] && exit 0

export MONITOR="$monitor"
exec polybar main 2>/dev/null
