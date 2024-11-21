local Camera = {
    x = 0,
    y = 0,
    scale = 2,

    shaking = false,
    shakingTimer = 0
}

--starts camera
function Camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:clear()
    love.graphics.pop()
end

--called in love.update(dt)
function Camera:setPosition(x, y)
    self.x = x - love.graphics.getWidth() / 2 / self.scale
    self.y = y - love.graphics.getHeight() / 2 / self.scale
    local RS = self.x + love.graphics.getWidth() / 2 -- Right Side
    local BS = self.y + love.graphics.getHeight() / 2 -- Bottom Side

    if self.x < 0 then
        self.x = 0
    elseif RS > MapWidth then
        self.x = MapWidth - love.graphics.getWidth() / 2
    end

    if self.y < 0 then
        self.y = 0
    elseif BS > MapHeight then
        self.y = MapHeight - love.graphics.getHeight() / 2
    end

    if self.shaking then
        local scale = 1
        if self.shakingTimer % 2 ~= 0 then
            scale = -1
        end
        self.y = self.y + self.yVel * scale
        self.x = self.x + self.xVel * scale
        self.shakingTimer = self.shakingTimer - 1
        if self.shakingTimer <= 0 then
            self.shaking = false
        end
        
    end
end

--@size: string == "large", "medium", "small", "extraSmall"
-- defaults to extraSmall if unknown size
function Camera:shake(size)
    self.shaking = true

    self.acceleration = 1
    self.xVel = 0
    self.yVel = 2
    self.shakingTimer = 10

    if size == "large" then
        self.xVel = 5
        self.yVel = 10
        self.shakingTimer = 20
    elseif size == "medium" then
        self.xVel = 1
        self.yVel = 2
        self.shakingTimer = 4
    elseif size == "small" then
        self.xVel = 2
        self.yVel = 0
        self.shakingTimer = 10
    end
end

return Camera
