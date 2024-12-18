local ForegroundObject = {}
ForegroundObject.__index = ForegroundObject

ActiveForegroundObjects = {}

local Player
local Camera = require("camera")

local levelScale = 100

function ForegroundObject.new(type, anim, level, x, y, width, height)
    local instance = setmetatable({}, ForegroundObject)

    if not Player then
        Player = require("player")
    end

    instance.anim = anim
    instance.type = type
    if anim then
        instance.state = "idle"
        instance.animation = {}
        instance.animation.clock = ForegroundObject.animAssets[type].clock
        instance.animation.draw = ForegroundObject.animAssets[type][instance.state].img[1]
    else
        instance.img = love.graphics.newImage("assets/"..type..".png")
    end
    instance.level = level -- what level dictates the movement in background
    instance.posX = x
    instance.posY = y
    instance.width = width
    instance.height = height

    instance.fgoRange = instance.level * levelScale
    instance.fgoX = 0

    table.insert(ActiveForegroundObjects, instance)
end

function ForegroundObject.loadAssets()
    ForegroundObject.animAssets = {}

    -- sleeping dragon
    ForegroundObject.animAssets.sleepingDragon = {}
    ForegroundObject.animAssets.sleepingDragon.clock = { timer = 0, rate = 0.4 }
    ForegroundObject.animAssets.sleepingDragon.idle = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, 4 do
        ForegroundObject.animAssets.sleepingDragon.idle.img[i] = love.graphics.newImage("assets/dragon/sleeping/" .. i .. ".png")
    end
end

function ForegroundObject:update(dt)
    self:syncCoordinate()
    self:animate(dt)
end

function ForegroundObject.updateAll(dt)
    for _, instance in ipairs(ActiveForegroundObjects) do
        instance:update(dt)
    end
end

function ForegroundObject:animate(dt)
    if self.anim then
        self.animation.clock.timer = self.animation.clock.timer + dt
        if self.animation.clock.timer > self.animation.clock.rate then
            self.animation.clock.timer = 0
            self:setNewFrame()
        end
    end
end

function ForegroundObject:setNewFrame()
    local anim = ForegroundObject.animAssets[self.type][self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

-- move background object relative to where the camera is on the map
function ForegroundObject:syncCoordinate()
    self.fgoX = Camera.x / MapWidth * self.fgoRange
    self.x = self.posX - self.fgoRange / 2 + self.fgoX
end

function ForegroundObject.removeAll()
    ActiveForegroundObjects = {}
end

function ForegroundObject:draw()
    if self.anim then
        love.graphics.draw(self.animation.draw, self.x, self.posY)
    else
        love.graphics.draw(self.img, self.x, self.posY)
    end
    --love.graphics.rectangle("fill", self.x, self.posY, self.width, self.height)
end

function ForegroundObject.drawAll()
    for _, instance in ipairs(ActiveForegroundObjects) do
        instance:draw()
    end
end

return ForegroundObject
