--Completely based on @Andrey135296 "Quality Effects" https://mods.factorio.com/mod/QualityEffects

local function stringStarts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

local machines = {}
for name, machine in pairs(prototypes.get_entity_filtered{{filter="type", type="mining-drill"}}) do
    if machine.module_inventory_size > 0 and not stringStarts(name, "QualityMiners-") then
        machines[name] = true
    end
end

local function check_entity(entity_name)
    if machines[entity_name] ~= nil then return true end
    return false
end

for _, surface in pairs(game.surfaces) do
	for index, entity in pairs(surface.find_entities_filtered({type="mining-drill"})) do
		if entity.quality.level ~= 0 and check_entity(entity.name) then 
			--game.print(index .. entity.name)
    			local info = {
        			name = "QualityMiners-" .. entity.quality.name .. "-" .. entity.name,
        			position = entity.position,
        			direction = entity.direction,
        			quality = entity.quality,
        			force = entity.force,
        			fast_replace = true,
        			player = entity.last_user,
    			}
			    --local recipe, qual = entity.get_recipe()
                local modules = entity.get_module_inventory().get_contents()
    			entity.destroy()
    			local new_entity = surface.create_entity(info)	
			    --new_entity.set_recipe(recipe, qual)
                for _, module in pairs(modules) do
                    new_entity.get_module_inventory().insert({name=module.name, count=module.count, quality=module.quality})
                end
		end
	end
end