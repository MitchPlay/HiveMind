
local make_damage_tech = function(category, icons)
  local tech =
    {
    type = "technology",
    name = category.."-damage-1",
    localised_name = {category.."-damage"},
    icons = icons,
    effects =
    {
      {
        type = "ammo-damage",
        ammo_category = category,
        modifier = 0.1
      }
    },
    prerequisites = {},
    unit =
    {
      count_formula = "2^(L-1)*1000",
      ingredients =
      {
        {names.pollution_proxy, 1}
      },
      time = 1
    },
    max_level = "infinite",
    upgrade = true,
    order = catagory,
    enabled = false
  }
  data:extend{tech}
end

--local take_the_frame = function(tint1, tint2)
--  return {
--    layers = {
--      filename = "__base__/graphics/entity/spitter.hr-spitter-attack-03.png"
--
--    }
--  }
--end
  

local biters = data.raw.unit
local shifting = {{19, 14},{-18, 17},{0, 25}}
local scaling = {0.9, 0.65, 0.55, 0.4}

make_damage_tech("biter-melee",
{
  {
    icon_size = 1,
    icon = "__core__/graphics/empty.png",
    scale = 64
  },
  {
    icon_size = biters["behemoth-biter"].icon_size,
    icon = biters["behemoth-biter"].icon,
    scale = scaling[1]
  },
  {
    icon_size = biters["big-biter"].icon_size,
    icon = biters["big-biter"].icon,
    shift = shifting[1],
    scale = scaling[2]
  },
  {
    icon_size = biters["medium-biter"].icon_size,
    icon = biters["medium-biter"].icon,
    shift = shifting[2],
    scale = scaling[3]
  },
  {
    icon_size = biters["small-biter"].icon_size,
    icon = biters["small-biter"].icon,
    shift = shifting[3],
    scale = scaling[4]
  },
})

make_damage_tech("spitter-biological",
{
  {
    icon_size = 1,
    icon = "__core__/graphics/empty.png",
    scale = 64
  },
  {
    icon_size = biters["behemoth-spitter"].icon_size,
    icon = biters["behemoth-spitter"].icon,
    scale = scaling[1]
  },
  {
    icon_size = biters["big-spitter"].icon_size,
    icon = biters["big-spitter"].icon,
    shift = shifting[1],
    scale = scaling[2]
  },
  {
    icon_size = biters["medium-spitter"].icon_size,
    icon = biters["medium-spitter"].icon,
    shift = shifting[2],
    scale = scaling[3]
  },
  {
    icon_size = biters["small-spitter"].icon_size,
    icon = biters["small-spitter"].icon,
    shift = shifting[3],
    scale = scaling[4]
  },
})

local worms = data.raw.turret

make_damage_tech("worm-biological",
{
  {
    icon_size = 1,
    icon = "__core__/graphics/empty.png",
    scale = 64
  },
  {
    icon_size = worms["behemoth-worm-turret"].icon_size,
    icon = worms["behemoth-worm-turret"].icon,
    shift = {0, -4},
    scale = 0.9
  },
  {
    icon_size = worms["big-worm-turret"].icon_size,
    icon = worms["big-worm-turret"].icon,
    shift = {19, 12},
    scale = 0.65
  },
  {
    icon_size = worms["medium-worm-turret"].icon_size,
    icon = worms["medium-worm-turret"].icon,
    shift = {-18, 15},
    scale = 0.55
  },
  {
    icon_size = worms["small-worm-turret"].icon_size,
    icon = worms["small-worm-turret"].icon,
    shift = {0, 23},
    scale = 0.4
  },
})