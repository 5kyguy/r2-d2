#!/bin/bash

# Enable GPU acceleration in voxtype on existing installs where Vulkan is
# available. Port of omarchy 1c65d1db (with the sudo fix that the original
# 64ef8044 migration lacked on some setups).

if ! r2-d2-cmd-present voxtype; then
  exit 0
fi

if r2-d2-hw-vulkan; then
  echo "Enabling GPU acceleration in voxtype"
  # sudo: voxtype setup gpu --enable touches system-wide config on some setups
  sudo voxtype setup gpu --enable || true

  # Re-run systemd setup to refresh the service symlink in case an older
  # non-GPU backend is hard-coded in the unit, then restart.
  voxtype setup systemd
  systemctl --user restart voxtype 2>/dev/null || true
  r2-d2-restart-waybar
fi
