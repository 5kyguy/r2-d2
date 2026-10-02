-- Prefer A2DP once it appears, unless the headset microphone is in use.
--
-- Hands-free is enumerated before A2DP on connect and would otherwise stay
-- selected. Playback then sounds like a phone call until the headset is
-- reconnected. A later recording still switches to the hands-free profile
-- through WirePlumber's own autoswitch.

cutils = require ("common-utils")
log = Log.open_topic ("s-device")

function is_headset_profile (profile)
  if profile == nil or profile.name == nil then
    return false
  end
  return string.find (profile.name, "^headset%-head%-unit") ~= nil
      or profile.name == "bap-duplex"
end

function best_a2dp_profile (device)
  local found = nil

  for pod in device:iterate_params ("EnumProfile") do
    local profile = cutils.parseParam (pod, "EnumProfile")
    if profile and profile.available ~= "no" and profile.name ~= "off"
        and not is_headset_profile (profile) then
      if found == nil or profile.priority > found.priority then
        found = profile
      end
    end
  end

  return found
end

function microphone_in_use (source, device_id)
  local node_om = source:call ("get-object-manager", "node")
  local link_om = source:call ("get-object-manager", "link")
  if node_om == nil or link_om == nil or device_id == nil then
    return false
  end

  for bt_node in node_om:iterate {
    Constraint { "media.class", "matches", "Audio/Source" },
    Constraint { "bluez5.loopback", "=", "true", type = "pw" },
  } do
    local node_device = bt_node.properties ["device.id"]
    if tonumber (node_device) == tonumber (device_id) then
      local bt_id = bt_node ["bound-id"]
      for link in link_om:iterate {
        Constraint { "link.output.node", "=", bt_id, type = "pw-global" },
      } do
        local peer_id = link.properties ["link.input.node"]
        local stream = node_om:lookup {
          Constraint { "bound-id", "=", peer_id, type = "gobject" },
          Constraint { "bluez5.loopback", "!", "true", type = "pw" },
          Constraint { "stream.monitor", "!", "true", type = "pw" },
        }
        if stream ~= nil then
          return true
        end
      end
    end
  end

  return false
end

SimpleEventHook {
  name = "device/bluetooth-prefer-a2dp",
  after = "device/find-best-profile",
  before = "device/apply-profile",
  interests = {
    EventInterest {
      Constraint { "event.type", "=", "select-profile" },
      Constraint { "device.api", "=", "bluez5" },
    },
  },
  execute = function (event)
    local device = event:get_subject ()
    local a2dp = best_a2dp_profile (device)
    if a2dp == nil then
      return
    end

    local selected = event:get_data ("selected-profile")
    if selected ~= nil and not is_headset_profile (selected) and selected.name ~= "off" then
      return
    end
    if microphone_in_use (event:get_source (), device ["bound-id"]) then
      log:info (device, "headset microphone is in use, keeping the phone profile")
      return
    end

    log:info (device, "preferring " .. a2dp.name .. " for playback")
    event:set_data ("selected-profile", a2dp)
  end
}:register ()
