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

-- Three-finger swipe moves through workspaces that have windows, plus one
-- empty workspace after the highest of those. Empty gaps are skipped, and
-- another swipe at that extra workspace stays put.
-- Finger motion to the right advances, matching the built-in workspace swipe.
local function swipe_workspace(direction)
  local monitor = hl.get_active_monitor()
  if not monitor or not monitor.active_workspace or monitor.active_workspace.special then
    return
  end

  local occupied = {}
  for _, ws in ipairs(hl.get_workspaces()) do
    if not ws.special and ws.windows > 0 and ws.monitor and ws.monitor.id == monitor.id then
      table.insert(occupied, ws.id)
    end
  end
  if #occupied == 0 then
    return
  end
  table.sort(occupied)

  local extra = occupied[#occupied] + 1
  while true do
    local existing = hl.get_workspace(extra)
    if not existing or (existing.monitor and existing.monitor.id == monitor.id and not existing.special) then
      break
    end
    extra = extra + 1
  end
  table.insert(occupied, extra)

  local current = monitor.active_workspace.id
  local dest = nil
  if direction > 0 then
    for _, id in ipairs(occupied) do
      if id > current then
        dest = id
        break
      end
    end
  else
    for i = #occupied, 1, -1 do
      if occupied[i] < current then
        dest = occupied[i]
        break
      end
    end
  end
  if dest then
    hl.dispatch(hl.dsp.focus({ workspace = dest }))
  end
end

hl.gesture({
  fingers = 3,
  direction = "right",
  action = function()
    swipe_workspace(1)
  end,
})
hl.gesture({
  fingers = 3,
  direction = "left",
  action = function()
    swipe_workspace(-1)
  end,
})
