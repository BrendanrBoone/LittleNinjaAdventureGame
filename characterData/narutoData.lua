local NarutoData = {}

function NarutoData:load()
    self.direction = "right"
    self.oppositeDirection = "left"
    self.asymmetric = false
    self:loadAssets()
end

function NarutoData:loadAssets()
    self.animation = {}

    self.animation.timer = {
        timer = 0,
        rate = 0.1
    }

    self.animation.run = {
        total = 6,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.run.total do
        self.animation.run.img[i] = love.graphics.newImage("assets/Naruto/run/" .. i .. ".png")
    end

    self.animation.idle = {
        total = 4,
        current = 1,
        img = {}
    }
    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/Naruto/idle/" .. i .. ".png")
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
NarutoData:load()

return NarutoData