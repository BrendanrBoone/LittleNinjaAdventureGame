local CastleGate = {img = love.graphics.newImage("assets/castleGateLong.png")}
CastleGate.__index = CastleGate

local Categories = require("categories")
local Helper = require("helper")

ActiveCastleGates = {}

function CastleGate.new(x, y, width, height)
    local instance = setmetatable({}, CastleGate)

    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height

    instance.gateIsOpen = false
    instance.rotation = 0 -- radians

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "kinematic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    --instance.physics.body:setGravityScale(0)
    instance.physics.fixture:setCategory(Categories.ground)
    instance.physics.fixture:setUserData("castleGate")

    table.insert(ActiveCastleGates, instance)
    return instance
end

function CastleGate:open()
    self.gateIsOpen = true
end

function CastleGate.openAll()
    for _, instance in ipairs(ActiveCastleGates) do
        instance:open()
    end
end

function CastleGate:moveGate()
    local gateSpeed = 0.2 -- in degrees
    if self.gateIsOpen and self.rotation < math.rad(90) then
        self.rotation = self.rotation + math.rad(gateSpeed)
    elseif not self.gateIsOpen and self.rotation > math.rad(0) then
        self.rotation = self.rotation - math.rad(gateSpeed)
    end
    self.physics.body:setAngle(self.rotation)
end

function CastleGate:update(dt)
    self:moveGate()
end

function CastleGate.updateAll(dt)
    for _, instance in ipairs(ActiveCastleGates) do
        instance:update(dt)
    end
end

function CastleGate.removeAll()
    for _, instance in ipairs(ActiveCastleGates) do
        instance.physics.body:destroy()
    end

    ActiveCastleGates = {}
end

function CastleGate:draw()
    -- IDK know why the position coordinates are like this with width and height but this works
    --love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    love.graphics.draw(CastleGate.img, self.x, self.y, self.rotation, 1, 1, self.width/2, self.height/2)
end

function CastleGate.drawAll()
    Helper.resetDrawSettings()
    for _, instance in ipairs(ActiveCastleGates) do
        instance:draw()
    end
end

return CastleGate