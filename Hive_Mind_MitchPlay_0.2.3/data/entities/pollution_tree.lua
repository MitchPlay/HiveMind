local name = names.pollution_tree

local tree = util.copy(data.raw.tree["dry-hairy-tree"])
local spawner_graphics = util.copy(data.raw["unit-spawner"]["biter-spawner"])
local tint = {r = 0.65, b = 0.60, g = 0.4}

util.recursive_hack_make_hr(tree)
util.recursive_hack_tint(tree, tint)

tree.icons =
{
  {
    icon = tree.icon,
    icon_size = tree.icon_size,
    tint = tint
  }
}

tree.icon = nil
tree.name = name
tree.type = "radar"
--tree.localised_name = {name}
tree.order = "noob"
tree.energy_source = {type = "void", emissions_per_minute = 12}
tree.collision_mask = util.default_building_collision_mask()
tree.working_sound = spawner_graphics.working_sound
tree.vehicle_impact_sound = spawner_graphics.vehicle_impact_sound
tree.module_specification = nil
tree.flags = {"player-creation", "placeable-neutral", "not-rotatable", "placeable-off-grid"}
tree.dying_explosion = spawner_graphics.dying_explosion
tree.corpse = nil
tree.subgroup = "pollution-c-tree-subgroup"
tree.picture = tree.pictures[math.random(1,#tree.pictures)]
tree.pictures = tree.picture
tree.pictures.direction_count = 1
tree.energy_per_nearby_scan	= "1W"
tree.energy_per_sector	= "1GW"
tree.energy_usage	= "1W"
tree.max_distance_of_nearby_sector_revealed	= 2
tree.max_distance_of_sector_revealed	= 2
tree.rotation_speed = 0
tree.max_health = 500

local subgroup =
{
  type = "item-subgroup",
  name = "pollution-c-tree-subgroup",
  group = "enemies",
  order = "b"
}

local item =
{
  type = "item",
  name = name,
  --localised_name = nil,
  localised_description = {"requires-pollution", names.required_pollution[name] * names.pollution_cost_multiplier},
  icons = tree.icons,
  icon = tree.icon,
  icon_size = tree.icon_size,
  flags = {},
  subgroup = subgroup.name,
  order = "aa-"..name,
  place_result = name,
  stack_size = 50
}

data:extend
{
  tree,
  item,
  subgroup
}
