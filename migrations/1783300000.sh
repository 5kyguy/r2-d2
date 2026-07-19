#!/bin/bash

# Enable pause_media in voxtype on existing installs so music doesn't bleed
# into dictation transcripts the agent receives. Port of omarchy b317bd53.

VOXTYPE_CONF="$HOME/.config/voxtype/config.toml"

if [[ ! -f $VOXTYPE_CONF ]] || ! command -v voxtype &>/dev/null; then
  exit 0
fi

if grep -q '^pause_media' "$VOXTYPE_CONF"; then
  sed -i 's/^pause_media.*/pause_media = true/' "$VOXTYPE_CONF"
else
  # Insert under the [audio] section, or append [audio] if missing
  if grep -q '^\[audio\]' "$VOXTYPE_CONF"; then
    sed -i '/^\[audio\]/a pause_media = true' "$VOXTYPE_CONF"
  else
    printf '\n[audio]\npause_media = true\n' >>"$VOXTYPE_CONF"
  fi
fi

echo "Enabled pause_media in $VOXTYPE_CONF"
