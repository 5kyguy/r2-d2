#!/bin/bash

echo "Hide retired launcher entries and refresh application menu"

APP_DIR="$HOME/.local/share/applications"

rm -f \
  "$APP_DIR/Ghostty.desktop" \
  "$APP_DIR/Disk Usage.desktop" \
  "$APP_DIR/DiskUsage.desktop" \
  "$APP_DIR/Docker.desktop"

if [[ -x $R2D2_PATH/bin/r2-d2-refresh-applications ]]; then
  $R2D2_PATH/bin/r2-d2-refresh-applications
fi
