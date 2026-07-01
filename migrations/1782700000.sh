#!/bin/bash

echo "Fix GNOME keyring default pointer for Brave/Chromium password store persistence"

KEYRING_DIR="$HOME/.local/share/keyrings"
KEYRING_FILE="$KEYRING_DIR/Default_keyring.keyring"
WRONG_KEYRING="$KEYRING_DIR/Default_Keyring.keyring"
DEFAULT_FILE="$KEYRING_DIR/default"

mkdir -p "$KEYRING_DIR"

if [[ -f $WRONG_KEYRING ]]; then
  rm -f "$WRONG_KEYRING"
  echo "Removed conflicting encrypted keyring: Default_Keyring.keyring"
fi

if [[ ! -f $KEYRING_FILE ]]; then
  cat <<EOF >"$KEYRING_FILE"
[keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=0
lock-on-idle=false
lock-after=false
EOF
  chmod 600 "$KEYRING_FILE"
  echo "Created passwordless Default_keyring.keyring"
fi

if [[ ! -f $DEFAULT_FILE ]] || [[ $(tr -d '[:space:]' <"$DEFAULT_FILE") != "Default_keyring" ]]; then
  printf 'Default_keyring\n' >"$DEFAULT_FILE"
  chmod 644 "$DEFAULT_FILE"
  echo "Set default keyring to Default_keyring"
fi

if rg -q 'pam_gnome_keyring\.so' /etc/pam.d/sddm 2>/dev/null; then
  if sudo sed -i '/pam_gnome_keyring\.so/d' /etc/pam.d/sddm; then
    echo "Removed pam_gnome_keyring from /etc/pam.d/sddm"
  else
    echo "Could not update /etc/pam.d/sddm — run manually:" >&2
    echo "  sudo sed -i '/pam_gnome_keyring\\.so/d' /etc/pam.d/sddm" >&2
  fi
fi

systemctl --user try-restart gnome-keyring-daemon.service 2>/dev/null || true