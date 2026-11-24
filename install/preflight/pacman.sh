#!/bin/bash

# Install build tools
r2-d2-pkg-add base-devel

# Configure pacman (always stable mirror)
sudo cp -f ~/.local/share/r2-d2/default/pacman/pacman.conf /etc/pacman.conf
sudo cp -f ~/.local/share/r2-d2/default/pacman/mirrorlist /etc/pacman.d/mirrorlist

# Refresh signing keys first: a stale keyring (common with older install ISOs)
# aborts every transaction with "signature is unknown trust" — same order as
# r2-d2-update-perform.
sudo pacman -Sy --noconfirm archlinux-keyring

# Refresh all repos
sudo pacman -Syyuu --noconfirm
