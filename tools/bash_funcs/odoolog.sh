odoolog() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "Usage: odoolog {on|off|level|handler|show|clear|tail|grep} [value]"
    echo
    echo "Toggle and read Odoo logging for the nearest project. The odoo.conf is"
    echo "located by walking up from the current directory; edits only the"
    echo "log_level and log_handler lines. Changes apply after restarting Odoo."
    echo
    echo "Commands:"
    echo "  on                Set log_level = debug (verbose)."
    echo "  off               Set log_level = info (quiet)."
    echo "  level <lvl>       Set log_level: debug|info|warn|error|critical."
    echo "  handler '<expr>'  Set log_handler, e.g. 'odoo.addons.sale:DEBUG'"
    echo "                    for per-module debug without the full flood."
    echo "  show              Print the conf path, level, handler and logfile."
    echo "  clear             Truncate the log file (fresh log on next start)."
    echo "  tail [pattern]    Live-follow the log (less +F); filter by pattern."
    echo "  grep [pattern]    Search the log (default pattern: ERROR)."
    echo
    echo "Environment:"
    echo "  ODOO_CONF         Override the odoo.conf path."
    echo "  ODOO_LOG          Override the log file path."
    return 0
  fi

  local conf="${ODOO_CONF:-}"
  local action="${1:-}"
  local val="${2:-}"

  [ -z "$conf" ] && conf="$(find_odo_conf)"
  [ -z "$conf" ] && { echo "could not locate odoo.conf (override with ODOO_CONF)"; return 1; }

  local logfile="${ODOO_LOG:-$(odo_log_file "$conf")}"

  case "$action" in
    on)
      odo_set_conf "$conf" log_level debug
      ;;
    off)
      odo_set_conf "$conf" log_level info
      ;;
    level)
      [ -z "$val" ] && { echo "usage: odoolog level <debug|info|warn|error|critical>"; return 1; }
      odo_set_conf "$conf" log_level "$val"
      ;;
    handler)
      [ -z "$val" ] && { echo "usage: odoolog handler '<log_handler expr>'"; return 1; }
      odo_set_conf "$conf" log_handler "$val"
      ;;
    show)
      echo "conf:    $conf"
      echo "level:   $(odo_get_conf "$conf" log_level)"
      echo "handler: $(odo_get_conf "$conf" log_handler)"
      echo "logfile: $(odo_log_file "$conf")"
      ;;
    tail)
      [ -z "$logfile" ] && { echo "no logfile in conf (override with ODOO_LOG)"; return 1; }
      if [ -n "$val" ]; then
        tail -F "$logfile" | grep --line-buffered "$val" | less +F
      else
        exec less +F "$logfile"
      fi
      ;;
    grep)
      [ -z "$logfile" ] && { echo "no logfile in conf (override with ODOO_LOG)"; return 1; }
      [ -z "$val" ] && val="ERROR"
      grep -n "$val" "$logfile"
      ;;
    clear)
      [ -z "$logfile" ] && { echo "no logfile in conf (override with ODOO_LOG)"; return 1; }
      mkdir -p "$(dirname "$logfile")"
      : > "$logfile"
      echo "odoolog: truncated $logfile"
      ;;
    *)
      echo "usage: odoolog {on|off|level|handler|show|clear|tail|grep} [value]"
      echo "  on                set log_level = debug"
      echo "  off               set log_level = info"
      echo "  level <lvl>       set log_level (debug|info|warn|error|critical)"
      echo "  handler '<expr>'  set log_handler, e.g. 'odoo.addons.sale:DEBUG'"
      echo "  show              print conf path, level, handler, logfile"
      echo "  clear             truncate the log file"
      echo "  tail [pattern]    live-follow the log (less +F), filter if pattern given"
      echo "  grep [pattern]    search the log (default ERROR)"
      ;;
  esac
}

find_odo_conf() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/odoo.conf" ]; then
      echo "$dir/odoo.conf"
      return
    fi
    dir="$(dirname "$dir")"
  done
  [ -f "/odoo.conf" ] && echo "/odoo.conf"
}

odo_get_conf() {
  local conf="$1" key="$2"
  grep -E "^[[:space:]]*${key}[[:space:]]*=" "$conf" | head -1 | sed -E "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*//; s/[[:space:]]*$//"
}

odo_set_conf() {
  local conf="$1" key="$2" val="$3"
  if grep -qE "^[[:space:]]*${key}[[:space:]]*=" "$conf"; then
    sed -i -E "s|^([[:space:]]*)${key}[[:space:]]*=.*|\1${key} = ${val}|" "$conf"
  else
    printf '%s = %s\n' "$key" "$val" >> "$conf"
  fi
  echo "odoolog: $conf -> $key = $val (restart odoo to apply)"
}

odo_log_file() {
  local conf="$1" f
  f="$(odo_get_conf "$conf" logfile)"
  [ -n "$f" ] && echo "$f"
}
