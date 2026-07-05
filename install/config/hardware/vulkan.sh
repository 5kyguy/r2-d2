#!/bin/bash

# Install Vulkan drivers matching detected GPU hardware

declare -A VULKAN_DRIVERS=(
  [AMD]=vulkan-radeon
)

# VA-API / VDPAU video-decode drivers matching detected GPU hardware.
# Counterpart to the Vulkan table: Vulkan drives rendering, VA-API drives
# hardware video decode (AV1/HEVC/VP9). Strix Halo's Radeon 8060S has powerful
# decode blocks that go unused without libva-mesa-driver.
declare -A VAAPI_DRIVERS=(
  [AMD]="libva-mesa-driver libva-utils"
  [ATI]="libva-mesa-driver libva-utils"
)

PACKAGES=()

for vendor in "${!VULKAN_DRIVERS[@]}"; do
  if lspci | grep -iE "(VGA|Display).*$vendor" >/dev/null; then
    PACKAGES+=("${VULKAN_DRIVERS[$vendor]}")
  fi
done

for vendor in "${!VAAPI_DRIVERS[@]}"; do
  if lspci | grep -iE "(VGA|Display).*$vendor" >/dev/null; then
    read -ra vaapi_pkgs <<<"${VAAPI_DRIVERS[$vendor]}"
    PACKAGES+=("${vaapi_pkgs[@]}")
  fi
done

if ((${#PACKAGES[@]} > 0)); then
  r2-d2-pkg-add "${PACKAGES[@]}"
fi
