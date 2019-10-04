-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest")

-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

local Ball = require 'ball'
local Pad = require 'pad'
local Brick = require 'brick'
local PowerUp = require 'powerup'
require 'vector2'
local level = require('levels') -- contient les niveaux du jeu

-- =========================================
-- Variables Globales
--==========================================
test_debug = 0
isPlaySong = false

local highscore = {}
local fic = assert(io.open("score.txt","r"))


repeat

  local v1 = fic:read('*l')
  if v1 ~= nil then
    table.insert(highscore, v1)
  end

until v1 == nil
fic:close()


screen_width = love.graphics.getWidth()
screen_height = love.graphics.getHeight()

local Balls_Sprite = {} -- liste des balles
local Bricks_Sprite = {} -- liste des sprite briques
local PowerUp_Sprite = {} -- liste des sprites powerup
local listPathPowerUp = {}
listPathPowerUp[1] = "res/images/powerup_health.png"
listPathPowerUp[2] = "res/images/powerup_missiles.png"
listPathPowerUp[3] = "res/images/paddle-expand.png"
listPathPowerUp[4] = "res/images/paddle-shrink.png"

local niveau = 0
local Padding, Balling -- objets du jeu
local delai_level = 3
local time_delai = 0
local display_level = true
local liste_colors = {}
for i=0, 30 do 
  liste_colors[i] = {love.math.random(), love.math.random(), love.math.random()}
end
--liste_colors[0] = {0,0,0} -- noir
--liste_colors[1] = {1,1,1} -- blanc

local font_large,font_normal,font_small
local imgBackground, imgBackgroundDoIs, bg,img_splash,imgUI
local snd_hit ,  snd_explose ,  snd_start , snd_powerUp, snd_level_end, music_game 

local state_game = {['start'] = 1, ['run']=2, ['pause']=3, ['end'] = 4, ['highscore']=5}
local state
-- =========================================
-- Functions LOVE
--==========================================
function love.load()
  --load fonts
  font_large = love.graphics.newFont("res/fonts/xirod.ttf", 40)
  font_normal = love.graphics.newFont("res/fonts/xirod.ttf", 20)
  font_small = love.graphics.newFont("res/fonts/xirod.ttf", 10)

  --Create pad
  Padding = Pad("res/images/paddle.png", Vector2(screen_width / 2, screen_height - 100))
  --Create ball
  table.insert(Balls_Sprite, Ball("res/images/ball.png"))

  -- Background
  imgBackground = love.graphics.newImage("res/images/etoile11.jpg")
  imgBackgroundDoIs = love.graphics.newImage("res/images/etoile11.jpg")
  bg = {
    x = 0,
    y = 0,
    y2 = 0 - imgBackground:getHeight(),
    velocity = 30
  }

  --Spash screen
  img_splash = love.graphics.newImage("res/images/splash.jpg")

  --UI
  imgUI = love.graphics.newImage("res/images/floorpadside3x3.jpg")

  --Musi and sound
  snd_hit = love.audio.newSource("res/sounds/drum.wav", "static")
  snd_explose = love.audio.newSource("res/sounds/Shiphit.wav", "static")
  snd_start = love.audio.newSource("res/sounds/start.wav", "static")
  snd_powerUp = love.audio.newSource("res/sounds/magic1.wav", "static")
  snd_level_end = love.audio.newSource("res/sounds/but.wav", "static")
  music_game =love.audio.newSource("res/sounds/Latina.mp3", "stream")

  --Mouse
  love.mouse.setVisible(false)
  
  -- state game
  state = state_game.start
  
end -- end Load
--==========================================================================
function love.update(dt)
--==========================================================================

  -- si partie en cours
  if state == state_game_run then
    update_game_run(dt)
  end
  ----------------------------------

  -- si ecran demmarage
  if state == state_game.start then
    if not isPlaySong then
      snd_start:play()
      isPlaySong = true
    end
    update_game_start(dt)
  end

end --update
--==========================================================================
function love.draw()
--=========================================================================
  draw_background()

  -- Si le jeu est en mode running on dessine les gameObjects
  if state == state_game.run or state == state_game.pause then
    draw_game_run()
  end

  -- si jeu perdu on affche game over
  if state == state_game['end'] then
    draw_game_over()
  end

  ----------------------------
  if state == state_game['start'] then
    love.graphics.draw(img_splash, 0 ,0)
  end
  ----------------------------------------
  
  if state == state_game['highscore'] then
    draw_highscore()
  end

  -- si debug Debug
--  love.graphics.setFont(font_small)
--  love.graphics.print("Debug " .. test_debug, 10, screen_height - 80)

  -- si display
  display_fps()
end
-------------------------------------------
-- =========================================
-- Functions Process input
--==========================================
function love.mousepressed(x,y,button)
  if button == 1 and not end_level then
    for i, v in ipairs(Balls_Sprite) do
      v:setIsGlue(false)
      v:setVelocity(Vector2(0, 0))
      v:setAngle(love.math.random(240,300)) -- entre 240 et 300
      v:setSpeed(Ball:getListSpeed(niveau)) --400 depart
    end
  end
end
------------------------------------------------------
function love.keyreleased(key)
  if key == 'escape' then
    love.event.quit(0)
  end
  if key == 'p' then
    if state ~= state_game.pause then
      state = state_game.pause
    else
      state = state_game.run
    end
  end

  if key == 'space' and state == state_game['end'] then
    niveau = 0
    Padding:setLives(3)
    Padding:setScale(Vector2(1,1))
    local s = Padding:getScore()
    Padding:setScore(-s)
    state = state_game.run
    Balls_Sprite = {}
    local B = Ball("res/images/ball.png")
    B:setIsGlue(true)
    table.insert(Balls_Sprite, B )
    snd_start:play()
    start()
  end

end
------------------------------------------------------
-- =========================================
-- Functions Game
--==========================================

--fun start
function start()
  music_game:play()
  music_game:setLooping(true)
  niveau = niveau + 1
  Bricks_Sprite = {}

  local stage = niveau
  --**************
  local bx, by = level[stage].startX, level[stage].startY  -- postion de départ

  local br = Brick("res/images/brick-gray.png")--contiendra objet brick
  local lig, col
  local offsetX = level[stage].offsetX
  local offsetY = level[stage].offsetY
  for lig = 1, level[stage].lig do
    bx = level[stage].startX
    for col = 1, level[stage].col do
      if level[stage].niveau[lig][col] > 0 then

        br = Brick("res/images/brick-gray.png", Vector2(bx, by),0, Vector2(0,0), Vector2(1,1),0,0, niveau, level[stage].niveau[lig][col])

        br:setHealth(love.math.random(0, niveau))
        table.insert(Bricks_Sprite, br)
      end
      bx = bx + br:getWidth() + offsetX
    end
    by = by + br:getHeight() + offsetY
  end

  time_delai = 0
  display_level = false
  end_level = false

end --start
------------------------------------------------------
--====================================================
-- fonctions Collision
--====================================================
function Collision()

  collision_pad_ball()

  collision_pad_powerUp()

  collision_ball_brick()


end --collision
---------------------------------------------------------
function collision_ball_brick()
  for j, b in ipairs(Balls_Sprite) do
    --=================================
    -- si collision avec la brique
    --==================================
    for i, v in ipairs(Bricks_Sprite) do
      if v:getIsAlive() then
        if CheckCollision(v:getPos().x, v:getPos().y, v:getWidth(), v:getHeight(), b:getPos().x, b:getPos().y, b:getWidth(),b:getHeight()) then

          local brickPercentHit = (b:getPos().x - v:getPos().x) / v:getWidth();
          -- si balle monte y -
          if b:getVelocity().y < 0 then
            if b:getVelocity().x > 0 then
              --voir si touche coté gauche
              if b:getPos().y > v:getPos().y + 16 then
                b:setAngle( 45 + ( 135 - 45) * 0.5 * brickPercentHit)
                b:setPos (Vector2( b:getPos().x, v:getPos().y + b:getHeight()))
              else
                b:setAngle(225)
                b:setPos (Vector2( b:getPos().x - b:getWidth(), v:getPos().y))
              end
            else
              --voir si touche coté droit
              if b:getPos().y > v:getPos().y + 16 then
                b:setAngle( 135 + ( 45 - 135) * 0.5 * brickPercentHit)
                b:setPos (Vector2( b:getPos().x, v:getPos().y + b:getHeight()))
              else
                b:setAngle(315) --
                b:setPos (Vector2( b:getPos().x + b:getWidth(), v:getPos().y))
              end
            end
            --  b:setPos (Vector2( b:getPos().x, v:getPos().y + b:getHeight()))
          else
            -- si balle descend y +
            if b:getVelocity().x < 0 then
              if b:getPos().y < v:getPos().y - 16 then
                b:setAngle( 225 + ( 315 - 225) * 0.5 * brickPercentHit)
                b:setPos (Vector2( b:getPos().x, v:getPos().y - b:getHeight()))
              else
                b:setAngle(45)
                b:setPos (Vector2( b:getPos().x + b:getWidth(), v:getPos().y))
              end
            else
              if b:getPos().y < v:getPos().y - 16 then
                b:setAngle( 315 + ( 225 - 315) * 0.5 * brickPercentHit)
                b:setPos (Vector2( b:getPos().x, v:getPos().y - b:getHeight()))
              else
                b:setAngle(135)
                b:setPos (Vector2( b:getPos().x - b:getWidth(), v:getPos().y))
              end
            end
          end
          snd_hit:play()
          v:setHealth(-1) -- enleve de la santé à la brique
          -- b:setSpeed(Ball:getListSpeed(niveau))
          v:setColor(v:getHealth())
          if v:getHealth() <= 0 then -- si brique santé = 0 rajoute point et détruit brique
            Padding:setScore(v:getPoint())
            -- create powerUp
            create_powerUp(v:getPos())
            table.remove(Bricks_Sprite,i)

          end
        end
      end
    end
  end
end

--------------------------------------------------
function collision_pad_powerUp()
  --=================================
  -- si collision pad avec le powerup
  --==================================
  for i, v in ipairs(PowerUp_Sprite) do
    if CheckCollision(Padding:getPos().x - Padding:getWidth() / 2, Padding:getPos().y - Padding:getHeight()/2 , Padding:getWidth(), Padding:getHeight(), v:getPos().x -  v:getWidth() / 2, v:getPos().y - v:getHeight()/2, v:getWidth(), v:getHeight()) then
      -- on recupère le type du power up
      local tp = v:getType()
      if tp == 1 then
        --rajoute +1 vie
        Padding:setLives(1) -- on rajoute une vie
        Padding:setScore(100) -- on rajoute 100pt au score
      elseif tp == 2 then-- on crée une 2ème balle
        --Create une ball supplementaire
        table.insert(Balls_Sprite, Ball("res/images/ball.png",Vector2(Padding:getPos().x, Padding:getPos().y),love.math.random(240,300), Vector2(0,0), Vector2(1,1), 400))
        Padding:setScore(50)
      elseif tp == 3 then
        --create geant pad
        Padding:setScale(Vector2(1.5,1))
        Padding:setScore(10)
      else
        --create mini pad
        Padding:setScale(Vector2(0.5,1))
        Padding:setScore(50 * niveau)
      end
      -- on suprime le powerup de la liste
      table.remove(PowerUp_Sprite, i)
      snd_powerUp:play()
    end
  end
end

--------------------------------------------------
function collision_pad_ball()
  for j, b in ipairs(Balls_Sprite) do

    if CheckCollision(Padding:getPos().x - Padding:getWidth() / 2, Padding:getPos().y - Padding:getHeight()/2 , Padding:getWidth(), Padding:getHeight(), b:getPos().x -  b:getWidth() / 2, b:getPos().y - b:getHeight()/2, b:getWidth(), b:getHeight()) then

      local paddlePercentHit = (b:getPos().x - b:getPos().x) / Padding:getWidth();
      if b:getVelocity().x > 0 then
        b:setAngle( 315 + ( 225 - 315) * 0.5 * paddlePercentHit)
      else
        b:setAngle( 225 + ( 315 - 225) * 0.5 * paddlePercentHit)
      end
      b:setPos (Vector2( b:getPos().x, Padding:getPos().y - b:getHeight()))
      snd_hit:play()
    end

  end

end

--------------------------------------------------

--====================================================
-- fonction Scroll Background
--====================================================
function scrollBackground(dt)
  bg.y = bg.y + bg.velocity * dt
  bg.y2 = bg.y2 + bg.velocity * dt

  if bg.y > screen_height then
    bg.y = bg.y2 - imgBackgroundDoIs:getHeight()
  end
  if bg.y2 > screen_height then
    bg.y2 = bg.y - imgBackground:getHeight()
  end
end
-------------------------------------------

--====================================================
-- fonctions UI
--====================================================
function display_ui()

  love.graphics.draw(imgUI,2,  screen_height - 80) -- fond affichage rectangle gris
  love.graphics.setColor(12/255,10/255,72/255, 1) --   33, 32, 47 
  love.graphics.setFont(font_large)
  love.graphics.print("Lives : ".. Padding:getLives() .. "  " .. "Level: " .. niveau .. "  Score: "..Padding:getScore(), 30, screen_height - 50, 0, 0.7,0.7)

  love.graphics.setColor(1,1,1)
end


-------------------------------------------------------

function level_over()
  if #Bricks_Sprite == 0 and not end_level then
    end_level = true
    display_level = true
    Balls_Sprite = {}
    table.insert(Balls_Sprite, Ball("res/images/ball.png"))
    for i, b in ipairs(Balls_Sprite) do
      b:setIsGlue(true) -- balle collée au pad
    end
    Padding:setScale(Vector2(1,1))
    PowerUp_Sprite = {}
    music_game:stop()
    snd_level_end:play()

  end
end

function level_start(dt)
  if end_level then 
    time_delai = time_delai + dt
    if time_delai > delai_level then
      start()
    end
  end
end

function level_game_over()
  if Padding:getLives() <= 0 then
    state = state_game['end']
    PowerUp_Sprite = {}
    music_game:stop()
  end
end

--====================================================
-- fonctions Créations objets
--====================================================
function create_powerUp(pos)
  -- une chance sur 3
  rnd = love.math.random()
  if rnd < 0.30 then
    rnd2 = love.math.random()

    if rnd2 <= 0.01 then
      tp = 1 --lives + 1
    elseif rnd2 > 0.01 and rnd2 <= 0.10 then
      tp = 2 -- 2 ball
    elseif rnd2 > 0.10 and rnd2 <= 0.40 then
      tp = 3 --max pad
    elseif rnd2 >0.40 and rnd2 <= 1 then
      tp = 4 --min pad
    end
    local P = PowerUp(listPathPowerUp[tp], Vector2(pos.x, pos.y),0, Vector2(0, 100), Vector2(1,1),0,0)
    P:setType(tp)
    table.insert(PowerUp_Sprite,P)
  end

end

-------------------------------------------------------

-- =========================================
-- Functions Draw game
--==========================================

function draw_background()
  love.graphics.draw(imgBackground, bg.x, bg.y)
  love.graphics.draw(imgBackgroundDoIs, bg.x, bg.y2)
end

function draw_game_over()

  love.graphics.setFont(font_large)
  love.graphics.setColor(0,0,1)
  love.graphics.print("G A M E  O V E R" , (screen_width/4) - 50, screen_height / 3,0, 1, 1)
  love.graphics.setFont(font_normal)
  love.graphics.print("Press <space> to start" , (screen_width/4) , screen_height / 2,0, 1, 1)
  love.graphics.setColor(1,1,1)

end

function draw_highscore()
  love.graphics.setFont(font_large)
  love.graphics.setColor(0,0,1)
  love.graphics.print("HIGHSCORE" , (screen_width/4) , 10,0, 1, 1)
  love.graphics.setFont(font_normal)
  love.graphics.setColor(1,0,0)
  love.graphics.print("Rang   Name   Level    score" , (screen_width/6) , screen_height / 6,0, 1, 1)
  
  love.graphics.setColor(0,1,0)
  for i, v in ipairs(highscore) do
    love.graphics.print(tostring(i) .."  " .. v, (screen_width/6) , screen_height /6 + 60 * i,0, 1, 1)
  end
  
  love.graphics.setColor(0,0,1)
  love.graphics.print("Press <space> to start" , (screen_width/4) , screen_height - 30,0, 1, 1)
  love.graphics.setColor(1,1,1)
end

function draw_game_run()

  --Objets du jeu
  Padding:draw()

  for i, v in ipairs(Balls_Sprite) do
    v:draw()
    test_debug = v:getAngle()
  end

  --Draw bricks
  for i, v in ipairs(Bricks_Sprite) do
    r,g,b = liste_colors[v:getColor()]
    love.graphics.setColor(r,g,b)
    v:draw()
    love.graphics.setColor(1,1,1)
  end

  --Draw powerup
  for i, v in ipairs(PowerUp_Sprite) do
    v:draw()
  end


  --Draw change level
  if end_level then
    love.graphics.setFont(font_large)
    love.graphics.setColor(0,0,1)
    love.graphics.print("L E V E L   ".. (niveau+1) , (screen_width/4) - 10, screen_height / 2,0, 1, 1)
    love.graphics.setColor(1,1,1)
  end

  -- Draw ui always displays
  display_ui()

  ---------------------------------------
end


-- =========================================
-- Functions Updates
--==========================================
function update_game_run(dt)
  scrollBackground(dt)
  Padding:update(dt)
  --balls
  for i, v in ipairs(Balls_Sprite) do
    if v:getIsAlive() then
      v:update(dt, Padding)
    else
      table.remove(Balls_Sprite, i)
      if #Balls_Sprite == 0 then
        Padding:setLives(-1)
      end
    end
  end
  --powerup
  for i, v in ipairs(PowerUp_Sprite) do
    if not v:getIsAlive() then
      table.remove(PowerUp_Sprite, i)
    else
      v:update(dt)
    end
  end

  Collision()
  level_over()
  level_start(dt)
  level_game_over()

  if #Balls_Sprite == 0 then
    --Create ball
    local B = Ball("res/images/ball.png")
    B:setIsGlue(true)
    table.insert(Balls_Sprite, B )
    Padding:setScale(Vector2(1,1))
    PowerUp_Sprite = {}
  end

end

function update_game_start(dt)
  if time_delai > 2 then
    state = state_game.highscore
    time_delai = 0
    isPlaySong = false
  else
    time_delai = time_delai + dt
  end
end

-- =========================================
-- Functions Utils
--==========================================
function display_fps()
  love.graphics.setFont(font_small)
  love.graphics.setColor(0,1,0)
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, screen_height - 100)
  love.graphics.setColor(1,1,1)
end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end
--------------------------------------------------
