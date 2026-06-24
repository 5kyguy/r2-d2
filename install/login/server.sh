#!/bin/bash

sudo systemctl disable sddm.service 2>/dev/null || true
sudo systemctl set-default multi-user.target
sudo systemctl enable --now sshd.service

run_logged $R2D2_INSTALL/login/limine-snapper.sh