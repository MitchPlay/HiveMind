local util = require("util")

local deregister_gui_internal
deregister_gui_internal = function(gui_element, data)
  data[gui_element.index] = nil
  for k, child in pairs (gui_element.children) do
    deregister_gui_internal(child, data)
  end
end

util.deregister_gui = function(gui_element, data)
  local player_data = data[gui_element.player_index]
  if not player_data then return end
  deregister_gui_internal(gui_element, player_data)
end

util.register_gui = function(data, gui_element, param)
  local player_data = data[gui_element.player_index]
  if not player_data then
    data[gui_element.player_index] = {}
    player_data = data[gui_element.player_index]
  end
  player_data[gui_element.index] = param
end

util.gui_action_handler = function(event, data, functions)
  error("don't actually use me")
  if not data then error("Gui action handler data is nil") end
  if not functions then error("Gui action handler functions is nil") end
  local element = event.element
  if not (element and element.valid) then return end
  local player_data = data[event.player_index]
  if not player_data then return end
  local action = player_data[element.index]
  if action then
    functions[action.type](event, action)
    return true
  end
end

util.center = function(area)
  local left_top = area.left_top or area[1]
  local ltx = left_top.x or left_top[1]
  local lty = left_top.y or left_top[2]
  local right_bottom = area.right_bottom or area[2]
  local rbx = right_bottom.x or right_bottom[1]
  local rby = right_bottom.y or right_bottom[2]

  return {x = (ltx + rbx) / 2, y = (lty + rby) / 2}
end

util.distance = function(p1, p2)
  local x1 = p1.x or p1[1]
  local y1 = p1.y or p1[2]
  local x2 = p2.x or p2[1]
  local y2 = p2.y or p2[2]
  return (((x1 - x2) ^ 2) + ((y1 - y2) ^ 2)) ^ 0.5
end

util.radius = function(area)
  return util.distance(area.right_bottom or area[1], area.left_top or area[2]) / 2
end


util.area = function(position, radius)
  local x = position[1] or position.x
  local y = position[2] or position.y
  return {{x - radius, y - radius}, {x + radius, y + radius}}
end

util.clear_item = function(entity, item_name)
  if not (entity and entity.valid and item_name) then return end
  entity.remove_item{name = item_name, count = entity.get_item_count(item_name)}
end

util.copy = util.table.deepcopy

util.first_key = function(map)
  local k, v = next(map)
  return k
end

util.first_value = function(map)
  local k, v = next(map)
  return v
end

util.angle = function(position_1, position_2)
  local d_x = (position_2[1] or position_2.x) - (position_1[1] or position_1.x)
  local d_y = (position_2[2] or position_2.y) - (position_1[2] or position_1.y)
  return math.atan2(d_y, d_x)
end

util.teleport_unit_away = function(unit, area)
  local center = util.center(area)
  local position = unit.position
  local dx = position.x - center.x
  local dy = position.y - center.y
  local radius = (util.radius(area) + unit.get_radius())
  local current_distance = ((dx * dx) + (dy * dy) ) ^ 0.5
  if current_distance == 0 then
    dx = radius
    dy = radius
  else
    local scale_factor = radius / current_distance
    dx = dx * scale_factor
    dy = dy * scale_factor
  end
  local new_position = {x = center.x + dx, y = center.y + dy}
  local non_collide = unit.surface.find_non_colliding_position(unit.name, new_position, 0, 0.1)
  unit.teleport(non_collide)
end

util.radian_distance_to_x_y = function(radian, distance)
  return {math.sin(radian) * distance, math.cos(radian) * distance}
end

util.is_hivemind_force = function(force)
  if (force.name:find("hivemind")) then return true end
  return false
end

local ft_util = require("__Hive_Mind_MitchPlay__/data/tf_util/tf_util")

local hivemind_entity_list
util.get_hivemind_entity_list = function()
  if hivemind_entity_list then return hivemind_entity_list end
  hivemind_entity_list = {}
  local worm_list = ft_util.get_worm_order() or {}
  local spawner_list = ft_util.get_spawner_list() or {}
  local shared_list = names.required_pollution or {}
  for _, name in pairs(worm_list) do
    if not hivemind_entity_list[name] then
      hivemind_entity_list[name] = true
    end
  end
  for _, name in pairs(spawner_list) do
    if not hivemind_entity_list[name] then
      hivemind_entity_list[name] = true
    end
  end
  for name, _ in pairs(shared_list) do
    if not hivemind_entity_list[name] then
      hivemind_entity_list[name] = true
    end
  end
  return hivemind_entity_list
end

util.needs_creep = ft_util.needs_creep
util.required_pollution = ft_util.required_pollution
util.evo_factor_to_pollution_cost = ft_util.evo_factor_to_pollution_cost
util.get_spawner_order = ft_util.get_spawner_order
util.get_deployer_order = ft_util.get_deployer_order
util.get_worm_order = ft_util.get_worm_order
util.get_spawner_list = ft_util.get_spawner_list

return util