#!/bin/bash

echo "Fix LUKS boot keyboard reliability: mkinitcpio hooks, Plymouth fonts, rootdelay, resume offset"

# Load amdgpu after LUKS decrypt so Plymouth password input is not racing early KMS.
if [[ -f /etc/mkinitcpio.conf.d/r2-d2_hooks.conf ]]; then
  sudo sed -i 's/^HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt/HOOKS=(base udev plymouth keyboard autodetect microcode modconf keymap consolefont block encrypt kms/' /etc/mkinitcpio.conf.d/r2-d2_hooks.conf
fi

# Plymouth theme fonts must match fonts bundled in the initramfs.
if [[ -d /usr/share/plymouth/themes/r2-d2 ]]; then
  sudo cp "$R2D2_PATH/default/plymouth/r2-d2.plymouth" /usr/share/plymouth/themes/r2-d2/r2-d2.plymouth
fi

# Give USB hubs time to enumerate before the LUKS prompt.
sudo mkdir -p /etc/limine-entry-tool.d
sudo cp "$R2D2_PATH/default/limine/rootdelay.conf" /etc/limine-entry-tool.d/rootdelay.conf

# Repair hibernation resume params when resume_offset was written without root.
SWAP_FILE="/swap/swapfile"
RESUME_DROP_IN="/etc/limine-entry-tool.d/resume.conf"
if [[ -f /etc/mkinitcpio.conf.d/r2-d2_resume.conf ]] && [[ -f $SWAP_FILE ]]; then
  if [[ ! -f $RESUME_DROP_IN ]] || grep -q 'resume_offset=$' "$RESUME_DROP_IN" || grep -q 'resume_offset=""' "$RESUME_DROP_IN"; then
    sudo swapon -p 0 "$SWAP_FILE" 2>/dev/null
    RESUME_DEVICE=$(findmnt -no SOURCE -T "$SWAP_FILE" | sed 's/\[.*\]//')
    RESUME_OFFSET=$(sudo btrfs inspect-internal map-swapfile -r "$SWAP_FILE")
    if [[ -n $RESUME_DEVICE && -n $RESUME_OFFSET ]]; then
      echo "KERNEL_CMDLINE[default]+=\" resume=$RESUME_DEVICE resume_offset=$RESUME_OFFSET\"" | sudo tee "$RESUME_DROP_IN" >/dev/null
    fi
  fi
fi

if command -v limine-update &>/dev/null; then
  sudo limine-update
fi
