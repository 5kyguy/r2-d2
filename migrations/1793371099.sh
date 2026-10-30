#!/bin/bash

echo "Retire the pre-r2-d2 den-den-mushi user unit"

# Autostart owns the daemon lifecycle now; a leftover user unit from the
# manual install would start a second copy.
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/den-den-mushi.service" ]]; then
  systemctl --user disable --now den-den-mushi.service 2>/dev/null || true
  rm -f "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/den-den-mushi.service"
  systemctl --user daemon-reload 2>/dev/null || true
fi
