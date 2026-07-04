#!/bin/bash

echo "Rename dwindle section to layout for Hyprland 0.54+"

if [[ -f ~/.config/hypr/looknfeel.conf ]]; then
  sed -i 's/^dwindle {$/layout {/' ~/.config/hypr/looknfeel.conf
  sed -i 's|See https://wiki.hyprland.org/Configuring/Dwindle-Layout/|See https://wiki.hyprland.org/Configuring/Layout/|' ~/.config/hypr/looknfeel.conf
fi
