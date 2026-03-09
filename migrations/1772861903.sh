#!/bin/bash

echo "Move repo-managed support assets from config/ to default/config"

bash "$R2D2_PATH/install/config/default-config.sh"

mkdir -p ~/.local/share/fonts
cp "$R2D2_PATH/default/config/r2-d2.ttf" ~/.local/share/fonts/
fc-cache -f

systemctl --user daemon-reload || true
systemctl --user restart r2-d2-battery-monitor.timer || true

r2-d2-state set desktop-refresh-required
r2-d2-state set relogin-required
