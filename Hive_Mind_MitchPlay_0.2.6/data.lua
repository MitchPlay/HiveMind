names = require("shared")

require("data/entities/entities")
require("data/technologies/technologies")
require("data/tiles/creep")
require("data/nerfs/nerfs")

if se_prodecural_tech_exclusions then 
    table.insert(se_prodecural_tech_exclusions, "hivemind-")
    table.insert(se_prodecural_tech_exclusions, "biter-melee-damage")
    table.insert(se_prodecural_tech_exclusions, "spitter-biological-damage")
    table.insert(se_prodecural_tech_exclusions, "worm-biological-damage")
    table.insert(se_prodecural_tech_exclusions, "popcap")
end