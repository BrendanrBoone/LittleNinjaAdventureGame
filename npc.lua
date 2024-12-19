local NPC = {}
NPC.__index = NPC

ActiveNPCs = {}
local Player = require("player")
local Anima = require("myTextAnima")
local Dialogue = require("dialogue")
local GUI = require("gui")
local Helper = require("helper")
local Categories = require("categories")
local Ally = require("ally")
local Inventory = require("inventory")

--@param type: string "princess" or "nicoRobin"
function NPC.new(x, y, type, itemName)
    local instance = setmetatable({}, NPC)

    instance.x = x
    instance.y = y
    instance.type = type
    instance.itemName = itemName -- this is so player knows if they have interacted with npc before beyond current maps

    instance.state = "idle"
    instance.idleTime = { current = 0, duration = 3 } -- start idle
    instance.interactable = false
    instance.interacted = false

    -- Animations
    instance.animation = { timer = 0, rate = 0.2 }
    instance.animation.draw = NPC.animAssets[instance.type].idle.img[1]

    -- Physics
    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true) -- prevents collisions but can be sensed
    instance.physics.fixture:setCategory(Categories.interactable)
    instance.physics.fixture:setUserData("npc")

    -- dialogue
    instance.interactText = Anima.new(instance.physics.fixture, Dialogue[instance.type].message, "above")
    instance.defaultNPCInteractText = tostring(instance.interactText.text)
    instance.dialogue = Dialogue[instance.type].sequence
    instance.dialogueIndex = 1
    instance.dialogueGrace = { time = 2, duration = 2 }

    table.insert(ActiveNPCs, instance)
    return instance
end

function NPC.loadAssets()
    NPC.animAssets = {}

    -- princess
    NPC.animAssets.princess = {}
    NPC.animAssets.princess.idle = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, 4 do
        NPC.animAssets.princess.idle.img[i] = love.graphics.newImage("assets/princess/idle/" .. i .. ".png")
    end

    -- nicoRobin
    NPC.animAssets.nicoRobin = {}
    NPC.animAssets.nicoRobin.idle = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, 6 do
        NPC.animAssets.nicoRobin.idle.img[i] = love.graphics.newImage("assets/nicoRobin/idle/" .. i .. ".png")
    end

    NPC.animAssets.nicoRobin.sittingDown = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, 4 do
        NPC.animAssets.nicoRobin.sittingDown.img[i] = love.graphics.newImage("assets/nicoRobin/sittingDown/" ..
        i .. ".png")
    end

    NPC.animAssets.nicoRobin.reading = {
        total = 50,
        current = 1,
        img = {}
    }
    for i = 1, 50 do
        local current, stillFrame, lastFrame = i, 1, 4
        if current > lastFrame then
            current = stillFrame
        end
        NPC.animAssets.nicoRobin.reading.img[i] = love.graphics.newImage("assets/nicoRobin/reading/" .. current .. ".png")
    end

    -- soldier
    NPC.animAssets.soldier = {}
    NPC.animAssets.soldier.idle = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, 4 do
        NPC.animAssets.soldier.idle.img[i] = love.graphics.newImage("assets/soldier/idle/" .. i .. ".png")
    end

    NPC.animAssets.soldier.wave = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, 4 do
        NPC.animAssets.soldier.wave.img[i] = love.graphics.newImage("assets/soldier/wave/" .. i .. ".png")
    end

    NPC.width = NPC.animAssets.princess.idle.img[1]:getWidth()
    NPC.height = NPC.animAssets.princess.idle.img[1]:getHeight()
end

function NPC.removeAll()
    for _, v in ipairs(ActiveNPCs) do
        v.physics.body:destroy()
        Anima.remove(v.physics.fixture)
    end

    ActiveNPCs = {}
end

function NPC:removeActive()
    for i, instance in ipairs(ActiveNPCs) do
        if instance == self then
            table.remove(ActiveNPCs, i)
            instance.physics.body:destroy()
            Anima.remove(instance.physics.fixture)
            break
        end
    end
end

function NPC:setState(dt)
    if self.type == "nicoRobin" then
        self:setNicoRobinState(dt)
    elseif self.type == "soldier" then
        self:setSoldierState()
    end
end

function NPC:setNicoRobinState(dt)
    if self.state == "idle" then
        self.idleTime.current = self.idleTime.current + dt
        if self.idleTime.current >= self.idleTime.duration then
            self.state = "sittingDown"
        end
    elseif self.state == "sittingDown"
        and NPC.animAssets.nicoRobin.sittingDown.current >= NPC.animAssets.nicoRobin.sittingDown.total then
        self.state = "reading"
    end
end

function NPC:setSoldierState()
    if self.interactable and not self.interacted then
        self.interacted = true
        self.state = "wave"
    end
end

function NPC:update(dt)
    self:setState(dt)
    self:animate(dt)
    self:runDialogue(dt)
end

function NPC:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

-- updates the image
function NPC:setNewFrame()
    local anim = NPC.animAssets[self.type][self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function NPC:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function NPC.updateAll(dt)
    for i, instance in ipairs(ActiveNPCs) do
        instance:update(dt)
    end
end

function NPC:runDialogue(dt)
    if self.interactable and Player.talking and not Anima.currentlyAnimating() then
        self:updateDialogueGrace(dt)
    end
end

function NPC:updateDialogueGrace(dt)
    if self.dialogueGrace.time == self.dialogueGrace.duration then
        self:updateDialogue()
    end
    self.dialogueGrace.time = self.dialogueGrace.time - dt
    if self.dialogueGrace.time <= 0 then
        self.dialogueGrace.time = self.dialogueGrace.duration
    end
end

function NPC:updateDialogue()
    local playerAnima = Player.interactText
    local npcAnima = self.interactText
    playerAnima:modifyAnimationRate(0.1)

    self:playDialogue(playerAnima, npcAnima)
end

function NPC:playDialogue(playerAnima, npcAnima)
    if self.dialogueIndex <= #self.dialogue then
        print(self.dialogue[self.dialogueIndex][2])
        if self.dialogue[self.dialogueIndex][1] == self.type then
            npcAnima:newTypingAnimation(self.dialogue[self.dialogueIndex][2])
        elseif self.dialogue[self.dialogueIndex][1] == "Player" then
            playerAnima:newTypingAnimation(self.dialogue[self.dialogueIndex][2])
        end
        self.dialogueIndex = self.dialogueIndex + 1

        if self.dialogueIndex > #self.dialogue then
            self.dialogueIndex = 1
            playerAnima:modifyAnimationRate(0)
            playerAnima:newTypingAnimation(Player.defaultInteractText)
            npcAnima:newTypingAnimation(self.defaultNPCInteractText)
            Player.talking = false
            self.dialogueGrace.time = 0
            self:dialogueEndEffects()
        end
    end
end

function NPC:dialogueStartEffects()
    self:soldierStartEffects()
end

function NPC:soldierStartEffects()
    if self.type == "soldier" then
        self.state = "idle"
        if Inventory:check("storyItem", "princessPass") then
            self.dialogue = Dialogue.soldier.sequence2
        end
    end
end

function NPC:dialogueEndEffects()
    self:nicoRobinEndEffects()
    self:princessEndEffects()
    self:soldierEndEffects()
end

function NPC:nicoRobinEndEffects()
    if self.type == "NicoRobin" then
        GUI:goNextLevelIndicatorAnimationStart()
    end
end

function NPC:princessEndEffects()
    if self.type == "princess" then
        self:removeActive()
        -- end the player dialogue animation because endContact is not called on fixture removal
        Player.interactText:animationEnd()
        Ally:load(self.x, self.y, "princess")
        Inventory:add("storyItem", self.itemName)
    end
end

function NPC:soldierEndEffects()
    if self.type == "soldier" then
        GUI:goNextLevelIndicatorAnimationStart()
        Inventory:add("storyItem", self.itemName)
    end
end

function NPC.keypressed(key)
    if NPC.interact(key)
        or NPC.skipDialogue(key) then
        return true
    end
    return false
end

function NPC.interact(key)
    if not Player:doingAction() and key == "e" then
        for _, instance in ipairs(ActiveNPCs) do
            if instance.interactable then
                instance:dialogueStartEffects()
                Player.talking = true
                Player.interactText:newTypingAnimation("")
                Player:setPosition(instance.x - instance.width / 2 + 5, instance.y - Player.offsetY)
                Player.xVel = 0
                Player.direction = "right"
                Player:cancelActiveActions()
                return true
            end
        end
    end
end

function NPC.skipDialogue(key)
    if key == "e" and Player.talking then
        for _, instance in ipairs(ActiveNPCs) do
            if instance.interactable then
                print("skipped")
                instance:playDialogue(Player.interactText, instance.interactText)
                return true
            end
        end
    end
end

function NPC.drawAll()
    for i, instance in ipairs(ActiveNPCs) do
        instance:draw()
    end
end

function NPC.beginContact(a, b, collision)
    if Helper.checkFUD(a, b, "player") and Helper.checkFUD(a, b, "npc") then
        for i, instance in ipairs(ActiveNPCs) do
            if a == instance.physics.fixture or b == instance.physics.fixture then
                if a == Player.physics.fixture or b == Player.physics.fixture then
                    instance.interactable = true
                    instance.interactText:animationStart()
                    Player.interactText:animationStart()
                    return true
                end
            end
        end
    end
end

function NPC.endContact(a, b, collision)
    for i, instance in ipairs(ActiveNPCs) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.interactable = false
                instance.interactText:animationEnd()
                Player.interactText:animationEnd()
                return true
            end
        end
    end
end

return NPC
