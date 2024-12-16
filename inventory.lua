Inventory = {}

--[[
-- this file removes and places npc locations, and handles dialogue
General story idea:
 - Chapter 1
    - Soldier requesting

]]

function Inventory:load()
    self.scroll = {} -- what jutsus the player can use
    self.item = {}
    self.missionItem = {} -- items received for story progression to tell where player is in story
end

--@param type: string (where in the inventory it is stored)
--@param item: table (item object)
function Inventory:add(type, item)
    table.insert(self[type], item)
end

return Inventory