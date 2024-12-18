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
    self.exitButton.y = self.pausedTitle.y + self.font:getHeight("IDK") + 10

    self.screenTint = {}
    self.screenTint.img = love.graphics.newImage("assets/menuTintBack.png")
    self.screenTint.width = self.screenTint.img:getWidth()
    self.screenTint.height = self.screenTint.img:getHeight()
    self.screenTint.x = 0
    self.screenTint.y = 0

    self.inventoryBox = {}
    self.inventoryBox.width = self.exitButton.width * 3
    self.inventoryBox.x = self.exitButton.x + self.exitButton.width / 2 - self.inventoryBox.width / 2
    self.inventoryBox.y = self.exitButton.y + self.exitButton.height + 100
    self.inventoryBox.height = love.graphics.getHeight() - self.inventoryBox.y - 10

    self.inventoryBox.storyItemsTab = {}
    self.inventoryBox.storyItemsTab.color = Colors.red
    self.inventoryBox.storyItemsTab.x = self.inventoryBox.x
    self.inventoryBox.storyItemsTab.y = self.inventoryBox.y
    self.inventoryBox.storyItemsTab.width = self.inventoryBox.width / 3
    self.inventoryBox.storyItemsTab.height = self.inventoryBox.height / 12

    self.inventoryBox.itemsTab = {}
    self.inventoryBox.itemsTab.color = Colors.yellowDim
    self.inventoryBox.itemsTab.x = self.inventoryBox.x + self.inventoryBox.storyItemsTab.width
    self.inventoryBox.itemsTab.y = self.inventoryBox.y
    self.inventoryBox.itemsTab.width = self.inventoryBox.width / 3
    self.inventoryBox.itemsTab.height = self.inventoryBox.height / 12

    self.inventoryBox.scrollsTab = {}
    self.inventoryBox.scrollsTab.color = Colors.orangeDim
    self.inventoryBox.scrollsTab.x = self.inventoryBox.x + self.inventoryBox.storyItemsTab.width * 2
    self.inventoryBox.scrollsTab.y = self.inventoryBox.y
    self.inventoryBox.scrollsTab.width = self.inventoryBox.width / 3
    self.inventoryBox.scrollsTab.height = self.inventoryBox.height / 12
    
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
    self:displayItemsTab()
    self:displayScrollsTab()
end

function Menu:displayStoryItemTab()
    local tab = self.inventoryBox.storyItemsTab
    local color = tab.color
    love.graphics.setColor(color[1], color[2], color[3], 0.5)
    love.graphics.rectangle("fill", tab.x, tab.y, tab.width, tab.height)
end

function Menu:displayItemsTab()
    local tab = self.inventoryBox.itemsTab
    local color = tab.color
    love.graphics.setColor(color[1], color[2], color[3], 0.5)
    love.graphics.rectangle("fill", tab.x, tab.y, tab.width, tab.height)
end

function Menu:displayScrollsTab()
    local tab = self.inventoryBox.scrollsTab
    local color = tab.color
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
            self:exitButtonClicked(mx, my)
            self:storyItemsTabClicked(mx, my)
            self:itemsTabClicked(mx, my)
            self:scrollsTabClicked(mx, my)
        end
    end
end

function Menu:exitButtonClicked(mx, my)
    if mx >= self.exitButton.x and mx < self.exitButton.x + self.exitButton.width
    and my >= self.exitButton.y and my < self.exitButton.y + self.exitButton.height then
        self.quit()
    end
end

function Menu:storyItemsTabClicked(mx, my)
    local tab = self.inventoryBox.storyItemsTab
    if mx >= tab.x and mx < tab.x + tab.width
    and my >= tab.y and my < tab.y + tab.height then
        print("tab clicked")
        tab.color = Colors.red
        self.inventoryBox.itemsTab.color = Colors.yellowDim
        self.inventoryBox.scrollsTab.color = Colors.orangeDim
    end
end

function Menu:itemsTabClicked(mx, my)
    local tab = self.inventoryBox.itemsTab
    if mx >= tab.x and mx < tab.x + tab.width
    and my >= tab.y and my < tab.y + tab.height then
        print("tab clicked")
        tab.color = Colors.yellow
        self.inventoryBox.storyItemsTab.color = Colors.redDim
        self.inventoryBox.scrollsTab.color = Colors.orangeDim
    end
end

function Menu:scrollsTabClicked(mx, my)
    local tab = self.inventoryBox.scrollsTab
    if mx >= tab.x and mx < tab.x + tab.width
    and my >= tab.y and my < tab.y + tab.height then
        print("tab clicked")
        tab.color = Colors.orange
        self.inventoryBox.storyItemsTab.color = Colors.redDim
        self.inventoryBox.itemsTab.color = Colors.yellowDim
    end
end

return Menu
