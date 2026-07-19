#!/bin/bash

# Diverge from Omarchy: drop the [omarchy] pacman repo, its GPG key, and the
# omarchy-keyring / omarchy-walker packages. Replace omarchy-walker with the
# upstream AUR `walker` package (same binary, same upstream project) so the
# launcher is never missing. R2-D2 now uses standard Arch mirrors only.

# 1. Keep walker installed. omarchy-walker is a meta package that depends on
#    walker; `pacman -Rns omarchy-walker` would delete walker too. Mark walker
#    as explicitly installed (or install from AUR), then remove the meta
#    package without -s so walker stays.
if pacman -Q walker &>/dev/null; then
  sudo pacman -D --asexplicit walker >/dev/null
else
  r2-d2-pkg-aur-add walker || echo "Could not install AUR walker; omarchy-walker will still be removed." >&2
fi

# 2. Strip the [omarchy] repo block from /etc/pacman.conf (idempotent).
#    Stop before the next [section] header without deleting that header.
if grep -q '^\[omarchy\]' /etc/pacman.conf; then
  sudo awk '
    /^\[omarchy\]/ { skip=1; next }
    /^\[/ { skip=0 }
    !skip { print }
  ' /etc/pacman.conf | sudo tee /etc/pacman.conf.r2d2-tmp >/dev/null
  sudo mv /etc/pacman.conf.r2d2-tmp /etc/pacman.conf
  echo "Removed [omarchy] repo from /etc/pacman.conf"
fi

# 3. Remove omarchy meta packages. Use -R (not -Rns) for omarchy-walker so
#    its dependency `walker` is not removed. Drop keyring with normal helper.
if pacman -Q omarchy-walker &>/dev/null; then
  sudo pacman -R --noconfirm omarchy-walker || true
fi
r2-d2-pkg-drop omarchy-keyring || true

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

# 7. Final safety: if walker is still missing (e.g. this migration already
#    ran with the buggy -Rns path), install it from AUR.
if ! pacman -Q walker &>/dev/null; then
  echo "walker missing after omarchy drop — installing from AUR"
  r2-d2-pkg-aur-add walker || echo "Failed to install walker; Super+Space launcher will not work until it is installed." >&2
fi
