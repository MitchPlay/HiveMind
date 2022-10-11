local util = require("__Hive_Mind_MitchPlay__/data/tf_util/tf_util")
local shared = require("shared")

local make_deployer = function(origin, name)

    local machine = util.copy(data.raw["assembling-machine"]["assembling-machine-2"])
    local graphics = util.copy(data.raw["unit-spawner"][origin])

    local localised_string
    if name == "spitter-deployer" or name == "biter-deployer" then
      localised_string = {name}
    else
      if graphics.localised_name then
        localised_string = graphics.localised_name
      else
        localised_string = {"entity-name."..graphics.name}
      end
    end

    for k, animation in pairs (graphics.animations) do
      if k == "layers" then
        if animation.animation_speed then
          animation.animation_speed = 0.5 / shared.deployer_speed_modifier
          if animation.hr_version then
            animation.hr_version.animation_speed = 0.5 / shared.deployer_speed_modifier
          end
        end
      else
        for k, layer in pairs (animation.layers) do
          if layer.animation_speed then
            layer.animation_speed = 0.5 / shared.deployer_speed_modifier
            if layer.hr_version then
              layer.hr_version.animation_speed = 0.5 / shared.deployer_speed_modifier
            end
          end
        end
      end
    end

    machine.name = name
    machine.localised_name = localised_string
    machine.localised_description = {"requires-pollution", util.required_pollution(name, graphics) * shared.pollution_cost_multiplier}
    machine.icon = graphics.icon
    machine.icon_size = graphics.icon_size or 64
    machine.collision_box = util.area({0,0}, 2.5)
    machine.selection_box = util.area({0,0}, 2)
    machine.crafting_categories = {name}
    machine.crafting_speed = 0.25
    machine.ingredient_count = 100
    machine.module_specification = nil
    machine.minable = {result = name, mining_time = 5}
    machine.flags = {--[["placeable-off-grid",]] "placeable-neutral", "player-creation", "no-automated-item-removal"}
    machine.is_deployer = true
    machine.next_upgrade = nil
    machine.dying_sound = graphics.dying_sound
    machine.corpse = graphics.corpse
    --machine.dying_explosion = graphics.dying_explosion
    machine.collision_mask = {"water-tile", "player-layer", "train-layer"}
    machine.order = graphics.order
    machine.healing_per_tick = graphics.healing_per_tick

    machine.open_sound =
    {
      {filename = "__base__/sound/creatures/worm-standup-small-1.ogg"},
      {filename = "__base__/sound/creatures/worm-standup-small-2.ogg"},
      {filename = "__base__/sound/creatures/worm-standup-small-3.ogg"},
    }
    machine.close_sound =
    {
      {filename = "__base__/sound/creatures/worm-folding-1.ogg"},
      {filename = "__base__/sound/creatures/worm-folding-2.ogg"},
      {filename = "__base__/sound/creatures/worm-folding-3.ogg"},
    }

    machine.minable = nil

    machine.always_draw_idle_animation = true
    if #graphics.animations >= 4 then
      machine.animation =
      {
        north = graphics.animations[1],
        east = graphics.animations[2],
        south = graphics.animations[3],
        west = graphics.animations[4],
      }
    else --[[if #graphics.animations == 1 then]]
      machine.animation =
      {
        north = graphics.animations,
        east = graphics.animations,
        south = graphics.animations,
        west = graphics.animations,
      }
    end
    machine.working_sound = graphics.working_sound
    machine.fluid_boxes =
    {
      {
        production_type = "output",
        pipe_picture = nil,
        pipe_covers = nil,
        base_area = 1,
        base_level = 1,
        pipe_connections = {{ type= "output", position = {0, -3} }},
      },
      off_when_no_fluid_recipe = false
    }
    machine.scale_entity_info_icon = true
    machine.energy_source = {type = "void"}
    machine.create_ghost_on_death = false
    machine.friendly_map_color = {g = 1}

    local item =
    {
      type = "item",
      name = name,
      localised_name = localised_string,
      localised_description = machine.localised_description,
      icon = machine.icon,
      icon_size = machine.icon_size,
      flags = {},
      subgroup = "hivemind-deployer",
      order = "aa-"..name,
      place_result = name,
      stack_size = 50
    }

    local catagory =
    {
      type = "recipe-category",
      name = name
    }


    local recipe = {
      type = "recipe",
      name = name,
      localised_name = localised_string,
      enabled = false,
      ingredients = {},
      energy_required = math.huge,
      result = name,
      catagory = name
    }

      

    local subgroup =
    {
      type = "item-subgroup",
      name = name,
      group = "enemies",
      order = "b"
    }


    data:extend
    {
      machine,
      item,
      catagory,
      recipe,
      subgroup
    }
end

data:extend
{
  {
    type = "item-subgroup",
    name = "hivemind-deployer",
    group = "enemies",
    order = "b"
  }
}

for name, spawner in pairs(data.raw["unit-spawner"]) do
  local deployer_name = util.deployer_name(name)
  if deployer_spawn_list[deployer_name] then
    make_deployer(name, deployer_name)
  end
end