#!/bin/bash

echo "Install WatchCat: nethogs, scoped sudoers, and the user service"

# nethogs captures packets and needs root; the daemon shells out to it.
r2-d2-pkg-add nethogs >/dev/null 2>&1 || true

# Scoped sudoers: passwordless /usr/bin/nethogs for %wheel, nothing else.
sudoers_file="/etc/sudoers.d/r2-d2-watchcat"
if [[ ! -f $sudoers_file ]]; then
  tmp=$(mktemp)
  cp "$R2D2_PATH/default/etc/sudoers.d/r2-d2-watchcat" "$tmp"
  if visudo -cf "$tmp" >/dev/null 2>&1; then
    sudo install -Dm440 -o root -g root "$tmp" "$sudoers_file"
  else
    echo "Invalid sudoers draft; refusing to install $sudoers_file" >&2
  fi
  rm -f "$tmp"
fi

# User service.
mkdir -p "$HOME/.config/systemd/user"
cp "$R2D2_PATH/default/config/systemd/user/r2-d2-watchcat.service" \
  "$HOME/.config/systemd/user/r2-d2-watchcat.service"

systemctl --user daemon-reload >/dev/null 2>&1 || true

if ! systemctl --user enable r2-d2-watchcat.service >/dev/null 2>&1; then
  wants_dir="$HOME/.config/systemd/user/graphical-session.target.wants"
  mkdir -p "$wants_dir"
  ln -sfn "$HOME/.config/systemd/user/r2-d2-watchcat.service" \
    "$wants_dir/r2-d2-watchcat.service"
fi

if systemctl --user is-active --quiet graphical-session.target; then
  systemctl --user start r2-d2-watchcat.service >/dev/null 2>&1 || true
fi
