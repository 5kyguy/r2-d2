#!/bin/bash

# Re-install the wifi-powersave udev rule with USB-C autodetect on existing
# installs. The old rule used ATTR{online}=="0/1" which silently never fired
# on USB-C-only laptops (no Mains device present). Port of omarchy 080c8ba3.

echo "Updating wifi-powersave udev rules for USB-C autodetect"

source "$R2D2_PATH/install/config/wifi-powersave-rules.sh"
