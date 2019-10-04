--===============================================
-- Classe Sprite dérive de la classe mère class
--===============================================

require 'class'
require 'vector2'
--===============================================
-- Constructeur
--===============================================
Sprite = class(function(a,path,pos, angle, velocity, scale,speed, health)
    a.pos = pos or Vector2(0,0)
    a.angle = angle or 0
    a.velocity = velocity or Vector2(0,0)
    a.img = love.graphics.newImage(path)
    a.scale = scale or Vector2(1,1)
    a.originX = a.img:getWidth() / 2
    a.originY = a.img:getHeight() / 2
    a.speed = speed or 0
    a.width = a.img:getWidth()
    a.height = a.img:getHeight()
    a.isAlive = true
    a.health = health or 0
  end)


function Sprite:__tostring()
  return 'Je suis un Sprite ..'
end


--===============================================
-- Accesseurs et mutateurs
--===============================================
function Sprite:getHealth() --number
  return self.health
end

function Sprite:setHealth(h) --number
  self.health = self.health + h
  if self.health < 0 then
    self.health = 0
  end
end

function Sprite:getWidth() -- number
  return self.width
end

--function Sprite:setWidth(w)
--    self.width = w
--end

function Sprite:getHeight() --number
  return self.height
end

--function Sprite:setHeight(h)
--    self.height = h
--end

function Sprite:getOriginX()
  return self.originX
end


function Sprite:setPos(v) --Vector2
  self.pos = v
end

function Sprite:getPos() ---Vector2
  return self.pos
end


function Sprite:setAngle(args) --number en degré
  self.angle = args
end

function Sprite:getAngle() --number en degré
  return self.angle
end

function Sprite:setVelocity(v) --Vector2
  self.velocity = v
end

function Sprite:getVelocity() --Vector2
  return self.velocity
end

function Sprite:setImage(path)
  self.img = love.graphics.newImage(path)
end

function Sprite:getIsAlive() --boolean
  return self.isAlive;
end

function Sprite:setIsAlive(b) --boolean
  self.isAlive = b;
end

function Sprite:getSpeed()
  return self.speed 
end

function Sprite:setSpeed(speed)
  self.speed = speed
end

function Sprite:getScale()
  return self.scale
end

function Sprite:setScale(v)
  self.scale = v
  self.width = self.img:getWidth() * v.x
  self.height = self.img:getHeight() * v.y
  
  --self.originX = self.width / 2
  --self.originY = self.height / 2
end
--==============================================
-- Méthodes
--===============================================

-- Update
function Sprite:update(dt)
end
----------------------------

-- Draw
function Sprite:draw()
  love.graphics.draw(
    self.img,
    self.pos.x,
    self.pos.y,
    math.rad(self.angle),
    self.scale.x,
    self.scale.y,
    self.originX,
    self.originY
  )
end
-----------------------------


