local level = {}

local offsetX = 2
local offsetY = 4
local tile_width = 64
local color = 0


for i=1, 30 do --2 niveau
  local col = love.math.random(6,12)
  local lig = love.math.random(4,8)
  
  level[i] = {}
  level[i].lig = lig
  level[i].col = col
  level[i].offsetX = offsetX
  level[i].offsetY = offsetY
  local x = col  * (tile_width + offsetX)
  level[i].startX = ((love.graphics.getWidth() - x) / 2) + 32
  level[i].startY = (9 - lig) * 30
  
  level[i].niveau = {}
  for l=1, lig do
    level[i].niveau[l] = {}
    for c = 1, col do
      level[i].niveau[l][c] = love.math.random(0,30)
    end
  end
end

--level[1] = {}
--level[1].lig = 8 --6
--level[1].col = 12-- 12 max
--level[1].offsetX = 2
--level[1].offsetY = 4
--level[1].startX = 32 --32 mini
--level[1].startY = 30
--level[1].niveau = {
--  {4,4,4,4,4,4,4,4,4,4,4,4,4},
--  {4,4,4,4,4,4,4,4,4,1,2,2,4},
--  {2,1,1,1,2,2,2,2,1,2,2,2,2},
--  {2,1,4,4,4,4,4,1,2,2,2,1,2},
--  {1,1,1,1,1,1,1,1,1,1,1,1,1},
--  {4,1,4,4,4,4,4,1,2,2,2,1,2},
--  {4,1,1,1,2,2,2,2,1,2,2,2,2},
--  {4,4,4,4,4,4,4,4,4,1,4,4,4}
--}

--level[2] = {}
--level[2].lig = 6
--level[2].col = 12
--level[2].offsetX = 2
--level[2].offsetY = 2
--level[2].startX = 34
--level[2].startY = 30
--level[2].niveau = {
--  {2,2,2,2,2,2,2,2,2,2,2,2},
--  {2,0,1,1,1,1,1,1,1,1,0,2},
--  {2,0,1,1,0,0,0,1,1,1,0,2},
--  {2,0,1,1,0,0,0,1,1,1,0,2},
--  {2,0,1,1,1,1,1,1,1,1,0,2},
--  {2,2,2,2,2,2,2,2,2,2,2,2}
--}

--level[3] = {}
--level[3].lig = 5
--level[3].col = 6
--level[3].offsetX = 2
--level[3].offsetY = 2
--level[3].startX = 134
--level[3].startY = 60
--level[3].niveau = {
--  {4,4,4,4,4,4},
--  {4,1,1,1,1,4},
--  {5,1,1,1,1,5},
--  {2,1,1,1,1,5},
--  {2,2,1,1,2,2}
--}


return level