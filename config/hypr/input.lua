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
  -- Sliding past the last occupied workspace opens one empty one. A further
  -- swipe from that empty workspace does not open another.
  gestures = {
    workspace_swipe_create_new = true,
  },
})

-- Scroll nicely in the terminal
hl.window_rule({
  match = { class = "Alacritty" },
  scroll_touchpad = 1.5,
})

-- Three-finger swipe slides with the fingers and can rest between workspaces.
-- It only visits workspaces that exist. Empty gaps are not kept (see
-- monitors.lua), so the slide runs across occupied workspaces and one new
-- empty workspace after the last of those.
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})
