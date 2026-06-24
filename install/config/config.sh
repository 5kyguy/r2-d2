#!/bin/bash

# Copy over user-editable R2-D2 configs
mkdir -p ~/.config
cp -R "$(r2d2_config_dir)"/* ~/.config/

# Use bashrc from config
cp ~/.config/bashrc ~/.bashrc