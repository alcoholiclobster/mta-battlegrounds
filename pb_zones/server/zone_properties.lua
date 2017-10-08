local zoneProperties = {
    { time = 15,  shrink = 15 },
    { time = 30,  shrink = 20 },
    { time = 30,  shrink = 30 },
    { time = 40,  shrink = 40 },
    { time = 60,  shrink = 50 },
    { time = 100, shrink = 50 },
    { time = 120, shrink = 70 },
    { time = 240, shrink = 200},
}

function getZone(index)
    if index >= 1 and index <= ZONES_COUNT then
        return zoneProperties[index]
    else
        return {time = 999, shrink = 999}
    end
end
