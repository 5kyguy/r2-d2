#!/bin/bash

echo "Finish the Robin cutover: retry thunar, retire the Omaroll helpers"

# 1794486499 tried thunar before its archive plugin; pacman refused and
# the guard hid it. Nothing requires thunar now.
if pacman -Q thunar >/dev/null 2>&1; then
  r2-d2-pkg-remove thunar || true
fi

# Omaroll-called helpers: their only caller is gone with Omaroll. The
# repo drops them here; the live copies need an explicit remove.
R2D2_BIN="${R2D2_PATH:-$HOME/.local/share/r2-d2}/bin"
rm -f "$R2D2_BIN/omarchy-theme-bg-set" \
  "$R2D2_BIN/omarchy-transcode" \
  "$R2D2_BIN/r2-d2-transcode"

# Omaroll's theme reader link, the only thing in that state dir.
rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
