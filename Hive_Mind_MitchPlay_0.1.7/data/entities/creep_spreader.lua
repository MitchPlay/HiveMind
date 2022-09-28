local name = names.creep_spreader
local util = require("__Hive_Mind_MitchPlay__/data/tf_util/tf_util")
local graphics = util.copy(data.raw["unit-spawner"]["biter-spawner"])

util.recursive_hack_scale(graphics, 2.5/5)
util.recursive_hack_tint(graphics, {r = 0.5, b = 0.5, g = 0.5})

local entity =
{
  type = "simple-entity-with-force",
  name = name,
  localised_name = {name},
  render_layer = "object",
  --icon = graphics.icon,
  --icon_size = graphics.icon_size,
  icons =
  {
    {
      icon = graphics.icon,
      icon_size = graphics.icon_size,
      tint = {r = 0.5, b = 0.5, g = 0.5}
    }
  },
  flags = {"placeable-neutral", "player-creation", --[["placeable-off-grid"]]},
  order = name,
  minable = nil,
  max_health = 75,
  collision_mask = {"water-tile", "player-layer", "train-layer"},
  collision_box = {{-1, -1}, {1, 1}},
  selection_box = {{-1, -1}, {1, 1}},
  animations = graphics.animations,
  dying_explosion = graphics.dying_explosion,
  friendly_map_color = {r = 0.5, b = 0.5}
}

local subgroup =
{
  type = "item-subgroup",
  name = "base-subgroup",
  group = "enemies",
  order = "a"
}

local item =
{
  type = "item",
  name = name,
  localised_name = {name},
  localised_description = {"requires-pollution", names.required_pollution[name] * names.pollution_cost_multiplier},
  icons = entity.icons,
  flags = {},
  subgroup = subgroup.name,
  order = "aa-"..name,
  place_result = name,
  stack_size = 50
}

--[[

  local recipe = {
    type = "recipe",
    name = name,
    localised_name = name,
    enabled = true,
    ingredients =
    {
      {names.items.biological_structure, 120},
    },
    energy_required = 100,
    result = name
  }

  ]]

data:extend
{
  entity,
  item,
  subgroup
}
