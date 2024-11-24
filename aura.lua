local Aura = {}
Aura.__index = Aura

ActiveAuras = {}
local Sounds = require("sounds")

function Aura.new(x, y, fix)
    local instance = setmetatable({}, Aura)

    instance.x = x
    instance.y = y
    instance.offsetY = -12

    instance.fixture = fix -- associated fixture

    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.chakra = {total = 3, current = 1, img = Aura.chakraAnim}
    instance.animation.draw = instance.animation.chakra.img[1]

    table.insert(ActiveAuras, instance)
end

function Aura.loadAssets()
    Aura.chakraAnim = {}
    for i=1, 3 do
        Aura.chakraAnim[i] = love.graphics.newImage("assets/Aura/chakra/"..i..".png")
    end

    Aura.width = Aura.chakraAnim[1]:getWidth()
    Aura.height = Aura.chakraAnim[1]:getHeight()
end

function Aura:update(dt)
    self:animate(dt)
    self:playSound()
end

function Aura:playSound()

end

function Aura:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function Aura:setNewFrame()
    local anim = self.animation.chakra
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

-- removes self instance from ActiveAuras
function Aura:removeActive()
    for i, instance in ipairs(ActiveAuras) do
        if instance == self then
            table.remove(ActiveAuras, i)
            break
        end
    end
end

--remove specific aura to fixture
function Aura.remove(fix)
    for i, instance in ipairs(ActiveAuras) do
        if instance.fixture == fix then
            table.remove(ActiveAuras, i)
            break
        end
    end
end

function Aura:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, 0, 1, 1, self.width / 2, self.height / 2)
end

function Aura.updateAll(dt)
    for _, instance in ipairs(ActiveAuras) do
        instance:update(dt)
    end
end

function Aura.drawAll()
    for _, instance in ipairs(ActiveAuras) do
        instance:draw()
    end
end

return Aura
