#!/bin/bash

# Deploy WirePlumber lua scripts from default/wireplumber/scripts to the user
# script search path. The conf in config/wireplumber/ requires these
# components: without the script, wireplumber crash-loops at boot (status 78)
# and leaves pipewire a dummy output only — no sinks, no audio.
# default/wireplumber/wireplumber.conf.d/ is deliberately NOT deployed: soft
# mixing is opt-in.

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
src_dir="$R2D2_PATH/default/wireplumber/scripts"
dest_dir="$HOME/.local/share/wireplumber/scripts"

if [[ ! -d $src_dir ]]; then
  echo "No WirePlumber scripts to deploy"
  exit 0
fi

mkdir -p "$dest_dir"
cp -R "$src_dir"/. "$dest_dir"/
echo "deployed WirePlumber scripts to $dest_dir"

# Pick the scripts up without a reboot when a session manager already runs
# (fresh installs run without a session; repairs and resets run inside one).
wp_state=$(systemctl --user is-active wireplumber.service 2>/dev/null || true)
if [[ $wp_state == "active" || $wp_state == "failed" ]]; then
  systemctl --user reset-failed wireplumber.service 2>/dev/null || true
  systemctl --user restart wireplumber.service
  # wireplumber is Type=simple: give it a moment to crash before trusting it
  sleep 1
  if ! systemctl --user is-active --quiet wireplumber.service; then
    echo "wireplumber is not running; check: journalctl --user -u wireplumber" >&2
    exit 1
  fi
  echo "wireplumber restarted"
fi
