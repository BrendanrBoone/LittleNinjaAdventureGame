local Map = {}
local STI = require("sti")
local Enemy = require("enemy")
local Spike = require("spike")
local Stone = require("stone")
local Coin = require("coin")
local Player = require("player")
local Trampoline = require("trampoline")
local Sounds = require("sounds")
local Hitbox = require("hitbox")
local NicoRobin = require("nicoRobin")
local Portal = require("portal")
local Anima = require("myTextAnima")
local BackgroundObject = require("backgroundObject")
local PickupItem = require("pickupItem")
local Sunny = require("sunny")
local Platform = require("platform")

local oceanHighBackground = love.graphics.newImage("assets/oceanBackground.png")
local skyBlueBackground = love.graphics.newImage("assets/background.png")
local redBackground = love.graphics.newImage("assets/redBackground.png")

function Map:load()
    self.backgroundLevels = { -- self.background["levelname"] == background for that level
        levelTutorial = oceanHighBackground,
        level2 = skyBlueBackground,
        level3 = skyBlueBackground,
        level4 = oceanHighBackground,
        levelLighthouse = skyBlueBackground
    }

    -- need to make some sort of way to make levels determinable by name
    self.allLevels = {
        levelPreTutorial = {
            next = "levelTutorial",
            prev = nil,
            background = oceanHighBackground
        },
        levelTutorial = {
            next = "level2",
            prev = "levelPreTutorial",
            background = oceanHighBackground
        },
        level2 = {
            next = "level3",
            prev = "levelTutorial",
            background = oceanHighBackground
        },
        level3 = {
            next = "level4",
            prev = "level2",
            background = oceanHighBackground
        },
        level4 = {
            next = nil,
            prev = "level3",
            background = oceanHighBackground
        },
        levelLighthouse = {
            next = nil,
            prev = nil,
            background = redBackground
        },
        levelLighthouse2 = {
            next = nil,
            prev = nil,
            background = redBackground
        }
    }

    World = love.physics.newWorld(0, 2000)
    World:setCallbacks(beginContact, endContact, preSolve)

    self:init("levelLighthouse2")
end

function Map:init(destination)
    self.currentLevel = destination
    self.level = STI("map/" .. destination .. ".lua", {"box2d"})
    self.level:box2d_init(World)
    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entityLayer = self.level.layers.entity
    self.spawnsLayer = self.level.layers.spawns
    if self.level.layers.backgroundObjects then
        self.bgoLayer = self.level.layers.backgroundObjects
        self.bgoLayer.visible = false
        self:spawnBgo()
    end

    self.solidLayer.visible = false
    self.entityLayer.visible = false
    self.spawnsLayer.visible = false
    MapWidth = self.groundLayer.width * 16 -- 16 is the tile size
    MapHeight = self.groundLayer.height * 16

    self:findSpawnPoints()
    self:spawnEntities()
    self:loadBgm()
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
    Hitbox.loadAllTargets(ActiveEnemys)
end

function Map:clean()
    self.level:box2d_removeLayer("solid")
    Coin.removeAll()
    Spike.removeAll()
    Stone.removeAll()
    Enemy.removeAll()
    NicoRobin.removeAll()
    Sunny.removeAll()
    Portal.removeAll()
    Trampoline.removeAll()
    BackgroundObject.removeAll()
end

function Map:update(dt)
    -- conditions to swap level
    if Player.x > MapWidth - 16 then
        self:next()
    elseif Player.x < 0 + 16 then
        self:prev()
    end
end

function Map:spawnEntities()
    for _, v in ipairs(self.entityLayer.objects) do
        if v.type == "spike" then
            Spike.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "coin" then
            Coin.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "stone" then
            Stone.new(v.x, v.y)
        elseif v.type == "enemy" then
            Enemy.new(v.x, v.y)
        elseif v.type == "trampoline" then
            Trampoline.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "nicoRobin" then
            NicoRobin.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "portal" then
            Portal.new(v.x + v.width / 2, v.y + v.height / 2, v.properties.destination, v.properties.dX, v.properties.dY)
        elseif v.type == "pickupItem" then
            PickupItem.new(v.x + v.width / 2, v.y + v.height / 2, v.properties.itemType)
        elseif v.type == "sunny" then
            Sunny.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "platform" then
            Platform.new(v.x + v.width / 2, v.y + v.height / 2, v.width, v.height)
        end
    end
end

function Map.moveThroughPortal(key)
    if key == "e" then
        for _, instance in ipairs(ActivePortals) do
            if instance.destinationVisual then
                Map:toDestination(instance.destination, instance.dX, instance.dY)
                return true
            end
        end
    end
end

return Map
