# Power menu & screen lock

## Power menu (`system-menu.sh`)

`~/.local/bin/system-menu.sh` opens a rofi menu with **Lock**, **Logout**,
**Suspend**, **Reboot** and **Shutdown**.

| Binding | Action |
| --- | --- |
| `Mod+x` | open the power menu |
| `Mod+Shift+x` | lock immediately (i3lock) |

Actions:

- Lock: `i3lock -c 282c34 -u` (One Dark background, no unlock indicator)
- Logout: `i3-msg exit`
- Suspend: `systemctl suspend`
- Reboot: `systemctl reboot`
- Shutdown: `systemctl poweroff`

## Screen lock

`xss-lock` (started at login) locks on suspend. **Idle lock** is configured via
the X screensaver at login:

```sh
xset s 300; xset s blank; xset dpms 600 600 600
```

After 5 minutes idle the screensaver activates -> `xss-lock` shows `i3lock`.
DPMS powers the displays off at 10 minutes.

> The lid is configured to be ignored in `/etc/systemd/logind.conf`
> (`HandleLidSwitch=ignore`), so closing the lid does **not** suspend.
