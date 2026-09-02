# Theming

A consistent **One Dark** palette is applied across every component.

## Palette

| Variable | Color |
| --- | --- |
| `$bg` / background | `#282c34` |
| `$bg2` / background-alt | `#2f3542` |
| `$fg` / foreground | `#abb2bf` |
| `$fg2` / foreground-alt | `#dfe1e8` |
| `$accent` / primary | `#61afef` (blue) |
| secondary | `#c678dd` (purple) |
| success | `#98c379` (green) |
| warning | `#e5c07b` (yellow) |
| alert / red | `#e06c75` |

## Where each color lives

| Component | Location |
| --- | --- |
| i3 borders/focus | `set $...` variables + `client.focused*` in `.config/i3/config` |
| polybar | `[colors]` section of `~/.config/polybar/config.ini` |
| rofi | `~/.config/rofi/themes/onedark.rasi` |
| dunst | `[urgency_*]` sections of `~/.config/dunst/dunstrc` |

## Fonts

`Hurmit Nerd Font Mono` is used for i3 titles, polybar, rofi, dunst and the
scratchpad. It provides the Nerd Font icons used in workspace names and bar
modules.

## Wallpaper

`~/Pictures/wallpapers/onedark.png` is a generated 1920x1080 vertical gradient
(One Dark top to a slightly darker bottom), applied at login with
`feh --bg-fill`.
