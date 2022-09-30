shared = require("shared")

local util = require("__Hive_Mind_MitchPlay__/data/tf_util/tf_util")

local default_unlocked = shared.default_unlocked

local dependency_list = {}
local pollution_values = {}
local dependency_list_worms = {}
local pollution_values_worms = {}

local deployer_recipe_catagories = {}

local make_biter_item = function(prototype, subgroup)
  local item =
  {
    type = "item",
    name = prototype.name,
    localised_name = prototype.localised_name,
    localised_description = {"requires-pollution-unit", prototype.pollution_to_join_attack * shared.pollution_cost_multiplier, prototype.unit_size},
    icon = prototype.icon,
    icon_size = prototype.icon_size,
    stack_size = 1,
    order = prototype.order or prototype.name,
    subgroup = subgroup,
    place_result = prototype.name
  }
  data:extend{item}
end

local make_biter_recipe = function(prototype, category)
  local recipe =
  {
    type = "recipe",
    name = prototype.name,
    localised_name = prototype.localised_name,
    enabled = false,
    ingredients = {},
    energy_required = prototype.pollution_to_join_attack * shared.pollution_cost_multiplier,
    result = prototype.name,
    category = category
  }
  data:extend{recipe}
end

local prerequisites_finder = function(prototype)
  local pollution_index
  local string = {}
  for y, x in pairs(pollution_values) do
    if x == prototype.pollution_to_join_attack then
      pollution_index = y
      break
    end
  end
  if pollution_index ~= 1 and pollution_index ~= nil then
    for _, name in pairs(dependency_list[pollution_values[pollution_index-1]]) do
      if not default_unlocked[name] then
        table.insert(string, "hivemind-unlock-"..name)
      end
    end
  end
  local name = prototype.name
  if name:find("worm") then
    local pollution_index
    for y, x in pairs(pollution_values_worms) do
      if x == util.required_pollution(prototype.name, prototype) then
        pollution_index = y
        break
      end
    end
    if pollution_index ~= 1 and pollution_index ~= nil then
      for _, name in pairs(dependency_list_worms[pollution_values_worms[pollution_index-1]]) do
        if not default_unlocked[name] then
          table.insert(string, "hivemind-unlock-"..name)
        end
      end
    end
    name = name:gsub("%-worm%-turret","")
    local biter = "hivemind-unlock-"..name.."-biter"
    local spitter = "hivemind-unlock-"..name.."-spitter"
    if data.raw.technology[biter] then
      table.insert(string,biter)
    elseif data.raw.technology[spitter] then
      table.insert(string,spitter)      
    end
  end
  return string
end


local make_unlock_technology = function(prototype, cost)
  if default_unlocked[prototype.name] then return end
  local tech =
  {
    type = "technology",
    name = "hivemind-unlock-"..prototype.name,
    localised_name = {"hivemind-unlock", prototype.localised_name or {"entity-name."..prototype.name}},
    icon = prototype.icon,
    icon_size = prototype.icon_size,
    icons = prototype.icons,
    enabled = false,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = prototype.name
      },
    },
    unit =
    {
      count = cost,
      ingredients = {{names.pollution_proxy, 1}},
      time = 1
    },
    prerequisites = prerequisites_finder(prototype),
    order = prototype.type..prototype.order..prototype.name
  }
  data:extend({tech})
end

local worm_category =
{
  type = "recipe-category",
  name = "worm-crafting-category"
}

data:extend{worm_category}

local make_worm_recipe = function(prototype, category, energy)
  local recipe =
  {
    type = "recipe",
    name = prototype.name,
    localised_name = prototype.localised_name,
    enabled = false,
    ingredients = {},
    energy_required = math.huge,
    result = prototype.name,
    category = worm_category.name
  }
  data:extend{recipe}
end


local worm_subgroup =
{
  type = "item-subgroup",
  name = "worm-subgroup",
  group = "enemies",
  order = "d"
}
data:extend{worm_subgroup}

local make_worm_item = function(prototype)
  local item =
  {
    type = "item",
    name = prototype.name,
    localised_name = prototype.localised_name,
    localised_description = {"requires-pollution", util.required_pollution(prototype.name, prototype) * shared.pollution_cost_multiplier},
    icon = prototype.icon,
    icon_size = prototype.icon_size,
    stack_size = 1,
    order = prototype.order or prototype.name,
    subgroup = worm_subgroup.name,
    place_result = prototype.name
  }
  data:extend{item}
end

local biter_ammo_category = util.ammo_category("biter-melee")
local spitter_ammo_category = util.ammo_category("spitter-biological")

local make_biter = function(biter)
  biter.collision_mask = util.ground_unit_collision_mask()
  biter.radar_range = biter.radar_range or 2
  biter.unit_size = math.ceil(biter.pollution_to_join_attack / shared.unit_size_divider)
  make_biter_item(biter, deployer_recipe_catagories[biter.name])
  make_biter_recipe(biter, deployer_recipe_catagories[biter.name])
  make_unlock_technology(biter, biter.pollution_to_join_attack * shared.pollution_cost_multiplier * 200)
  biter.ai_settings = biter.ai_settings or {}
  biter.ai_settings.destroy_when_commands_fail = false
  biter.friendly_map_color = {b = 1, g = 1}
  biter.affected_by_tiles = biter.affected_by_tiles or true
  biter.localised_description = {"requires-pollution-unit", biter.pollution_to_join_attack * shared.pollution_cost_multiplier, biter.unit_size}
  --biter.corpse = nil
  biter.dying_explosion = nil
  if biter.attack_parameters.ammo_type.category == "melee" then
    biter.attack_parameters.ammo_type.category = biter_ammo_category
  end
  if biter.attack_parameters.ammo_type.category == "biological" then
    biter.attack_parameters.ammo_type.category = spitter_ammo_category
  end
end

local worm_ammo_category = util.ammo_category("worm-biological")

local make_worm = function(turret)
  if not util.required_pollution(turret.name, turret) then return end
  make_worm_item(turret)
  make_worm_recipe(turret, worm_category, util.required_pollution(turret.name, turret) * shared.pollution_cost_multiplier)
  make_unlock_technology(turret, util.required_pollution(turret.name, turret) * shared.pollution_cost_multiplier * 100)
  table.insert(turret.flags, "player-creation")
  turret.create_ghost_on_death = false
  turret.friendly_map_color = {b = 1, g = 0.5}
  turret.localised_description = {"requires-pollution", util.required_pollution(turret.name, turret) * shared.pollution_cost_multiplier}
  turret.collision_mask = util.buildable_on_creep_collision_mask()
  if turret.attack_parameters.ammo_type.category == "biological" then
    turret.attack_parameters.ammo_type.category = worm_ammo_category
  end
  util.remove_from_list(turret.flags, "placeable-off-grid")
end


local units = data.raw.unit
for name, unit in pairs(units) do
  if unit.name:find("biter") or unit.name:find("spitter") then
    if dependency_list[unit.pollution_to_join_attack] then
      table.insert(dependency_list[unit.pollution_to_join_attack],unit.name)
    else
      dependency_list[unit.pollution_to_join_attack] = {unit.name}
      table.insert(pollution_values, unit.pollution_to_join_attack)
    end
  end
end
table.sort(pollution_values)

local spawners = data.raw["unit-spawner"]
local spawner_list = {"biter-spawner","spitter-spawner"}
for name, spawner in pairs(spawners) do
  if name ~= "biter-spawner" or name ~= "spitter-spawner" then
    table.insert(spawner_list, name)
  end
end

for index, name in pairs(spawner_list) do
  for unit_name, unit in pairs(spawners[name].result_units) do
    if not deployer_recipe_catagories[unit[1]] then
      deployer_recipe_catagories[unit[1]] = util.deployer_name(name)
    end
  end
end

for index, pollution_cost in pairs(pollution_values) do
  for index, unit in pairs(dependency_list[pollution_cost]) do
    make_biter(units[unit])
  end
end

--The acid splashes are still OP.

for k, fire in pairs (data.raw.fire) do
  if fire.name:find("acid%-splash%-fire") then
    fire.on_damage_tick_effect = nil
  end
end

local turrets = data.raw.turret

for name, turret in pairs (turrets) do
  if turret.name:find("worm%-turret") and util.required_pollution(name, turret) then
    if dependency_list_worms[util.required_pollution(name, turret)] then
      table.insert(dependency_list_worms[util.required_pollution(name, turret)],turret.name)
    else
      dependency_list_worms[util.required_pollution(name, turret)] = {turret.name}
      table.insert(pollution_values_worms, util.required_pollution(name, turret))
    end
  end
end
table.sort(pollution_values_worms)

--Overall, they just have too large a range.

--[[
range_worm_small    = 25
range_worm_medium   = 30
range_worm_big      = 38
range_worm_behemoth = 48
]]
--Laser turret is 24, flamethrower is 30, so lets make behemoth 55 and scale the rest accordingly

turrets["small-worm-turret"].attack_parameters.range = 30
turrets["medium-worm-turret"].attack_parameters.range = 35
turrets["big-worm-turret"].attack_parameters.range = 45
turrets["behemoth-worm-turret"].attack_parameters.range = 55

--Also the damage is ridiculous:
--[[damage_modifier_worm_small    = 36
damage_modifier_worm_medium   = 48
damage_modifier_worm_big      = 72
damage_modifier_worm_behemoth = 96]]

--lets say behemoth is 70

turrets["small-worm-turret"].attack_parameters.damage_modifier = 20
turrets["medium-worm-turret"].attack_parameters.damage_modifier = 40
turrets["big-worm-turret"].attack_parameters.damage_modifier = 55
turrets["behemoth-worm-turret"].attack_parameters.damage_modifier = 70
--error(serpent.block(turrets["behemoth-worm-turret"].attack_parameters))


turrets["small-worm-turret"].collision_box = util.area({0,0}, 1)
turrets["medium-worm-turret"].collision_box = util.area({0,0}, 1)
turrets["big-worm-turret"].collision_box = util.area({0,0}, 1.5)
turrets["behemoth-worm-turret"].collision_box = util.area({0,0}, 2)

for index, pollution_cost in pairs(pollution_values_worms) do
  log(pollution_cost)
  for index, worm in pairs(dependency_list_worms[pollution_cost]) do
    log(worm)
    make_worm(turrets[worm])
  end
end

for name, spawner in pairs (data.raw["unit-spawner"]) do
  spawner.collision_mask = {"water-tile", "player-layer", "train-layer"}
end

for k, corpse in pairs (data.raw.corpse) do
  corpse.time_before_removed = 60 * 60
end
