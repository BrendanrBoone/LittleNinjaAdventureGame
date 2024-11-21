local Explosion = {}
Explosion.__index = Explosion

ActiveExplosions = {}

function Explosion.new(x, y)
    local instance = setmetatable({}, Explosion)

    instance.x = x
    instance.y = y
    instance.offsetY = -8

    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.explod = {total = 17, current = 1, img = Explosion.explodAnim}
    instance.animation.draw = instance.animation.explod.img[1]

    table.insert(ActiveExplosions, instance)
end

function Explosion.loadAssets()
    Explosion.explodAnim = {}
    for i=1, 17 do
        Explosion.explodAnim[i] = love.graphics.newImage("assets/RealisticExplosion/explosion/"..i..".png")
    end

    Explosion.width = Explosion.explodAnim[1]:getWidth()
    Explosion.height = Explosion.explodAnim[1]:getHeight()
end

function Explosion:update(dt)
    self:animate(dt)
end

function Explosion:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function Explosion:setNewFrame()
    local anim = self.animation.explod
    if anim.current == anim.total then
        self:removeActive()
        return
    end
    if anim.current < anim.total then
        anim.current = anim.current + 1
    end
    self.animation.draw = anim.img[anim.current]
end

-- removes self instance from ActiveExplosions
function Explosion:removeActive()
    for i, instance in ipairs(ActiveExplosions) do
        if instance == self then
            table.remove(ActiveExplosions, i)
            break
        end
    end
end

function Explosion:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, 0, 1, 1, self.width / 2, self.height / 2)
end

function Explosion.updateAll(dt)
    for _, instance in ipairs(ActiveExplosions) do
        instance:update(dt)
    end
end

function Explosion.drawAll()
    for _, instance in ipairs(ActiveExplosions) do
        instance:draw()
    end
end

return Explosion
