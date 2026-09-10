--main
mano = {}
function _init()

estado = "jugando"

dek= {2,2,2,1,2,2,2,1,2,2,2,1,2,2,2,1}

function health()
r1.qnty = r1.qnty +1
end

function still_card()
if #dek == 0 then return end
local i = dek[flr(rnd(#dek))+1]
local t = dek[1]
del(dek, t)
if t == 1 then
add(mano,card:new(40))
else
local c = card:new(9,health)
c:util()
end
end

//poke (0x5f2d, 1)--start mou
b= board:new(8,8)

b:reg_t(8)
b:reg_t(22)
b:reg_t(24)

d1= die:new(6)
d1.x=5
d1.y=120
d2 = die:new(50)
d2.x = 120
d2.y = 5

r1= rsrc:new(8,4)

p1 = pawn1:new(b,0)
p2 = pawn2:new(b,44)

p2.x = 8
p2.y = 1

p1.mov = 0

end

function _update()
if estado  != "jugando" then return end

cls()
//mou:updt()
d1:updt()
d2:updt()
r1:updt()

if (btnp(5)) then
d1:roll()
d2:roll()
p1.mov = d1.num --juego le da el valor del dado al move
for i= 1,d2.num do
p2:steps()
end
if p2.x == p1.x and p2.y == p1.y then
r1.qnty= r1.qnty-1
end
 end
 
--arrows
if btnp(0) then p1:move(-1,0) end
if btnp(1) then p1:move(1,0) end
if btnp(2) then p1:move(0,-1) end
if btnp(3) then p1:move(0,1) end


if #mano >=4 then
estado = "ganaste"
end 
if r1.qnty <= 0 then
estado = "game over"
end
end

function _draw()
map()
//mou:draw()
p1:draw()
d1:draw()
d2:draw()
p2:draw()
r1:draw()

rectfill(113,2,16,7,10)
rectfill(125,120,16,125,10)
print ("usa flechas para moverte",16,2,2)
print ("presona x para usar el dado",16,120,2)

for i = 1, #mano do
mano [i].x = 20 +(i-1)*18
mano [i].y = 116
mano [i]:updt()
mano [i]:draw()
end
if estado == "ganaste" then
rectfill(0,0,150,150,0)
print ("ganaste!",48,60,11)
end
if estado == "game over" then
rectfill(0,0,150,150,0)
print ("game over",48,60,8)
  end

end
--utility
smt = setmetatable
-->8
--board
board =
{
reg,
ix,
iy
}

function board:new(x,y)
local b=smt({},{__index=board})
 b.ix=x or 0
 b.iy=y or 0
 b.reg={}
 return b
end

function board:reg_t(id,u)
function no_use() end
self.reg[id]=u or no_use
end
function board:get_u(id)
return self.reg[id]
end
-->8
--mouse

mou= 
{
x=0,
y=0,
dx=0,
dy=0,
s=0
}
function mou:updt()
 local nx = stat(32)
 local ny = stat(33)
 self.dx=nx-self.x
 self.dy=ny-self.y
 self.x=nx
 self.y=ny
 
 --clck
 if stat (34) == 1 then
   if self.s == 0 then self.s=1
   elseif self.s ==1 then self.s=2
   end
   --rlse
   else
     if self.s==1 then self.s=3
     elseif self.s==2 then self.s=3
     elseif self.s==3 then self.s=0
     end
    end
  end
  
function mou:draw()
local m=self
local c = 8
if m.s==1 then c=4 end
if m.s==2 then c=11 end
circfill(m.x,m.y,4,c)
end


-->8
--pawn1

pawn1=
{
x,y,px,py,ox=0,oy=0,sprt
}

function pawn1:new(b,s)
  local p1=smt({},{__index=pawn1})
  p1.x = b.ix
  p1.y = b.iy
  p1.px=p1.x
  p1.py=p1.y
  p1.sprt=s
  return p1
end


function pawn1:draw()
local m=self
spr(m.sprt,(m.x*8)+m.ox,(m.y*8)+m.oy)
end

function pawn1:move(dx,dy)
 if self.mov <=0 then return end
 local newx = self.x + dx
 local newy = self.y + dy
 if not fget(mget(newx,newy),0) then
 self.x = newx
 self.y = newy 
 self.mov = self.mov -1
 if self.x == p2.x and self.y == p2.y then
 r1.qnty = r1.qnty - 1
 end 
 if fget(mget(newx,newy),2) then
 still_card()
 mset(newx,newy,18)
 end
 if fget (mget(newx, newy),1) then
 r1.qnty = r1.qnty - 1
 mset(newx,newy,18)
 end
 end
end  
-->8
--die
die =
{
x=0, y=0, ox= 0, oy=0, fcnt, num=1,
}

function die:new(n)
 local d = smt({},{__index=die})
 d.fcnt = n or 6
 return d
end



function die:updt()
end

function die:draw()
local m=self
circfill(m.x,m.y,5,5)
print (m.num,m.x+m.ox,m.y+m.oy,2)
end

function die:roll()
self.num = flr(rnd(self.fcnt))+1
end


-->8
--pawn 2
pawn2=
{
x,y,px,py,ox=0,oy=0,sprt, dx=0, dy=0, dir
}

function pawn2:new(b,s)
  local p2=smt({},{__index=pawn2})
  p2.x = b.ix
  p2.y = b.iy
  p2.px=p2.x
  p2.py=p2.y
  p2.sprt=s
  return p2
end


function pawn2:draw()
local m=self
spr(m.sprt,(m.x*8)+m.ox,(m.y*8)+m.oy)
end

function pawn2:steps()
local dir = flr(rnd(4))+1
local dx = 0
local dy = 0
if dir == 1 then dx= -1 end
if dir == 2 then dx= 1  end
if dir == 3 then dy= -1 end
if dir == 4 then dy= 1 end
local newx = self.x + dx 
local newy = self.y + dy 
if not fget(mget(newx,newy),0) then
 self.x = newx
 self.y = newy 
 
 end
end
-->8
--resource
rsrc = 
{
x = 0, y=0, ox= 0, oy=0,sprt
}
function rsrc:new(s,q)
local r = smt({},{__index=rsrc})
r.sprt=s
r.qnty=q or 0
return r
end

function rsrc:updt()
end

function rsrc:draw()
local m = self
spr(m.sprt,m.x+m.ox, m.y+m.oy)
print("x"..m.qnty,m.x+m.ox+8,m.y+m.oy,7)
end
-->8
--cards

card=
{
x = 0, y = 0, ox= 0, oy = 0, sprt, util
}
function no_use() end

function card:new(s, u)
local c=smt ({},{__index = card})
c.sprt = s

 c.util =  u or no_use
 return c
 end
 
 
function card:updt()
 self.oy = sin(time()*1.5)
 end 
 
function card:draw()
local m=self
spr(m.sprt,m.x+m.ox, m.y+m.oy,2,2)
end