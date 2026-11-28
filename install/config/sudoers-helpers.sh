#!/bin/bash

# Install every passwordless sudoers drop-in from default/etc/sudoers.d, plus
# the /usr/local/bin wrapper that sudoers/pkexec invoke. Idempotent: install,
# repair, and reset runs re-validate and re-install, so a lost drop-in
# self-heals instead of waiting for a migration that may never run.

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"

install_sudoers() {
  local src=$1 dest=$2
  local tmp

  tmp=$(mktemp)
  cp "$src" "$tmp"
  if ! visudo -cf "$tmp" >/dev/null 2>&1; then
    echo "Invalid sudoers draft from $src; refusing to install" >&2
    rm -f "$tmp"
    return 1
  fi
  sudo install -Dm440 -o root -g root "$tmp" "$dest"
  rm -f "$tmp"
}

sudo install -Dm755 "$R2D2_PATH/bin/r2-d2-setup-dns" /usr/local/bin/r2-d2-setup-dns

shopt -s nullglob
failed=0
for src in "$R2D2_PATH"/default/etc/sudoers.d/*; do
  install_sudoers "$src" "/etc/sudoers.d/$(basename "$src")" || failed=1
done
shopt -u nullglob

exit $failed
