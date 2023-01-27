local require = function(name) return require("data/technologies/"..name) end

require("biter_damage.lua")
require("popcap_and_research_prod.lua")

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
      count_formula = math.ceil(names.required_pollution[prototype] * 10 * settings.startup["hivemind-tech-costs"].value),
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