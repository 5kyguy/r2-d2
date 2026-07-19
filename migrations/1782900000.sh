#!/bin/bash

# Re-install the power-profile udev rule with USB-C autodetect and enable the
# daemon on existing installs. The old rule used ATTR{online}=="0/1" which
# silently never fired on USB-C-only laptops (no Mains device present).
# Port of omarchy 62f69808 + ed93a047.
#
# Note: the rule setup now lives in install/first-run/ (moved from
# install/config/) because power-profiles-daemon is not running during the
# install/config phase of a fresh archinstall. On existing installs this
# migration is the path that re-runs it.

echo "Updating power-profile udev rules for USB-C autodetect"

source "$R2D2_PATH/install/first-run/powerprofilesctl-rules.sh"
