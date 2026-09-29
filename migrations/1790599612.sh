#!/bin/bash

echo "Install Manrope for notifications"

font_dir="${R2D2_PATH:-$HOME/.local/share/r2-d2}/default/config"
mkdir -p "$HOME/.local/share/fonts"
cp "$font_dir/manrope-variable.ttf" "$font_dir/manrope-OFL.txt" "$HOME/.local/share/fonts/"
fc-cache -f
