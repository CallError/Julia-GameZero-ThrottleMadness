# initialize screen
WIDTH = 600
HEIGHT = 720
BACKGROUND = colorant"antiquewhite"
header = 120                                        # the header is used to display the score
# adjustable settings
carSize = 20                                        # lower to see what will happen
delayStart = 0.05                                   # delay used to slower the gameloop at start
# settings which proofed OK
delay = delayStart                                  # the delay will get smaller during the game play to accelerate the car
minDelay = 0.001                                    # the delay won't get smaller than this value
edgeDistStart = round(WIDTH/3/carSize/2)*carSize    # distance from the center of the street to the edge of the street to left and right at start
edgeDist = edgeDistStart                            # this value will be lowered during the gameplay, the street will beomce narrower
minEdgeDist = 2*carSize                             # minimum Street width, distance from center to the left and the right.
headerbox = Rect(0, 0, WIDTH, header)               # header box
gameover = false                                    # define gamestatus
score = 0                                           # scare at start
# objects ------------------------------------------------------------------------------------------------------------------
# the car:
carPosY = header+3*(HEIGHT-header)/4                   
carPosX = WIDTH/2 -carSize                          # the car's start position
carColor = colorant"green"                          # the car is green
car = Rect(                                         # the car's shape is a rectangle
    carPosX, carPosY, carSize, carSize
)
# the street:
streetPosX = carPosX                                # center of the street, the streetsrones will be placed left on right on the center of the street with edgeDist 
streetColor = colorant"red"
streetStoneY = HEIGHT
street = []
t = (HEIGHT-header)/carSize
#this function pushes one street stone into the street array
function pushStreetStone()
    push!(street,
        Rect(
            streetStoneX, streetStoneY, carSize, carSize
        )
    )
end
# this function will push one street stone on the left and one on the right side with the distance (edgeDist) to the car into the street array
function pushStreet()
    global streetStoneX
    streetStoneX = streetPosX - edgeDist
    pushStreetStone()
    streetStoneX = streetPosX + edgeDist
    pushStreetStone()
end
# this is loop will fill the street array with the street stones for the game start
for i in 1:t
    global streetStoneY
    streetStoneY -= carSize
    pushStreet()
end
# functions ----------------------------------------------------------------------------------------------------------------------
# extend the street
function growStreet()
    global streetPosX
    global streetStoneY
    # this is generating the left or right "curve"                   
    random = rand(-1:1)
    if streetPosX + random*carSize + edgeDist <= WIDTH - carSize && streetPosX + random*carSize - edgeDist >= 0 # the street will only move to the left or the right, if there is enough space left
        streetPosX += random*carSize
    end
    streetStoneY = header
    pushStreet()
end
#move the car
function moveCar()
    car.x = carPosX
end
#move the street
function moveStreet()
    for i in 1:length(street)                              # this loop pushes every street stone one place down
        street[i].y += carSize
    end
end
# narrow street
function narrowStreet()
    global edgeDist
    dif = round(score/100)*carSize                         # the higher the score the narrower the street will become
    if edgeDistStart - dif > minEdgeDist
        edgeDist = edgeDistStart - dif
    end
end
# score
function scoreAddition()                                   # every game cycle the score will increase by one
    global score
    score += 1
end
# acceleration
function accelerate()
    global delay
    dif = round(score/20)*0.001                             # the higher the score the faster the game will become
    if delayStart - dif > minDelay
        delay = delayStart - dif
    end
end
# collision
function collideCar()
    global gameover
    for i in 1:length(street)
        if collide(car, street[i])                          # this game function checks whether the car rectangle is inside of the street array
            gameover = true
        end
    end
end
# reset
function reset()
    # reset all global variables
    global street, streetStoneY, carPosX, streetPosX, edgeDist, score, delay, gameover
    score = 0
    delay = delayStart
    gameover = false
    edgeDist = edgeDistStart
    streetStoneY = HEIGHT
    carPosX = WIDTH/2 -carSize
    streetPosX = carPosX
    street = []                                     # empty the street array
    for i in 1:t                                    # fill the street array with the start parameters
        streetStoneY -= carSize
        pushStreet()
    end
end
# game functions ---------------------------------------------------------------------------
# draw
function draw(g::Game)
    draw(car, carColor, fill = true)                        # draws the car
    for i in 1:length(street)                               # this loop draws the street stones
        draw(street[i], streetColor, fill = true)
    end
    draw(headerbox, colorant"navyblue", fill = true)
# display score
    if gameover == false
        display = "Score = $score"
    else
        display = "GAME OVER! Final Score = $score"
# play again instructions
        replay = TextActor("Press Up or Down to Play Again", "comicbd";
            font_size = 30, color = Int[0, 0, 0, 255]
        )
        replay.pos = (60, 390)
        draw(replay)
    end
    txt = TextActor(display, "comicbd";
        font_size = 36, color = Int[255, 255, 0, 255]
    )
    txt.pos = (30, 30)
    draw(txt)
end
# update
function update(g::Game)
    if gameover == false
        moveCar()
        moveStreet()
        growStreet()
        popat!(street, 1, 2)
        scoreAddition()
        narrowStreet()
        accelerate()
        sleep(delay)
        collideCar()
    end
end
# controls -------------------------------------------------------------------------------------------------
# car steering and restart
function on_key_down(g::Game, k)
    global carPosX
    global gameover
    if g.keyboard.RIGHT                         # move car to the right
        carPosX += carSize
    elseif g.keyboard.LEFT
        carPosX -= carSize                      # move car to the left
    elseif g.keyboard.DOWN                      # restart
        if gameover == true
            reset()
        end
    elseif g.keyboard.UP                        # restart
        if gameover == true
            reset()
        end
    end
end