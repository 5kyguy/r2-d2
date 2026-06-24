#!/bin/bash

set -e

bash "$R2D2_PATH/install/first-run/server-firewall.sh"
bash "$R2D2_PATH/install/first-run/dns-resolver.sh"
bash "$R2D2_PATH/install/first-run/battery-monitor.sh"
bash "$R2D2_PATH/install/first-run/cleanup-reboot-sudoers.sh"

sudo loginctl enable-linger "$USER"

if systemctl --user is-enabled k2so.service &>/dev/null; then
  systemctl --user start k2so.service || true
fi