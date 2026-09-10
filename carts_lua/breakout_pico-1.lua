function _init()
e="j"
t=0

px=64
b=0
bs=0
rb=0
l=3

bx=64
by=64

dx=1
dy=1
end

function _update()
if e=="j" then
 if btn(➡️) and mget((px+8)/8,100/8)<18 then
  px+=2
 elseif btn(⬅️) and mget((px-1)/8,100/8)<18 then
  px-=2
  end

 if mget((bx+3)/8,(by+3)/8)==18 then
  dx=-1
 elseif mget((bx+3)/8,(by+3)/8)==19 then
  dx=1
 elseif abs(px-bx)<4 and abs(100-by)<4 then
  dy=-1
 elseif mget((bx+3)/8,(by+3)/8)==16 then
  dy=1
  b+=1
  bs+=1
  mset(bx/8,by/8,17)
  end

 if by>120 then
  by=63
  bx=63
  l-=1
  end

 if l<=0 then
  e="g"
  end
 
 bx+=dx
 by+=dy
 
 if b>rb then
  rb=b
  end 
else
 t+=0.1
 if t>1.9 then
  t=0
  end
 
 if btn(❘) then
  e="j"
  l=3
  px=64
  bx=64
  by=64
  b=0
  end
 end
end

function _draw()
cls()
map()

if e=="j" then
 spr(1,px,100)
 spr(2,bx,by)
 if bs>=42 then
  _init()
  end
else
 spr(10,px,100)
 print("gameover",45,45,8)
 if t<0.9 then
  print("❘/x to reset",20,80,7)
  end
 end

spr(3,1,1)
spr(9,1,10)
spr(11,1,19)
print(b,10,2,6)
print(rb,10,20,10)
print(l,10,11,10)
end