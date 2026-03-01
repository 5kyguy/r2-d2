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

# Always use stable mirror
echo 'Server = https://stable-mirror.omarchy.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null

sudo pacman -Syu --noconfirm --needed git

echo -e "\nCloning from: https://github.com/5kyguy/artoo-d2.git (branch: dev)"
rm -rf ~/.local/share/omarchy/
git clone "https://github.com/5kyguy/artoo-d2.git" ~/.local/share/omarchy >/dev/null

cd ~/.local/share/omarchy || exit
git fetch origin dev && git checkout dev
cd - || exit

echo -e "\nInstallation starting..."
# shellcheck source=install.sh
source ~/.local/share/omarchy/install.sh
