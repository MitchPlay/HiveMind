--Fucking nerfing fish.
--I am losing because of them.
if data.raw.capsule["raw-fish"] then
    if data.raw.capsule["raw-fish"].capsule_action.attack_parameters.ammo_type.action then
        if data.raw.capsule["raw-fish"].capsule_action.attack_parameters.ammo_type.action.action_delivery.target_effects[1] then
            if data.raw.capsule["raw-fish"].capsule_action.attack_parameters.ammo_type.action.action_delivery.target_effects[1].damage.amount then
                data.raw.capsule["raw-fish"].capsule_action.attack_parameters.ammo_type.action.action_delivery.target_effects[1].damage.amount = settings.startup["hivemind-fish-heal-nerf"].value * -1
            end
        end
    end
end
