
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