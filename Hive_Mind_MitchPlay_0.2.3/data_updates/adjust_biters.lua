shared = require("shared")

local util = require("__Hive_Mind_MitchPlay__/data/tf_util/tf_util")

local default_unlocked = shared.default_unlocked

local dependency_list = {biters = {}, worms = {}, deployers = {}, deployer = {}}
local pollution_values = {biters = {}, worms = {}, deployers = {}}

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

local prerequisites_finder = function(prototype, deployer)

  
  local name = prototype.name
  local pollution_index
  local string = {}

  if deployer and dependency_list.deployer[deployer] then
    for index, unit in pairs(dependency_list.deployer[deployer]) do
      for name, tech in pairs(data.raw.technology) do
        if tech.effects then
          for index, array in pairs(tech.effects) do
            if array.type == "unlock-recipe" and array.recipe == unit then
              table.insert(string, name)
            end
          end
        end
      end
    end
  end

  if not name:find("worm") then
    local subgroup = deployer_recipe_catagories[prototype.name]
    local pollution_values = pollution_values.deployers[subgroup]
    local dependency_list = dependency_list.deployers[subgroup]
    for y, x in pairs(pollution_values) do
      if x == prototype.pollution_to_join_attack then
        pollution_index = y
        break
      end
    end
    if pollution_index ~= 1 and pollution_index ~= nil then
      for _, name in pairs(dependency_list[pollution_values[pollution_index-1]]) do
        if not util.is_default_unlocked(name) then
          table.insert(string, "hivemind-unlock-"..name)
        end
      end
    end
  else
    for y, x in pairs(pollution_values.worms) do
      if x == util.required_pollution(prototype.name, prototype) then
        pollution_index = y
        break
      end
    end
    if pollution_index ~= 1 and pollution_index ~= nil then
      for _, name in pairs(dependency_list.worms[pollution_values.worms[pollution_index-1]]) do
        if not default_unlocked[name] then
          table.insert(string, "hivemind-unlock-"..name)
        end
      end
    end
    name = name:gsub("%-worm%-turret","")
    local biter = name.."-biter"
    local spitter = name.."-spitter"
    for name, tech in pairs(data.raw.technology) do
      if tech.effects then
        for index, array in pairs(tech.effects) do
          if array.type == "unlock-recipe" and array.recipe == biter then
            table.insert(string, name)
          elseif array.type == "unlock-recipe" and array.recipe == spitter then
            table.insert(string, name)
          end
        end
      end
    end
  end
  return string
end


local make_unlock_technology = function(prototype, cost, combined_deployer)
  if util.is_default_unlocked(prototype.name) then return end
  local unit
  if combined_deployer then
    unit = prototype
    prototype = combined_deployer
  end
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
    order = prototype.type..prototype.order..prototype.name
  }
  if unit then
    tech.prerequisites = prerequisites_finder(unit, combined_deployer.name)
    table.insert(tech.effects,
    {
      type = "unlock-recipe",
      recipe = unit.name
    })
  else
    tech.prerequisites = prerequisites_finder(prototype)
  end

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

local make_biter = function(biter, combined_deployer)
  biter.collision_mask = util.ground_unit_collision_mask()
  biter.radar_range = biter.radar_range or 2
  biter.unit_size = math.ceil(biter.pollution_to_join_attack / shared.unit_size_divider)
  make_biter_item(biter, deployer_recipe_catagories[biter.name])
  make_biter_recipe(biter, deployer_recipe_catagories[biter.name])
  make_unlock_technology(biter, biter.pollution_to_join_attack * shared.pollution_cost_multiplier * 200, combined_deployer)
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

for deployer, spawn_list in pairs(deployer_spawn_list) do
  dependency_list.deployers[deployer] = {}
  pollution_values.deployers[deployer] = {}
  for index, unit_name in pairs(spawn_list) do
    local unit = units[unit_name]
    --if unit.name:find("biter") or unit.name:find("spitter") then
      if dependency_list.deployers[deployer][unit.pollution_to_join_attack] then
        if util.is_default_unlocked(unit.name) then
          table.insert(dependency_list.deployers[deployer][unit.pollution_to_join_attack], 1, unit.name)
        else
          table.insert(dependency_list.deployers[deployer][unit.pollution_to_join_attack], unit.name)
        end
      else
        dependency_list.deployers[deployer][unit.pollution_to_join_attack] = {unit.name}
        table.insert(pollution_values.deployers[deployer], unit.pollution_to_join_attack)
      end
      if dependency_list.biters[unit.pollution_to_join_attack] then
        if util.is_default_unlocked(unit.name) then
          table.insert(dependency_list.biters[unit.pollution_to_join_attack], 1, unit.name)
        else
          table.insert(dependency_list.biters[unit.pollution_to_join_attack], unit.name)
        end
      else
        dependency_list.biters[unit.pollution_to_join_attack] = {unit.name}
        table.insert(pollution_values.biters, unit.pollution_to_join_attack)
      end
    --end
  end
  table.sort(pollution_values.deployers[deployer])
end
table.sort(pollution_values.biters)

local can_spawn = function(unit, spawn_list)
  for index, name in pairs(spawn_list) do
    if unit == name then return true end
  end
  return false
end

for index, spawner in pairs(util.get_spawner_order()) do
  local deployer = util.deployer_name(spawner)
  local spawn_list = deployer_spawn_list[deployer] or {}
  local max_evo_number = 0
  dependency_list.deployer[deployer] = {}
  for unit_index, unit in pairs(data.raw["unit-spawner"][spawner].result_units) do
    if not can_spawn(unit[1], spawn_list) then
      if unit[2][1][1] == max_evo_number then
        table.insert(dependency_list.deployer[deployer], unit[1])
      end
      if unit[2][1][1] > max_evo_number then
        dependency_list.deployer[deployer] = {unit[1]}
        max_evo_number = unit[2][1][1]
      end
    end
  end
end

local flags = {}
for index, pollution_cost in pairs(pollution_values.biters) do
  for index, unit in pairs(dependency_list.biters[pollution_cost]) do
    local combined_deployer
    if not flags[deployer_recipe_catagories[unit]] then
      flags[deployer_recipe_catagories[unit]] = true
      combined_deployer = deployer_recipe_catagories[unit]
      for index, name in pairs(dependency_list.deployers[combined_deployer][pollution_cost]) do
        if name == unit then dependency_list.deployers[combined_deployer][pollution_cost][index] = combined_deployer end
      end
    end
    make_biter(units[unit], data.raw["assembling-machine"][combined_deployer])
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
  if --[[turret.name:find("worm%-turret") and]] util.required_pollution(name, turret) then
    if dependency_list.worms[util.required_pollution(name, turret)] then
      table.insert(dependency_list.worms[util.required_pollution(name, turret)],turret.name)
    else
      dependency_list.worms[util.required_pollution(name, turret)] = {turret.name}
      table.insert(pollution_values.worms, util.required_pollution(name, turret))
    end
  end
end
table.sort(pollution_values.worms)

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

for index, pollution_cost in pairs(pollution_values.worms) do
  for index, worm in pairs(dependency_list.worms[pollution_cost]) do
    make_worm(turrets[worm])
  end
end

for name, spawner in pairs (data.raw["unit-spawner"]) do
  spawner.collision_mask = {"water-tile", "player-layer", "train-layer"}
end

for k, corpse in pairs (data.raw.corpse) do
  corpse.time_before_removed = 60 * 60
end
