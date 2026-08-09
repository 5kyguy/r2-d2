-- hypridle (idle lock) off by default; use r2-d2-toggle-idle to enable

hl.on("hyprland.start", function()
  -- Clear built-in display toggle state on login (session-only, resets on reboot)
  hl.exec_cmd("rm -f ~/.local/state/r2-d2/toggles/builtin-display-disabled")
  hl.exec_cmd("uwsm-app -- mako")
  hl.exec_cmd("uwsm-app -- waybar")
  hl.exec_cmd("uwsm-app -- swaybg -i ~/.local/share/r2-d2/backgrounds/@background -m fill")
  hl.exec_cmd("uwsm-app -- swayosd-server")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("r2-d2-cmd-first-run")
  -- Set the power profile on boot (udev rules only fire on changes).
  hl.exec_cmd("r2-d2-powerprofiles-init")
  -- Slow app launch fix -- set systemd vars
  hl.exec_cmd("bash -c 'systemctl --user import-environment $(env | cut -d\"=\" -f 1)'")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")

  -- Apply external-left monitor layout when 2 monitors (e.g. HDMI left of laptop)
  hl.timer(function()
    hl.exec_cmd("r2-d2-hyprland-monitor-layout external-left 2>/dev/null || true")
  end, { timeout = 2000, type = "oneshot" })
end)
