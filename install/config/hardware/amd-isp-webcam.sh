#!/bin/bash

# Detect AMD ISP4 webcam hardware and build/install drivers if needed.
# Only runs if both the ISP capture device and OV05C10 sensor I2C device exist.

if ! ls /sys/bus/platform/devices/amd_isp_capture.*.auto >/dev/null 2>&1 ||
  ! ls /sys/bus/i2c/devices/i2c-ov05c10 >/dev/null 2>&1; then
  exit 0
fi

if ls /dev/video* >/dev/null 2>&1; then
  exit 0
fi

r2-d2-fix-amd-webcam || true
