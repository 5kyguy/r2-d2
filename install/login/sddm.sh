#!/bin/bash

# Install r2-d2 SDDM theme
r2-d2-refresh-sddm

# Setup SDDM login service
sudo mkdir -p /etc/sddm.conf.d
if [[ ! -f /etc/sddm.conf.d/autologin.conf ]]; then
  cat <<EOF | sudo tee /etc/sddm.conf.d/autologin.conf
[Autologin]
User=$USER
Session=hyprland-uwsm

[Theme]
Current=r2-d2
EOF
fi

# Prevent SDDM from creating an encrypted login keyring (Default_Keyring) that
# conflicts with the passwordless Default_keyring used for auto-unlock.
sudo sed -i '/pam_gnome_keyring\.so/d' /etc/pam.d/sddm

# Don't use --now here; it can cause issues for manual installs
r2-d2-pkg-add sddm
sudo systemctl enable sddm.service
