
data:extend({
    {
        type = "int-setting",
        name = "hivemind-max-popcap",
        localised_name = {"settings.hivemind-max-popcap"},
        localised_description = {"settings.hivemind-max-popcap-description"},
        setting_type = "startup",
        minimum_value = 0,
        default_value = 0
    },
    {
        type = "double-setting",
        name = "hivemind-tech-costs",
        localised_name = {"settings.hivemind-tech-costs"},
        localised_description = {"settings.hivemind-tech-costs-description"},
        setting_type = "startup",
        minimum_value = 0.001,
        default_value = 1
    },
    {
        type = "double-setting",
        name = "hivemind-tech-biter-costs",
        localised_name = {"settings.hivemind-tech-biter-costs"},
        localised_description = {"settings.hivemind-tech-biter-costs-description"},
        setting_type = "startup",
        minimum_value = 0.001,
        default_value = 1
    },
    {
        type = "double-setting",
        name = "hivemind-tech-worm-costs",
        localised_name = {"settings.hivemind-tech-worm-costs"},
        localised_description = {"settings.hivemind-tech-worm-costs-description"},
        setting_type = "startup",
        minimum_value = 0.001,
        default_value = 1
    },
    {
        type = "int-setting",
        name = "hivemind-fish-heal-nerf",
        localised_name = {"settings.hivemind-fish-heal-nerf"},
        localised_description = {"settings.hivemind-fish-heal-nerf-description"},
        setting_type = "startup",
        minimum_value = 0,
        default_value = 35
    },
    {
        type = "double-setting",
        name = "hivemind-unit-size-devider",
        localised_name = {"settings.hivemind-unit-size-devider"},
        localised_description = {"settings.hivemind-unit-size-devider-description"},
        setting_type = "startup",
        minimum_value = 0.1,
        default_value = 6
    },
    {
        type = "int-setting",
        name = "hivemind-starting-popcap",
        localised_name = {"settings.hivemind-starting-popcap"},
        localised_description = {"settings.hivemind-starting-popcap-description"},
        setting_type = "runtime-global",
        minimum_value = 0,
        default_value = 10
    },
    {
        type = "int-setting",
        name = "hivemind-increase-per-level",
        localised_name = {"settings.hivemind-increase-per-level"},
        localised_description = {"settings.hivemind-increase-per-level-description"},
        setting_type = "runtime-global",
        minimum_value = 0,
        default_value = 10
    },
    {
        type = "int-setting",
        name = "hivemind-spawning-distance",
        localised_name = {"settings.hivemind-spawning-distance"},
        localised_description = {"settings.hivemind-spawning-distance-description"},
        setting_type = "runtime-global",
        minimum_value = 0,
        default_value = 500
    },
    {
        type = "int-setting",
        name = "hivemind-switch-timer",
        localised_name = {"settings.hivemind-switch-timer"},
        localised_description = {"settings.hivemind-switch-timer-description"},
        setting_type = "runtime-global",
        minimum_value = 0,
        default_value = 7200
    },
    {
        type = "bool-setting",
        name = "hivemind-hostile-to-hivemind",
        localised_name = {"settings.hivemind-hostile-to-hivemind"},
        localised_description = {"settings.hivemind-hostile-to-hivemind-description"},
        setting_type = "runtime-global",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "hivemind-hostile-to-enemies",
        localised_name = {"settings.hivemind-hostile-to-enemies"},
        localised_description = {"settings.hivemind-hostile-to-enemies-description"},
        setting_type = "runtime-global",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "hivemind-is-one-team",
        localised_name = {"settings.hivemind-is-one-team"},
        localised_description = {"settings.hivemind-is-one-team-description"},
        setting_type = "runtime-global",
        default_value = false
    },
    {
        type = "int-setting",
        name = "hivemind-max-hive-players",
        localised_name = {"settings.hivemind-max-hive-players"},
        localised_description = {"settings.hivemind-max-hive-players-description"},
        setting_type = "runtime-global",
        minimum_value = 0,
        default_value = 0
    },
    --[[{
        type = "string-setting",
        name = "hivemind-selection-tool",
        localised_name = {"settings.hivemind-selection-tool"},
        localised_description = {"settings.hivemind-selection-tool-description"},
        setting_type = "runtime-per-user",
        default_value = "with-deployers",
        allowed_values = {"with-deployers","only-units"},
        auto_trim = true
    },]]

})