#!/bin/bash

# Copy repo-managed support assets into their live ~/.config locations.

R2D2_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}"
DEFAULT_CONFIG_DIR="$R2D2_PATH/default/config"

mkdir -p ~/.config/systemd/user
cp "$DEFAULT_CONFIG_DIR"/systemd/user/* ~/.config/systemd/user/

mkdir -p ~/.config/walker
cp "$DEFAULT_CONFIG_DIR"/walker/walker.desktop ~/.config/walker/
cp "$DEFAULT_CONFIG_DIR"/walker/restart.conf ~/.config/walker/
mkdir -p ~/.config/walker/themes
cp -R "$DEFAULT_CONFIG_DIR"/walker/themes/. ~/.config/walker/themes/

mkdir -p ~/.config/elephant/menus
cp "$DEFAULT_CONFIG_DIR"/elephant/menus/background_selector.lua ~/.config/elephant/menus/

mkdir -p ~/.config/hyprland-preview-share-picker
cp "$DEFAULT_CONFIG_DIR"/hyprland-preview-share-picker/* ~/.config/hyprland-preview-share-picker/

mkdir -p ~/.config/waybar/indicators
cp "$DEFAULT_CONFIG_DIR"/waybar/indicators/* ~/.config/waybar/indicators/

mkdir -p ~/.config/chromium/extensions/copy-url
cp "$DEFAULT_CONFIG_DIR"/chromium/extensions/copy-url/* ~/.config/chromium/extensions/copy-url/

cp "$DEFAULT_CONFIG_DIR"/xdg-terminals.list ~/.config/
