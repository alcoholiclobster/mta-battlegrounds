local screenSize = Vector2(guiGetScreenSize())
local isVisible = true

DEBUG_DRAW = false

local isHealthbarVisible = true
local healthbarWidth = 400
local healthbarHeight = 28
local healthbarBorder = 1

local markerTexture
local markerColors = {
    { 253, 218, 14  },
    { 46,  198, 2   },
    { 0,   170, 240 },
    { 237, 5,   3   },
}

local counters = {
    alive = 0,
    kills = 0,
}

function localize(name)
    local res = getResourceFromName("pb_lang")
    if (res) and (getResourceState(res) == "running") then
        return exports.pb_lang:localize(name)
    else
        return name
    end
end

function isResourceRunning(resName)
    local res = getResourceFromName(resName)
    return (res) and (getResourceState(res) == "running")
end

local function dxDrawBorderRect(x, y, width, height, color, borderWidth)
    dxDrawLine(x, y, x + width, y, color, borderWidth)
    dxDrawLine(x + width, y, x + width, y + height, color, borderWidth)
    dxDrawLine(x + width, y + height, x, y + height, color, borderWidth)
    dxDrawLine(x, y + height, x, y, color, borderWidth)
end

local function drawHealthbar(health, x, y, width, height)
    if not health then
        return
    end
    dxDrawRectangle(x - 1, y - 1, width + 2, height + 2, tocolor(0, 0, 0, 150))

    local hpMul = health / 100
    local color = tocolor(255, 255, 255)
    local borderColor = tocolor(255, 255, 255, 150)
    if health < 75 then
        color = tocolor(255, 150, 150)
    elseif health > 99.5 then
        color = tocolor(255, 255, 255, 100)
        borderColor = tocolor(255, 255, 255, 120)
    end
    dxDrawBorderRect(x - 1, y - 1, width + 1, height + 1, borderColor, 1)
    dxDrawRectangle(x, y, width * hpMul, height, color)
end

local function drawPlayerHealthbar()
    local x = screenSize.x / 2 - healthbarWidth / 2
    local y = screenSize.y - 35 - healthbarHeight

    drawHealthbar(localPlayer.health, x, y, healthbarWidth, healthbarHeight)
    local healthbarText = string.gsub(localPlayer.name, '#%x%x%x%x%x%x', '') .. " - " .. tostring(getVersion().sortable)
    dxDrawText(healthbarText, x + 1, screenSize.y - 34, x + healthbarWidth + 1, screenSize.y + 1, tocolor(0, 0, 0, 150), 1, "default", "center", "center")
    dxDrawText(healthbarText, x, screenSize.y - 35, x + healthbarWidth, screenSize.y, tocolor(255, 255, 255, 150), 1, "default", "center", "center")

    if DEBUG_DRAW then
        dxDrawText("[health="..tostring(localPlayer.health).."]", x, y - 20, x + healthbarWidth, y,tocolor(0,255,0),1,"default","center","center")
    end
end

local function drawBoost()
    local boost = localPlayer:getData("boost")
    if not boost or boost <= 0 then
        return
    end
    local x = screenSize.x / 2 - healthbarWidth / 2
    local y = screenSize.y - 35 - healthbarHeight - 15
    local count = math.floor(boost/10)
    local w = healthbarWidth * 0.2 - 5
    dxDrawRectangle(x, y, w, 5, tocolor(255, 255, 255, 100))

    if boost > 0 then
        local mul = math.min(1, boost / 20)
        dxDrawRectangle(x, y, w * mul, 5, tocolor(255, 150, 0))
    end
    x = x + w + 5

    local w = healthbarWidth * 0.4 - 5
    dxDrawRectangle(x, y, w, 5, tocolor(255, 255, 255, 150))
    if boost > 20 then
        local mul = math.min(1, (boost - 20) / 40)
        dxDrawRectangle(x, y, w * mul, 5, tocolor(255, 150, 0))
    end
    x = x + w + 5
    local w = healthbarWidth * 0.3 - 5
    dxDrawRectangle(x, y, w, 5, tocolor(255, 255, 255, 200))
    if boost > 60 then
        local mul = math.min(1, (boost - 60) / 30)
        dxDrawRectangle(x, y, w * mul, 5, tocolor(255, 150, 0))
    end
    x = x + w + 5
    local w = healthbarWidth * 0.1
    dxDrawRectangle(x, y, w, 5, tocolor(255, 255, 255, 255))
    if boost > 90 then
        local mul = math.min(1, (boost - 90) / 10)
        dxDrawRectangle(x, y, w * mul, 5, tocolor(255, 150, 0))
    end
    -- if boost > 0 then
    --     localPlayer.health = localPlayer.health + 1
    -- elseif boost > 20 and boost <= 60 then
    --     localPlayer.health = localPlayer.health + 2
    -- elseif boost > 60 and boost <= 90 then
    --     localPlayer.health = localPlayer.health + 3
    -- elseif boost > 90 then
    --     localPlayer.health = localPlayer.health + 4
    -- end
end

local function drawCounter(x, y, count, label)
    local countWidth = dxGetTextWidth(count, 2.8, "default-bold")
    local labelWidth = dxGetTextWidth(label, 2.5, "default")
    x = x - countWidth - labelWidth
    dxDrawRectangle(x, y, countWidth + 10, 42, tocolor(0, 0, 0, 150))
    dxDrawText(count, x + 6, y + 1, x + 5, y, tocolor(0, 0, 0), 2.8, "default-bold")
    dxDrawText(count, x + 5, y, x + 5, y, tocolor(255, 255, 255), 2.8, "default-bold")
    x = x + countWidth + 10
    dxDrawRectangle(x, y, labelWidth + 10, 42, tocolor(255, 255, 255, 150))
    dxDrawText(label, x + 5, y + 1, x + 5, y, tocolor(0, 0, 0, 150), 2.5, "default")
    return countWidth + labelWidth
end

addEventHandler("onClientRender", root, function ()
    if not isVisible then
        return
    end
    drawPlayerHealthbar()
    drawBoost()

    local y = 30
    local x = screenSize.x - 36
    local aliveText
    if localPlayer:getData("match_waiting") then
        aliveText = localize("hud_join_counter")
    else
        aliveText = localize("hud_alive_counter")
    end
    x = x - drawCounter(x, y, counters.alive, aliveText) - 45
    if (isResourceRunning("pb_map") and exports.pb_map:isVisible()) or
       (isResourceRunning("pb_inventory") and exports.pb_inventory:isVisible())
    then
        drawCounter(x, y, localPlayer:getData("kills") or 0, localize("hud_kills_counter"))
    end

    if isResourceRunning("pb_gameplay") and (isResourceRunning("pb_inventory") and not exports.pb_inventory:isVisible()) then
        local squadPlayers = exports.pb_gameplay:getSquadPlayers()
        if #squadPlayers > 1 then
            local y = 20
            local x = 20
            for i, player in ipairs(squadPlayers) do
                local playerName = ""
                local playerHealth = 0
                local icon
                if isElement(player) and player:getData("matchId") == localPlayer:getData("matchId") then
                    playerName = player.name or ""
                    playerHealth = player.health
                    if player.vehicle or player:getData("isInPlane") then
                        icon = "driving"
                    end
                    if player:getData("parachuting") then
                        icon = "parachute"
                    end
                end
                local textWidth = dxGetTextWidth(playerName, 1, "default")
                dxDrawText(playerName, x+1, y+1, x, y, tocolor(0, 0, 0), 1, "default")
                dxDrawText(playerName, x, y, x, y, tocolor(49, 177, 178), 1, "default")
                if isElement(player) and player:getData("map_marker") then
                    dxDrawImage(x + textWidth + 5, y, 13, 15, markerTexture, 0, 0, 0, tocolor(markerColors[i][1], markerColors[i][2], markerColors[i][3]))
                end
                y = y + 20
                local ix = x
                local isize = 20
                local iy = y + 5 - isize / 2
                if playerHealth > 0 then
                    drawHealthbar(playerHealth, x, y, 150, 10)
                    ix = ix + 155
                else
                    icon = "dead"
                end
                if icon then
                    dxDrawImage(ix, iy, isize, isize, "assets/"..icon..".png")
                end
                y = y + 20
            end
        end
    end
end, false, "low-1")

addEventHandler("onClientResourceStart", resourceRoot, function ()
    showPlayerHudComponent("all", false)
    showPlayerHudComponent("crosshair", true)

    markerTexture = dxCreateTexture(":pb_map/assets/marker.png", "argb", true, "clamp")
end)

function setVisible(visible)
    isVisible = not not visible
end

function setCounter(name, count)
    if not name then
        return
    end
    if not tonumber(count) then
        counters[name] = 0
    else
        counters[name] = count
    end
end
