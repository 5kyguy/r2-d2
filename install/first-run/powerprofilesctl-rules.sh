#!/bin/bash

# Install udev rules to auto-switch power profile on AC/battery changes.
# Port of omarchy 62f69808: drop the broken ATTR{online}=="0/1" filter
# (which silently fails on USB-C-only laptops that have no Mains device)
# and delegate to r2-d2-powerprofiles-set, which autodetects power state
# by scanning all power_supply devices (Mains OR USB).

if r2-d2-battery-present; then
  mapfile -t profiles < <(r2-d2-powerprofiles-list)

  if ((${#profiles[@]} > 1)); then
    # Remove legacy rule that hard-coded ATTR{online} filters (idempotent reinstall)
    sudo rm -f /etc/udev/rules.d/99-power-profile.rules

    cat <<EOF | sudo tee "/etc/udev/rules.d/99-power-profile.rules" >/dev/null
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="/usr/bin/systemd-run --no-block --collect --unit=r2-d2-power-profile --property=After=power-profiles-daemon.service $HOME/.local/share/r2-d2/bin/r2-d2-powerprofiles-set"
SUBSYSTEM=="power_supply", ATTR{type}=="USB", RUN+="/usr/bin/systemd-run --no-block --collect --unit=r2-d2-power-profile --property=After=power-profiles-daemon.service $HOME/.local/share/r2-d2/bin/r2-d2-powerprofiles-set"
EOF

    # Ensure the daemon is running and starts on boot. The arch package preset
    # leaves it disabled, which silently breaks profile switching.
    sudo systemctl enable --now power-profiles-daemon

    sudo udevadm control --reload
    sudo udevadm trigger --subsystem-match=power_supply
  fi
fi
