#!/bin/bash

# Ensure iwd service will be started
chrootable_systemctl_enable iwd.service iwd

# Prevent systemd-networkd-wait-online timeout on boot
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service
