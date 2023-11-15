local util = require("__Hive_Mind_MitchPlay__/data/tf_util/tf_util")
local name = names.blight
local blight_color = {r = 0.3, b = 0.3, g = 0.15}
local blight = util.copy(data.raw.tile["sand-1"])
blight.name = name
blight.localised_name = {name}
blight.collision_mask = util.blight_collision_mask()

--util.recursive_hack_tint(blight, blight_color)
blight.tint = blight_color
blight.map_color = blight_color
--blight.allowed_neighbors = {}
blight.pollution_absorption_per_second = 0
blight.walking_sound = {}
for k = 1, 8 do
  table.insert(blight.walking_sound, {filename = util.path("data/tiles/blight-0"..k..".ogg")})
end
blight.walking_speed_modifier = 1.3
blight.autoplace = nil --data.raw["unit-spawner"]["biter-spawner"].autoplace
blight.needs_correction = false
blight.layer = 127
--This is needed to trick the game into setting the hidden tile for me.
blight.minable = {mining_time = 2^32, result = "raw-fish", required_fluid = "steam"}
--blight.allowed_neighbors = {}
--error(serpent.block(blight))



data:extend
{
  blight
}

for k, v in pairs (data.raw.cliff) do
  v.collision_mask = {"player-layer", "train-layer", "object-layer", "not-colliding-with-itself"}
end

for k, v in pairs (data.raw.tree) do
  v.collision_mask = {"player-layer", "train-layer", "object-layer"}
end

for k, v in pairs (data.raw["simple-entity"]) do
  if v.count_as_rock_for_filtered_deconstruction then
    v.collision_mask = {"player-layer", "train-layer", "object-layer"}
  end
end

--[[
for k, v in pairs (data.raw["corpse"]) do
  v.remove_on_tile_placement = false
end
]]

for k, v in pairs (data.raw.item) do
  if v.place_as_tile then
    table.insert(v.place_as_tile.condition, "floor-layer")
  end
end

--data.raw.item.landfill.place_as_tile.condition = {"floor-layer"}
