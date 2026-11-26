#!/bin/bash

# Fresh installs use NetworkManager. Retire iwd and archinstall networkd DHCP leftovers.

chrootable_systemctl_enable NetworkManager.service networkmanager

# Don't let network-online.target hold up graphical.target waiting for DHCP/Wi-Fi.
sudo systemctl mask NetworkManager-wait-online.service 2>/dev/null || true

# Carry iwd Wi-Fi credentials over to NetworkManager before retiring iwd, so
# the first reboot connects without a manual hop. iwd profiles live root-only
# in /var/lib/iwd and NM keeps its own store, so nothing survives the handover
# otherwise. Only .psk profiles migrate; open and 802.1x networks are skipped.
if systemctl is-active --quiet NetworkManager.service 2>/dev/null; then
  mapfile -t iwd_profiles < <(sudo find /var/lib/iwd -maxdepth 1 -name '*.psk' 2>/dev/null || true)

  for profile in "${iwd_profiles[@]}"; do
    base=${profile##*/}
    base=${base%.psk}

    # iwd names the file after the SSID verbatim when it contains only
    # alphanumeric characters, spaces, underscores or minus signs, else as
    # '=' followed by the lower-case hex encoding of the SSID.
    if [[ $base == "="* ]]; then
      hex=${base#=}
      fmt=""
      for ((i = 0; i < ${#hex}; i += 2)); do
        fmt+="\\x${hex:$i:2}"
      done
      ssid=$(printf '%b' "$fmt")
    else
      ssid=$base
    fi

    # Skip networks NetworkManager already knows (re-runs, manual connects)
    if nmcli --get-values 802-11-wireless.ssid connection show 2>/dev/null | grep -qxF "$ssid"; then
      continue
    fi

    # iwd escapes \s (space), \t, \r, \n and \\ inside values
    passphrase=$(sudo sed -n 's/^[[:space:]]*Passphrase=//p' "$profile" 2>/dev/null | head -1 || true)
    passphrase=$(printf '%b' "${passphrase//\\s/ }")
    psk_hex=$(sudo sed -n 's/^[[:space:]]*PreSharedKey=//p' "$profile" 2>/dev/null | head -1 || true)

    if [[ -n $passphrase ]]; then
      key=$passphrase
    elif [[ -n $psk_hex ]]; then
      key=$psk_hex
    else
      echo "iwd profile for '$ssid' has no stored key; skipping."
      continue
    fi

    hidden=$(sudo sed -n 's/^[[:space:]]*Hidden=//p' "$profile" 2>/dev/null | head -1 || true)

    args=(type wifi ifname '*' con-name "$ssid" 802-11-wireless.ssid "$ssid" 802-11-wireless-security.key-mgmt wpa-psk 802-11-wireless-security.psk "$key")
    if [[ $hidden == "true" ]]; then
      args+=(802-11-wireless.hidden yes)
    fi

    if nmcli connection add "${args[@]}" >/dev/null 2>&1; then
      echo "Migrated iwd Wi-Fi profile: $ssid"
    else
      echo "Could not migrate iwd Wi-Fi profile: $ssid" >&2
    fi
  done
fi

# Disable only, never --now: a fresh install may be connected through iwd at
# this very moment, and stopping it severs the network mid-install —
# NetworkManager has no saved Wi-Fi credentials to take over with. iwd keeps
# running for the rest of the session and stays off after the reboot.
sudo systemctl disable iwd.service 2>/dev/null || true

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
