#!/bin/bash

# Swap Caps Lock and Left Super via keyd (see default/keyd/default.conf).

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"

r2-d2-pkg-add keyd

sudo mkdir -p /etc/keyd
sudo cp "$R2D2_PATH/default/keyd/default.conf" /etc/keyd/default.conf
sudo systemctl enable --now keyd
sudo systemctl restart keyd
