#!/bin/bash

sudo loginctl enable-linger "$USER"

sudo mkdir -p /etc/systemd/logind.conf.d
if [[ ! -f /etc/systemd/logind.conf.d/r2-d2-server-lid.conf ]]; then
  sudo tee /etc/systemd/logind.conf.d/r2-d2-server-lid.conf >/dev/null <<'EOF'
[Login]
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
EOF
  sudo systemctl restart systemd-logind
fi

if command -v powerprofilesctl &>/dev/null; then
  powerprofilesctl set balanced 2>/dev/null || powerprofilesctl set performance 2>/dev/null || true
fi