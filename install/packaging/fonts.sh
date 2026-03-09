#!/bin/bash

# R2-D2 logo font for Waybar use
mkdir -p ~/.local/share/fonts
cp ~/.local/share/r2-d2/default/config/r2-d2.ttf ~/.local/share/fonts/
fc-cache -f
