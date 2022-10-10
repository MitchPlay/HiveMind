names = require("shared")

local util = require("__Hive_Mind_MitchPlay__/data/tf_util/tf_util")

deployer_spawn_list = {}
deployer_recipe_catagories = {}

log(serpent.line(data.raw["unit-spawner"]))
for index, name in pairs(util.get_spawner_order()) do
  for unit_name, unit in pairs(data.raw["unit-spawner"][name].result_units) do
    if not deployer_recipe_catagories[unit[1]] then
      deployer_recipe_catagories[unit[1]] = util.deployer_name(name)
    end
  end
end
  
for unit, deployer in pairs(deployer_recipe_catagories) do
  if deployer_spawn_list[deployer] then
    table.insert(deployer_spawn_list[deployer], unit)
  else
    deployer_spawn_list[deployer] = {unit}
  end
end

require("data_updates/deploy_machine")
require("data_updates/adjust_biters")
require("data_updates/balance_flamethrower")
--require("data_updates/attack_proxies")
