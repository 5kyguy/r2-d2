#!/bin/bash

if ! r2d2_is_server; then
  run_logged $R2D2_INSTALL/post-install/hibernation.sh
fi

run_logged $R2D2_INSTALL/post-install/pacman.sh
source $R2D2_INSTALL/post-install/allow-reboot.sh

if r2d2_is_server; then
  run_logged $R2D2_INSTALL/first-run/server.sh
  sudo rm -f /etc/sudoers.d/first-run
  rm -f ~/.local/state/r2-d2/first-run.mode
fi

source $R2D2_INSTALL/post-install/finished.sh