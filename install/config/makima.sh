#!/bin/bash

# Remap Copilot key (Super+Shift+F23) to Super+Alt+Space (R2-D2 menu) using makima
R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"

r2-d2-pkg-aur-add makima-bin

mkdir -p "$HOME/.config/makima"
cp "$R2D2_PATH/default/makima/AT Translated Set 2 Keyboard.toml" "$HOME/.config/makima/"

# Create systemd override with correct user and config path
sudo mkdir -p /etc/systemd/system/makima.service.d
sudo tee /etc/systemd/system/makima.service.d/override.conf >/dev/null <<EOF
[Service]
User=$USER
Environment="MAKIMA_CONFIG=/home/$USER/.config/makima"
EOF

sudo systemctl daemon-reload
chrootable_systemctl_enable makima.service
