local util = require("script/script_util")
local names = require("shared")
local mod_gui = require("mod-gui")

remote.add_interface("unit-control-no-spawning",{["hivemind"] = util.get_deployer_order})

local script_data =
{
  player_lights = {},
  previous_life_data = {},
  player_spawns = {},
  force_balance = false,
  player_can_switch_tick = {}
}

local convert_nest

local be_friends = function(force_1, force_2)
  force_1.set_cease_fire(force_2, true)
  force_1.set_friend(force_2, true)
  force_2.set_cease_fire(force_1, true)
  force_2.set_friend(force_1, true)
end

local is_hivemind_technology = function(technology)
  local ingredients = technology.research_unit_ingredients
  for k, ingredient in pairs (ingredients) do
    if ingredient.type == "item" and ingredient.name == names.pollution_proxy then
      return true
    end
  end
  return false
end

local is_hivemind_unlocked = function(force, tech)
  if not names.needs_oponent_tech[force.name] then return true end
  if not names.needs_oponent_tech[force.name][tech.name] then return true end
  for x, _ in pairs(game.forces) do
    local check_all_techs = 0
    for _, y in pairs(names.needs_oponent_tech[force.name][tech.name]) do
      if game.forces[x].technologies[y].researched == true then
        check_all_techs = check_all_techs + 1
      end
    end
    if #names.needs_oponent_tech[force.name][tech.name] == check_all_techs then return true end
  end
  return false
end


local reset_hivemind_technology = function(force, hivemind_only)
  if not hivemind_only then hivemind_only = false end
  local is_hivemind = util.is_hivemind_force(force)
  if hivemind_only == false then
    for _, tech in pairs(force.technologies) do
      tech.enabled = (is_hivemind == is_hivemind_technology(tech)) and is_hivemind_unlocked(force, tech)
      tech.visible_when_disabled = (is_hivemind == is_hivemind_technology(tech))
    end
  else
    for _, tech in pairs(force.technologies) do
      if is_hivemind_unlocked(force, tech) == false or is_hivemind_technology(tech) == true then
        tech.enabled = (is_hivemind == is_hivemind_technology(tech)) and is_hivemind_unlocked(force, tech)
        tech.visible_when_disabled = (is_hivemind == is_hivemind_technology(tech))
      end
    end
  end
end

local create_hivemind_force

local get_hivemind_force = function(player)
  if player.force == "hivemind" then return game.forces.hivemind end
  if player.force == "hivemind-"..player.index then return game.forces["hivemind-"..player.index] end
  if settings.global["hivemind-is-one-team"].value == true then return game.forces.hivemind or create_hivemind_force(player) end
  return game.forces["hivemind-"..player.index] or create_hivemind_force(player)
end

local reset_hivemind_force
reset_hivemind_force = function(player)

  if player == "all" then
    for _, force in pairs(game.forces) do
      if util.is_hivemind_force(force) then reset_hivemind_force(force.name) end
    end
  end

  local force
  if type(player) == "string" then 
    force = game.forces[player]
  else
    force = get_hivemind_force(player)
  end
  
  if not force then return end
  force.reset()

  force.share_chart = true

  local enemy_force = game.forces.enemy
  if not settings.global["hivemind-hostile-to-enemies"].value then
    enemy_force.share_chart = true
    be_friends(force, enemy_force)
  end

  --hivemind friends
  if not settings.global["hivemind-hostile-to-hivemind"].value then
    for _, forces in pairs(game.forces) do
      if util.is_hivemind_force(forces) and forces ~= force then
        be_friends(force, forces)
      end
    end
  end

  if game.forces.spectator then
    be_friends(force, game.forces.spectator)
  end

  reset_hivemind_technology(force)

  force.evolution_factor = enemy_force.evolution_factor
  for k, recipe in pairs (force.recipes) do
    recipe.enabled = util.is_default_unlocked(recipe.name)
  end

end

create_hivemind_force = function(player)
  local force
  if settings.global["hivemind-is-one-team"].value == true then
    force = game.create_force("hivemind")
  else
    force = game.create_force("hivemind-"..player.index)
  end
  reset_hivemind_force(player)
  return force
end

local deploy_map = 
{
  ["biter-spawner"] = names.deployers.biter_deployer,
  ["spitter-spawner"] = names.deployers.spitter_deployer
}

local light_color = {r = 1, b = 0, g = 0.6}

local add_biter_light = function(player)
  if not player.character then return end
  local index = script_data.player_lights[player.index]
  if index and rendering.is_valid(index) then return end
  script_data.player_lights[player.index] = rendering.draw_light
  {
    sprite = "utility/light_medium",
    scale = 50,
    intensity = 0.5,
    color = light_color,
    target = player.character,
    surface = player.surface,
    forces = {player.force},
    minimum_darkness = 0,
  }
end

local reset_gun_inventory = function(player)
  if not player.character then return end
  local gun_inventory = player.character.get_inventory(defines.inventory.character_guns)
  local ammo_inventory = player.character.get_inventory(defines.inventory.character_ammo)
  gun_inventory.clear()
  ammo_inventory.clear()
  gun_inventory.insert(player.character.name.."-gun")
  ammo_inventory.insert(player.character.name.."-ammo")
  gun_inventory.insert(names.firestarter_gun)
  ammo_inventory.insert(names.firestarter_ammo)
end

local characters =
{
  [names.players.behemoth_biter_player] = 0.75,
  [names.players.big_biter_player] = 0.5,
  [names.players.medium_biter_player] = 0.25,
  [names.players.small_biter_player] = 0
}

local random_spawn_location = function(surface, shrinkage)
  local distance = (math.random() * 0.2 + 0.9) * settings.global["hivemind-spawning-distance"].value*surface.map_gen_settings.starting_area * shrinkage
  return util.radian_distance_to_x_y(math.random()*6.28, distance), distance
end

local create_character = function(player)

  local force = player.force
  local factor = game.forces.enemy.evolution_factor
  local name = names.players.small_biter_player
  for character, minimum_factor in pairs (characters) do
    if factor >= minimum_factor then
      name = character
      break
    end
  end
  local surface = player.surface
  local origin = script_data.player_spawns[player.index] or {0,0}
  local closest = surface.get_closest(origin, surface.find_entities_filtered{force = player.force, type = "assembling-machine"})
  local position
  local distance
  if closest then
    position = surface.find_non_colliding_position(name, closest.position, 64, 1)
  else
    surface.force_generate_chunk_requests()
    for x = 0, (names.spawning_attempts_per_radius * 6 - 1), 1 do
      local shrinkage = (6 - math.floor(x/names.spawning_attempts_per_radius)) / 6
      local position_1, return_distance = random_spawn_location(surface, shrinkage)
      position_1 = surface.find_non_colliding_position("hivemind-spawning-area", position_1, 64, 1)
      if position_1 then
        position = surface.find_non_colliding_position_in_box(name, {
          {position_1.x + game.entity_prototypes["hivemind-spawning-area"].collision_box.left_top.x, position_1.y + game.entity_prototypes["hivemind-spawning-area"].collision_box.left_top.y},
          {position_1.x + game.entity_prototypes["hivemind-spawning-area"].collision_box.right_bottom.x, position_1.y + game.entity_prototypes["hivemind-spawning-area"].collision_box.right_bottom.y}}, 1)
      end
      if position then distance = return_distance break end 
    end
  end
  if not position then position = surface.find_non_colliding_position(name, origin, 64, 1) end
  if not position then return nil end
  player.character = surface.create_entity
  {
    name = name,
    position = position,
    force = force
  }
  reset_gun_inventory(player)
  add_biter_light(player)
  return name, distance
end

local make_map_load = function()
  for _, surface in pairs(game.surfaces) do
    for x = 0, 20, 1 do
      surface.request_to_generate_chunks(random_spawn_location(surface, 1), 1)
    end
  end
end


local summon_starter_pack = function(player)

  local starter_package = names.summon_starter_data[player.character.name]
  if not starter_package then return end

  local surface = player.surface
  local position = player.position
  local force = player.force

  for name, count in pairs(starter_package.units) do
   for x=1, count do 
    local spawn_spot = surface.find_non_colliding_position(name, position, 64, 1)
    surface.create_entity
    {
      name = name,
      position = spawn_spot,
      force = force
    }
   end
  end

  if starter_package.default_biters_and_worm_unlocked_factor == 0 then return end

  local term = 1
  if player.character.name == "behemoth-biter-player" then term = game.forces.enemy.evolution_factor end

  local pollution_free = term * 3.5 * util.evo_factor_to_pollution_cost(starter_package.default_biters_and_worm_unlocked_factor * game.forces.enemy.evolution_factor)
  for name, technology in pairs(force.technologies) do
    local is_in_needs_tech = names.needs_tech[string.gsub(name,"hivemind%-unlock%-","")]
    if name:find("hivemind") and not is_in_needs_tech then
      if technology.research_unit_count <= pollution_free then
        technology.researched = true
      end
    end
  end

  --the stuff for bonus tech

end

local get_hive_entities = function(entity)
  local map = {}
  local surface = entity.surface
  local find = surface.find_entities_filtered
  local params = {force = "enemy", type = {"turret", "unit", "unit-spawner"}, radius = 20}
  --local count = 1
  local function recursive_find_neighbors(entity)
    local unit_number = entity.unit_number
    if (not unit_number) or map[unit_number] then return end
    map[entity.unit_number] = entity
    params.position = entity.position
    if entity.type == "unit-spawner" then
      for k, nearby in pairs (find(params)) do
        recursive_find_neighbors(nearby)
        --count = count + 1
      end
    end
  end
  recursive_find_neighbors(entity)
  --game.print(count)
  return map
end

local get_root_spawner = function(surface, position)
  local radius = 100
  local spawner
  local params = {position = position, radius = radius, type = "unit-spawner", force = "enemy", limit = nil}
  while true do
    local spawners = surface.find_entities_filtered(params)
    local count = #spawners
    if count > 0 then
      return spawners[math.random(count)]
    end
    params.radius = params.radius * 1.5
    if params.radius > 5000 then
      return
    end
  end
end

convert_nest = function(player, spawner)
  local surface = player.surface
  --local origin = player.force.get_spawn_position(surface)
  local origin = player.position
  local force = player.force
  local position = spawner.position
  script_data.player_spawns[player.index] = position
  local entities = get_hive_entities(spawner)
  local create_entity = surface.create_entity
  local find_entities_filtered = surface.find_entities_filtered
  local teleport_unit_away = util.teleport_unit_away
  for k, nearby in pairs (entities) do
    local deploy_name = deploy_map[nearby.name]
    if deploy_name then
      local deployer = create_entity{name = deploy_name, position = nearby.position, force = force, direction = (math.random(4) - 1) * 2, raise_built = true}
      nearby.destroy({raise_destroy = true})
      local area = deployer.bounding_box
      for k, unit in pairs (find_entities_filtered{area = area, type = "unit"}) do
        teleport_unit_away(unit, area)
      end
    elseif nearby.type == "unit" or nearby.type == "turret" then
      nearby.force = force
    end
  end
end


local join_hive_button =
{
  type = "button",
  name = "join-hive-button",
  caption = {"join-hive"},
  style = mod_gui.button_style
}

local leave_hive_button =
{
  type = "button",
  name = "leave-hive-button",
  caption = {"leave-hive"},
  style = mod_gui.button_style
}

local join_hive
local leave_hive

local actions =
{
  [join_hive_button.name] = function(event) join_hive(game.get_player(event.player_index)) end,
  [leave_hive_button.name] = function(event) leave_hive(game.get_player(event.player_index)) end,
}

local gui_init = function(player)
  local gui = mod_gui.get_button_flow(player)

  for name, action in pairs (actions) do
    if gui[name] then gui[name].destroy() end
  end

  --on_player_changed_force --when players switch sides (done) + then the total hivemind players is below the count.
  --on_player_created --when a new player joins (done)
  --on_runtime_mod_setting_changed --for when the cooldown changes 
  --on_tick --for the cooldown

  local element
  if util.is_hivemind_force(player.force) then
    element = leave_hive_button
  else
    element = join_hive_button
  end

  gui.add(element)
end

local biter_quickbar
local biter_quickbar = function()
  if biter_quickbar then return biter_quickbar end
  biter_quickbar = util.get_deployer_order()
  for name, pollution in pairs (names.required_pollution) do
    if game.item_prototypes[name] and game.item_prototypes[name].subgroup.name ~= "hivemind-deployer" and game.item_prototypes[name].subgroup.name ~= "worm-subgroup" then
      table.insert(biter_quickbar, name)
    end
  end
  for index, name in pairs(util.get_worm_order()) do
    table.insert(biter_quickbar, name)
  end
  return biter_quickbar
end


join_hive = function(player)

  if player.controller_type ~= defines.controllers.character then return end

  if script_data.player_can_switch_tick[player.index] then
    if script_data.player_can_switch_tick[player.index] + settings.global["hivemind-switch-timer"].value > game.tick then
      player.print({"script-text.cant-join-time", math.ceil((script_data.player_can_switch_tick[player.index] + settings.global["hivemind-switch-timer"].value - game.tick)/60)})
      return 
    end
  end

  script_data.player_can_switch_tick[player.index] = game.tick

  if settings.global["hivemind-max-hive-players"].value ~= 0 then

    local hivemind_players = 0
    for _, force in pairs(game.forces) do
      if util.is_hivemind_force(force) then
        for _, name in pairs(force.players) do
          hivemind_players = 1 + hivemind_players
        end
      end
    end
    if hivemind_players >= settings.global["hivemind-max-hive-players"].value then return end
  end


  local force = get_hivemind_force(player)
  if script_data.force_balance then
    local max = 1
    local name
    for k, force in pairs (game.forces) do
      local count = #force.connected_players
      if count > max then
        max = count
        name = force.name
      end
    end
    if name == force.name then
      player.print({"cant-join-force-balance"})
      return
    end
  end

  local position = player.position
  local surface = player.surface

  if remote.interfaces["pvp"] then
    local battle_surface = game.surfaces["battle_surface_1"] or game.surfaces["battle_surface_2"]
    if battle_surface then
      surface = battle_surface
      local teams = remote.call("pvp", "get_teams")
      for k, team in pairs (teams) do
        local force = game.forces[team.name]
        if force and force.valid then
          position = force.get_spawn_position(surface)
          break
        end
      end
    else
      player.print({"cant-join-pvp"})
      return
    end
  end

  --local spawner = get_root_spawner(surface, position)
  --if not spawner then
  --  player.print({"cant-find-spawner"})
  --  return
  --end
  if player.surface ~= surface then
    player.character = nil
    player.teleport(position, surface)
  end
  local get_quick_bar_slot = player.get_quick_bar_slot
  local set_quick_bar_slot = player.set_quick_bar_slot
  local quickbar = {}
  local biter_quickbar = biter_quickbar()
  for k = 1, 100 do
    local item = get_quick_bar_slot(k)
    if item then quickbar[k] = item.name end
    set_quick_bar_slot(k, biter_quickbar[k])
  end
  player.set_active_quick_bar_page(1, 1)
  player.set_active_quick_bar_page(2, 2)
  local previous_life_data =
  {
    force = player.force,
    character = player.character,
    character_name = player.character and player.character.name,
    controller = player.controller_type,
    position = player.position,
    quickbar = quickbar,
    tag = player.tag,
    color = player.color,
    chat_color = player.chat_color
  }
  script_data.previous_life_data[player.index] = previous_life_data
  player.character = nil
  player.force = force
  --convert_nest(player, spawner)
  --player.game_view_settings.show_controller_gui = false
  local _, distance = create_character(player)
  summon_starter_pack(player)
  player.color = {r = 255, g = 100, b = 100}
  player.chat_color = {r = 255, g = 100, b = 100}
  player.tag = "[color=255,100,100]HIVE[/color]"
  gui_init(player)
  game.print{"joined-hive", player.name}
  if distance then player.print({"script-text.spawn-distance", math.floor(distance + 0.5)}) end
end

local check_hivemind_disband = function(force)

  if not util.is_hivemind_force(force) then return end

  if #force.players > 0 then
    --still players on this force, so its alright.
    return
  end

  --We just need to turn the crafting machines back into spawners.

  local map = {}
  for name, entity in pairs (game.entity_prototypes) do
    if entity.type == "unit-spawner" then
      map[util.deployer_name(name)] = name
    end
  end

  local destroy_map_type =
  {
    ["entity-ghost"] = true,
    lab = true,
    ["mining-drill"] = true
  }

  local params = {force = force, type = {"turret", "unit", "unit-spawner", "entity-ghost", "radar", "assembling-machine"}}
  local enemy_force = game.forces.enemy
  for surface_index, surface in pairs(game.surfaces) do
    for k, entity in pairs (surface.find_entities_filtered(params)) do
      if entity.valid then
        if map[entity.name] then
          surface.create_entity{name = map[entity.name], position = entity.position, force = entity.force, raise_built = true}
          entity.destroy()
        elseif destroy_map_type[entity.type] then
          entity.destroy()
        else
          if entity.type == "unit" then
            entity.ai_settings.allow_try_return_to_spawner = true
          end
          entity.force = enemy_force
        end
      end
    end
  end

  game.merge_forces(force, game.forces.enemy)

end

leave_hive = function(player)
  
  if player.controller_type ~= defines.controllers.character then return end

  if script_data.player_can_switch_tick[player.index] then
    if script_data.player_can_switch_tick[player.index] >= game.tick then
      player.print({"script-text.cant-leave-time", math.ceil((script_data.player_can_switch_tick[player.index] - game.tick)/60)})
      return
    end
  end

  script_data.player_can_switch_tick[player.index] = settings.global["hivemind-switch-timer"].value + game.tick

  local previous_life_data = script_data.previous_life_data[player.index]
  local force = previous_life_data.force
  local character = previous_life_data.character
  local controller = previous_life_data.controller
  local character_name = previous_life_data.character_name
  local color = previous_life_data.color or {r = 255, g = 255, b = 255}
  local chat_color = previous_life_data.chat_color or color
  local hivemind_force = player.force

  local biter = player.character
  player.character = nil
  if biter and biter.valid then biter.die() end

  player.force = force
  player.color = color
  player.chat_color = chat_color
  local surface = player.surface
  if character then
    --he used to have a character
    if character.valid then
      player.character = character
    else
      --however his old character died or something...
      player.character = surface.create_entity
      {
        name = character_name,
        position = surface.find_non_colliding_position(character_name, force.get_spawn_position(surface), 0, 1),
        force = force
      }
    end
  else
    player.teleport(previous_life_data.position)
  end
  gui_init(player)

  local set_quick_bar_slot = player.set_quick_bar_slot
  local old_quickbar = previous_life_data.quickbar
  for k = 1, 100 do
    set_quick_bar_slot(k, old_quickbar[k])
  end

  player.tag = previous_life_data.tag or ""

  game.print{"left-hive", player.name}
  check_hivemind_disband(hivemind_force)

end

local on_player_respawned = function(event)
  local player = game.get_player(event.player_index)
  if not util.is_hivemind_force(player.force) then return end
  player.character.destroy()
  create_character(player)

end

  
local pollution_values =
{
  --wood = 1,
  --coal = 1.5,
  --stone = 0.1
}

local on_player_mined_entity = function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  local force = player.force

  if not (force and force.valid and util.is_hivemind_force(force)) then return end

  local entity = event.entity
  if not (entity and entity.valid) then return end

  local buffer = event.buffer
  if not (buffer and buffer.valid) then return end
  local surface = entity.surface
  local position = entity.position
  local remove = buffer.remove
  local total_pollution = 0
  for name, count in pairs (buffer.get_contents()) do
    local pollution = pollution_values[name]
    if pollution then
      total_pollution = total_pollution + (pollution * count)
    end
    remove{name = name, count = count}
  end
  if total_pollution == 0 then return end

  surface.create_entity{name = "flying-text", position = position, text = "Pollution +"..total_pollution, color = {r = 1, g = 0.2, b = 0.2}}
  surface.pollute(position, total_pollution)

end

local on_gui_click = function(event)
  local gui = event.element
  if not (gui and gui.valid) then return end
  local name = gui.name
  if name and actions[name] then return actions[name](event) end
end

local on_player_joined_game = function(event)
  local player = game.get_player(event.player_index)
  if util.is_hivemind_force(player.force) then
    add_biter_light(player)
  end
  gui_init(player)
end

local on_player_created = function(event)
  local player = game.get_player(event.player_index)
  gui_init(player)
end

remote.add_interface("hive_mind",
{
  --test = function(player) return join_hive(player) end
  set_force_balance = function(bool)
    script_data.force_balance = bool
  end
})

local on_marked_for_deconstruction = function(event)
  if not event.player_index then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  local force = player.force
  if not util.is_hivemind_force(force) then return end
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if entity.force == force then
    entity.die(force)
  end
end

local on_player_changed_force = function(event)
  local old_force = event.force

  local player = game.get_player(event.player_index)
  check_hivemind_disband(old_force)
  gui_init(player)
end

local allowed_types =
{
  ["blueprint"] = true,
  ["copy-paste-tool"] = true,
  ["selection-tool"] = true,
  ["deconstruction-item"] = true,
  ["gun"] = true,
  ["ammo"] = true,

}

local on_player_cursor_stack_changed = function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  if not util.is_hivemind_force(player.force) then return end
  local stack = player.cursor_stack
  if not stack.valid_for_read then return end
  if allowed_types[stack.type] then return end

  player.print({"biters-cant-hold", stack.prototype.localised_name})
  player.surface.spill_item_stack(player.position, stack, false, nil, false)
  stack.clear()
end

local on_player_gun_inventory_changed = function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  if not util.is_hivemind_force(player.force) then return end
  reset_gun_inventory(player)
end

local on_player_ammo_inventory_changed = function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  if not util.is_hivemind_force(player.force) then return end
  reset_gun_inventory(player)
end

local on_player_ammo_inventory_changed = function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  if not util.is_hivemind_force(player.force) then return end
  reset_gun_inventory(player)
end

local on_player_armor_inventory_changed = function(event)
  local player = game.get_player(event.player_index)
  if not (player and player.valid) then return end
  if not util.is_hivemind_force(player.force) then return end
  if not player.character then return end
  local armor_inventory = player.get_inventory(defines.inventory.character_armor)
  armor_inventory.clear()
end

local set_map_settings = function()
  game.map_settings.pollution.enabled = true
  game.map_settings.pollution.min_to_diffuse = 10
  game.map_settings.pollution.diffusion_ratio = 0.03
  game.map_settings.pollution.expected_max_per_chunk = 500
  game.map_settings.pollution.min_to_show_per_chunk = 100
end

local allowed_gui_types =
{
  ["assembling-machine"] = true,
  ["lab"] = true,
}

local on_gui_opened = function(event)
  if event.gui_type ~= defines.gui_type.entity then return end
  local player = game.get_player(event.player_index)
  if not util.is_hivemind_force(player.force) then return end
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if not allowed_gui_types[entity.type] then
    player.opened = nil
  end
end

local on_forces_merging = function(event)
  local source = event.source
  local destination = event.destination

  if not (source and source.valid and destination and destination.valid) then
    return
  end

  for k, data in pairs (script_data.previous_life_data) do
    if data.force == source then
      data.force = destination
    end
  end

end

local events =
{
  [defines.events.on_player_respawned] = on_player_respawned,
  --[defines.events.on_tick] = on_tick,
  [defines.events.on_player_mined_entity] = on_player_mined_entity,
  [defines.events.on_player_joined_game] = on_player_joined_game,
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_gui_click] = on_gui_click,
  [defines.events.on_marked_for_deconstruction] = on_marked_for_deconstruction,
  [defines.events.on_player_changed_force] = on_player_changed_force,
  [defines.events.on_player_cursor_stack_changed] = on_player_cursor_stack_changed,
  [defines.events.on_player_gun_inventory_changed] = on_player_gun_inventory_changed,
  [defines.events.on_player_ammo_inventory_changed] = on_player_ammo_inventory_changed,
  [defines.events.on_player_armor_inventory_changed] = on_player_armor_inventory_changed,
  [defines.events.on_forces_merging] = on_forces_merging,
  [defines.events.on_gui_opened] = on_gui_opened

}

local on_wave_defense_round_started = function(event)
  reset_hivemind_force("all")
  set_map_settings()
end

local on_pvp_round_start = function(event)
  reset_hivemind_force("all")
end

local register_wave_defense = function()
  if not remote.interfaces["wave_defense"] then return end
  local wave_defense_events = remote.call("wave_defense", "get_events")
  events[wave_defense_events.on_round_started] = on_wave_defense_round_started
end

local register_pvp = function()
  if not remote.interfaces["pvp"] then return end
  local pvp_events = remote.call("pvp", "get_events")
  events[pvp_events.on_round_start] = on_pvp_round_start
end


local online = function(list, is_force)
  local return_list = {}
  for index, name in pairs(list) do
    if is_force then
      for _, player in pairs(game.forces[name].players) do
        if player.connected == true then
          table.insert(return_list, name)
        end
      end
    else
      if game.players[name].connected == true then
        table.insert(return_list, name)
      end
    end
  end
  return return_list
end

local force_to_player = function(list)
  local return_list = {}
  for _, name in pairs(list) do
    for _, player in pairs(game.forces[name].players) do
      table.insert(return_list, player.name)
    end
  end
  return return_list
end

commands.add_command("hivemind", {"command.hivemind-help"}, function(command)
  local player = game.get_player(command.player_index)
  parameters = {}

  if command.parameter then
    for match in (command.parameter.." "):gmatch("(.-)".." ") do
      table.insert(parameters, match);
    end
  end

  if parameters[1] == "list" or parameters[1] == "l" then
    table.remove(parameters, 1)

    local is_force = true
    local only_count = false
    local list_of_results = {}
    local result_type = "forces"
    for _, force in pairs(game.forces) do
     if util.is_hivemind_force(force) then
      table.insert(list_of_results, force.name)
     end
    end

    for _, parameter in pairs(parameters) do
      if (parameter == "player" or parameter == "p") and is_force == true then
        is_force = false
        list_of_results = force_to_player(list_of_results)
        if result_type == "forces" then result_type = "players" end
        if result_type == "online-forces" then result_type = "online-forces-players" end
      elseif parameter == "online" or parameter == "o" then
        list_of_results = online(list_of_results, is_force)
        if result_type == "forces" then result_type = "online-forces" end
        if result_type == "players" or result_type == "online-forces-players" then result_type = "online-players" end
      elseif parameter == "count" or parameter == "c" then
        only_count = true
      end
    end

    player.print({"command.hivemind-result-"..result_type, #list_of_results})

    if not only_count then
      for _, name in pairs(list_of_results) do
        if is_force then
          local online = ""
          for _, player in pairs(game.forces[name].players) do
            if player.connected then
              online = " (online)"
            end
          end
          player.print(name..online)
        else
          if game.players[name].connected then
            player.print(name.." (online)")
          else
            player.print(name)
          end
        end
      end
    end


  elseif parameters[1] == "force" or parameters[1] == "f" then
    table.remove(parameters, 1)

    local force
    if parameters then
      if game.players[parameters[1]] then force = game.players[parameters[1]].force end
      if game.forces[parameters[1]] then force = game.forces[parameters[1]] end
    end
    table.remove(parameters, 1)

    if force then

      if parameters[1] == "player" or parameters[1] == "p" then
        table.remove(parameters, 1)

        local player_list = {}
        for _, player in pairs(force.players) do
          table.insert(player_list, player.name)
        end
        local result_type = "players"
        local only_count = false

        for _, parameter in pairs(parameters) do
          if parameter == "online" or parameter == "o" then
            player_list = online(player_list)
            if result_type == "players" then result_type = "online-players" end
          elseif parameter == "count" or parameter == "c" then
            only_count = true
          end
        end

        player.print({"command.hivemind-result-"..result_type, #player_list})

        if not only_count then
          for _, name in pairs(player_list) do
            if game.players[name].connected then
              player.print(name.." (online)")
            else
              player.print(name)
            end
          end
        end

      elseif parameters[1] == "ally" or parameters[1] == "a" or parameters[1] == "fight" or parameters[1] == "f" then
        
        local make_friendly = false
        if parameters[1] == "ally" or parameters[1] == "a" then make_friendly = true end
        table.remove(parameters, 1)
        
        local force_2
        if parameters then
          if game.players[parameters[1]] then force_2 = game.players[parameters[1]].force end
          if game.forces[parameters[1]] then force_2 = game.forces[parameters[1]] end
        end

        if force_2 then
          if player.admin then
            force.set_cease_fire(force_2, make_friendly)
            force.set_friend(force_2, make_friendly)
            force_2.set_cease_fire(force, make_friendly)
            force_2.set_friend(force, make_friendly)
            player.print({"command.hivemind-ally-fight-set", force.name, force_2.name, (function() if make_friendly == true then return {"command.allies"} end return {"command.enemies"} end)()})
          else
            player.print({"command.admin-only", {"command.hivemind-ally-fight-name"}})
          end
        else
          player.print({"command.hivemind-ally-fight"})
        end

      elseif parameters[1] == "status" or parameters[1] == "s" then
        table.remove(parameters, 1)

        if parameters[1] == "list" or parameters[1] == "l" then
          table.remove(parameters, 1)

          local filters_ally = false
          local filters_cease_fire = false
          local filters_enemy = false

          for _, parameter in pairs(parameters) do
            if parameter == "ally" or parameter == "a" then filters_ally = true end
            if parameter == "cease_fire" or parameter == "f" then filters_cease_fire = true end
            if parameter == "enemy" or parameter == "e" then filters_enemy = true end
          end
          if filters_ally == false and filters_cease_fire == false and filters_enemy == false then
            filters_ally = true
            filters_cease_fire = true
            filters_enemy = true
          end

          local forces_list = {}
          for _, check_force in pairs(game.forces) do
            if check_force ~= force then
              if force.get_friend(check_force) then
                if filters_ally == true then
                  table.insert(forces_list, check_force.name)
                end
              elseif force.get_cease_fire(check_force) then
                if filters_cease_fire == true then
                  table.insert(forces_list, check_force.name)
                end
              else
                if filters_enemy == true then
                  table.insert(forces_list, check_force.name)
                end
              end
            end
          end

          local result_type = "forces"
          local is_force = true
          local only_count = false

          for _, parameter in pairs(parameters) do
            if (parameter == "player" or parameter == "p") and is_force == true then
              is_force = false
              forces_list = force_to_player(forces_list)
              if result_type == "forces" then result_type = "players" end
              if result_type == "online-forces" then result_type = "online-forces-players" end
            elseif parameter == "online" or parameter == "o" then
              forces_list = online(forces_list, is_force)
              if result_type == "forces" then result_type = "online-forces" end
              if result_type == "players" or result_type == "online-forces-players" then result_type = "online-players" end
            elseif parameter == "count" or parameter == "c" then
              only_count = true
            end
          end
         
          player.print({"command.hivemind-result-"..result_type, #forces_list})
        
          if not only_count then
            for _, name in pairs(forces_list) do
              local force_2
              if is_force then
                force_2 = game.forces[name]
              else
                force_2 = game.players[name].force
              end
              local status = " (enemy)"
              if force.get_cease_fire(force_2) then status = " (cease_fire)" end
              if force.get_friend(force_2) then status = " (ally)" end
              if is_force then
                local online = ""
                for _, player in pairs(game.forces[name].players) do
                  if player.connected then
                    online = " (online)"
                  end
                end
                player.print(name..status..online)
              else
                if game.players[name].connected then
                  player.print(name..status.." (online)")
                else
                  player.print(name..status)
                end
              end
            end
          end
          
        elseif parameters[1] == "force" or parameters[1] == "f" then
          table.remove(parameters, 1)

          local force_2
          if parameters then
            if game.players[parameters[1]] then force_2 = game.players[parameters[1]].force end
            if game.forces[parameters[1]] then force_2 = game.forces[parameters[1]] end
          end

          if force_2 then
            local status = " (enemy)"
            if force.get_cease_fire(force_2) then status = " (cease_fire)" end
            if force.get_friend(force_2) then status = " (ally)" end
            player.print(force_2.name..status)
          else
            player.print({"command.hivemind-status"})
          end
        else
          player.print({"command.hivemind-status"})
        end
        
      elseif parameters[1] == "reset" or parameters[1] == "r" then
      
        if player.admin then
          if util.is_hivemind_force(force) then
            for _, force_2 in pairs(game.forces) do
              if force ~= force_2 then
                local allies = false
                if force_2.name == "enemy" then
                  allies = settings.global["hivemind-hostile-to-enemies"].value
                elseif util.is_hivemind_force(force_2) then
                  allies = settings.global["hivemind-hostile-to-hivemind"].value
                end
                force.set_cease_fire(force_2, allies)
                force.set_friend(force_2, allies)
                force_2.set_cease_fire(force, allies)
                force_2.set_friend(force, allies)
              end
            end
            player.print({"command.hivemind-reset",force.name})

          else
            player.print({"command.hivemind-no-reset",force.name})
          end

        else
          player.print({"command.admin-only", {"command.hivemind-reset-name"}})
        end

      else
        player.print(force.name)
      end
    else
      player.print({"command.hivemind-force"})
    end

  elseif parameters[1] == "reset_all" or parameters[1] == "ra" then

    if player.admin then

      for _, force in pairs(game.forces) do
        if util.is_hivemind_force(force) then
          for _, force_2 in pairs(game.forces) do
            if force ~= force_2 then
              local allies = false
              if force_2.name == "enemy" then
                allies = settings.global["hivemind-hostile-to-enemies"].value
              elseif util.is_hivemind_force(force_2) then
                allies = settings.global["hivemind-hostile-to-hivemind"].value
              end
              force.set_cease_fire(force_2, allies)
              force.set_friend(force_2, allies)
              force_2.set_cease_fire(force, allies)
              force_2.set_friend(force, allies)
            end
          end
        end
      end
      player.print({"command.hivemind-reset-all-forces"})
    else
      player.print({"command.admin-only", {"command.hivemind-reset-all-name"}})
    end

  else
    player.print({"command.hivemind-hivemind"})
  end
end)

local lib = {}

lib.get_events = function() return events end

lib.on_init = function()
  global.hive_mind = global.hive_mind or script_data
  for k, player in pairs (game.players) do
    gui_init(player)
  end
  set_map_settings()
  register_wave_defense()
  register_pvp()
  make_map_load()
end

lib.on_load = function()
  script_data = global.hive_mind or script_data
  register_wave_defense()
  register_pvp()
end

lib.on_configuration_changed = function()
  if script_data.hive_mind_forces then
    local target = get_hivemind_force()
    for k, force in pairs (script_data.hive_mind_forces) do
      game.merge_forces(force, target)
    end
    script_data.hive_mind_forces = nil
  end
  script_data.player_spawns = script_data.player_spawns or {}
  set_map_settings()
  for _, force in pairs(game.forces) do
    reset_hivemind_technology(force,true)
  end
end

return lib