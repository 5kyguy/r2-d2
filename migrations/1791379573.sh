#!/bin/bash

echo "Enable the R2-D2 Screen Time sampler"

# r2-d2-screentime samples hyprctl activewindow, so it needs a running
# Hyprland session; the service is gated on graphical-session.target.

mkdir -p "$HOME/.config/systemd/user"
cp "$R2D2_PATH/default/config/systemd/user/r2-d2-screentime.service" \
  "$HOME/.config/systemd/user/r2-d2-screentime.service"

systemctl --user daemon-reload >/dev/null 2>&1 || true

if ! systemctl --user enable r2-d2-screentime.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn "$HOME/.config/systemd/user/r2-d2-screentime.service" \
    "$wants_dir/r2-d2-screentime.service"
fi

if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start r2-d2-screentime.service >/dev/null 2>&1 || true
fi
