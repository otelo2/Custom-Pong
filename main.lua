push = require "push"
Class = require "class"
require "Paddle"
require "Ball"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200  

PADDLE_SIZE_X = 5
PADDLE_SIZE_Y = 20

PLAYER1_COLOR = {255/255, 51/255, 51/255}
PLAYER2_COLOR = {0/255, 146/255, 204/255}
BOT_COLOR = {119/255, 153/255, 51/255} --Pending functionality
BALL_COLOR = {220/255, 212/255, 39/255}

function love.load()
    --Used for initializing the game state at the very beggining.
    love.graphics.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())

    --Loads the two fonts for the game
    smallFont = love.graphics.newFont("font.ttf", 8)
    scoreFont = love.graphics.newFont("font.ttf", 32)

    love.graphics.setFont(smallFont)

    --Load the music file
    menuMusic = love.audio.newSource("Music/menuMusic.mp3", "stream")
    playMusic = love.audio.newSource("Music/playMusic.mp3", "stream")
    menuMusic:play()

    --Loads all the sound effects
    collision1 = love.audio.newSource("Sound/collision1.ogg", "static")
    collision2 = love.audio.newSource("Sound/collision2.ogg", "static")
    collision3 = love.audio.newSource("Sound/collision3.ogg", "static")
    collision4 = love.audio.newSource("Sound/collision4.ogg", "static")
    wallCollision1 = love.audio.newSource("Sound/wallCollision1.ogg", "static")
    wallCollision2 = love.audio.newSource("Sound/wallCollision2.ogg", "static")
    wallCollision3 = love.audio.newSource("Sound/wallCollision3.ogg", "static")
    wallCollision4 = love.audio.newSource("Sound/wallCollision4.ogg", "static")
    wallCollision5 = love.audio.newSource("Sound/wallCollision5.ogg", "static")

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    --Create the paddle objects
    player1 = Paddle(10, PADDLE_SIZE_Y, PADDLE_SIZE_X, PADDLE_SIZE_Y, PLAYER1_COLOR)
    player2 = Paddle(VIRTUAL_WIDTH-20, VIRTUAL_HEIGHT-PADDLE_SIZE_Y, PADDLE_SIZE_X, PADDLE_SIZE_Y, PLAYER2_COLOR)
    bot = Paddle(VIRTUAL_WIDTH-20, VIRTUAL_HEIGHT-PADDLE_SIZE_Y, PADDLE_SIZE_X, PADDLE_SIZE_Y, BOT_COLOR)

    --Create the ball object
    ball = Ball(VIRTUAL_WIDTH/2-2, VIRTUAL_HEIGHT/2-2, 4, 4, BALL_COLOR)

    --Set starting score for the players
    player1Score = 0
    player2Score = 0

    --Keeps track of who is serving
    servingPlayer = 1

    --Set starting state
    gameState = 'menu'
    
end


function love.update(dt)
    --Called each frame by love. dt is time in seconds elapsed since last frame

    --Sets the correct serving for each player
    if gameState == 'serve' then
        if servingPlayer == 1 then
            --Player 1 serves. Go left
            ball.dx = -math.random(50, 100)*2
        else
            --Player 2 serves. Go right
            ball.dx = math.random(50, 100)*2
        end
        ball.dy = (math.random(2) == 1 and -100 or 100) * 2

    --Checks for collision between the ball, paddles and screen borders
    elseif gameState == 'play' then
        playMusic:play()
        --Check for collision with the top of the screen
        if ball.y <= 0 then
            --Play collision sound effect
            randomSound = math.random(1, 5)
            if randomSound == 1 then
                wallCollision1:play()
            elseif randomSound == 2 then
                wallCollision2:play()
            elseif randomSound == 3 then
                wallCollision3:play()
            elseif randomSound == 4 then
                wallCollision4:play()
            else 
                wallCollision5:play()
            end

            --Make the ball bounce away from the boundry
            ball.y = 0
            ball.dy = -ball.dy
            
        end

        --Check for collision with the bottom of the screen
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            --Play collision sound effect
            randomSound = math.random(1, 5)
            if randomSound == 1 then
                wallCollision1:play()
            elseif randomSound == 2 then
                wallCollision2:play()
            elseif randomSound == 3 then
                wallCollision3:play()
            elseif randomSound == 4 then
                wallCollision4:play()
            else 
                wallCollision5:play()
            end

            --Make the ball bounce away from the boundry
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end

        if ball:collides(player1) then
            --play a collision sound
            randomSound = math.random(1, 4)
            if randomSound == 1 then
                collision1:play()
                wallCollision1:play()
            elseif randomSound == 2 then
                collision2:play()
                wallCollision2:play()
            elseif randomSound == 3 then
                collision3:play()
                wallCollision3:play()
            else 
                collision4:play()
                wallCollision4:play()
            end

            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)*2
            else
                ball.dy = math.random(10, 150)*2
            end
        end

        if gameMode == 'pVp' then
            if ball:collides(player2) then
                --play a collision sound
                randomSound = math.random(1, 4)
                if randomSound == 1 then
                    collision1:play()
                    wallCollision2:play()
                elseif randomSound == 2 then
                    collision2:play()
                    wallCollision4:play()
                elseif randomSound == 3 then
                    collision3:play()
                    wallCollision1:play()
                else 
                    collision4:play()
                    wallCollision5:play()
                end

                ball.dx = -ball.dx * 1.03
                ball.x = player2.x - 4
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)*2
                else
                    ball.dy = math.random(10, 150)*2
                end
            end
        elseif gameMode == 'pVb' then
            if ball:collides(bot) then
                --play a collision sound
                randomSound = math.random(1, 4)
                if randomSound == 1 then
                    collision1:play()
                    wallCollision2:play()
                elseif randomSound == 2 then
                    collision2:play()
                    wallCollision4:play()
                elseif randomSound == 3 then
                    collision3:play()
                    wallCollision1:play()
                else 
                    collision4:play()
                    wallCollision5:play()
                end

                ball.dx = -ball.dx * 1.03
                ball.x = bot.x - 4
                if ball.dy < 0 then
                    ball.dy = -math.random(10, 150)*2
                else
                    ball.dy = math.random(10, 150)*2
                end
            end
        end
    elseif gameState == 'done' then
        playMusic:stop()
    end

    --If the ball gets out of player1's goal, give score to player 2 
    if ball.x < 0 then
        player2Score = player2Score + 1
        --Check if we've reached the max score and won
        if player2Score == 10 then
            winningPlayer = 2
            gameState = 'done'
        else
            servingPlayer = 1
            gameState = 'serve'
        end
        ball:reset()
    end

    --If the ball gets out of player2's goal, give score to player 1
    if ball.x > VIRTUAL_WIDTH then
        player1Score = player1Score + 1
        --Check if we've reached the max score and won
        if player2Score == 10 then
            winningPlayer = 1
            gameState = 'done'
        else
            servingPlayer = 2
            gameState = 'serve'
        end
        ball:reset()
    end

    --Move the left paddle up and down.
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if gameMode == 'pVp' then
        --Move the right paddle up and down.
        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
    elseif gameMode == 'pVb' then
        --Bot follows the ball around
        bot:followBall(ball)
    end

    --Update the position of the ball
    if gameState == 'play' then
        ball:update(dt)
    end

    --Update the position of the paddles
    player1:update(dt)
    if gameMode == 'pVp' then
        player2:update(dt) 
    elseif gameMode== 'pVb' then
        bot:update(dt)
    end

    

end

--Checks what key has been pressed
function love.keypressed(key)
    if key == 'escape' then
        --Exit the game
        love.event.quit()
    elseif (key == 'enter' or key == 'return') and (gameState == 'menu' or gameState == 'serve') then
        gameMode = 'pVp'
        if gameState == 'menu' then
            --Set the state to serve
            gameState = 'serve'
            --Stop the main menu music
            menuMusic:stop()
        elseif gameState == 'serve' then 
            --Starts the game
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            --Reset the ball and scores
            ball:reset()
            player1Score = 0
            player2Score = 0
            --If one player wins the other one serves
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        else 
            gameState = 'menu'
            --Reset position of the ball
            ball:reset()
        end
    elseif (key == 'space' or key == 'return') and (gameState == 'menu' or gameState == 'serve') then
        gameMode = 'pVb'
        if gameState == 'menu' then
            --Set the state to serve
            gameState = 'serve'
            --Stop the main menu music
            menuMusic:stop()
        elseif gameState == 'serve' then 
            --Starts the game
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            --Reset the ball and scores
            ball:reset()
            player1Score = 0
            player2Score = 0
            --If one player wins the other one serves
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        else 
            gameState = 'menu'
            --Reset position of the ball
            ball:reset()
        end
    end

end

function love.draw()
    --Called each frame by love after update for drawing things to the screen once they've changed
    push:apply("start")

    --Title of the game
    love.graphics.setFont(smallFont)

    --Check state of the game
    if gameState == 'menu' then
        love.graphics.printf('Press enter to start!', 0,20,VIRTUAL_WIDTH,'center')
    elseif gameState == 'serve' then
        love.graphics.printf('Your turn Player ' .. tostring(servingPlayer) .. '!', 0,20,VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press enter to serve!', 0,30,VIRTUAL_WIDTH,'center')
    elseif gameState == 'play' then
        --Show nothing while playing
    elseif gameState == 'done' then
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' won!', 0,20,VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press enter to play again', 0,30,VIRTUAL_WIDTH,'center')
    else
        love.graphics.printf('Hello Pong!',0,20,VIRTUAL_WIDTH,'center')
    end
    

    --Place the scores
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(1,1,1,0.5)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2-50, VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2+30, VIRTUAL_HEIGHT/3)

    --Rendering the paddles
    player1:render()
    --Render player 2 if selected 2 player mode. Render bot if selected 1 player mode
    if gameMode == 'pVp' then
        player2:render()
    elseif gameMode == 'pVb' then
        bot:render()
    end
    
    --Rendering the ball
    ball:render()


    push:apply("end")
end