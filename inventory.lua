Inventory = {}

local Item = require("item")
local StoryItems = require("itemData/storyItems")

--[[
-- this file removes and places npc locations, and handles dialogue
General story idea:
 - Chapter 1
    - Soldier requesting

]]

function Inventory:load()
    self.scroll = {} -- what jutsus the player can use
    self.item = {}
    self.storyItem = {} -- items received for story progression to tell where player is in story
end

--@param type: string (where in the inventory it is stored)
--@param itemName: table (item object.name)
function Inventory:add(type, itemName)
    local item
    if type == "storyItem" and not self:checkStoryItems(itemName) then
        item = Item.newStoryItem(StoryItems[itemName])
    elseif type == "item" then
        item = Item.newItem(StoryItems[itemName])
    elseif type == "scroll" then
        item = self:newScroll(itemName)
    end
    table.insert(self[type], item)
end

function Inventory:check(type, itemName)
    if type == "storyItem" then
        return self:checkStoryItems(itemName)
    elseif type == "item" then
        return self:checkItems(itemName)
    elseif type == "scroll" then
        return self:checkScrolls(itemName)
    end
    return false
end

function Inventory:checkStoryItems(itemName)
    if itemName == "" then print("itemName was null") return true end
    for _, v in ipairs(self.storyItem) do
        if v.itemName == itemName then
            return true
        end
    end
    return false
end

function Inventory:checkItems(itemName)
    for _, v in ipairs(self.item) do
        if v.itemName == itemName then
            return true
        end
    end
    return false
end

function Inventory:checkScrolls(itemName)
    for _, v in ipairs(self.scroll) do
        if v.itemName == itemName then
            return true
        end
    end
    return false
end

function Inventory:printStoryItems()
    print("\nPRINTING STORYITEMS")
    for _, v in ipairs(self.storyItem) do
        print(v.itemName)
    end
    print("\n")
end

return Inventory