#!/bin/bash

# Make repo shell entrypoints executable. Scoped to known script dirs only —
# never a blanket find from cwd (that can chmod unrelated trees if run from
# the wrong place, and must never touch ~/.config or applications/*.desktop).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

chmod_tree() {
  local dir=$1
  [[ -d $dir ]] || return 0
  find "$dir" -type f \( -name '*.sh' -o -path '*/bin/*' \) -print0 |
    xargs -0 -r chmod a+x
}

echo "Making R2-D2 script entrypoints executable under $ROOT"

# Top-level installers
[[ -f boot.sh ]] && chmod a+x boot.sh
[[ -f install.sh ]] && chmod a+x install.sh

# Commands on PATH after install
chmod_tree bin

# Install / migration / helper scripts
chmod_tree install
chmod_tree migrations
chmod_tree scripts
chmod_tree hooks

echo "Done."
