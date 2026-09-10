function _init()
jogo="senha"
horror=false

clc=12
tic=0

x=63
vl=1
y=100
sp=1

cx=rnd(120)
cy=-2
csp=2
c=0
end

function _update()
if jogo=="senha" then
 if btnp(❘) then
  horror=true
  jogo="play"
 elseif btnp(🅾️) or btnp(➡️) or btnp(⬅️) or btnp(⬆️) or btnp(⬇️) then
  jogo="play"
  end 
else
 cy=cy+1

 if cy>120 then
  reset_coin()
  end

 if btn(➡️) then
  x=x+vl
 elseif btn(⬅️) then
  x=x-vl
 end

 if btn(🅾️) then
  vl=2
 else
  vl=1
 end

 if abs(x-cx)<4 and abs(y-cy)<4 then
  reset_coin()
  c=c+1
  sfx(1)
  end

 if c>=25 then
  clc=0
  csp=6
  sp=5
 end

 if c>=30 then
  tic+=0.1
  sfx(0)
 end

 if tic>1.9 then
  _init()
  end
 end
end

function _draw()
cls(0)
if jogo=="senha" then
 print("password",45,30)
 print("btn",55,60)
else

 if c>=30 then
  map(16)
  print("❘",60,30)
 else
  if horror==true then
   cls(0)
   map(16)
   sp=5
   csp=6
   
   if c==10 then
    print("you wana know the truht",15,40)
   elseif c==20 then
    print("give up this is not for you",11,40)
   elseif c==25 then
    print("now!!!",57,40,8)
    sfx(0)
    end 
  else
   cls(clc)
   map(0)
   end
  spr(sp,x,y)
  spr(csp,cx,cy)
  print(c,0,0)
  end
 end
end

function reset_coin()
cx=rnd(120)
cy=-2
end