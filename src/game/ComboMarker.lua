local Class = require "libs.hump.class"
local Tween = require "libs.tween" 

local comboFontSize = 36
local comboFont = love.graphics.newFont(comboFontSize)

local ComboMarker = Class{}
function ComboMarker:init(x, y, comboNum,  multiplier)
    self.x = x
    self.y = y
    self.backgroundAlpha = 0.2
    self.alpha = 1
    self.comboNum = comboNum
    self.multiplier = multiplier
    self.animation = false
    self.tweenAnimation = nil
end

function ComboMarker:draw()
    if self.animation then
        love.graphics.setColor(1,0,0, self.backgroundAlpha) -- Black
        love.graphics.rectangle("fill",0,self.y-10,gameWidth,comboFontSize*2)
        love.graphics.setColor(1, 0, 0, self.alpha) -- Red
        love.graphics.printf("Combo "..tostring(self.comboNum).." (x"..tostring(self.multiplier)..")!" , comboFont, self.x - 100,self.y, 400,"center")
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function ComboMarker:update(dt)
    if self.animation then
        self.animation = not self.tweenAnimation:update(dt)
    end
end

function ComboMarker:playAnimation()
    self.tweenAnimation = Tween.new(1.5, self, { y = self.y - 40, alpha = 0, backgroundAlpha = 0}, Tween.easing.outQuad)
    self.animation = true
end

return ComboMarker