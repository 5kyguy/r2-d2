#!/bin/bash

echo "Repair WatchCat: nethogs, scoped sudoers, and the user service"

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"

# nethogs captures packets and needs root; the daemon shells out to it.
r2-d2-pkg-add nethogs >/dev/null 2>&1 || true

# Scoped sudoers: passwordless /usr/bin/nethogs for %wheel, nothing else.
# /etc/sudoers.d is 0750 root:root, so the "already installed" check must
# run under sudo; a failed install exits non-zero so the rule is retried
# on the next update instead of being marked done silently.
src="$R2D2_PATH/default/etc/sudoers.d/r2-d2-watchcat"
dest="/etc/sudoers.d/r2-d2-watchcat"

if [[ ! -f $src ]]; then
  echo "  WatchCat sudoers source missing; nothing to do"
elif sudo test -f $dest && sudo cmp -s "$src" "$dest"; then
  echo "  sudoers rule already installed"
else
  tmp=$(mktemp)
  cp "$src" "$tmp"
  if ! visudo -cf "$tmp" >/dev/null 2>&1; then
    echo "  Invalid sudoers draft; refusing to install $dest" >&2
    rm -f "$tmp"
    exit 1
  fi
  if ! sudo install -Dm440 -o root -g root "$tmp" "$dest"; then
    echo "  Could not install $dest (sudo declined?); re-run to retry" >&2
    rm -f "$tmp"
    exit 1
  fi
  rm -f "$tmp"
  echo "  installed $dest"
fi

# User service (idempotent): unit file, enable, start if a session is up.
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
