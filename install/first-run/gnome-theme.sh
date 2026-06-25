#!/bin/bash

r2-d2-pkg-add gnome-themes-extra yaru-icon-theme

gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface icon-theme "Yaru-blue"

sudo gtk-update-icon-cache /usr/share/icons/Yaru
