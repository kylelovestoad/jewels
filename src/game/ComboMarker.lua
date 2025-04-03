local Class = require "libs.hump.class"
local Timer = require "libs.hump.timer"
local Tween = require "libs.tween" 

local comboFontSize = 24
local comboFont = love.graphics.newFont(comboFontSize)

local ComboMarker = Class{}
function ComboMarker:init(x, y, comboNum,  multiplier)
    self.x = x
    self.y = y
    self.alpha = 1
    self.comboNum = comboNum
    self.multiplier = multiplier
    self.animation = false
    self.tweenAnimation = nil
end

function ComboMarker:draw()
    if self.animation then
        love.graphics.setColor(1, 1, 0, self.alpha) 
        love.graphics.rectangle("fill",0,self.y-10,gameWidth / 4,comboFontSize*2)
        love.graphics.setColor(1,0,0) -- Red
        love.graphics.printf("Combo "..tostring(self.comboNum).." (x"..tostring(self.multiplier)..")!" , comboFont, gameWidth/2-60,self.y,200,"center")
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function ComboMarker:update(dt)
    if self.animation then
        self.animation = not self.tweenAnimation:update(dt)
    end
end

function ComboMarker:playAnimation()
    self.tweenAnimation = Tween.new(1, self, { y = 0, alpha = 0}, Tween.easing.outQuad)
    self.animation = true
end

return ComboMarker