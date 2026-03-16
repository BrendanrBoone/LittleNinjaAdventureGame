local MgStar = {}
MgStar.__index = MgStar

ActiveMgStars = {}
local Sounds = require("sounds")
local Player = require("player")
local Categories = require("categories")

function MgStar.new(x, y, dropper)
    local instance = setmetatable({}, MgStar)

    instance.x = x
    instance.y = y
    instance.dropper = dropper
    instance.yVel = 0
    instance.xVel = 0
    instance.gravity = 1500
    instance.radius = 5

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newCircleShape(instance.radius)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setGravityScale(0)       -- unaffected by world gravity
    instance.physics.fixture:setCategory(Categories.enemyHitbox)
    instance.physics.fixture:setMask({Categories.ally, Categories.interactable}) -- don't collide with allies
    instance.physics.fixture:setUserData("mgStar") -- name fixture

    table.insert(ActiveMgStars, instance)
    Sounds:playSound(Sounds.sfx.smoke)
end

function MgStar:update(dt)
    self:syncPhysics(dt)
    self:applyGravity(dt)
end

function MgStar:applyGravity(dt)
    self.yVel = self.yVel + self.gravity * dt
end

function MgStar:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

-- removes self instance from ActiveMgStars
function MgStar:removeActive()
    for i, instance in ipairs(ActiveMgStars) do
        if instance == self then
            table.remove(ActiveMgStars, i)
            break
        end
    end
end

function MgStar:draw()
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function MgStar.updateAll(dt)
    for _, instance in ipairs(ActiveMgStars) do
        instance:update(dt)
    end
end

function MgStar.drawAll()
    for _, instance in ipairs(ActiveMgStars) do
        instance:draw()
    end
end

function MgStar.beginContact(a, b, collision)
    for _, instance in ipairs(ActiveMgStars) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.dropper:reduceScore()
            end
            instance:removeActive()
            return true
        end
    end
end

return MgStar
