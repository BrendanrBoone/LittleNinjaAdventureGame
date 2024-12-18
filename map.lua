local Map = {}
local STI = require("sti")
local Player = require("player")
local Sounds = require("sounds")
local Hitbox = require("hitbox")
local Portal = require("portal")
local BackgroundObject = require("backgroundObject")
local ForegroundObject = require("foregroundObject")
local PickupItem = require("pickupItem")
local NPC = require("npc")
local Categories = require("categories")
local Ally = require("ally")
local ScreenTransition = require("screenTransition")
local Inventory = require("inventory")

local oceanHighBackground = love.graphics.newImage("assets/oceanBackground.png")
local skyBlueBackground = love.graphics.newImage("assets/background.png")
local redBackground = love.graphics.newImage("assets/redBackground.png")
local blackBackground = love.graphics.newImage("assets/blackBackground.jpg")
local desertBackground = love.graphics.newImage("assets/desertBackground.png")
local desertBackground2 = love.graphics.newImage("assets/desertBackground2.png")
local desertBackground3 = love.graphics.newImage("assets/desertBackground3.png")

function Map:load()
    -- need to make some sort of way to make levels determinable by name
    self.allLevels = {
        level1 = {
            next = nil,
            prev = nil,
            background = desertBackground
        },
        dragonDen = {
            next = nil,
            prev = nil,
            background = blackBackground
        }
    }

    -- store transition variables so it can be desynced
    self.transitionDesync = {
        destination = nil,
        dX = nil,
        dY = nil
    }

    World = love.physics.newWorld(0, 2000)
    World:setCallbacks(beginContact, endContact)

    self:init("level1")
end

function Map:init(destination)
    self.currentLevel = destination
    self.level = STI("map/" .. destination .. ".lua", { "box2d" })
    self.level:box2d_init(World)

    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entityLayer = self.level.layers.entity
    self.spawnsLayer = self.level.layers.spawns

    self:setGroundFixtures()

    self.solidLayer.visible = false
    self.entityLayer.visible = false
    self.spawnsLayer.visible = false
    MapWidth = self.groundLayer.width * 16 -- 16 is the tile size
    MapHeight = self.groundLayer.height * 16

    self:findSpawnPoints()
    self:spawnEntities()
    self:loadBgm()
    self:checkBgo()
end

-- set the solid layer fixtures to the ground category because using the masking system
-- requires every fixture to have a category
function Map:setGroundFixtures()
    local collision = self.level.box2d_collision
    for i = #collision, 1, -1 do
        local obj = collision[i]
        if obj.object.layer == self.solidLayer then
            obj.fixture:setCategory(Categories.ground)
        end
    end
end

function Map:checkBgo()
    if self.level.layers.backgroundObjects then
        self.bgoLayer = self.level.layers.backgroundObjects
        self.bgoLayer.visible = false
        self:spawnBgo()
    end
end

-- change background according to what level
function Map:drawBackground()
    local background = self.allLevels[self.currentLevel].background
    love.graphics.draw(background)
end

function Map:loadBgm()
    Sounds:playMusic(self.currentLevel)
end

function Map:spawnBgo()
    for _, v in ipairs(self.bgoLayer.objects) do
        BackgroundObject.new(v.type, v.properties.level, v.x, v.y, v.width, v.height)
    end
end

function Map:findSpawnPoints()
    for _, v in ipairs(self.spawnsLayer.objects) do
        if v.type == "end" then
            self.endX, self.endY = v.x, v.y
        elseif v.type == "start" then
            self.startX, self.startY = v.x, v.y
        end
    end
end

function Map:toDestination(destination, dX, dY)
    self:clean()
    self:init(destination)
    print(dX .. " " .. dY)
    Map.loadPlayer(dX, dY) -- go to portal coordinates
    if ScreenTransition.state == "black" then
        ScreenTransition:open()
    end
end

function Map:next()
    local nextLevel = self.allLevels[self.currentLevel].next
    if nextLevel then
        self:clean()
        self:init(nextLevel)
        self.loadPlayer(self.startX, self.startY)
    end
end

function Map:prev()
    local prevLevel = self.allLevels[self.currentLevel].prev
    if prevLevel then
        self:clean()
        self:init(prevLevel)
        self.loadPlayer(self.endX, self.endY)
    end
end

function Map.loadPlayer(x, y)
    Player:setPosition(x, y)
    --Hitbox.loadAllTargets(ActiveEnemys)
end

function Map:clean()
    self.level:box2d_removeLayer("solid")
    Portal.removeAll()
    NPC.removeAll()
    BackgroundObject.removeAll()
    PickupItem.removeAll()
end

function Map:update(dt)
    self:swapLevel()
    self:levelTransitionDesync()
end

function Map:levelTransitionDesync()
    if ScreenTransition.state == "black" then
        Map:toDestination(
            self.transitionDesync.destination,
            self.transitionDesync.dX,
            self.transitionDesync.dY - Player.offsetY
        )
        if Ally.alive then
            Ally:teleportToPlayer()
        end
    end
end

-- conditions to swap level
function Map:swapLevel()
    if Player.x > MapWidth - 16 then
        self:next()
    elseif Player.x < 0 + 16 then
        self:prev()
    end
end

function Map:spawnEntities()
    for _, v in ipairs(self.entityLayer.objects) do
        -- NPCs can only spawn when you don't have their storyItem and have all prerequisite story items
        if v.type == "npc" and
            not Inventory:check("storyItem", v.properties.storyItemName) and
            Inventory:check("storyItem", v.properties.prerequisiteStoryItem) then
            NPC.new(v.x + v.width / 2, v.y + v.height / 2, v.properties.type, v.properties.storyItemName)
        elseif v.type == "portal" then
            Portal.new(v.x + v.width / 2, v.y + v.height / 2, v.properties.destination, v.properties.dX, v.properties.dY,
            v.properties.lock, v.properties.displayText)
        elseif v.type == "pickupItem" then
            PickupItem.new(v.x + v.width / 2, v.y + v.height / 2, v.properties.itemType)
        elseif v.type == "backgroundObject" then
            BackgroundObject.new(v.properties.type, v.properties.anim, v.properties.level, v.x, v.y, v.width, v.height)
        elseif v.type == "foregroundObject" then
            ForegroundObject.new(v.properties.type, v.properties.anim, v.properties.level, v.x, v.y, v.width, v.height)
        end
    end
end

function Map:moveThroughPortal(key)
    if key == "e" then
        for _, instance in ipairs(ActivePortals) do
            if instance.destinationVisual and instance:checkLock() then
                --transition Desync
                ScreenTransition:close()
                self.transitionDesync.destination = instance.destination
                self.transitionDesync.dX = instance.dX
                self.transitionDesync.dY = instance.dY
                return true
            end
        end
    end
end

return Map
