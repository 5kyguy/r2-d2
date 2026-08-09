-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors: hyprctl monitors

hl.env("GDK_SCALE", "1")

-- vrr enables FreeSync/VRR — measurable idle-power win on capable AMD panels.
-- No-op on monitors that don't advertise VRR.
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1,
  vrr = 1,
})

-- Presets (for reference; use the script for dynamic layout):
--   r2-d2-hyprland-monitor-layout external-left
--   r2-d2-hyprland-monitor-layout external-right
