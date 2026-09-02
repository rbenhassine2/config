# picom compositor

`picom` provides compositing effects. Config: `~/.config/picom/picom.conf`
(picom v12+ format).

Started at login via i3 `exec --no-startup-id picom --config ~/.config/picom/picom.conf`.

## Effects

- **Shadows** - soft drop shadows, excluded for dunst/polybar/rofi/docks.
- **Fading** - windows fade in/out.
- **Opacity** - inactive windows at 97%, active at 100%.
- **Rounded corners** - 8px radius with border rounding.

## Notes

- `vsync` is disabled (the GPU handles it); enable if you see tearing.
- The `GLib` / shadow-exclude patterns keep panels and notifications from
  casting shadows onto the bar.
