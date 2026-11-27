#!/bin/bash

# https://wiki.archlinux.org/title/Systemd-resolved
# Enable resolved first: nothing else in the install flow does, and a
# resolv.conf symlinked to a stub nobody serves leaves the first login
# connected with an IP but no DNS (archinstall's NetworkManager profile
# never enables it either). The first-run sudoers grants passwordless
# systemctl for exactly this.
sudo systemctl enable --now systemd-resolved

echo "Symlink resolved stub-resolv to /etc/resolv.conf"
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
