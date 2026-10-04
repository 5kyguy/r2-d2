#!/bin/bash

echo "Replace Nautilus and GNOME Calculator with Thunar and Qalculate GTK"

r2-d2-pkg-add thunar tumbler qalculate-gtk
r2-d2-pkg-remove nautilus nautilus-python sushi gnome-calculator

if [[ -f /usr/share/applications/thunar.desktop ]]; then
  xdg-mime default thunar.desktop inode/directory
fi
