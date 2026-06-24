#!/bin/bash

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
# shellcheck source=../install/helpers/profile.sh
source "$R2D2_PATH/install/helpers/profile.sh"
r2d2_skip_if_server


echo "Swap Caps Lock and Left Super via keyd"

sudo mkdir -p /etc/keyd
sudo cp "$R2D2_PATH/default/keyd/default.conf" /etc/keyd/default.conf
sudo systemctl enable --now keyd 2>/dev/null || true
sudo systemctl restart keyd 2>/dev/null || true

if [[ -f ~/.config/hypr/input.conf ]]; then
  sed -i 's/^[[:space:]]*kb_options = compose:caps.*/  kb_options =/' ~/.config/hypr/input.conf
fi

r2-d2-refresh-config hypr/input.conf 2>/dev/null || true
hyprctl reload >/dev/null 2>&1 || true