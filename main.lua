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
BOT_COLOR = {119/255, 153/255, 51/255}
BALL_COLOR = {220/255, 212/255, 39/255}

WINNING_SCORE = 5

function love.load()
    --Used for initializing the game state at the very beggining.
    love.graphics.setDefaultFilter("nearest", "nearest")

    math.randomseed(os.time())

    --Loads all the fonts for the game
    smallFont = love.graphics.newFont("font.ttf", 8)
    mediumFont = love.graphics.newFont("font.ttf", 24)
    titleFont = love.graphics.newFont("font.ttf", 48)
    scoreFont = love.graphics.newFont("font.ttf", 80)
    miniFont = love.graphics.newFont("font.ttf", 6)

    love.graphics.setFont(smallFont)

    --Load the music files
    menuMusic = love.audio.newSource("Music/menuMusic.mp3", "stream")
    playMusic = love.audio.newSource("Music/playMusic.mp3", "stream")
    winMusic = love.audio.newSource("Music/winMusic.mp3", "stream")

    --Load the game background image
    gameBackground = love.graphics.newImage("Images/gameBackground.png")
    --Load the manu background image
    menuBackground = love.graphics.newImage("Images/menuBackground.jpg")

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
    ballMiss1 = love.audio.newSource("Sound/ballMiss1.ogg", "static")
    ballMiss2 = love.audio.newSource("Sound/ballMiss2.ogg", "static")
    ballMiss3 = love.audio.newSource("Sound/ballMiss3.ogg", "static")
    ballMiss4 = love.audio.newSource("Sound/ballMiss4.ogg", "static")

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

    if gameState == 'menu' then
        menuMusic:play()


    --Sets the correct serving for each player
    elseif gameState == 'serve' then
        goodServe = false
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

            --Make the ball bounce away from the walls
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
            goodServe = true
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
                goodServe = true
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
                goodServe = true
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
        --Chech if a player missed the serve
        if goodServe == false then
            --Play the sound for a missed serve
            randomSound = math.random(1, 4)
                if randomSound == 1 then
                    collision1:play()
                    ballMiss1:play()
                elseif randomSound == 2 then
                    collision2:play()
                    ballMiss2:play()
                elseif randomSound == 3 then
                    collision3:play()
                    ballMiss3:play()
                else 
                    collision4:play()
                    ballMiss4:play()
                end
        end
        --Increase the corresponding players score
        player2Score = player2Score + 1
        --Check if we've reached the max score and won
        if player2Score == WINNING_SCORE then
            winningPlayer = 2
            gameState = 'done'
            --Play won music
            winMusic:play()
        else
            servingPlayer = 1
            gameState = 'serve'
        end
        ball:reset()
    end

    --If the ball gets out of player2's goal, give score to player 1
    if ball.x > VIRTUAL_WIDTH then
        --Chech if a player missed the serve
        if goodServe == false then
            --Play the sound for a missed serve
            randomSound = math.random(1, 4)
                if randomSound == 1 then
                    collision1:play()
                    ballMiss1:play()
                elseif randomSound == 2 then
                    collision2:play()
                    ballMiss2:play()
                elseif randomSound == 3 then
                    collision3:play()
                    ballMiss3:play()
                else 
                    collision4:play()
                    ballMiss4:play()
                end
        end
        --Increase the corresponding players score
        player1Score = player1Score + 1
        --Check if we've reached the max score and won
        if player1Score == WINNING_SCORE then
            winningPlayer = 1
            gameState = 'done'
            --Play won music
            winMusic:play()
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
    elseif (key == 'enter' or key == 'return') and (gameState == 'menu' or gameState == 'serve' or gameState == 'done') then
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

    --Check if we are on the menu or playing
    if gameState == 'menu' then
        --Draw all the menu things
        love.graphics.draw(menuBackground, 0, 0, 0 ,0.361, 0.35)
        love.graphics.setFont(titleFont)
        love.graphics.printf('Pong', 0, 20,VIRTUAL_WIDTH,'center')
        love.graphics.setFont(mediumFont)
        --Show the game modes
        love.graphics.printf('Press space for 1 Player mode!', 0, 170, VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press enter for 2 Players mode!', 0, 200, VIRTUAL_WIDTH,'center')
        --Credits
        love.graphics.setFont(miniFont)
        love.graphics.printf('Modified by Jose Antonio Solis Martinez', 0, 230, VIRTUAL_WIDTH,'right')
    else
        --Draw the game things 
    
        --Draw background image
        love.graphics.draw(gameBackground, 0, 0, 0, 0.7, 0.5)

        --Set the regular text font
        love.graphics.setFont(smallFont)

        --Check state of the game
        if gameState == 'serve' then
            if gameMode == 'pVp' then
                -- 2 Player mode graphics
                love.graphics.printf('Your turn Player ' .. tostring(servingPlayer) .. '!', 0,20,VIRTUAL_WIDTH,'center')
                love.graphics.printf('Press enter to serve!', 0,30,VIRTUAL_WIDTH,'center')
            else
                -- 1 Player mode graphics
                if servingPlayer == 1 then
                    love.graphics.printf('Your turn Player ' .. tostring(servingPlayer) .. '!', 0,20,VIRTUAL_WIDTH,'center')
                else
                    love.graphics.printf('It\'s the turn of the computer!', 0,20,VIRTUAL_WIDTH,'center')
                end
                love.graphics.printf('Press space to serve!', 0,30,VIRTUAL_WIDTH,'center')
            end
        elseif gameState == 'play' then
            --Show nothing while playing
        elseif gameState == 'done' then
            RAINBOW_COLOR = {math.random(0, 255)/255, math.random(0, 255)/255, math.random(0, 255)/255}
            love.graphics.setColor(RAINBOW_COLOR)
            if gameMode == 'pVb' and winningPlayer == 2 then
                love.graphics.printf('The computer won!', 0,20,VIRTUAL_WIDTH,'center')
            else
                love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' won!', 0,20,VIRTUAL_WIDTH,'center')
            end
            love.graphics.setColor(255,255,255)
            love.graphics.printf('Press enter or space to play again', 0,30,VIRTUAL_WIDTH,'center')
        else
            love.graphics.printf('Hello Pong!',0,20,VIRTUAL_WIDTH,'center')
        end
        

        --Place the scores
        love.graphics.setFont(scoreFont)
        love.graphics.setColor(1, 1, 1, 0.1)
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/5, 0)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH-125, 0)

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
    end

    --Reset color
    love.graphics.setColor(255,255,255)

    push:apply("end")
end