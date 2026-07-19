#!/bin/bash

# Install the FUSE unmount system-sleep hook on existing installs.
# Prevents silent suspend failures when gvfsd-fuse blocks the kernel freeze.
# Port of omarchy dd86a893 / f9271254 / 24ca8e2b.

echo "Installing FUSE unmount hook for suspend/hibernate safety"

sudo mkdir -p /usr/lib/systemd/system-sleep
sudo install -m 0755 -o root -g root \
  "$R2D2_PATH/default/systemd/system-sleep/unmount-fuse" \
  /usr/lib/systemd/system-sleep/
