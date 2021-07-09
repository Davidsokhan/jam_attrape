debug = true
 
-- Timers
-- We declare these here so we don't have to edit them multiple places
createEnemyTimerMax = 0.7
createEnemyTimer = createEnemyTimerMax
 
-- Player Object
player = { x = 200, y = 500, speed = 600, img = nil }
isAlive = true
lives = 5 
score = 0
speedmult = 1
-- Image Storage
penImg = nil
rulerImg = nil
 
-- Entity Storage
-- bullets = {} -- array of current bullets being drawn and updated
enemies = {} -- array of current enemies on screen
 
-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
    x2 < x1+w1 and
    y1 < y2+h2 and
    y2 < y1+h1
end
 
-- Loading
function love.load(arg)
    player.img = love.graphics.newImage('assets/hand.png')
    penImg = love.graphics.newImage('assets/pen.png')
    rulerImg = love.graphics.newImage('assets/ruler.png')
    tableImg = love.graphics.newImage('assets/table.png')
    sky = love.graphics.newImage('assets/sky.jpg')
end
 
-- Updating
function love.update(dt)
    -- I always start with an easy way to exit the game
    if love.keyboard.isDown('escape') then
    love.event.push('quit')
    end
 
    -- Time out enemy creation
    createEnemyTimer = createEnemyTimer - (1 * dt)
    if createEnemyTimer < 0 then
        createEnemyTimer = createEnemyTimerMax
 
 -- Create an enemy
        randomNumber = math.random(10, love.graphics.getWidth() - 10)
        spriteRandom = math.random(0, 1)
        if spriteRandom == 0 then
            newEnemy = { x = randomNumber, y = -10, img = penImg}
        else
            newEnemy = { x = randomNumber, y = -10, img = rulerImg}
        end
            table.insert(enemies, newEnemy)
    end
 
 -- update the positions of enemies
    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (200 * dt * speedmult)
        
        if enemy.y > 700 then -- remove enemies when they pass off the screen
            lives = lives - 1
            table.remove(enemies, i)
        end
    end
 
 -- run our collision detection
 -- Since there will be fewer enemies on screen than bullets we'll loop them first
 -- Also, we need to see if the enemies hit our player
    for i, enemy in ipairs(enemies) do
        if lives > 0 and CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) then
            table.remove(enemies, i)
            score = score + 1
            if score % 5 == 0 and speedmult < 2.7 then
                speedmult = speedmult + 0.10
            end
            if score % 15 == 0 and createEnemyTimerMax > 0.3 then
                createEnemyTimerMax = createEnemyTimerMax - 0.05
            end 
        end
    end
 
    if love.keyboard.isDown('left','q') then
        if player.x > 0 then -- binds us to the map
            player.x = player.x - (player.speed*dt)
        end
    elseif love.keyboard.isDown('right','d') then
        if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
            player.x = player.x + (player.speed*dt)
        end
    end
 
    if lives <= 0 and love.keyboard.isDown('r') then
        -- remove all our bullets and enemies from screen
        enemies = {}
        
        -- reset timers
        createEnemyTimer = 0.7
        createEnemyTimerMax = 0.7
        
        -- move player back to default position
        player.x = 50
        player.y = 500
        speedmult  = 1
        -- reset our game state
        score = 0
        lives = 5
    end
end
 
-- Drawing
function love.draw(dt)
    love.graphics.draw(sky, 0,0)
    love.graphics.draw(tableImg, 0, 540)
    for i, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.img, enemy.x, enemy.y)
    end
 
    love.graphics.setColor(0, 0, 0)
    if debug then
        fps = tostring(love.timer.getFPS())
        love.graphics.print("Current FPS: "..fps, 9, 10)
    end
    love.graphics.print("SCORE: " .. tostring(score), 400, 10)
    love.graphics.print("LIVES: " .. tostring(lives), 210, 15)
    love.graphics.setColor(255, 255, 255)

    if lives > 0 then
        love.graphics.draw(player.img, player.x, player.y)
    else
        love.graphics.print("Game Over : Press 'R' to restart", love.graphics:getWidth()/2-57, love.graphics:getHeight()/2-10)
    end
 
end