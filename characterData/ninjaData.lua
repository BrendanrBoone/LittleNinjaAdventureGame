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

    self.animation.airRising = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.airRising.total do
        self.animation.airRising.img[i] = love.graphics.newImage("assets/Naruto/airRising/" .. i .. ".png")
    end

    self.animation.airFalling = {
        total = 2,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.airFalling.total do
        self.animation.airFalling.img[i] = love.graphics.newImage("assets/Naruto/airFalling/" .. i .. ".png")
    end
end

-- Initialize the data immediately
NinjaData:load()

return NinjaData