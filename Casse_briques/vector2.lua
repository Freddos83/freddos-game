--===============================================
-- Classe Vector2 dérive de la classe mère class
--===============================================
require 'class'


--===============================================
-- Constructeur
--===============================================

Vector2 = class(function(a,x, y)
    a.x = x or 0
    a.y = y or 0
    
  end)

function Vector2:mult(x, y)
  self.x = self.x * x
  self.y = self.y * y
  return Vector2(self.x, self.y)
end


--===============================================
-- TODO Méthodes
--===============================================


