local util = require("script/script_util")

local shared = require("shared")
local unit_deployment = require("script/unit_deployment")

local on_marked_for_upgrade = function(event)
  local entity = event.entity
  local target = event.target

  local can_upgrade = false

  if request_needs_technology(target.name) then
    if entity.force.technologies[request_needs_technology(target.name)].researched then
      can_upgrade = true
    end
  else
    can_upgrade = true
  end

  if can_upgrade then
    local stored_pollution = shared.required_pollution[entity.name]
    if stored_pollution == nil then
      if(entity.name:find("biter")) then
        stored_pollution = shared.required_pollution["spitter-deployer"]
      end
      if(entity.name:find("spitter")) then
        stored_pollution = shared.required_pollution["spitter-deployer"]
      end
    end
  
    local required_pollution = shared.required_pollution[target.name]
    if required_pollution == nil then
      if(target.name:find("biter")) then
        required_pollution = shared.required_pollution["spitter-deployer"]
      end
      if(target.name:find("spitter")) then
        required_pollution = shared.required_pollution["spitter-deployer"]
      end
    end

    local difference = required_pollution * shared.pollution_cost_multiplier - stored_pollution * shared.pollution_cost_multiplier
    if difference <= 0 then
      local ent = entity.surface.create_entity{
        name = "entity-ghost", 
        inner_name = target.name,
        position = entity.position, 
        direction = event.direction or entity.direction,
        force = entity.force
      }

      if not (ent == nil) then
        register_ghost_built(ent, event.player_index, -999999999)

        entity.destroy()
      end
    else
      local ent = entity.surface.create_entity{
        name = "entity-ghost", 
        inner_name = target.name,
        position = entity.position, 
        direction = event.direction or entity.direction,
        force = entity.force
      }

      if not (ent == nil) then
        register_ghost_built(ent, event.player_index, stored_pollution * shared.pollution_cost_multiplier)

        entity.destroy()
      end
    end
  else
    local player = game.get_player(event.player_index)
    player.create_local_flying_text
    {
      text={"entity-not-unlocked", request_get_prototype(target.name).localised_name},
      position=entity.position,
      color=nil,
      time_to_live=nil,
      speed=nil
    }
  end
end

local events =
{
  [defines.events.on_marked_for_upgrade] = on_marked_for_upgrade,
}

local lib = {}

lib.get_events = function() return events end

return lib