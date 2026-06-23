#!/bin/bash

echo "Re-sync K-2SO systemd unit, profile, and OpenCode config when k2so is enabled"

if ! systemctl --user is-enabled k2so.service &>/dev/null; then
  exit 0
fi

r2-d2-refresh-config k2so/profile.toml
r2-d2-ensure-k2so-secrets
r2-d2-merge-k2so-opencode

mkdir -p "$HOME/.config/systemd/user"
cp "$R2D2_PATH/default/config/systemd/user/k2so.service" "$HOME/.config/systemd/user/"

systemctl --user daemon-reload

if systemctl --user is-active k2so.service &>/dev/null; then
  systemctl --user restart k2so.service
fi
