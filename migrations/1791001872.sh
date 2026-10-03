#!/bin/bash

echo "Use the icon art for the screensaver"

mkdir -p ~/.config/r2-d2/branding
cp "${R2D2_PATH:-$HOME/.local/share/r2-d2}/assets/icon.txt" ~/.config/r2-d2/branding/screensaver.txt
