#!/bin/bash

echo "Install Quickshell and switch the desktop shell off Waybar, Mako, SwayOSD, and Hyprlock"

r2-d2-pkg-add quickshell

if [[ -x ${R2D2_PATH:-$HOME/.local/share/r2-d2}/bin/r2-d2-apply-lock ]]; then
  r2-d2-apply-lock || true
fi

for pkg in waybar mako swayosd hyprlock; do
  if pacman -Q "$pkg" >/dev/null 2>&1; then
    sudo pacman -Rns --noconfirm "$pkg" || true
  fi
done
