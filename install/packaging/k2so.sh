#!/bin/bash

# Build and install K-2SO from the nested k-2so repo and wire r2d2-mcp.

set -euo pipefail

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
K2SO_DIR="${K2SO_DIR:-$R2D2_PATH/k-2so}"

r2-d2-pkg-add nodejs npm

if [[ ! -f $K2SO_DIR/package.json ]]; then
  echo "k-2so source not found at $K2SO_DIR" >&2
  echo "Clone https://github.com/5kyguy/k-2so into that path or set K2SO_DIR." >&2
  exit 1
fi

echo "Building k-2so…"
(cd "$K2SO_DIR" && npm ci && npm run build)

mkdir -p "$HOME/.local/bin"
ln -sf "$K2SO_DIR/dist/cli.js" "$HOME/.local/bin/k2so"

echo "Building r2d2-mcp…"
(cd "$R2D2_PATH/mcp/r2d2" && npm ci && npm run build)

mkdir -p "$HOME/.config/r2-d2"
if [[ ! -f $HOME/.config/r2-d2/k2so.env ]]; then
  cp "$R2D2_PATH/config/r2-d2/k2so.env.example" "$HOME/.config/r2-d2/k2so.env"
  echo "Created ~/.config/r2-d2/k2so.env — add your ZAI_API_KEY"
fi

r2-d2-refresh-config k2so/profile.toml
r2-d2-refresh-config opencode/opencode.json

mkdir -p "$HOME/.config/systemd/user"
cp "$R2D2_PATH/default/config/systemd/user/k2so.service" "$HOME/.config/systemd/user/"

systemctl --user daemon-reload
systemctl --user enable --now k2so.service

echo "K-2SO installed. Hotkeys: Super+A (ask), Super+Shift+A (voice)"
