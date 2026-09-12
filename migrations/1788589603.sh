#!/bin/bash

echo "Cut over from iwd/impala to NetworkManager; install DNS/timezone sudoers"

r2-d2-pkg-add networkmanager qrencode

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

as_root systemctl enable NetworkManager.service >/dev/null 2>&1 || true
as_root systemctl mask NetworkManager-wait-online.service >/dev/null 2>&1 || true

networkd_units=(
  systemd-networkd.service
  systemd-networkd.socket
  systemd-networkd-varlink.socket
  systemd-networkd-varlink-metrics.socket
  systemd-networkd-resolve-hook.socket
)

for unit in "${networkd_units[@]}"; do
  as_root systemctl disable "$unit" >/dev/null 2>&1 || true
done
as_root systemctl disable systemd-networkd-wait-online.service >/dev/null 2>&1 || true
as_root systemctl mask systemd-networkd-wait-online.service >/dev/null 2>&1 || true
as_root systemctl disable iwd.service >/dev/null 2>&1 || true

state=$(systemctl is-enabled wpa_supplicant.service 2>/dev/null || true)
if [[ $state == masked* ]]; then
  as_root systemctl unmask wpa_supplicant.service
  state=$(systemctl is-enabled wpa_supplicant.service 2>/dev/null || true)
  if [[ $state == "masked-runtime" ]]; then
    as_root systemctl unmask --runtime wpa_supplicant.service
  fi
fi

# Prefer enabling NM for next boot; do not yank the live iwd link mid-update.
if systemctl is-active --quiet NetworkManager.service 2>/dev/null; then
  as_root systemctl disable --now iwd.service >/dev/null 2>&1 || true
  for unit in "${networkd_units[@]}"; do
    as_root systemctl disable --now "$unit" >/dev/null 2>&1 || true
  done
fi

r2-d2-pkg-remove iwd impala 2>/dev/null || true

bash "$R2D2_PATH/install/config/sudoers-helpers.sh" || true

r2-d2-state set reboot-required
