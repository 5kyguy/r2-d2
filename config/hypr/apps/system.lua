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
  match = { class = "(org.r2d2.btop|org.r2d2.terminal|org.r2d2.bash|org.pwmt.zathura|R2-D2|About|TUI.float)" },
  tag = "+floating-window",
})
hl.window_rule({
  match = { class = "dev.tensaku.Tensaku" },
  float = true,
})
hl.window_rule({
  match = { class = "dev.tensaku.Tensaku" },
  center = true,
})
hl.window_rule({
  match = { class = "^io\\.github\\.tsouth89\\.omaroll$", title = ".* · Omaroll" },
  float = true,
})
hl.window_rule({
  match = { class = "^io\\.github\\.tsouth89\\.omaroll$", title = ".* · Omaroll" },
  center = true,
})
hl.window_rule({
  match = {
    class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.xfce.thunar)",
    title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
  },
  tag = "+floating-window",
})
hl.window_rule({
  match = { class = "qalculate-gtk" },
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
