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

r2d2_read_tty() {
  # curl | bash leaves stdin as the pipe; read prompts need the real terminal.
  if [[ -e /dev/tty ]]; then
    read -r "$@" </dev/tty
  else
    read -r "$@"
  fi
}

r2d2_choose_profile() {
  local profile_file="$HOME/.config/r2-d2/profile"
  mkdir -p "$(dirname "$profile_file")"

  if [[ -f $profile_file ]]; then
    echo "Existing install profile: $(<"$profile_file")"
    r2d2_read_tty -p "Keep it? [Y/n] " keep
    if [[ ${keep,,} != n ]]; then
      return
    fi
  fi

  echo
  echo "Install profile:"
  echo "  1) desktop  — Hyprland workstation (default)"
  echo "  2) server   — headless (SSH, Docker, K-2SO, no GUI stack)"
  r2d2_read_tty -p "Choice [1]: " choice
  case "${choice:-1}" in
    2 | server) echo server >"$profile_file" ;;
    *) echo desktop >"$profile_file" ;;
  esac
  echo "Profile set to: $(<"$profile_file")"
  echo
}

r2d2_choose_profile

# Always use stable mirror first; on failure refresh mirrorlist (fallback to Arch mirrors) and retry
set_stable_mirror() {
  echo 'Server = https://stable-mirror.omarchy.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
}

refresh_mirrorlist_fallback() {
  echo "Stable mirror failed. Refreshing mirrorlist from Arch Linux mirrors..."
  if curl -fsSL 'https://archlinux.org/mirrorlist/?country=all&protocol=https&use_mirror_status=on' |
    sed 's/^#Server/Server/' | sudo tee /etc/pacman.d/mirrorlist >/dev/null; then
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
  if ((attempt >= max_attempts)); then
    echo "Failed to sync and install git after $max_attempts attempt(s)." >&2
    exit 1
  fi
  refresh_mirrorlist_fallback || exit 1
  attempt=$((attempt + 1))
done

echo -e "\nCloning from: https://github.com/5kyguy/r2-d2.git (branch: master)"
rm -rf ~/.local/share/r2-d2/
git clone "https://github.com/5kyguy/r2-d2.git" ~/.local/share/r2-d2 >/dev/null

cd ~/.local/share/r2-d2 || exit
git fetch origin master && git checkout master
cd - || exit

echo -e "\nInstallation starting..."
# shellcheck source=install.sh
source ~/.local/share/r2-d2/install.sh
