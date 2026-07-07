#!/bin/bash

# Install build tools
r2-d2-pkg-add base-devel

# Configure pacman (always stable mirror)
sudo cp -f ~/.local/share/r2-d2/default/pacman/pacman.conf /etc/pacman.conf
sudo cp -f ~/.local/share/r2-d2/default/pacman/mirrorlist /etc/pacman.d/mirrorlist

# Refresh all repos
sudo pacman -Syyuu --noconfirm
