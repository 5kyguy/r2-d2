-- Control your input devices
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
  input = {
    kb_layout = "us",
    -- Caps → Super via keyd (default/keyd/default.conf). caps:none blocks lock state.
    kb_options = "caps:none",
    repeat_rate = 40,
    repeat_delay = 600,
    numlock_by_default = true,
    sensitivity = 0.45,
    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
      scroll_factor = 0.4,
      disable_while_typing = true,
    },
  },
})

-- Scroll nicely in the terminal
hl.window_rule({
  match = { class = "Alacritty" },
  scroll_touchpad = 1.5,
})

-- Enable touchpad gestures for changing workspaces
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})
