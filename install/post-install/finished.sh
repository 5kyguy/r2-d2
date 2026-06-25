#!/bin/bash

# Install is done — cosmetic effects must not trip the error handler.
set +e
set +o pipefail

stop_install_log

LOGO_PATH="${R2D2_PATH:-$HOME/.local/share/r2-d2}/assets/logo.txt"

echo_in_style() {
  local msg=$1
  if command -v tte &>/dev/null; then
    echo "$msg" | tte --canvas-width 0 --anchor-text c --frame-rate 640 print 2>/dev/null || echo "$msg"
  else
    echo "$msg"
  fi
}

show_finish_logo() {
  if command -v tte &>/dev/null && [[ -f $LOGO_PATH ]]; then
    tte -i "$LOGO_PATH" --canvas-width 0 --anchor-text c --frame-rate 920 laseretch 2>/dev/null || cat "$LOGO_PATH"
  elif [[ -f $LOGO_PATH ]]; then
    cat "$LOGO_PATH"
  fi
}

clear
echo
show_finish_logo
echo

# Display installation time (from log or persisted file) and persist for later
TOTAL_TIME=""
if [[ -f $R2D2_INSTALL_LOG_FILE ]] && grep -q "Total:" "$R2D2_INSTALL_LOG_FILE" 2>/dev/null; then
  TOTAL_TIME=$(tail -n 20 "$R2D2_INSTALL_LOG_FILE" | grep "^Total:" | sed 's/^Total:[[:space:]]*//')
fi
if [[ -z $TOTAL_TIME ]] && [[ -f $HOME/.config/r2-d2/install-duration ]]; then
  TOTAL_TIME=$(cat "$HOME/.config/r2-d2/install-duration")
fi
if [[ -n $TOTAL_TIME ]]; then
  echo
  echo_in_style "Installed in $TOTAL_TIME"
  mkdir -p "$HOME/.config/r2-d2"
  echo -n "$TOTAL_TIME" >"$HOME/.config/r2-d2/install-duration"
else
  echo_in_style "Finished installing"
fi

# Exit gracefully if user chooses not to reboot
if gum confirm --padding "0 0 0 $((PADDING_LEFT))" --show-help=false --default --affirmative "Reboot Now" --negative "" ""; then
  # Remove passwordless-reboot sudoers only when actually rebooting
  if sudo test -f /etc/sudoers.d/99-r2-d2-installer-reboot; then
    sudo rm -f /etc/sudoers.d/99-r2-d2-installer-reboot &>/dev/null
  fi

  clear
  sudo reboot 2>/dev/null
fi

# Clean up passwordless-reboot sudoers if the user declined
if sudo test -f /etc/sudoers.d/99-r2-d2-installer-reboot; then
  sudo rm -f /etc/sudoers.d/99-r2-d2-installer-reboot &>/dev/null
fi
