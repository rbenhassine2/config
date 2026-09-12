#!/usr/bin/env bash

install_incus=false

while [[ $# -gt 0 ]]; do
  case "$1" in
  --install-incus)
    install_incus=true
    shift
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

# updgrade teh system
sudo apt update
sudo apt upgrade -y

# install dependencies
sudo apt install i3 jq git curl wget gawk build-essential ca-certificates btop ffmpeg zstd dunst polybar autorandr rofi picom i3lock feh copyq redshift blueman -y

# download and setup config.
# Copied from https://www.atlassian.com/git/tutorials/dotfiles
echo ".cfg" >>.gitignore
git clone --bare https://github.com/rbenhassine2/config.git $HOME/.cfg
function config {
  /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}
mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
  echo "Checked out config."
else
  echo "Backing up pre-existing dot files."
  config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi
config checkout
config config status.showUntrackedFiles no

# Keep README + wiki out of $HOME (tracked in repo, visible on GitHub)
config update-index --skip-worktree README.md $(config ls-files 'wiki/*')
rm -rf $HOME/README.md $HOME/wiki

# install bashit
# Copied from https://github.com/bash-it/bash-it#installation
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash_it/install.sh --no-modify-config

# install blesh
# Copied from https://github.com/akinomyoga/ble.sh
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local

source $HOME/.bashrc

# install astral uv
# Copied from https://docs.astral.sh/uv/getting-started/installation/
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
config checkout -- ~/.bashrc

uv python install 3.11 3.12 3.13 3.14

uv tool install pyrefly
uv tool install ruff
uv tool install alembic

# Install zvm (Zig Version Manager)
# Copied from https://www.zvm.app/
curl https://www.zvm.app/install.sh | bash
ZVM_INSTALL="$HOME/.zvm/self"
PATH="$PATH:$HOME/.zvm/bin"
PATH="$PATH:$ZVM_INSTALL/"

zvm install --zls master
zvm install --zls 0.14.0
zvm install --zls 0.15.1
zvm install --zls 0.16.0

# Install rust
# Copied from https://rust-lang.github.io/rustup/installation/other.html
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install Go
VERSION=$(curl -fsSL https://go.dev/dl/?mode=json | jq -r '.[0].version')
ARCHIVE="$VERSION.linux-amd64.tar.gz"
URL="https://go.dev/dl/$ARCHIVE"
curl -fL -o $ARCHIVE $URL
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf $ARCHIVE
rm $ARCHIVE

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

export NVM_DIR="${HOME}/.nvm"
. "$NVM_DIR/nvm.sh"

nvm install --lts
nvm alias default lts/*
npm install -g npm@latest

# Install antigrivity
curl -fsSL https://antigravity.google/cli/install.sh | bash

# Install opencode
curl -fsSL https://opencode.ai/install | bash

# Install ollama
curl -fsSL https://ollama.com/install.sh | sh

# Install gh (GitHub CLI)
# Copied from https://github.com/cli/cli/blob/trunk/docs/install_linux.md
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y) ) &&
  sudo mkdir -p -m 755 /etc/apt/keyrings &&
  out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg &&
  cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
  sudo mkdir -p -m 755 /etc/apt/sources.list.d &&
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
  sudo apt update &&
  sudo apt install gh -y

# configure git
git config --global user.name "Raouf Ben Hassine"
git config --global user.email "raouf.benhassine@proton.me"

# Install incus
if $install_incus; then
  sudo apt install incus
  sudo adduser $USER incus-admin
  newgrp incus-admin
fi

# install autotiling (auto split orientation for i3)
uv tool install autotiling

# Install Brave only on a graphical (non-server) session
case "${XDG_SESSION_TYPE:-}" in
x11 | wayland)
  echo "Graphical session detected, installing Brave."
  curl -fsS https://dl.brave.com/install.sh | sh
  ;;
*)
  echo "No graphical session detected (${XDG_SESSION_TYPE:-unset}); skipping Brave."
  ;;
esac

# Restore tracked shell environment files. uv/rustup/antigravity append their
# own PATH hooks to ~/.profile and ~/.bashrc; ~/.config/me/env.sh is the single
# source of truth now, so force the tracked versions back.
config checkout -- ~/.profile ~/.bashrc
config checkout -- ~/.config/me/env.sh

# enable display watchdog (systemd user service)
chmod +x "$HOME/.local/bin/displays.sh" "$HOME/.local/bin/display-watch.sh"
chmod +x "$HOME/.local/bin/system-menu.sh" "$HOME/.local/bin/polybar-launch.sh" "$HOME/.local/bin/boot-display.sh" "$HOME/.local/bin/docs-edit.sh"
mkdir -p "$HOME/.config/systemd/user"
systemctl --user daemon-reload
systemctl --user enable display-watch.service

# install nim
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
