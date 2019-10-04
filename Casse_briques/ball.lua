--===============================================
-- Classe Ball dérive de la classe Sprite
--===============================================
require 'class'
require 'sprite'
require 'vector2'


local Ball = class(Sprite, function(c,path,pos, angle, velocity, scale,speed)
    Sprite.init(c,path,pos, angle, velocity, scale,speed)  -- must init base!
    c.radius = 32 / 2
    c.isGlue = false
  end)



--===============================================
-- accesseurs
--===============================================

function Ball:getIsGlue()
  return self.isGlue
end

function Ball:setIsGlue(b)
  self.isGlue = b
end

--===============================================
-- Functions override
--===============================================
function Ball:update(dt, pad)
  -- si balle collée au pad
  if self.isGlue then
    local v = pad:getPos()
    self.pos.x = v.x
    self.pos.y = v.y - self.height
  else --sinon elle bouge
    
    local angle_radian = math.rad(self.angle)
    self.velocity.x  = (math.cos(angle_radian) * (self.speed * dt)) * 1
     self.velocity.y  = (math.sin(angle_radian) * (self.speed * dt)) * 1
    
    self.pos.x = self.pos.x  + self.velocity.x 
    self.pos.y = self.pos.y  + self.velocity.y 
    
  end

  -- rebond à droite et a gauche
  if self.pos.x > screen_width - self.radius then
    --self.velocity.x = self.velocity.x * -1
    if self.velocity.y > 0 then
      self.angle = 135
    else 
      self.angle = 225
    end
    self.pos.x = screen_width - self.radius
  
  
  elseif self.pos.x < self.radius then
    --self.velocity.x = self.velocity.x * -1
    if self.velocity.y > 0 then
      self.angle = 45
    else 
      self.angle = 315
    end
    self.pos.x = self.radius 
  end

  -- rebond en haut
  if self.pos.y < self.radius   then
   -- self.velocity.y = self.velocity.y * -1
   if self.velocity.x > 0 then
      self.angle = 45
    else 
      self.angle = 135
    end
   
    self.pos.y = self.radius 
  end

  
  -- perdu
  if self.pos.y > screen_width then
    self.isAlive = false
    --pad:setLives(-1)
  end

end


-- end update

function Ball:getListSpeed(level)
  speed = 300 + (level * 25)
  return speed
end

return Ball






