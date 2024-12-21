Inventory = {}

local Item = require("item")
local StoryItems = require("itemData/storyItems")
local Scrolls = require("itemData/scrolls")

--[[
STORY:
    Soldier asks for help saving princess

REQUIREMENTS:
    Princess wants soldier badge
    Soldier at castle gate wants princess pass and spawns after soldier badge
]]

function Inventory:load()
    self.scroll = { -- controls what jutsus the player can use, and shows the player their sequences in the menu
        -- default scrolls to teach the player some of the controls
        Item.newScroll(Scrolls.jutsuTutorial),
        Item.newScroll(Scrolls.chakraTutorial),
        Item.newScroll(Scrolls.fireRelease),
        Item.newScroll(Scrolls.waterRelease),
        Item.newScroll(Scrolls.windRelease)
    }
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
        --item = Item.newItem(StoryItems[itemName])
    elseif type == "scroll" and not self:checkScrolls(itemName) then
        item = self:newScroll(Scrolls[itemName])
    end
    table.insert(self[type], item)
end

--@param type: string (ex: "storyItem")
--@param itemName: string (ex: "soldierBadge")
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