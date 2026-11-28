#!/bin/bash

echo "Restore the WirePlumber A2DP script lost with the migration-history wipe"

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
script="$R2D2_PATH/default/wireplumber/scripts/bluetooth-prefer-a2dp.lua"
target_dir="$HOME/.local/share/wireplumber/scripts"

# Installs and resets restore ~/.config (the conf that requires this script)
# but not ~/.local/share (where it is deployed), so wireplumber crash-loops
# with status 78 at every boot and leaves pipewire a dummy output only.
if [[ ! -f $script ]]; then
  echo "  A2DP script source missing; nothing to do"
  exit 0
fi

mkdir -p "$target_dir"
cp "$script" "$target_dir/bluetooth-prefer-a2dp.lua"
echo "  installed $target_dir/bluetooth-prefer-a2dp.lua"

# Reload the session manager when one is running or has crash-looped, and
# verify it stays up so a bad deploy cannot pass silently again.
wp_state=$(systemctl --user is-active wireplumber.service 2>/dev/null)
if [[ $wp_state == "active" || $wp_state == "failed" ]]; then
  systemctl --user reset-failed wireplumber.service 2>/dev/null || true
  systemctl --user restart wireplumber.service
  # wireplumber is Type=simple: give it a moment to crash before trusting it
  sleep 1
  if ! systemctl --user is-active --quiet wireplumber.service; then
    echo "  wireplumber is not running; check: journalctl --user -u wireplumber" >&2
    exit 1
  fi
  echo "  wireplumber restarted"
fi
