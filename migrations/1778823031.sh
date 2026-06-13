#!/bin/bash

echo "Hyprland 0.55: remove pseudotile and revert layout section to dwindle"

if [[ -f ~/.config/hypr/looknfeel.conf ]]; then
  sed -i '/^[[:space:]]*pseudotile = /d' ~/.config/hypr/looknfeel.conf
  sed -i 's/^layout {$/dwindle {/' ~/.config/hypr/looknfeel.conf
  sed -i 's|See https://wiki.hyprland.org/Configuring/Layout/|See https://wiki.hyprland.org/Configuring/Layouts/Dwindle-Layout/|' ~/.config/hypr/looknfeel.conf
fi
