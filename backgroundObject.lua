local BackgroundObject = {}
BackgroundObject.__index = BackgroundObject

ActiveBackgroundObjects = {}

local Player
local Camera = require("camera")

local levelScale = 100

function BackgroundObject.new(imgName, level, x, y, width, height)
    local instance = setmetatable({}, BackgroundObject)

    if not Player then
        Player = require("player")
    end

    instance.img = love.graphics.newImage("assets/"..imgName..".png")
    instance.level = level -- what level dictates the movement in background
    instance.posX = x
    instance.posY = y
    instance.width = width
    instance.height = height

    instance.bgoRange = instance.level * levelScale
    instance.bgoX = 0

    table.insert(ActiveBackgroundObjects, instance)
end

function BackgroundObject:update(dt)
    self:syncAssociate()
end

function BackgroundObject.updateAll(dt)
    for _, instance in ipairs(ActiveBackgroundObjects) do
        instance:update(dt)
    end
end

-- move background object relative to where the player is on the map
function BackgroundObject:syncAssociate()
    self:syncCoordinate()
end

function BackgroundObject:syncCoordinate()
    self.bgoX = Camera.x / MapWidth * self.bgoRange
    self.x = self.posX - self.bgoRange / 2 + self.bgoX
end

function BackgroundObject.removeAll()
    ActiveBackgroundObjects = {}
end

function BackgroundObject:draw()
    love.graphics.draw(self.img, self.x, self.posY)
    --love.graphics.rectangle("fill", self.x, self.posY, self.width, self.height)
end

function BackgroundObject.drawAll()
    for _, instance in ipairs(ActiveBackgroundObjects) do
        instance:draw()
    end
end

return BackgroundObject
