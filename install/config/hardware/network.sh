#!/bin/bash

# Fresh installs use NetworkManager. Retire iwd and archinstall networkd DHCP leftovers.

chrootable_systemctl_enable NetworkManager.service networkmanager

# Don't let network-online.target hold up graphical.target waiting for DHCP/Wi-Fi.
sudo systemctl mask NetworkManager-wait-online.service 2>/dev/null || true

sudo systemctl disable --now iwd.service 2>/dev/null || true

for unit in \
  systemd-networkd.service \
  systemd-networkd.socket \
  systemd-networkd-varlink.socket \
  systemd-networkd-varlink-metrics.socket \
  systemd-networkd-resolve-hook.socket; do
  sudo systemctl disable "$unit" 2>/dev/null || true
done

sudo systemctl disable systemd-networkd-wait-online.service 2>/dev/null || true
sudo systemctl mask systemd-networkd-wait-online.service 2>/dev/null || true

stock_networkd_file() {
  local file="$1"

  [[ -f $file ]] || return 1
  case "$(basename "$file")" in
  20-ethernet.network | 20-wlan.network | 20-wwan.network) ;;
  *) return 1 ;;
  esac

  grep -Eq '^[[:space:]]*DHCP=yes[[:space:]]*$' "$file" || return 1
  grep -Eq '^[[:space:]]*Name=(en\*|eth\*|wl\*|ww\*)[[:space:]]*$' "$file" || return 1
}

backup_dir="/etc/systemd/network/r2-d2-networkd-retired-$(date +%Y%m%d%H%M%S)"
for file in /etc/systemd/network/20-ethernet.network /etc/systemd/network/20-wlan.network /etc/systemd/network/20-wwan.network; do
  if stock_networkd_file "$file"; then
    sudo install -d -m 0755 "$backup_dir"
    sudo mv "$file" "$backup_dir/"
  fi
done

if systemctl is-active --quiet NetworkManager.service 2>/dev/null; then
  sudo systemctl stop systemd-networkd.service 2>/dev/null || true
fi

# iwd-era installs may mask wpa_supplicant; NetworkManager needs it available.
if [[ $(systemctl is-enabled wpa_supplicant.service 2>/dev/null || true) == masked* ]]; then
  sudo systemctl unmask wpa_supplicant.service
  if [[ $(systemctl is-enabled wpa_supplicant.service 2>/dev/null || true) == "masked-runtime" ]]; then
    sudo systemctl unmask --runtime wpa_supplicant.service
  fi
fi
