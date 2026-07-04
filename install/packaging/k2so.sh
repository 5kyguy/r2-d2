#!/bin/bash

# Install K-2SO (npm) and wire r2d2-mcp. K-2SO registers via k2so init.

set -euo pipefail

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
K2SO_DIR="${K2SO_DIR:-}"

r2-d2-pkg-add nodejs npm git

if [[ -n $K2SO_DIR && -f $K2SO_DIR/package.json ]]; then
  echo "Building k2so from $K2SO_DIR…"
  (cd "$K2SO_DIR" && npm ci && npm run build)
  npm install -g "$K2SO_DIR"
else
  echo "Installing k2so from npm…"
  npm install -g @5kyguy/k2so
fi

if ! command -v opencode &>/dev/null; then
  echo "Installing OpenCode…"
  bash "$R2D2_PATH/install/packaging/opencode.sh"
fi

echo "Building r2d2-mcp…"
(cd "$R2D2_PATH/mcp/r2d2" && npm ci && npm run build)

mkdir -p "$HOME/.config/k2so" "$HOME/.config/opencode"

r2-d2-ensure-k2so-secrets
r2-d2-merge-k2so-opencode

if command -v k2so &>/dev/null; then
  k2so init
else
  echo "k2so not on PATH after install — run k2so init manually" >&2
fi

mkdir -p "$HOME/.config/systemd/user"
cp "$R2D2_PATH/default/config/systemd/user/k2so.service" "$HOME/.config/systemd/user/"

systemctl --user daemon-reload
systemctl --user enable --now k2so.service

echo "K-2SO installed. Hotkeys: Super+A (ask), Super+Shift+A (voice)"