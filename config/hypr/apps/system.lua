-- Floating windows
hl.window_rule({
  match = { tag = "floating-window" },
  float = true,
})
hl.window_rule({
  match = { tag = "floating-window" },
  center = true,
})
hl.window_rule({
  match = { tag = "floating-window" },
  size = "875 600",
})

hl.window_rule({
  match = { class = "(org.r2d2.bluetui|org.r2d2.impala|org.r2d2.wiremix|org.r2d2.btop|org.r2d2.terminal|org.r2d2.bash|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|R2-D2|About|TUI.float|org.gnome.Totem|org.gnome.eog)" },
  tag = "+floating-window",
})
hl.window_rule({
  match = {
    class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus)",
    title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
  },
  tag = "+floating-window",
})
hl.window_rule({
  match = { class = "org.gnome.Calculator" },
  float = true,
})

-- Fullscreen screensaver
hl.window_rule({
  match = { class = "org.r2d2.screensaver" },
  fullscreen = true,
})
hl.window_rule({
  match = { class = "org.r2d2.screensaver" },
  float = true,
})
hl.window_rule({
  match = { class = "org.r2d2.screensaver" },
  animation = "slide",
})

-- Popped window rounding
hl.window_rule({
  match = { tag = "pop" },
  rounding = 8,
})

-- Prevent idle while open
hl.window_rule({
  match = { tag = "noidle" },
  idle_inhibit = "always",
})
