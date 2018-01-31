local skinId = 235
local layerNames = {
    "head",
    "body",
    "jacket",
    "legs",
    "feet",
    "gloves",
    "hat",
    "hair"
}

local bodyParts = {
    "body1",
    "body2",
    "wrist",
    "elbow",
    "forearm",
    "legsbody1",
    "legsbody2",
    "legsbody3",
}

local loadedClothes = {}
local loadedTextures = {}

local function unloadPedClothes(ped)
    if not ped or not loadedClothes[ped] then
        return
    end
    for i, element in ipairs(loadedClothes[ped]) do
        if isElement(element) then
            destroyElement(element)
        end
    end
    loadedClothes[ped] = nil
end

local function getTexture(path)
    if not fileExists(path) then
        return placeholderTexture
    end
    local texture = loadedTextures[path]
    if not texture then
        texture = dxCreateTexture(path, "dxt5", false)
        loadedTextures[path] = texture
    end
    return texture
end

local function createClothesShader(ped, material, texture)
    if not isElement(texture) then
        outputDebugString("Failed to load " .. material)
    end
    local elementType = "ped"
    if ped.type == "object" then
        elementType = "object"
    end
    local shader = dxCreateShader("assets/shaders/replace.fx", 0, 0, false, elementType)
    shader:setValue("gTexture", texture)
    engineApplyShaderToWorldTexture(shader, material, ped)
    return shader
end

function loadPedClothes(ped)
    if not isElement(ped) then
        return
    end
    unloadPedClothes(ped)
    loadedClothes[ped] = {}
    -- Наличие слоев одежды
    local hasJacket = ped:getData("clothes_jacket")
    hasJacket = not not ClothesTable[hasJacket]
    local hasShirt  = ped:getData("clothes_body")
    hasShirt = not not ClothesTable[hasShirt]
    local hasPants  = ped:getData("clothes_legs")
    hasPants = not not ClothesTable[hasPants]
    local hasShoes  = ped:getData("clothes_feet")
    hasShoes = not not ClothesTable[hasShoes]
    local hasHat  = ped:getData("clothes_hat")
    hasHat = not not ClothesTable[hasHat]
    local tmpHat = ped:getData("tmp_clothes_hat")
    if tmpHat and ClothesTable[tmpHat] then
        hasHat = true
    end
    -- Части тела, которые должны быть скрыты
    local hideParts = {}
    -- Части тела, для которых игнорируется скрытие
    local showParts = {}
    -- Цвет кожи, определяется головой
    local bodyTextureName = "whitebody"
    local head = ped:getData("clothes_head")
    if head and ClothesTable[head] and ClothesTable[head].body then
        bodyTextureName = ClothesTable[head].body
    end
    ped.doubleSided = false
    -- Текстура тела
    local bodyTexture = getTexture("assets/textures/skin/"..bodyTextureName..".png")

    for i, layer in ipairs(layerNames) do
        local tmpName = ped:getData("tmp_clothes_"..layer)
        if tmpName then
            name = tmpName
        else
            name = ped:getData("clothes_"..layer)
        end
        if name and ClothesTable[name] then
            local texture
            if ClothesTable[name].texture then
                texture = getTexture("assets/textures/" .. ClothesTable[name].texture)
            end
            -- Если указана модель, то необходимо создать и прикрепить аттач
            if ClothesTable[name].model and (layer ~= "hair" or (layer == "hair" and not hasHat)) then
                local model = exports.pb_models:getReplacedModel(ClothesTable[name].model)
                local object = createObject(model, ped.position)
                object:setCollisionsEnabled(false)
                object.dimension = ped.dimension
                object.interior = ped.interior
                local attach = ClothesTable[name].attach or Config.attachOffsets[layer]
                object.scale = attach.scale or 1
                -- Прикрепление объекта через bone_attach
                exports.bone_attach:attachElementToBone(object, ped, attach.bone,
                    attach.x, attach.y, attach.z,
                    attach.rx, attach.ry, attach.rz)
                table.insert(loadedClothes[ped], object)

                -- Если есть материал, то наложить текстуру
                if ClothesTable[name].material then
                    local shader = createClothesShader(object, ClothesTable[name].material, texture)
                    table.insert(loadedClothes[ped], shader)
                end

                setTimer(function ()
                    if isElement(object) then
                        object.doubleSided = true
                    end
                end, 50, 1)

            -- Если указан только материал, то наложить шейдер
            elseif ClothesTable[name].material then
                if layer == "body" then
                    for i = 1, 3 do
                        local useTexture = texture
                        if i == 1 then
                            useTexture = bodyTexture
                        end
                        if not (i == 2 and hasJacket) then
                            local shader = createClothesShader(ped, ClothesTable[name].material .. "p"..i, useTexture)
                            table.insert(loadedClothes[ped], shader)
                        end
                    end
                else
                    local shader = createClothesShader(ped, ClothesTable[name].material, texture)
                    table.insert(loadedClothes[ped], shader)
                end
            end

            if ClothesTable[name].hide then
                for name in pairs(ClothesTable[name].hide) do
                    hideParts[name] = true
                end
            end

            if ClothesTable[name].show then
                for name in pairs(ClothesTable[name].show) do
                    showParts[name] = true
                end
            end
        end
    end
    if hasShirt then
        hideParts.body2 = true
    end
    if hasShirt or hasJacket then
        hideParts.body1 = true
    end
    if hasPants then
        hideParts.legsbody1 = true
        hideParts.legsbody2 = true
    end
    if hasShoes then
        hideParts.legsbody3 = true
    end

    for name in pairs(showParts) do
        hideParts[name] = nil
    end

    for i, name in ipairs(bodyParts) do
        if not hideParts[name] then
            table.insert(loadedClothes[ped], createClothesShader(ped, name, bodyTexture))
        end
    end
end

addEventHandler("onClientElementDataChange", root, function (dataName)
    if source.type ~= "player" and source.type ~= "ped" then
        return
    end
    if source ~= localPlayer and not isElementStreamedIn(source) then
        return
    end
    if string.find(dataName, "clothes_") then
        loadPedClothes(source)
    end
end)

addEventHandler("onClientElementStreamIn", root, function ()
    loadPedClothes(source)
end)

addEventHandler("onClientElementStreamOut", root, function ()
    unloadPedClothes(source)
end)

addEventHandler("onClientElementDestroy", root, function ()
    unloadPedClothes(source)
end)

addEventHandler("onClientResourceStart", resourceRoot, function ()
    setElementDoubleSided(localPlayer, true)

    for i, player in ipairs(getElementsByType("player")) do
        loadPedClothes(player)
    end

    for i, ped in ipairs(getElementsByType("ped")) do
        loadPedClothes(ped)
    end
end)
