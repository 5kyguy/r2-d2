-- Menus and launchers
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("r2-d2-launch-walker"), { description = "Launch apps" })
hl.bind("SUPER + CTRL + E", hl.dsp.exec_cmd("r2-d2-launch-walker -m symbols"), { description = "Emoji picker" })
hl.bind("SUPER + CTRL + SPACE", hl.dsp.exec_cmd("r2-d2-launch-walker -m menus:r2-d2-background-selector --width 800 --minheight 400"), { description = "Background selector" })
hl.bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("r2-d2-menu"), { description = "R2-D2 menu" })
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("r2-d2-menu system"), { description = "System menu" })
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("r2-d2-menu system"), { locked = true, description = "Power menu" })
hl.bind("SUPER + K", hl.dsp.exec_cmd("r2-d2-menu-keybindings"), { description = "Show key bindings" })

-- K-2SO companion (Shift+A is Audio under system settings — use Alt for voice)
hl.bind("SUPER + A", hl.dsp.exec_cmd("r2-d2-k2so-ask"), { description = "Ask K-2SO" })
hl.bind("SUPER + ALT + A", hl.dsp.exec_cmd("r2-d2-k2so-listen"), { description = "K-2SO voice" })

-- System settings (Super + Shift + letter)
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("r2-d2-launch-bluetooth"), { description = "Bluetooth controls" })
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("r2-d2-launch-wifi"), { description = "Wifi controls" })
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("r2-d2-launch-audio"), { description = "Audio controls" })
hl.bind("SUPER + SHIFT + I", hl.dsp.exec_cmd("r2-d2-launch-tui btop"), { description = "Activity" })
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("r2-d2-cmd-screenshot"), { description = "Screenshot" })
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("r2-d2-toggle-waybar"), { description = "Toggle top bar" })
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("r2-d2-toggle-builtin-display"), { description = "Toggle device display" })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("r2-d2-toggle-display-mirror"), { description = "Toggle display mirror" })
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("r2-d2-toggle-notification-silencing"), { description = "Toggle notification silencing" })
hl.bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("r2-d2-menu power"), { description = "Power profile" })
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("r2-d2-hyprland-monitor-layout external-left"), { description = "Apply monitor layout (external left)" })

-- Captures (hardware keys)
hl.bind("PRINT", hl.dsp.exec_cmd("r2-d2-cmd-screenshot"), { description = "Screenshot" })
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("r2-d2-menu screenrecord"), { description = "Screenrecording" })
hl.bind("SUPER + CTRL + PRINT", hl.dsp.exec_cmd("r2-d2-capture-text-extraction"), { description = "Extract text (OCR) from screen" })

-- Voxtype push-to-talk (hold F5). release fires stop reliably.
hl.bind("F5", hl.dsp.exec_cmd("voxtype record start"), { description = "Start dictation (push-to-talk)" })
hl.bind("F5", hl.dsp.exec_cmd("voxtype record stop"), { release = true, description = "Stop dictation (push-to-talk)" })

-- Lid switch: closing disables built-in display ONLY when an external monitor is connected.
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("r2-d2-hw-external-monitors && r2-d2-toggle-builtin-display"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("r2-d2-toggle-builtin-display"), { locked = true })
