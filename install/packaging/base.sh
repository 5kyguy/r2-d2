#!/bin/bash

# Install all base packages (official repos first, then AUR)
mapfile -t packages < <(grep -v '^#' "$OMARCHY_INSTALL/omarchy-base.packages" | grep -v '^$')
omarchy-pkg-add "${packages[@]}"

mapfile -t aur_packages < <(grep -v '^#' "$OMARCHY_INSTALL/omarchy-base.aur.packages" | grep -v '^$')
if [[ ${#aur_packages[@]} -gt 0 ]]; then
  omarchy-pkg-aur-add "${aur_packages[@]}"
fi

# Voxtype dictation: download model and enable systemd (config is in config phase)
if command -v voxtype &>/dev/null; then
  voxtype setup --download --no-post-install
  voxtype setup systemd
fi
