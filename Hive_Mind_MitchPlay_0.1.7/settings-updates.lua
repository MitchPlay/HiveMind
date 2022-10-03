
if mods["ArmouredBiters"] then
    data.raw["bool-setting"]["ab-enable-nest"].default_value = true
end
if mods["Cold_biters"] then
    data.raw["bool-setting"]["cb-disable-mother"].default_value = false
end
if mods["Explosive_biters"] then
    data.raw["bool-setting"]["eb-disable-mother"].default_value = false
end