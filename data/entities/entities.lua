local require = function(name) return require("data/entities/"..name) end

require("biter_player")
--require("deploy_machine/deploy_machine")
require("pollution_proxy")
require("creep_landmine")
require("spawning_area")

local entity_catagory =
{
  type = "recipe-category",
  name = "hivemind-entities-category"
}

data:extend{entity_catagory}

local make_recipe = function(name)
    local recipe = 
    {
      type = "recipe",
      name = name,
      localised_name = {name},
      enabled = false,
      ingredients = {},
      energy_required = math.huge,
      result = name,
      category = entity_catagory.name
    }
    data:extend{recipe}
end


for name, _ in pairs(names.required_pollution) do
  if not name:find("worm%-turret") then
      if not(name == "biter-deployer") and not(name == "spitter-deployer") then
          local file = name:gsub("-","_")
          require(file)
      end
      make_recipe(name)
  end
end