# dotfiles

Personal dotfiles and Linux workstation configuration, managed as a bare Git
repository using the classic [Atlassian dotfiles pattern](https://www.atlassian.com/git/tutorials/dotfiles).

The repository is a bare repo at `~/.cfg` whose working tree is `$HOME`, so the
files it tracks *are* your live config. Cloning it to a new machine reproduces
the whole environment.

## What's inside

| Area | Component |
| --- | --- |
| Window manager | [i3](wiki/i3.md) with vi-style navigation, icon workspaces, scratchpad, autotiling |
| Displays | [External/internal switching + fallback watchdog](wiki/displays.md) |
| Status bar | [polybar](wiki/polybar.md) (CPU, temp, memory, disk, network, volume, battery) |
| Launchers | [rofi](wiki/rofi.md) (apps, window, run, emoji) with a One Dark theme |
| Notifications | [dunst](wiki/dunst.md) + OSD from volume / night light |
| Compositor | [picom](wiki/picom.md) (shadows, rounded corners, transparency) |
| Clipboard | [copyq](wiki/clipboard.md) history |
| Night light | [redshift](wiki/nightlight.md) toggle |
| Volume | [volume.sh](wiki/volume.md) with on-screen display |
| Power | [system menu + lock](wiki/power-lock.md) (i3lock, xss-lock, idle lock) |
| Boot/apps | [autostart apps & services](wiki/autostart-apps.md) |
| Theming | [One Dark palette, fonts, wallpaper](wiki/theming.md) |
| Graphics | [nVidia proprietary driver guide](wiki/nvidia.md) |
| Dotfiles workflow | [Bare repo mechanics, docs, editing](wiki/dotfiles-workflow.md) |

## Install on a new machine

```sh
bash ~/.config/me/setup.sh
```

`setup.sh` installs the base tooling, clones this repo into `~/.cfg`, checks out
the config, and enables the systemd user service (display watchdog).

## Documentation

All component docs live in the [`wiki/`](wiki/index.md) folder.
