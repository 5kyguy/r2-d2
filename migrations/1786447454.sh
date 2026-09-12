#!/bin/bash

echo "Add Quattro QoL packages (socat, zbar, ddcutil, pacman-contrib) and enable systemd-oomd"

r2-d2-pkg-add socat zbar ddcutil pacman-contrib

# Ship oomd drop-ins so runaway apps in app.slice are killed instead of the session.
sudo mkdir -p /usr/lib/systemd/user/app.slice.d /etc/systemd/oomd.conf.d
sudo cp "$R2D2_PATH/default/systemd/user/app.slice.d/10-oomd.conf" /usr/lib/systemd/user/app.slice.d/10-oomd.conf
sudo cp "$R2D2_PATH/default/etc/systemd/oomd.conf.d/10-r2-d2.conf" /etc/systemd/oomd.conf.d/10-r2-d2.conf

if systemctl is-enabled --quiet systemd-oomd.service 2>/dev/null; then
  sudo systemctl try-restart systemd-oomd.service >/dev/null 2>&1 || true
else
  sudo systemctl enable --now systemd-oomd.service >/dev/null 2>&1 ||
    echo "Could not enable systemd-oomd.service; memory pressure may still take the session down."
fi

systemctl --user daemon-reload >/dev/null 2>&1 || true
