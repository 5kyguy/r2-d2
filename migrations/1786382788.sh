#!/bin/bash

echo "Replace hyprland-preview-share-picker with AUR hyprland-preview-share-picker-git"

# Non-git package name left the AUR; keep the binary via the -git package.
if pacman -Q hyprland-preview-share-picker &>/dev/null; then
  sudo pacman -R --noconfirm hyprland-preview-share-picker 2>/dev/null || true
fi

r2-d2-pkg-aur-add hyprland-preview-share-picker-git || true
