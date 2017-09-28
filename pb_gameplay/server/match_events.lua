addEvent("playerFindMatch", true)
addEventHandler("playerFindMatch", root, function ()
    findMatch({client})
end)

addEvent("teamFindMatch", true)
addEventHandler("teamFindMatch", root, function (players)
    findMatch(players)
end)

addEvent("clientLeaveMatch", true)
addEventHandler("clientLeaveMatch", resourceRoot, function ()
    removePlayerFromMatch(client, "leave")
end)

addEvent("planeJump", true)
addEventHandler("planeJump", resourceRoot, function ()
    handlePlayerPlaneJump(client)
end)

addEventHandler("onPlayerQuit", root, function ()
    removePlayerFromMatch(source, "disconnect")
end)

addEventHandler("onPlayerWasted", root, function (ammo, killer, weaponId)
    local player = source
    if not isElement(player) then
        return
    end
    local match = getPlayerMatch(player)
    if not match then
        return
    end
    if match.state == "waiting" then
        spawnWaitingPlayer(match, player)
        return
    end

    if isResourceRunning("pb_inventory") then
        exports.pb_inventory:spawnPlayerLootBox(player)
    end

    local killerPlayer
    if isElement(killer) then
        if killer.type == "player" then
            killerPlayer = killer
        elseif killer.type == "vehicle" then
            killerPlayer = killer.controller
        end
    end

    if isElement(killerPlayer) then
        local kills = killerPlayer:getData("kills") or 0
        killerPlayer:setData("kills", kills + 1)
    end

    local aliveCount = getMatchAlivePlayersCount(match)
    local rank = aliveCount + 1
    triggerClientEvent(player, "onMatchFinished", resourceRoot, rank, match.totalPlayers, match.totalTime)
    triggerMatchEvent(match, "onMatchPlayerWasted", player, aliveCount, killerPlayer, weaponId)
end)

addEvent("onMatchElementCreated", false)
addEventHandler("onMatchElementCreated", root, function (matchId)
    local match = getMatchById(matchId)
    if not isMatch(match) then
        destroyElement(source)
        return
    end
    table.insert(match.elements, source)
end)
