--Completely based on @Andrey135296 "Quality Effects" https://mods.factorio.com/mod/QualityEffects

local qualities = table.deepcopy(data.raw["quality"])

local new_machines = {}

for mname, machine_orig in pairs(data.raw["mining-drill"]) do
    for qname, qvalue in pairs(qualities) do
        if machine_orig.mining_speed ~= nil and qvalue.level > 0 then
            local machine = table.deepcopy(machine_orig)
            machine.placeable_by = {item=machine.name, count=1, quality=qvalue}
            machine.localised_name = {"entity-name." .. mname}
            machine.localised_description = {"entity-description." .. mname}
            machine.hidden = true
            machine.name = "QualityMiners-" .. qname .. "-" .. machine.name
            
            machine.mining_speed = machine.mining_speed + (machine.mining_speed * qvalue.level * settings.startup["mining-speed-bonus-per-quality-level"].value)
            
            if settings.startup["drop-stacks-on-belt"].value then
                --Only matters if not using space age
                --Credit: @RockPaperKatana "Stackable Mining Drills" https://mods.factorio.com/mod/Stackable_Mining_Drills
                if not data.raw.tile["empty-space"] then
                    local empty_space = table.deepcopy(data.raw.tile["out-of-map"])
                    empty_space.name = "empty-space"
                    data:extend{empty_space}
                end

                machine.drops_full_belt_stacks = true
            end

            table.insert(new_machines, machine)
        end
    end
end

data.extend(new_machines)