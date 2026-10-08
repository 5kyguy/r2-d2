#!/bin/bash

echo "Install Omaroll as the image and video viewer, and replace Satty with Tensaku"

r2-d2-pkg-aur-add tensaku-bin
r2-d2-install-omaroll
r2-d2-pkg-remove satty eog totem
