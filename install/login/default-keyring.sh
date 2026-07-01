#!/bin/bash

KEYRING_DIR="$HOME/.local/share/keyrings"
KEYRING_FILE="$KEYRING_DIR/Default_keyring.keyring"
WRONG_KEYRING="$KEYRING_DIR/Default_Keyring.keyring"
DEFAULT_FILE="$KEYRING_DIR/default"

mkdir -p "$KEYRING_DIR"

# pam_gnome_keyring creates an encrypted login keyring with different casing;
# it cannot auto-unlock under SDDM autologin and breaks Chromium password stores.
if [[ -f $WRONG_KEYRING ]]; then
  rm -f "$WRONG_KEYRING"
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
fi

printf 'Default_keyring\n' >"$DEFAULT_FILE"

chmod 700 "$KEYRING_DIR"
chmod 644 "$DEFAULT_FILE"
