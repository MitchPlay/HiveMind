local util = require("script/script_util")

local script_data =
{
  spreading_landmines = {},
  idle_landmines = {},
  shrinking_landmines = {},
  tiles_to_set = {}
}

local names = require("shared")

local blight_spread_map
local get_blight_spread_map = function()
  if blight_spread_map then return blight_spread_map end
  blight_spread_map = names.blight_radius
  {
    --["biter-deployer"] = true, -- not needed because they are generated later
    --["spitter-deployer"] = true,
    --["biter-spawner"] = true,
    --["spitter-spawner"] = true,
    ["blight-spreader"] = 15, -- bools replaced with ints
    ["advanced-blight-spreader"] = 30,
    ["blight-tumor"] = 10,
    ["armored-blight-tumor"] = 15,
    ["blight-wall"] = 2,
    ["blight-gate"] = 2
  }
  for index, name in pairs(util.get_spawner_order()) do -- spawners/deployers added to map from here
    blight_spread_map[name] = 10
    blight_spread_map[util.deployer_name(name)] = 10
  end

  for index, name in pairs(util.get_worm_order()) do -- worms added to map from here
    blight_spread_map[name] = 4
  end
  return blight_spread_map
end

local on_chunk_generated = function(event)
  local area = event.area
  local surface = event.surface
  for k, entity in pairs (surface.find_entities_filtered{type = "unit-spawner", area = area}) do
    local unit_number = entity.unit_number
    if not script_data.spreading_landmines[unit_number] then
      local landmine = entity.surface.create_entity{name = names.blight_landmine, position = entity.position, force = entity.force}
      landmine.destructible = false
      script_data.spreading_landmines[unit_number] = {entity = landmine, radius = 1, max_radius = get_blight_spread_map()[entity.name]}
    end
  end
end

local blight_spread_list
local get_blight_spread_list = function()
  if blight_spread_list then return blight_spread_list end
  blight_spread_list = {}
  for name, bool in pairs (get_blight_spread_map()) do
    table.insert(blight_spread_list, name)
  end
  return blight_spread_list
end

local shuffle_table = function(table)
  local size = #table
  local random = math.random
  for k = size, 1, -1 do
    local i = random(size)
    table[i], table[k] = table[k], table[i]
  end
  return table
end

local on_built_entity = function(event)

  local entity = event.created_entity or event.entity
  if not (entity and entity.valid) then return end

  if get_blight_spread_map()[entity.name] and get_blight_spread_map()[entity.name] > 0 then -- checks if entity is a number and true
    local unit_number = entity.unit_number
    if not script_data.spreading_landmines[unit_number] then
      local landmine = entity.surface.create_entity{name = names.blight_landmine, position = entity.position, force = entity.force}
      landmine.destructible = false
      script_data.spreading_landmines[unit_number] = {entity = landmine, radius = 1, max_radius = get_blight_spread_map()[entity.name]} -- changed to max_radius to just have a single value to chen and not needing to check the map everytime we need the value.
    end
  end

end

local biggest_radius = util.biggest_blight_radius()
local blight_spread_update_rate = 84
local get_area = util.area
local distance = util.distance
local insert = table.insert

local register_to_set_tiles = function(surface, tile)

  local register = script_data.tiles_to_set
  if not register then
    register = {}
    script_data.tiles_to_set = register
  end

  local index = surface.index

  local surface_register = register[index]
  if not surface_register then
    surface_register = {}
    register[index] = surface_register
  end

  insert(surface_register, tile)

end


local root_2 = 2 ^ 0.5

local spread_blight
spread_blight = function(unit_number, spawner_data)

  local spawner = spawner_data.entity

  if not spawner.valid then
    script_data.spreading_landmines[unit_number] = nil
    return
  end

  local surface = spawner.surface
  local position = spawner.position

  local tiles = spawner_data.tiles
  local radius = spawner_data.radius
  local max_radius = spawner_data.max_radius
  if not tiles then

    if radius == max_radius then
      script_data.idle_landmines[unit_number] = spawner_data
      script_data.spreading_landmines[unit_number] = nil
      return
    end

    radius = math.min(radius + 1, max_radius)
    tiles = shuffle_table(surface.find_tiles_filtered{position = position, radius = radius, collision_mask = {"ground-tile", "water-tile"}})
    spawner_data.tiles = tiles
    spawner_data.radius = radius

  end

  local tile_to_set

  for k, tile in pairs (tiles) do
    tiles[k] = nil
    if tile.valid and (tile.name ~= names.blight) and (tile.name ~= "out-of-map") then
      tile_to_set = tile
      break
    end
  end

  if not tile_to_set then
    spawner_data.tiles = nil
    return spread_blight(unit_number, spawner_data)
  end

  return register_to_set_tiles(surface, {position = tile_to_set.position, name = "blight"})

end

local check_blight_spread = function(event)
  local mod = event.tick % blight_spread_update_rate
  for unit_number, spawner_data in pairs (script_data.spreading_landmines) do
    if (unit_number % blight_spread_update_rate) == mod then
      spread_blight(unit_number, spawner_data)
    end
  end
end

local blight_unspread_update_rate = 64
local unspread_blight
unspread_blight = function(unit_number, landmine_data)

  local landmine = landmine_data.entity
  local shrinking_landmines = script_data.shrinking_landmines
  if not (landmine and landmine.valid) then
    shrinking_landmines[unit_number] = nil
    return
  end

  --tiles are shuffled when we create find them.
  --We want to kill one tile every update.

  local surface = landmine.surface
  local tiles = landmine_data.tiles

  if not tiles then
    local radius = landmine_data.radius

    if radius <= 0 then
      landmine.destructible = true
      landmine.destroy()
      shrinking_landmines[unit_number] = nil
      return
    end

    local new_radius = radius - root_2

    local position = landmine.position
    tiles = shuffle_table(surface.find_tiles_filtered{position = position, radius = radius, name = names.blight})
    for k, tile in pairs (tiles) do
      local tile_position = tile.position
      local tile_distance = distance(tile_position, position)
      if tile_distance < (new_radius - root_2) then
        tiles[k] = nil
      end
    end
    landmine_data.radius = new_radius
    landmine_data.tiles = tiles
  end

  local nearby_shrinking_landmines = surface.find_entities_filtered{name = names.blight_landmine, position = landmine.position, radius = biggest_radius * 2}
  local nearby_active_landmines = {}
  local any_active = false
  for k, v in pairs (nearby_shrinking_landmines) do
    if not shrinking_landmines[v.unit_number] then
      nearby_active_landmines[k] = v
      any_active = true
      nearby_shrinking_landmines[k] = nil
    end
  end

  local get_closest = surface.get_closest

  local blight_to_remove

  for k, tile in pairs (tiles) do
    tiles[k] = nil
    local position = tile.position
    if tile.name == names.blight and get_closest(position, nearby_shrinking_landmines) == landmine then
      if not any_active then
        blight_to_remove = tile
        break
      end
      local claimed_tile
      for _, active_landmine in pairs(nearby_active_landmines) do
        if distance(position, active_landmine.position) < active_landmine.max_radius then
          claimed_tile = true
          break
        end
      end
      if claimed_tile == false then
        blight_to_remove = tile
        break
      end
    end
  end

  if not blight_to_remove then
    landmine_data.tiles = nil
    return unspread_blight(unit_number, landmine_data)
  end

  register_to_set_tiles(surface, {position = blight_to_remove.position, name = blight_to_remove.hidden_tile or "out-of-map"})

end

local check_blight_unspread = function(event)

  local mod = event.tick % blight_unspread_update_rate
  for unit_number, landmine_data in pairs (script_data.shrinking_landmines) do
    if (unit_number % blight_unspread_update_rate) == mod then
      unspread_blight(unit_number, landmine_data)
    end
  end

end

local check_set_tile_register = function()
  local register = script_data.tiles_to_set
  local surfaces = game.surfaces
  for surface_index, tiles in pairs (register) do
    local surface = surfaces[surface_index]
    if surface and surface.valid then
      surface.set_tiles(tiles, true)
    end
    register[surface_index] = {}
  end
end

local on_tick = function(event)
  check_blight_spread(event)
  check_blight_unspread(event)
  check_set_tile_register()
end

--local sticker_types = {"character", "unit", "car"}

local on_trigger_created_entity = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end

  if entity.name ~= names.blight_sticker then return end

  local tile = entity.surface.get_tile(entity.position)
  if tile.name == names.blight then return end

  entity.destroy()

end

local on_entity_died = function(event)

  local entity = event.entity
  if not (entity and entity.valid) then return end
  local unit_number = entity.unit_number
  local landmine_data = script_data.idle_landmines[unit_number] or script_data.spreading_landmines[unit_number]
  if not landmine_data then return end

  script_data.idle_landmines[unit_number] = nil
  script_data.spreading_landmines[unit_number] = nil

  local blight_landmine = landmine_data.entity
  if not (blight_landmine and blight_landmine.valid) then return end

  --We need to notify nearby shrinking ones to reexpand their radius, as they may have already checked the nearby tiles and determined they should be left as blight.
  local shrinking_landmines = script_data.shrinking_landmines

  local nearby_shrinking_landmines = blight_landmine.surface.find_entities_filtered{name = names.blight_landmine, position = blight_landmine.position, radius = biggest_radius * 2}
  for k, v in pairs (nearby_shrinking_landmines) do
    local nearby_data = shrinking_landmines[v.unit_number]
    if nearby_data then
      nearby_data.radius = nearby_data.max_radius + root_2
    end
  end

  landmine_data.radius = landmine_data.max_radius + root_2
  shrinking_landmines[blight_landmine.unit_number] = landmine_data
end

local events =
{
  [defines.events.on_chunk_generated] = on_chunk_generated,
  [defines.events.script_raised_revive] = on_built_entity,
  [defines.events.script_raised_built] = on_built_entity,
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_biter_base_built] = on_built_entity,
  [defines.events.on_tick] = on_tick,
  [defines.events.on_trigger_created_entity] = on_trigger_created_entity,
  [defines.events.script_raised_destroy] = on_entity_died,
  [defines.events.on_entity_died] = on_entity_died,
}

local lib = {}

lib.get_events = function() return events end

lib.on_init = function()
  global.blight = global.blight or global.creep or script_data
  for k, surface in pairs (game.surfaces) do
    for k, v in pairs (surface.find_entities_filtered{name = get_blight_spread_list()}) do
      on_built_entity({entity = v})
    end
  end
end

lib.on_load = function()
  script_data = global.blight or global.creep or script_data
end

lib.on_configuration_changed = function()
  if global.blight then return end
  if global.creep then global.blight = global.creep return end
  global.blight = script_data
  for k, surface in pairs (game.surfaces) do
    for k, v in pairs (surface.find_entities_filtered{name = get_blight_spread_list()}) do
      on_built_entity({entity = v})
    end
  end
end

return lib