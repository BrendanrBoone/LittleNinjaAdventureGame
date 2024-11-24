local Smoke = {}
Smoke.__index = Smoke

ActiveSmokes = {}

function Smoke.new(x, y)
    local instance = setmetatable({}, Smoke)

    instance.x = x
    instance.y = y
    instance.offsetY = -8

    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.smok = {total = 6, current = 1, img = Smoke.smokAnim}
    instance.animation.draw = instance.animation.smok.img[1]

    table.insert(ActiveSmokes, instance)
end

function Smoke.loadAssets()
    Smoke.smokAnim = {}
    for i=1, 6 do
        Smoke.smokAnim[i] = love.graphics.newImage("assets/smoke/"..i..".png")
    end

    Smoke.width = Smoke.smokAnim[1]:getWidth()
    Smoke.height = Smoke.smokAnim[1]:getHeight()
end

function Smoke:update(dt)
    self:animate(dt)
end

function Smoke:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function Smoke:setNewFrame()
    local anim = self.animation.smok
    if anim.current == anim.total then
        self:removeActive()
        return
    end
    if anim.current < anim.total then
        anim.current = anim.current + 1
    end
    self.animation.draw = anim.img[anim.current]
end

-- removes self instance from ActiveSmokes
function Smoke:removeActive()
    for i, instance in ipairs(ActiveSmokes) do
        if instance == self then
            table.remove(ActiveSmokes, i)
            break
        end
    end
end

function Smoke:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y + self.offsetY, 0, 1, 1, self.width / 2, self.height / 2)
end

function Smoke.updateAll(dt)
    for _, instance in ipairs(ActiveSmokes) do
        instance:update(dt)
    end
end

function Smoke.drawAll()
    for _, instance in ipairs(ActiveSmokes) do
        instance:draw()
    end
end

return Smoke
