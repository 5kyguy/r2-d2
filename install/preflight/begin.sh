#!/bin/bash

clear_logo
echo
# Ask for sudo credentials up front, while the screen is still quiet. The
# keeper refreshes them for the rest of the install so long phases (AUR
# downloads, model downloads) never outlast sudo's timestamp.
sudo -v
start_sudo_keeper
# The live monitor paints the status bar and log lines below the logo
start_install_log
