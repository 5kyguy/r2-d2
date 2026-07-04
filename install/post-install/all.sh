#!/bin/bash

run_logged $R2D2_INSTALL/post-install/hibernation.sh
run_logged $R2D2_INSTALL/post-install/pacman.sh
source $R2D2_INSTALL/post-install/allow-reboot.sh
source $R2D2_INSTALL/post-install/finished.sh
