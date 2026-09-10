-- red ball 2.5d: full game reset on game over

function make_sfx()
 poke(0x3200, 0x02, 0x58, 0x48, 0x38, 0x28, 0x18, 0x08)
 poke(0x3240, 0x06, 0x40, 0x30, 0x20, 0x10, 0x08, 0x00)
end

function _init()
 make_sfx()
 score=0
 lvl=1
 screen=1
 cam_x=0
 init_world()
end

function init_world()
 srand(time() + lvl * 133 + screen * 17)
 
 p={x=12 + (screen-1)*128, y=75, dx=0, dy=0, r=4, ground=false}
 game_over=false
 win_lvl=false

 platforms={}
 enemies={}
 decors={}

 for i=1,6 do
  add(decors,{x=(screen-1)*128 + i*22, y=10+rnd(50), w=4, h=100, col=3})
 end

 local cur_x = (screen-1)*128 + 5
 local limit_x = screen * 128 - 10
 while cur_x < limit_x do
  local pw = 12 + rnd(18)
  local py = 45 + rnd(60)
  add(platforms,{x=cur_x, y=py, w=pw, h=6})
  cur_x += pw + 10 + rnd(15)
 end

 add(platforms,{x=(screen-1)*128, y=120, w=35, h=8})
 if rnd(1) > 0.3 then
  add(platforms,{x=(screen-1)*128 + 45, y=114, w=25, h=14})
 end
 add(platforms,{x=screen*128 - 40, y=120, w=40, h=8})

 local ec = flr(rnd(2)) + 1
 for i=1, ec do
  add(enemies,{x=(screen-1)*128 + 30 + rnd(70), y=100, dir=(rnd(1)>0.5 and 1 or -1), spd=0.6+rnd(0.6)})
 end

 target_star={x=(screen-1)*128 + 20 + rnd(80), y=25+rnd(40), collected=false}
end

function _update()
 if game_over then
  if btnp(4) or btnp(5) then
   -- oyunu tamamen ba??tan resetliyoruz (skor 0, level 1, sahne 1)
   score = 0
   lvl = 1
   screen = 1
   cam_x = 0
   init_world()
  end
  return
 end

 if win_lvl then
  if btnp(4) or btnp(5) then
   if screen < 8 then
    screen += 1
    init_world()
   else
    lvl += 1
    screen = 1
    init_world()
   end
  end
  return
 end

 local target_cam = (screen - 1) * 128
 cam_x += (target_cam - cam_x) * 0.15

 if (btn(0)) p.dx-=0.4
 if (btn(1)) p.dx+=0.4
 p.dx*=0.85

 if (abs(p.dx) > 3.2) p.dx = (p.dx>0 and 1 or -1) * 3.2

 if btnp(4) and p.ground then
  p.dy=-5.4
  p.ground=false
  sfx(0)
 end

 p.dy+=0.28
 p.x+=p.dx
 p.y+=p.dy

 local min_x = (screen-1)*128 + 3
 if p.x < min_x then
  p.x = min_x
  if (p.dx < 0) p.dx = 0
 end

 local max_x = screen * 128 - 3
 if p.x > max_x then
  if screen < 8 then
   screen += 1
   init_world()
   sfx(2)
  else
   win_lvl=true
   score += 500
   sfx(2)
  end
 end

 p.ground=false
 for pf in all(platforms) do
  if p.x+p.r > pf.x and p.x-p.r < pf.x+pf.w then
   if p.y+p.r >= pf.y and p.y+p.r <= pf.y+6 and p.dy>=0 then
    p.y=pf.y-p.r
    p.dy=0
    p.ground=true
   end
  end
 end

 for e in all(enemies) do
  e.x += e.spd * e.dir
  if (e.x < (screen-1)*128 + 8 or e.x > screen*128 - 8) e.dir *= -1

  if abs(p.x-e.x)<6 and abs(p.y-e.y)<6 then
   if p.dy > 0 and p.y < e.y then
    del(enemies,e)
    p.dy = -3.5
    score += 100
    sfx(2)
   else
    game_over=true
    sfx(1)
   end
  end
 end

 if not target_star.collected and abs(p.x-target_star.x)<7 and abs(p.y-target_star.y)<7 then
  target_star.collected=true
  score += 200
  sfx(2)
 end

 if (p.y > 128) then
  game_over=true
  sfx(1)
 end
end

function _draw()
 cls(1)

 camera(cam_x, 0)

 for d in all(decors) do
  rectfill(d.x, d.y, d.x+d.w, d.y+d.h, 2)
  rectfill(d.x, d.y, d.x+1, d.y+d.h, 1)
 end

 for pf in all(platforms) do
  rectfill(pf.x, pf.y+1, pf.x+pf.w, pf.y+pf.h+2, 2)
  rectfill(pf.x, pf.y, pf.x+pf.w, pf.y+pf.h, 3)
  rectfill(pf.x, pf.y, pf.x+pf.w, pf.y+1, 11)
 end

 for e in all(enemies) do
  rectfill(e.x-3, e.y-3+1, e.x+3, e.y+3+1, 1)
  rectfill(e.x-3, e.y-3, e.x+3, e.y+3, 0)
  rectfill(e.x-2, e.y-2, e.x+2, e.y+2, 8)
  pset(e.x, e.y, 7)
 end

 if not target_star.collected then
  circfill(target_star.x, target_star.y+1, 3, 2)
  circfill(target_star.x, target_star.y, 3, 10)
  pset(target_star.x, target_star.y, 7)
 end

 circfill(p.x, p.y+1, p.r, 2)
 circfill(p.x, p.y, p.r, 8)
 circfill(p.x-1, p.y-1, 1, 7)
 pset(p.x+1, p.y, 2)

 camera(0,0)

 rectfill(0,0,128,10,0)
 line(0,10,128,10,5)
 print("lvl:"..lvl.." scene:"..screen.."/8",2,2,7)
 print("score:"..score,76,2,10)

 if game_over then
  rectfill(24,45,104,80,0)
  rect(24,45,104,80,2)
  rect(24,45,104,80,8)
  print("game over!",44,52,8)
  print("press z to retry",26,68,6)
 elseif win_lvl then
  rectfill(24,45,104,80,0)
  rect(24,45,104,80,3)
  rect(24,45,104,80,11)
  print("stage completed!",30,52,11)
  print("press z for next",28,68,7)
 end
end