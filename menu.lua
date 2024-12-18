local Menu = {}

local Colors = require("colors")
local Helper = require("helper")

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

    self.inventoryBox = {}
    self.inventoryBox.width = self.exitButton.width * 3
    self.inventoryBox.height = self.exitButton.height * 2
    self.inventoryBox.x = self.exitButton.x + self.exitButton.width / 2 - self.inventoryBox.width / 2
    self.inventoryBox.y = self.exitButton.y + self.exitButton.height + 10

    self.inventoryBox.storyItemsTab = {}
    self.inventoryBox.storyItemsTab.color = Colors.red
    self.inventoryBox.storyItemsTab.x = self.inventoryBox.x
    self.inventoryBox.storyItemsTab.y = self.inventoryBox.y
    self.inventoryBox.storyItemsTab.width = self.inventoryBox.width / 3
    self.inventoryBox.storyItemsTab.height = self.inventoryBox.height / 6
    
end

function Menu:update(dt)

end

function Menu:draw()
    if self.paused then
        self:displayScreenTint()
        self:displayPauseTitle()
        self:displayExitButton()
        self:displayInventoryBox()
        Helper.resetDrawSettings()
    end
end

function Menu:displayInventoryBox()
    love.graphics.setColor(Colors.gray[1], Colors.gray[2], Colors.gray[3], 0.5)
    love.graphics.rectangle("fill", self.inventoryBox.x, self.inventoryBox.y, self.inventoryBox.width, self.inventoryBox.height)
    self:displayStoryItemTab()
end

function Menu:displayStoryItemTab()
    local color = self.inventoryBox.storyItemsTab.color
    local tab = self.inventoryBox.storyItemsTab
    love.graphics.setColor(color[1], color[2], color[3], 0.5)
    love.graphics.rectangle("fill", tab.x, tab.y, tab.width, tab.height)
end

function Menu:displayScreenTint()
    love.graphics.draw(self.screenTint.img, self.screenTint.x, self.screenTint.y, 0, 1, 1)
end

function Menu:displayPauseTitle()
    love.graphics.setFont(self.font)
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
        if button == 1 then
            self:exitButtonPressed(mx, my)
        end
    end
end

function Menu:exitButtonPressed(mx, my)
    if mx >= self.exitButton.x and mx < self.exitButton.x + self.exitButton.width
    and my >= self.exitButton.y and my < self.exitButton.y + self.exitButton.height then
        self.quit()
    end
end

return Menu
