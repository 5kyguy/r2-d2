#!/bin/bash

# Install core packages (and desktop packages when profile is desktop).

mapfile -t packages < <(r2d2_all_packages)

while r2d2-pkg-missing "${packages[@]}"; do
  echo "Installing packages from r2-d2-core.packages$(r2d2_is_server || echo ' + r2-d2-desktop.packages') (retrying until all are installed)..."
  r2-d2-pkg-add "${packages[@]}" || true
  if r2d2-pkg-missing "${packages[@]}"; then
    echo "Some packages are still missing; retrying in 10s..."
    sleep 10
  fi
done
echo "All profile package lists are installed."

mapfile -t aur_packages < <(r2d2_aur_packages)
if ((${#aur_packages[@]} > 0)); then
  while r2d2-pkg-missing "${aur_packages[@]}"; do
    echo "Installing AUR packages (retrying until all are installed)..."
    r2d2-pkg-aur-add "${aur_packages[@]}" || true
    if r2d2-pkg-missing "${aur_packages[@]}"; then
      echo "Some AUR packages are still missing; retrying in 10s..."
      sleep 10
    fi
  done
  echo "All profile AUR packages are installed."
fi

# Voxtype dictation setup is optional and handled via menu (see `r2-d2-voxtype-install`)