local util = require("__Hive_Mind_MitchPlay__/data/tf_util/tf_util")
local shared = require("shared")

local on_marked_for_upgrade = function(event)
    game.print("Gotta go fast!") 
end

local events =
{
  [defines.events.on_marked_for_upgrade] = on_marked_for_upgrade,
}

local lib = {}

lib.get_events = function() return events end

lib.on_init = function()
  global.blight = global.blight or script_data
  for k, surface in pairs (game.surfaces) do
    for k, v in pairs (surface.find_entities_filtered{name = get_blight_spread_list()}) do
      on_built_entity({entity = v})
    end
  end
end

lib.on_load = function()
  script_data = global.blight or script_data
end

lib.on_configuration_changed = function()
  if global.blight then return end
  global.blight = script_data
  for k, surface in pairs (game.surfaces) do
    for k, v in pairs (surface.find_entities_filtered{name = get_blight_spread_list()}) do
      on_built_entity({entity = v})
    end
  end
end

return lib