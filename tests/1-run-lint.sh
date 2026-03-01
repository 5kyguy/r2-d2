#!/usr/bin/env bash
# Lint all shell and TOML files in bin/, default/, install/, config/, and root boot.sh / install.sh.
# Shell: shellcheck. TOML: taplo lint.
#
# By default only shellcheck "warning" and "error" are shown. For full lint (info/style too):
#   SHELLCHECK_SEVERITY=style ./tests/1-run-lint.sh
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
	shellcheck -S "${SHELLCHECK_SEVERITY:-warning}" "${shell_files[@]}"
fi

if ((${#toml_files[@]} > 0)); then
	taplo lint "${toml_files[@]}"
fi
