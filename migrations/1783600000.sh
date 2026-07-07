#!/bin/bash

# Diverge from Omarchy: drop the [omarchy] pacman repo, its GPG key, and the
# omarchy-keyring / omarchy-walker packages. Replace omarchy-walker with the
# upstream AUR `walker` package (same binary, same upstream project) so the
# launcher is never missing. R2-D2 now uses standard Arch mirrors only.

# 1. Install AUR walker FIRST so the launcher stays available after we remove
#    omarchy-walker. Skip if already present.
if ! pacman -Q walker &>/dev/null; then
  r2-d2-pkg-aur-add walker || echo "Could not install AUR walker; omarchy-walker will still be removed." >&2
fi

# 2. Strip the [omarchy] repo block from /etc/pacman.conf (idempotent).
if grep -q '^\[omarchy\]' /etc/pacman.conf; then
  # Delete the [omarchy] header line and any directives that follow it until
  # the next section header or end of file.
  sudo sed -i '/^\[omarchy\]/,/^\[/d;/^\[omarchy\]/d' /etc/pacman.conf
  echo "Removed [omarchy] repo from /etc/pacman.conf"
fi

# 3. Remove the omarchy packages (no-op if already gone).
r2-d2-pkg-drop omarchy-walker omarchy-keyring || true

# 4. Reset mirrorlist to the repo default (standard Arch mirror).
if [[ -f $R2D2_PATH/default/pacman/mirrorlist ]]; then
  sudo cp -f "$R2D2_PATH/default/pacman/mirrorlist" /etc/pacman.d/mirrorlist
fi

# 5. Optionally forget the Omarchy signing key from the local keyring.
#    Non-fatal: pacman-key --delete prompts if the key is in the trustdb,
#    so guard it and swallow errors.
OMARCHY_KEY='40DFB630FF42BCFFB047046CF0134EE680CAC571'
if sudo pacman-key --list-keys "$OMARCHY_KEY" &>/dev/null; then
  echo "y" | sudo pacman-key --delete "$OMARCHY_KEY" &>/dev/null || true
fi

# 6. Refresh the local pacman DB with the omarchy-free repo set.
sudo pacman -Sy || true
