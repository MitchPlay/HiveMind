
local make_damage_tech = function(category, icons)
  local tech =
    {
    type = "technology",
    name = category.."-damage",
    localised_name = {"tech-names."..category.."-damage"},
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
      count_formula = "2^(L-1)*"..math.ceil(1000*settings.startup["hivemind-tech-costs"].value),
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
 

local biters = data.raw.unit

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
    scale = 0.9
  },
  {
    icon_size = biters["big-biter"].icon_size,
    icon = biters["big-biter"].icon,
    shift = {19, 14},
    scale = 0.65
  },
  {
    icon_size = biters["medium-biter"].icon_size,
    icon = biters["medium-biter"].icon,
    shift = {-18, 17},
    scale = 0.55
  },
  {
    icon_size = biters["small-biter"].icon_size,
    icon = biters["small-biter"].icon,
    shift = {0, 25},
    scale = 0.4
  },
  {
    icon_size = 128,
    icon_minimaps = 4,
    icon = "__core__/graphics/icons/technology/constants/constant-damage.png",
    shift = {25, 25},
    scale = 0.25
  }
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
    scale = 0.9
  },
  {
    icon_size = biters["big-spitter"].icon_size,
    icon = biters["big-spitter"].icon,
    shift = {19, 14},
    scale = 0.65
  },
  {
    icon_size = biters["medium-spitter"].icon_size,
    icon = biters["medium-spitter"].icon,
    shift = {-18, 17},
    scale = 0.55
  },
  {
    icon_size = biters["small-spitter"].icon_size,
    icon = biters["small-spitter"].icon,
    shift = {0, 25},
    scale = 0.4
  },
  {
    icon_size = 128,
    icon_minimaps = 4,
    icon = "__core__/graphics/icons/technology/constants/constant-damage.png",
    shift = {25, 25},
    scale = 0.25
  }
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
  {
    icon_size = 128,
    icon_minimaps = 4,
    icon = "__core__/graphics/icons/technology/constants/constant-damage.png",
    shift = {25, 25},
    scale = 0.25
  }
})
