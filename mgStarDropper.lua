local MgStarDropper = {}
MgStarDropper.__index = MgStarDropper

ActiveMgStarDroppers = {}
local Sounds = require("sounds")
local Player = require("player")
local Categories = require("categories")
local Helper = require("helper")
local Anima = require("myTextAnima")
local MgStar = require("mgStar")

function MgStarDropper.new(x, y, width, height)
    local instance = setmetatable({}, MgStarDropper)

    instance.x = x
    instance.y = y
    instance.height = height
    instance.width = width
    instance.dropOffset = 10
    instance.starCounter = { current = 0, max = 10 }
    instance.starGrace = { time = 1, duration = 0.3 }
    instance.dropRate = 0.7

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x + instance.width/2, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    instance.physics.fixture:setCategory(Categories.interactable)
    instance.physics.fixture:setMask({Categories.ally, Categories.enemyHitbox}) -- don't collide with allies
    instance.physics.fixture:setUserData("mgStarDropper") -- name fixture

    instance.score = 100
    instance.timer = { current = 30 , duration = 30 }

    instance.active = false
    instance.interactable = false
    instance.interactText = Anima.new(
        instance.physics.fixture,
        "Score: " .. instance.score,
        "above",
        0
    )

    table.insert(ActiveMgStarDroppers, instance)
end

function MgStarDropper:update(dt)
    if self.active then
        self:countdown(dt)
        self:updateAnima()
        self:dropStar(dt)
    end
    self:checkCollision()
end

function MgStarDropper:checkCollision()
    local boxA = {
        x = self.x,
        y = self.y,
        width = self.width,
        height = self.height
    }
    local boxB = {
        x = Player.x,
        y = Player.y,
        width = Player.width,
        height = Player.height
    }
    if Helper.checkIfCollided(boxA, boxB) then
        if not self.active then
            self.interactable = true
            self.interactText:animationStart()
            Player.interactText:animationStart()
        end
    else
        self.interactable = false
        self.interactText:animationEnd()
        Player.interactText:animationEnd()
    end
end

function MgStarDropper:countdown(dt)
    self.timer.current = self.timer.current - dt
    if self.timer.current <= 0 then
        self.active = false
        self.timer.current = self.timer.duration
    end
end

function MgStarDropper:updateAnima()
    local time = math.floor(self.timer.current)
    self.interactText:newTypingAnimation(
        "Score: " .. self.score .. ". Time: " .. time
    )
end

function MgStarDropper:dropStar(dt)
    print("dt: " .. dt)
    if self.starCounter.current <= self.starCounter.max and
    self.starGrace.time < 0 then
        self.starGrace.time = self.starGrace.duration
        print("dropped")
        if math.random() < self.dropRate then
            local offsetX = math.random() * self.width
            MgStar.new(self.x + offsetX, self.y + self.dropOffset, self)
        end
    end
    self.starGrace.time = self.starGrace.time - dt
end

function MgStarDropper:reduceScore()
    self.score = self.score - 1
end

function MgStarDropper:startMg()
    self.active = true
end

-- removes self instance from ActiveMgStarDroppers
function MgStarDropper:removeActive()
    for i, instance in ipairs(ActiveMgStarDroppers) do
        if instance == self then
            table.remove(ActiveMgStarDroppers, i)
            break
        end
    end
end

function MgStarDropper:draw()
    love.graphics.setColor(0,0,0,0.3)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function MgStarDropper.updateAll(dt)
    for _, instance in ipairs(ActiveMgStarDroppers) do
        instance:update(dt)
    end
end

function MgStarDropper.drawAll()
    for _, instance in ipairs(ActiveMgStarDroppers) do
        instance:draw()
    end
end

function MgStarDropper.keypressed(key)
    if MgStarDropper.interact(key) then
        return true
    end
    return false
end

function MgStarDropper.interact(key)
    if not Player:doingAction() and key == "e" then
        for _, instance in ipairs(ActiveMgStarDroppers) do
            if instance.interactable then
                instance:startMg()
                return true
            end
        end
    end
end

--[[
function MgStarDropper.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveMgStarDroppers) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                print("beginning contact")
                instance.interactable = true
                instance.interactText:animationStart()
                Player.interactText:animationStart()
                return true
            end
        end
    end
end

function MgStarDropper.endContact(a, b, collision)
    for i, instance in ipairs(ActiveMgStarDroppers) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                print("ending contact")
                instance.interactable = false
                instance.interactText:animationEnd()
                Player.interactText:animationEnd()
                return true
            end
        end
    end
end
]]
return MgStarDropper
