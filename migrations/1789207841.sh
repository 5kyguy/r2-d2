#!/bin/bash

echo "Install bluez-utils/tools and recover Bluetooth tooling"

r2-d2-pkg-add bluez-utils bluez-tools

# Unblock if a prior migration soft-blocked without bluetoothctl available.
rfkill unblock bluetooth 2>/dev/null || true
