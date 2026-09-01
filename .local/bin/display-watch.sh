#!/usr/bin/env bash
set -uo pipefail

state_file="${XDG_STATE_HOME:-$HOME/.local/state}/display-watch.fallback"

internal=""
external=""

notify() {
  if command -v dunstify >/dev/null 2>&1; then
    dunstify -a "display-watch" "$1" 2>/dev/null
    return 0
  fi
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "display-watch" "$1" 2>/dev/null
    return 0
  fi
  return 0
}

restart_bar() {
  if [ -x "$HOME/.local/bin/polybar-launch.sh" ]; then
    nohup "$HOME/.local/bin/polybar-launch.sh" >/dev/null 2>&1 &
    disown 2>/dev/null || true
  fi
}

find_outputs() {
  local out
  internal=""
  external=""
  while read -r out; do
    [ -z "$out" ] && continue
    case "$out" in
      eDP-* | LVDS-* | DSI-*)
        [ -z "$internal" ] && internal="$out"
        ;;
      *)
        [ -z "$external" ] && external="$out"
        ;;
    esac
  done < <(xrandr --query 2>/dev/null | awk '/ connected /{print $1}')
}

output_active() {
  xrandr --query 2>/dev/null | grep "^${1} connected" | grep -qE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+'
}

sleep 3

while true; do
  find_outputs

  if [ -z "$external" ] || [ -z "$internal" ]; then
    sleep 2
    continue
  fi

  ext_active=0
  int_active=0
  output_active "$external" && ext_active=1
  output_active "$internal" && int_active=1

  if [ "$ext_active" = 1 ] && [ "$int_active" = 0 ]; then
    rm -f "$state_file"
  elif [ "$ext_active" = 0 ] && [ "$int_active" = 0 ]; then
    if [ ! -e "$state_file" ]; then
      mkdir -p "$(dirname "$state_file")"
      touch "$state_file"
      xrandr --output "$internal" --auto --primary 2>/dev/null
      [ -n "$external" ] && xrandr --output "$external" --off 2>/dev/null
      notify "External display lost. Internal screen enabled - open the lid if closed."
      restart_bar
    fi
  elif [ "$ext_active" = 1 ] && [ "$int_active" = 1 ] && [ -e "$state_file" ]; then
    rm -f "$state_file"
    xrandr --output "$external" --auto --primary 2>/dev/null
    xrandr --output "$internal" --off 2>/dev/null
    notify "External display restored."
    restart_bar
  fi

  sleep 2
done
