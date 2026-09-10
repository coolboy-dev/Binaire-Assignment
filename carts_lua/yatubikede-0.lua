function game_over()
 pipes = {}
 high_score = max(score,high_score)
 score = 0
 sfx(2)
 move_speed = -3
 
 state = "title"
end

function _init()
 state = "title"
 started = false
 title_y = 1
 title_dir = 0.25
 difficulty = 1
 
 floor_y = 104
 player_y = 20
 player_x = 20
 player_acc = 1
 player_h = 8+4
 max_acc = 10
 jump_pow = -4
 fall_spd = 0.5
 grid = 8
 rows = 128/grid
 
 score = 0
 high_score = 0
 
 spawn_pipe = every(20)
 blink = every(10)
 increase_speed = every(120)
 show_game_over = false
 
 move_speed = -2
 
 cloud_title_size=7
 cloud_reset_point=cloud_title_size*grid*-1
 cloud_x=0
 cloud_speed=-1
 
 floor_x=0

 pipes={}
 add_pipe()
end

function add_pipe()
 local y = rnd(30)+10
 local gap = 60
 
 if score > 10 then
  gap = 55
 end
 
 if score > 20 then
  gap = 50
 end
 
 if score > 30 then
  gap = 45
 end
 
 if score > 40 then
  gap = 40
 end
 
 local pipe = {
   x=128,
   y=y,
   gap=gap
 }
 
 add(pipes,pipe)
end

function _update()

 if state == "title" then
  title_y += title_dir
  if title_y > 4 then
   title_dir = -0.25
  end
  
  if title_y <= 1 then
   title_dir = 0.25
  end
  
  if btnp(5) then
   state="game"
   started=true
  end
  
  if btnp(1) then
   difficulty += 1
  end
  
  if blink() then
   if show_game_over then
    show_game_over = false
   else
    show_game_over = true
   end
  end
  return
 end
 
 if increase_speed() then
  move_speed -= 0.25
 end
 
 -- animates cloud
 cloud_x += cloud_speed
 if cloud_x == cloud_reset_point then
  cloud_x = 0
 end
 
 -- animates floor
 floor_x += move_speed
 if floor_x <= -8 then
  floor_x = 0
 end
 
 -- player
 player_acc = min(max_acc, player_acc+fall_spd)
 player_y = player_y + player_acc
 local player_yh = player_y + player_h
 
 if player_yh >= floor_y then
  player_y = floor_y-player_h
 end
 
 if btnp(5) then
  sfx(0)
  player_acc = jump_pow
 end
 
 -- pipes
 for pipe in all(pipes) do
  pipe.x += move_speed
  
  if pipe.x < -10 then
   del(pipes,pipe)
  end
  
  local p = {
    l=player_x,
    r=player_x+8,
    t=player_y,
    b=player_y+player_h
  }
  
  -- collision
  if (pipe.x <= p.r and pipe.x+16 >= p.l) and (p.t <= pipe.y+16 or p.b >= pipe.y+pipe.gap) then
   game_over()
  end
  
  if pipe.x+16 < player_x then
   if not pipe.scored then
    pipe.scored = true
    score += 1
    sfx(1)
   end
  end
 end
 
 if spawn_pipe() then
  add_pipe()
 end
end

function _draw()
 cls(12)
 
 --clouds
 for i=0,3 do
  spr(33,cloud_x+(grid*i*7),48,7,2)
 end

 rectfill(0,64,128,128,7) 
 
 --player
 palt(8, true)
 palt(0, false)
 spr(6, player_x, player_y, 2, 2)
 palt(0, true)
 palt(8, false)
 
 --pipes
 for pipe in all(pipes) do
  --up
  spr(1,pipe.x,pipe.y,2,2)
  
  for i=1,flr(pipe.y/8)+1 do
   spr(1,pipe.x,pipe.y-(i*8),2,1)
  end
  
  --down
  spr(3,pipe.x,pipe.y+pipe.gap,2,2)
  
  for i=1,flr((128-pipe.y+pipe.gap)/8)+1 do
   spr(1,pipe.x,pipe.y+pipe.gap+(i*8),2,1)
  end
 end
 
 --floor
 for i=1,rows+1 do
  spr(5,(i-1)*grid+floor_x,floor_y)
 end
 for y=1,2 do
  for i=1,rows+1 do
   spr(21,(i-1)*grid+floor_x,floor_y+grid*y)
  end
 end
 
 if state=="game" then
   prt_out(score,3,3,7)
 end
 
 -- title
 if state=="title" then
  fillp(░)
  rectfill(0,0,128,128,1)
  fillp()
  
  prt_out("high score: "..high_score,3,3,7)
  
  if started and show_game_over then
   prt_out("\^t\^ game over",44,65,8)
  end
  prt_out("press ❘ to jump",32,78+title_y,7)
 end
end

function prt_out(s,x,y,c)
print(s,x-1,y,0)
print(s,x+1,y)
print(s,x,y-1)
print(s,x,y+1)
print(s,x,y,c)
end

function draw_spr(frames,x,y,fsize)
 local size = 0
 
 if fsize then
  size = fsize
 end
 
 spr(frames[1],x,y,size,size)
end


function every(n)
 local count = 0
 return function()
  count += 1
  if count >= n then
   count = 0
   return true
  end
  
  return false
 end
end
