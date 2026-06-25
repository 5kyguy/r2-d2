#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define R2-D2 locations
export R2D2_PATH="$HOME/.local/share/r2-d2"
export R2D2_INSTALL="$R2D2_PATH/install"
export R2D2_INSTALL_LOG_FILE="/var/log/r2-d2-install.log"
export PATH="$R2D2_PATH/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin${PATH:+:$PATH}"

# Install
source "$R2D2_INSTALL/helpers/all.sh"
source "$R2D2_INSTALL/preflight/all.sh"
source "$R2D2_INSTALL/packaging/all.sh"
source "$R2D2_INSTALL/config/all.sh"
source "$R2D2_INSTALL/login/all.sh"
source "$R2D2_INSTALL/post-install/all.sh"
