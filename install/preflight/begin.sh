#!/bin/bash

# Ask for sudo credentials before the layout is drawn: a cold-ticket prompt
# prints lines that would shift the monitor's rows and wreck the display.
# The keeper refreshes them for the rest of the install so long phases (AUR
# downloads, model downloads) never outlast sudo's timestamp.
sudo -v
start_sudo_keeper

clear_logo
echo
# The live monitor paints the status bar and log lines below the logo
start_install_log
