#!/bin/bash

if command -v limine &>/dev/null; then
  r2-d2-pkg-aur-add limine-snapper-sync limine-mkinitcpio-hook

  sudo tee /etc/mkinitcpio.conf.d/r2-d2_hooks.conf <<EOF >/dev/null
HOOKS=(base udev plymouth keyboard autodetect microcode modconf keymap consolefont block encrypt kms filesystems fsck btrfs-overlayfs)
EOF
  sudo tee /etc/mkinitcpio.conf.d/thunderbolt_module.conf <<EOF >/dev/null
MODULES+=(thunderbolt)
EOF

  # Detect boot mode
  if [[ -d /sys/firmware/efi ]]; then
    EFI=true
  fi

  # Find config location (known layouts first, then any limine.conf on the
  # ESP). All checks go through sudo: the ESP is often root-only, which makes
  # user-side -f checks and reads fail with permission errors.
  limine_config=""
  for candidate in \
    /boot/EFI/arch-limine/limine.conf \
    /boot/EFI/BOOT/limine.conf \
    /boot/EFI/limine/limine.conf \
    /boot/limine/limine.conf \
    /boot/limine.conf; do
    if sudo test -f "$candidate"; then
      limine_config=$candidate
      break
    fi
  done

  # Unusual ESP layouts: archinstall or manual installs may place the config
  # elsewhere under /boot
  if [[ -z $limine_config ]]; then
    limine_config=$(sudo find /boot -type f -name 'limine.conf' -print -quit 2>/dev/null || true)
  fi

  # Read as root for the same reason; || true because "no cmdline line" (or a
  # closed pipe under pipefail) must fall through to the /proc/cmdline backup,
  # not abort the install.
  CMDLINE=""
  if [[ -n $limine_config ]]; then
    CMDLINE=$(sudo grep "^[[:space:]]*cmdline:" "$limine_config" 2>/dev/null | head -1 | sed 's/^[[:space:]]*cmdline:[[:space:]]*//' || true)
  fi

  # No config anywhere, or no cmdline line in it: this system was booted by
  # that old entry, so /proc/cmdline carries exactly the cmdline to preserve.
  if [[ -z $CMDLINE ]]; then
    echo "No limine.conf cmdline found; using the running kernel's /proc/cmdline."
    CMDLINE=$(cat /proc/cmdline)
  fi

  if [[ -z $CMDLINE ]]; then
    echo "Error: could not determine the kernel cmdline" >&2
    exit 1
  fi

  sudo cp $R2D2_PATH/default/limine/default.conf /etc/default/limine
  sudo sed -i "s|@@CMDLINE@@|$CMDLINE|g" /etc/default/limine

  sudo mkdir -p /etc/limine-entry-tool.d
  sudo cp $R2D2_PATH/default/limine/rootdelay.conf /etc/limine-entry-tool.d/rootdelay.conf

  # Append any drop-in kernel cmdline configs (from hardware fix scripts, etc.)
  for dropin in /etc/limine-entry-tool.d/*.conf; do
    [[ -f $dropin ]] || continue
    cat "$dropin" | sudo tee -a /etc/default/limine >/dev/null
  done

  # UKI and EFI fallback are EFI only
  if [[ -z $EFI ]]; then
    sudo sed -i '/^ENABLE_UKI=/d; /^ENABLE_LIMINE_FALLBACK=/d' /etc/default/limine
  fi

  # Remove the original config file if it's not /boot/limine.conf
  if [[ $limine_config != "/boot/limine.conf" ]] && sudo test -f "$limine_config"; then
    sudo rm "$limine_config"
  fi

  # We overwrite the whole thing knowing the limine-update will add the entries for us
  sudo cp $R2D2_PATH/default/limine/limine.conf /boot/limine.conf

  if ! sudo snapper list-configs 2>/dev/null | grep -q "root"; then
    sudo snapper -c root create-config /
  fi

  if ! sudo snapper list-configs 2>/dev/null | grep -q "home"; then
    sudo snapper -c home create-config /home
  fi

  # Enable quota to allow space-aware algorithms to work
  sudo btrfs quota enable /

  # Tweak default Snapper configs
  sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/{root,home}
  sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' /etc/snapper/configs/{root,home}
  sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/{root,home}
  sudo sed -i 's/^SPACE_LIMIT="0.5"/SPACE_LIMIT="0.3"/' /etc/snapper/configs/{root,home}
  sudo sed -i 's/^FREE_LIMIT="0.2"/FREE_LIMIT="0.3"/' /etc/snapper/configs/{root,home}

  chrootable_systemctl_enable limine-snapper-sync.service limine-snapper-sync
fi

echo "Re-enabling mkinitcpio hooks..."

# Restore the specific mkinitcpio pacman hooks
if [[ -f /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled ]]; then
  sudo mv /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled /usr/share/libalpm/hooks/90-mkinitcpio-install.hook
fi

if [[ -f /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled ]]; then
  sudo mv /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook
fi

echo "mkinitcpio hooks re-enabled"

sudo limine-update

# Verify that limine-update actually added boot entries (root-only ESP: the
# read itself fails as user, which would look like missing entries)
if ! sudo grep -q "^/+" /boot/limine.conf; then
  echo "Error: limine-update failed to add boot entries to /boot/limine.conf" >&2
  exit 1
fi

if [[ -n $EFI ]] && efibootmgr &>/dev/null; then
  # Remove the archinstall-created Limine entry (efivars are root-only too)
  while IFS= read -r bootnum; do
    sudo efibootmgr -b "$bootnum" -B >/dev/null 2>&1 || true
  done < <(sudo efibootmgr | grep -E "^Boot[0-9]{4}\*? Arch Linux Limine" | sed 's/^Boot\([0-9]\{4\}\).*/\1/')
fi
