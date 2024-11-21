local GUI = {}
local Player = require("player")
local Sounds = require("sounds")

function GUI:load()
    self.coins = {}
    self.coins.img = love.graphics.newImage("assets/coin.png")
    self.coins.width = self.coins.img:getWidth()
    self.coins.height = self.coins.img:getHeight()
    self.coins.scale = 3
    self.coins.x = love.graphics.getWidth() - 200
    self.coins.y = 50

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

    self.staminaBar = {
        x = self.hearts.spacing,
        y = self.hearts.y * 2 + self.hearts.height
    }
    self.staminaBar.height = 30

    self.goNextLevelIndicator = {}
    self.goNextLevelIndicator.img = love.graphics.newImage("assets/ui/rightArrow.png")
    self.goNextLevelIndicator.y = (self.coins.y + self.coins.height) * 2
    self.goNextLevelIndicator.x = self.coins.x - self.goNextLevelIndicator.img:getWidth() / 2
    self.goNextLevelIndicator.visible = false
    self.goNextLevelIndicator.animating = false
    self.grace = {
        time = 100,
        duration = 1,
        totalDuration = 200
    }

    self.font = love.graphics.newFont("assets/ui/bit.ttf", 36)
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

function GUI:update(dt)
    GUI:arrowAnimation(dt)
end

function GUI:draw()
    GUI:displayStaminaBar()
    GUI:displayCoins()
    GUI:displayCoinText()
    GUI:displayHearts()
    GUI:displayVolume()
    GUI:displayArrowIndicator()
end

function GUI:arrowAnimation(dt)
    if self.goNextLevelIndicator.animating then
        self.grace.time = self.grace.time - 1
        print("time: " .. self.grace.time)
        print("modulus: "..self.grace.time % 2)
        if self.grace.time % 2 == 0 then
            self.goNextLevelIndicator.visible = not self.goNextLevelIndicator.visible
            print(tostring(self.goNextLevelIndicator.visible))
        end
        if self.grace.time <= 0 then
            self.grace.time = self.grace.totalDuration
            self.goNextLevelIndicator.animating = false
        end
    end
end

function GUI:displayArrowIndicator()
    if self.goNextLevelIndicator.visible then
        love.graphics.draw(self.goNextLevelIndicator.img, self.goNextLevelIndicator.x, self.goNextLevelIndicator.y, 0,
            1, 1)
    end
end

function GUI:displayStaminaBar()
    love.graphics.setColor(0, 1, 0)
    love.graphics
        .rectangle("fill", self.staminaBar.x, self.staminaBar.y, Player.stamina.current, self.staminaBar.height)
end

function GUI:displayVolume()
    love.graphics.draw(self.volume.img, self.volume.x, self.volume.y, 0, self.volume.scale, self.volume.scale)
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

function GUI:displayCoins()
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.draw(self.coins.img, self.coins.x + 2, self.coins.y + 2, 0, self.coins.scale, self.coins.scale)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.coins.img, self.coins.x, self.coins.y, 0, self.coins.scale, self.coins.scale)
end

function GUI:displayCoinText()
    love.graphics.setFont(self.font)
    local x = self.coins.x + self.coins.width * self.coins.scale
    local y = self.coins.y + self.coins.height / 2 * self.coins.scale - self.font:getHeight() / 2
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.print(" : " .. Player.coins, x + 2, y + 2) -- shadow
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(" : " .. Player.coins, x, y)
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
