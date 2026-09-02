# rofi launcher

Rofi is used for application launching, window switching, command running and
emoji picking, with a custom One Dark theme.

## Files

- `~/.config/rofi/config.ini` - global config + theme reference.
- `~/.config/rofi/themes/onedark.rasi` - the theme.

## Modes

| Binding | Mode | What it shows |
| --- | --- | --- |
| `Mod+d` | `drun` | installed applications (`.desktop` files) |
| `Mod+])` | `drun` | same as above |
| `Mod+Tab` | `window` | open windows |
| `Mod+bracketright` | `run` | executables on `$PATH` |
| `Mod+.` | `emoji` | emoji picker |

> Note: only `drun` lists `.desktop` apps like Hubstaff; `run` only shows PATH
> binaries. Keep app launching on `drun`.

## Theme notes

- Variables are defined in the `*` block and referenced with `@name`.
- Rofi 1.7 uses `border` + `border-color` (the `border: 1px solid ...` shorthand
  is not supported).
- The theme matches the One Dark palette used across i3/polybar/dunst (see
  [theming.md](theming.md)).

## Troubleshooting

If an app is missing from `drun`, its `.desktop` file is usually malformed.
A common cause is a non-standard `Exec` (e.g. a quoted path or extra bogus keys
like `Value=1.0`). Validate with:

```sh
desktop-file-validate ~/.local/share/applications/<app>.desktop
```

Then clear the cache and re-check:

```sh
rm -f ~/.cache/rofi3.druncache
rofi -show drun
```

(Transient `GLib-CRITICAL g_string_insert_len / g_markup_escape_text` messages
are a harmless rofi 1.7.5 icon-loading quirk and do not affect the list.)
