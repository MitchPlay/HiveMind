local name = require("shared").pollution_proxy

local steam = data.raw.fluid.steam

data:extend
{
  {
    name = name,
    localised_name = {name},
    type = "tool",
    icon = steam.icon,
    icon_size = steam.icon_size,
    flags = {"hidden"},
    stack_size = 10,
    durability = 1
  }
}