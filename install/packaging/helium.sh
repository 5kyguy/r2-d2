#!/bin/bash

# Install Helium browser as AppImage (avoids AUR helium-browser which builds clang/llvm).
# Adds desktop entry and icon for Walker.

set -e

HELIUM_URL="https://github.com/imputnet/helium-linux/releases/download/0.9.4.1/helium-0.9.4.1-x86_64.AppImage"
HELIUM_DIR="$HOME/.local/share/omarchy/helium"
HELIUM_APPIMAGE="$HELIUM_DIR/helium.AppImage"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$HOME/.local/share/applications"
ICON_DIR="$APPS_DIR/icons"

mkdir -p "$HELIUM_DIR" "$BIN_DIR" "$ICON_DIR"

# Download AppImage if missing or outdated
need_download=true
if [[ -f $HELIUM_APPIMAGE ]]; then
  # Keep existing if present (user can delete to force re-download)
  need_download=false
fi

if [[ $need_download == true ]]; then
  echo "Downloading Helium AppImage..."
  curl -fsSL -o "$HELIUM_APPIMAGE" "$HELIUM_URL"
  chmod +x "$HELIUM_APPIMAGE"
fi

# Symlink into PATH so `helium` command works (omarchy-webapp-install checks command -v helium)
ln -sf "$HELIUM_APPIMAGE" "$BIN_DIR/helium"

# Extract icon from AppImage if not already present
if [[ ! -f $ICON_DIR/helium.png ]]; then
  extract_dir=$(mktemp -d)
  trap 'rm -rf $extract_dir' EXIT
  (cd "$extract_dir" && "$HELIUM_APPIMAGE" --appimage-extract 2>/dev/null) || true
  if [[ -f $extract_dir/squashfs-root/.DirIcon ]]; then
    cp "$extract_dir/squashfs-root/.DirIcon" "$ICON_DIR/helium.png"
  else
    icon_candidate=$(find "$extract_dir" -type f \( -name ".DirIcon" -o -name "helium*.png" \) 2>/dev/null | head -1)
    [[ -n $icon_candidate ]] && cp "$icon_candidate" "$ICON_DIR/helium.png"
  fi
fi

# Desktop entry for Walker
DESKTOP_FILE="$APPS_DIR/helium.desktop"
# Use path for Icon if we have one, else theme icon
if [[ -f $ICON_DIR/helium.png ]]; then
  ICON_SPEC="$ICON_DIR/helium.png"
else
  ICON_SPEC="web-browser"
fi

cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Helium
Comment=Privacy-focused browser
Exec=$BIN_DIR/helium
Icon=$ICON_SPEC
Terminal=false
Categories=Network;WebBrowser;
StartupNotify=true
StartupWMClass=helium
EOF

chmod +x "$DESKTOP_FILE"
