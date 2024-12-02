local ScreenTransition = {}

function ScreenTransition:load()
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()

    self.state = "null" -- 3 states: "null", "open", "close"
    self.animation = { timer = 0, rate = 0.1 }
    
    -- Define the square size as a fraction of the screen size
    self.squareSize = math.max(self.screenWidth, self.screenHeight) * 0.5 -- 50% of the smaller dimension
    self.x = (self.screenWidth - self.squareSize) / 2 -- Centering the square
    self.y = (self.screenHeight - self.squareSize) / 2 -- Centering the square

    self:loadAssets()
end

function ScreenTransition:loadAssets()
    self.animAssets = {}
    local maxCircleSize = self.squareSize

    --open
    self.animAssets.open = {}
    self.animAssets.open.current = 1
    self.animAssets.open.circleSize = {}
    for i=1, maxCircleSize do
        self.animAssets.open.circleSize[i] = i - 1
    end
    self.animAssets.open.total = #self.animAssets.open.circleSize

    --close
    self.animAssets.close = {}
    self.animAssets.close.current = 1
    self.animAssets.close.circleSize = {}
    for i=1, maxCircleSize do
        self.animAssets.close.circleSize[i] = maxCircleSize - i
    end
    self.animAssets.close.total = #self.animAssets.close.circleSize

    self.curCircleSize = maxCircleSize
end

function ScreenTransition:update(dt)
    self:animate(dt)
end

function ScreenTransition:animate(dt)
    if self.state ~= "null" then
        self.animation.timer = self.animation.timer + dt
        if self.animation.timer > self.animation.rate then
            self.animation.timer = 0
            self:setNewFrame()
        end
    end
end

function ScreenTransition:setNewFrame()
    local anim = ScreenTransition.animAssets[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    elseif self.state == "open" then
        anim.current = 1
        self.animAssets.close.current = 1
        self.state = "null"
    end
    self.animation.curCircleSize = anim.circleSize[anim.current]
end

function ScreenTransition:close()
    self.state = "close"
end

function ScreenTransition:open()
    self.state = "open"
end

function ScreenTransition:draw()
    if self.state ~= "null" then
        love.graphics.stencil(function()
            love.graphics.circle("fill", self.x + self.squareSize, self.y + self.squareSize, self.animation.curCircleSize)
        end, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", self.x + self.squareSize, self.y + self.squareSize, self.squareSize, self.squareSize)
        love.grphics.setStencilTest()
        love.graphics.setColor(1, 1, 1)
    end
end

return ScreenTransition