#!/bin/bash

# Install zram-generator drop-in, reclaim sysctl, and disable zswap in front of zram.

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"

sudo mkdir -p /usr/lib/systemd/zram-generator.conf.d /etc/sysctl.d /etc/tmpfiles.d
sudo cp "$R2D2_PATH/default/systemd/zram-generator.conf.d/90-r2-d2.conf" \
  /usr/lib/systemd/zram-generator.conf.d/90-r2-d2.conf
sudo cp "$R2D2_PATH/default/etc/sysctl.d/99-r2-d2-sysctl.conf" \
  /etc/sysctl.d/99-r2-d2-sysctl.conf
sudo cp "$R2D2_PATH/default/etc/tmpfiles.d/r2-d2-zswap.conf" \
  /etc/tmpfiles.d/r2-d2-zswap.conf

sudo sysctl -p /etc/sysctl.d/99-r2-d2-sysctl.conf >/dev/null 2>&1 || true
sudo systemd-tmpfiles --create /etc/tmpfiles.d/r2-d2-zswap.conf >/dev/null 2>&1 || true
sudo systemctl daemon-reload
