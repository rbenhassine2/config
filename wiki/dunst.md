# dunst notifications

`dunst` is the notification daemon. Config: `~/.config/dunst/dunstrc`.

## Settings

- Top-right, offset below the bar, 300px wide, 8px corner radius.
- One Dark background/frame, with urgency colors:
  - low: foreground `#abb2bf`
  - normal: foreground `#dfe1e8`, highlight `#61afef`
  - critical: red background, white text, no timeout
- Font: `Hurmit Nerd Font Mono 10`.
- **Hex colors must be quoted** (`"#3b4252"`), otherwise dunst parses them as empty.

## Shortcuts

| Keys | Action |
| --- | --- |
| `Ctrl+Space` | close current notification |
| `Ctrl+Shift+Space` | close all |
| `Ctrl+`` ` | history |
| `Ctrl+Shift+.` | context menu |

## OSD usage

Two dedicated notification channels are used for on-screen displays:

- `volume` (`dunstify -r 9999`) - volume changes.
- `nightlight` (`dunstify -r 9998`) - night-light toggle.

Dedicated `-r` IDs mean repeated notifications replace each other instead of
stacking.

## CLI

```sh
dunstify -a appname "message"
```
