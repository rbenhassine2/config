# Rejoin remote coding sessions.
#
# A "coding session" is a directory of windows: each window is a kitty OS
# window (opened as a tab on its own i3 workspace) that SSHes to a remote
# server and attaches to a tmux session, creating + bootstrapping it on first
# use. Config files live in ~/.config/me/sessions/<name>.

_REJOIN_DIR="${_REJOIN_DIR:-$HOME/.config/me/sessions}"
_REJOIN_DEFAULT_HOST='atp@51.222.241.191'
_REJOIN_DEFAULT_KEY="$HOME/.ssh/raouf-bhs0806b01c"
_REJOIN_SSH_OPTS=(-o ServerAliveInterval=60 -o ServerAliveCountMax=3)

# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------

_rejoin_list_sessions() {
  local f
  [[ -d "$_REJOIN_DIR" ]] || return 0
  for f in "$_REJOIN_DIR"/*; do
    [[ -f $f ]] && printf '%s\n' "${f##*/}"
  done
}

_rejoin_usage() {
  cat <<'EOF'
Usage:
  rejoin                  list available coding sessions
  rejoin <session>        open <session>: switch to its i3 workspace
                          (tabbed) and attach each window's tmux session,
                          creating + bootstrapping ones that don't exist yet
  rejoin --new <session>  shorthand for: newsession <session>
  rejoin --bg <session>    force background (runs in the foreground by default)
  rejoin -H <host> <session>
                          override the SSH host (default atp@51.222.241.191)

Options:
  -h, --help              show this help
  -H, --host <user@host>  SSH destination override
      --key <path>        SSH key override (default ~/.ssh/raouf-bhs0806b01c)
      --new               alias for newsession
      --bg                run in the background (default when rejoin is run
                          from one of the session's own kitty windows)
      --fg                run in the foreground (default; debugging)

Workspace: by default windows open on a workspace named after the session.
Set ws=<number> or ws=<name> (e.g. ws=11:  Odoo) in the session config to pick
the i3 workspace.

Hosts: each session config can set host= and key= for all windows, and any
single window line can override them with inline host=... key=... tokens:
  window <label> <tmux> host=user@host key=~/path ~/proj nvim
Precedence: window token > --host/--key > session host=/key= > defaults.

Completion: <session> tab-completes from ~/.config/me/sessions/*.
EOF
}

_rejoin_validate_name() {
  local name=$1
  if [[ -z $name ]]; then
    echo "rejoin: session name is required" >&2
    return 1
  fi
  if [[ ! $name =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "rejoin: invalid session name '$name' (allowed: A-Z a-z 0-9 . _ -)" >&2
    return 1
  fi
}

# _rejoin_load <file>  populates _REJOIN_HOST/_REJOIN_KEY/_REJOIN_WS and the
# _REJOIN_W_* arrays (label / tmux-session / cwd / cmd / host / key). Config:
#   host=user@host
#   key=/path/to/key
#   ws=11                 i3 workspace number to open the session in
#   ws=11:  Odoo          ...or an explicit workspace name
#   window <label> <tmux-session> [cwd|-] [cmd...]
# A single window can override the host/user/key with inline tokens anywhere on
# its line (they are removed before cwd/cmd are parsed):
#   window <label> <tmux-session> host=user@host key=~/key [cwd|-] [cmd...]
# Precedence per window: window token > --host/--key > session host=/key= >
# script defaults. 'cmd' is run once, only when the tmux session is fresh.
# Comments must start on their own line with '#'.
_rejoin_load() {
  local file=$1 line tokens label tname cwd cmd start tok fhost fkey
  local -a tokens filtered
  _REJOIN_HOST=
  _REJOIN_KEY=
  _REJOIN_WS=
  _REJOIN_W_LABEL=()
  _REJOIN_W_SNAME=()
  _REJOIN_W_CWD=()
  _REJOIN_W_CMD=()
  _REJOIN_W_HOST=()
  _REJOIN_W_KEY=()
  while IFS= read -r line || [[ -n $line ]]; do
    [[ $line =~ ^[[:space:]]*(.*)$ ]] && line=${BASH_REMATCH[1]}
    [[ -z $line || $line == '#'* ]] && continue
    case $line in
      host=*) _REJOIN_HOST=${line#host=} ;;
      key=*) _REJOIN_KEY=${line#key=} ;;
      ws=* | workspace=*) _REJOIN_WS=${line#*=} ;;
      window*)
        read -r -a tokens <<< "${line#window}"
        fhost=
        fkey=
        filtered=()
        for tok in "${tokens[@]}"; do
          case $tok in
            host=*) fhost=${tok#host=} ;;
            key=*) fkey=${tok#key=} ;;
            *) filtered+=("$tok") ;;
          esac
        done
        tokens=("${filtered[@]}")
        ((${#tokens[@]} >= 2)) || { echo "rejoin: bad window line: $line" >&2; continue; }
        label=${tokens[0]}
        tname=${tokens[1]}
        cwd=
        cmd=
        start=2
        if ((${#tokens[@]} >= 3)); then
          [[ ${tokens[2]} != '-' ]] && cwd=${tokens[2]}
          start=3
        fi
        if ((${#tokens[@]} > start)); then
          cmd="${tokens[*]:$start}"
        fi
        _REJOIN_W_LABEL+=("$label")
        _REJOIN_W_SNAME+=("$tname")
        _REJOIN_W_CWD+=("$cwd")
        _REJOIN_W_CMD+=("$cmd")
        _REJOIN_W_HOST+=("$fhost")
        _REJOIN_W_KEY+=("$fkey")
        ;;
    esac
  done < "$file"
}

# _rejoin_payload <tmux-session> <cwd> <cmd>
# Emits a self-contained remote script (base64-encoded on the wire) that
# attaches to the session, or creates it (optionally cd'd and bootstrapped).
# A leading '~' in the cwd is expanded against the *remote* $HOME (tmux -c
# does not expand it). Errors keep the window open instead of closing it.
_rejoin_payload() {
  local tname=$1 cwd=$2 cmd=$3
  local tb64 db64 cb64
  tb64=$(printf '%s' "$tname" | base64 -w0)
  db64=$(printf '%s' "$cwd" | base64 -w0)
  cb64=$(printf '%s' "$cmd" | base64 -w0)
  cat <<EOF
export TERM=xterm-256color
_n=\$(printf '%s' "$tb64" | base64 -d)
_d=\$(printf '%s' "$db64" | base64 -d)
_c=\$(printf '%s' "$cb64" | base64 -d)
_t='~'
if [[ "\${_d:0:1}" == "\$_t" ]]; then _d="\$HOME\${_d:1}"; fi
tmux_bin=\$(command -v tmux 2>/dev/null) || tmux_bin=/usr/bin/tmux
if ! "\$tmux_bin" has-session -t "\$_n" 2>/dev/null; then
  if [[ -n "\$_d" ]]; then
    "\$tmux_bin" new-session -d -s "\$_n" -c "\$_d" 2>/dev/null || "\$tmux_bin" new-session -d -s "\$_n" 2>/dev/null
  else
    "\$tmux_bin" new-session -d -s "\$_n" 2>/dev/null
  fi
  if "\$tmux_bin" has-session -t "\$_n" 2>/dev/null && [[ -n "\$_c" ]]; then
    "\$tmux_bin" send-keys -t "\$_n" "\$_c" Enter
  fi
fi
if ! "\$tmux_bin" attach-session -t "\$_n"; then
  echo "tmux attach failed for session \$_n"
  exec bash
fi
EOF
}

_rejoin_spawn() {
  local session=$1 host=$2 key=$3
  local label=$4 tname=$5 cwd=$6 cmd=$7
  local payload b64 rcmd
  local -a sshcmd
  # local key paths are written as ~/... in configs; expand against $HOME
  [[ $key == '~/'* ]] && key="$HOME${key:1}"
  payload=$(_rejoin_payload "$tname" "$cwd" "$cmd")
  b64=$(printf '%s' "$payload" | base64 -w0)
  # run the script via bash -c "$( … )" so the payload's stdin stays the ssh
  # pty (piping it through `| bash` makes tmux attach fail with "not a
  # terminal"). Command-substitution output is inserted verbatim, so the
  # payload needs no further quoting.
  rcmd="bash -c \"\$(printf '%s' '$b64' | base64 -d)\""
  sshcmd=(ssh)
  [[ -n $key ]] && sshcmd+=(-i "$key")
  sshcmd+=("${_REJOIN_SSH_OPTS[@]}" -t)
  sshcmd+=("$host" "$rcmd")
  kitty --detach \
    --class "rejoin-$session" --name "$label" -T "$label" \
    -e "${sshcmd[@]}"
}

_rejoin_show_list() {
  local s n
  if ! _rejoin_list_sessions | grep -q .; then
    echo "No sessions defined. Create one with: newsession <name>"
    return 0
  fi
  echo "Available sessions:"
  while IFS= read -r s; do
    if [[ -r "$_REJOIN_DIR/$s" ]]; then
      _rejoin_load "$_REJOIN_DIR/$s"
      n=${#_REJOIN_W_LABEL[@]}
    else
      n=0
    fi
    printf '  %-20s (%d windows)\n' "$s" "$n"
  done < <(_rejoin_list_sessions)
}

# ---------------------------------------------------------------------------
# main entry points
# ---------------------------------------------------------------------------

# rejoin [-h|--help] [--fg|--bg] [-H <host>] [--key <path>] [--new] [<session>]
rejoin() {
  local help=0 mode=auto new=0 host= key= session=
  while (($#)); do
    case $1 in
      -h | --help) help=1; shift ;;
      -H | --host) host=$2; shift 2 ;;
      --key) key=$2; shift 2 ;;
      --fg) mode=fg; shift ;;
      --bg) mode=bg; shift ;;
      --new) new=1; shift ;;
      -*) echo "rejoin: unknown option: $1" >&2; return 1 ;;
      *)
        if [[ -z $session ]]; then session=$1; else echo "rejoin: unexpected argument: $1" >&2; return 1; fi
        shift ;;
    esac
  done

  ((help)) && { _rejoin_usage; return 0; }

  if [[ -z $session ]]; then
    _rejoin_show_list
    return 0
  fi

  _rejoin_validate_name "$session" || return 1
  ((new)) && { newsession "$session"; return $?; }

  local conf=$_REJOIN_DIR/$session
  if [[ ! -r $conf ]]; then
    echo "rejoin: no session '$session' ($conf)" >&2
    echo "Create one with: newsession $session" >&2
    return 1
  fi

  # default to background when run from one of the session's own windows
  # (they are about to be killed and respawned, which would cut our shell)
  if [[ $mode == auto ]] && [[ $(_rejoin_focused_class) == "rejoin-$session" ]]; then
    mode=bg
  fi

  if [[ $mode == bg ]]; then
    local log=${TMPDIR:-/tmp}/rejoin-$session.log
    echo "rejoin: opening '$session' in the background (log: $log)"
    ( _rejoin_go "$session" "$host" "$key" >"$log" 2>&1 & )
  else
    _rejoin_go "$session" "$host" "$key"
  fi
}

# _rejoin_focused_class  prints the WM_CLASS of the currently focused i3 window
_rejoin_focused_class() {
  i3-msg -t get_tree 2>/dev/null | python3 -c '
import sys, json
d = json.load(sys.stdin)
def find(n):
    if n.get("focused"):
        return n
    for c in n.get("nodes", []) + n.get("floating_nodes", []):
        r = find(c)
        if r: return r
r = find(d) or {}
print((r.get("window_properties") or {}).get("class", ""))
'
}

# _rejoin_ws_expr <session> <config-ws>
# Prints an i3 workspace expression (usable after "workspace", "workspace number",
# or "move container to workspace"): numeric -> "number N", else -> "<name>".
_rejoin_ws_expr() {
  local ws=${2:-$1}
  if [[ $ws =~ ^[0-9]+$ ]]; then
    printf '%s' "number $ws"
  else
    printf '%s' "\"$ws\""
  fi
}

_rejoin_ws_cmd() {
  # $1: session name, $2: config ws value ("" = use the session name)
  i3-msg "workspace $(_rejoin_ws_expr "$1" "$2"); layout tabbed" >/dev/null 2>&1
}

# _rejoin_count_windows <session>  prints number of live rejoin-<session> windows
_rejoin_count_windows() {
  i3-msg -t get_tree 2>/dev/null | python3 -c '
import sys, json
klass = "rejoin-%s" % sys.argv[1]
d = json.load(sys.stdin)
def walk(n):
    if isinstance(n, dict):
        p = n.get("window_properties") or {}
        if p.get("class") == klass and n.get("name"):
            return 1
        return sum(walk(c) for c in n.get("nodes", []) + n.get("floating_nodes", []))
    return 0
print(walk(d))
' "$1"
}

# _rejoin_clear_windows <session>  close stale windows and wait until they are
# actually gone. i3's `kill` only sends WM_DELETE and can be handled very
# late / not at all by kitty windows attached to a tmux session, so also
# SIGTERM the matching kitty processes (instant) and poll the tree.
_rejoin_clear_windows() {
  local i pids
  for ((i = 0; i < 40; i++)); do
    [[ $(_rejoin_count_windows "$1") == 0 ]] && return 0
    i3-msg "[class=\"rejoin-$1\"] kill" >/dev/null 2>&1
    pids=$(pgrep -f "^kitty --detach --class rejoin-$1" 2>/dev/null)
    if [[ -n $pids ]]; then
      kill -TERM $pids 2>/dev/null
    fi
    sleep 0.25
  done
  # last resort
  pids=$(pgrep -f "^kitty --detach --class rejoin-$1" 2>/dev/null)
  [[ -n $pids ]] && kill -KILL $pids 2>/dev/null
  sleep 0.5
}

_rejoin_go() {
  local session=$1 host=$2 key=$3
  local conf=$_REJOIN_DIR/$session
  local expr n i

  _rejoin_validate_name "$session" || return 1
  _rejoin_load "$conf"

  host=${host:-${_REJOIN_HOST:-$_REJOIN_DEFAULT_HOST}}
  key=${key:-${_REJOIN_KEY:-$_REJOIN_DEFAULT_KEY}}
  [[ -n $host ]] || { echo "rejoin: no host configured for '$session'" >&2; return 1; }

  n=${#_REJOIN_W_SNAME[@]}
  if ((n == 0)); then
    echo "rejoin: session '$session' has no 'window' lines in $conf" >&2
    return 1
  fi

  expr=$(_rejoin_ws_expr "$session" "$_REJOIN_WS")
  echo "rejoin: opening '$session' — $n window(s) on workspace $expr"

  _rejoin_ws_cmd "$session" "$_REJOIN_WS"
  # drop stale windows from a previous run (tmux state lives on the server)
  _rejoin_clear_windows "$session"
  _rejoin_ws_cmd "$session" "$_REJOIN_WS"

  local expected=0
  for ((i = 0; i < n; i++)); do
    local whost wkey
    # per-window host=/key= override, else the session/CLI/default resolution
    whost=${_REJOIN_W_HOST[$i]:-$host}
    wkey=${_REJOIN_W_KEY[$i]:-$key}
    echo "rejoin: launching kitty tab '${_REJOIN_W_LABEL[$i]}' -> tmux ${_REJOIN_W_SNAME[$i]} (${whost})"
    _rejoin_spawn "$session" "$whost" "$wkey" \
      "${_REJOIN_W_LABEL[$i]}" "${_REJOIN_W_SNAME[$i]}" \
      "${_REJOIN_W_CWD[$i]}" "${_REJOIN_W_CMD[$i]}"
    ((expected++))
    # kitty maps windows asynchronously; wait for this one to appear before
    # opening the next so the tab order matches the config order.
    for ((t = 0; t < 24; t++)); do
      [[ $(_rejoin_count_windows "$session") -ge $expected ]] && break
      sleep 0.25
    done
  done

  # kitty maps windows asynchronously, and a freshly opened one lands on
  # whatever workspace is focused at that instant (so if rejoin is started
  # from another workspace, windows can briefly appear there). Poll until all
  # windows have mapped, moving any that appear onto the target workspace.
  for ((i = 0; i < 20; i++)); do
    i3-msg "[class=\"rejoin-$session\"] move container to workspace $expr" >/dev/null 2>&1
    [[ $(_rejoin_count_windows "$session") -ge $n ]] && break
    sleep 0.3
  done

  # focus the session and re-group as tabs (autotiling may have split things)
  i3-msg "workspace $expr; layout tabbed" >/dev/null 2>&1
  echo "rejoin: done."
}

# newsession [<name>]  interactively scaffold a session config
newsession() {
  local name=$1 host key ws label tname cwd cmd more yes
  _rejoin_validate_name "$name" || return 1
  local conf=$_REJOIN_DIR/$name
  if [[ -e $conf ]]; then
    echo "newsession: '$name' already exists ($conf)" >&2
    return 1
  fi

  read -rp "SSH host [$_REJOIN_DEFAULT_HOST]: " host
  host=${host:-$_REJOIN_DEFAULT_HOST}
  read -rp "SSH key [$_REJOIN_DEFAULT_KEY] (blank for none): " key
  key=${key:-$_REJOIN_DEFAULT_KEY}
  read -rp "i3 workspace number or name (blank = session name): " ws

  mkdir -p "$_REJOIN_DIR"
  {
    echo "# coding session: $name"
    echo "# rejoin reads this file; comments must start on their own line"
    echo "# window syntax:"
    echo "#   window <label> <tmux-session> [cwd|-] [cmd...]"
    echo "#   label      -> kitty tab/window title"
    echo "#   tmux-session -> tmux session to attach-or-create on the server"
    echo "#   cwd        -> working dir for a freshly created session ('-' to skip)"
    echo "#   cmd        -> run once when the session is first created"
    echo "#   optional per-window override: add host=user@host and/or key=path"
    echo "#     tokens anywhere on the window line, e.g.:"
    echo "#     window <label> <tmux> host=user@host key=~/key [cwd|-] [cmd...]"
    echo "# workspace: ws=<number> or ws=<name> (e.g. ws=11:  Odoo); default: session name"
    echo "host=$host"
    echo "key=$key"
    [[ -n $ws ]] && echo "ws=$ws"
    echo
  } > "$conf"

  echo "Now add windows to $name (blank label to finish):"
  more=1
  while ((more)); do
    read -rp "  label (e.g. editor)        : " label
    [[ -z $label ]] && break
    read -rp "  tmux session (e.g. ${name}-code): " tname
    tname=${tname:-${name}-${label}}
    read -rp "  working dir (blank for none): " cwd
    cwd=${cwd:--}
    read -rp "  startup cmd  (blank for none): " cmd
    echo "window $label $tname $cwd${cmd:+ $cmd}" >> "$conf"
    read -rp "  add another window? [Y/n]: " yes
    [[ ${yes,,} == n ]] && more=0
  done

  if ! grep -q '^window ' "$conf"; then
    echo "newsession: no windows added; removing empty config" >&2
    rm -f "$conf"
    return 1
  fi

  echo "Created $conf"
  echo "Rejoin it with: rejoin $name"
}

# ---------------------------------------------------------------------------
# completion
# ---------------------------------------------------------------------------

_rejoin_complete() {
  local cur=$2
  local s
  COMPREPLY=()
  if [[ $cur == -* ]]; then
    COMPREPLY=( $(compgen -W '--help --new --bg --fg --host' -- "$cur") )
    return 0
  fi
  while IFS= read -r s; do
    [[ $s == "$cur"* ]] && COMPREPLY+=("$s")
  done < <(_rejoin_list_sessions)
}

complete -F _rejoin_complete rejoin newsession
