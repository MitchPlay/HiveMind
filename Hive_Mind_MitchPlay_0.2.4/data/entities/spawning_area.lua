local shared = require("shared")
local util = require("data/tf_util/tf_util")

data:extend(
{
    {
        name = "hivemind-spawning-area",
        type = "simple-entity",
        collision_box = {{-20, -20}, {20, 20}},
        collision_mask = {"water-tile"},
        picture = {
            filename = "__core__/graphics/empty.png",
            size = 1,
            width = 1,
            height = 1
        }
    }
})