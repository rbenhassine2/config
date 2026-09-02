# Volume OSD

`~/.local/bin/volume.sh` wraps `pactl` and shows an on-screen notification on
every change, so you get visual feedback instead of guessing.

## Usage

| Key | Action |
| --- | --- |
| `XF86AudioRaiseVolume` | `volume.sh up` (+10%) |
| `XF86AudioLowerVolume` | `volume.sh down` (-10%) |
| `XF86AudioMute` | `volume.sh mute` (toggle) |
| `XF86AudioMicMute` | mute the microphone (no OSD) |

The script queries the current volume/mute state via `pactl` and posts a
`dunstify -r 9999` OSD ("Volume: 45%", "Volume muted").

Works with PipeWire's pulse-compat (`pipewire-pulse`).
