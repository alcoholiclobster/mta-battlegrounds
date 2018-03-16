-- Взять оружие в руки
function equipPlayerWeapon(player, name)
    if not isElement(player) then
        return
    end
    if not WeaponsTable[name] then
        return
    end

    unequipPlayerWeapon(player)

    local weaponId = WeaponsTable[name].baseWeapon
    giveWeapon(player, weaponId, 999, true)
    setWeaponAmmo(player, weaponId, 999, 999)
    if Config.skillFromWeapon[weaponId] then
        local weaponStat = (WeaponsTable[name].propsGroup or 1) * 500 - 500
        setPedStat(player, Config.skillFromWeapon[weaponId], weaponStat)
    end
end

-- Убрать оружие из рук
function unequipPlayerWeapon(player)
    if not isElement(player) then
        return
    end

    takeAllWeapons(player)
end

addEvent("onPlayerUnequipWeapon", true)
addEventHandler("onPlayerUnequipWeapon", resourceRoot, function ()
    unequipPlayerWeapon(client)
end)

addEventHandler("onPlayerWeaponFire", root, function (weaponId)
    setWeaponAmmo(source, weaponId, 999, 999)
end)

addCommandHandler("weapon", function (player, cmd, name)
    equipPlayerWeapon(player, name)
end)

addEvent("onPlayerRequestReload", true)
addEventHandler("onPlayerRequestReload", resourceRoot, function ()
    reloadPedWeapon(client)
end)

addEvent("onPlayerReloadWeapon", true)
addEventHandler("onPlayerReloadWeapon", resourceRoot, function (clip)
    setWeaponAmmo(client, client:getWeapon(), 999, 999)
    triggerClientEvent("onClientReloadWeapon", resourceRoot, 30)
end)
