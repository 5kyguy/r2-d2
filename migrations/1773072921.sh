#!/bin/bash

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
# shellcheck source=../install/helpers/profile.sh
source "$R2D2_PATH/install/helpers/profile.sh"
r2d2_skip_if_server


echo "Remove stale Helium wrapper + desktop entry (no longer installed by default)"

rm -f "$HOME/.local/bin/helium"
rm -f "$HOME/.local/share/applications/Helium.desktop"

# Refresh desktop database if available
if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi
