local NPC = {}
NPC.__index = NPC

ActiveNPCs = {}
local Player = require("player")
local Anima = require("myTextAnima")
local Dialogue = require("dialogue")
local GUI = require("gui")
local Helper = require("helper")
local Categories = require("categories")

--@param type: string "princess" or "nicoRobin"
function NPC.new(x, y, type)
    local instance = setmetatable({}, NPC)

    instance.x = x
    instance.y = y
    instance.type = type

    instance.state = "idle"
    instance.idleTime = { current = 0, duration = 3} -- robin

    -- Animations
    instance.animation = { timer = 0, rate = 0.2 }
    instance.animation.npc = { total = 4, current = 1, img = NPC.princessAnim } -- change this to princess later
    instance:updateAnimationImgType() -- remove this later
    instance.animation.draw = instance.animation.npc.img[1]

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
    NPC.princessAnim = {}
    for i = 1, 4 do
        NPC.princessAnim[i] = love.graphics.newImage("assets/princess/idle/" .. i .. ".png")
    end

    NPC.width = NPC.princessAnim[1]:getWidth()
    NPC.height = NPC.princessAnim[1]:getHeight()
end

-- changes the animation image based on the NPC type, necessary for NPCs that have different animations
function NPC:updateAnimationImgType()
    if self.type == "princess" then
        self.animation.npc.total = 4
        self.animation.npc.img = NPC.princessAnim
    end
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
    if self.type == "NicoRobin" then
        self:setNicoRobinState(dt)
    end
end

function NPC:setNicoRobinState(dt)
    if self.state == "idle" then
        self.idleTime.current = self.idleTime.current + dt
        if self.idleTime.current >= self.idleTime.duration then
            self.state = "sittingDown"
        end
    elseif self.state == "sittingDown"
    and self.animation.sittingDown.current >= self.animation.sittingDown.total then
        self.state = "reading"
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
    local anim = self.animation.npc
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

    if self.dialogue[self.dialogueIndex][1] == self.type then
        npcAnima:newTypingAnimation(self.dialogue[self.dialogueIndex][2])
    elseif self.dialogue[self.dialogueIndex][1] == "Player" then
        playerAnima:newTypingAnimation(self.dialogue[self.dialogueIndex][2])
    end
    print(self.dialogue[self.dialogueIndex][2])
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

function NPC:dialogueEndEffects()
    self:nicoRobinEndEffects()
    self:princessEndEffects()
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
    end
end

function NPC.interact(key)
    if not Player:doingAction() and key == "e" then
        for _, instance in ipairs(ActiveNPCs) do
            if instance.interactable then
                Player.talking = true
                Player.interactText:newTypingAnimation("")
                Player:setPosition(instance.x - instance.width / 2 + 5, instance.y)
                Player.xVel = 0
                Player.direction = "right"
                Player:cancelActiveActions()
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
