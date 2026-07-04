#!/bin/bash

echo "Remove stale Helium wrapper + desktop entry (no longer installed by default)"

rm -f "$HOME/.local/bin/helium"
rm -f "$HOME/.local/share/applications/Helium.desktop"

# Refresh desktop database if available
if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi
