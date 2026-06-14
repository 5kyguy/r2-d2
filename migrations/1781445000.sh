#!/bin/bash

echo "Fix default wallpaper symlink and refresh hyprlock background path"

BACKGROUND_DIR="$R2D2_PATH/backgrounds"
if [[ -f $BACKGROUND_DIR/dark_limits.jpg ]]; then
  ln -nsf "$BACKGROUND_DIR/dark_limits.jpg" "$BACKGROUND_DIR/@background"
fi

r2-d2-refresh-config hypr/hyprlock.conf
