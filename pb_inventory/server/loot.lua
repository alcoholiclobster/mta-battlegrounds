local lootColors = {
    white  = 1575,
    orange = 1576,
    yellow = 1577,
    green  = 1578,
    blue   = 1579,
    red    = 1580,
}

function spawnLootItem(item, position, dimension)
    if not isItem(item) or not position then
        return
    end
    local color = "white"
    if isItemWeapon(item) then
        color = "red"
    elseif Items[item.name].category == "medicine" then
        color = "green"
    elseif Items[item.name].category == "ammo" then
        color = "blue"
    elseif Items[item.name].category == "backpack" then
        color = "orange"
    end
    local object = createObject(lootColors[color], position)
    object.rotation = Vector3(0, 0, math.random(360))
    object:setCollisionsEnabled(false)

    item.lootElement = object
    if dimension then
        object.dimension = dimension
    end
    object:setData("loot_item", item)

    return object
end

function spawnPlayerLootItem(player, item)
    if not isElement(player) or not item then
        return
    end
    local offsetX = math.random() * 0.4 - 0.2
    local offsetY = math.random() * 0.4 - 0.2
    local position = player.position - Vector3(offsetX, offsetY, 1)
    local color = "white"
    return spawnLootItem(item, position, player.dimension)
end

function spawnPlayerLootBox(player)
    if not isElement(player) then
        return
    end
    -- Взять все вещи из рюкзака
    local backpack = getPlayerBackpack(player)
    if backpack then
        for name, item in pairs(backpack) do
            local object = spawnPlayerLootItem(player, item)
            triggerEvent("onMatchElementCreated", object, player.dimension)
        end
    end
    -- Взять все снаряжение
    local equipment = getPlayerEquipment(player)
    if equipment then
        for name, item in pairs(equipment) do
            local object = spawnPlayerLootItem(player, item)
            triggerEvent("onMatchElementCreated", object, player.dimension)
        end
    end
    -- Взять все оружие
    local weapons = getPlayerWeapons(player)
    if weapons then
        for name, item in pairs(weapons) do
            local object = spawnPlayerLootItem(player, item)
            triggerEvent("onMatchElementCreated", object, player.dimension)
        end
    end
    takeAllItems(player)
end

addEvent("pickupLootItem", true)
addEventHandler("pickupLootItem", resourceRoot, function (element, weaponSlot, itemName)
    if not isElement(element) then
        return
    end
    if client.vehicle then
        return
    end
    if getDistanceBetweenPoints3D(client.position, element.position) > Config.minLootDistance + 2 then
        return
    end
    local item = element:getData("loot_item")

    if not isItem(item) then
        destroyElement(element)
    end
    item.lootElement = nil

    if isItemWeapon(item) then
        local primarySlot
        if weaponSlot == "primary1" then
            primarySlot = 1
        elseif weaponSlot == "primary2" then
            primarySlot = 2
        end
        addPlayerWeapon(client, item, primarySlot)
        destroyElement(element)
        animatePlayerPickup(client)
    elseif isItemEquipment(item) then
        addPlayerEquipment(client, item)
        destroyElement(element)
        animatePlayerPickup(client)
    else
        local backpackWeight = getPlayerBackpackTotalWeight(player)
        local itemWeight = getItemWeight(item)
        local backpackCapacity = getPlayerBackpackCapacity(player)
        if backpackWeight + itemWeight > backpackCapacity then
            local weight = Items[item.name].weight or 0
            local slotsAvailable = math.ceil((backpackCapacity - backpackWeight) / weight)
            local item2 = cloneItem(item)
            item2.count = slotsAvailable
            item.count = item.count - slotsAvailable
            if item.count > 0 then
                item.lootElement = element
                element:setData("loot_item", item)
            else
                destroyElement(element)
            end
            addBackpackItem(client, item2)
            animatePlayerPickup(client)
        else
            addBackpackItem(client, item)
            destroyElement(element)
            animatePlayerPickup(client)
        end
    end

end)

function animatePlayerPickup(player)
    if not isElement(player) then
        return
    end
    if player:getData("pickup_animation") then
        return
    end
    player:setData("pickup_animation", true)

    player:setAnimation("BOMBER", "BOM_Plant")
    setTimer(function ()
        if isElement(player) then
            player:setAnimation("BOMBER", "BOM_Plant_2Idle", -1, false, false, true, true)
        end
    end, 500, 1)

    setTimer(function ()
        if isElement(player) then
            player:setAnimation()
            player:removeData("pickup_animation")
        end
    end, 1500, 1)
end
