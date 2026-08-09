-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

-- App-specific tweaks
require("apps")

-- Fully opaque by default (active and inactive)
hl.window_rule({
  match = { class = ".*" },
  opacity = "1 1",
})

-- Partial opacity only for terminal and file manager
hl.window_rule({
  match = { class = "Alacritty" },
  opacity = "0.98 1",
})
hl.window_rule({
  match = { class = "org.gnome.Nautilus" },
  opacity = "0.98 1",
})
