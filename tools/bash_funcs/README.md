# bash_funcs

Reusable bash functions auto-sourced by `.bashrc`. Every `.sh` file in this
directory defines one or more shell functions; they are available in every new
shell. Run any function with `--help` (or `-h`) to see its usage inline.

`pg_init` and `pglog` need PostgreSQL tooling on `PATH`; the audio splitters need
`ffmpeg` (and `ffprobe`/`jq` where noted).

---

## git helpers

### `gca`
Stage everything and open the commit message editor.

```
gca
```

Runs `git add .`, then `git commit -a`.

### `gcam`
Stage everything and commit with a message.

```
gcam <message>
```

Runs `git add .`, then `git commit -am "<message>"`. Errors out without a message.

### `gcamc`
Stage everything and commit with an auto-generated timestamp message.

```
gcamc
```

Runs `git add .`, then `git commit -am "checkpoint <ISO-8601 timestamp>"`.

---

## benchmarking

### `benchmark`
Time a shell command across several runs and print statistics.

```
benchmark <command> [iterations]
```

| Argument   | Description                       | Default |
|------------|-----------------------------------|---------|
| `command`  | Shell command to time (quote it if it contains spaces) | — |
| `iterations` | Number of runs               | `10`    |

Output: per-run timings, then average, min, max, and range.

```
$ benchmark 'curl -s http://localhost:8069' 5
Benchmarking: curl -s http://localhost:8069
...
Average: 0.134200 seconds
```

---

## PostgreSQL

### `pg_init`
Recreate the local dev PostgreSQL cluster under `~/pg/server`.

```
pg_init
```

Stops the running server, deletes the data directory, runs `initdb` with trust
auth, writes a performance-tuned `postgresql.conf` (NVMe, statement logging,
parallelism, JIT off), and starts the server again with `pg_start`.

- Port: `45000`, unix socket: `/home/atp/pg/server`
- **WARNING:** destroys all data in the current cluster.

### `pglog`
Toggle and read PostgreSQL statement logging for a database.

```
pglog {on|off|status|truncate|tail|grep} <db> [pattern]
```

| Command          | Description |
|------------------|-------------|
| `on <db>`        | Set `log_statement=all` (applies to new connections; existing sessions must reconnect) |
| `off <db>`       | Set `log_statement=none` |
| `status <db>`    | Show the current `log_statement` setting |
| `truncate`       | Empty the active postgres log in place; the running server keeps appending (no restart needed) |
| `tail <db> [pat]`| Live-follow the postgres log, keeping only that database's lines (optionally matching `[pat]`) |
| `grep <db> [pat]`| Search all rotated log files for that database (default pattern: `ERROR`) |

Logs live under `/var/log/postgresql` (root-owned, uses `sudo`). Override the
log path with the `PGLOG_FILE` environment variable.

```
$ pglog on mydb
$ pglog grep mydb 'ERROR' | tail -n 1
$ pglog truncate
```

`truncate` empties the currently-active log file in place (`truncate -s 0`), so
Postgres keeps writing to the same file without a restart. Only the active log
is affected; rotated `*.log.1` files are left intact.

---

## Odoo

### `odoolog`
Toggle and read Odoo logging for the project you are working in.

```
odoolog {on|off|level|handler|show|clear|tail|grep} [value]
```

The `odoo.conf` is located by walking up from the current directory, so the
function always targets the project you are `cd`'d into. Only the `log_level`
and `log_handler` lines are edited; changes apply after restarting Odoo.

| Command            | Description |
|--------------------|-------------|
| `on`               | Set `log_level = debug` (verbose) |
| `off`              | Set `log_level = info` (quiet) |
| `level <lvl>`      | Set `log_level`: `debug` \| `info` \| `warn` \| `error` \| `critical` |
| `handler '<expr>'` | Set `log_handler`, e.g. `odoo.addons.sale:DEBUG` for per-module debug without the full flood |
| `show`             | Print the conf path, current level, handler, and logfile |
| `clear`            | Truncate the log file (run before starting Odoo for a fresh log) |
| `tail [pattern]`   | Live-follow the log (`less +F`); filter lines by pattern |
| `grep [pattern]`   | Search the log (default pattern: `ERROR`) |

Environment overrides: `ODOO_CONF` (conf path) and `ODOO_LOG` (log path).

```
$ odoolog show
conf:    /home/user/odoo19/odoo.conf
level:   info
handler: :INFO
logfile: /home/user/odoo19/logs.log
```

---

## Remote sessions

### `rejoin`
Reopen a remote coding session: switch to the session's own i3 workspace
(tabbed layout) and open one kitty window per configured "window". Each kitty
window SSHes to the server and attaches to its tmux session; sessions that do
not exist yet are created (optionally `cd`'d to a working dir and running a
startup command once). Re-running `rejoin` replaces the kitty tabs — the tmux
sessions live on the server, so their state survives.

```
rejoin                     # list available sessions
rejoin <session>           # reopen the session
rejoin -H <user@host> <session>
rejoin --new <session>     # shorthand for newsession
rejoin --fg <session>      # run in the foreground (debugging)
```

Session configs live in `~/.config/me/sessions/<name>`. They are tracked by the
dotfiles repo, so the same sessions are available on every machine. `<session>`
tab-completes from that directory.

Config syntax (comments must start on their own line):

| Line                          | Description                                             |
|-------------------------------|---------------------------------------------------------|
| `host=user@host`              | Optional SSH destination override                       |
| `key=/path/to/key`            | Optional SSH key override (blank to use ssh-agent/config) |
| `ws=<number>` or `ws=<name>`  | i3 workspace to open the session in (default: a workspace named after the session; e.g. `ws=11` or `ws=11:  Odoo`) |
| `window <label> <tmux> [cwd] [cmd...]` | One kitty/tmux window                      |

- `label` — kitty window title (permanently fixed, so tmux can't overwrite it).
- `tmux` — tmux session to attach-or-create on the server.
- `cwd` — working dir for a *freshly created* session; use `-` to give a
  command without a cwd; omit for neither.
- `cmd` — run once, only when the session is first created (e.g. `nvim`,
  `./dev-server.sh`, `tail -f`). It is typed into a real shell pane, so your
  remote `.bashrc` `PATH` applies.

```
# ~/.config/me/sessions/odoo
host=atp@51.222.241.191
ws=11:  Odoo
window editor odoo-nvim ~/projects/odoo nvim
window run    odoo-run  ~/projects/odoo ./dev-server.sh
window logs   odoo-log  ~/projects/odoo tail -f ~/projects/odoo/logs/app.log
window shell  odoo-shell ~/projects/odoo
```

Defaults (override per file or with `-H`/`--key`): host `atp@51.222.241.191`,
key `~/.ssh/raouf-bhs0806b01c`, plus `ServerAliveInterval=60
ServerAliveCountMax=3`.

### `newsession`
Interactively scaffold a session config (prompts for host, then one window at
a time: label, tmux session, working dir, startup command).

```
newsession <name>
```

Requires `kitty` + `i3` on this machine and `tmux` on the remote server.

---

## Audio splitters

All splitters work on files in the current directory, convert with `ffmpeg`, and
remove the source files on success. Each accepts `--dir-name true|false` to
prefix outputs with the current directory name.

### `m4bsplt`
Convert the **first** `.m4b` file to MP3, split into 5-minute segments
(`000.mp3`, `001.mp3`, ...). Removes non-MP3 files in the directory on success.

```
m4bsplt [--dir-name true|false]
```

### `m4bchsplt`
Convert **every** `.m4b` file to MP3. Files ≤5 minutes are renamed to MP3;
longer files are split into 5-minute segments (`<prefix>-001.mp3`, ...).
Removes the original `.m4b` files on success.

```
m4bchsplt [--dir-name true|false]
```

Requires `ffmpeg` and `ffprobe`.

### `m4btochsplt`
Split the **first** `.m4b` file by its chapters into `chapter_001.m4b`,
`chapter_002.m4b`, ..., then convert the result to MP3 segments (delegates to
`m4bchsplt`). Falls back to `m4bsplt` when the file has no chapters.

```
m4btochsplt [--dir-name true|false]
```

Requires `ffmpeg`, `ffprobe`, `jq`.

### `mp3splt`
Convert the **first** `.mp3` file to Opus (libopus), split into 5-minute
segments (`000.opus`, `001.opus`, ...). Removes the original file on success.

```
mp3splt [--dir-name true|false] [--bitrate <bitrate>]
```

| Option                 | Description                        | Default |
|------------------------|------------------------------------|---------|
| `--dir-name true\|false` | Prefix segments with the directory name | `false` |
| `--bitrate <bitrate>`  | Opus bitrate (`46k`, `64k`, `128k`) | `46k` |

### `mp3chsplt`
Convert **every** `.mp3` file to Opus, split into 5-minute segments
(`<prefix>-001.opus`, ...); a single-segment result drops the `-001` suffix.
Removes the original `.mp3` files on success.

```
mp3chsplt [--dir-name true|false] [--bitrate <bitrate>]
```

Options as `mp3splt`. Requires `ffmpeg`.

### `mp3tochsplt`
Split the **first** `.mp3` file by its chapters into `chapter_001.mp3`,
`chapter_002.mp3`, ..., then convert the result to Opus segments (delegates to
`mp3chsplt`). Falls back to `mp3splt` when the file has no chapters.

```
mp3tochsplt [--dir-name true|false]
```

Requires `ffmpeg`, `ffprobe`, `jq`.
