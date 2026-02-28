# Set links for Nautilus action icons
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg

# Single-theme setup: UI/themes/colors/fonts are applied once via config/ and default/.
# No theme-set or subsequent scripted theme changes.

# Set default background once (first image in default/backgrounds)
if [[ -n ${OMARCHY_PATH:-} ]] && [[ -d "$OMARCHY_PATH/default/backgrounds" ]]; then
  first_bg=$(find "$OMARCHY_PATH/default/backgrounds" -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' \) 2>/dev/null | head -1)
  if [[ -n $first_bg ]]; then
    mkdir -p "$OMARCHY_PATH/default"
    ln -nsf "$first_bg" "$OMARCHY_PATH/default/background"
  fi
fi

rm -rf ~/.config/chromium/SingletonLock

# Add managed policy directories for Chromium and Brave (used by system policy, not theme switching)
sudo mkdir -p /etc/chromium/policies/managed
sudo chmod a+rw /etc/chromium/policies/managed
sudo mkdir -p /etc/brave/policies/managed
sudo chmod a+rw /etc/brave/policies/managed
