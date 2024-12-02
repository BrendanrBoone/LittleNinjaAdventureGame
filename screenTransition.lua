local ScreenTransition = {}

local Camera = require("camera")

function ScreenTransition:load()
    self.screenWidth = love.graphics.getWidth()
    self.screenHeight = love.graphics.getHeight()

    self.state = "null" -- 3 states: "null", "open", "close"
    self.animation = { timer = 0, rate = 0.1 }
    
    self.xCenter = self.screenWidth - self.screenWidth / 2 -- Centering the square
    self.yCenter = self.screenHeight - self.screenHeight / 2 -- Centering the square
    self.x, self.y = 0, 0

    self:loadAssets()
end

function ScreenTransition:loadAssets()
    self.animAssets = {}
    local maxCircleSize = self.screenWidth

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
    self:setPosition()
    self:animate(dt)
end

function ScreenTransition:setPosition()
    self.x = Camera.x
    self.y = Camera.y
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
    else
        self:transitionState(anim)
    end
    self.curCircleSize = anim.circleSize[anim.current]
end

function ScreenTransition:transitionState(anim)
    if self.state == "close" then
        anim.current = 1
        self.state = "open"
    elseif self.state == "open" then
        anim.current = 1
        self.state = "null"
    end
end

-- start screen transition with close()
function ScreenTransition:close()
    self.state = "close"
end

function ScreenTransition:open()
    self.state = "open"
end

function ScreenTransition:draw()
    if self.state ~= "null" then
        print("drawing")
        --[[love.graphics.stencil(function()
            love.graphics.circle("fill", self.x + self.squareSize, self.y + self.squareSize, self.curCircleSize)
        end, "replace", 1)]]
        --love.graphics.setStencilTest("greater", 0)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", self.x, self.y, self.screenWidth, self.screenHeight)
        --love.graphics.setStencilTest()
        love.graphics.setColor(1, 1, 1)
    end
end

return ScreenTransition