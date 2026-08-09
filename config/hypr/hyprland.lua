-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/
-- All config lives under ~/.config/hypr/. Edit files here and reload.
-- Compositor entrypoint is hyprland.lua (hyprlang .conf is deprecated).

require("envs")
require("monitors")
require("looknfeel")
require("input")
require("windows")
require("autostart")
require("bindings.media")
require("bindings.clipboard")
require("bindings.tiling-v2")
require("bindings.utilities")
require("bindings.apps")
-- Optional: add overrides or extra bindings (sourced last)
require("bindings")
