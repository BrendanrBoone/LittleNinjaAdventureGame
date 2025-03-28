local Portal = {}
Portal.__index = Portal

ActivePortals = {}
local Player = require("player")
local Categories = require("categories")

function Portal.new(x, y, destination, dX, dY, lock, displayText)
    local instance = setmetatable({}, Portal)

    instance.x = x
    instance.y = y
    instance.destination = destination
    instance.dX = dX
    instance.dY = dY
    instance.lock = lock
    instance.displayText = displayText
    instance.state = "idle"
    instance.idleTime = {
        current = 0,
        duration = 3
    }
    instance.destinationVisual = false
    instance.font = love.graphics.newFont("assets/ui/bit.ttf", 15)
    instance.displayTextLength = instance.font:getWidth(instance.displayText)

    -- Animations
    instance.animation = {
        timer = 0,
        rate = 0.2
    }
    instance.animation.idle = {
        total = 4,
        current = 1,
        img = Portal.blueAnim
    }
    instance:updateImg()
    instance.animation.draw = instance.animation.idle.img[1]

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true) -- prevents collisions but can be sensed
    instance.physics.fixture:setCategory(Categories.interactable)
    table.insert(ActivePortals, instance)
end

function Portal.loadAssets()
    Portal.blueAnim = {}
    for i = 1, 4 do
        Portal.blueAnim[i] = love.graphics.newImage("assets/portal/blue/" .. i .. ".png")
    end

    Portal.fireAnim = {}
    for i = 1, 4 do
        Portal.fireAnim[i] = love.graphics.newImage("assets/portal/fire/" .. i .. ".png")
    end

    Portal.greenAnim = {}
    for i = 1, 4 do
        Portal.greenAnim[i] = love.graphics.newImage("assets/portal/green/" .. i .. ".png")
    end

    Portal.width = Portal.blueAnim[1]:getWidth()
    Portal.height = Portal.blueAnim[1]:getHeight()
end

function Portal.removeAll()
    for _, v in ipairs(ActivePortals) do
        v.physics.body:destroy()
    end

    ActivePortals = {}
end

function Portal:checkLock()
    print("lock '"..self.lock.."'")
    if (self.lock == "fire" and Player.activeFireRelease) 
    or (self.lock == "water" and Player.activeWaterRelease)
    or (self.lock == "wind" and Player.activeWindRelease)
    or (self.lock == "null") then
        return true
    end
    return false
end

-- updates which portal asset to use based on the lock
function Portal:updateImg()
    if self.lock == "fire" then
        self.animation.idle.img = Portal.fireAnim
    elseif self.lock == "wind" then
        self.animation.idle.img = Portal.greenAnim
    else
        self.animation.idle.img = Portal.blueAnim
    end
end

function Portal:update(dt)
    self:animate(dt)
end

function Portal:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

-- updates the image
function Portal:setNewFrame()
    local anim = self.animation[self.state] -- not a copy. mirrors animation.[state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Portal:displayDestination()
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(self.displayText, self.x - self.displayTextLength / 2, self.y - self.height / 2)
end

function Portal:draw()
    if self.destinationVisual then
        self:displayDestination()
    end
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function Portal.updateAll(dt)
    for _, instance in ipairs(ActivePortals) do
        instance:update(dt)
    end
end

function Portal.drawAll()
    for _, instance in ipairs(ActivePortals) do
        instance:draw()
    end
end

function Portal.beginContact(a, b, collision)
    for i, instance in ipairs(ActivePortals) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.destinationVisual = true
                Player.interactText:animationStart()
                return true
            end
        end
    end
end

function Portal.endContact(a, b, collision)
    for i, instance in ipairs(ActivePortals) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.destinationVisual = false
                Player.interactText:animationEnd()
                return true
            end
        end
    end
end

return Portal
