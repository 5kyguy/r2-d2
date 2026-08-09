-- Close windows
hl.bind("SUPER + W", hl.dsp.window.close(), { description = "Close window" })
hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("r2-d2-hyprland-window-close-all"), { description = "Close all windows" })

-- Control tiling
hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle window floating/tiling" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Full screen" })
hl.bind("SUPER + CTRL + F", hl.dsp.window.fullscreen_state({ internal = 0, client = 2, action = "toggle" }), { description = "Tiled full screen" })
hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Full width" })
hl.bind("SUPER + O", hl.dsp.exec_cmd("r2-d2-hyprland-window-pop"), { description = "Pop window out (float & pin)" })
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Toggle split orientation" })

-- Scratchpad
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("scratchpad"), { description = "Toggle scratchpad" })
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }), { description = "Move window to scratchpad" })

-- Move focus with SUPER + arrow keys
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }), { description = "Move window focus left" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }), { description = "Move window focus right" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }), { description = "Move window focus up" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }), { description = "Move window focus down" })

-- Switch workspaces with SUPER + [1-9; 0]
for i = 1, 10 do
  local code = 9 + i -- code:10 .. code:19
  hl.bind("SUPER + code:" .. code, hl.dsp.focus({ workspace = i }), { description = "Switch to workspace " .. i })
  hl.bind("SUPER + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = i }), { description = "Move window to workspace " .. i })
end

-- TAB between workspaces
hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
hl.bind("SUPER + CTRL + TAB", hl.dsp.focus({ workspace = "previous" }), { description = "Former workspace" })

-- Scroll through existing workspaces with SUPER + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll active workspace forward" })
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll active workspace backward" })

-- Resize active window
hl.bind("SUPER + code:20", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { description = "Decrease window width" })
hl.bind("SUPER + code:21", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { description = "Increase window width" })
hl.bind("SUPER + SHIFT + code:20", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { description = "Decrease window height" })
hl.bind("SUPER + SHIFT + code:21", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { description = "Increase window height" })

-- Move/resize windows with SUPER + mouse drag
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })
