#!/bin/bash

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
# shellcheck source=../install/helpers/profile.sh
source "$R2D2_PATH/install/helpers/profile.sh"
r2d2_skip_if_server


echo "Enable dynamic wallpaper-driven accent theme (repo templates only)"

if [[ -f ~/.config/hypr/looknfeel.conf ]]; then
  sed -i '/^[[:space:]]*pseudotile = /d' ~/.config/hypr/looknfeel.conf
fi

if [[ -x $R2D2_PATH/bin/r2-d2-theme-apply ]]; then
  $R2D2_PATH/bin/r2-d2-theme-apply --from-background
fi