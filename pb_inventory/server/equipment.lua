local playerEquipments = {}
local equipmentSlots = {
    helmet = true,
    armor = true,
    backpack = true
}

function initPlayerEquipment(player)
    if not isElement(player) then
        return
    end

    playerEquipments[player] = {
        helmet   = nil,
        armor    = nil,
        backpack = nil,
    }

    for slot in pairs(equipmentSlots) do
        player:removeData("wear_"..tostring(slot))
    end
end

function getPlayerEquipment(player)
    if not player then
        return
    end
    return playerEquipments[player]
end

function getPlayerBackpackCapacity(player)
    if not isElement(player) or not playerEquipments[player] then
        return Config.defaultBackpackCapacity
    end
    local backpack = playerEquipments[player].backpack
    if not isItem(backpack) then
        return Config.defaultBackpackCapacity
    end
    return tonumber(Items[backpack.name].capacity)
end

function updatePlayerEquipment(player)
    if not isElement(player) then
        return
    end
    triggerClientEvent(player, "sendPlayerEquipment", resourceRoot, playerEquipments[player])


    if isResourceRunning("pb_models") then
        for slot in pairs(equipmentSlots) do
            local item = playerEquipments[player][slot]
            if item then
                player:setData("wear_"..tostring(slot), exports.pb_models:getItemModel(item.name))
            else
                player:removeData("wear_"..tostring(slot))
            end
        end
        triggerClientEvent("updateWearableItems", resourceRoot, player)
    end
end

function addPlayerEquipment(player, item)
    if not isElement(player) or not playerEquipments[player] or not isItem(item) then
        return
    end
    local itemClass = Items[item.name]
    local slot = itemClass.category
    if equipmentSlots[slot] then
        if slot == "backpack" and itemClass.capacity < getPlayerBackpackTotalWeight(player) then
            return
        end
        dropPlayerEquipment(player, itemClass.category)
        playerEquipments[player][slot] = item
        updatePlayerEquipment(player)
    end
end

function dropPlayerEquipment(player, slot)
    if not isElement(player) or not playerEquipments[player] or type(slot) ~= "string" then
        return
    end
    if playerEquipments[player][slot] then
        if slot == "backpack" and Config.defaultBackpackCapacity < getPlayerBackpackTotalWeight(player) then
            return
        end
        spawnPlayerLootItem(player, playerEquipments[player][slot])
        playerEquipments[player][slot] = nil
        updatePlayerEquipment(player)
    end
end

function removePlayerEquipment(player, slot)
    if not isElement(player) or not playerEquipments[player] or type(slot) ~= "string" then
        return
    end
    if playerEquipments[player][slot] then
        if slot == "backpack" and Config.defaultBackpackCapacity < getPlayerBackpackTotalWeight(player) then
            return
        end
        playerEquipments[player][slot] = nil
        updatePlayerEquipment(player)
    end
end

function clearPlayerEquipment(player)
    if not isElement(player) then
        return
    end
    initPlayerEquipment(player)
    updatePlayerEquipment(player)
end

function getPlayerEquipmentSlot(player, slot)
    if not isElement(player) or not playerEquipments[player] or type(slot) ~= "string" then
        return
    end
    return playerEquipments[player][slot]
end

addEvent("dropPlayerEquipment", true)
addEventHandler("dropPlayerEquipment", resourceRoot, function (slot)
    dropPlayerEquipment(client, slot)
end)

addEventHandler("onPlayerJoin", root, function ()
    initPlayerEquipment(source)
end)

addEventHandler("onPlayerQuit", root, function ()
    playerEquipments[source] = nil
end)

addEventHandler("onResourceStart", resourceRoot, function ()
    for i, player in ipairs(getElementsByType("player")) do
        initPlayerEquipment(player)
    end
end)

addEvent("requireClientEquipment", true)
addEventHandler("requireClientEquipment", resourceRoot, function ()
    triggerClientEvent(client, "sendPlayerEquipment", resourceRoot, playerEquipments[client])
end)

addEvent("updateEquipmentHealth", true)
addEventHandler("updateEquipmentHealth", resourceRoot, function (slot, health)
    local item = getPlayerEquipmentSlot(client, slot)
    if not isItem(item) then
        return
    end
    if health > item.health then
        return
    end
    item.health = health
    if item.health <= 0 then
        removePlayerEquipment(client, slot)
    end
    updatePlayerEquipment(player)
end)
