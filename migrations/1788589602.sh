#!/bin/bash

echo "Move Docker to opt-in group membership (docker group is root-equivalent)"

if id -nG "$USER" | grep -qw docker; then
  R2D2_DEFER_REBOOT=1 r2-d2-remove-security-sudoless-docker
fi
