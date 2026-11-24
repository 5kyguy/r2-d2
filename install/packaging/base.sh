#!/bin/bash

# Install all base packages (official repos first, then AUR). Transient failures
# retry up to MAX_ATTEMPTS; a package that cannot install at all fails the
# install loudly (naming the packages still missing) instead of retrying forever.

max_attempts=3

missing_packages() {
  local pkg
  for pkg in "$@"; do
    pacman -Q "$pkg" &>/dev/null || echo "$pkg"
  done
}

install_with_retries() {
  local list_name=$1 installer=$2
  shift 2
  local packages=("$@")
  local attempt=1

  (( ${#packages[@]} > 0 )) || return 0

  while r2-d2-pkg-missing "${packages[@]}"; do
    echo "Installing packages from $list_name (attempt $attempt of $max_attempts)..."
    "$installer" "${packages[@]}" || true
    if r2-d2-pkg-missing "${packages[@]}"; then
      if (( attempt >= max_attempts )); then
        echo "ERROR: packages still missing from $list_name after $max_attempts attempts:" >&2
        missing_packages "${packages[@]}" >&2
        echo "See $R2D2_INSTALL_LOG_FILE for the pacman/yay errors." >&2
        return 1
      fi
      echo "Some packages are still missing; retrying in 10s..." >&2
      sleep 10
      attempt=$((attempt + 1))
    fi
  done
  echo "All packages from $list_name are installed."
}

mapfile -t packages < <(grep -v '^#' "$R2D2_INSTALL/r2-d2-base.packages" | grep -v '^$')
install_with_retries r2-d2-base.packages r2-d2-pkg-add "${packages[@]}" || exit 1

# yay is bootstrapped by r2-d2-pkg-aur-add on each attempt (r2-d2-pkg-ensure-yay)
mapfile -t aur_packages < <(grep -v '^#' "$R2D2_INSTALL/r2-d2-base.aur.packages" | grep -v '^$')
install_with_retries r2-d2-base.aur.packages r2-d2-pkg-aur-add "${aur_packages[@]}" || exit 1
