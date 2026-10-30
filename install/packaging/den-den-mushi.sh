#!/bin/bash

# Build den-den-mushi and install the binary to ~/.local/bin.
# https://github.com/5kyguy/den-den-mushi

set -euo pipefail

REV=cb60ce6211bbb7e3f7a9a2fed651bd3e9040e385
BIN="${HOME}/.local/bin/den-den-mushi"
STAMP="${XDG_STATE_HOME:-$HOME/.local/state}/r2-d2/den-den-mushi-rev"

if [[ -x $BIN && -f $STAMP && $(<"$STAMP") == "$REV" ]]; then
  echo "den-den-mushi ${REV:0:12} is already installed"
else
  r2-d2-pkg-add rust gtk4 gtk4-layer-shell ttf-jetbrains-mono-nerd
  cargo install --locked --force \
    --git https://github.com/5kyguy/den-den-mushi.git \
    --rev "$REV" \
    --root "${HOME}/.local" \
    den-den-mushi
  mkdir -p "$(dirname "$STAMP")"
  printf '%s\n' "$REV" >"$STAMP"
fi

if [[ -n ${WAYLAND_DISPLAY:-} && -x $BIN ]]; then
  setsid -f uwsm-app -- "$BIN" --replace >/dev/null 2>&1 \
    || setsid -f "$BIN" --replace >/dev/null 2>&1 \
    || true
fi
