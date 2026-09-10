-- catch the safe one!
-- piyush warang
-- press x to start
function _init()
x=63
y=100
score = 3
reset_coin()
speed = 2
difficulty = 0
game_over=false
won=false
game_state=0
coin_type=1

end


function _update()

 
 if game_state==0 then
 if btnp(❘) then
 
  game_state=1
 end
 return
end


 if btn(1) then x=x+speed 
 end
 
 if btn(0) then x=x-speed
 end
   
 cy=cy+difficulty+1
 
 --catch the coin
 if abs(x-cx)<4 and abs(y-cy)<4 then

 if coin_type==1 then
  score=score+1
 elseif coin_type==2 then
  score=score-3
 elseif coin_type==3 then
  score=score+5
 end
 reset_coin()
end
 
 if cy>128 then
 reset_coin()
 end
 
 if score<=0 then
  game_over=true

 end
 
 if game_over then
 if btnp(4) then
  _init()
 end
 return
 end
 
 
 if score<5 then
 difficulty=0
elseif score<15 then
 difficulty=0.5
 
elseif score<20 then
 difficulty=1.0
 
elseif score<25 then
 difficulty=1.2
 
elseif score<25 then
 difficulty=1.5

end

if score>=40 then
 won=true
end

if won then
 if btnp(4) then
  _init()
 end
 return
end
 
end

function _draw()
 cls()
 map(3)
 spr(1,x,y)
 
 if coin_type==1 then
 spr(2,cx,cy)
elseif coin_type==2 then
 spr(6,cx,cy)
elseif coin_type==3 then
 spr(5,cx,cy)
end

 print(score)
 print("difficulty: "..difficulty)
 
 if game_over then
 cls()
 print("game over",42,50,8)
 print("press ❘",48,65,7)
 return
 end
 
 if won then
 cls()
 print("you win!",45,45,11)
 print("score: "..score,42,60,7)
 print("press ❘",43,75,7)
 return
end



 if game_state==0 then
 cls()
 print("catch the safe coin",30,45,7)
 print("trust no one edition!",23,30,8)
 print("press ❘ to start",30,70,7)
 return
end
end

 function reset_coin()

  cx=rnd(120)
 cy=-8

 local r=rnd(1)

 if r<0.25 then
  coin_type=2
 elseif r<0.40 then
  coin_type=3
 else
  coin_type=1
 end

 end