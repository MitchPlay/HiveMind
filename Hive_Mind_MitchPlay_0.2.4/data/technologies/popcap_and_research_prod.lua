
local shared = require("__Hive_Mind_MitchPlay__/shared.lua")


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
      name = "popcap",
      localised_name = {"tech-names.popcap_tech"},
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
    },


    {
        type = "technology",
        name = "hivemind-research-bonus",
        localised_name = {"tech-names.hivemind-research-bonus"},
        icons = data.raw.lab[shared.pollution_lab].icons,
        effects =
        {
          {
            type = "laboratory-productivity",
            modifier = 0.02
          }
        },
        prerequisites = {},
        unit =
        {
          count_formula = "500 * L^1.5",
          ingredients =
          {
            {names.pollution_proxy, 1}
          },
          time = 1
        },
        upgrade = true,
        max_level = "infinite",
        order = "research-bonus",
        enabled = false
    }
})

