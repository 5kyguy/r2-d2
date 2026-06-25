#!/bin/bash

# Give this user privileged input access for dictation tools + xbox controllers to work
if getent group input >/dev/null; then
  sudo usermod -aG input "$USER"
fi
