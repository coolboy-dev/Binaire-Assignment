function _init()
estado="jogo"
pisca=0

plr={
x=60,
y=64,
ys=0,
sp=1,
estado="parado",
flp=false,
hp=3
}

hazard={
x=rnd(120),
y=-8,
sp=9
}

mart={
x=rnd(120),
y=rnd(120),
sp=13,
m=0,
rm=0
}
end

function _update()
if estado=="jogo" then
 ong()
 pupdate()
 hupdate()
 mupdate()
else
 pisca+=0.1
 if btnp(❘) then
  estado="jogo"
  plr.hp=3
  mart.m=0
  end
  if pisca>1.9 then
   pisca=0
   end
 end
end

function _draw()
cls(0)
if estado=="jogo" then
 map(0,0,0,0,16,16)
 pdraw()
 hdraw()
 mdraw()
else
 map(16,0,0,0,16,16)
 if pisca<1 then
  print("press ❘/x to continue",20,100,8)
  end
 end 
end
-->8
function pupdate()
if plr.estado=="parado" then
 plr.sp=1
elseif plr.estado=="andando" then
 plr.sp+=0.2
 if plr.sp>5.9 then
  plr.sp=2
  end
end
 
if btn(➡️) then
 plr.x+=1
 plr.estado="andando"
 plr.flp=false
elseif btn(⬅️) then
 plr.x-=1
 plr.estado="andando"
 plr.flp=true
else
 plr.estado="parado"
 end

plr.y+=plr.ys

if not ong() then
 plr.ys+=0.05
 plr.sp=6
else
 plr.ys=0
 if btnp(🅾️) then
  plr.ys=-1.5
  sfx(1)
  end
 end

if mget((plr.x+3)/8,(plr.y+3)/8)==17 then
 plr.sp=7
 end

if plr.hp<0 then
 estado="game over"
 end
end

function pdraw()
spr(plr.sp,plr.x,plr.y,1,1,plr.flp)
spr(12,0,0)

print(plr.hp,9,2,8)
end
-->8
function ong()
local tx=(plr.x+3)/8
local ty=(plr.y+8)/8

return fget(mget(tx,ty),0)
end

function reset_h()
hazard.x=rnd(120)
hazard.y=-8
end
-->8
function hupdate()
hazard.y+=1.5
hazard.sp+=0.2

if hazard.sp>10.9 then
 hazard.sp=9
 end

if mget((hazard.x+3)/8,(hazard.y+3)/8)==32 then
 reset_h()
 sfx(0)
elseif abs(plr.x-hazard.x)<3 and abs(plr.y-hazard.y)<3 then
 reset_h()
 plr.hp-=1
 sfx(0)
 end
end

function hdraw()
spr(hazard.sp,hazard.x,hazard.y)
end
-->8
function mupdate()
if mget((mart.x+4)/8,(mart.y+4)/8)>0 or mart.y<20 then
 mart.x=rnd(120)
 mart.y=rnd(120)
 end
 
if abs(plr.x-mart.x)<3 and abs(plr.y-mart.y)<3 then
 mart.x=rnd(120)
 mart.y=rnd(120)
 mart.m+=1
 sfx(2)
 end

if mart.m>mart.rm then
 mart.rm=mart.m
 end
end

function mdraw()
spr(mart.sp,mart.x,mart.y)
spr(13,0,9)
spr(14,0,17)
print(mart.m,9,10,6)
print(mart.rm,9,20,10)
end