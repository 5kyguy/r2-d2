#!/bin/bash

r2-d2-pkg-add plymouth

if [[ $(plymouth-set-default-theme) != "r2-d2" ]]; then
  sudo cp -r "$HOME/.local/share/r2-d2/default/plymouth" /usr/share/plymouth/themes/r2-d2/
  sudo plymouth-set-default-theme r2-d2
fi
