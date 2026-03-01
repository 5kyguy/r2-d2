#!/bin/bash

# Omarchy logo font for Waybar (optional; skip if not in repo)
mkdir -p ~/.local/share/fonts
if [[ -f ~/.local/share/omarchy/config/omarchy.ttf ]]; then
  cp ~/.local/share/omarchy/config/omarchy.ttf ~/.local/share/fonts/
  fc-cache -f
fi
