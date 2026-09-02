# Display management

Handles switching between the internal laptop panel and an external monitor, and
recovers automatically when the external monitor is lost.

## Scripts

| File | Purpose |
| --- | --- |
| `~/.local/bin/displays.sh` | Layout switcher |
| `~/.local/bin/display-watch.sh` | Fallback watchdog daemon |
| `~/.local/bin/boot-display.sh` | Auto-enable external at i3 startup |
| `~/.config/systemd/user/display-watch.service` | Runs the watchdog |

### `displays.sh`

Detects the **internal** output (`eDP-*`/`LVDS-*`/`DSI-*`) and the **external**
output (first connected non-internal output) dynamically - it does not hardcode
`eDP-1`/`HDMI-1-0`, so it survives driver and naming changes.

Modes:

- `external` - external only, primary
- `internal` / `recover` - internal only, primary
- `mirror` - both, same-as
- `extended` - side by side
- `cycle` - rotate through the above

After every switch it restarts polybar so the bar follows the new primary monitor.

### `display-watch.service` (watchdog)

A systemd user service that polls every 2 seconds:

- If the external display goes inactive while the internal is off, it enables the
  internal panel and notifies you to **open the lid** if closed.
- When the external comes back after an automatic fallback, it restores external-only.
- Otherwise it never touches the display, so it never fights manual `cycle` choices.

Enable/start:

```sh
systemctl --user enable --now display-watch.service
```

### `boot-display.sh`

Runs at i3 startup: if any external output is connected, it enables it as primary.
This matches the docked + lid-closed workflow so the external comes up automatically
after every boot.

## autorandr

`autorandr` is installed and a `docked` profile is saved for the current layout.
It is **not** auto-started, to avoid racing the watchdog. Apply it manually:

```sh
autorandr --load docked     # or: autorandr --change
autorandr --save docked     # re-save after changing the layout
```

## Notes

- The watchdog and switcher use `xrandr` only, so they work on both the nouveau
  and nVidia proprietary drivers.
- On the nVidia driver the external output may be named `HDMI-1-0` instead of
  `HDMI-1-1`; the scripts adapt automatically.
