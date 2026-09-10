-- orbitwell
-- by rufenerd

start_mission = 1
mission = start_mission
g = 1
infinity = 32767
moon_distance = 3844 -- 384400km
crash_speed = 0.6
sqrt_infinity = sqrt(infinity)
star_density = 0.01

ship = {
  x=0,
  y=-100,
  w=8,
  h=8,
  dx=0,
  dy=0,
  ang=0.25,
  dang=0,
  thrust=0.02,
  rot_thrust=0.0001,
  m=1,
  s=1
}


moon = { name="moon", m=4, x=0, y=-moon_distance, r=27, ang=0, dang=0 }
earth = { name="earth", m=100, x=0, y=0, r=100, dx=0, dy=0 }
objects = {ship}
particles = {}
terrain = {}

function _init()
  cartdata("rufenerd_orbitwell_v1") 
  
  sat = make_sat()
  reset_moon()
  init_terrain(earth, 12, 3, ship.x, ship.y, 0.005)
  init_terrain(moon, 6, 5, false, false, 0.01)
  init_stars()
  
  stat_index = 1

  init_levels()
  
  menuitem(1, "restart mission", reset_mission)
end

function reset_mission()
  mission_fail(0)
end

function reset_moon()
  del(objects, moon)
  local moon_os = orbit_speed(moon, earth)
  
  local a = rnd()
  moon.x = moon_distance*cos(a)
  moon.y = moon_distance*sin(a)
  
  moon.dx = moon_os * cos(a-0.25)
  moon.dy = moon_os * sin(a-0.25)
  
  add(objects, moon)
  moon_objects = {}
end

function make_sat()
 return new_object(1, 0, -150, 0.25, 2, 0, 0, 0, true)
end

function make_sat_in_orbit()
  del(objects, sat)
  sat = make_sat()
  local sat_os = orbit_speed(sat, earth)
  sat.dx = sat_os

  add(objects, sat)
end

function init_terrain(o, c1, c2, pad_x, pad_y, land_freq)
  --ocean
  add_terrain(o, 0, 0, o.r, c1, true)
  
  -- land
  local max_land_r = o.r/5
  local di=flr(o.r*0.8)
  for x=-di,di do    
    for y=-di,di do
      if rnd() < land_freq then
        add_terrain(o, x, y, rnd(max_land_r), c2, true)
      end
    end
  end
  
  --launch land
  if pad_x then
    add_terrain(o, pad_x, pad_y, 12, 3, true)
  end
  
  -- no land in space
  for i=1,flr(2*max_land_r) do
    add_terrain(o, 0, 0, o.r+i, 0, false)
    add_terrain(o, 0, 1, o.r+i, 0, false)
    add_terrain(o, 0, -1, o.r+i, 0, false)
  end
    
  --orbital guide lines
  for r=o.r, o.r+100, 20 do
    add_terrain(o, 0, 0, r, 5, false)
  end
end

function add_terrain(parent,x,y,r,c,fill)
  add(terrain, {x=x,y=y,r=r,c=c,fill=fill,parent=parent})
end

function new_object(m, x, y, ang, s, dx, dy, dang, skip_add)
  if not dx then
    dx = 0
  end
  if not dy then
    dy = 0
  end
  if not dang then
    dang = 0
  end
  local o = { m=m, s=s, x=x, y=y, dx=dx, ang=ang, dy=dy, ddx=0, ddy=0, dang=dang}
  
  if not skip_add then
    add(objects, o)
  end
  return o
end

function set_stats()
  stats = {
	  {"ship", ship},
	  {"satellite", sat},
	  {"moon", moon}
  }
end

function _update()
  if not game_started then
    local saved_mission = dget(0)
		  if saved_mission and saved_mission > 0 then
		    mission = saved_mission
		  end
		  
		  prior_time = dget(1) or 0
		  
		  title_update()
  elseif not main_music then
    music(0)
    main_music = true
  end
  
  if game_started then
    dset(1, game_duration())
  end
  
  set_stats()

  control_ship()
  change_stats()
    
  for o in all(objects) do
    update_object(o)
  end
  
  for p in all(particles) do
    p.x += p.dx
    p.y += p.dy
    p.ttl -= 1
    if p.ttl <= 0 then
      del(particles, p)
    end
  end
  
  for t in all(terrain) do
    if t.parent.name == "moon" then
      t.parent = moon
    end
  end
  
  update_moon_landing()

  check_objective()
end

function control_ship()
  if (ship.exploded) return
  if (astro) return

  if btn(⬅️) or btn(➡️) or btn(❘) then
    sfx(0)
		  local r = ship.w / 2
		  local px = ship.x - 1.1*r * cos(ship.ang)
		  local py = ship.y - 1.1*r * sin(ship.ang)
	
		  local pdx = -1*cos(ship.ang)+rnd(0.5)-.25
		  local pdy = -1*sin(ship.ang)+rnd(0.5)-.25
		  
		  if btn(⬅️) then
		    ship.dang += ship.rot_thrust
		    if rnd() < 0.5 then
		      new_particle(px+2*r*cos(ship.ang), py+2*r*sin(ship.ang), pdy+ship.dx, -pdx+ship.dy)
		    else
		      new_particle(px, py, -pdy+ship.dx, pdx+ship.dy)
		    end
		  elseif btn(➡️) then
		    ship.dang -= ship.rot_thrust

		    if rnd() < 0.5 then
		      new_particle(px+2*r*cos(ship.ang), py+2*r*sin(ship.ang), -pdy+ship.dx, pdx+ship.dy)
		    else
		      new_particle(px, py, pdy+ship.dx, -pdx+ship.dy)
		    end
		  end
		
		  if btn(❘) then
		    ship.dx += ship.thrust * cos(ship.ang)
		    ship.dy += ship.thrust * sin(ship.ang)

		    new_particle(px, py, pdx+ship.dx, pdy+ship.dy)
		  end
		else
		 sfx(0, -2)
		end
end

function new_particle(x, y, dx, dy, c)
  local p = {
    x=x,
    y=y,
    c=c or 7,
    dx=dx,
    dy=dy,
    ttl=10
  }
  add(particles, p)
end


sat_stat_index = 2
moon_stat_index = 3
mission_stats = {
  [9]=sat_stat_index,
  [10]=moon_stat_index
}
function change_stats()
  stat_index = (btn(🅾️) and mission_stats[mission]) or 1
end

function update_object(o)
  o.x += o.dx
  o.y += o.dy
  
  if tostring(o.dang) != "0" and tostring(o.dang) != "-0" then
  		o.ang += o.dang
  end
  if o.ang > 1 then
    o.ang -= 1
  end
  if o.ang < 0 then
    o.ang += 1
  end

  for p in all{earth, moon} do
    if p != o then
		    if o == ship and o.landed_on and (o.landed_on == p) and btn(❘) and (not astro) then
		      return
		    end
    
				  local d = dist(o, p)
				
				  if d > p.r then
						  local og = gravity(o, p)
						  o.dx += og.x
						  o.dy += og.y
						  if o.landed_on and o.landed_on == p then
						    o.landed_on = false
						    o.landing_ang = false
						  end
						else
				  		if d == infinity then
				    		return
				    end
				    
				    local rspeed = rel_speed(o, p)
				    if (not o.landed_on) and rspeed > crash_speed then
				      explode(o, rspeed)
				    end
				    if o == ship and not o.exploded then
				      o.landed_on = p
				      o.landing_ang = o.ang
				    end
						  o.dx = p.dx
						  o.dy = p.dy
						  o.dang = 0
						end
				end
		end
end

function explode(o, rspeed)
  sfx(0, -2)
  sfx(1)
  o.exploded = true
  o.explode_rspeed = rspeed
  del(objects, o)
  for i=1,100 do
    local p = {
      x=o.x,
      y=o.y,
      c=7+flr(rnd(4)),
      dx=2*(rnd(2)-1)+o.dx,
      dy=2*(rnd(2)-1)+o.dy,
      ttl=rnd(10)
    }
    add(particles, p)
  end
end

function gravity(o1, o2)
 local d = dist(o1, o2)
  if (d^2 < 0.001) then
    return {x=0, y=0}
  end
  
  local m = (o1.m * o2.m) / (d / g)
  m /= d
  local dx = o1.x - o2.x
  local dy = o1.y - o2.y
  local a = atan2(dx, dy)
  return {x=-m*cos(a), y=-m*sin(a)}
end

function dist(o1, o2)
  local dx = (o1.x - o2.x)/100
  local dy = (o1.y - o2.y)/100
  if abs(dx) > sqrt_infinity or abs(dy) > sqrt_infinity then
    return infinity
  end

  local res = dx^2 + dy^2
  if res < 0 then
    return infinity
  end
  return 100*sqrt(res)
end

function orbit_speed(o1, o2, r)
	 r = dist(o1, o2)
  local z = g * o2.m
  z /= r
  return sqrt(z)
end

--function orbit_period(o1, o2)
--  local r = dist(o1, o2)
--  return sqrt(r^3 / (g*o2.m))
--end

function ship_cam()
  camera(ship.x-64, ship.y-64)
end

function _draw()
  cls()
  
  if not game_started then
    draw_title()
    return
  end

  ship_cam()
  draw_terrain()
  draw_stars()

  for o in all(objects) do
  		local sx = flr(o.x-4)
  		local sy = flr(o.y-4)
  		
  		spr_r(o.s, sx, sy, o.ang)
  end
  
  draw_moon_landing()
  
  for p in all(particles) do
    pset(p.x, p.y, p.c)
  end
    
  if mission == #missions then
    draw_win()
    return
  else
    draw_hud()
  end
end

function angle(o1, o2)
 return atan2(o1.x - o2.x, o1.y-o2.y)
end

function vangle(o1, o2)
 return atan2(o1.dx - o2.dx, o1.dy-o2.dy)
end

function draw_terrain()
  for t in all(terrain) do
    local crc = t.fill and circfill or circ
    crc(t.parent.x+t.x, t.parent.y+t.y, t.r, t.c)
  end
end

function speed(o)
 return (o.dx^2+o.dy^2)^0.5
end

function rel_speed(o, p)
  local rdx = o.dx - p.dx
  local rdy = o.dy - p.dy
  return sqrt(rdx^2 + rdy^2)
end

function draw_ship()
 local r = ship.w / 2
end

function rounded(x)
  local f = flr(x)
  return (x-f > 0.5) and f+1 or f
end

-- adapted from jihem's #22757
-- with commented fix from gabe_8_bit
-- https://www.lexaloffle.com/bbs/?pid=52525
function spr_r(s,x,y,a,w,h)
 if (not s) return
 a=1-a
 sw=(w or 1)*8
 sh=(h or 1)*8
 sx=(s%16)*8
 sy=flr(s/16)*8
 x0=flr(0.5*sw)
 y0=flr(0.5*sh)
 sa=sin(a)
 ca=cos(a)
 for ix=sw*-1,sw+4 do
  for iy=sh*-1,sh+4 do
   dx=ix-x0
   dy=iy-y0
   xx=flr(dx*ca-dy*sa+x0)
   yy=flr(dx*sa+dy*ca+y0)
   if (xx>=0 and xx<sw and yy>=0 and yy<=sh) then
    local c = sget(sx+xx,sy+yy)
    if c>0 then
      pset(x+ix,y+iy,c)
    end
   end
  end
 end
end

function init_stars()
  stars = {}
  local colors = { 13, 5, 6, 7 }
  for x=0,128 do
    for y=0,128 do
      if rnd() < star_density then
        local col = colors[flr(rnd(#colors))+1]
        add(stars, {x=x,y=y,c=col})
      end
    end
  end
end

function draw_stars(draw_all)
  camera()
  local deep = draw_all or dist(ship, earth) == infiniity and dist(ship, moon) == infiniity
  for s in all(stars) do
    local near_earth = false
    local near_moon = false
    if not deep then
		    local rs = {
		      x=(s.x-ship.x)%128 + ship.x-64,
		      y=(s.y-ship.y)%128 + ship.y-64
		    }
		    near_earth = dist(rs, earth) < earth.r
		    near_moon = dist(rs, moon) < moon.r
		  end
    
    if not near_earth and not near_moon then
      pset((s.x-ship.x)%128,(s.y-ship.y)%128,s.c)
    end
  end
  ship_cam()
end
-->8
-- hud
function draw_hud()
  if (astro) return
  
  camera()
  local stat_pack = stats[stat_index]
  hud(stat_pack[2], stat_pack[1], 6, 94)
  
  draw_mission()
end

function hud(o, title, x0, y0)
  draw_overlay(x0, y0, 115, 29, 4)
  rect(x0-4, y0-4, x0+115+4, y0+29+4, 9)
  local rpad = 8
  local cpad = 38

  local row1 = y0 + rpad
  local row2 = y0 + 2*rpad
  local row3 = y0 + 3*rpad
  local row4 = y0 + 4*rpad
  
  local col1 = x0
  local col2 = x0 + cpad
  local col3 = x0 + 2*cpad
  
  center(title.." telemetry", y0, false, 9)
  gauge_stat("x", o.x, col1, row1, 0, 1)
  gauge_stat("y", -o.y, col2, row1, 0, 1)
  if (o == ship) then
    gauge_stat(5, o.ang*2, col3, row1, 4, 0)
    gauge_stat(6, o.dang*2, col3, row2, 4, 0)
  end
  
  gauge_stat("dx", o.dx, col1, row2, 3, 0)
  gauge_stat("dy", -o.dy, col2, row2, 3, 0)

  if o == ship then
    if not o.exploded then
      gauge_stat("|v|", speed(ship), col1, row3, 2, 0, vc)
      orbit_helper(earth, col2, col3, row3)
      
      local r = dist(earth, ship)
      if r > 200 or mission < 5 then
        gauge_stat("r", r, col2, row3)
      end
    else
      gauge_stat("relative crash v", ship.explode_rspeed, col1, row3, 3, 0, 8)
      print(" (>"..crash_speed..")", col3+12, row3, 8)
    end
  elseif o == moon or o == sat then
    gauge_stat("relv", rel_speed(ship, o), col3, row2, 2, 1)

		  local o_dist = dist(ship, o)
		  if o_dist != infinity then
      local dist_col = (o == sat and (o_dist < sat_repair_rtol)) and 12 or 7
				  gauge_stat("dist", o_dist, col3, row1, 0, 1, dist_col)
				end
  end
end

function orbit_helper(p, x, x2, y)
  vc = 7
  if (mission < 5) return
  local ship_speed = speed(ship)
  local os = orbit_speed(ship, p)
  
  local r = dist(ship, p)
  if r != infinity and not ship.exploded then
    local tol = 0.02
		  if abs(ship_speed - os) < tol then
		    vc = 11
		    osc = 11
		  elseif ship_speed < os then
		    vc = 12
		    osc = 8
		  else
		    vc = 8
		    osc = 12
		  end
		  
		  if r < 200 then
--		    pal(7, osc)
--		    spr(7, x, y-2)
--		    line(x+8, y-2, x+22, y-2, osc)
--		    pal()
--      gauge_stat("  mg/r", os, x, y, 2, 0, osc)
      gauge_stat("orbv", os, x, y, 2, 0, osc)
      
      local ecc = eccentricity()
      local ecolor = ecc < etol and 11 or (ecc < (2*etol) and 9 or 8)
      gauge_stat("ecc", ecc, x2, y, 3, 0, ecolor)
    else
      vc = 7
    end
  end
end

function eccentricity()
  local r = dist(ship, earth)
  local v = speed(ship)
  local mu = earth.m * g
  local x = ship.x
  local dx = ship.dx
  local y = ship.y
  local dy = ship.dy
  
  -- claude helped write
  -- the following lines
  -- since getting e from the above
  -- was beyond me
  local am = x * dy - y * dx -- cross product of 
  local ex = ((dy * am) / mu) - (x / r)
  local ey = (-(dx * am) / mu) - (y / r)
  return sqrt(ex^2 + ey^2)
end

function gauge_stat(name, val, x, y, prec, pad, c)
  if (not val) return
  if (val == infinity) return
  
  prec = prec or 0
  pad = pad or 0
  c = c or 7
  local rval = round(val, prec)
  
  local padding = ""
  for i=1,pad do
    padding = padding.." "
  end
  if type(name) == "number" then
    spr(name, x, y)
    print("  :"..padding..rval, x, y, c)
  else
    print(name..":"..padding..rval, x, y, c)
  end
end

function round(x, prec)
 return rounded((10^prec)*x)/(10^prec)
end

function center(txt, y, draw_overlay, c)
  local x = 64 - (#txt*4)/2
  local prnt = draw_overlay and oprint or print
  prnt(txt, x, y, c or 7)
end

-- adapted from https://www.reddit.com/r/pico8/comments/1kmdjk0/hows_the_semitransparent_effect_in_pico8_pause/
function draw_overlay(x, y, w, h, padding)
 x = x - padding
 y = y - padding
 w = w + 2*padding
 h = h + 2*padding
 -- screen memory as the sprite sheet
 poke(0x5f54,0x60)
 -- set overlay palette
 pal({0,1,5,1,1,1,1,1,1,4,1,1,1,1,1})
 -- draw screen to screen 
 -- (sprite sheet x,sprite sheet y,width,height,screen x,screen y)
 sspr(x,y,w,h,x,y) 
 -- reset palette
 pal()
 -- reset spritesheet
 poke(0x5f54,0x00)
end

function oprint(msg, x, y, c)
  local l = #msg
  local splt = split(msg, "\n")
  local max_row_chars = -1
  for r in all(splt) do
    if #r > max_row_chars then
      max_row_chars = #r
    end
  end
  local w = 4*max_row_chars-1
  local h = 6 * #splt-1
  local p = 2
  draw_overlay(x, y, w, h, p)
  print(msg, x, y, c)
end

-->8
missions = {}
mission_titles = {}
mission_texts = {}

etol = 0.05
function init_levels()
  mission_start_at = t()

  make_mission(
    hold_x,
    [[push ❘ for thrust]],
    [[the cosmos is within us.
we are made of star-stuff.
we are a way for the universe
to know itself.
  - CARL SAGAN]]
  )

  make_mission(
    reach_elev_200,
    [[fly deeper into space]],
    [[remote test 1
    
use thrust ❘ to fly the rocket
deeper into space (r>200)

pause/enter to restart any
mission back on earth]]
  )

		  make_mission(
		    y_over_200,
		[[fly to y<-200]],
		[[remote test 2
		
rotate and move to y<-200

➡️: clockwise spin 
⬅️: counterclockwise thrust]]
)
		
		make_mission(
		    crash,
		[[crash into earth (0,0)]],
		[[final remote test

crash the rocket, for science]]
		)
		
		make_mission(
		    no_thrust_orbit,
		[[orbit earth without thrust]],
		[[mission 1: orbit
		
get into an ok orbit, then
coast one revolution.

orbv is target speed |v| for
the ship's current elevation.
lower orbit eccentricity
is better as ecc=0 is a circle.]]
)

  make_mission(
    circle_and_land,
    "circle earth and land anywhere",
    [[mission 2: orbit and land
    
orbit the earth and gently
(speed |v|<]]..crash_speed..[[) land
the rocket anywhere on earth
(ocean ok, rocket floats)]]
  )

		
		make_mission(
		    good_sat_launch,
		    		"launch sat 🅾️/z into low-e orbit",
		[[mission 3: launch satellite
		
obtain circle (e<0.05) orbit
at right speed (all green)
and press 🅾️/z to release sat
]]
		)
		
		  make_mission(
    circle_and_land,
    "circle earth, land at north pole",
    [[mission 4: orbit and return
    
orbit the earth and land
the rocket back down where you
launched]]
  )
  
  make_mission(
      repair_sat,
    "stay near satellite for 15 secs",
    [[mission 5: repair satellite
    
match orbit with the satellite
and stay near it for 15 seconds
while repairs are made.

hold 🅾️/z for sat telemetry.
]]
  )

  make_mission(
      moon_and_back,
    "land on moon, return to earth",
    [[final mission: moon and back
    
hold 🅾️/z for moon telemetry.

fly to the moon and land,
return to the earth and land
a hero!
]]
  )

  make_mission(
    completed,
[[end of game
]],
[[you win!!]]
)
end

function no_thrust_orbit()
  local thrusting = btn(❘) or btn(⬅️) or btn(➡️)
  if thrusting or ship.exploded then
    orbit_start = false
    orbit_halfway = false
  else
    local a = atan2(ship.x, ship.y)
    if not orbit_start then
      orbit_start = a
    else
      local ang_dist = abs(orbit_start - a)
      if not orbit_halfway and ang_dist > 0.5 then
        orbit_halfway = true
      elseif abs(ang_dist) < 0.01 and orbit_halfway then
        return true
      end
    end
  end
  return false
end

function good_sat_launch()
  if not deployed_sat then
    if btn(🅾️) then
    		deploy_sat()
    end
  elseif not good_e_sat then
    mission_fail(6)
    return false
  else
    return true
  end
end

function deploy_sat()
  del(objects, sat)
  sat.x = ship.x
  sat.y = ship.y
  sat.ang = ship.ang
  sat.dx = ship.dx
  sat.dy = ship.dy
  sat.dang = ship.dang
  sat.exploded = false
  add(objects, sat)
  deployed_sat = true
  
  good_e_sat = eccentricity() < etol
  
  ship.dx += 0.2 * cos(ship.ang)
  ship.dy += 0.2 * sin(ship.ang)
end

function good_e_orbit()
  return no_thrust_orbit() and eccentricity(ship) < etol
end

function circle_and_land()
  -- reach each quadrant
  if ship.x > 0 and ship.y < 0 then
    q1 = true
  elseif ship.x < 0 and ship.y < 0 then
    q2 = true
  elseif ship.x < 0 and ship.y > 0 then
    q3 = true
  elseif ship.x > 0 and ship.y > 0 then
    q4 = true
  end
  
  if  ship.landed_on and ship.landed_on == earth and (mission != 8 or (abs(ship.x) < 12 and ship.y<0)) then
    return q1 and q2 and q3 and q4
  end
end

function moon_and_back()
  if moon == ship.landed_on then
    landed_on_moon = true
  end
  
  return landed_on_moon and earth == ship.landed_on
end

function completed()
  dset(0)
  return false
end

x_held_at = false
function hold_x()
  if btn(❘) and (not x_held_at) then
    x_held_at = t()
  elseif not btn(❘) then
    x_held_at = false
  end
  
  return x_held_at and t() - x_held_at > 0.5
end

function ang_25()
  return ship.ang > 0.24 and ship.ang < 0.26
end

function crash()
  return ship.exploded
end

function make_mission(objective, title, text)
  add(missions, objective)
  add(mission_titles, title)
  add(mission_texts, text)
end

function reach_elev_200()
  return dist(ship, earth) > 200
end

function y_over_200()
  return ship.y > 200
end

function check_objective() 
  local win = missions[mission]()
  if win and t() - mission_start_at > 2 then
    complete_delay = mission == 7 and 6 or false
    mission_complete(complete_delay)
  end
  
  if not win and ship.exploded then
    mission_fail()
  end
  
  reset_ship_if_needed()
end

function mission_complete(reset_delay)
  reset_delay = reset_delay or 2
  if mission > 1 then
    sfx(2)
    set_alert("mission complete!", reset_delay)
    if (not reset_at) and (mission > 3) then
      reset_at = t() + reset_delay
    end
  end

  mission += 1
  if mission == #missions then
    if not game_end_time then
      game_end_time = t()
    end
    local your_time = game_duration()
    local fastest = dget(2)
    if (not fastest) or (fastest < 1) or (your_time < fastest) then
      dset(2, your_time)
    end
  end
  mission_start_at = t()
  dset(0, mission)
end

function reset_ship_if_needed()
  if reset_at and t() > reset_at then
    reset_at = nil
    make_new_ship()
    
    if mission == 6 or mission == 8 then
      q1 = false
      q2 = false
      q3 = false
      q4 = false
    elseif mission == 7 then
      deployed_sat = false
      good_e_sat = false
		  elseif mission == 9 then
		    broken_sat_init = false
		    make_sat_in_orbit()
    elseif mission == 10 then
      landed_on_moon = false
      landed_at = nil
      moon_flag = nil
      reset_moon()
    end
    
    mission_start_at = t()
  end
end

function make_new_ship()
  del(objects, ship)
  ship.x = 0
  ship.y = -100
  ship.ang = 0.25
  ship.dx = 0
  ship.dy = 0
  ship.dang = 0
  ship.exploded = false
  ship.explode_rspeed = false
  add(objects, ship)
end

function mission_fail(wait)
  wait = wait or 2
  if not reset_at then
    reset_at = t() + wait
  end
end

function set_alert(msg, show_duration)
  show_duration = show_duration or 2
  alert = msg
  alert_until = t() + show_duration
end

alert_at = -1
function draw_mission()
  if alert then
    center(alert, 52, true)
    if t() > alert_until then
		    alert = nil
		  end
  else
    local text_delay = mission >= 3 and 15 or 9
		  if t() - mission_start_at < text_delay then
		    oprint(mission_texts[mission], 4, 4, 7)
		  elseif not reset_at then
		    center(mission_titles[mission], 4, true)
		  end
  end
  
  draw_sat_repair()
end

-->8
-- repair sat mission
sat_repair_rtol = 12
function repair_sat()
  if (mission != 9 and not reset_at) return

  if not broken_sat_init then
    make_sat_in_orbit()
    sat.s = 8
    broken_sat_init = true
  end
  
  local r = dist(ship, sat)
  if r < sat_repair_rtol then
    if not repair_start_at then
      repair_start_at = t()
    end
  else
    repair_start_at = false
  end
  
  local complete = repair_start_at and t() - repair_start_at >= 15
  if complete then
    sat.s = 2
  end
  
  return complete
end

function draw_sat_repair()
  if (mission != 9 and not reset_at) return
  if (not repair_start_at) return
  
  local dur = t() - repair_start_at
  if dur < 1 or dur > 15 then
    return
  else
    local x1 = ship.x
    local y1 = ship.y
    local x2 = sat.x
    local y2 = sat.y
    
    local ax = 0.2*x1+0.8*x2
    local ay = 0.2*y1+0.8*y2
    ship_cam()
    line(ship.x, ship.y, ax+4, ay+4, 7)
    spr(4, ax, ay)
  end
end
-->8
function draw_moon_landing()
  ship_cam()
  for o in all(moon_objects) do
    spr(o.s, moon.x+o.x-4, moon.y+o.y-4)
  end
end

function update_moon_landing()
  if (mission != 10 or moon != ship.landed_on or ship.exploded) return
  
  if not landed_at then
    landed_at = t()
    moon_objects = {}
  end
  
  if (not moon_flag) and t() - landed_at > 1 then
    if not astro then
		    astro = {s=4, x=ship.x-moon.x, y=ship.y-moon.y, target="moon", speed=0.2}
		    add(moon_objects, astro)
		  end
  end
  
  if astro then
    if astro.target == "moon" then
      local a = atan2(astro.x, astro.y)
      astro.x -= astro.speed*cos(a) 
      astro.y -= astro.speed*sin(a) 
      if (not moon_flag) and abs(astro.x) < 4 and abs(astro.y) < 4 then
      		moon_flag = {s=3, x=0, y=-4}
      		add(moon_objects, moon_flag)
      		astro.target = "ship"
      end
    elseif astro.target == "ship" then
						astro.x = 0.98 * astro.x + 0.02 * (ship.x-moon.x)
						astro.y = 0.98 * astro.y + 0.02 * (ship.y-moon.y)
      if abs(ship.x-(moon.x+astro.x)) < 4 and abs(ship.y-(moon.y+astro.y)) < 4 then
      		del(moon_objects, astro)
      		astro = nil
      end
    end
  end
end
-->8
menu_index = 1
menu_index_at = -1
menu = {"continue", "restart"}
function title_update()
  if t() - menu_index_at < 0.3 then
    return
  end
  
  if btn(❘) or btn(🅾️) then
    if menu[menu_index] == "restart" then
      mission = start_mission
      dset(0, nil)
      dset(1, nil)
      prior_time = 0
    end
    
    game_started = true
    game_start_time = t()
    return
  end

  if btn(⬇️) then
    menu_index += 1
  elseif btn(⬆️) then
    menu_index -= 1
  end

  menu_index = max(1, min(menu_index, #menu))
end

function draw_title()
  draw_stars(true)
  camera()
  center("ORBITWELL", 50, true, 9)
  center("by rufenerd", 60, true)

  if mission == 1 then
    menu = {"press ❘ to start"}
  end
  draw_menu()
end

function draw_menu()
  for i, m in ipairs(menu) do
    center(m, 90 + i*10, true, (i == menu_index and 9) or 6)
  end
end

function game_duration()
  if not game_start_time then
    return 0
  end
  local end_time = game_end_time or t()
  
  return (end_time-game_start_time) + prior_time
end

function draw_win()
  camera()
  fireworks()
  center("you win!!", 32, true, 7+rnd(8))
  local dur = format_time(game_duration())
  center("your time: "..dur, 42, true, 7)
  local fastest = format_time(dget(2))
  center("fastest time: "..fastest, 52, true, 7)
end

function fireworks()
  for i=1,2 do
    local speed = rnd(4)
    local x = ship.x+rnd(256)-128
    local y = ship.y+rnd(256)-128
    for j=1,8 do
      new_particle(
        x + rnd(6)-3,
        y + rnd(6)-3,
        rnd(2*speed) - speed,
        rnd(2*speed) - speed,
        7+rnd(9)
      )
    end
  end
end

function format_time(dur)
local h=0
  local m=0
  local s=0
  while dur > 3600 do
    h += 1
    dur -= 3600
  end
  while dur > 60 do
    m += 1
    dur -= 60
  end
  s = rounded(dur)
  return h.."h "..m.."m "..s.."s"
end
