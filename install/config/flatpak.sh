#!/bin/bash

# Add Flathub remote so Flatpak apps can be installed
r2-d2-pkg-add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
