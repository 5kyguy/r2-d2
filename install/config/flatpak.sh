#!/bin/bash

# Add Flathub remote so Flatpak apps can be installed
# (flatpak is in omarchy-base.packages; xdg-desktop-portal-* already configured)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
