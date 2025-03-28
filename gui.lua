local GUI = {}
local Player = require("player")
local Sounds = require("sounds")
local Colors = require("colors")

function GUI:load()
    self.hearts = {}
    self.hearts.x = 0
    self.hearts.y = 30
    self.hearts.scale = 3

    self:loadAssets()

    self.volume = {}
    self.volume.img_soundOn = love.graphics.newImage("assets/ui/volumeIcon48x48.png")
    self.volume.img_soundOff = love.graphics.newImage("assets/ui/volumeIconMute48x48.png")
    if Sounds.soundToggle then
        self.volume.img = self.volume.img_soundOn
    else
        self.volume.img = self.volume.img_soundOff
    end
    self.volume.width = self.volume.img:getWidth()
    self.volume.height = self.volume.img:getHeight()
    self.volume.x = 30
    self.volume.y = love.graphics.getHeight() - self.volume.height - 20
    self.volume.scale = 1

    self.chakraBar = {
        x = self.hearts.spacing,
        y = self.hearts.y * 2 + self.hearts.height
    }
    self.chakraBar.height = 30

    self.goNextLevelIndicator = {}
    self.goNextLevelIndicator.img = love.graphics.newImage("assets/ui/rightArrow.png")
    self.goNextLevelIndicator.y = (50 + 100) * 2
    self.goNextLevelIndicator.x = love.graphics.getWidth() - 200 - self.goNextLevelIndicator.img:getWidth() / 2
    self.goNextLevelIndicator.visible = false
    self.goNextLevelIndicator.animating = false
    self.grace = {
        time = 100,
        duration = 1,
        totalDuration = 200
    }

    self.font = love.graphics.newFont("assets/ui/bit.ttf", 36)

    self.sealDisplay = {}
    self.sealDisplay.x = love.graphics.getWidth() / 2
    self.sealDisplay.y = 100
    self.sealDisplay.fireSealImg = love.graphics.newImage("assets/fireSeal/3.png")
    self.sealDisplay.scrollLImg = love.graphics.newImage("assets/ui/Scroll/cut/scrollL.png")
    self.sealDisplay.scrollRImg = love.graphics.newImage("assets/ui/Scroll/cut/scrollR.png")
    self.sealDisplay.scrollMImg = love.graphics.newImage("assets/ui/Scroll/cut/scrollM.png")
end

function GUI:loadAssets()
    self.hearts.img = {}
    for i = 1, 4 do
        self.hearts.img[i] = love.graphics.newImage("assets/Heart/heart/" .. i .. ".png")
    end
    self.hearts.width = self.hearts.img[1]:getWidth()
    self.hearts.height = self.hearts.img[1]:getHeight()
    self.hearts.spacing = self.hearts.width * self.hearts.scale + 30
end

function GUI:goNextLevelIndicatorAnimationStart()
    self.goNextLevelIndicator.animating = true
    self.grace.time = self.grace.totalDuration
end

function GUI:update(dt)
    GUI:arrowAnimation(dt)
end

function GUI:draw()
    GUI:displaychakraBar()
    GUI:displayHearts()
    GUI:displayVolume()
    GUI:displaySeals()
    GUI:displayArrowIndicator()
end

function GUI:arrowAnimation(dt)
    if self.goNextLevelIndicator.animating then
        self.grace.time = self.grace.time - 1
        --print("time: " .. self.grace.time)
        --print("modulus: " .. self.grace.time % 2)
        if self.grace.time % 2 == 0 then
            self.goNextLevelIndicator.visible = not self.goNextLevelIndicator.visible
            --print(tostring(self.goNextLevelIndicator.visible))
        end
        if self.grace.time <= 0 then
            self.goNextLevelIndicator.animating = false
        end
    end
end

function GUI:displayArrowIndicator()
    if self.goNextLevelIndicator.visible then
        love.graphics.draw(self.goNextLevelIndicator.img, self.goNextLevelIndicator.x, self.goNextLevelIndicator.y, 0, 1,
        1)
    end
end

function GUI:displaychakraBar()
    love.graphics.setColor(Colors.chakra)
    love.graphics.rectangle("fill", self.chakraBar.x, self.chakraBar.y, Player.chakra.current, self.chakraBar.height)
end

function GUI:displayVolume()
    love.graphics.draw(self.volume.img, self.volume.x, self.volume.y, 0, self.volume.scale, self.volume.scale)
end

function GUI:displaySeals()
    local L = self.sealDisplay.scrollLImg
    local M = self.sealDisplay.scrollMImg
    local R = self.sealDisplay.scrollRImg
    local sealsNum = Player.sealSequence.current
    love.graphics.draw(L, self.sealDisplay.x - L:getWidth() - sealsNum * M:getWidth() / 2, self.sealDisplay.y, 0, 1, 1)
    for i=1,sealsNum do
        local sealImg = love.graphics.newImage("assets/"..Player.sealSequence.sequence[i].."/3.png")
        love.graphics.draw(M, self.sealDisplay.x - sealsNum * M:getWidth() / 2 + (i - 1) * M:getWidth(), self.sealDisplay.y, 0, 1, 1)
        love.graphics.draw(sealImg, self.sealDisplay.x - sealsNum * M:getWidth() / 2 + (i - 1) * M:getWidth() + (M:getWidth() / 2 - sealImg:getWidth() / 2), self.sealDisplay.y, 0, 1, 1)
    end
    love.graphics.draw(R, self.sealDisplay.x + sealsNum * M:getWidth() / 2, self.sealDisplay.y, 0, 1, 1)
end

function GUI:displayHearts()
    local fullHearts = math.floor(Player.health.current / 4)
    local partialHearts = Player.health.current % 4
    for i = 1, fullHearts + 1 do
        if i == fullHearts + 1 then
            if partialHearts == 0 then
                break
            end
            local x = self.hearts.x + self.hearts.spacing * i
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.draw(self.hearts.img[partialHearts], x + 2, self.hearts.y + 2, 0, self.hearts.scale,
                self.hearts.scale)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics
                .draw(self.hearts.img[partialHearts], x, self.hearts.y, 0, self.hearts.scale, self.hearts.scale)
        else
            local x = self.hearts.x + self.hearts.spacing * i
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.draw(self.hearts.img[4], x + 2, self.hearts.y + 2, 0, self.hearts.scale, self.hearts.scale)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(self.hearts.img[4], x, self.hearts.y, 0, self.hearts.scale, self.hearts.scale)
        end
    end
end

function GUI:mousepressed(mx, my, button)
    if button == 1 and mx >= self.volume.x and mx < self.volume.x + self.volume.width and my >= self.volume.y and my <
        self.volume.y + self.volume.height then
        if Sounds.soundToggle then
            Sounds.soundToggle = false
            self.volume.img = self.volume.img_soundOff
            Sounds:muteSound(Sounds.currentlyPlayingBgm.source)
        else
            Sounds.soundToggle = true
            self.volume.img = self.volume.img_soundOn
            Sounds:maxSound(Sounds.currentlyPlayingBgm.source)
        end
    end
end

return GUI
