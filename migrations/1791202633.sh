#!/bin/bash

echo "Remove Helium and open web apps in Brave"

desktop_dir="$HOME/.local/share/applications"
shopt -s nullglob
for file in "$desktop_dir"/*.desktop; do
  line=$(grep -m1 '^Exec=' "$file" || true)
  [[ $line =~ ^Exec=(helium|helium-browser)[[:space:]]+--app=\"?([^\"[:space:]]+)\"? ]] || continue
  url="${BASH_REMATCH[2]}"
  tmp=$(mktemp)
  replaced=false
  while IFS= read -r row || [[ -n $row ]]; do
    if [[ $replaced == false && $row == Exec=* ]]; then
      printf 'Exec=r2-d2-launch-webapp %s\n' "$url"
      replaced=true
    else
      printf '%s\n' "$row"
    fi
  done <"$file" >"$tmp"
  mv "$tmp" "$file"
done
shopt -u nullglob

if command -v update-desktop-database >/dev/null; then
  update-desktop-database "$desktop_dir" >/dev/null 2>&1 || true
fi

xdg-settings set default-web-browser brave-origin-nightly.desktop
xdg-mime default brave-origin-nightly.desktop x-scheme-handler/http
xdg-mime default brave-origin-nightly.desktop x-scheme-handler/https

r2-d2-pkg-remove helium-browser-bin

rm -rf "$HOME/.config/net.imput.helium" "$HOME/.cache/net.imput.helium"
