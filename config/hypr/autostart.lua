-- hypridle (idle lock) off by default; use r2-d2-toggle-idle to enable

hl.on("hyprland.start", function()
  -- Clear built-in display toggle state on login (session-only, resets on reboot)
  hl.exec_cmd("rm -f ~/.local/state/r2-d2/toggles/builtin-display-disabled ~/.local/state/r2-d2/toggles/builtin-display-clamshell")
  hl.exec_cmd("uwsm-app -- r2-d2-launch-shell")
  hl.exec_cmd("uwsm-app -- swaybg -i ~/.local/share/r2-d2/backgrounds/@background -m fill")
  hl.exec_cmd("uwsm-app -- udiskie --automount --no-notify --no-tray")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("r2-d2-cmd-first-run")
  -- Set the power profile on boot (udev rules only fire on changes).
  hl.exec_cmd("r2-d2-powerprofiles-init")
  -- Slow app launch fix -- set systemd vars
  hl.exec_cmd("bash -c 'systemctl --user import-environment $(env | cut -d\"=\" -f 1)'")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  -- Reconcile clamshell / docked display state across hotplug
  hl.exec_cmd("uwsm-app -- r2-d2-hyprland-monitor-watch")

  -- Reapply the last saved monitor layout, or external-left when none is saved.
  hl.timer(function()
    hl.exec_cmd("r2-d2-hyprland-monitor-profile apply-active || r2-d2-hyprland-monitor-layout external-left 2>/dev/null || true")
  end, { timeout = 2000, type = "oneshot" })
end)

-- looknfeel.lua is rewritten on every wallpaper change, and Hyprland reloads.
-- That re-applies monitors.lua. Put a manually disabled laptop panel back off,
-- then restore a saved layout when no display toggle is holding the session.
hl.on("config.reloaded", function()
  hl.exec_cmd("r2-d2-hyprland-monitors-restore --after-reload; r2-d2-hyprland-monitor-profile apply-active")
end)
