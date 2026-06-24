#!/bin/bash

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
# shellcheck source=../install/helpers/profile.sh
source "$R2D2_PATH/install/helpers/profile.sh"
r2d2_skip_if_server


echo "Simplify defaults: mime types, opencode PATH, remove Discord webapp, drop retired packages"

# Refresh mime defaults (Brave Origin, Totem, Nano, Pinta)
if [[ -f $R2D2_PATH/install/config/mimetypes.sh ]]; then
  bash "$R2D2_PATH/install/config/mimetypes.sh"
fi

# Ensure opencode is on PATH via refreshed bash envs
if ! command -v opencode &>/dev/null && [[ -f $R2D2_PATH/install/packaging/opencode.sh ]]; then
  bash "$R2D2_PATH/install/packaging/opencode.sh"
fi

r2-d2-refresh-config bash/envs

# Remove Discord web app shortcut
rm -f "$HOME/.local/share/applications/Discord.desktop"
rm -f "$HOME/.local/share/applications/icons/Discord.png"

if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# Drop packages no longer in the default stack (no-op if not installed)
for pkg in ghostty omarchy-nvim tree-sitter-cli pear-desktop-bin brave-bin \
  vlc vlc-plugin-ass vlc-plugin-bluray vlc-plugin-dca vlc-plugin-dvd \
  vlc-plugin-ffmpeg vlc-plugin-freetype vlc-plugin-srt; do
  r2-d2-pkg-drop "$pkg" 2>/dev/null || true
done
