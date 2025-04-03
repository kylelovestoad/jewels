local Globals = require "src.Globals"
local Push = require "libs.push"
local Background = require "src.game.Background"
local Gem = require "src.game.Gem"
local Board = require "src.game.Board"
local Border = require "src.game.Border"
local Explosion = require "src.game.Explosion"
local Sounds = require "src.game.SoundEffects"
local Stats = require "src.game.Stats"

-- Had fun with this! Making the animations was super fun and cool. If I were to change one thing I would refactor a bit more
-- And make the gamestates a bit better with hump.gamestate. Maybe also make it so the gems would move back if they don't make a match

-- Load is executed only once; used to setup initial resource for your game
function love.load()
    love.window.setTitle("Jewels")
    Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})
    math.randomseed(os.time()) -- RNG setup for later

    titleFont = love.graphics.newFont(32)
    bigFont = love.graphics.newFont(28)

    bg1 = Background("graphics/bg/background1.png",30)
    bg2 = Background("graphics/bg/background2.png",60)

    gem1 = Gem(100,50,5)
    gem2 = Gem(500,50,6)

    stats = Stats()
    board = Board(140,80,stats)
    border = Border(110,50,380,380)

    testexp = Explosion()
end

-- When the game window resizes
function love.resize(w,h)
    Push:resize(w,h) -- must called Push to maintain game resolution
end

-- Event for keyboard pressing
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "F2" or key == "tab" then
        debugFlag = not debugFlag
    elseif key == "return" and gameState=="start" then
        gameState = "play"
    elseif key == "return" and gameState == "over" then
        stats:reset()
        board = Board(140,80,stats)
        gameState = "play"
    end
end

-- Event to handle mouse pressed (there is another for mouse release)
function love.mousepressed(x, y, button, _)
    local gx, gy = Push:toGame(x,y)
    if button == 1 then -- regurlar mouse click
        board:mousepressed(gx,gy)
    elseif debugFlag then
        if button == 2 and love.keyboard.isDown("lctrl","rctrl") then
           testexp:trigger(gx,gy)
        elseif button == 2 then
            board:cheatGem(gx,gy)
        end
    end
end

-- Update is executed each frame, dt is delta time (a fraction of a sec)
function love.update(dt)
    bg1:update(dt)
    bg2:update(dt)
    testexp:update(dt)

    if stats.countdown == 0 and gameState == "play" then 
        Sounds["timeOut"]:play()
        gameState = "over"
    end

    if gameState == "start" then

        gem1:update(dt)
        gem2:update(dt)
    elseif gameState == "play" then
        Sounds["playStateMusic"]:play()
        stats:update(dt)
        board:update(dt)

    elseif gameState == "over" then
        -- for later, if we needed
        Sounds["playStateMusic"]:stop()
    end
end

-- Draws the game after the update
function love.draw()
    Push:start()

    -- always draw between Push:start() and Push:finish()
    if gameState== "start" then
        drawStartState()
    elseif gameState == "play" then
        drawPlayState()    
    elseif gameState == "over" then
        drawGameOverState()    
    end

    if testexp:isActive() then
        testexp:draw()
    end
    if debugFlag then
        love.graphics.print("DEBUG ON",20,gameHeight-20)
    end

    Push:finish()
end

function drawStartState()
    bg1:draw()
    bg2:draw()

    love.graphics.printf("Jewels",titleFont,0,50,
        gameWidth,"center")
    love.graphics.printf("Press Enter to Play or Escape to exit",
        0,90, gameWidth,"center")

    gem1:draw()
    gem2:draw()    
end

function drawPlayState()
    bg1:draw()
    bg2:draw()

    board:draw()

    border:draw()
    stats:draw()
end

function drawGameOverState()
    love.graphics.printf("Game Over",titleFont,0,50,
        gameWidth,"center")
    love.graphics.printf("Press Enter to Play or Escape to exit",
        0,230, gameWidth,"center")
    love.graphics.printf("Level: "..stats.level,
        bigFont,0,130,gameWidth,"center")
    love.graphics.printf("High Score: "..stats.totalScore,
        bigFont,0,170,gameWidth,"center")
end
