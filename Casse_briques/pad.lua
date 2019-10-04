--===============================================
-- Classe Pad dérive de la classe Sprite
--===============================================
require 'class'
require 'sprite'
require 'vector2'

local Pad = class(Sprite, function(c,path,pos, angle, velocity, scale,speed)
    Sprite.init(c,path,pos, angle, velocity, scale,speed)  -- must init base!
    c.lives = 3
    c.score = 0
  end)

function Pad:update(dt)
  self.pos.x = love.mouse.getX()
  if self.pos.x < self.width / 2 then
    self.pos.x = self.width / 2
  elseif self.pos.x > screen_width - self.width / 2 then
    self.pos.x = screen_width - self.width / 2

  end
end


function Pad:getLives()
  return self.lives
end

function Pad:setLives(lives)
  self.lives = self.lives + lives
  
end

function Pad:getScore()
  return self.score 
end

function Pad:setScore(score)
  self.score = self.score + score
end

return Pad