--Shared data interface between data and script, notably prototype names.

local data = {}

data.deployers =
{
  biter_deployer = "biter-deployer",
  spitter_deployer = "spitter-deployer"
}

data.players =
{
  small_biter_player = "small-biter-player",
  medium_biter_player = "medium-biter-player",
  big_biter_player = "big-biter-player",
  behemoth_biter_player = "behemoth-biter-player",
}

data.pollution_proxy = "pollution-proxy"

data.firestarter_gun = "firestarter-gun"
data.firestarter_ammo = "firestarter-ammo"

data.creep = "creep"
data.creep_tumor = "creep-tumor"
data.armored_creep_tumor = "armored-creep-tumor"
data.creep_radius = 10
data.creep_sticker = "creep-sticker"
data.creep_landmine = "creep-landmine"
data.creep_wall = "creep-wall"
data.creep_chest = "creep-chest"
data.creep_spreader = "creep-spreader"
data.pollution_lab = "pollution-lab"
data.pollution_burner_mining_drill = "pollution-burner-mining-drill"
data.pollution_mining_drill = "pollution-mining-drill"
data.advanced_pollution_mining_drill = "advanced-pollution-mining-drill"
data.pollution_oil_drill = "pollution-oil-drill"
data.advanced_pollution_oil_drill = "advanced-pollution-oil-drill"
data.sticker_proxy = "sticker-proxy"

data.required_pollution =
{
  [data.deployers.biter_deployer] = 100,
  [data.deployers.spitter_deployer] = 200,
  [data.creep_tumor] = 50,
  [data.armored_creep_tumor] = 415,
  [data.creep_spreader] = 75,
  [data.creep_wall] = 115,
  [data.creep_chest] = 50,
  [data.pollution_lab] = 250,
  [data.pollution_burner_mining_drill] = 200,
  [data.pollution_mining_drill] = 415,
  [data.advanced_pollution_mining_drill] = 1425,
  [data.pollution_oil_drill] = 1150,
  [data.advanced_pollution_oil_drill] = 3150,
  ["small-worm-turret"] = 200,
  ["medium-worm-turret"] = 400,
  ["big-worm-turret"] = 800,
  ["behemoth-worm-turret"] = 1600
}

-- Pollution Burner Miner Drill - 175 cost - 6 pollution 
-- Pollution Mining Drill - 350 cost - 12 pollution 
-- Advanced Pollution Mining Drill - 1120 cost - 36 pollution 
-- Pollution oil drill -875 cost - 45 pollution
-- Advanced Pollution oil drill - 2625 cost - 225 pollution

data.needs_proxy_type =
{
  ["assembling-machine"] = true,
  ["lab"] = true,
  ["mining-drill"] = true
}

data.default_unlocked =
{
  ["small-biter"] = true,
  ["small-spitter"] = true,
  ["small-worm-turret"] = true
}

data.needs_creep =
{
  ["small-worm-turret"] =true,
  ["medium-worm-turret"] = true,
  ["big-worm-turret"] = true,
  ["behemoth-worm-turret"] = true,
  [data.creep_tumor] = true,
  [data.creep_wall] = true,
  [data.armored_creep_tumor] = true,
  [data.pollution_mining_drill] = true,
  [data.advanced_pollution_mining_drill] = true,
  [data.pollution_burner_mining_drill] = true,
  [data.pollution_oil_drill] = true,
  [data.advanced_pollution_oil_drill] = true,
  [data.pollution_lab] = true
}

data.pollution_cost_multiplier = 1
data.deployer_speed_modifier = 0.25

return data
