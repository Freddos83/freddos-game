--powerup
--===============================================
-- Classe Powerup dérive de la classe Sprite
--===============================================
require 'class'
require 'sprite'
require 'vector2'

local PowerUp = class(Sprite, function(c,path,pos, angle, velocity, scale,speed, t)
    Sprite.init(c,path,pos, angle, velocity, scale,speed)  -- must init base!
    c.type = t or 0
    
  end)



function PowerUp:getType()
  return self.type
end

function PowerUp:setType(t)
  self.type = t
end

function PowerUp:update(dt)
  
  self.pos.x = self.pos.x  + (self.velocity.x * dt)
  self.pos.y = self.pos.y  + (self.velocity.y * dt)
  
  if self.pos.y > screen_height then
    self.isAlive = false
  end
  
end

return PowerUp

