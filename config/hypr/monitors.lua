-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors: hyprctl monitors

hl.env("GDK_SCALE", "1")

-- A wallpaper rewrite reloads this file. The catch-all below would turn a
-- manually disabled laptop panel back on, and turning it off again makes
-- Hyprland open the lowest missing workspace (usually 3). Keep it off here.
local function session_disabled_output()
  local home = os.getenv("HOME")
  if not home or home == "" then
    return nil
  end
  local state = os.getenv("XDG_STATE_HOME")
  if not state or state == "" then
    state = home .. "/.local/state"
  end
  local dir = state .. "/r2-d2/toggles/"
  for _, name in ipairs({ "builtin-display-disabled", "builtin-display-clamshell" }) do
    local handle = io.open(dir .. name, "r")
    if handle then
      local value = handle:read("*l") or ""
      handle:close()
      if value:match("^[A-Za-z0-9._-]+$") then
        return value
      end
    end
  end
  return nil
end

local disabled_output = session_disabled_output()

-- vrr enables FreeSync/VRR — measurable idle-power win on capable AMD panels.
-- No-op on monitors that don't advertise VRR.
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1,
  vrr = 1,
})

if disabled_output then
  hl.monitor({
    output = disabled_output,
    disabled = true,
  })
end

-- The bar draws workspaces 1–5 itself. Leaving them non-persistent lets an
-- empty one disappear once it is not on screen, so a three-finger swipe does
-- not stop on an unused gap.

-- Presets (for reference; use the script for dynamic layout):
--   r2-d2-hyprland-monitor-layout external-left
--   r2-d2-hyprland-monitor-layout external-right
