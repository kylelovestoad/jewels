local Class = require "libs.hump.class"
local Timer = require "libs.hump.timer"
local Tween = require "libs.tween" 
local Sounds = require "src.game.SoundEffects"

local statFontSize = 26
local statFont = love.graphics.newFont(statFontSize)

local Stats = Class{}
function Stats:init()
    self.y = 10 -- we will need it for tweening later
    self.level = 1 -- current level    
    self.totalScore = 0 -- total score so far
    self.startingTargetScore = 80
    self.targetScore = self.startingTargetScore
    self.maxSecs = 99 -- max seconds for the level
    self.countdown = self.maxSecs -- elapsed seconds
    self.timeOut = false -- when time is out
    self.levelingAnimation = false
    self.tweenLevel = nil
    self.board = nil
    self.timer = Timer.every(1, function()
        if self.countdown > 0 then
            self.countdown = self.countdown - 1
        end
        if self.countdown <= 0 then
            self.timeOut = true
        end
    end)
end

function Stats:draw()
    if self.levelingAnimation then
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill",0,self.y-10,gameWidth,statFontSize*2)
    end
    love.graphics.setColor(1,0,1) -- Magenta
    love.graphics.printf("Level "..tostring(self.level), statFont, gameWidth/2-60,self.y,100,"center")
    if not self.levelingAnimation then
        love.graphics.printf("Time "..tostring(self.countdown), statFont,10,10,200)
        love.graphics.printf("Score "..tostring(self.totalScore), statFont,gameWidth-210,10,200,"right")
    end
    love.graphics.setColor(1,1,1) -- White
end
    
function Stats:update(dt) -- for now, empty function
    if self.levelingAnimation then
        self.levelingAnimation = not self.tweenLevel:update(dt)
    end

    Timer.update(dt)
end

function Stats:addScore(n)
    self.totalScore = self.totalScore + n
    if self.totalScore > self.targetScore then
        self:levelUp()
    end
end

function Stats:levelUp()
    self.level = self.level +1
    self.targetScore = self.targetScore+self.level*1000
    self.countdown = self.maxSecs
    self.levelingAnimation = true

    Sounds["levelUp"]:play()

    self.board:addRandomCoin()

    -- My boomerang tween effect
    -- I know I could have used two tweens, but I wanted to try a custom tween function
    self.tweenLevel = Tween.new(2.6, self, { y = 10 }, function(time, begin, _, duration)
        -- Where the boomerang stops and starts going back
        local mid = gameHeight/2 - begin
        local half = duration / 2
        -- Go forwards for half of the duration, then go back
        -- Time moves towards duration, so duration / 2 is the halfway point
        if time < half then
            -- mid - begin is the change between starting and ending y val since it is moving forwards
            return Tween.easing.outCubic(time, begin, mid - begin, half)
        else
            -- time - half = 0 at the halfway point, 0 is the beginning of a tween
            -- begin - mid is the change between starting and ending since it is moving backwards
            return Tween.easing.inCubic(time - half, mid, begin - mid, half)
        end
    end)
end

function Stats:reset()
    self.totalScore = 0
    self.targetScore = self.startingTargetScore
    self.countdown = self.maxSecs
    self.level = 1
    self.timeOut = false
    self.levelingAnimation = false
end
    
return Stats
    