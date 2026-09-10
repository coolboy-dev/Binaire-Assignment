function _init()
p = {x=1,y=54}
i = {x=123,y=54}
b ={x=64,y=64,dx=1,dy=1}
puntos ={p=0,i=0}
end

--logica
function _update()
move_player()
move_ball()
ball_bounce()
opp_follow()
opp_bounce()
player_bounce()
check_puntos()
end
-- dibujo
function _draw()
cls(0) 
--p1
rectfill(p.x,p.y,p.x+3,p.y+15,7) 
--p2
rectfill(i.x,i.y,i.x+3,i.y+15,7)
--ball
circfill(b.x,b.y,2,7)
print(puntos.p,54,5,12)
print(puntos.i,74,5,8)
end
-->8
-- player move
function move_player()
	if (btn(2)and p.y>0)p.y-=2
	if (btn(3)and p.y<112)p.y+=2
end
-->8
--ball
function move_ball()
	b.x+=b.dx
	b.y+=b.dy
end

function ball_bounce()
 if b.y>124 then
 b.dy=-b.dy
 end
 if b.y<4 then
 b.dy=-b.dy
 end
end
-->8
--ia
function opp_follow()
-- solo se mueve si la distancia es mayor a 1.5
 if abs(i.y - b.y) > 1.5 and b.x>86 then 
  if i.y+15 < b.y then
   i.y += 1.5
  elseif i.y > b.y then
   i.y -= 1.5
  end
 end
end
-->8
--bounce
function opp_bounce()
 if b.y>=i.y and
  b.y<=i.y+15 and
  b.x==i.x-3 then
   b.dx=-b.dx
   sfx(0)
   
   -- calcular centro de la paleta e impacto
   local centro = i.y + 8
   -- cambia el angulo segun la distancia al centro
   b.dy = (b.y - centro) * 0.2
 end
end

function player_bounce()
 if b.y >= p.y and
  b.y <= p.y + 15 and
  b.x <= p.x + 3 then
   b.dx = -b.dx
   sfx(0)
   
   -- calcular centro de la paleta e impacto
   local centro = p.y + 8
   -- cambia el angulo segun la distancia al centro
   b.dy = (b.y - centro) * 0.2
 end
end

-->8
--puntos
function check_puntos()
 if b.x <= 0 then
  b.x = 64
  b.y = 64
  b.dx = 1   -- reinicia direcci??n
  puntos.i += 1
 elseif b.x >= 127 then
  b.x = 64
  b.y = 64
  b.dx = -1  -- reinicia direcci??n
  puntos.p += 1
 end
end
