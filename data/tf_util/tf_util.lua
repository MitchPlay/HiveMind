local util = require("util")
local shared = require("shared")

local is_sprite_def = function(array)
  return array.width and array.height and (array.filename or array.stripes or array.filenames)
end

util.is_sprite_def = is_sprite_def

local recursive_hack_scale
recursive_hack_scale = function(array, scale)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if is_sprite_def(v) then
        v.scale = (v.scale or 1) * scale
        if v.shift then
          v.shift[1], v.shift[2] = v.shift[1] * scale, v.shift[2] * scale
        end
      end
      if v.source_offset then
        v.source_offset[1] = v.source_offset[1] * scale
        v.source_offset[2] = v.source_offset[2] * scale
      end
      if v.projectile_center then
        v.projectile_center[1] = v.projectile_center[1] * scale
        v.projectile_center[2] = v.projectile_center[2] * scale
      end
      if v.projectile_creation_distance then
        v.projectile_creation_distance = v.projectile_creation_distance * scale
      end
      recursive_hack_scale(v, scale)
    end
  end
end
util.recursive_hack_scale = recursive_hack_scale

local recursive_hack_animation_speed
recursive_hack_animation_speed = function(array, scale)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if is_sprite_def(v) then
        v.animation_speed = v.animation_speed * scale
      end
      recursive_hack_animation_speed(v, scale)
    end
  end
end
util.recursive_hack_animation_speed = recursive_hack_animation_speed

local recursive_hack_tint
recursive_hack_tint = function(array, tint)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if is_sprite_def(v)  then
        v.tint = tint
      end
      recursive_hack_tint(v, tint)
    end
  end
end
util.recursive_hack_tint = recursive_hack_tint

local recursive_hack_make_hr
recursive_hack_make_hr = function(prototype)
  for k, v in pairs (prototype) do
    if type(v) == "table" then
      if is_sprite_def(v) and v.hr_version then
        prototype[k] = v.hr_version
        --v.scale = v.scale * 0.5
        v.hr_version = nil
      end
      recursive_hack_make_hr(v)
    end
  end
end
util.recursive_hack_make_hr = recursive_hack_make_hr

util.scale_box = function(box, scale)
  box[1][1] = box[1][1] * scale
  box[1][2] = box[1][2] * scale
  box[2][1] = box[2][1] * scale
  box[2][2] = box[2][2] * scale
  return box
end

util.scale_boxes = function(prototype, scale)
  for k, v in pairs {"collision_box", "selection_box"} do
    local box = prototype[v]
    if box then
      local width = (box[2][1] - box[1][1]) * (scale / 2)
      local height = (box[2][2] - box[1][2]) * (scale / 2)
      local x = (box[1][1] + box[2][1]) / 2
      local y = (box[1][2] + box[2][2]) / 2
      box[1][1], box[2][1] = x - width, x + width
      box[1][2], box[2][2] = y - height, y + height
    end
  end
end

util.remove_flag = function(prototype, flag)
  if not prototype.flags then return end
  for k, v in pairs (prototype.flags) do
    if v == flag then
      table.remove(prototype.flags, k)
      break
    end
  end
end

util.add_flag = function(prototype, flag)
  if not prototype.flags then return end
  table.insert(prototype.flags, flag)
end

util.base_player = function()

  local player = util.table.deepcopy(data.raw.player.player or error("Wat man cmon why"))
  player.ticks_to_keep_gun = (600)
  player.ticks_to_keep_aiming_direction = (100)
  player.ticks_to_stay_in_combat = (600)
  util.remove_flag(player, "not-flammable")
  return player
end

util.path = function(str)
  return "__Hive_Mind_MitchPlay__/" .. str
end

util.empty_sound = function()
  return
  {
    filename = util.path("data/tf_util/empty-sound.ogg"),
    volume = 0
  }
end

util.empty_sprite = function()
  return
  {
    filename = util.path("data/tf_util/empty-sprite.png"),
    height = 1,
    width = 1,
    frame_count = 1,
    direction_count = 1
  }
end

util.damage_type = function(name)
  if not data.raw["damage-type"][name] then
    data:extend{{type = "damage-type", name = name, localised_name = {name}}}
  end
  return name
end

util.ammo_category = function(name)
  if not data.raw["ammo-category"][name] then
    data:extend{{type = "ammo-category", name = name, localised_name = {name}}}
  end
  return name
end

util.base_gun = function(name)
  return
  {
    name = name,
    localised_name = {name},
    type = "gun",
    stack_size = 10,
    flags = {}
  }
end

util.base_ammo = function(name)
  return
  {
    name = name,
    localised_name = {name},
    type = "ammo",
    stack_size = 10,
    magazine_size = 1,
    flags = {}
  }
end

local base_speed = 0.25
util.speed = function(multiplier)
  return multiplier * (base_speed)
end

util.remove_from_list = function(list, name)
  local remove = table.remove
  for i = #list, 1, -1 do
    if list[i] == name then
      remove(list, i)
    end
  end
end

local recursive_hack_something
recursive_hack_something = function(prototype, key, value)
  for k, v in pairs (prototype) do
    if type(v) == "table" then
      recursive_hack_something(v, key, value)
    end
  end
  prototype[key] = value
end
util.recursive_hack_something = recursive_hack_something

local recursive_hack_blend_mode
recursive_hack_blend_mode = function(prototype, value)
  for k, v in pairs (prototype) do
    if type(v) == "table" then
      if util.is_sprite_def(v) then
        v.blend_mode = value
      end
      recursive_hack_blend_mode(v, value)
    end
  end
end

util.copy = util.table.deepcopy

util.prototype = require("data/tf_util/prototype_util")

util.flying_unit_collision_mask = function()
  return {"not-colliding-with-itself", "layer-15"}
end

util.ground_unit_collision_mask = function()
  return {"not-colliding-with-itself", "player-layer", "train-layer"}
end

util.projectile_collision_mask = function()
  return {"layer-15", "player-layer", "train-layer"}
end

util.blight_collision_mask = function()
  return {"item-layer", "floor-layer"}
end

util.buildable_on_blight_collision_mask = function()
  return {"ground-tile", "water-tile", "player-layer"}
end

util.default_building_collision_mask = function()
  return {"item-layer", "object-layer", "player-layer", "water-tile"}
end

util.unit_flags = function()
  return {"player-creation", "placeable-off-grid"}
end

util.shift_box = function(box, shift)
  local left_top = box[1]
  local right_bottom = box[2]
  left_top[1] = left_top[1] + shift[1]
  left_top[2] = left_top[2] + shift[2]
  right_bottom[1] = right_bottom[1] + shift[1]
  right_bottom[2] = right_bottom[2] + shift[2]
  return box
end


util.shift_layer = function(layer, shift)
  layer.shift = layer.shift or {0,0}
  layer.shift[1] = layer.shift[1] + shift[1]
  layer.shift[2] = layer.shift[2] + shift[2]
  return layer
end

util.entity_types = function()
  return
  {
    accumulator = true,
    ["ammo-turret"] = true,
    ["arithmetic-combinator"] = true,
    arrow = true,
    ["artillery-flare"] = true,
    ["artillery-projectile"] = true,
    ["artillery-turret"] = true,
    ["artillery-wagon"] = true,
    ["assembling-machine"] = true,
    beacon = true,
    beam = true,
    boiler = true,
    car = true,
    ["cargo-wagon"] = true,
    ["character-corpse"] = true,
    cliff = true,
    ["combat-robot"] = true,
    ["constant-combinator"] = true,
    ["construction-robot"] = true,
    container = true,
    corpse = true,
    ["curved-rail"] = true,
    ["decider-combinator"] = true,
    ["deconstructible-tile-proxy"] = true,
    decorative = true,
    ["electric-energy-interface"] = true,
    ["electric-pole"] = true,
    ["electric-turret"] = true,
    ["entity-ghost"] = true,
    explosion = true,
    fire = true,
    fish = true,
    ["flame-thrower-explosion"] = true,
    ["fluid-turret"] = true,
    ["fluid-wagon"] = true,
    ["flying-text"] = true,
    furnace = true,
    gate = true,
    generator = true,
    ["heat-interface"] = true,
    ["heat-pipe"] = true,
    ["highlight-box"] = true,
    ["infinity-container"] = true,
    ["infinity-pipe"] = true,
    inserter = true,
    ["item-entity"] = true,
    ["item-request-proxy"] = true,
    lab = true,
    lamp = true,
    ["land-mine"] = true,
    ["leaf-particle"] = true,
    loader = true,
    locomotive = true,
    ["logistic-container"] = true,
    ["logistic-robot"] = true,
    market = true,
    ["mining-drill"] = true,
    ["offshore-pump"] = true,
    particle = true,
    ["particle-source"] = true,
    pipe = true,
    ["pipe-to-ground"] = true,
    player = true,
    ["player-port"] = true,
    ["power-switch"] = true,
    ["programmable-speaker"] = true,
    projectile = true,
    pump = true,
    radar = true,
    ["rail-chain-signal"] = true,
    ["rail-remnants"] = true,
    ["rail-signal"] = true,
    reactor = true,
    resource = true,
    roboport = true,
    ["rocket-silo"] = true,
    ["rocket-silo-rocket"] = true,
    ["rocket-silo-rocket-shadow"] = true,
    ["simple-entity"] = true,
    ["simple-entity-with-force"] = true,
    ["simple-entity-with-owner"] = true,
    smoke = true,
    ["smoke-with-trigger"] = true,
    ["solar-panel"] = true,
    ["speech-bubble"] = true,
    splitter = true,
    sticker = true,
    ["storage-tank"] = true,
    ["straight-rail"] = true,
    stream = true,
    ["tile-ghost"] = true,
    ["train-stop"] = true,
    ["transport-belt"] = true,
    tree = true,
    turret = true,
    ["underground-belt"] = true,
    unit = true,
    ["unit-spawner"] = true,
    wall = true
  }
end

util.area = function(position, radius)
  local x = position[1] or position.x
  local y = position[2] or position.y
  return {{x - radius, y - radius}, {x + radius, y + radius}}
end

util.deployer_name = function(name)
  local deployer_name = name:gsub("spawner","deployer")
  if deployer_name == name then return name.."-deployer" end
  return deployer_name
end

util.evo_factor_to_pollution_cost = function(evo_factor)
  return (shared.evolution_factor_to_pollution_cost.base + math.floor(0.5+shared.evolution_factor_to_pollution_cost.multiplier *((math.floor(0.5+evo_factor*10))^(shared.evolution_factor_to_pollution_cost.power_effect * evo_factor))) * 25)
end

util.required_pollution = function(name, entity)
  pollution_cost = shared.required_pollution[name]
  if pollution_cost then return pollution_cost end

  evolution_factor = entity.build_base_evolution_requirement
  if not evolution_factor then evolution_factor = 0 end
  if evolution_factor < 0 then evolution_factor = 0 end
  if evolution_factor > 0 and evolution_factor <= 0.05 then return 100 end
  return util.evo_factor_to_pollution_cost(evolution_factor)
end

util.needs_blight = function(name)
  if shared.needs_blight[name] then return true end
  if name:find("worm%-turret") then return true end
  return false
end

util.get_filtered_type_from_list = function(type_filter, prototype_list)
  local return_list = {}
  for name, prototype in pairs(prototype_list) do
    if prototype.type == type_filter then
      table.insert(return_list, prototype)
    end
  end
  return return_list
end

local is_default_unlocked
util.is_default_unlocked = function(name)
  if is_default_unlocked then return is_default_unlocked[name] end
  is_default_unlocked = shared.default_unlocked
  local spawners = util.get_spawner_order()
  if not game then
    local no_dupes_pls = {}
    for index, name in pairs(spawners) do
      for unit_index, unit in pairs(data.raw["unit-spawner"][name].result_units) do
        if unit[2][1][1] == 0.0 then
          is_default_unlocked[unit[1]] = true
          if not no_dupes_pls[unit[1]] then
            no_dupes_pls[unit[1]] = true
            is_default_unlocked[util.deployer_name(name)] = true
          end
        end
      end
    end
  else
    for index, name in pairs(spawners) do
      for unit_index, unit in pairs(game.entity_prototypes[name].result_units) do
        if unit.spawn_points[1].evolution_factor == 0.0 then
          is_default_unlocked[unit.unit] = true
        end
      end
    end
  end
  return is_default_unlocked[name]
end

local spawner_list
util.get_spawner_list = function()
  if spawner_list then return spawner_list end
  spawner_list = {}
  local spawners = data
  if spawners then
    spawners = data.raw["unit-spawner"]
  else
    spawners = util.get_filtered_type_from_list("unit-spawner", game.entity_prototypes)
  end
  for index, spawner in pairs(spawners) do
    table.insert(spawner_list, spawner.name)
  end
  return spawner_list
end

local spawner_order
util.get_spawner_order = function()
  if spawner_order then return spawner_order end
  spawner_order = {}
  local different_pollution_values = {
    shared.required_pollution[shared.deployers.biter_deployer],
    shared.required_pollution[shared.deployers.spitter_deployer]
  }
  local timely_table = {
    [shared.required_pollution[shared.deployers.biter_deployer]] = {"biter-spawner"},
    [shared.required_pollution[shared.deployers.spitter_deployer]] = {"spitter-spawner"}
  }
  local spawners = data
  if spawners then
    spawners = data.raw["unit-spawner"]
  else
    spawners = util.get_filtered_type_from_list("unit-spawner", game.entity_prototypes)
  end
  for index, spawner in pairs(spawners) do
    local name = spawner.name
    local pollution_cost = util.required_pollution(util.deployer_name(name), spawner)
    if timely_table[pollution_cost] then
      if name ~= "biter-spawner" and name ~= "spitter-spawner" then
        table.insert(timely_table[pollution_cost], name)
      end
    else
      timely_table[pollution_cost] = {name}
      table.insert(different_pollution_values, pollution_cost)
    end
  end
  table.sort(different_pollution_values)
  for index, value in pairs(different_pollution_values) do
    for index, spawner_name in pairs(timely_table[value]) do
      table.insert(spawner_order, spawner_name)
    end
  end
  return spawner_order
end

local deployer_order
util.get_deployer_order = function()
  if deployer_order then return deployer_order end
  deployer_order = {}
  for index, name in pairs(util.get_spawner_order()) do
    if game then
      if game.entity_prototypes[util.deployer_name(name)] then
        table.insert(deployer_order, util.deployer_name(name))
      end
    else
      if data.raw["assembling-machine"][util.deployer_name(name)] then
        table.insert(deployer_order, util.deployer_name(name))
      end
    end
  end
  return deployer_order
end

local worm_order
util.get_worm_order = function()
  if worm_order then return worm_order end
  worm_order = {}
  local different_pollution_values = {}
  local timely_table = {}
  local worms = game
  if not worms then
    worms = {}
    for name, turret in pairs(data.raw["turret"]) do
      if turret.name:find("worm%-turret") and util.required_pollution(name, turret) then
        table.insert(worms, turret)
      end
    end
  else
    worms = util.get_filtered_type_from_list("turret", worms.entity_prototypes)
  end
  for index, worm in pairs(worms) do
    local name = worm.name
    local pollution_cost = util.required_pollution(name, worm)
    if timely_table[pollution_cost] then
      table.insert(timely_table[pollution_cost], name)
    else
      timely_table[pollution_cost] = {name}
      table.insert(different_pollution_values, pollution_cost)
    end
  end
  table.sort(different_pollution_values)
  for index, value in pairs(different_pollution_values) do
    for index, worm_name in pairs(timely_table[value]) do
      table.insert(worm_order, worm_name)
    end
  end
  return worm_order
end

util.get_propper_repeat_counts = function(num_list)
  local lcm = 1
  for _,x in pairs(num_list) do
    local multiplier = 1
    while math.floor(lcm*multiplier/x) ~= lcm*multiplier/x do
      multiplier = 1 + multiplier
    end
    lcm = lcm * multiplier
  end
  return lcm
end


return util
