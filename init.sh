#!/bin/sh

# Universal linux zsh installation
/usr/bin/env zsh --version || \
sudo apt update && sudo apt install zsh -y 2>/dev/null || \
sudo dnf install zsh -y 2>/dev/null || \
sudo yum install zsh -y 2>/dev/null || \
sudo pacman -Sy zsh --noconfirm 2>/dev/null || \
sudo zypper in -y zsh 2>/dev/null || \
sudo apk add zsh 2>/dev/null

chsh -s $(which zsh)
curl https://mise.run/zsh | sh
curl https://raw.githubusercontent.com/timabrmsn/config/refs/heads/main/mise.toml -o ~/.config/mise.toml
mise run sync
