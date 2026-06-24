#!/bin/bash

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
# shellcheck source=../install/helpers/profile.sh
source "$R2D2_PATH/install/helpers/profile.sh"
r2d2_skip_if_server


echo "Rename dwindle section to layout for Hyprland 0.54+"

if [[ -f ~/.config/hypr/looknfeel.conf ]]; then
  sed -i 's/^dwindle {$/layout {/' ~/.config/hypr/looknfeel.conf
  sed -i 's|See https://wiki.hyprland.org/Configuring/Dwindle-Layout/|See https://wiki.hyprland.org/Configuring/Layout/|' ~/.config/hypr/looknfeel.conf
fi
