#!/bin/bash
# Format all shell and TOML files in bin/, default/, install/, config/, and root boot.sh / install.sh.
# Style follows .editorconfig: indent_size=2, indent_style=space, etc.
# Shell: shfmt. TOML: taplo.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

shell_files=()
while IFS= read -r -d '' f; do shell_files+=("$f"); done < <(find bin -type f -print0 2>/dev/null || true)
while IFS= read -r -d '' f; do shell_files+=("$f"); done < <(find default install -type f -name '*.sh' -print0 2>/dev/null || true)
for f in boot.sh install.sh; do
  [[ -f $f ]] && shell_files+=("$f")
done

toml_files=()
while IFS= read -r -d '' f; do toml_files+=("$f"); done < <(find config default -type f -name '*.toml' -print0 2>/dev/null || true)
for f in *.toml; do
  [[ -f $f ]] && toml_files+=("$f")
done

if ((${#shell_files[@]} > 0)); then
  shfmt -w -s -i 2 "${shell_files[@]}"
fi

if ((${#toml_files[@]} > 0)); then
  taplo format -o indent_string="  " "${toml_files[@]}"
fi
