#!/bin/bash

stop_install_log

echo_in_style() {
  echo "$1" | tte --canvas-width 0 --anchor-text c --frame-rate 640 print
}

clear
echo
tte -i ~/.local/share/r2-d2/assets/logo.txt --canvas-width 0 --anchor-text c --frame-rate 920 laseretch
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

# Remove passwordless-reboot sudoers file created by allow-reboot.sh
if sudo test -f /etc/sudoers.d/99-r2-d2-installer-reboot; then
  sudo rm -f /etc/sudoers.d/99-r2-d2-installer-reboot &>/dev/null
fi

# Exit gracefully if user chooses not to reboot
if gum confirm --padding "0 0 0 $((PADDING_LEFT + 32))" --show-help=false --default --affirmative "Reboot Now" --negative "" ""; then
  # Clear screen to hide any shutdown messages
  clear

  sudo reboot 2>/dev/null
fi
