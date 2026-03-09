#!/bin/bash

# Copy over user-editable R2-D2 configs
mkdir -p ~/.config
cp -R ~/.local/share/r2-d2/config/* ~/.config/

# Use bashrc from config
cp ~/.config/bashrc ~/.bashrc
