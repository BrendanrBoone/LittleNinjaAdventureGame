local Item = {}
Item.__index = Item

ActiveItems = {}

--@params name: string
--@params description: string
function Item.new(displayName, description, itemName, iconImg, type)
    local instance = setmetatable({}, Item)

    instance.displayName = displayName
    instance.description = description
    instance.itemName = itemName
    instance.iconImg = iconImg
    instance.type = type

    table.insert(ActiveItems, instance)
    return instance
end

--@param item: table (itemData/storyItems.lua)
function Item.newStoryItem(item)
    local storyItem = Item.new(item.displayName, item.description, item.itemName, item.iconImg, "storyItem")
    return storyItem
end

--@param item: table (itemData/scrolls.lua)
function Item.newScroll(item)
    local storyItem = Item.new(item.displayName, item.description, item.itemName, item.iconImg, "scroll")

    return storyItem
end

--unfinished
function Item.newItem(item)
    local storyItem = Item.new(item.displayName, item.description, item.itemName, item.iconImg, "item")

    return storyItem
end

return Item