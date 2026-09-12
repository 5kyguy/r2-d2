#!/bin/bash

# Install passwordless sudoers for DNS presets and timezone changes, plus the
# /usr/local/bin wrapper that sudoers/pkexec invoke.

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
install_sudoers "$R2D2_PATH/default/etc/sudoers.d/r2-d2-dns" /etc/sudoers.d/r2-d2-dns
install_sudoers "$R2D2_PATH/default/etc/sudoers.d/r2-d2-tzupdate" /etc/sudoers.d/r2-d2-tzupdate
