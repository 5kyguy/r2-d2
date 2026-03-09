#!/bin/bash

# Set Alacritty as the default terminal for xdg-terminal-exec.
# Both alacritty and ghostty are in base packages; we prefer Alacritty.

mkdir -p ~/.local/share/applications
cp "$R2D2_PATH/applications/Alacritty.desktop" ~/.local/share/applications/
cp "$R2D2_PATH/applications/com.mitchellh.ghostty.desktop" ~/.local/share/applications/
