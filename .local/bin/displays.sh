#!/usr/bin/env bash
set -euo pipefail

internal=""
external=""

notify() {
  local msg="${1:-}"
  if command -v dunstify >/dev/null 2>&1; then
    dunstify -a "displays" "$msg" 2>/dev/null || true
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send -a "displays" "$msg" 2>/dev/null || true
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

geom_of() {
  xrandr --query 2>/dev/null | grep "^${1} connected" | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+' | head -n1
}

restart_bar() {
  if [ -x "$HOME/.local/bin/polybar-launch.sh" ]; then
    nohup "$HOME/.local/bin/polybar-launch.sh" >/dev/null 2>&1 &
    disown 2>/dev/null || true
  fi
}

current_state() {
  local ia=0 ea=0
  [ -n "$internal" ] && output_active "$internal" && ia=1
  [ -n "$external" ] && output_active "$external" && ea=1
  if [ "$ea" = 1 ] && [ "$ia" = 0 ]; then
    echo "external"
    return
  fi
  if [ "$ia" = 1 ] && [ "$ea" = 0 ]; then
    echo "internal"
    return
  fi
  if [ "$ia" = 1 ] && [ "$ea" = 1 ]; then
    if [ "$(geom_of "$internal")" = "$(geom_of "$external")" ]; then
      echo "mirror"
    else
      echo "extended"
    fi
    return
  fi
  echo "none"
}

switch_to_external() {
  if [ -z "$external" ]; then
    notify "No external display found"
    return 1
  fi
  xrandr --output "$external" --auto --primary
  [ -n "$internal" ] && xrandr --output "$internal" --off
  notify "Display: external"
  restart_bar
}

switch_to_internal() {
  if [ -z "$internal" ]; then
    notify "No internal display found"
    return 1
  fi
  xrandr --output "$internal" --auto --primary
  [ -n "$external" ] && xrandr --output "$external" --off
  notify "Display: internal"
  restart_bar
}

switch_to_mirror() {
  if [ -z "$external" ] || [ -z "$internal" ]; then
    notify "Cannot mirror: need internal and external displays"
    return 1
  fi
  xrandr --output "$external" --primary --auto --output "$internal" --auto --same-as "$external"
  notify "Display: mirror"
  restart_bar
}

switch_to_extended() {
  if [ -z "$external" ] || [ -z "$internal" ]; then
    notify "Cannot extend: need internal and external displays"
    return 1
  fi
  xrandr --output "$external" --primary --auto --output "$internal" --auto --right-of "$external"
  notify "Display: extended"
  restart_bar
}

recover_internal() {
  if [ -z "$internal" ]; then
    notify "No internal display found"
    return 1
  fi
  xrandr --output "$internal" --auto --primary
  [ -n "$external" ] && xrandr --output "$external" --off
  notify "Recovery: internal screen enabled. If the lid is closed, open it."
  restart_bar
}

case "${1:-}" in
  external)
    find_outputs
    switch_to_external
    ;;
  internal)
    find_outputs
    switch_to_internal
    ;;
  mirror)
    find_outputs
    switch_to_mirror
    ;;
  extended)
    find_outputs
    switch_to_extended
    ;;
  recover)
    find_outputs
    recover_internal
    ;;
  cycle)
    find_outputs
    state="$(current_state)"
    case "$state" in
      none | extended) switch_to_external ;;
      external) switch_to_internal ;;
      internal) switch_to_mirror ;;
      mirror) switch_to_extended ;;
    esac
    ;;
  *)
    echo "usage: $0 {external|internal|mirror|extended|cycle|recover}" >&2
    exit 1
    ;;
esac
