#!/bin/bash

# Detect AMD ISP4 webcam hardware and build/install drivers if needed.
# Only runs if both the ISP capture device and OV05C10 sensor I2C device exist.

if ! ls /sys/bus/platform/devices/amd_isp_capture.*.auto >/dev/null 2>&1 ||
  ! ls /sys/bus/i2c/devices/i2c-ov05c10 >/dev/null 2>&1; then
  exit 0
fi

# Skip if the ISP4 capture driver is already bound (webcam working). The module
# is named `amd_capture` but registers its platform driver as `amd_isp_capture`,
# so check that driver name in sysfs. Note that other V4L2 devices (e.g. an
# external USB webcam) also produce /dev/video*, so checking for any video node
# is not sufficient.
if ls /sys/bus/platform/drivers/amd_isp_capture/amd_isp_capture.*.auto >/dev/null 2>&1; then
  exit 0
fi

r2-d2-fix-amd-webcam || true
