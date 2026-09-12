# ~/.profile: executed by the command interpreter for login shells and by the
# GDM Xsession for the GUI session. Sourced for non-interactive use (dash/sh),
# so only POSIX-safe environment setup lives here.

# Shared environment (PATH, toolchains) — single source of truth, also read by
# ~/.bashrc for interactive shells.
if [ -f "$HOME/.config/me/env.sh" ]; then
  . "$HOME/.config/me/env.sh"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# if running bash, load interactive setup for real terminal logins
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi
fi

export PATH=/home/raouf/.nimble/bin:$PATH
