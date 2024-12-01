local BackgroundObject = {}
BackgroundObject.__index = BackgroundObject

ActiveBackgroundObjects = {}

local Player
local Camera = require("camera")

local levelScale = 100

function BackgroundObject.new(type, anim, level, x, y, width, height)
    local instance = setmetatable({}, BackgroundObject)

    if not Player then
        Player = require("player")
    end

    instance.anim = anim
    instance.type = type
    if anim then
        instance.state = "idle"
        instance.animation = { timer = 0, rate = 0.2 }
        instance.animation.draw = BackgroundObject.animAssets[type][instance.state].img[1]
    else
        instance.img = love.graphics.newImage("assets/"..type..".png")
    end
    instance.level = level -- what level dictates the movement in background
    instance.posX = x
    instance.posY = y
    instance.width = width
    instance.height = height

    instance.bgoRange = instance.level * levelScale
    instance.bgoX = 0

    table.insert(ActiveBackgroundObjects, instance)
end

function BackgroundObject.loadAssets()
    BackgroundObject.animAssets = {}

    -- sleeping dragon
    BackgroundObject.animAssets.sleepingDragon = {}
    BackgroundObject.animAssets.sleepingDragon.idle = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, 4 do
        BackgroundObject.animAssets.sleepingDragon.idle.img[i] = love.graphics.newImage("assets/dragon/sleeping/" .. i .. ".png")
    end
end

function BackgroundObject:update(dt)
    self:syncCoordinate()
    self:animate(dt)
end

function BackgroundObject.updateAll(dt)
    for _, instance in ipairs(ActiveBackgroundObjects) do
        instance:update(dt)
    end
end

function BackgroundObject:animate(dt)
    if self.anim then
        self.animation.timer = self.animation.timer + dt
        if self.animation.timer > self.animation.rate then
            self.animation.timer = 0
            self:setNewFrame()
        end
    end
end

function BackgroundObject:setNewFrame()
    local anim = BackgroundObject.animAssets[self.type][self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

-- move background object relative to where the camera is on the map
function BackgroundObject:syncCoordinate()
    self.bgoX = Camera.x / MapWidth * self.bgoRange
    self.x = self.posX - self.bgoRange / 2 + self.bgoX
end

function BackgroundObject.removeAll()
    ActiveBackgroundObjects = {}
end

function BackgroundObject:draw()
    if self.anim then
        love.graphics.draw(self.animation.draw, self.x, self.posY)
    else
        love.graphics.draw(self.img, self.x, self.posY)
    end
    --love.graphics.rectangle("fill", self.x, self.posY, self.width, self.height)
end

function BackgroundObject.drawAll()
    for _, instance in ipairs(ActiveBackgroundObjects) do
        instance:draw()
    end
end

return BackgroundObject
