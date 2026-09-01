# nVidia proprietary driver (GTX 1650 Ti Mobile, TU117M)

Your laptop is a PRIME/Optimus machine: the internal panel is driven by the
Intel iGPU and the external HDMI by the nVidia dGPU. These notes cover
switching from the open-source `nouveau` driver to the proprietary driver.

Status on this machine as of 2026-09-01: driver `550.163.01` installed, DKMS
module built, `nouveau` blacklisted, `nvidia-drm.modeset=1` added to GRUB.
**A reboot is required to activate it.** Until you reboot, `nouveau` is still
in use and everything works as before.

## Why it took extra steps (for reference)

- The nVidia driver lives in Debian's `non-free` (+ some helpers in `contrib`).
  Those components were not enabled, so `nvidia-driver` had no candidate.
- Kernel headers were not installed, which would break the DKMS build.

## Install steps (already done here, for fresh machines)

1. Install matching kernel headers:

   ```
   sudo apt install linux-headers-amd64
   ```

2. Add a dedicated sources file so it is easy to remove later:

   ```
   sudo tee /etc/apt/sources.list.d/nvidia.sources
   ```

   Contents (deb822):

   ```
   Types: deb
   URIs: http://deb.debian.org/debian
   Suites: trixie trixie-updates
   Components: contrib non-free
   Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

   Types: deb
   URIs: http://security.debian.org/debian-security
   Suites: trixie-security
   Components: contrib non-free
   Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
   ```

   Then `sudo apt update`.

3. Install:

   ```
   sudo apt install nvidia-driver
   ```

4. **Checkpoint before rebooting** — the DKMS module must be built:

   ```
   dkms status
   find /lib/modules/$(uname -r)/updates/dkms -name 'nvidia-current.ko*'
   ```

   If nothing is present, stop here and roll back (below); the system stays
   on nouveau and nothing breaks.

5. Add kernel param for smooth GDM/tearing-free modesetting:

   ```
   sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet nvidia-drm.modeset=1"/' /etc/default/grub
   sudo update-grub
   sudo update-initramfs -u
   ```

6. Reboot **with the lid open** so the internal panel is a fallback if the
   external does not light up.

## Verify after reboot

```
nvidia-smi            # should show the GTX 1650 Ti
xrandr                # external HDMI-1-1 active again
~/.local/bin/displays.sh cycle        # still switches screens
journalctl --user -u display-watch    # watchdog still fine
```

## Rollback (if anything goes wrong)

```
sudo apt remove --purge nvidia-driver nvidia-kernel-dkms nvidia-settings nvidia-persistenced
sudo rm -f /etc/modprobe.d/nvidia-blacklists-nouveau.conf
sudo rm -f /etc/apt/sources.list.d/nvidia.sources
sudo apt update
sudo apt install --reinstall xserver-xorg-video-nouveau
sudo update-initramfs -u && sudo update-grub
reboot
```

## Notes

- `displays.sh` and the watchdog use `xrandr` only, so they are driver-agnostic.
- The display switcher treats "internal" as any `eDP-*`/`LVDS-*`/`DSI-*` output
  and "external" as the first connected non-internal output; output names may
  change slightly on the nvidia driver but the scripts adapt automatically.
- On an Optimus laptop the default after reboot is PRIME "on-demand" behavior;
  the external monitor routes through the dGPU, the internal panel through the
  iGPU. If you want the dGPU always-on, install `nvidia-prime` and run
  `prime-select on-demand`/`nvidia` as needed.
