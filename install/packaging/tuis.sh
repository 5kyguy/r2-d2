#!/bin/bash

ICON_DIR="$HOME/.local/share/applications/icons"

r2-d2-tui-install "Disk Usage" "bash -c 'dust -r; read -n 1 -s'" float "$ICON_DIR/DiskUsage.png"
r2-d2-tui-install "Docker" "lazydocker" tile "$ICON_DIR/Docker.png"
