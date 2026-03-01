#!/bin/bash

chrootable_systemctl_enable() {
  sudo systemctl enable --now $1
}

# Export the function so it's available in subshells
export -f chrootable_systemctl_enable
