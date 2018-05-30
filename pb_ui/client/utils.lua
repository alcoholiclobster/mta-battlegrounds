function defaultValue(t, key, default)
    local v = t[key]
    if v == nil then
        return default
    else
        return v
    end
end

function defaultValues(sourceTable, targetTable, defaults)
    for key, default in pairs(defaults) do
        if sourceTable[key] == nil then
            targetTable[key] = default
        else
            targetTable[key] = sourceTable[key]
        end
    end
end

function removeArrayValue(t, removeValue)
    for i, value in ipairs(t) do
        if value == removeValue then
            table.remove(t, i)
            return true
        end
    end
    return false
end

local screenWidth, screenHeight = guiGetScreenSize()

function getMousePosition()
    if isCursorShowing() then
        local mx, my = getCursorPosition()
        mx = mx * screenWidth
        my = my * screenHeight
    else
        return screenWidth / 2, screenHeight / 2
    end
end

function isPointInRect(x, y, rx, ry, rw, rh)
    return (x >= rx and y >= ry and x <= rx + rw and y <= ry + rh)
end
