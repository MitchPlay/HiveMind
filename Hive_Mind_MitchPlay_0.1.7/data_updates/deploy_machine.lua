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
      for k, layer in pairs (animation.layers) do
        layer.animation_speed = 0.5 / shared.deployer_speed_modifier
        layer.hr_version.animation_speed = 0.5 / shared.deployer_speed_modifier
      end
    end

    machine.name = name
    machine.localised_name = localised_string
    machine.localised_description = {"requires-pollution", util.required_pollution(name, graphics) * shared.pollution_cost_multiplier}
    machine.icon = graphics.icon
    machine.icon_size = graphics.icon_size
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
    machine.animation =
    {
      north = graphics.animations[1],
      east = graphics.animations[2],
      south = graphics.animations[3],
      west = graphics.animations[4],
    }
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

for name, spawner in pairs (data.raw["unit-spawner"]) do
  local deployer_name =  util.deployer_name(name)
  make_deployer(name, deployer_name)
end