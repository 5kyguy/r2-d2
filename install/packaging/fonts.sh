#!/bin/bash

# R2-D2 logo font for Waybar use, and Manrope for Mako notifications.
# Manrope is vendored because the AUR ttf-manrope source download returns 404.
r2-d2-pkg-add fontconfig

mkdir -p ~/.local/share/fonts
cp ~/.local/share/r2-d2/default/config/r2-d2.ttf \
  ~/.local/share/r2-d2/default/config/manrope-variable.ttf \
  ~/.local/share/r2-d2/default/config/manrope-OFL.txt \
  ~/.local/share/fonts/
fc-cache -f
