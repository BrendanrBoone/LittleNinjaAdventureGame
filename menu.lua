local Menu = {}

-- Complete after finishing hitboxes

function Menu:load()
    self.paused = false
    self.font = love.graphics.newFont("assets/ui/bit.ttf", 40)

    self.pausedTitle = {}
    self.pausedTitle.x = love.graphics.getWidth() / 2 - 50
    self.pausedTitle.y = 100

    self.exitButton = {}
    self.exitButton.img = love.graphics.newImage("assets/exitIcon.png")
    self.exitButton.width = self.exitButton.img:getWidth()
    self.exitButton.height = self.exitButton.img:getHeight()
    self.exitButton.x = love.graphics.getWidth() / 2 - self.exitButton.width / 2
    self.exitButton.y = love.graphics.getHeight() / 2

    self.screenTint = {}
    self.screenTint.img = love.graphics.newImage("assets/menuTintBack.png")
    self.screenTint.width = self.screenTint.img:getWidth()
    self.screenTint.height = self.screenTint.img:getHeight()
    self.screenTint.x = 0
    self.screenTint.y = 0
end

function Menu:update(dt)

end

function Menu:draw()
    if self.paused then
        self:displayScreenTint()
        self:displayPauseTitle()
        self:displayExitButton()
    end
end

function Menu:displayScreenTint()
    love.graphics.draw(self.screenTint.img, self.screenTint.x, self.screenTint.y, 0, 1, 1)
end

function Menu:displayPauseTitle()
    love.graphics.setFont(self.font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Paused", self.pausedTitle.x, self.pausedTitle.y)
end

function Menu:displayExitButton()
    love.graphics.draw(self.exitButton.img, self.exitButton.x, self.exitButton.y, 0, 1, 1)
end

function Menu.quit()
    love.event.quit()
end

function Menu:Escape(key)
    if key == "escape" then
        if WorldPause then
            WorldPause = false
            self.paused = false
        else
            WorldPause = true
            self.paused = true
        end
    end
end

function Menu:mousepressed(mx, my, button)
    if self.paused then
        if button == 1
            and mx >= self.exitButton.x and mx < self.exitButton.x + self.exitButton.width
            and my >= self.exitButton.y and my < self.exitButton.y + self.exitButton.height then
            self.quit()
        end
    end
end

return Menu
