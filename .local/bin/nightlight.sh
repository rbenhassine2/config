#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_STATE_HOME:-$HOME/.local/state}/nightlight"

on() {
  command -v redshift >/dev/null 2>&1 || { notify-send "nightlight" "redshift not installed"; exit 1; }
  redshift -P -O 4500
  touch "$state_file"
  if command -v dunstify >/dev/null 2>&1; then
    dunstify -r 9998 -a nightlight "Night light ON (4500K)" 2>/dev/null || true
  fi
}

off() {
  command -v redshift >/dev/null 2>&1 || exit 0
  redshift -x
  rm -f "$state_file"
  if command -v dunstify >/dev/null 2>&1; then
    dunstify -r 9998 -a nightlight "Night light OFF" 2>/dev/null || true
  fi
}

case "${1:-toggle}" in
  on) on ;;
  off) off ;;
  toggle)
    if [ -e "$state_file" ]; then off; else on; fi
    ;;
esac
