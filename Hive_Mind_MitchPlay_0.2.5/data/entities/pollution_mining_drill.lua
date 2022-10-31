local name = names.pollution_mining_drill

local id = "Pollution Mining Drill"

local drill = util.copy(data.raw["mining-drill"]["electric-mining-drill"])
local spawner_graphics = util.copy(data.raw["unit-spawner"]["biter-spawner"])
local tint = {r = 0.80, b = 0.75, g = 0.3}
util.recursive_hack_scale(spawner_graphics, 0.60)
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
drill.order = "b-b"
drill.collision_box = util.area({0,0}, 1.75)
drill.selection_box = util.area({0,0}, 1.75)
drill.mining_speed = 0
drill.energy_source = {type = "void", emissions_per_minute = 12}
drill.resource_searching_radius = 0.5
drill.collision_mask = util.buildable_on_creep_collision_mask()
drill.resource = {"coal", "copper-ore", "iron-ore"}
drill.vector_to_place_result = {0, 0}
drill.base_picture = spawner_graphics.animations[4]
drill.working_sound = spawner_graphics.working_sound
drill.vehicle_impact_sound = spawner_graphics.vehicle_impact_sound
drill.module_specification = nil
drill.dying_explosion = spawner_graphics.dying_explosion
drill.corpse = nil

local subgroup =
{
  type = "item-subgroup",
  name = "pollution-drill-subgroup",
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
