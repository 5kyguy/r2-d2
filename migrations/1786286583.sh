#!/bin/bash

echo "Migrate Hyprland compositor config from hyprlang (.conf) to Lua (.lua)"

# Normal update sync already copies config/hypr/*.lua into ~/.config/hypr/.
# Remove stale compositor .conf modules so users are not confused, and so a
# leftover hyprland.conf cannot be mistaken for the active entrypoint.
# Keep hyprlock / hypridle / hyprsunset / xdph as .conf (still hyprlang).

HYPR="$HOME/.config/hypr"

if [[ -d $HYPR ]]; then
  # Entrypoint and top-level compositor modules
  for f in \
    hyprland.conf \
    autostart.conf \
    envs.conf \
    input.conf \
    monitors.conf \
    windows.conf \
    looknfeel.conf \
    apps.conf \
    bindings.conf
  do
    rm -f "$HYPR/$f"
  done

  # Bindings modules (including orphaned legacy tiling.conf)
  for f in \
    tiling.conf \
    tiling-v2.conf \
    utilities.conf \
    apps.conf \
    clipboard.conf \
    media.conf
  do
    rm -f "$HYPR/bindings/$f"
  done

  # App window-rule modules
  for f in \
    browser.conf \
    hyprshot.conf \
    localsend.conf \
    pip.conf \
    steam.conf \
    system.conf \
    terminals.conf \
    walker.conf \
    webcam-overlay.conf
  do
    rm -f "$HYPR/apps/$f"
  done
fi

# Ensure looknfeel.lua exists after theme render (update runs theme-apply first).
if [[ ! -f $HYPR/looknfeel.lua && -f $R2D2_PATH/config/hypr/looknfeel.lua ]]; then
  mkdir -p "$HYPR"
  cp "$R2D2_PATH/config/hypr/looknfeel.lua" "$HYPR/looknfeel.lua"
fi

if [[ ! -f $HYPR/hyprland.lua && -f $R2D2_PATH/config/hypr/hyprland.lua ]]; then
  mkdir -p "$HYPR"
  cp "$R2D2_PATH/config/hypr/hyprland.lua" "$HYPR/hyprland.lua"
fi

echo
echo "Hyprland Lua config is ready under ~/.config/hypr/hyprland.lua."
echo "Restart Hyprland to activate it (log out, uwsm stop, or reboot)."
echo "hyprctl reload alone will NOT switch a session that started on hyprland.conf."
