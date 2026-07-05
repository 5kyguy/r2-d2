#!/bin/bash

# Install udev rules to toggle wifi power_save on AC/battery changes.
# Same USB-C fix as powerprofilesctl-rules.sh: drop the broken ATTR{online}
# filter and emit a Mains + USB pair that delegates to autodetect. Without
# this, USB-C-only laptops never fire the rule and wifi power_save is stuck.

if r2-d2-battery-present; then
  # Remove legacy rule that hard-coded ATTR{online} filters (idempotent reinstall)
  sudo rm -f /etc/udev/rules.d/99-wifi-powersave.rules

  cat <<EOF | sudo tee "/etc/udev/rules.d/99-wifi-powersave.rules" >/dev/null
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="$HOME/.local/share/r2-d2/bin/r2-d2-wifi-powersave"
SUBSYSTEM=="power_supply", ATTR{type}=="USB", RUN+="$HOME/.local/share/r2-d2/bin/r2-d2-wifi-powersave"
EOF

  sudo udevadm control --reload
  sudo udevadm trigger --subsystem-match=power_supply
fi
