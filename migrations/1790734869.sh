#!/bin/bash

echo "Keep Bluetooth headset playback on A2DP and leave the microphone available"

r2d2_path="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
conf_dir="$r2d2_path/config/wireplumber/wireplumber.conf.d"
script="$r2d2_path/default/wireplumber/scripts/bluetooth-prefer-a2dp.lua"

mkdir -p "$HOME/.config/wireplumber/wireplumber.conf.d"
mkdir -p "$HOME/.local/share/wireplumber/scripts"
if [[ -f $conf_dir/bluetooth-a2dp.conf ]]; then
  cp "$conf_dir/bluetooth-a2dp.conf" "$HOME/.config/wireplumber/wireplumber.conf.d/bluetooth-a2dp.conf"
fi
if [[ -f $script ]]; then
  cp "$script" "$HOME/.local/share/wireplumber/scripts/bluetooth-prefer-a2dp.lua"
fi

if systemctl --user is-active --quiet wireplumber.service; then
  systemctl --user restart wireplumber.service
fi
