-- brought a gun to a laser fight
-- by @dredds

-- music by ridgek
-- https://ridgek.itch.io/20th-century-ops

--[[

todo
- victory reward animation
]]

--debug = true
--debug_level = 8

unit = 0x0.0001


function _init()
 cartdata(
   "dredds_guntolaserfight")
 
 -- 64x64 mode
 poke(0x5f2c,3)
 
 -- disable button autorepeat
 poke(0x5f5d, 255)
 
 if debug then
  -- turn on devkit mode
  poke(0x5f2d, 1)  
 end
 
 hiscore = dget(0)
 menuitem(1, "abandon mission",
   function()
    music(0)
    start_mode(title)
   end)
 menuitem(2, "clear progress",
   function()
    hiscore = 0
    memset(0x5e01,0,255)
   end)
 
 music(0)
 start_mode(title)
end

function _update60()
 mode:update()
 if debug then
  dispatch_test_keys()
 end
end

function _draw()
 -- in case framerate drops
 set_draw_dst()
 
 mode:draw()
end


function start_mode(m)
	mode = m
	mode:init()
end


function set_draw_dst(n)
 poke(0x5f55, n or 0x60)
end

function set_sprites(n)
 poke(0x5f54, n or 0x00)
end


function noop()
end


function foreach_alive(os,f)
 local alive = {}
 for o in all(os) do
  if f(o) then
   add(alive,o)
  end
 end
 return alive
end


function seq(...)
 local fs = pack(...)
 return function(...)
  for f in all(fs) do
   f(...)
  end
 end
end


function prompt(s)
 local w = print(s, 0,128)
 printa(s, 32,56, 0.5)
end


function printa(s, x,y, a)
 local w = print(s, 0,128)
 print(s, x-w*a,y)
end


function printi(i,x,y,a)
 local digits = 
   split(tostr(i,2),"")
 local w = #digits*4 - 1
 local x0 = x - w*a
 
 for i,d in ipairs(digits) do
  sspr(
    32+3*d, 0,
    3, 4,
    x0+(i-1)*4, y)
 end
end


function smooth(x,x0,x1)
 x0 = x0 or 0
 x1 = x1 or 1
 x = mid(0,1,(x-x0)/(x1-x0))
 
 return x^3 * (x*(6*x-15) + 10)
end



function dispatch_test_keys()
 while stat(30) do
  local k = stat(31)
  if mode.test_key then
   mode:test_key(k)
  end
 end
end

-->8
-- gameplay

-- gameplay parameters
bonus_level = 5
level_len = 128 --max map width
multiplier_timeout = 60
spawn_step = 16
extra_life_score = 1000
max_thrust = 12
gun_cooldown = 10


-- himem areas
bullet_plane = 0x80
hitmask_plane = 0xa0


gameplay = {
 init = function(m)
  music(-1,500)
  
  playing = true
  
  if debug and debug_level then
   level = debug_level
   score = 0
	  lives = 3
  else
   if start_at_level == "continue" 
   then
    level = max_level_reached()
   else
    level = start_at_level
   end
   
   if level == 1 then
		  score = 0
		  lives = 3
		 else
		  score,lives = 
		    level_best(level)
	  end 
  end
  
  is_hiscore = false
  victory = false
  
  next_life = 
    extra_life_score * unit
  while next_life < score do
   next_life *= 2
  end
  
  player = {}
  
  m:start_level()
 end;
 
 start_level = function(m)
  bullets = {}
  nasties = {}
  particles = {}
  shrapnel = {}
  shake = 0
  new_level = true
  distance = 0
  
  bg = init_bg(levels[level].bg)
  
  set_draw_dst(bullet_plane)
  cls()
  set_draw_dst()
  
  player_start(player)
 end;
 
 update = function()
  if not playing then
   start_mode(game_over)
   return
  end
  
  if shake > 0 then
   shake *= 0.9
   if shake < 0.05 then
    shake = 0
   end
  end
  
  particles = foreach_alive(
    particles,
    update_particle)
  shrapnel = foreach_alive(
    shrapnel,
    update_particle)
  
  bg:update()
  
  multiplier_timer =
    max(0,multiplier_timer-1)
  if multiplier_timer == 0 then
   multiplier = 1
  end
  
  bullets = foreach_alive(
    bullets,
    update_bullet)
  
  player:state()
  
  nasties = foreach_alive(
   nasties,
   update_nasty)
  
  -- create hitmask and check
  -- for player hit
  if player.state==player_active
  then
	  local at_end_of_level =
	    spawn_nasties()
	    
	  set_draw_dst(hitmask_plane)
	  palt(1,true)
	  for i=0,15 do
	   pal(i,7)
	  end
	  cls()
	  
	  for n in all(nasties) do
	   if not n.bonus then
		   draw_nasty(n)
		   if n.firing then
		    draw_laser(n)
		   end
		  end
	  end
	  palt(1,false)
	  pal()
	  
	  local phit = 
	    pget(player.x,player.y)
	  set_draw_dst()
			
	  if phit ~= 0 then
	   sfx(9)
	   explode(
	     player,1,1,40,
	     yellows, 
	     shrapnel)
	   explode(
	     player,1,1.25,60,
	     yellows, 
	     shrapnel)
	   explode(
	     player,2,2,60,
	     yellows, 
	     shrapnel)
	   shake = 2
	   
	   lives -= 1
	   player.cooldown = 60
	   player.state = 
	     player_exploding
	  end
	  
		 if at_end_of_level 
		 and #nasties == 0
		 and #particles == 0
		 and #shrapnel == 0
		 then
		  start_mode(level_transition)
		 end
		end
 end;
 
 draw = function()
  cls(0)
  
  if shake > 0 then
   local ms = ceil(shake)
   camera(
     ms*sgn(rnd()-0.5),
     ms*sgn(rnd()-0.5))
  end
  
  bg:draw()
  
  -- draw lasers
  if time()*20\1%5 == 0 then
   pal(8,7)
  end
  foreach(nasties, draw_laser)
  pal(8,8)
  palt(11,true)
  palt(0,false)
  foreach(nasties,draw_nasty)
  palt(11,false)
  palt(0,true)
  
  set_draw_dst(bullet_plane)
  for _ = 1,512 do
   pset(rnd(64),rnd(64),0)
  end
  for b in all(bullets) do
   spr(2, b.x-4,b.y)
  end
  set_draw_dst()
  set_sprites(bullet_plane)
  spr(0,0,0,8,8)
  set_sprites()
  
  local ps = player.state
  
  if ps ~= player_exploding
  then
   draw_player(player,true)
  end
  
  foreach(shrapnel,
    draw_particle)
  foreach(particles,
    draw_particle)
    
  -- draw hud
  camera()
  
  for i=0,lives-1 do
   spr(8,i*5,0)
  end
  
  printi(score, 63,0, 1)
  
  if multiplier > 1 then
   pset(0,0, 12)
  end
  
  if new_level then
   color(7)
   printa("zone " .. level,
     32,8, 0.5)
  end
 end;
 
 test_key = function(m,k)
  local l = tonum(k)
  if l and new_level
  and l >= 1
  and l <= #levels
  then 
   level = l
  elseif k == "e" then
   distance = 
     spawn_step*level_len
  elseif k == "b" then
   distance = spawn_step *
     (level_len-32)
  elseif k == "l" then
   award_extra_life()
  elseif k == "f" then
   -- save screen and hitmask
   extcmd("screen",4)
   set_sprites(hitmask_plane)
   cls()
   sspr(0,0,128,128)
   set_sprites()
   flip()
   extcmd("screen",4)
   
  end
 end
}


function update_nasty(n)
 animate_nasty(n)
 
 local deliberate = true
 
 check_hit(n, bullets)
 
 if not n.hit then
  deliberate = false
  check_hit(n, shrapnel)
 end
 
 if n.hit then
  sfx(13)
  if n.bonus then
   sfx(18)
  end
  explode(
    n,1,2,40, 
    greens,
    particles)
  if deliberate then
   award_score(n.score)
  end
 end
 
 return n.alive
end


function spawn_nasties()
 if distance%spawn_step > 0 
 then
  return false
 else
  local mx =
    distance\spawn_step
  
  if mx > level_len then
   -- reached end of level
   return true
  else
		 local my0 = 
		   levels[level].mapy
		 
		 for my=my0,my0+7 do
		  local s = mget(mx,my)
		  
		  if fget(s,0) then
		   spawn_nasty(s,mx,my-my0)
		  end
		 end
		 return false
		end
	end
end


function spawn_nasty(s,mx,my)
 add(nasties,
   new_nasty(s,mx,my))
end


function update_bullet(b)
 b.x += 2
 return b.alive
    and b.x < 68
end


function check_hit(
 n,
 projectiles
)
 for b in all(projectiles) do
  if b.alive 
  and abs(b.x-n.x) <= n.hx
  and abs(b.y-n.y) <= n.hy
  then
   b.alive = false
   n.alive = false
   n.hit = true
   break
  end
 end
end


function draw_bullet(b)
 spr(2,b.x,b.y)
end


-- states

function player_starting(p)
 p.x += 0.25
 
 if p.x >= 8 then
  p.cooldown = 0
  new_level = false
  if distance == 0 then
   player_drop_shields(p)
   
   if levels[level].bonus then
	   spr_particles(
	    16,48, 19,11, bright
	   )
   end
  else
   p.state = player_safe
  end
 end
end

function player_safe(p)
 player_move(p)
 
 if btnp(❘) or btnp(🅾️) then
  player_drop_shields(p)
  player_shoot(p)
 end
end


function player_active(p)
 player_move(p)
  
 p.cooldown = max(p.cooldown-1)
 
 if (btn(❘) or btn(🅾️))
 and p.cooldown == 0
 then
  player_shoot(p)
 end
 
 distance += 1
end

function player_exploding(p)
 p.cooldown=max(p.cooldown-1)
 
 if shake == 0 
 and p.cooldown == 0
 and #particles == 0
 and #shrapnel == 0
 and #bullets == 0
 then
  if lives > 0 then
   player_start(p)
  else
   playing = false
  end
 end
end

-- actions

function player_start(p)
 p.x = -16
 p.y = 32
 p.thrustx = 0
 p.thrusty = 0
 p.cooldown = 0;
 p.shielded = true
 p.state = player_starting
 
 multiplier = 1
 multiplier_timer = 0
end


function player_move(p)
 local dx,dy
 
 p.thrustx,dx = 
   thrust(p.thrustx,
     tonum(btn(➡️)) -
     tonum(btn(⬅️)))
 
 p.thrusty,dy = 
   thrust(p.thrusty,
     tonum(btn(⬇️)) -
     tonum(btn(⬆️)))
  
 p.x = mid(3,61, p.x + dx)
 p.y = mid(2,61, p.y + dy)
end


function thrust(t,dt)
 local t2
 
 if dt == 0 then
  if t == 0 then
   t2 = 0
  else
   t2 = t - sgn(t)
  end
  
 elseif t == 0
 or sgn(dt) == sgn(t)
 then
  t2 = t + dt
 
 else
  t2 = t + 2*dt
 end
 
 local clamped_t2 = mid(t2,
   -max_thrust, max_thrust)
 
 local move =
   smooth(abs(clamped_t2),
     0,max_thrust)
      * sgn(clamped_t2)
 
 return clamped_t2, move
end


function player_shoot(p)
 sfx(8)
 add(bullets, {
  x = player.x+6;
  y = player.y+1;
  alive = true;
 })
 p.cooldown = gun_cooldown
end


function player_drop_shields(p)
  sfx(12)
  p.shielded = false
  p.state = player_active
  
  spr_particles(
    0,48,16,16,
    blues,
    p.x,p.y+2)
end


function draw_player(
 p,
 draw_jet
)
 spr(1, p.x-3,p.y-1)
 if draw_jet then
	 pset(
	  p.x-4 + time()*12\1%2,
	  p.y,
	  12)
 end
 
 if p.shielded then
  local i = time()*15\1%4
  spr(64 + i*2, 
    p.x-8,p.y-7, 
    2,2)
 end
end


function award_score(s)
 local old_score = score
 
 score += s*unit*multiplier
 
 multiplier += 1
 multiplier_timer = 
   multiplier_timeout
   
 if multiplier == 10 then
  sfx(20)
  spr_particles(
    96,0,10,5,
    bright)
 elseif multiplier == 25 then
  sfx(21)
  spr_particles(
    110,0,11,5,
    bright)
 elseif multiplier == 100 then
  sfx(22)
  spr_particles(
    96,0,14,5,
    bright)
 end
 
 if score > hiscore then
  hiscore = score
  is_hiscore = true
  dset(0,hiscore)
 end
 
 if old_score < next_life
 and score >= next_life 
 then
  if lives < 5 then
   award_extra_life()
  end
  next_life *= 2
 end
end

function record_progress()
 local ld = (level-1)*2
 local lmax_s = dget(ld)
 local lmax_l = dget(ld+1)
 
 if score > lmax_s then
  dset(ld, score)
  dset(ld+1, lives)
 end
end


function level_best(l)
 local ld = (l-1)*2 
 return dget(ld),dget(ld+1)
end


function has_reached_level(l)
 return l == 1 
     or level_best(l) ~= 0
end


function max_level_reached()
 for l = #levels,2,-1 do
  if has_reached_level(l) then
   return l
  end
 end
 return 1
end



function award_extra_life()
 lives += 1
 
 sfx(19)
 spr_particles(
  40,48, 15,11, bright
 )
end


level_transition = {
 init = function()
  sfx(16)
  transition_x = 0
 end;
 
 update = function()
  bg:update()
  
  bullets = foreach_alive(
    bullets,
    update_bullet)
  
  if transition_x < 72 then
   transition_x += 0.5
   player.x = 
     max(player.x,transition_x)
  elseif #bullets == 0 then
		 if level == #levels then
		  victory = true
		  start_mode(game_over)
		 elseif btnp(❘) or btnp(🅾️)
		 then
		  sfx(17)
		  level += 1
		  record_progress()
	   mode = gameplay
	   mode:start_level()
		 end
		end
 end;
 
 draw = function()
   gameplay.draw()
   color(7)
   printa("zone clear",
     32,
     player.y > 14 and 8 or 28,
     0.5)
   
   if transition_x >= 72
   and #bullets == 0
   then
    prompt("❘ : continue")
   end
 end;
}

-->8
-- nasties


function new_nasty(s,mx,my)
 local y = my*8+4
 local x = 72
 local dym = 1
 local alt = false
 
 local nt = nasty_types[s]
 
 if not nt then
  alt = true
  s -= 16
  nt = nasty_types[s]
  dym = -1
 end
 
 local n = {
  s = s;
  x = 72, y=my*8+4;
  alive = true;
  dy = nt.dy * dym
 }
 
 if nt.charge_t then
	 n.warn_t = 
		  min(60, nt.charge_t/2);
 	n.t = n.warn_t
 end
 
 setmetatable(n,{
   __index=nt
 })
 
 if nt.init then
  n:init(alt)
 end
 
 return n
end


function draw_nasty(n)
 spr(n.s + 16*(time()*10\1%2),
     n.x-3,n.y-3)
end


function draw_laser(n)
 if n.draw_laser then
	 if n.firing then
	  color(8)
	  n:draw_laser()
	 elseif n.t <= n.warn_t then
	  color(2)
	  n:draw_laser()
	 end
	end
end


function animate_nasty(n)
 n:move()
 if n.draw_laser then
	 n.t -= 1
	 if n.t == 0 then
	  n.firing = not n.firing
	  if n.firing then
	   sfx(14)
	   n.t = n.fire_t
	  else
	   if n.stopped_firing then
	    n:stopped_firing()
	   end
	   n.t = n.charge_t
	  end
	 end
	end
end


function flypast(n)
 n.x += n.dx
 n.alive = n.x > -n.hx
end

function siny(n)
 n.y += sin(n.a)/2
 n.a += 1/128
end

function bounce(n)
 n.x += n.dx
 n.y += n.dy
 
 if n.dx < 0 and n.x <= 2
 or n.dx > 0 and n.x >= 61 then
  n.dx *= -1
 end
 
 if n.dy < 0 and n.y <= 2 
 or n.dy > 0 and n.y >= 61 then
  n.dy *= -1
 end
end

function laser_w(n)
 line(n.x,n.y, 0,n.y)
end

function laser_e(n)
 line(n.x,n.y, 63,n.y)
end

function laser_n(n)
 line(n.x,n.y, n.x,0)
end

function laser_s(n)
 line(n.x,n.y, n.x,63)
end;


function init_spin(n,alt)
 n.spind = alt and -1 or 1
end

function spin_lasers(n)
 n.a = (n.a + n.spind/512)%1
end

function rotating_lasers(n)
 for i = 0,n.nlasers-1 do
  local la = i/n.nlasers
  line(n.x,n.y,
    n.x + 64*cos(n.a+la),
    n.y + 64*sin(n.a+la))
 end
end


nasty_types = {
	[16] = {
	 -- left shooter
	 hx = 2;
	 hy = 2;
	 
	 charge_t = 180;
	 fire_t = 30;
	 
	 dx = -0.5;
	 dy = 0.5;
	 
	 draw_laser = laser_w;
	 move = bounce;
	 
	 score = 30;
	};
	
	[17] = {
	 -- down shooter
	 hx = 2;
	 hy = 2;
	 
	 charge_t = 240;
	 fire_t = 45;
	 dx = -0.5;
	 dy = 0;
	 	 
	 draw_laser = laser_s;
	 
	 move = bounce;
	 
	 score = 3;
	};
 
	[18] = {
	 -- up shooter
	 hx = 2;
	 hy = 2;
	 
	 charge_t = 240;
	 fire_t = 45;
	 dx = -0.5;
	 dy = 0;
	 
	 draw_laser = laser_n;
	 
	 move = bounce;
	 
	 score = 3;
	};
 
 [19] = {
  -- up/down shooter
	 hx = 2;
	 hy = 3;
	 
	 charge_t = 120;
	 fire_t = 60;

	 dx = -0.25;
	 dy = 0.5;
	 
	 draw_laser = seq(
   laser_n,
   laser_s
	 );
	  
	 move = bounce;
	 
	 score = 6;
 };
 
	[20] = {
	 -- left/right shooter
	 hx = 3;
	 hy = 2;
	 	 
	 charge_t = 120;
	 fire_t = 60;
	 dx = -0.5;
	 dy = 0.25;
	 score = 2;
	 
	 draw_laser = seq(
	  laser_w,
	  laser_e
	 );
	 
	 move = bounce;
	 
	 score = 25;
	};
	
	[21] = {
	 -- up/down/left/right shooter
	 hx = 3;
	 hy = 3;
	 	 
	 charge_t = 90;
	 fire_t = 45;
	 vertical = true;
  
	 dx = -0.5;
	 dy = 0.5;
	 
	 draw_laser = function(n)
	  if n.vertical then
	   laser_n(n)
	   laser_s(n)
		 else
		  laser_w(n)
		  laser_e(n)
		 end
	 end;
	 
	 move = bounce;
	 
	 stopped_firing = function(n)
	  n.vertical = not n.vertical
	 end;
	 
	 score = 15;
	};
	
	[22] = {
	 -- diagonal shooter
	 hx = 3;
	 hy = 3;
	 	 
	 charge_t = 180;
	 fire_t = 45;
	 dx = 0.5;
	 dy = 0.5;
	 
	 draw_laser = function(n)
	  line(n.x,n.y,n.x-64,n.y-64)
	  line(n.x,n.y,n.x+64,n.y-64)
	  line(n.x,n.y,n.x-64,n.y+64)
	  line(n.x,n.y,n.x+64,n.y+64)
	 end;
	 
	 move = bounce;
	 
	 score = 13;
	};
 
	[23] = {
	 -- interceptor
	 hx = 3;
	 hy = 3;
	 
	 charge_t = 30;
	 fire_t = 30;
	 dx = -0.5;
	 dy = 0.5;
	 
	 draw_laser = function(n)
	  if n.dx > 0 then
	   laser_w(n)
	  end
	 end;
	 
	 init = function(n,alt)
	  n.move = n.patrol
	  n.dy1 = n.dy
	 end;
	 
	 patrol = function(n)
	  bounce(n)
	  
	  if abs(n.y-player.y) < 2
	  and n.x > player.x
	  and n.x < 62
	  and not player.shielded
	  then
	   n.dx = -2
	   n.dy = 0
	   n.move = n.attack
	  end
	 end;
	 
	 attack = function(n)
	  n.x += n.dx
   if n.x <= 2 then
    n.dx = 0.5
    n.t = n.warn_t
		  n.firing = false
    n.move = n.reverse
   else
	   local yo = player.y - n.y
	   if yo ~= 0 then
	    n.y += sgn(yo)*0.5
	   end
	  end
	 end;
	 
	 reverse = function(n)
	  n.x += n.dx
	  if n.x > 62 then
	   n.dx = -0.5
	   n.dy = n.dy1
	   n.move = n.patrol
	  end
	 end;
	 
	 score = 25;
	};
	
	[24] = {
	 -- 1-laser spinner
	 hx = 3;
	 hy = 3;
	 
	 charge_t = 180;
	 fire_t = 30;
	 dx = 0.5;
	 dy = 0.5;
	 a = 0.5;
	 nlasers = 1;
	 
	 init = init_spin;
	 
	 draw_laser = rotating_lasers;
	 
	 move = seq(
	  bounce,
	  spin_lasers
	 );
	 
	 score = 7;
	};
	
	[25] = {
	 -- 2-laser spinner
	 hx = 3;
	 hy = 3;
	 
	 charge_t = 180;
	 fire_t = 30;
	 dx = 0.5;
	 dy = 0.5;
	 a = 0.5;
	 nlasers = 2;
	 
	 init = init_spin;
	 
	 draw_laser = rotating_lasers;
	 
	 move = seq(
	  bounce,
	  spin_lasers
	 );
	 
	 score = 14;
 };

	[26] = {
	 -- 3-laser spinner
	 hx = 3;
	 hy = 3;
	 
	 charge_t = 180;
	 fire_t = 30;
	 dx = 0.5;
	 dy = 0.5;
	 a = 0.5;
	 nlasers = 3;
	 
	 init = init_spin;
	 
	 draw_laser = rotating_lasers;
	 
	 move = seq(
	  bounce,
	  spin_lasers
	 );
	 
	 score = 21;
 };

	[27] = {
	 -- 4-laser spinner
	 hx = 3;
	 hy = 3;
	 
	 charge_t = 180;
	 fire_t = 30;
	 dx = 0.5;
	 dy = 0.5;
	 a = 0.5;
	 nlasers = 4;
	 
	 init = init_spin;
	 
	 draw_laser = rotating_lasers;
	 
	 move = seq(
	  bounce,
	  spin_lasers
	 );
	 
	 score = 28;
 };
 
 [28] = {
	 -- right shooter
	 hx = 2;
	 hy = 2;
	 
	 charge_t = 180;
	 fire_t = 30;
	 
	 dx = -0.5;
	 dy = 0.5;
	 
	 draw_laser = laser_e;
	 move = bounce;
	 
	 score = 3;
	};
	
 [29] = {
	 -- no lasers
	 hx = 2;
	 hy = 2;
	 
	 dx = -0.5;
	 dy = 0.5;
	 
	 move = bounce; 

	 score = 2;
 };
 
 [30] = {
	 -- bonus
	 hx = 2;
	 hy = 2;
	 
  dx = -0.5;
  dy = 0;
  
  move = flypast;
  
  bonus = true;
  score = 1;
 };
 
 [31] = {
	 -- big no lasers flights left
	 hx = 3;
	 hy = 3;
	 
	 dx = -0.5;
	 dy = 0.5;
	 
	 move = flypast; 

	 score = 1;
 };
 
 [72] = {
  -- super bonus
	 hx = 2;
	 hy = 3;
	 
  dx = -0.5;
  dy = 0;
  a = 0;
  
  move = seq(flypast,siny);
  
  bonus = true;
  score = 3;
 }
 
}

-->8
-- particles

yellows = split
  "7,7,7,10,10,10,9,10,9,9,5,9,5,5"

greens = split
  "7,7,7,11,11,11,3,11,3,3,5,3,5,5"

bright = split
  "10,7,10,7,10,7,10,7,10,10,10,10,10"

blues = split
  "12,12,12,7,12,12,7,12,12,13,12,13"

function update_particle(p)
 p.x += p.dx*p.v
 p.y += p.dy*p.v
 p.v *= p.a
 p.t -= 1
 
 return p.t > 0
    and p.alive
    and (p.dx > 0 or p.x >= 0)
    and (p.dx < 0 or p.x < 64)
    and (p.dy > 0 or p.y >= 0)
    and (p.dy < 0 or p.y < 64)
end


function draw_particle(p)
 pset(p.x,p.y, 
  p.hues[ceil(#p.hues*(p.t0-p.t)/p.t0)])
end


function launch_particle(
 category,
 p
)
 p.t0 = p.t
 p.alive = true
 add(category, p)
end


function explode(o, 
	r,v,t,
	hues,
	category
)
 local n=24
 for i = 0,n-1 do
  local a = (i+rnd()/2-0.25)/n 
  local dx = cos(a)
  local dy = sin(a)
  
  launch_particle(category, {
   x = o.x + dx*r;
   y = o.y + dy*r;
   dx = dx;
   dy = dy;
   v = v or 2;
   a = 0.95;
   t = t or 40;
   hues = hues;
  })
 end
end


function spr_particles(
 sx0,sy0,sw,sh,hues,
 midx,midy
)
 for sx = 0,sw-1 do
  local ox = sx - sw/2
  for sy = 0,sh-1 do
   local oy = sy - sh/2
   
   local p = 
     sget(sx0+sx,sy0+sy)
   
   if p ~= 0 then
    local d = sqrt(ox*ox+oy*oy)
    launch_particle(particles,{
     x = (midx or 32) + ox;
     y = (midy or 32) + oy;
     dx = ox/d;
     dy = oy/d;
     v = d/32;
     a = 1.02;
     t = 120;
     hues = hues;
    })
   end
  end
 end
end
-->8
-- title screen

replay_mode_changed = false
start_at_level = 1

title = {
 init = function()
  player = {
   x=29;
   y=42;
   x1=29;
   y1=42;
   oy=0;
  }
 end;
 
 update = function()
  player.oy = 1.5*sin(time()/2)
  player.y = 
    player.y1 + player.oy
  
  if btnp(🅾️) or btnp(❘) then
   sfx(17)
   sfx(11)
   start_mode(starting)
  elseif btnp(⬅️) then
   sfx(17)
   start_at_level = next_level(
     start_at_level,1)
   replay_mode_changed = true
  elseif btnp(➡️) then
   sfx(17)
	  start_at_level = next_level(
	     start_at_level,-1)
   replay_mode_changed = true
  end
 end;
 
 draw = function(m)
  cls(0)
  
  if debug then
   spr(103, 12,30, 5,1)
  end
  
  color(4)
  draw_logo(0,9)
  color(10)
  draw_logo(0,8)
  
  m:draw_rest()
 end;
 
 draw_rest = function(m)
  draw_player(player)
  
  color(7)
  if start_at_level == 1 then
   prompt("❘ start")
  elseif start_at_level == "continue" then
   prompt("❘ start best")
  else
   prompt("❘ start " .. 
     start_at_level)
  end
  
  spr(9,0,56)
  spr(9,56,56,1,1,true)
 end;
}

function draw_logo(x,y)
 print("you brought", x+11,y+0)
 print("a gun to a", x+13,y+7)
 print("laser fight", x+11,y+14)
end


function next_level(l,d)
 if l == "continue" then
  if d == -1 then
   return max_level_reached()
  else
   return 1
  end
 
 else
  local k = l+d
  
  if k < 1 
  or k > #levels
  or not has_reached_level(k)
  then
   return "continue"
  else
   return k
  end
 end
end



starting = {
 init = function()
  player.shielded = true
  player.t = 0
 end;
 
 update = function()
  player.t += 1
  player.x = player.x1 + 
    50 * smooth(
      player.t, 0,100)
  if player.x > 75 then
   start_mode(gameplay)
  end
 end;
 
 draw = title.draw;
 
 draw_rest = function()
  draw_player(player,true)
  color(7)
  prompt("hi " .. tostr(hiscore,2))
 end;
}

-->8
-- game over screen

game_over = {
 init = function()
  music(0)
 end;
 
 update = function()
  if btnp(❘) or btnp(🅾️) then
   sfx(17)
   start_mode(title)
  end
 end;
 
 draw = function()
  cls(0)
  color(victory and 10 or 6)
  printa(
    victory
      and "victory!"
      or "defeated",
    32,8, 0.5)
  
  color(is_hiscore and 10 or 7)
  printa(
    is_hiscore 
     and "high score!" 
     or "score",
    32,24, 0.5)
  printa(
    tostr(score,2), 
    32,32, 0.5)
  
  color(7)
  prompt("❘ : play again")
 end;
}


-->8
-- backgrounds

function init_bg(bgtype)
 local bg = setmetatable({},{
  __index = bgtype
 })
 bg:init()
 return bg
end


stars = {
 init = function(bg)
  for i = 1,20 do
   add(bg,{
    x = rnd(64), y=rnd(64);
    speed = star_speed();
   })
  end 
 end;
 
 update = function(bg)
  for s in all(bg) do
			s.x -= s.speed
		 if s.x < 0 then
		  s.y = rnd(64)
		  s.x = 63
		  s.speed = star_speed()
		 end  
  end
 end;
 
 draw = function(bg)
  for s in all(bg) do
   line(s.x,s.y,
        flr(s.x+s.speed),s.y,
        1)
  end 
 end;
}


function star_speed()
 return 1+rnd(12)/8
end


clouds = {
 init = function(bg)
  for i = 1,32 do
   local r = cloud_r()
   
   add(bg, {
    r = r;
    y = rnd(64);
    x = rnd(64);
   })
  end
 end;
 
 update = function(bg)
  for c in all(bg) do
   c.x -= c.r/6
   if c.x + c.r < 0 then
    c.r = cloud_r()
    c.x = 64+c.r
    c.y = rnd(64)
   end
  end
 end;
 
 draw = function(bg)
 	for c in all(bg) do
 	 circfill(c.x, c.y, c.r, 1)
 	end
 	for c in all(bg) do
 	 circfill(c.x, c.y, c.r-1, 0)
 	end
 end;
}


function cloud_r()
 return 6 + rnd(6)
end


rects = {
 init = function(bg)
  for i=1,24 do
   add(bg,rndrect(rnd(64)))
  end
 end;
 
 update = function(bg)
  for i,r in ipairs(bg) do
	  r.x -= r.v
	  if r.x + r.w < 0 then
	   bg[i] = rndrect(64)
	  end
	 end
 end;
 
 draw = function(bg)
  for r in all(bg) do
   rrect(r.x,r.y,r.w,r.h,0,1)
  end
  for r in all(bg) do
   rrectfill(
     r.x+1,r.y+1,
     r.w-2,r.h-2,
     0,
     0)
  end
 end;
}

function rndrect(x)
 local h = 4 + rnd(24)
 return {
  x = x;
  y = rnd(66)-2;
  w = 4 + rnd(24);
  h = h;
  v = 0.5+rnd(2.5);
 }
end
-->8
-- levels

levels = {
 {
  mapy = 0;
  bg = stars;
 },
 {
  mapy = 8;
  bg = stars;
 },
 {
  mapy = 16;
  bg = stars;
 },
 {
  mapy = 32;
  bonus = true;
  bg = stars;
 },
 {
  mapy = 56;
  bg = clouds;
 },
 {
  mapy = 24;
  bg = clouds;
 },
 {
  mapy = 48;
  bonus = true;
  bg = clouds;
 },
 {
  mapy = 40;
  bg = rects;
 },
}
