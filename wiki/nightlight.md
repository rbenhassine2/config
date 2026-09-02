# Night light (redshift)

`redshift` adjusts the screen color temperature at night. This setup uses a
simple on/off toggle (no location-based daemon) via `~/.local/bin/nightlight.sh`.

## Usage

| Action | Command |
| --- | --- |
| Toggle | `Mod+Shift+t` |
| On (4500K) | `nightlight.sh on` |
| Off | `nightlight.sh off` |

`on` applies `redshift -P -O 4500` (4500K) and remembers the state in
`~/.local/state/nightlight`; `off` resets with `redshift -x`. A dunst OSD
notification (`-r 9998`) confirms the change.

> Redshift prints a harmless "could not connect to Wayland" line before falling
> back to the `randr` method on X11.
