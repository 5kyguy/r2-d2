#!/bin/bash

# Install named packages (if any), then enable a systemd unit.
chrootable_systemctl_enable() {
  local unit=$1
  shift

  if ((${#@})); then
    r2-d2-pkg-add "$@"
  fi

  if ! systemctl list-unit-files --no-legend "$unit" 2>/dev/null | awk '{print $1}' | grep -qx "$unit"; then
    echo "systemd unit not found: $unit" >&2
    exit 1
  fi

  sudo systemctl enable --now "$unit"
}
