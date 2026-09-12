#!/bin/bash

echo "Enable crash → K-2SO diagnosis when k2so is active"

if ! systemctl --user is-active --quiet k2so.service 2>/dev/null; then
  echo "k2so.service not active; skipping crash-watch enable"
  exit 0
fi

mkdir -p "$HOME/.config/systemd/user"
cp "$R2D2_PATH/default/config/systemd/user/r2-d2-crash-watch.service" \
  "$HOME/.config/systemd/user/r2-d2-crash-watch.service"

systemctl --user daemon-reload >/dev/null 2>&1 || true

if ! systemctl --user enable r2-d2-crash-watch.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn "$HOME/.config/systemd/user/r2-d2-crash-watch.service" \
    "$wants_dir/r2-d2-crash-watch.service"
fi

if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start r2-d2-crash-watch.service >/dev/null 2>&1 || true
fi
