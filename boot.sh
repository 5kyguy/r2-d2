#!/bin/bash

ansi_art='     ▄▄▄▄▄▄▄▄    ▄▄▄▄▄▄▄▄        ▄▄▄▄▄▄▄▄▄▄      ▄▄▄▄▄▄▄▄
   ▄██▀▀▀▀███  ▄██▀▀▀▀▀▀██▄       ▀███▀▀▀▀██▄  ▄██▀▀▀▀▀▀██▄
   ███    ███  ███      ███        ███    ███  ███      ███
   ███    ███         ▄███▀        ███    ███         ▄███▀
 ▄█████████▀        ▄███▀   ████   ███    ███       ▄███▀
 ▄▄███▄▄▄▄▄▄▄     ▄███▀            ███    ███     ▄███▀
  ▀███▀▀▀▀███   ▄███▀              ███    ███   ▄███▀
   ███    ███  ████▄▄▄▄▄▄▄▄       ▄███▄▄▄▄██▀  ████▄▄▄▄▄▄▄▄
   ▀▀▀    ███  ▀▀▀▀▀▀▀▀▀▀▀▀      ▀▀▀▀▀▀▀▀▀▀    ▀▀▀▀▀▀▀▀▀▀▀▀'

clear
echo -e "\n$ansi_art\n"

# Always use stable mirror first; on failure refresh mirrorlist (fallback to Arch mirrors) and retry
set_stable_mirror() {
  echo 'Server = https://stable-mirror.omarchy.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
}

refresh_mirrorlist_fallback() {
  echo "Stable mirror failed. Refreshing mirrorlist from Arch Linux mirrors..."
  if curl -fsSL 'https://archlinux.org/mirrorlist/?country=all&protocol=https&use_mirror_status=on' \
    | sed 's/^#Server/Server/' | sudo tee /etc/pacman.d/mirrorlist >/dev/null; then
    echo "Mirrorlist updated. Retrying..."
    return 0
  fi
  echo "Could not refresh mirrorlist." >&2
  return 1
}

set_stable_mirror
max_attempts=2
attempt=1
while ! sudo pacman -Syu --noconfirm --needed git; do
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "Failed to sync and install git after $max_attempts attempt(s)." >&2
    exit 1
  fi
  refresh_mirrorlist_fallback || exit 1
  attempt=$((attempt + 1))
done

echo -e "\nCloning from: https://github.com/5kyguy/artoo-d2.git (branch: dev)"
rm -rf ~/.local/share/r2-d2/
git clone "https://github.com/5kyguy/artoo-d2.git" ~/.local/share/r2-d2 >/dev/null

cd ~/.local/share/r2-d2 || exit
git fetch origin dev && git checkout dev
cd - || exit

echo -e "\nInstallation starting..."
# shellcheck source=install.sh
source ~/.local/share/r2-d2/install.sh
