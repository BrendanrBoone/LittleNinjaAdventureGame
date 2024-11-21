love.graphics.setDefaultFilter("nearest", "nearest") -- only needs to be done because pixel art
local Player = require("player")
local Coin = require("coin")
local GUI = require("gui")
local Spike = require("spike")
local Stone = require("stone")
local Camera = require("camera")
local Enemy = require("enemy")
local Map = require("map")
local Trampoline = require("trampoline")
local Sounds = require("sounds")
local Explosion = require("explosion")
local Menu = require("menu")
local Hitbox = require("hitbox")
local NicoRobin = require("nicoRobin")
local Portal = require("portal")
local Anima = require("myTextAnima")
local BackgroundObject = require("backgroundObject")
local PickupItem = require("pickupItem")
local Sunny = require("sunny")
local Platform = require("platform")

WorldPause = false

function love.load()
    Sounds:load()
    Enemy.loadAssets()
    NicoRobin.loadAssets()
    Portal.loadAssets()
    Map:load()
    GUI:load()
    Player:load()
    Explosion.loadAssets()
    Menu:load()
end

-- menu screen toggle update to pause game
function love.update(dt)
    if not WorldPause then
        World:update(dt)
        Sounds:update(dt)
        Camera:setPosition(Player.x, Player.y)
        Player:update(dt)
        Coin.updateAll()
        Sunny.updateAll()
        PickupItem.updateAll()
        GUI:update(dt)
        Spike.updateAll(dt)
        Stone.updateAll(dt)
        Enemy.updateAll(dt)
        NicoRobin.updateAll(dt)
        Portal.updateAll(dt)
        Platform.updateAll(dt)
        Trampoline.updateAll(dt)
        Explosion.updateAll(dt)
        Map:update(dt)
        Menu:update(dt)
        Hitbox.updateAll(dt)
        Anima.updateAll(dt)
        BackgroundObject.updateAll(dt)
    end
end

function love.draw()
    Map:drawBackground()

    Camera:apply() -- between
    BackgroundObject.drawAll()
    Sunny.drawAll()
    Map.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
    Explosion.drawAll()
    Trampoline.drawAll()
    NicoRobin.drawAll()
    Portal.drawAll()
    Platform.drawAll()
    Player:draw()
    Coin.drawAll()
    PickupItem.drawAll()
    Spike.drawAll()
    Stone.drawAll()
    Enemy.drawAll()
    Hitbox.drawAll()
    Anima.drawAll()
    Camera:clear() -- these

    GUI:draw()
    Menu:draw()
end

function love.keypressed(key)
    if not WorldPause then
        if Map.moveThroughPortal(key) then return end
        if NicoRobin.interact(key) then return end
        Player:jump(key)
        Player:fastFall(key)
        Player:emote(key)
        Player:forwardAir(key)
        Player:forwardAttack(key)
        Player:rushAttack(key)
        Player:dashForward(key)
        --Platform.onPlatform(key)
    end

    Menu:Escape(key)
end

function love.mousepressed(mx, my, button)
    GUI:mousepressed(mx, my, button)
    Menu:mousepressed(mx, my, button)
end

function beginContact(a, b, collision)
    if Coin.beginContact(a, b, collision) then return end
    if PickupItem.beginContact(a, b, collision) then return end
    if Spike.beginContact(a, b, collision) then return end
    if Trampoline.beginContact(a, b, collision) then return end
    if Hitbox.beginContact(a, b, collision) then return end
    if Portal:beginContact(a, b, collision) then return end
    if NicoRobin.beginContact(a, b, collision) then return end
    --Platform.beginContact(a, b, collision)
    Enemy.beginContact(a, b, collision)
    Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    if Hitbox.endContact(a, b, collision) then return end
    if Portal:endContact(a, b, collision) then return end
    if NicoRobin.endContact(a, b, collision) then return end
    --Platform.endContact(a, b, collision)
    Enemy.endContact(a, b, collision)
    Player:endContact(a, b, collision)
end

function preSolve(a, b, collision)
    --Platform.preSolve(a, b, collision)
    Player:preSolve(a, b, collision)
end
