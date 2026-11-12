#!/bin/bash

echo "Make Robin the file manager and media viewer; retire Thunar and Omaroll"

# The desktop entry with Robin's mime types must exist before the
# installer can point defaults at it.
r2-d2-refresh-applications || true
update-desktop-database ~/.local/share/applications || true

# Installs from the GitHub release and points directories, images,
# video, and audio at Robin.
r2-d2-install-robin

# Thunar's toolchain and the viewer Robin replaces. gvfs remote mounts
# went with Thunar: Robin browses local disks and UDisks2 devices.
for pkg in thunar thunar-archive-plugin tumbler omaroll gvfs-mtp gvfs-nfs gvfs-smb; do
  if pacman -Q "$pkg" >/dev/null 2>&1; then
    r2-d2-pkg-remove "$pkg" || true
  fi
done
