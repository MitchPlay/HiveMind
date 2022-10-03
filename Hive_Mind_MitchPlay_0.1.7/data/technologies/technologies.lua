local require = function(name) return require("data/technologies/"..name) end

require("biter_damage")

local biter = data.raw.unit["small-biter"]
local max_level
if settings.startup["hivemind-max-popcap"].value == 0 then
  max_level = "infinite"
else
  max_level = settings.startup["hivemind-max-popcap"].value
end


data:extend({
    {
      type = "technology",
      name = "popcap-1",
      localised_name = {"popcap_tech"},
      icons = {
            {icon_size = 1,
            icon = "__core__/graphics/empty.png",
            scale = 64},

            {icon_size = biter.icon_size,
            icon = biter.icon,
            shift = {1, -4},
            scale = 0.68},
            {icon_size = biter.icon_size,
            icon = biter.icon,
            shift = {-8, 0},
            scale = 0.7},
            {icon_size = biter.icon_size,
            icon = biter.icon,
            shift = {8, 6},
            scale = 0.78},},
      effects =
      {
        {
          type = "nothing",
          effect_description = {"modifier-description.popcap_modifier"} 
        }
      },
      prerequisites = {},
      unit =
      {
        count_formula = "L*1000",
        ingredients =
        {
          {names.pollution_proxy, 1}
        },
        time = 1
      },
      upgrade = true,
      max_level = max_level,
      order = "popcap",
      enabled = false
    }
})


local make_tech = function(prototype, icons)
  local tech =
  {
    type = "technology",
    name = "hivemind-unlock-"..prototype,
    localised_name = {"tech-description."..prototype},
    icons = icons,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = prototype
      }
    },
    prerequisites = names.needs_tech[prototype],
    unit =
    {
      count_formula = names.required_pollution[prototype] * 10,
      ingredients =
      {
        {names.pollution_proxy, 1}
      },
      time = 1
    },
    max_level = 1,
    upgrade = false,
    order = "hive",
    enabled = false
  }
  data:extend({tech})
end



for name, _ in pairs(names.needs_tech) do
  if not name:find("worm%-turret") and not names.default_unlocked[name] then
    make_tech(name, data.raw.item[name].icons)
  end
end