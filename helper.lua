local Helper = {}

-- helper function
function Helper.isInTable(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then return true end
    end
    return false
end

--Check Fixture User Data
-- checks if one of the given fixtures is the given userDataType
--@param a: table (fixture)
--@param b: table (fixture)
--@param userDataType: string
--@return fixture
function Helper.checkFUD(a, b, userDataType)
    if (a:getUserData() == userDataType) then
        return a
    elseif (b:getUserData() == userDataType) then
        return b
    end
    return nil
end

--Check Collisioin Direction
--@param collision: table
--@param dir: string
function Helper.checkCollDir(collision, dir)
    local nx, ny = collision:getNormal()
    if dir == "above" then
        return ny < 0
    elseif dir == "below" then
        return ny > 0
    elseif dir == "right" then
        return nx > 0
    elseif dir == "left" then
        return nx < 0
    end
    return false
end

return Helper