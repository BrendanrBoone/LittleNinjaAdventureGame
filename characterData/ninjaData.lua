local NinjaData = {}

function NinjaData:load()
    self.direction = "right"
    self.oppositeDirection = "left"
    self.asymmetric = true
    self:loadAssets()
end

function NinjaData:loadAssets()
    self.animation = {}

    self.animation.timer = {
        timer = 0,
        rate = 0.1
    }

    self.animation.runRight = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.runRight.total do
        self.animation.runRight.img[i] = love.graphics.newImage("assets/Ninja/runRight/" .. i .. ".png")
    end

    self.animation.runLeft = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.runLeft.total do
        self.animation.runLeft.img[i] = love.graphics.newImage("assets/Ninja/runLeft/" .. i .. ".png")
    end

    self.animation.idleRight = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.idleRight.total do
        self.animation.idleRight.img[i] = love.graphics.newImage("assets/Ninja/idleRight/" .. i .. ".png")
    end

    self.animation.idleLeft = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.idleLeft.total do
        self.animation.idleLeft.img[i] = love.graphics.newImage("assets/Ninja/idleLeft/" .. i .. ".png")
    end

    self.animation.airRisingRight = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.airRisingRight.total do
        self.animation.airRisingRight.img[i] = love.graphics.newImage("assets/Ninja/airRisingRight/" .. i .. ".png")
    end

    self.animation.airRisingLeft = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.airRisingLeft.total do
        self.animation.airRisingLeft.img[i] = love.graphics.newImage("assets/Ninja/airRisingLeft/" .. i .. ".png")
    end

    self.animation.airFallingRight = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.airFallingRight.total do
        self.animation.airFallingRight.img[i] = love.graphics.newImage("assets/Ninja/airFallingRight/" .. i .. ".png")
    end

    self.animation.airFallingLeft = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.airFallingLeft.total do
        self.animation.airFallingLeft.img[i] = love.graphics.newImage("assets/Ninja/airFallingLeft/" .. i .. ".png")
    end

    self.animation.sealRight = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.sealRight.total do
        local current = i
        if current > 1 then
            current = 2
        end
        self.animation.sealRight.img[i] = love.graphics.newImage("assets/Ninja/seal/" .. current .. ".png")
    end

    self.animation.sealLeft = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.sealLeft.total do
        local current = i
        if current > 1 then
            current = 2
        end
        self.animation.sealLeft.img[i] = love.graphics.newImage("assets/Ninja/seal/" .. current .. ".png")
    end
end

-- Initialize the data immediately
NinjaData:load()

return NinjaData