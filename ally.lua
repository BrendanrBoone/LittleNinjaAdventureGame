local Ally = {}
local Sounds = require("sounds")
local Helper = require("helper")
local Anima = require("myTextAnima")
local Dialogue = require("dialogue")
local Categories = require("categories")

function Ally:new(type)
    self.x = 100
    self.y = 100
    self.offsetY = -12
    self.FrankyOffsetX = 3
    self.startX = self.x
    self.startY = self.y
    self.width = 25
    self.height = 40
    self.xVel = 0            -- + goes right
    self.yVel = 0            -- + goes down
    self.maxSpeed = 200
    self.acceleration = 4000 -- 200 / 4000 = 0.05 seconds to reach maxSpeed
    self.friction = 3500     -- 200 / 3500 = 0.0571 seconds to stop from maxSpeed
    self.gravity = 1500
    self.jumpAmount = -500
    self.airJumpAmount = self.jumpAmount * 0.8
    self.totalAirJumps = 1
    self.airJumpsUsed = 0

    self.health = {
        current = 15,
        max = 15
    }

    self.color = {
        red = 1,
        green = 1,
        blue = 1,
        speed = 3 -- speed to untint
    }

    self.graceTime = 0
    self.graceDuration = 0.1 -- time to do a grounded jump after leaving the ground

    self.emoting = false
    self.talking = false
    self.attacking = false

    self.alive = true
    self.invincibility = false
    self.grounded = false

    self.direction = "left"
    self.state = "idle"
    self.type = type

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true) -- doesn't rotate
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setGravityScale(0)       -- unaffected by world gravity
    self.physics.fixture:setCategory(Categories.ally)
    self.physics.fixture:setMask(Categories.player) -- don't collide with player
    self.physics.fixture:setUserData("ally") -- name fixture

    self.interactText = Anima.new(self.physics.fixture, Dialogue[self.type].message, "below")
    self.defaultInteractText = tostring(self.interactText.text)

    self:loadAssets()
    self:loadHitboxes()
end

function Ally:loadAssets()
    self.animation = {
        timer = 0,
        rate = 0.1
    }

    self.animation.run = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.run.total do
        self.animation.run.img[i] = love.graphics.newImage("assets/Naruto/run/" .. i .. ".png")
    end

    self.animation.idle = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/princess/idle/" .. i .. ".png")
    end

    self.animation.airRising = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.airRising.total do
        self.animation.airRising.img[i] = love.graphics.newImage("assets/Naruto/airRising/" .. i .. ".png")
    end

    self.animation.airFalling = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.airFalling.total do
        self.animation.airFalling.img[i] = love.graphics.newImage("assets/Naruto/airFalling/" .. i .. ".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()

    self:loadSealAssets()
end

function Ally:takeDamage(amount)
    if not self.invincibility then
        self:cancelActiveActions()
        self:resetAnimations()
        self:resetHitboxes()

        self:tintRed()
        Sounds.playSound(Sounds.sfx.AllyHit)
        if self.health.current - amount > 0 then
            self.health.current = self.health.current - amount
        else
            self.health.current = 0
            self:die()
        end
        print("Ally health: " .. self.health.current)
    end
end

function Ally:resetPosition()
    self.physics.body:setPosition(self.startX, self.startY)
end

function Ally:setPosition(x, y)
    self.physics.body:setPosition(x, y)
    self:cancelActiveActions()
end

function Ally:tintRed()
    self.color.green = 0
    self.color.blue = 0
end

function Ally:tintBlue()
    self.color.green = 0
    self.color.red = 0
end

function Ally:tintGreen()
    self.color.blue = 0
    self.color.red = 0
end

function Ally:update(dt)
    -- print(self.x..", "..self.y)
    self:unTint(dt)
    self:respawn()
    self:setState()
    self:setDirection()
    self:animate(dt)
    self:decreaseGraceTime(dt)
    self:syncPhysics() -- sets character position
    self:move(dt)
    self:applyGravity(dt)
end

function Ally:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Ally:setState()
    if not self.grounded then
        if self.yVel < 0 then
            self.state = "airRising"
        else
            self.state = "airFalling"
        end
    else
        if self.xVel == 0 then
            if self.emoting then
                self.state = "emote"
            else
                self.state = "idle"
            end
        else
            self.state = "run"
        end
    end
end

function Ally:setDirection()
    if not self.attacking then
        if self.xVel > 0 then
            self.direction = "right"
        elseif self.xVel < 0 then
            self.direction = "left"
        end
    end
end

function Ally:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

-- updates the image
function Ally:setNewFrame()
    local anim = self.animation[self.state]
    self:animEffects(anim)
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Ally:animEffects(animation)
    
end

function Ally:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

-- this checks sealing, cancelActiveActions does not
function Ally:doingAction()
    if self.talking then
        return true
    end
    return false
end

function Ally:move(dt)
    -- sprint
    if love.keyboard.isDown("lshift") and self.chakra.current > 0 and self.xVel ~= 0 then
        self.maxSpeed = 400
    else
        self.maxSpeed = 200
    end

    -- left and right movement
    if love.keyboard.isDown("d", "right") and not self:doingAction() then
        self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
    elseif love.keyboard.isDown("a", "left") and not self:doingAction() then
        self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed)
    else
        self:applyFriction(dt)
    end
end

function Ally:applyFriction(dt)
    if self.grounded then
        if self.xVel > 0 then
            self.xVel = math.max(self.xVel - self.friction * dt, 0)
        elseif self.xVel < 0 then
            self.xVel = math.min(self.xVel + self.friction * dt, 0)
        end
    else -- MAYBE CHANGE THIS LATER
        if self.xVel > 0 then
            self.xVel = math.max(self.xVel - self.friction / 6 * dt, 0)
        elseif self.xVel < 0 then
            self.xVel = math.min(self.xVel + self.friction / 6 * dt, 0)
        end
    end
end

function Ally:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

-- called in Ally:update()
function Ally:decreaseGraceTime(dt)
    self:decreaseJumpGrace(dt)
end

function Ally:decreaseJumpGrace(dt)
    if not self.grounded then
        self.graceTime = self.graceTime - dt
    end
end

function Ally:jump(key)
    if not self:doingAction() then
        if (key == "w" or key == "up" or key == "space") then
            if self.grounded or self.graceTime > 0 then
                self.yVel = self.jumpAmount
                Sounds.playSound(Sounds.sfx.AllyJump)
            elseif self.airJumpsUsed < self.totalAirJumps then
                self.yVel = self.airJumpAmount
                self.grounded = false
                self.airJumpsUsed = self.airJumpsUsed + 1
                Sounds.playSound(Sounds.sfx.AllyJump)
            end
        end
    end
end

function Ally:fastFall(key)
    if not self.grounded and not self.sealing then
        if (key == "s") then
            self.yVel = -self.jumpAmount
        end
    end
end

-- reset cancellable animations
function Ally:resetAnimations()
    
end

function Ally:cancelActiveActions()
    self.invincibility = false
end

function Ally:beginContact(a, b, collision)
    if self.grounded == true then
        return
    end
    if Helper.checkFUD(a, b, "hitbox") then
        return
    end
    local __, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny > 0 then
            self:land(collision)
        elseif ny < 0 then
            self.yVel = 0
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            self:land(collision)
        elseif ny > 0 then
            self.yVel = 0
        end
    end
end

function Ally:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
    self.airJumpsUsed = 0
    self.graceTime = self.graceDuration

    self:cancelActiveActions()

    self:resetAnimations()
    self:resetHitboxes()
end

function Ally:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end
end

function Ally:draw()
    local scaleX = 1
    if self.direction == "right" then
        scaleX = -1
    end
    local width = self.animation.width / 2
    local height = self.animation.height / 2
    -- draw character
    love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, 0, scaleX, 1, width, height)
end

return Ally
