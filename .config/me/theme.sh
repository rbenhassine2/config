#!/usr/bin/env bash
# Enforce dark global/GTK theme for GTK3/GTK4 apps. Idempotent; safe to
# re-run on every i3 start and on a fresh machine after cloning dotfiles.
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
