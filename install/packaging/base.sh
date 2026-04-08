#!/bin/bash

# Install all base packages (official repos first, then AUR). Retry until complete.

mapfile -t packages < <(grep -v '^#' "$R2D2_INSTALL/r2-d2-base.packages" | grep -v '^$')

while r2-d2-pkg-missing "${packages[@]}"; do
  echo "Installing base packages from r2-d2-base.packages (retrying until all are installed)..."
  r2-d2-pkg-add "${packages[@]}" || true
  if r2-d2-pkg-missing "${packages[@]}"; then
    echo "Some packages are still missing; retrying in 10s..."
    sleep 10
  fi
done
echo "All base packages from r2-d2-base.packages are installed."

mapfile -t aur_packages < <(grep -v '^#' "$R2D2_INSTALL/r2-d2-base.aur.packages" | grep -v '^$')
if [[ ${#aur_packages[@]} -gt 0 ]]; then
  while r2-d2-pkg-missing "${aur_packages[@]}"; do
    echo "Installing AUR packages from r2-d2-base.aur.packages (retrying until all are installed)..."
    r2-d2-pkg-aur-add "${aur_packages[@]}" || true
    if r2-d2-pkg-missing "${aur_packages[@]}"; then
      echo "Some AUR packages are still missing; retrying in 10s..."
      sleep 10
    fi
  done
  echo "All AUR packages from r2-d2-base.aur.packages are installed."
fi

# Voxtype dictation setup is optional and handled via menu (see `r2-d2-voxtype-install`)
