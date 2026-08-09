#!/bin/bash

# Copy over the keyboard layout that's been set in Arch during install to Hyprland

conf="/etc/vconsole.conf"
hyprconf="$HOME/.config/hypr/input.lua"

if [[ ! -f $hyprconf ]]; then
  exit 0
fi

if grep -q '^XKBLAYOUT=' "$conf"; then
  layout=$(grep '^XKBLAYOUT=' "$conf" | cut -d= -f2 | tr -d '"')
  # Insert kb_layout before kb_options inside the input table.
  if grep -q 'kb_layout' "$hyprconf"; then
    sed -i "s/kb_layout = \"[^\"]*\"/kb_layout = \"$layout\"/" "$hyprconf"
  else
    sed -i "/kb_options/i\\    kb_layout = \"$layout\"," "$hyprconf"
  fi
fi

if grep -q '^XKBVARIANT=' "$conf"; then
  variant=$(grep '^XKBVARIANT=' "$conf" | cut -d= -f2 | tr -d '"')
  if grep -q 'kb_variant' "$hyprconf"; then
    sed -i "s/kb_variant = \"[^\"]*\"/kb_variant = \"$variant\"/" "$hyprconf"
  else
    sed -i "/kb_options/i\\    kb_variant = \"$variant\"," "$hyprconf"
  fi
fi
