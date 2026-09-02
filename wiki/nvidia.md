# nVidia proprietary driver

This laptop is PRIME/Optimus: the internal panel is driven by the Intel iGPU and
the external HDMI by an nVidia GTX 1650 Ti Mobile. The proprietary driver
(550.x) is installed with `nouveau` blacklisted.

The full, reversible install/rollback guide is at
[`docs/nvidia-driver.md`](../docs/nvidia-driver.md).

## Quick facts

- Driver: `nvidia-driver` 550.163.01 (from Debian `non-free`/`contrib`).
- Kernel module: `nvidia-current` via DKMS (built for the installed kernel).
- Boot: `nvidia-drm.modeset=1` added to the kernel command line.
- External output on this driver is named **`HDMI-1-0`** (was `HDMI-1-1`).
- `displays.sh`, the watchdog and `boot-display.sh` are driver-agnostic (they
  use `xrandr`), so display switching is unchanged.

## Verify

```sh
nvidia-smi
xrandr | grep connected
```

## Rollback

```sh
sudo apt remove --purge nvidia-driver nvidia-kernel-dkms nvidia-settings nvidia-persistenced
sudo rm -f /etc/modprobe.d/nvidia-blacklists-nouveau.conf /etc/apt/sources.list.d/nvidia.sources
sudo apt update && sudo apt install --reinstall xserver-xorg-video-nouveau
sudo update-initramfs -u && sudo update-grub
```
