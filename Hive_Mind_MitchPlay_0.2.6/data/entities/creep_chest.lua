local name = names.creep_chest

local drill = util.copy(data.raw["container"]["wooden-chest"])
local spawner_graphics = util.copy(data.raw["unit-spawner"]["biter-spawner"])
local tint = {r = 0.8, b = 0.8}
util.recursive_hack_scale(spawner_graphics, 0.75)
util.recursive_hack_make_hr(spawner_graphics)
util.recursive_hack_tint(spawner_graphics, tint)

util.recursive_hack_make_hr(drill)
util.recursive_hack_tint(drill, tint)

drill.icons =
{
  {
    icon = spawner_graphics.icon,
    icon_size = spawner_graphics.icon_size,
    tint = tint
  },
  {
    icon = drill.icon,
    icon_size = drill.icon_size,
    tint = tint
  }
}
drill.icon = nil
drill.name = name
drill.localised_name = {name}
drill.order = "noob"
drill.max_health = 50
drill.collision_mask = {"water-tile", "player-layer", "train-layer"}
collision_box = {{-0.48, -0.48}, {0.48, 0.48}}
drill.selection_box = {{-0.5, -0.5}, {0.5, 0.5}}
drill.energy_source = {type = "void", emissions_per_minute = 1}
drill.collision_mask = util.buildable_on_creep_collision_mask()
drill.base_picture = spawner_graphics.animations[4]
drill.working_sound = nil
drill.vehicle_impact_sound = spawner_graphics.vehicle_impact_sound
drill.module_specification = nil
drill.dying_explosion = spawner_graphics.dying_explosion
drill.corpse = nil
drill.next_upgrade = nil

local subgroup =
{
  type = "item-subgroup",
  name = "base-subgroup",
  group = "enemies",
  order = "b"
}

local item =
{
  type = "item",
  name = name,
  localised_name = {name},
  localised_description = {"requires-pollution", names.required_pollution[name] * names.pollution_cost_multiplier},
  icons = drill.icons,
  icon = drill.icon,
  icon_size = drill.icon_size,
  flags = {},
  subgroup = subgroup.name,
  order = "aa-"..name,
  place_result = name,
  stack_size = 50
}

data:extend
{
  drill,
  item,
  subgroup
}
