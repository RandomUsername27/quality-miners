--Based on @Andrey135296 "Quality Effects" https://mods.factorio.com/mod/QualityEffects

local function stringStarts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

local machines = {}
for name, machine in pairs(prototypes.get_entity_filtered{{filter="type", type="mining-drill"}}) do
    if not stringStarts(name, "QualityMiners-") then
        machines[name] = true
    end
end

local function check_entity(entity_name)
    return machines[entity_name] ~= nil
end

--#region Courtesy of @tvededk
local function should_skip_entity(entity)
    return entity.quality.level == 0 or not check_entity(entity.name)
end

local function createNewEntityInfo(entity)
    return {
        name = "QualityMiners-" .. entity.quality.name .. "-" .. entity.name,
        position = entity.position,
        direction = entity.direction,
        quality = entity.quality,
        force = entity.force,
        fast_replace = true,
        player = entity.last_user,
    }
end

local function convertEntity(entity, info)
    local surface = entity.surface
    entity.destroy()
    return surface.create_entity(info)
end

local function copyModulesIfNeeded(previousModulesTable, resultingModulesInventory)
    -- If the new entity can't hold modules, or there's nothing to copy, skip.
    if not resultingModulesInventory or #previousModulesTable == 0 then return end

    -- .insert() respects inventory size afaik, check can be simplified. 
    for i = 1, #previousModulesTable do
        resultingModulesInventory.insert(previousModulesTable[i])
    end
end

local function isItemStackValid(itemStack)
    if itemStack == nil then
        return false
    end

    return itemStack.valid and itemStack.valid_for_read
end

local function copyModuleFrom(itemStack)
    if not isItemStackValid(itemStack) then
        return nil
    end
    return {name=itemStack.name, count=itemStack.count, quality=itemStack.quality}
end

local function copyModuleInvetoryDeep(entity)
    local modules = entity.get_module_inventory()
    if not modules then return {} end -- Burner miners might return nil.

    local result = {}
    for i = 1, #modules do
        local copy = copyModuleFrom(modules[i])
        if copy ~= nil then
            table.insert(result, copy)
        end
    end
    return result
end
--#endregion

local on_built = function (data)
    local entity = data.entity
    if should_skip_entity(entity) then return end

    local previousModules = copyModuleInvetoryDeep(entity)

    local info = createNewEntityInfo(entity)

    local newEntity = convertEntity(entity, info)

    copyModulesIfNeeded(previousModules, newEntity.get_module_inventory())

end

script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
--script.on_event(defines.events.on_space_platform_built_entity, on_built, {{filter = "type", type = "mining-drill"}})