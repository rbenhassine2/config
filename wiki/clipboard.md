# Clipboard manager (copyq)

`copyq` keeps a clipboard history with a tray icon. It is started at login via
i3 `exec` and hosts its tray icon in polybar.

## Usage

| Action | How |
| --- | --- |
| Open history | `Mod+Shift+v` (runs `copyq show`) |
| Copy normally | `Ctrl+C` (copyq monitors the clipboard transparently) |
| Paste from history | select an entry in the copyq window |

Config lives in `~/.config/copyq/` (tracked in the dotfiles repo, machine-local
lock/dat files are not).
