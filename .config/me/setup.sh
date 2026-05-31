#!/usr/bin/env bash

set -x

# updgrade teh system
sudo apt update
sudo apt upgrade -y

# install dependencies
sudo apt install jq git curl wget gawk build-essential ca-certificates -y

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
