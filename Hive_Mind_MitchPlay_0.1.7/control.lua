handler = require("script/event_handler")
names = require("shared")
util = require("script/script_util")

--error(serpent.block(defines.events))

local libs = {
  --debug = require "script/debug",
  unit_deployment = require("script/unit_deployment"),
  hive_mind = require("script/hive_mind"),
  creep = require("script/creep"),
  pollution_lab = require("script/pollution_lab")
}


local register_events = function(libraries)

  local all_events = {}

  for lib_name, lib in pairs (libraries) do
    if lib.get_events then
      local lib_events = lib.get_events()
      for k, handler in pairs (lib_events) do
        all_events[k] = all_events[k] or {}
        all_events[k][lib_name] = handler
      end
    else
      --error(lib_name.." needs to have a get events function cmon lets be reasonable now ok I know its some boiler plate etc. but its alright its more efficient")
    end
  end

  for event, handlers in pairs (all_events) do
    local action
    action = function(event)
      for k, handler in pairs (handlers) do
        handler(event)
      end
    end
    script.on_event(event, action)
  end

end

local on_init = function()
  --game.speed = settings.startup["game-speed"].value
  for name, lib in pairs (libs) do
    if lib.on_init then
      lib.on_init()
    end
  end
  register_events(libs)
end

local on_load = function()
  for name, lib in pairs (libs) do
    if lib.on_load then
      lib.on_load()
    end
  end
  register_events(libs)
end

local on_configuration_changed = function(data)
  for name, lib in pairs (libs) do
    if lib.on_configuration_changed then
      lib.on_configuration_changed(data)
    end
  end
end

script.on_init(on_init)

script.on_load(on_load)

script.on_configuration_changed(on_configuration_changed)
