#!/bin/bash

# Hyprland 0.54+ removed the togglesplit dispatcher; use layoutmsg instead.
echo "Hyprland 0.54+: migrate togglesplit binds to layoutmsg"

for conf in ~/.config/hypr/bindings/tiling-v2.conf ~/.config/hypr/bindings/tiling.conf; do
  if [[ -f $conf ]] && grep -qE ', togglesplit(,|$)' "$conf"; then
    sed -i 's/, togglesplit,*/, layoutmsg, togglesplit/' "$conf"
  fi
done
