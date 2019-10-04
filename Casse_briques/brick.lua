--===============================================
-- Classe Pad dérive de la classe Sprite
--===============================================
require 'class'
require 'sprite'
require 'vector2'

local Brick = class(Sprite, function(c,path,pos, angle, velocity, scale,speed, health, point, color)
         Sprite.init(c,path,pos, angle, velocity, scale,speed, health)  -- must init base!
         c.point = point or 1
         c.color = color or 0
      end)


function Brick:getPoint()
  return self.point
end

function Brick:setPoint(n)
  self.point = n
end

function Brick:getColor()
  return self.color
end

function Brick:setColor(color)
  self.color = color
end

return Brick