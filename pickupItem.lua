local PickupItem = {}
PickupItem.__index = PickupItem

local ActivePickupItems = {}
local Player = require("player")

-- note: "." vs ":" -> ":" implies "self" like a referenced table, "." does not
function PickupItem.new(x, y, type)
    local instance = setmetatable({}, PickupItem)

    instance.x = x
    instance.y = y
    instance.type = type
    instance.img = love.graphics.newImage("assets/"..instance.type..".png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    instance.scaleX = 1
    instance.randomTimeOffset = math.random(0, 100)
    instance.toBeRemoved = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true) -- prevents collisions but can be sensed

    table.insert(ActivePickupItems, instance)
end

function PickupItem:remove()
    for i, instance in ipairs(ActivePickupItems) do
        if instance == self then
            Player:pickUpItem(self.type)
            self.physics.body:destroy()
            table.remove(ActivePickupItems, i)
        end
    end
end

function PickupItem.removeAll()
    for i,v in ipairs(ActivePickupItems) do
        v.physics.body:destroy()
    end

    ActivePickupItems = {}
end

function PickupItem:update(dt)
    self:spin()
    self:checkRemove()
end

function PickupItem:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

-- animation without using images
function PickupItem:spin()
    self.scaleX = math.sin(love.timer.getTime() * 2 + self.randomTimeOffset)
end

function PickupItem:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.scaleX, 1, self.width / 2, self.height / 2)
end

function PickupItem.updateAll()
    for __, instance in ipairs(ActivePickupItems) do
        instance:update()
    end
end

function PickupItem.drawAll()
    for __, instance in ipairs(ActivePickupItems) do
        instance:draw()
    end
end

function PickupItem.beginContact(a, b, collision)
    for i, instance in ipairs(ActivePickupItems) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.toBeRemoved = true
                return true
            end
        end
    end
end

return PickupItem