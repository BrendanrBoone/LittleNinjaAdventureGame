local Item = {}
Item.__index = Item

ActiveItems = {}

--@params name: string
--@params description: string
function Item.new(name, description, itemName, type)
    local instance = setmetatable({}, Item)

    instance.name = name
    instance.description = description
    instance.itemName = itemName
    instance.type = type

    table.insert(ActiveItems, instance)
    return instance
end

--@param item: table (itemData/storyItems.lua)
function Item.newStoryItem(item)
    local storyItem = Item.new(item.name, item.description, item.itemName, "storyItem")
    return storyItem
end

--unfinished
function Item.newScroll(item)
    local storyItem = Item.new(item.name, item.description, item.itemName, "scroll")

    return storyItem
end

--unfinished
function Item.newItem(item)
    local storyItem = Item.new(item.name, item.description, item.itemName, "item")

    return storyItem
end

return Item