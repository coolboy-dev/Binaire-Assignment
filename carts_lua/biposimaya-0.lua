--mode logic/start/over
function _init()
 mode="start"
 init_game()
end

function _update()
 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="over" then
  update_over()
 end
end

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="over" then
  draw_over()
 end
end

--start mode
function update_start()
 if btnp(❘) then
  startgame()
 end
end

function draw_start()
 cls(1)
 print("pico8snake!",42,54,10)
 print("press ❘ to start",30,62,7)
end

-- over mode
function update_over()
 if btnp(❘) then
  startgame()
 end
end

function draw_over()
 cls()
 draw_checkerboard()
 draw_food()
 draw_snake()
 print("game over!",45,54,8)
 print("score:"..finalscore,45,62,10)
 print("press ❘ to restart",27,70,7)
end

-->8
-- game mode
function startgame()
 mode="game"
 init_game()
end

function init_game()
 ticks=0
 pldir="right"
 newx=2
 newy=0
 gameover=false
 sfxflip=false
 
 rush=false
 movespeed=12
 
 score=0
 scoremultiplier=1
 finalscore=0
 
 food={sprid=31,x=15,y=15}
 place_food()
 
 grow_this_cycle=false
 
 snake={
  {x=0,y=0,dir="right",nxtdir="right"},
  {x=1,y=0,dir="right",nxtdir="right"},
  {x=2,y=0,dir="right",nxtdir="right"}
 }
end

function update_game()
 local head=snake[#snake]
 ticks+=1
 
 update_input(head)
 newx,newy=calc_new_pos(head)
 
 if rush==true then
 	movespeed=3
 	rush=false
 	scoremultiplier+=0.0001
 else
 	movespeed=12
 end
 
 if ticks>movespeed then
  ticks=0
  if collides_with_food(newx,newy) then
    sfx(0)
    place_food()
    score+=100
    grow_this_cycle=true
  end
  
  if collides_with_self(newx,newy)
  or collides_with_wall(newx,newy) then
   finalscore=flr((flr(score*scoremultiplier)+5)/10)*10
   sfx(3)
   mode="over"
  else
   move_snake(newx,newy)

   if snake[#snake].dir!=snake[#snake-1].dir then
    if sfxflip==false then
     sfx(1)
     sfxflip=true
    else
     sfx(2)
     sfxflip=false
    end
   end  
  end
 end
end

function draw_game()
 cls()
 draw_checkerboard()
 draw_food()
 draw_snake()
 print(score,1,1,7)
 print(scoremultiplier,1,8,7)
end

function update_input(head)
 if btn(0) and head.dir!="right" then pldir="left"
 elseif btn(1) and head.dir!="left" then pldir="right"
 elseif btn(2) and head.dir!="down" then pldir="up"
 elseif btn(3) and head.dir!="up" then pldir="down"
 end

 if btn(4) then rush=true end
end

function calc_new_pos(head)
 if pldir=="left" then return head.x-1,head.y
 elseif pldir=="right" then return head.x+1,head.y
 elseif pldir=="up"    then return head.x,head.y-1
 elseif pldir=="down"  then return head.x,head.y+1
 end
end

function collides_with_food(newx,newy)
 return newx==food.x and newy==food.y
end

function place_food()
 repeat
  food.x=rnd(16)\1
  food.y=rnd(16)\1
 until not collides_with_self(food.x, food.y)
end


function collides_with_self(x,y)
 for part in all(snake) do
  if part.x==x and part.y==y then return true end
 end
 return false
end

function collides_with_wall(x,y)
 return x<0 or x>15 or y<0 or y>15
end

function move_snake(newx,newy)
 snake[#snake].nxtdir=pldir
 add(snake,{x=newx,y=newy,dir=pldir,nxtdir=pldir})
 
 if grow_this_cycle==false then
  del(snake,snake[1])
 end
 grow_this_cycle=false
end

function get_body_sprite(dir,nxtdir)
 if dir==nxtdir then
  if dir=="left" or dir=="right" then return 1
  elseif dir=="up" or dir=="down" then return 0
  end
 end
 return get_corner_sprite(dir,nxtdir)
end

function get_corner_sprite(dir,nxtdir)
 if dir=="up" and nxtdir=="right" then return 6
 elseif dir=="right" and nxtdir=="down" then return 7
 elseif dir=="down" and nxtdir=="left" then return 8
 elseif dir=="left" and nxtdir=="up" then return 9

 elseif dir=="left" and nxtdir=="down" then return 14
 elseif dir=="down" and nxtdir=="right" then return 15
 elseif dir=="right" and nxtdir=="up" then return 16
 elseif dir=="up" and nxtdir=="left" then return 17
 end
end

function draw_checkerboard()
 for y=0,15 do
  for x=0,15 do
   local c = ((x+y)%2==0) and 3 or 11
   rectfill(x*8,y*8,x*8+7,y*8+7,c)
  end
 end
end

function draw_food()
	spr(food.sprid,food.x*8,food.y*8)
end

function draw_snake()
 for i, part in ipairs(snake) do
  local sprid=get_body_sprite(part.dir,part.nxtdir)
  local is_corner=part.dir!=part.nxtdir
  local flipx=false
  local flipy=false

  if i==1 then sprid+=4
  elseif i==#snake then sprid+=2
  end

  if not is_corner then
   if part.dir=="left" then flipx=true
   elseif part.dir=="down" then flipy=true
   end
  end

  spr(sprid,part.x*8,part.y*8,1,1,flipx,flipy)
 end
end