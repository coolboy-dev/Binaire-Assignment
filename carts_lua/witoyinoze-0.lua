--hARASS cLANKERS 3d
--bY mEiSzWI

state = "main_menu"

function _init()
	if state=="main_menu" then
		main_menu_init()
	end
	if state=="game" then
		game_init()
	end
	if state=="game_over" then
		game_over_init()
	end
end

function _update()
	if state=="main_menu" then
		main_menu_update()
	end
	if state=="game" then
		game_update()
	end
	if state=="game_over" then
		game_over_update()
	end
end

function _draw()
	for c=0,15 do
		pal(c, c+128, 1)
	end
	
	if state=="main_menu" then
		main_menu_draw()
	end
	if state=="game" then
		game_draw()
	end
	if state=="game_over" then
		game_over_draw()
	end
end
-->8
--3d math

function dist(x1,y1,x2,y2)
	return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))
end

function rotate(x,y,theta)
 return	x*cos(theta)-y*sin(theta),x*sin(theta)+y*cos(theta)
end

function project(x,y)
	return (x/y*50), 1/y*50
end

spr3d_list = {}

function spr3d(sx,sy,sw,sh,x,y,camx,camy,camdir)
	local rotx, roty = rotate(x-camx,y-camy,camdir)
	
	if roty <= 1 then
		return
	end
	
	local cx, scale = project(rotx,roty)
	local dw, dh = sw * scale, sh*scale
	local dx = 64+cx-dw/2
	local dy = 64-dh/4
	
	add(spr3d_list,
				{roty,sx,sy,sw,sh,
					dx,dy,dw,dh})
end

function render_spr3ds()
	if #spr3d_list == 0 then
	 return
	end
	for i=1,#spr3d_list do
		for s=1,#spr3d_list-1 do
			if spr3d_list[s][1] < spr3d_list[s+1][1]
			then
				local temp = spr3d_list[s]
				spr3d_list[s] = spr3d_list[s+1]
				spr3d_list[s+1] = temp
			end
		end
	end
	
	for s in all(spr3d_list) do
		deli(s,1)
		sspr(unpack(s))
	end
	
	spr3d_list = {}
end
-->8
--game loop

score = 0

function game_init()
	music(2)
	sfx(22)
	
	score = 0
	
	player_init()
	
	load_props()
	
	clankers={}
	police={}
	
	last_police_spawn = t()
	police_spawns = 0
end

function game_update()
	player:update()
	update_clankers()
	update_particles()
	update_police()
end

function game_draw()
	cls(0)
	rectfill(0,0,128,64,12)
	rectfill(0,64,128,128,3)
	
	draw_clankers()
	draw_particles()
	draw_props()
	draw_police()
	
	render_spr3ds()
	
	player:draw()
	
	pset(64,64,7)
end
-->8
-- player
player = {}

function player_init()
player = {
	x=8*12,
	y=8*12,
	
	vx=0,
	vy=0,
	friction=0.5,
	dir=0,
	move_speed=1,
	turn_speed=0.01,
	
	shoot_anim_timer=0,
	
	curse_timer=0,
	slur="",
	
	health = 10,
}

player.hit = function(self)
	self.health -= 1
	if self.health <= 0 then
		state="game_over"
		game_over_init()
	end
end

player.shoot = function(self)
	sfx(16)
	self.shoot_anim_timer = 8
	
	self:check_hits(clankers)
	self:check_hits(police)
end

player.check_hits = function(self, enemies)
	hits = {}
	
	-- find clankers in crosshair
	for c in all(enemies) do
		local rotx, roty = rotate(c.x - self.x, c.y - self.y, self.dir)
		
		if abs(rotx) < 6 then
			add(hits, c)
			break
		end
	end
	
	if(#hits == 0) return
	
	-- chose the closest one
	closest = hits[1]
	
	for h in all(hits) do
		if dist(h.x,h.y,self.x,self.y) < dist(closest.x,closest.y,self.x,self.y)
		then
			closest = h		
		end
	end
	
	closest:hit()
end

player.curse = function(self)
	self.slur = rnd({
		"clanker!",
		"tinskin!",
		"wireback!",
		"buckets of bolts!",
		"you bot!",
		"freaking droids!",
	})
	self.curse_timer=30
end

player.update = function(self)
	-- movement controls
	if btn(⬅️) then 
		self.dir += self.turn_speed
		self.dir = self.dir % 1
	end
	if btn(➡️) then 
		self.dir -= self.turn_speed
		self.dir = self.dir % 1
	end
	if btn(⬆️) then
		self.vx += sin(self.dir) * self.move_speed
		self.vy += cos(self.dir) * self.move_speed
	end
	if btn(⬇️) then
		self.vx -= sin(self.dir) * self.move_speed
		self.vy -= cos(self.dir) * self.move_speed
	end
	
	if btn(❘) and self.shoot_anim_timer == 0 then
		self:shoot()
	end
	
	if btn(🅾️) and self.curse_timer == 0 then
		self:curse()
	end
	
	-- apply velocity and friction
	self.x += self.vx
	self.y += self.vy
	
	self.x = max(min(self.x,14*12),1*12)
	self.y = max(min(self.y,14*12),1*12)
	
	self.vx *= self.friction
	self.vy *= self.friction
	
	-- tick down animation timers
	if self.shoot_anim_timer > 0 then
		self.shoot_anim_timer -= 1
	end
	if self.curse_timer > 0 then
		self.curse_timer -= 1
	end
end

player.draw = function(self)
	local y=0
	if self.shoot_anim_timer > 4 then
		y = 16	
	end
	sspr(
		80,y,16,16,
		64,74-self.shoot_anim_timer,64,64
	)
	
	sspr(
		96,0,16,16,
		0,
		128+sin(self.curse_timer/60)*60,
		64,
		64
	)
	print(
		self.slur,
		32,
		128+sin(self.curse_timer/60)*32,
		8
	)
	
	rectfill(2,122,52,125,0)
	rect(1,121,53,126,2)
	rectfill(2,122,2 + self.health*5,125,8)
	
	print("score: "..score, 0, 0, 7)
end
end
-->8
-- clankers

clankers = {}

function clanker(x,y,adult)
	local c = {
		x=x,
		y=y,
		adult=adult,
		health=3,
		seen_player=false,
		next_chirp=t()+rnd(3)+2,
	}
	-- checking distance from player
	c.player_dist = function(self)
		return dist(self.x,self.y,player.x,player.y)
	end
	-- clanker shot by player
	c.hit = function(self)
		if self:player_dist() < 40 then
			sfx(13)
		end
		self.health -= 1
		
		-- death
		if self.health <= 0 then
			if self:player_dist() < 40 then
				sfx(15)
			end
			explosion_fx(self.x,self.y)
			del(clankers, self)
			
			score += 100
		end
	end
	-- main update loop
	c.update = function(self)
		
		-- make a sound and look at the
		-- player when seeing them
		if not self.seen_player then
			if self:player_dist() < 40 then
				self.seen_player = true
				sfx(12)
			end
		end
		
		-- make random chirps when in
		-- hearing range
		if t() >= self.next_chirp then
			self.next_chirp=t()+rnd(5)+2
			if self:player_dist() < 40 then
				sfx(11)
			end
		end
		
	end
	-- draw y'know
	c.draw = function(self)
		local y = 0
		if(self.adult) y = 16
		
		local x = 64
		if(self.seen_player) x = 48
		
		spr3d(
			x,y,16,16,
			self.x,self.y,
			player.x,player.y,
			player.dir
		)
	end
	
	add(clankers, c)
	
	return c
end

function update_clankers()
	for c in all(clankers) do
		c:update()
	end
	if #clankers < 4 then
		spawn_clanker()
	end
end

function spawn_clanker()
	local x,y=0,0
	local rotx, roty=0,100
	
	for i=0,10 do
		x = (1+rnd(13))*12
		y = (1+rnd(13))*12
		rotx, roty = rotate(x-player.x,y-player.y,player.dir)
		if roty <= -1 then break end	
	end
	if roty > -1 then return end
	
	clanker(x,y,rnd({true,false}))
end

function draw_clankers()
	for c in all(clankers) do
		c:draw()
	end
end
-->8
-- particles

particles = {}

function particle(x,y,sx,sy,frames,life)
	local p = {
		x = x,
		y = y,
		frames = frames,
		sx = sx,
		sy = sy,
		born = t(),
		life = life
	}
	p.update = function(self)
		if t() - self.born > self.life then
			del(particles, self)
		end
	end
	p.draw = function(self)
		spr3d(
			self.sx + 8*flr(self.frames*(t()-self.born)/self.life),
			self.sy,
			8,8,
			self.x,self.y,
			player.x,player.y,
			player.dir
		)
	end
	
	add(particles, p)
end

function update_particles()
	for p in all(particles) do
		p:update()
	end
end

function draw_particles()
	for p in all(particles) do
		p:draw()
	end
end

function explosion_fx(x,y)
	particle(x,y,16,64,4,0.25)
end
-->8
-- props

props = {}

function load_props()
	props = {}
	
	
	
	for y=0,15 do
		for x=0,15 do
			if mget(x,y) == 128 then
				prop(0,64,16,24,x*12,y*12)
			end
			if mget(x,y) == 146 then
				prop(16,72,16,16,x*12,y*12)
			end
		end
	end
end

function prop(sx,sy,sw,sh,x,y)
	local p = {
		sx=sx,
		sy=sy,
		sw=sw,
		sh=sh,
		x=x,
		y=y
	}
	p.draw = function(self)
		spr3d(
			self.sx,self.sy,
			self.sw,self.sh,
			self.x,self.y,
			player.x,player.y,
			player.dir
		)
	end
	
	add(props,p)
end

function draw_props()
	for p in all(props) do
		p:draw()
	end
end
-->8
-- main menu

function main_menu_init()
	music(0)
end

function main_menu_update()
	if btnp(🅾️) then
		state = "game"
		game_init()
	end
end

function main_menu_draw()
	cls(0)
	fillp(∧)
	rectfill(0,0,127,127,1)
	fillp()
	
	sspr(48,16,16,16,t()*50%256-128,32,64,64+sin(t()/5)*5)
	
	sspr(0,32,16*8,4*8,0,16+cos(t()/2)*2,16*8,4*8+cos(t()/2)*2)
	
	print("by meiszwi",8,56,6)
	
	print("press 🅾️ to start",8,64,7)
	print([[


controls
--------
shoot - ❘
curse - 🅾️
turn  - ⬅️➡️
walk  - ⬆️⬇️		
]])
end
-->8
-- police

police = {}

last_police_spawn = 0
police_spawns = 0

function policeman(x,y)
	sfx(14)
	local p = {
		x=x,
		y=y,
		
		vx=0,
		vy=0,
		friction=0.5,
		move_speed=0.5,
		
		health=10,
		attack_cooldown=20
	}
	-- checking distance from player
	p.player_dist = function(self)
		return dist(self.x,self.y,player.x,player.y)
	end
	-- police shot by player
	p.hit = function(self)
		if self:player_dist() < 40 then
			sfx(17)
		end
		self.health -= 1
		
		-- death
		if self.health <= 0 then
			if self:player_dist() < 40 then
				sfx(18)
			end
			explosion_fx(self.x,self.y)
			del(police, self)
			
			score += 200
		end
	end
	-- main update loop
	p.update = function(self)
		
		-- move towards the player
		if self:player_dist() > 14 then
			local dx,dy=player.x-self.x,player.y-self.y
			dx /= self:player_dist()
			dy /= self:player_dist()
			
			self.vx += self.move_speed * dx
			self.vy += self.move_speed * dy
		end
		
		-- apply velocity and friction
		self.x += self.vx
		self.y += self.vy
		
		self.vx *= self.friction
		self.vy *= self.friction
		
		-- attack the player
		if self:player_dist() < 20 and self.attack_cooldown <= 0 then
			self.attack_cooldown = 30
			player:hit()
			sfx(19)
		end
		self.attack_cooldown -= 1
	end
	-- draw y'know
	p.draw = function(self)
		local x=0
		if dist(0,0,self.vx,self.vy) > 0 then
			x = 16 * flr(((t()*3) % 2)+1)
		end
		
		spr3d(
			x,0,16,16,
			self.x,self.y,
			player.x,player.y,
			player.dir
		)
	end
	
	add(police, p)
	
	return p
end

function update_police()
	for p in all(police) do
		p:update()
	end
	if t()-last_police_spawn > 20-min(police_spawns,15) then
		policeman(7*14,-14)
		last_police_spawn = t()
		police_spawns += 1
	end
end

function draw_police()
	for p in all(police) do
		p:draw()
	end
end
-->8
-- game over

darken_grad = {0,0,0,1,2,2,13,6,2,8,11,3,1,2,9,14}

go_anim_timer = 0
go_score_counter = 0

function game_over_init()
	sfx(20)
	go_anim_timer = 0
	music(-1)
end

function game_over_update()
	go_anim_timer += 1
	if go_anim_timer > 120 and btn(🅾️) then
		state="main_menu"
		main_menu_init()
	end
end

function game_over_draw()
	if go_anim_timer < 50 then
		for c=0,15 do
			local new_color=c
			for	i=0,flr(go_anim_timer/10) do
				new_color = darken_grad[new_color+1]
			end
			pal(c,new_color+128,1)
		end
	else
		cls(0)
		spr(
			134,32,
			min(-16+go_anim_timer-50,32),
			8,2
		)
		if go_anim_timer > 120 then
			print("score: "..go_score_counter.."\n\npress 🅾️ to continue",32,64,6)
			
			if go_anim_timer%5 == 0 and go_anim_timer < 150 then
				sfx(21)
				go_score_counter = (go_anim_timer - 120)/25*score
			end
		end
	end
end