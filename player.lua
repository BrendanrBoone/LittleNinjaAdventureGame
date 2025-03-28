local Player = {}
local Sounds = require("sounds")
local Explosion = require("explosion")
local Smoke = require("smoke")
local Aura = require("aura")
local STI = require("sti")
local Hitbox = require("hitbox")
local Helper = require("helper")
local Anima = require("myTextAnima")
local Recipes = require("recipes")
local Categories = require("categories")
local Inventory = require("inventory")
local CharacterData = require("characterData")

function Player:load()
    self.data = CharacterData["ninja"]

    self.x = 100
    self.y = 100
    self.offsetY = -12       -- arbitrary y axis offset to align Naruto character model
    self.FrankyOffsetX = 3   -- arbitrary x axis offset to align hitboxes for Franky character model
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
    self.superJumpAmount = -2500
    self.airJumpAmount = self.jumpAmount * 0.8
    self.totalAirJumps = 1
    self.airJumpsUsed = 0
    self.dash = {
        amount = 700,
        cost = 50,
        inputPressed = 0,
        inputRequirment = 2
    }
    self.dash.graceTime = 0
    self.dash.graceDuration = 0.3
    self.coins = 0
    self.health = {
        current = 15,
        max = 15
    }
    self.chakra = {
        current = 200,
        max = 200,
        rate = 10, -- spend rate
        chargeRate = 20
    }
    self.sealSequence = {
        current = 0,
        max = 6,
        graceTime = 0,
        graceDuration = 2,
        sequence = {}
    }

    self.color = {
        red = 1,
        green = 1,
        blue = 1,
        speed = 3 -- speed to untint
    }

    self.releaseColor = {
        red = 0,
        green = 0,
        blue = 0,
        scale = 1.1 -- aura size scale, greater than character size
    }

    self.releaseGrace = {
        time = 0,
        duration = 6
    }

    self.graceTime = 0
    self.graceDuration = 0.1 -- time to do a grounded jump after leaving the ground

    -- boolean check if action are active
    self.activeForwardAir = false
    self.activeForwardAttack = false
    self.activeRushAttack = false
    self.activeFireRelease = false
    self.activeWaterRelease = false
    self.activeWindRelease = false

    self.sealPerformed = false
    self.charging = false
    self.sealing = false
    self.emoting = false
    self.attacking = false
    self.dashing = false
    self.talking = false

    self.alive = true
    self.invincibility = false
    self.grounded = false
    self.actionable = true

    self.direction = "right"
    self.state = "idleRight"
    self.seal = ""

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true) -- doesn't rotate
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setGravityScale(0)       -- unaffected by world gravity
    self.physics.fixture:setCategory(Categories.player)
    self.physics.fixture:setMask(Categories.ally) -- don't collide with allies
    self.physics.fixture:setUserData("player") -- name fixture

    self.interactText = Anima.new(self.physics.fixture, "interact (E)", "below", 0)
    self.defaultInteractText = tostring(self.interactText.text)

    self:loadAssets()
    self:loadHitboxes()
end

function Player:loadAssets()
    self.animation = self.data.animation.timer

    if self.data.asymmetric then
        self.animation.idleRight = self.data.animation.idleRight
        self.animation.idleLeft = self.data.animation.idleLeft
        self.animation.runRight = self.data.animation.runRight
        self.animation.runLeft = self.data.animation.runLeft
        self.animation.airRisingRight = self.data.animation.airRisingRight
        self.animation.airRisingLeft = self.data.animation.airRisingLeft
        self.animation.airFallingRight = self.data.animation.airFallingRight
        self.animation.airFallingLeft = self.data.animation.airFallingLeft
        self.animation.sealRight = self.data.animation.sealRight
        self.animation.sealLeft = self.data.animation.sealLeft
    else
        self.animation.idleRight = self.data.animation.idle
        self.animation.idleLeft = self.data.animation.idle
        self.animation.runRight = self.data.animation.run
        self.animation.runLeft = self.data.animation.run
        self.animation.airRisingRight = self.data.animation.airRising
        self.animation.airRisingLeft = self.data.animation.airRising
        self.animation.airFallingRight = self.data.animation.airFalling
        self.animation.airFallingLeft = self.data.animation.airFalling
        self.animation.sealRight = self.data.animation.seal
        self.animation.sealLeft = self.data.animation.seal
    end

    self.animation.draw = self.animation.idleRight.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()

    self:loadSealAssets()
end

function Player:loadSealAssets()
    self.animation.seals = {}

    self.animation.seals.fireSeal = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.seals.fireSeal.total do
        self.animation.seals.fireSeal.img[i] = love.graphics.newImage("assets/fireSeal/" .. i .. ".png")
    end

    self.animation.seals.waterSeal = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.seals.waterSeal.total do
        self.animation.seals.waterSeal.img[i] = love.graphics.newImage("assets/waterSeal/" .. i .. ".png")
    end

    self.animation.seals.windSeal = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.seals.windSeal.total do
        self.animation.seals.windSeal.img[i] = love.graphics.newImage("assets/windSeal/" .. i .. ".png")
    end

    self.animation.seals.draw = self.animation.seals.fireSeal.img[1]
    self.animation.seals.width = self.animation.seals.draw:getWidth()
    self.animation.seals.height = self.animation.seals.draw:getHeight()
end

function Player:loadHitboxes()
    self.hitbox = {}
    --self:loadForwardAirHitbox()
    --self:loadForwardAttackHitbox()
    --self:loadRushAttackHitbox()
end

--@param recipe: string (jutsu.name)
function Player:performJutsu(recipe)
    Sounds:playSound(Sounds.sfx.jutsu)
    if recipe == "fireRelease" then
        self:fireRelease()
    elseif recipe == "waterRelease" then
        self:waterRelease()
    elseif recipe == "windRelease" then
        self: windRelease()
    end
end

function Player:takeDamage(amount)
    if not self.invincibility then
        self:cancelActiveActions()
        self:resetAnimations()
        self:resetHitboxes()

        self:tintRed()
        Sounds.playSound(Sounds.sfx.playerHit)
        if self.health.current - amount > 0 then
            self.health.current = self.health.current - amount
        else
            self.health.current = 0
            self:die()
        end
        print("Player health: " .. self.health.current)
    end
end

function Player:respawn()
    if not self.alive then
        self:resetPosition()
        self.health.current = self.health.max
        self.alive = true
    end
end

function Player:resetPosition()
    self.physics.body:setPosition(self.startX, self.startY)
end

function Player:setPosition(x, y)
    self.physics.body:setPosition(x, y)
    self:cancelActiveActions()
end

function Player:tintRed()
    self.color.green = 0
    self.color.blue = 0
end

function Player:tintBlue()
    self.color.green = 0
    self.color.red = 0
end

function Player:tintGreen()
    self.color.blue = 0
    self.color.red = 0
end

function Player:die()
    print("Player Died")
    self.alive = false
end

function Player:incrementCoins()
    Sounds.playSound(Sounds.sfx.playerGetCoin)
    self.coins = self.coins + 1
end

function Player:pickUpItem(item)
    if item == "chakraRefresh" then
        self:chakraRefresh()
    end
end

function Player:chakraRefresh()
    -- play a noise
    self.chakra.current = self.chakra.max
end

function Player:update(dt)
    -- print(self.x..", "..self.y)
    self:unTint(dt)
    self:respawn()
    self:setDirection()
    self:setState()
    self:animate(dt)
    self:decreaseGraceTime(dt)
    self:syncPhysics() -- sets character position
    self:action(dt)
    self:applyGravity(dt)
end

function Player:action(dt)
    if self.actionable then
        self:move(dt)
        self:chargeChakra(dt)
    end
end

function Player:chargeChakra(dt)
    if love.keyboard.isDown("q")
    and self.xVel == 0
    and self.yVel == 0 then
        if not self:doingAction() then
            self.charging = true
            Aura.new(self.x, self.y, self.physics.fixture)
            Sounds.repeatSound(Sounds.sfx.chargeLoop)
        end
        self.chakra.current = math.min(self.chakra.current + dt * self.chakra.chargeRate, self.chakra.max)
        print("charging: ".. self.chakra.current)
    else
        Sounds.stopSound(Sounds.sfx.chargeLoop)
        Aura.remove(self.physics.fixture)
        self.charging = false
    end
end

function Player:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

-- sets state to its direction
function Player:stateWithDirection(state)
    if self.direction == "right" then
        self.state = state .. "Right"
    else
        self.state = state .. "Left"
    end
end

function Player:setState()
    if self.dashing then
        self.state = "dash"
    elseif not self.grounded then
        if self.attacking then
            if self.activeForwardAir then
                self.state = "forwardAir"
            end
        else
            if self.yVel < 0 then
                self:stateWithDirection("airRising")
            else
                self:stateWithDirection("airFalling")
            end
        end
    else
        if self.attacking then
            if self.activeForwardAttack then
                self.state = "forwardAttack"
            elseif self.activeRushAttack then
                self.state = "rushAttack"
            end
        else
            if self.xVel == 0 then
                if self.emoting then
                    self.state = "emote"
                elseif self.sealing then
                    self:stateWithDirection("seal")
                else
                    self:stateWithDirection("idle")
                end
            else
                self:stateWithDirection("run")
            end
        end
    end
end

function Player:setDirection()
    if not self.attacking then
        if self.xVel > 0 then
            self.direction = "right"
        elseif self.xVel < 0 then
            self.direction = "left"
        end
    end
end

function Player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

-- updates the image
function Player:setNewFrame()
    local anim = self.animation[self.state]
    self:sealSetNewFrame()
    self:animEffects(anim)
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Player:sealSetNewFrame()
    if self.sealing then
        local sanim = self.animation.seals[self.seal]
        self:sealAnimEffects(sanim)
        if sanim.current < sanim.total then
            sanim.current = sanim.current + 1
        else
            sanim.current = 1
        end
        self.animation.seals.draw = sanim.img[sanim.current]
    end
end

function Player:animEffects(animation)
    self:emoteOwEffects(animation)
    self:forwardAirEffects(animation)
    self:forwardAttackEffects(animation)
    self:rushAttackEffects(animation)
    self:dashEffects(animation)
    self:fireReleaseEffects()
end

function Player:sealAnimEffects(animation)
    self:fireSealEffects(animation)
    self:waterSealEffects(animation)
    self:windSealEffects(animation)
end

function Player:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

-- this checks sealing, cancelActiveActions does not
function Player:doingAction()
    if self.emoting
    or self.sealing
    or self.charging
    or self.attacking
    or self.talking
    or self.dashing then
        return true
    end
    return false
end

function Player:move(dt)
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

function Player:applyFriction(dt)
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

function Player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

-- called in Player:update()
function Player:decreaseGraceTime(dt)
    self:decreaseJumpGrace(dt)
    self:decreaseDashGrace(dt)
    self:decreaseSealGrace(dt)
    self:decreaseReleaseGrace(dt)
end

function Player:decreaseReleaseGrace(dt)
    if self.activeFireRelease or self.activeWaterRelease or self.activeWindRelease then
        self.releaseGrace.time = self.releaseGrace.time + dt
        if self.releaseGrace.time > self.releaseGrace.duration then
            self.activeFireRelease = false
            self.activeWaterRelease = false
            self.activeWindRelease = false
            print("release off")
        end
    end
end

function Player:decreaseSealGrace(dt)
    if not self.sealing then
        self.sealSequence.graceTime = self.sealSequence.graceTime - dt
        self:checkSealSequence()
    end
end

function Player:decreaseJumpGrace(dt)
    if not self.grounded then
        self.graceTime = self.graceTime - dt
    end
end

function Player:decreaseDashGrace(dt)
    if self.dash.inputPressed ~= 0 then
        self.dash.graceTime = self.dash.graceTime - dt
        if self.dash.graceTime <= 0 then
            self.dash.inputPressed = 0
            self.dash.graceTime = self.dash.graceDuration
        end
    end
end

-- make this more efficient if everything works properly
function Player:checkSealSequence()
    if self.sealSequence.graceTime < 0 then
        if #self.sealSequence.sequence > 0 then
            if self.sealPerformed then
                self.sealPerformed = false
            else
                self:sealFailed()
            end
        end
    end
end

-- checks if release jutsu is active
function Player:checkRelease()
    if self.activeFireRelease
    or self.activeWaterRelease
    or self.activeWindRelease then
        return true
    end
    return false
end

function Player:dashForward(key)
    if not self:doingAction() and key == "lshift" and self.dash.cost <= self.chakra.current then
        self.dash.inputPressed = self.dash.inputPressed + 1
        if self.dash.inputPressed == self.dash.inputRequirment then
            self.dashing = true
            self.dash.graceTime = self.dash.graceDuration
            self.dash.inputPressed = 0
            local v
            if self.direction == "right" then
                v = self.dash.amount
            else
                v = -self.dash.amount
            end
            self.xVel = self.xVel + v
            self.chakra.current = self.chakra.current - self.dash.cost
        end
    end
end

function Player:dashEffects()
    if self.dashing and math.abs(self.xVel) <= self.maxSpeed then
        self:cancelActiveActions()
    end
end

function Player:jump(key)
    if not self:doingAction() then
        if (key == "w" or key == "up" or key == "space") then
            if self.grounded or self.graceTime > 0 then
                self.yVel = self.jumpAmount
                Sounds.playSound(Sounds.sfx.playerJump)
            elseif self.airJumpsUsed < self.totalAirJumps then
                self.yVel = self.airJumpAmount
                self.grounded = false
                self.airJumpsUsed = self.airJumpsUsed + 1
                Sounds.playSound(Sounds.sfx.playerJump)
            end
        end
    end
end

function Player:fastFall(key)
    if not self.grounded and not self.sealing then
        if (key == "s") then
            self.yVel = -self.jumpAmount
        end
    end
end

-- reset cancellable animations
function Player:resetAnimations()
    --[[self.animation.forwardAir.current = 1
    self.animation.forwardAttack.current = 1
    self.animation.rushAttack.current = 1
    self.animation.emote.current = 1]]
end

function Player:sealResetAnimations()
    self.animation.seals.fireSeal.current = 1
    self.animation.seals.waterSeal.current = 1
    self.animation.seals.windSeal.current = 1
end

function Player:resetHitboxes()
    for _, hitbox in ipairs(LiveHitboxes) do
        for _, v in ipairs(self.hitbox) do
            if hitbox.type:find(v.type) then
                hitbox.active = false
            end
        end
    end
end

function Player:rushAttack(key)
    if not self:doingAction() and self.grounded and self.xVel ~= 0 and key == "p" then
        self.attacking = true
        self.activeRushAttack = true
    end
end

function Player:rushAttackEffects(anim)
    if self.activeRushAttack then
        self.invincibility = true
        for _, hitbox in ipairs(LiveHitboxes) do
            if hitbox.type:find(self.hitbox.rushAttack.type) then
                if self.direction == "right" and hitbox.type == self.hitbox.rushAttack.type .. anim.current .. "Right" then
                    hitbox.active = true
                elseif self.direction == "left" and hitbox.type == self.hitbox.rushAttack.type .. anim.current .. "Left" then
                    hitbox.active = true
                else
                    hitbox.active = false
                end
            end
        end
        if anim.current == anim.total then
            self:cancelActiveActions()
        end
    end
end

function Player:forwardAttack(key)
    if not self:doingAction() and self.grounded and self.xVel == 0 and key == "p" then
        self.attacking = true
        self.activeForwardAttack = true
    end
end

-- this determines what frames are active
function Player:forwardAttackEffects(anim)
    if self.activeForwardAttack then
        for _, hitbox in ipairs(LiveHitboxes) do
            if hitbox.type:find(self.hitbox.forwardAttack.type) then
                if self.direction == "right" and hitbox.type == self.hitbox.forwardAttack.type .. anim.current ..
                    "Right" then
                    hitbox.active = true
                elseif self.direction == "left" and hitbox.type == self.hitbox.forwardAttack.type .. anim.current ..
                    "Left" then
                    hitbox.active = true
                else
                    hitbox.active = false
                end
            end
        end
        if anim.current == anim.total then
            self:cancelActiveActions()
        end
    end
end

function Player:forwardAir(key)
    if not self.grounded and not self:doingAction() and key == "p" and love.keyboard.isDown("a", "d", "left", "right") then
        self.attacking = true
        self.activeForwardAir = true
    end
end

function Player:forwardAirEffects(anim)
    if self.activeForwardAir then
        self.invincibility = true
        for _, hitbox in ipairs(LiveHitboxes) do
            if hitbox.type:find(self.hitbox.forwardAir.type) then
                if self.direction == "right" and hitbox.type == self.hitbox.forwardAir.type .. anim.current .. "Right" then
                    hitbox.active = true
                elseif self.direction == "left" and hitbox.type == self.hitbox.forwardAir.type .. anim.current .. "Left" then
                    hitbox.active = true
                else
                    hitbox.active = false
                end
            end
        end
        if anim.current == anim.total then
            self:cancelActiveActions()
        end
    end
end

function Player:spendChakra(amount)
    local diff = self.chakra.current - amount
    if diff < 0 then
        self.chakra.current = 0
    else
        self.chakra.current = diff
    end
end

function Player:cancelActiveActions()
    self.attacking = false
    self.activeForwardAir = false
    self.activeForwardAttack = false
    self.activeRushAttack = false
    self.emoting = false
    self.invincibility = false
    self.dashing = false
    self.charging = false
end

function Player:keypressed(key)
    if self.actionable then
        self:jump(key)
        self:fastFall(key)
        self:fireSeal(key)
        self:waterSeal(key)
        self:windSeal(key)
        self:activateJutsu(key)
    end
end

-- start some sort of animation and clear sequence after
function Player:sealFailed()
    print("sealFailed")
    self:spendChakra(self.chakra.rate * self.sealSequence.current)
    print("chakra: "..self.chakra.current)
    self:resetSeals()
    self.sealing = false
    self.seal = ""
    Smoke.new(self.x, self.y)
end

function Player:resetSeals()
    self.sealSequence.current = 0
    self.sealSequence.sequence = {}
end

function Player:addSealToSequence(seal)
    Sounds:playSound(Sounds.sfx.seal)
    self.sealSequence.graceTime = self.sealSequence.graceDuration
    if not (self.sealSequence.current >= self.sealSequence.max) then
        self.sealSequence.current = self.sealSequence.current + 1
        self.sealSequence.sequence[self.sealSequence.current] = seal
    else
        self:sealFailed()
    end
end

function Player:fireSeal(key)
    if (not self:doingAction() or self.sealing) and key == "1" then
        self:sealResetAnimations()
        self.sealing = true
        self.seal = "fireSeal"
        self:addSealToSequence(self.seal)
    end
end

function Player:fireSealEffects(anim)
    if self.seal == "fireSeal" then
        if anim.current == anim.total then
            self.sealing = false
            self.seal = ""
        end
    end
end

function Player:waterSeal(key)
    if (not self:doingAction() or self.sealing) and key == "2" then
        self:sealResetAnimations()
        self.sealing = true
        self.seal = "waterSeal"
        self:addSealToSequence(self.seal)
    end
end

function Player:waterSealEffects(anim)
    if self.seal == "waterSeal" then
        if anim.current == anim.total then
            self.sealing = false
            self.seal = ""
        end
    end
end

function Player:windSeal(key)
    if (not self:doingAction() or self.sealing) and key == "3" then
        self:sealResetAnimations()
        self.sealing = true
        self.seal = "windSeal"
        self:addSealToSequence(self.seal)
    end
end

function Player:windSealEffects(anim)
    if self.seal == "windSeal" then
        if anim.current == anim.total then
            self.sealing = false
            self.seal = ""
        end
    end
end

function Player:activateJutsu(key)
    if (not self:doingAction() or self.sealing) and key == "r" then
        Inventory:printStoryItems()
        local recipe = Recipes:checkSequence(self.sealSequence.sequence)
        if recipe then -- inventory mechanic for jutsus added here later
            self:resetSeals()
            self.sealPerformed = true
            print("activated "..recipe)
            self:performJutsu(recipe)
        else
            self:sealFailed()
        end
    end
end

function Player:emote(key)
    if not self:doingAction() and key == "e" and self.grounded and self.xVel == 0 then
        Sounds.sfx.frankyEyeCatchTheme:setVolume(Sounds.sfx.maxSound)
        Sounds.playSound(Sounds.sfx.frankyEyeCatchTheme)
        self.emoting = true
    end
end

function Player:emoteOwEffects(anim)
    if self.emoting then
        if anim.current < anim.total and self.emoting and self.animation.emote.current == 10 then
            Sounds.playSound(Sounds.sfx.playerHit)
            Explosion.new(self.x, self.y)
        elseif anim.current == anim.total and self.emoting then
            self.emoting = false
        end
    end
end

function Player:superJump()
    self.yVel = self.superJumpAmount
    Sounds.playSound(Sounds.sfx.playerJump)
end

function Player:beginContact(a, b, collision)
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

function Player:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
    self.airJumpsUsed = 0
    self.graceTime = self.graceDuration

    self:cancelActiveActions()

    self:resetAnimations()
    self:resetHitboxes()
end

function Player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end
end

function Player:draw()
    local scaleX = 1
    if self.direction == self.data.oppositeDirection then
        scaleX = -1
    end
    local width = self.animation.width / 2
    local height = self.animation.height / 2
    love.graphics.setColor(1, 1, 1)

    --draw seal
    if self.sealing then
        local sealWidth = self.animation.seals.width / 2
        local sealHeight = self.animation.seals.height / 2
        love.graphics.draw(self.animation.seals.draw, self.x, self.y, 0, 1, 1, sealWidth, sealHeight)
    end

    -- draw release aura
    if self:checkRelease() then
        love.graphics.setColor(self.releaseColor.red, self.releaseColor.green, self.releaseColor.blue)
        love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, 0, scaleX, 1, width * self.releaseColor.scale, height * self.releaseColor.scale)
    end
    
    -- draw character
    love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, 0, scaleX, 1, width, height)
    
    --love.graphics.draw(self.animation.seals.fireSeal.img[self.animation.seals.fireSeal.current], sealWidth, sealHeight + 75, 0, 1, 1, sealWidth, sealHeight)
    --love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end

-- gives player fire attribute for a period of time
function Player:fireRelease()
    print("fireRelease")
    self.releaseGrace.time = 0
    self.activeFireRelease = true
    self.activeWaterRelease = false
    self.activeWindRelease = false
    self.releaseColor.red = 1
    self.releaseColor.blue = 0
    self.releaseColor.green = 0
    self:tintRed()
    --play sound
end

function Player:fireReleaseEffects()
    if self.activeFireRelease
    and not self.activeWaterRelease
    and not self.activeWindRelease then
        
    end
end

-- gives player water attribute for a period of time
function Player:waterRelease()
    print("waterRelease")
    self.releaseGrace.time = 0
    self.activeFireRelease = false
    self.activeWaterRelease = true
    self.activeWindRelease = false
    self.releaseColor.red = 0
    self.releaseColor.blue = 1
    self.releaseColor.green = 0
    self:tintBlue()
    --play sound
end

function Player:waterReleaseEffects()
    if not self.activeFireRelease
    and self.activeWaterRelease
    and not self.activeWindRelease then
        
    end
end

-- gives player water attribute for a period of time
function Player:windRelease()
    print("windRelease")
    self.releaseGrace.time = 0
    self.activeFireRelease = false
    self.activeWaterRelease = false
    self.activeWindRelease = true
    self.releaseColor.red = 0
    self.releaseColor.blue = 0
    self.releaseColor.green = 1
    self:tintGreen()
    --play sound
end

function Player:windReleaseEffects()
    if not self.activeFireRelease
    and not self.activeWaterRelease
    and self.activeWindRelease then
        
    end
end

function Player:loadRushAttackHitbox()
    self.hitbox.rushAttack = {}
    self.hitbox.rushAttack.map = STI("hitboxMap/rushAttack.lua", { "box2d" })
    self.hitbox.rushAttack.hitboxesLayer = self.hitbox.rushAttack.map.layers.hitboxes
    self.hitbox.rushAttack.mapWidth = self.hitbox.rushAttack.map.layers.ground.width * 16
    self.hitbox.rushAttack.mapHeight = self.hitbox.rushAttack.map.layers.ground.height * 16

    self.hitbox.rushAttack.damage = 10
    self.hitbox.rushAttack.shakeSize = "medium"

    self.hitbox.rushAttack.knockbackAtFrame = { { 100, 0 }, { 100, 0 }, { 100, 0 }, { 500, -100 } }

    self.hitbox.rushAttack.targets = ActiveEnemys

    self.hitbox.rushAttack.type = "rushAttack"
    local args = {
        animTotal = self.animation.rushAttack.total,
        hitboxType = self.hitbox.rushAttack.type,
        layerObjects = self.hitbox.rushAttack.hitboxesLayer.objects,
        hitboxMapWidth = self.hitbox.forwardAir.mapWidth,
        hitboxMapHeight = self.hitbox.rushAttack.mapHeight,
        playerImgWidth = self.animation.width,

        srcFixture = self.physics.fixture,
        targets = self.hitbox.rushAttack.targets,
        width = self.width,
        xOff = self.FrankyOffsetX,
        height = self.height,
        yOff = self.FrankyOffsetY,

        damage = self.hitbox.rushAttack.damage,
        knockbackAtFrame = self.hitbox.rushAttack.knockbackAtFrame,
        shakeSize = self.hitbox.rushAttack.shakeSize
    }
    Hitbox.generateHitboxes(args)
end

function Player:loadForwardAttackHitbox()
    self.hitbox.forwardAttack = {}
    self.hitbox.forwardAttack.map = STI("hitboxMap/forwardAttack.lua", { "box2d" })
    self.hitbox.forwardAttack.hitboxesLayer = self.hitbox.forwardAttack.map.layers.hitboxes
    self.hitbox.forwardAttack.mapWidth = self.hitbox.forwardAttack.map.layers.ground.width * 16
    self.hitbox.forwardAttack.mapHeight = self.hitbox.forwardAttack.map.layers.ground.height * 16

    self.hitbox.forwardAttack.damage = 10
    self.hitbox.forwardAttack.shakeSize = "large"

    self.hitbox.forwardAttack.xVel = 500
    self.hitbox.forwardAttack.yVel = -100

    self.hitbox.forwardAttack.targets = ActiveEnemys

    self.hitbox.forwardAttack.type = "forwardAttack"
    local args = {
        animTotal = self.animation.forwardAttack.total,
        hitboxType = self.hitbox.forwardAttack.type,
        layerObjects = self.hitbox.forwardAttack.hitboxesLayer.objects,
        hitboxMapWidth = self.hitbox.forwardAir.mapWidth,
        hitboxMapHeight = self.hitbox.forwardAttack.mapHeight,
        playerImgWidth = self.animation.width,

        srcFixture = self.physics.fixture,
        targets = self.hitbox.forwardAttack.targets,
        width = self.width,
        xOff = self.FrankyOffsetX,
        height = self.height,
        yOff = self.FrankyOffsetY,

        damage = self.hitbox.forwardAttack.damage,
        xVel = self.hitbox.forwardAttack.xVel,
        yVel = self.hitbox.forwardAttack.yVel,
        shakeSize = self.hitbox.forwardAttack.shakeSize
    }
    Hitbox.generateHitboxes(args)
end

function Player:loadForwardAirHitbox()
    self.hitbox.forwardAir = {}
    self.hitbox.forwardAir.map = STI("hitboxMap/forwardAir.lua", { "box2d" })
    self.hitbox.forwardAir.hitboxesLayer = self.hitbox.forwardAir.map.layers.hitboxes
    self.hitbox.forwardAir.mapWidth = self.hitbox.forwardAir.map.layers.ground.width * 16
    self.hitbox.forwardAir.mapHeight = self.hitbox.forwardAir.map.layers.ground.height * 16

    self.hitbox.forwardAir.damage = 5
    self.hitbox.forwardAir.shakeSize = "small"

    self.hitbox.forwardAir.xVel = 500
    self.hitbox.forwardAir.yVel = -100

    self.hitbox.forwardAir.targets = ActiveEnemys

    self.hitbox.forwardAir.type = "forwardAir"
    local args = {
        animTotal = self.animation.forwardAir.total,
        hitboxType = self.hitbox.forwardAir.type,
        layerObjects = self.hitbox.forwardAir.hitboxesLayer.objects,
        hitboxMapWidth = self.hitbox.forwardAir.mapWidth,
        hitboxMapHeight = self.hitbox.forwardAir.mapHeight,
        playerImgWidth = self.animation.width,

        srcFixture = self.physics.fixture,
        targets = self.hitbox.forwardAir.targets,
        width = self.width,
        xOff = self.FrankyOffsetX,
        height = self.height,
        yOff = self.FrankyOffsetY,

        damage = self.hitbox.forwardAir.damage,
        xVel = self.hitbox.forwardAir.xVel,
        yVel = self.hitbox.forwardAir.yVel,
        shakeSize = self.hitbox.forwardAir.shakeSize
    }
    Hitbox.generateHitboxes(args)
end

return Player
