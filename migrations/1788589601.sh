#!/bin/bash

echo "Quattro QoL batch 2 (no reboot): udiskie, bluetooth power persistence, zram tuning"

r2-d2-pkg-add udiskie

# Remember Bluetooth on/off via rfkill soft-block; undo AutoEnable=false hold-down.
marker="${R2D2_BLUETOOTH_MIGRATION_MARKER:-/var/lib/r2-d2/migrations/bluetooth-power}"
main_conf="${R2D2_BLUETOOTH_MAIN_CONF:-/etc/bluetooth/main.conf}"

if [[ ! -e $marker ]]; then
  if r2-d2-bluetooth-power is-on; then
    sudo r2-d2-bluetooth-power on
  else
    sudo r2-d2-bluetooth-power off
  fi

  if [[ -f $main_conf ]]; then
    sudo sed -i 's/^AutoEnable=false$/#AutoEnable=true/' "$main_conf"
  fi

  sudo install -Dm644 /dev/null "$marker"
fi

# zram drop-ins + reclaim sysctl
sudo mkdir -p /usr/lib/systemd/zram-generator.conf.d /etc/sysctl.d /etc/tmpfiles.d
sudo cp "$R2D2_PATH/default/systemd/zram-generator.conf.d/90-r2-d2.conf" \
  /usr/lib/systemd/zram-generator.conf.d/90-r2-d2.conf
sudo cp "$R2D2_PATH/default/etc/sysctl.d/99-r2-d2-sysctl.conf" \
  /etc/sysctl.d/99-r2-d2-sysctl.conf
sudo cp "$R2D2_PATH/default/etc/tmpfiles.d/r2-d2-zswap.conf" \
  /etc/tmpfiles.d/r2-d2-zswap.conf

sudo sysctl -p /etc/sysctl.d/99-r2-d2-sysctl.conf >/dev/null 2>&1 || true
sudo systemd-tmpfiles --create /etc/tmpfiles.d/r2-d2-zswap.conf >/dev/null 2>&1 || true

zram_conf="${R2D2_ZRAM_CONF:-/etc/systemd/zram-generator.conf}"
zram_dropin="/usr/lib/systemd/zram-generator.conf.d/90-r2-d2.conf"
if [[ -f $zram_conf && -f $zram_dropin ]] && ! pacman -Qo "$zram_conf" &>/dev/null; then
  settings=$(grep -vE '^[[:space:]]*([#;]|$)' "$zram_conf" | tr -d '[:space:]') || true
  if [[ -z $settings || $settings =~ ^\[zram0\]compression-algorithm=[[:alnum:]-]+$ ]]; then
    sudo rm -f "$zram_conf" || true
  fi
fi

if sudo systemctl daemon-reload; then
  zram_used=$(awk '$1 == "/dev/zram0" {print $4}' /proc/swaps)
  if [[ ${zram_used:-0} == 0 ]]; then
    sudo systemctl restart dev-zram0.swap >/dev/null 2>&1 || true
  fi
fi
