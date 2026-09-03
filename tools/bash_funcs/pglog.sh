pglog() {
  local action="${1:-}"
  local db="${2:-}"
  local pat="${3:-}"
  local logfile="${PGLOG_FILE:-}"

  case "$action" in
    --help|-h)
      echo "Usage: pglog {on|off|status|truncate|tail|grep} <db> [pattern]"
      echo
      echo "Toggle and read PostgreSQL statement logging for a database."
      echo "Logs live under /var/log/postgresql (root-owned; sudo is used)."
      echo
      echo "Commands:"
      echo "  on <db>          Set log_statement=all on the database (new connections"
      echo "                   only; existing sessions must reconnect)."
      echo "  off <db>         Set log_statement=none."
      echo "  status <db>      Show the current log_statement setting."
      echo "  truncate         Empty the active postgres log in place; the running"
      echo "                   server keeps appending (no restart needed)."
      echo "  tail <db> [pat]  Live-follow the postgres log, keeping only lines from"
      echo "                   that database (and matching [pat] if given)."
      echo "  grep <db> [pat]  Search all rotated log files for that database;"
      echo "                   default pattern is ERROR."
      echo
      echo "Environment:"
      echo "  PGLOG_FILE       Override the postgres log file path."
      echo
      echo "Example:"
      echo "  pglog on mydb"
      echo "  pglog grep mydb 'ERROR' | tail -n 1"
      return 0
      ;;
    on|off)
      [ -z "$db" ] && { echo "usage: pglog $action <db>"; return 1; }
      local val="all"; [ "$action" = "off" ] && val="none"
      sudo -u postgres psql -tAc "ALTER DATABASE \"$db\" SET log_statement = '$val';"
      echo "log_statement='$val' set on db '$db' (applies to new connections; existing sessions must reconnect)"
      ;;
    status)
      [ -z "$db" ] && { echo "usage: pglog status <db>"; return 1; }
      sudo -u postgres psql -d "$db" -tAc "SHOW log_statement;"
      ;;
    truncate)
      [ -z "$logfile" ] && logfile="$(pg_log_file)"
      [ -z "$logfile" ] && { echo "could not locate postgres log file (override with PGLOG_FILE)"; return 1; }
      local owner; owner="$(sudo stat -c '%U' "$logfile")"
      [ -z "$owner" ] && owner=postgres
      sudo -u "$owner" truncate -s 0 "$logfile" || { echo "failed to truncate $logfile" >&2; return 1; }
      echo "truncated $logfile (server keeps appending; no restart needed)"
      ;;
    tail|grep)
      [ -z "$db" ] && { echo "usage: pglog $action <db> [pattern]"; return 1; }
      [ -z "$logfile" ] && logfile="$(pg_log_file)"
      [ -z "$logfile" ] && { echo "could not locate postgres log file (override with PGLOG_FILE)"; return 1; }
      [ "$action" = "grep" ] && [ -z "$pat" ] && pat="ERROR"
      local prog='
        /^[0-9]{4}-[0-9]{2}-[0-9]{2}/ {
          cur = $1 " " $2 " " $3
          if (index($0, db) > 0) {
            if (pat == "" || index($0, pat) > 0) { keep = 1; ts = cur; print }
            else if (keep && cur == ts) print
            else keep = 0
          } else keep = 0
          fflush()
          next
        }
        keep { print; fflush() }
      '
      if [ "$action" = "tail" ]; then
        sudo tail -F "$logfile" | gawk -v db="@$db " -v pat="$pat" "$prog"
      else
        local files; files="$(sudo ls "$logfile"* 2>/dev/null)"
        [ -n "$files" ] || { echo "no log files found at: $logfile"; return 1; }
        sudo gawk -v db="@$db " -v pat="$pat" "$prog" $files
      fi
      ;;
    *)
      echo "usage: pglog {on|off|status|truncate|tail|grep} <db> [pattern]"
      ;;
  esac
}

pg_log_file() {
  if command -v pg_lsclusters >/dev/null 2>&1; then
    local f
    f="$(pg_lsclusters -h 2>/dev/null | awk '$4 == "online" {print "/var/log/postgresql/postgresql-"$1"-main.log"}' | head -1)"
    [ -n "$f" ] && { echo "$f"; return; }
  fi
  sudo ls /var/log/postgresql/postgresql-*-main.log 2>/dev/null | head -1
}
