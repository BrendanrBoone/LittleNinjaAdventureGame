local Menu = {}

local Colors = require("colors")
local Helper = require("helper")
local Inventory = require("inventory")

-- Complete after finishing hitboxes

function Menu:load()
    self.paused = false
    self.font = love.graphics.newFont("assets/ui/bit.ttf", 40)
    self.tabFont = love.graphics.newFont("assets/ui/bit.ttf", 20)

    self.pausedTitle = {}
    self.pausedTitle.x = love.graphics.getWidth() / 2
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
    self.inventoryBox.items = {}   -- {itemData={x=x, y=y, item=item}}
    self.inventoryBox.imgSize = 64 -- height and width because square
    self.inventoryBox.currentInventory = "storyItem"

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

    self.itemFocus = {}
    self.itemFocus.focused = false
    self.itemFocus.displayName = ""
    self.itemFocus.description = ""
    self.itemFocus.displayNameX = self.pausedTitle.x
    self.itemFocus.displayNameY = self.pausedTitle.y
    self.itemFocus.descriptionX = self.pausedTitle.x
    self.itemFocus.descriptionY = self.pausedTitle.y + 100
end

function Menu:update(dt)

end

function Menu:draw()
    if self.paused then
        self:displayScreenTint()
        self:displayPauseTitle()
        self:displayExitButton()
        self:displayInventoryBox()
        self:displayItemFocus()
        Helper.resetDrawSettings()
    end
end

function Menu:displayItemFocus()
    if self.itemFocus.focused then
        self:displayScreenTint()
        local color = Colors.gray
        local displayNameWidth = self.font:getWidth(self.itemFocus.displayName)
        local displayNameX = self.itemFocus.displayNameX - displayNameWidth / 2

        local descriptionWidth = self.tabFont:getWidth(self.itemFocus.description)
        local descriptionHeight = self.tabFont:getHeight(self.itemFocus.description)
        local descriptionX = self.itemFocus.descriptionX - descriptionWidth / 2

        local focusBoxWidth = math.max(displayNameWidth, descriptionWidth)
        local focusBoxHeight = self.itemFocus.descriptionY + descriptionHeight - self.itemFocus.displayNameY
        local focusBoxX = math.min(displayNameX, descriptionX)

        love.graphics.setColor(color[1], color[2], color[3], 1)
        love.graphics.rectangle("fill", focusBoxX, self.itemFocus.displayNameY, focusBoxWidth, focusBoxHeight)

        Helper.resetDrawSettings()
        love.graphics.setFont(self.font)
        love.graphics.print(self.itemFocus.displayName, displayNameX, self.itemFocus.displayNameY)

        love.graphics.setFont(self.tabFont)
        love.graphics.print(self.itemFocus.description, descriptionX, self.itemFocus.descriptionY)
    end
end

function Menu:displayInventoryBox()
    love.graphics.setColor(Colors.gray[1], Colors.gray[2], Colors.gray[3], 0.5)
    love.graphics.rectangle("fill", self.inventoryBox.x, self.inventoryBox.y, self.inventoryBox.width,
        self.inventoryBox.height)
    self:displayStoryItemTab()
    self:displayItemsTab()
    self:displayScrollsTab()

    local currentX = self.inventoryBox.x + 10
    local currentY = self.inventoryBox.y + self.inventoryBox.storyItemsTab.height + 10
    for _, item in ipairs(Inventory[self.inventoryBox.currentInventory]) do
        local img = love.graphics.newImage(item.iconImg)
        local imgSize = self.inventoryBox.imgSize
        local itemData = {}
        if not (currentX + imgSize > self.inventoryBox.x + self.inventoryBox.width) then
            love.graphics.setColor(Colors.gray)
            love.graphics.rectangle("fill", currentX, currentY, imgSize, imgSize)
            Helper.resetDrawSettings()
            love.graphics.draw(img, currentX, currentY, 0, 1, 1)
            itemData.x, itemData.y, itemData.item = currentX, currentY, item
            currentX = currentX + imgSize + 10
        else
            currentX = self.inventoryBox.x + 10
            currentY = currentY + imgSize + 10
            love.graphics.draw(img, currentX, currentY, 0, 1, 1)
            itemData.x, itemData.y, itemData.item = currentX, currentY, item
        end
        table.insert(self.inventoryBox.items, itemData)
    end
end

function Menu:displayStoryItemTab()
    local tab = self.inventoryBox.storyItemsTab
    local color = tab.color
    love.graphics.setColor(color[1], color[2], color[3], 0.5)
    love.graphics.rectangle("fill", tab.x, tab.y, tab.width, tab.height)

    Helper.resetDrawSettings()
    local displayText = "Story Items"
    local textLength = self.tabFont:getWidth(displayText)
    local textHeight = self.tabFont:getHeight(displayText)
    love.graphics.setFont(self.tabFont)
    love.graphics.print(displayText, tab.x + tab.width / 2 - textLength / 2, tab.y + tab.height / 2 - textHeight / 2)
end

function Menu:displayItemsTab()
    local tab = self.inventoryBox.itemsTab
    local color = tab.color
    love.graphics.setColor(color[1], color[2], color[3], 0.5)
    love.graphics.rectangle("fill", tab.x, tab.y, tab.width, tab.height)

    Helper.resetDrawSettings()
    local displayText = "Items"
    local textLength = self.tabFont:getWidth(displayText)
    local textHeight = self.tabFont:getHeight(displayText)
    love.graphics.setFont(self.tabFont)
    love.graphics.print(displayText, tab.x + tab.width / 2 - textLength / 2, tab.y + tab.height / 2 - textHeight / 2)
end

function Menu:displayScrollsTab()
    local tab = self.inventoryBox.scrollsTab
    local color = tab.color
    love.graphics.setColor(color[1], color[2], color[3], 0.5)
    love.graphics.rectangle("fill", tab.x, tab.y, tab.width, tab.height)

    Helper.resetDrawSettings()
    local displayText = "Scrolls"
    local textLength = self.tabFont:getWidth(displayText)
    local textHeight = self.tabFont:getHeight(displayText)
    love.graphics.setFont(self.tabFont)
    love.graphics.print(displayText, tab.x + tab.width / 2 - textLength / 2, tab.y + tab.height / 2 - textHeight / 2)
end

function Menu:displayScreenTint()
    love.graphics.draw(self.screenTint.img, self.screenTint.x, self.screenTint.y, 0, 1, 1)
end

function Menu:displayPauseTitle()
    local x = self.pausedTitle.x - self.font:getWidth("Paused")/2
    love.graphics.setFont(self.font)
    love.graphics.print("Paused", x, self.pausedTitle.y)
end

function Menu:displayExitButton()
    love.graphics.draw(self.exitButton.img, self.exitButton.x, self.exitButton.y, 0, 1, 1)
end

function Menu.quit()
    love.event.quit()
end

function Menu:Escape(key)
    if key == "escape" then
        if self.itemFocus.focused then
            self.itemFocus.focused = false
            return
        end
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
            if self:exitFocus() then return end
            if self:exitButtonClicked(mx, my) then return end
            if self:storyItemsTabClicked(mx, my) then return end
            if self:itemsTabClicked(mx, my) then return end
            if self:scrollsTabClicked(mx, my) then return end
            if self:itemClicked(mx, my) then return end
        end
    end
end

function Menu:exitButtonClicked(mx, my)
    if mx >= self.exitButton.x and mx < self.exitButton.x + self.exitButton.width
        and my >= self.exitButton.y and my < self.exitButton.y + self.exitButton.height then
        self.quit()
        return true
    end
end

function Menu:storyItemsTabClicked(mx, my)
    local tab = self.inventoryBox.storyItemsTab
    if mx >= tab.x and mx < tab.x + tab.width
        and my >= tab.y and my < tab.y + tab.height then
        tab.color = Colors.red
        self.inventoryBox.itemsTab.color = Colors.yellowDim
        self.inventoryBox.scrollsTab.color = Colors.orangeDim
        self.inventoryBox.currentInventory = "storyItem"
        return true
    end
end

function Menu:itemsTabClicked(mx, my)
    local tab = self.inventoryBox.itemsTab
    if mx >= tab.x and mx < tab.x + tab.width
        and my >= tab.y and my < tab.y + tab.height then
        tab.color = Colors.yellow
        self.inventoryBox.storyItemsTab.color = Colors.redDim
        self.inventoryBox.scrollsTab.color = Colors.orangeDim
        self.inventoryBox.currentInventory = "item"
        return true
    end
end

function Menu:scrollsTabClicked(mx, my)
    local tab = self.inventoryBox.scrollsTab
    if mx >= tab.x and mx < tab.x + tab.width
        and my >= tab.y and my < tab.y + tab.height then
        tab.color = Colors.orange
        self.inventoryBox.storyItemsTab.color = Colors.redDim
        self.inventoryBox.itemsTab.color = Colors.yellowDim
        self.inventoryBox.currentInventory = "scroll"
        return true
    end
end

function Menu:itemClicked(mx, my)
    if not self.itemFocus.focused then
        for _, item in ipairs(self.inventoryBox.items) do
            if mx >= item.x and mx < item.x + self.inventoryBox.imgSize
                and my >= item.y and my < item.y + self.inventoryBox.imgSize then
                self.itemFocus.displayName = item.item.displayName
                self.itemFocus.description = item.item.description
                self.itemFocus.focused = true
                return true
            end
        end
    end
end

function Menu:exitFocus()
    if self.itemFocus.focused then
        self.itemFocus.focused = false
        return true
    end
end

return Menu
