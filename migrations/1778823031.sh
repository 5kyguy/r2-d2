#!/bin/bash

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
# shellcheck source=../install/helpers/profile.sh
source "$R2D2_PATH/install/helpers/profile.sh"
r2d2_skip_if_server


echo "Hyprland 0.55: remove pseudotile and revert layout section to dwindle"

if [[ -f ~/.config/hypr/looknfeel.conf ]]; then
  sed -i '/^[[:space:]]*pseudotile = /d' ~/.config/hypr/looknfeel.conf
  sed -i 's/^layout {$/dwindle {/' ~/.config/hypr/looknfeel.conf
  sed -i 's|See https://wiki.hyprland.org/Configuring/Layout/|See https://wiki.hyprland.org/Configuring/Layouts/Dwindle-Layout/|' ~/.config/hypr/looknfeel.conf
fi
