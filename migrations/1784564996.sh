#!/bin/bash

echo "Disable Caps Lock: Caps key is Super only (keyd); XKB caps:none"

# Redeploy keyd config (default/ is not synced by normal update).
sudo mkdir -p /etc/keyd
sudo cp "$R2D2_PATH/default/keyd/default.conf" /etc/keyd/default.conf
sudo systemctl enable --now keyd 2>/dev/null || true
sudo systemctl restart keyd 2>/dev/null || true

# Belt-and-suspenders: ignore Caps Lock at the compositor even if something injects it.
if [[ -f $R2D2_PATH/config/hypr/input.lua ]]; then
  r2-d2-refresh-config hypr/input.lua 2>/dev/null || \
    cp "$R2D2_PATH/config/hypr/input.lua" ~/.config/hypr/input.lua
elif [[ -f $R2D2_PATH/config/hypr/input.conf ]]; then
  # Pre-Lua installs (should not happen after compositor Lua migration).
  r2-d2-refresh-config hypr/input.conf 2>/dev/null || \
    cp "$R2D2_PATH/config/hypr/input.conf" ~/.config/hypr/input.conf
fi

hyprctl reload >/dev/null 2>&1 || true
