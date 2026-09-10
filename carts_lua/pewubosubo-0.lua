-- a bee adventure
-- by charlie w.
-- music by robby duguay

--simple camera
cam_x=0
cam_y=0

--map limits
map_start_x=0
map_end_x=1024
map_start_y=0
map_end_y=256

max_health=4
max_pollen=4
max_hbees=4
max_pollen_total=8

--THIS IS HOW MUCH HONEY MUST BE AQUIRED BEFORE
--THE END OF THE YEAR
honey_goal=20
honey_collected=0

seasons={
	spng=0,
	summ=1,
	fall=2,
	wint=3,
	season=0,
	timer=0,
	time=0,
}

seasons.timer=0
seasons.time=(2.5*60)
--seasons.time=(5)

current_pal=0

game_modes={
	splash=1,
	info=2,
	play=3,
	done=4
}

game_mode=game_modes.splash

--------------------------------
function set_game_mode( mode )
	game_mode=mode
	printh("game_mode updated:"..game_mode)
end

--------------------------------
function _init()
	map_init()
	bee_init()
	flies_init()
	hbee_init()
	init_snowflakes()
	title_init()

	for b=1,max_hbees do
		hbee_spawn()
	end

	init_pollen_system()

	seasons.season=seasons.spng
	seasons.timer=flr(time())
	change_season(seasons.season)

	play_music_track(1)
end

--------------------------------
function reset_game()
	printh("reset_game()")
	max_health=4
	max_pollen=4
	honey_collected=0
	--empty the hive of pollen
	hive.filled=0
	for i=1,#hive.honey_comb do
		hive.honey_comb[i].full=false
	end
	reset_all_flower_pollen()
	_init()
	bee.x=bee_reset_x
	bee.y=bee_reset_y
	set_game_mode(game_modes.play)
end

--------------------------------
function _update()

	if game_mode!=game_modes.play then
		if game_mode==game_modes.splash then
			title_update()
			if btnp(❘) then
				reset_game()
			elseif btnp(🅾️) then
				set_game_mode(game_modes.info)
			end
			return
		elseif game_mode==game_modes.info then
			if btnp(❘) then
				set_game_mode(game_modes.play)
				reset_game()
			else
				return
			end
		elseif game_mode==game_modes.done then
			if btnp(🅾️) then
				toast_cancel()
				title_init()
				set_game_mode(game_modes.splash)
				return
			else
				return
			end
		end
	end

	--update player's bee
	bee_update()
	bee_animate()

	if btn(🅾️) then
		if bee.dead then
			bee.dead=false
			bee.health=max_health
			bee.x=bee_reset_x
			bee.y=bee_reset_y
			toast_cancel()
			play_music_track(1)
		else
			--recall hbees!
			if bee_call.cooldown <= 0 and not bee_call.active then
				call_helper_bees()
			end
		end
	end

	-- Update bee call cooldown
	if bee_call.cooldown > 0 then
		bee_call.cooldown -= 1
	end

	-- Update sonar effect
	update_sonar_effect()

	--update enemies
	flies_update(bee)

	--update helper bees
	hbee_update(bee)

	--update pollen collection
	check_pollen_collection(bee)
	update_pollen_regeneration()

	--update pollen deposite
	map_update_pollen_deposite(bee)

	--update season if timer elapsed
	update_season()

	--update snow if it's winter time
	if seasons.season == seasons.wint then
		update_snowflakes()
	end

	::draw_camera::

	--simple camera
	cam_x=bee.x-64+(bee.w/2)
	cam_y=bee.y-64+(bee.h/2)
	if cam_x<map_start_x then
		cam_x=map_start_x
	end
	if cam_x>map_end_x-128 then
		cam_x=map_end_x-128
	end
	if cam_x<0 then
		cam_x=0
	end
	if cam_y<8 then
		cam_y=8
	end
	if cam_y>128 then
		cam_y=128
	end
	camera(cam_x,cam_y)
end

--------------------------------
function _draw()

	cls(current_pal)

	if game_mode!=game_modes.play then
		if game_mode==game_modes.splash then
			draw_splash_screen()
			return
		elseif game_mode==game_modes.info then
			draw_info_screen()
			return
		end
	end

	draw_map()
	draw_bee()

	-- Draw sonar effect if active
	if sonar.active then
		draw_sonar_effect()
	end

	draw_flies()
	draw_hbees()

	--draw snow if it's winter time
	if seasons.season == seasons.wint then
		draw_snowflakes()
	end

	draw_staus()

	draw_toast()

	--draw_debug()
	--draw_flower_debug()
end

--------------------------------
function draw_staus()
	rectfill(cam_x+31,cam_y+118,cam_x+100,cam_y+126,0)
	rect(cam_x+31,cam_y+118,cam_x+100,cam_y+126,7)

	local tx=cam_x+32
	local ty=cam_y+118

	--health
	for h=1,max_health do
		if h<=bee.health then
			spr(113,tx,ty)
		else
			spr(112,tx,ty)
		end
		tx+=6
	end

	-- pollen count
	tx+=2
	for p=1,max_pollen do
		if p<=bee.pollen then
			spr(115,tx,ty)
		else
			spr(114,tx,ty)
		end
		tx+=5
	end

	--show possible pollen count
	for p=max_pollen+1,max_pollen_total do
		spr(29,tx,ty)
		tx+=5
	end

	--honey count
	rectfill(cam_x+1,cam_y+1,cam_x+47,cam_y+9,0)
	rect(cam_x+1,cam_y+1,cam_x+47,cam_y+9,7)
	print("HONEY:"..honey_collected.."/"..honey_goal,cam_x+3,cam_y+3,10)

	-- helper bees
	-- tx+=2
	-- for b=1,#hbees do
	-- 	if b<=#hbees do
	-- 		spr(58,tx,ty)
	-- 	end
	-- 	tx+=5
	-- end
end

--------------------------------
function update_season()

	if game_mode==game_modes.done then
		return
	end

	if time()-seasons.timer>seasons.time then
		seasons.season+=1

		if seasons.season == 4 then
			seasons.season=0
			--check for end-game condition (end of winter season)
			check_end_game()
			return
		end

		change_season(seasons.season)
		seasons.timer=flr(time())

		--show a season toast
		local txt
		if seasons.season==0 then
			txt="spring!"
			play_music_track(1)
		elseif seasons.season==1 then
			txt="summer!"
			play_music_track(3)
		elseif seasons.season==2 then
			txt="fall!"
			play_music_track(4)
		else
			txt="winter!"
		end
		show_toast("season change","",txt,"",2)
		printh("season changed to:"..seasons.season)
	end
end

--------------------------------
function change_season(s_num)
	pal() --reset pal
	if s_num==0 then
		current_pal=12
	elseif s_num==1 then
		current_pal=14
	elseif s_num==2 then
		current_pal=9
	elseif s_num==3 then
		current_pal=5
	end

	pal(12, current_pal)
	printh("season:"..s_num)
end

--------------------------------
function check_end_game()
	printh("check_end_game")
	if game_mode!=game_modes.done then
		--did player collect enough honey?
		if honey_collected>=honey_goal then
			show_toast("your bee lives","another year!","press 🅾️ to","start again",0)
			printh("  win")
		else
			show_toast("not enough honey","to survive!","press 🅾️ to","try again",0)
			printh("  loose")
		end
		--set game mode to end mode
		set_game_mode(game_modes.done)
		pal()
	end
end

--------------------------------
function reset_pal()
	pal()
	pal(12, current_pal)
end

--------------------------------
function draw_debug()
	--print("x:"..bee.x..",y:"..bee.y,1,0,0)
	--print("dx:"..b.dx..",dy:"..b.dy,1,9,0)
	--print("cam_x:"..cam_x,1,17)
	--draw_collision_box()

	-- print the window numbers and their centers
	for i=1,32 do
		local cx, cy = window_center(i)
		print(i, cx-4, cy-2, 7)
	end
end

-->8
--bee code--
bee_reset_x=5*8  --in pixels
bee_reset_y=2*8

sonar = {
	active = false,
	radius = 0,
	max_radius = 16,
	speed = 4,
	direction = 1, -- 1 = expanding, -1 = contracting
	center_x = 0,
	center_y = 0,
	color = 7,
	wait_timer = 0,
	wait_time = 15 -- frames to wait at max expansion before reversing
}

bee_call = {
	active = false,  -- Flag to indicate if bees are being called
	cooldown = 0,    -- Cooldown timer
	max_cooldown = 60 -- Maximum cooldown (1 second at 60fps)
}

--------------------------------
function bee_init()
	bee={
		--sprite number
		sp=1,
		sp_dead=9,

		--position, height & width
		x=bee_reset_x,
		y=bee_reset_y,
		dx=0,
		dy=0,
		max_dx=2.5,
		max_dy=2.5,
		acc=0.5,
		boost=0.75,

		w=2*8,
		h=2*8,

		anim=0,
		anim_sp_inc=2,
		flp=false,

		--movement
		flying=false,
		falling=true,
		walking=false,
		landed=false,

		--health
		health=max_health,
		dead=false,

		--inventory
		pollen=0,
	}

	gravity=0.3
	friction=0.85
end

--------------------------------
function bee_update()
	--check if dead
	if bee.health == 0 and not bee.dead then
		bee.dead=true
		bee.pollen=0
		sfx(62)
		play_music_track(2)
		show_toast("oh no!","your bee died!","","press 🅾️",0)
	end

	--physics
	bee.dy+=gravity
	bee.dx*=friction

	if not bee.dead then
		--controls
		if btn(⬅️) then
			bee.dx-=bee.acc
			--bee.walking=true
			bee.flp=true
		end
		if btn(➡️) then
			bee.dx+=bee.acc
			--bee.walking=true
			bee.flp=false
		end

		--jump into air
		if btn(❘) then
			bee.dy-=bee.boost
			bee.landed=false
			bee.flying=true
		end
	end

	--collision checks up/down
	if bee.dy>0 then
		bee.falling=true
		bee.landed=false

		bee.dy=limit_speed(bee.dy,bee.max_dy)

		if collide_map(bee,"down",flg.wall) then
			bee.landed=true
			bee.falling=false
			bee.flying=false
			bee.dy=0
			bee.y-=((bee.y+bee.h+1)%8)-1
		end
	elseif bee.dy<0 then
		bee.flying=true
		if collide_map(bee,"up",flg.wall) then
			bee.dy=0
		end
	end

	--collision check left/right
	if bee.dx<0 then
		bee.dx=limit_speed(bee.dx,bee.max_dx)
		if collide_map(bee,"left",flg.wall) then
			bee.dx=0
		end
	elseif bee.dx>0 then
		bee.dx=limit_speed(bee.dx,bee.max_dx)
		if collide_map(bee,"right",flg.wall) then
			bee.dx=0
		end
	end

	--move the bee
	bee.x+=bee.dx
	bee.y+=bee.dy

	--limit player to map
	if bee.x<map_start_x then
		bee.x=map_start_x
	end
	if bee.x>map_end_x-bee.w then
		bee.x=map_end_x-bee.w
	end

	if bee.y<map_start_y then
		bee.y=map_start_y
		bee.dy=0
	end
	if bee.y>map_end_y-bee.h then
		bee.y=map_end_y-bee.h
	end
end

--------------------------------
function bee_animate()
	if bee.flying then
		if time()-bee.anim>.05 then
			bee.anim=time()

			bee.sp+=bee.anim_sp_inc

			if bee.sp > 5 then
				bee.anim_sp_inc=-2
				bee.sp=3
			elseif bee.sp < 1 then
				bee.anim_sp_inc=2
				bee.sp=1
			end
		end
	else
		bee.sp=7
	end
end

--------------------------------
function limit_speed(num,maximum)
	return mid(-maximum,num,maximum)
end

--------------------------------
function call_helper_bees()
	-- Set the bee call active flag
	bee_call.active = true

	-- Start the sonar effect
	sonar.active = true
	sonar.radius = 0
	sonar.direction = 1 -- Expanding
	sonar.center_x = bee.x + bee.w/2
	sonar.center_y = bee.y + bee.h/2
	sonar.color = 7
	sonar.wait_timer = 0

	-- Mark all helper bees as returning to player
	for i=1, #hbees do
		if not hbees[i].dead then
			hbees[i].following = true
			hbees[i].return_to_player = true
		end
	end

	-- Play sound effect
	sfx(63) -- Use an appropriate sound effect ID

	-- Set cooldown
	bee_call.cooldown = bee_call.max_cooldown
  end

--------------------------------
function draw_bee()
	if bee.dead then
		spr(bee.sp_dead,bee.x,bee.y,bee.w/8,bee.h/8,bee.flp)
	else
		spr(bee.sp,bee.x,bee.y,bee.w/8,bee.h/8,bee.flp)
	end
end

--------------------------------
function update_sonar_effect()
	if not sonar.active then
	  return
	end

	if sonar.direction == 1 then
	  -- Expanding
	  sonar.radius += sonar.speed

	  if sonar.radius >= sonar.max_radius then
		-- Wait at maximum radius
		sonar.wait_timer += 1

		if sonar.wait_timer >= sonar.wait_time then
		  -- Switch to contracting
		  sonar.direction = -1
		  sonar.color = 6 -- Change color for the return wave
		end
	  end
	else
	  -- Contracting
	  sonar.radius -= sonar.speed

	  -- When sonar effect is done
	  if sonar.radius <= 0 then
		sonar.active = false
		bee_call.active = false

		-- Reset any return flags for helper bees
		for i=1, #hbees do
		  if not hbees[i].dead then
				hbees[i].return_to_player = false
		  end
		end
	  end
	end
end

--------------------------------
-- Function to draw the sonar effect
function draw_sonar_effect()
	sonar.center_x = bee.x + bee.w/2
	sonar.center_y = bee.y + bee.h/2

	-- Draw a hollow circle around the bee
	circ(sonar.center_x, sonar.center_y, sonar.radius, sonar.color)

	-- Draw a slightly thinner concentric circle for effect
	circ(sonar.center_x, sonar.center_y, sonar.radius-4, sonar.color)
	circ(sonar.center_x, sonar.center_y, sonar.radius-8, sonar.color)
end

-->8
--map code--

flg={
	wall=0,
	flower=1,
	hive=2,
}

hc={
	full=false,
}

hive={
	honey_comb={},
	filled=0,
	x=0,
	y=0
}

--------------------------------
function map_init()

	hive.x, hive.y = window_center(9)

	for i=1,16 do
		local new_hc={}
		for k,v in pairs(hc) do
			new_hc[k]=v
		end

		add(hive.honey_comb, new_hc)
	end

	init_flicker_sprites()
end

--------------------------------
function draw_map()
	map(0,0,0,0,128,64)
	draw_hive()
	draw_flicker_sprites()
end

--collision box
cb={x1,y1,x2,y2}

--------------------------------
function collide_map(obj,dir,flag)
	--obj=table needs x,y,w,h
	--aim=left,right,up,down

	local x=obj.x	local y=obj.y
	local w=obj.w	local h=obj.h

	local x1=0	local y1=0
	local x2=0	local y2=0

	if dir=="left" then
		x1=x-1		y1=y
		x2=x			y2=y+h-1
	elseif dir=="right" then
		x1=x+w-1	y1=y
		x2=x+w		y2=y+h-1
	elseif dir=="up" then
		x1=x+2			y1=y-1
		x2=x+w-3	y2=y
	elseif dir=="down" then
		x1=x+2		y1=y+h
		x2=x+w-3	y2=y+h
	end

	-- update collision box for debug
	cb.x1=x1  cb.y1=y1
	cb.x2=x2  cb.y2=y2

	--pixels to tiles
	x1/=8		y1/=8
	x2/=8		y2/=8

	if fget(mget(x1,y1), flag)
	or fget(mget(x1,y2), flag)
	or fget(mget(x2,y1), flag)
	or fget(mget(x2,y2), flag) then
		return true
	else
		return false
	end
end

--------------------------------
function draw_collision_box()
	rect(cb.x1,cb.y1,cb.x2,cb.y2,7)
end

--------------------------------
function window_center(window_num)
	-- check for valid input
	if window_num < 1 or window_num > 32 then
		return nil
	end

	-- convert from 1-16 to x,y grid coordinates (0-based)
	local col = (window_num - 1) % 8
	local row = flr((window_num - 1) / 8)

	-- calculate center pixel coordinates
	local center_x = col * 128 + 64
	local center_y = row * 128 + 64

	return center_x, center_y
end

--------------------------------
function draw_hive()
	local hx=hive.x
	local hy=hive.y
	local x,y
	local index=1

	hx-=(2*8) hy-=(2*8)

	y=hy
	for r=1,4 do
		x=hx
		for c=1,4 do
			if hive.honey_comb[index].full then
				spr(31,x,y)
			end
			x+=8
			index+=1
		end
		y+=8
	end
end

--------------------------------
function map_update_pollen_deposite(entity)
	--is bee close to hive?
	if collide_map(entity,"down",flg.hive) then
		--does bee have pollen to deposit?
		for p=1,bee.pollen do
			for hc=1,#hive.honey_comb do
				if not hive.honey_comb[hc].full then
					hive.honey_comb[hc].full=true
					hive.filled+=1
					bee.pollen-=1
					break
				end
			end
			if hive.filled==16 then
				break
			end
		end
	end

	--check if we have enough pollen to spawn a new bee
	if hive.filled==16 then
		printh("hive deposite")
		hbee_spawn()
		--Also, give the player a health point if needed
		if bee.health < max_health then
			bee.health+=1
		end
		--add honey count
		honey_collected+=(16/4)
		--empty the hive of pollen
		hive.filled=0
		for i=1,#hive.honey_comb do
			hive.honey_comb[i].full=false
		end
	end
end
-->8
--enemy flyies--

flies={}

fly = {
	x=0,
	y=0,
	sprite=32,
	health=3,
	speed=1,
	dir=1,
	h=8,
	w=8,
	attack_delay=100,
	window=11,

	-- fly methods
	update = function(self, obj)
		-- move in current direction
		self.x += self.speed * self.dir

		-- calculate window boundaries
		local col = (self.window - 1) % 8
		local row = flr((self.window - 1) / 8)
		local left_bound = col * 128
		local right_bound = left_bound + 127

		-- check window boundaries and reverse direction
		if self.x > right_bound - self.w then
			self.x = right_bound - self.w
			self.dir = -1
		elseif self.x < left_bound then
			self.x = left_bound
			self.dir = 1
		end

		-- check for collision with player
		self.attack_delay-=1
		if self.attack_delay > 0 then
			return
		end

		if self.check_collision(self, obj) then
			-- reverse direction on collision
			self.dir = -self.dir

			-- take away a health point
			obj.health-=1
			self.attack_delay=100
			sfx(61)

			-- move away a bit to prevent getting stuck
			self.x += self.speed * self.dir * 2
		end

		-- Check for collision with helper bees
		for h=1, #hbees do
			local hbee = hbees[h]

			-- Skip dead helper bees
			if hbee.dead then
				goto continue_hbee
			end

			if self.check_collision(self, hbee) and self.attack_delay <= 0 then
				-- Hurt the helper bee
				hbee.health -= 1

				-- Play hit sound
				sfx(61)

				-- Set attack delay
				self.attack_delay = 80

				-- Check if helper bee died
				if hbee.health <= 0 then
					hbee.dead = true
					--remove pollen from player bee
					max_pollen-=1
					if bee.pollen > max_pollen then
						bee.pollen-=1
					end
				--printh("fly killed a bee!")
				end

				-- Reverse direction
				self.dir = -self.dir

				-- Move away a bit
				self.x += self.speed * self.dir * 3
			end
		end

		::continue_hbee::
	end,

	draw = function(self)
		spr(self.sprite, self.x, self.y, 1, 1, self.dir<0)
		rectfill(self.x, self.y-4, self.x+self.health*2, self.y-4, 8)
	end,

	-- collision check method
	check_collision = function(self, other)
	return self.x < other.x + other.w and
			self.x + self.w > other.x and
			self.y < other.y + other.h and
			self.y + self.h > other.y
	end,

	animate = function(self)
		if self.sprite==32 then
			self.sprite=33
		else
			self.sprite=32
		end
	end
}

--------------------------------
function flies_init()
	  -- Reset the flies table first
	flies = {}
	-- spawn 2 groups of flies
	flies_spawn()
	flies_spawn()
end

--------------------------------
function flies_spawn()
	local window = ceil(rnd(16))

	--don't put flies in the hive or above the hive!
	if window==1 or window==9 then
		return
	end

	cx, cy = window_center(window)
	cy-=64
	for i=1,3 do
		-- create a new table that inherits from fly
		local new_fly = {}
		for k,v in pairs(fly) do
			new_fly[k] = v
		end

		-- put flies in their own window
		new_fly.x = cx+(30 * i)
		new_fly.y = cy+(20 + 25 * i)
		new_fly.window=window
		-- add to flies array
		add(flies, new_fly)
	end
end

--------------------------------
function flies_update(obj)
	for i=#flies, 1, -1 do
		if flies[i].health <= 0 then
			-- Remove dead flies
			del(flies, flies[i])
			--printh("fly died. remaining:"..#flies)
		else
			flies[i]:update(obj)
			flies[i]:animate()
		end
	end

	-- spawn more flies if there are less than 3
	if #flies<3 then
		flies_spawn()
	end
end

--------------------------------
function draw_flies()
	for i=1,#flies do
		flies[i]:draw()
	end
end

-->8
-- pollen collection system using down direction with regeneration

-- global variables for tracking pollen
pollen_avail = 0
pollen_cooldown = 0  -- prevent multiple collections in one frame
pollen_flowers = {}  -- table to store all flowers and their states

--------------------------------
-- initialize the pollen collection system
function init_pollen_system()
	bee.pollen = 0
	pollen_cooldown = 0
	pollen_flowers = {}

	-- count all flowers with pollen on the map
	pollen_avail = 0
	for mx=0,127 do
		for my=0,63 do
			local tile = mget(mx, my)
			if fget(tile, flg.flower) then
				pollen_avail += 1
				-- store flower information in our table
				add(pollen_flowers, {
					x=mx,
					y=my,
					sp=tile,
					has_pollen=true,
					regen_timer=0,
					-- 30 seconds * 60 fps = 1800 frames
					regen_delay=(30*60)
				})
			end
		end
	end
	--printh("pollen flwrs:"..#pollen_flowers)
end

--------------------------------
-- check if bee is on top of a flower with pollen
function check_pollen_collection(entity)
	-- if on cooldown, decrement and return
	if pollen_cooldown > 0 then
		pollen_cooldown -= 1
		return
	end

	-- use collide_map to check if bee is colliding with flag 2 tiles in the down direction
	if collide_map(entity, "down", flg.flower) then
		-- get the tile position below the bee's feet
		local tx1 = flr((entity.x + 2) / 8)  -- left foot
		local tx2 = flr((entity.x + entity.w - 3) / 8)  -- right foot
		local ty = flr((entity.y + entity.h) / 8)  -- bottom of bee

		-- check both potential tiles (the bee might be standing across two tiles)
		local tiles_to_check = {{tx1, ty}, {tx2, ty}}

		for i=1,#tiles_to_check do
			local tx, ty = tiles_to_check[i][1], tiles_to_check[i][2]
			local tile = mget(tx, ty)

			-- check if this is actually a flower tile with pollen
			if fget(tile, flg.flower) and bee.pollen<max_pollen then
				-- change to collected flower sprite (2x2 grid of sprites)
				if tile==69 then
					mset(tx,ty,101)
					mset(tx+1,ty,102)
					mset(tx,ty+1,117)
					mset(tx+1,ty+1,118)
				end
				if tile==140 then
					mset(tx,ty,142)
				end
				if tile==138 then
					mset(tx,ty,139)
				end
				if tile==161 then
					mset(tx,ty,132)
				end

				-- update pollen counter
				bee.pollen += 1
				--printh("pollen:"..bee.pollen)

				-- find this flower in our table and update its state
				for f=1,#pollen_flowers do
					if pollen_flowers[f].x==tx and pollen_flowers[f].y==ty then
						pollen_flowers[f].has_pollen = false
						pollen_flowers[f].regen_timer = pollen_flowers[f].regen_delay
						break
					end
				end

				-- play collection sound
				sfx(60)

				-- set cooldown to prevent multiple collections
				pollen_cooldown = 10

				-- only collect one flower per check
				return
			end
		end
	end
end

--------------------------------
-- update regeneration timers for all flowers
function update_pollen_regeneration()
	for i=1,#pollen_flowers do
		local flower = pollen_flowers[i]

		-- if this flower needs regeneration
		if not flower.has_pollen and flower.regen_timer > 0 then
			flower.regen_timer -= 1

			-- time to regenerate
			if flower.regen_timer <= 0 then
				-- restore pollen to this flower
				flower.has_pollen = true

				-- change back to full flower sprites (2x2 grid)
				mset(flower.x,flower.y,flower.sp)
				if flower.sp==69 then
					mset(flower.x, flower.y, 69)
					mset(flower.x+1, flower.y, 70)
					mset(flower.x, flower.y+1, 85)
					mset(flower.x+1, flower.y+1, 86)
				end
			end
		end
	end
end

--------------------------------
function reset_all_flower_pollen()
	for i=1,#pollen_flowers do
		local flower = pollen_flowers[i]
		-- restore pollen to this flower
		flower.has_pollen = true
		flower.regen_timer=0
		-- change back to full flower sprite
		mset(flower.x,flower.y,flower.sp)
		if flower.sp==69 then
			mset(flower.x, flower.y, 69)
			mset(flower.x+1, flower.y, 70)
			mset(flower.x, flower.y+1, 85)
			mset(flower.x+1, flower.y+1, 86)
		end
	end
end

--------------------------------
-- debug function to visualize flower states
function draw_flower_debug()
	for i=1,#pollen_flowers do
		local f = pollen_flowers[i]
		local world_x = f.x * 8
		local world_y = f.y * 8

		-- color based on state
		local color = f.has_pollen and 11 or 8  -- green if has pollen, red if depleted

		-- draw rectangle around flower
		rect(world_x, world_y, world_x+15, world_y+15, color)

		-- show regeneration timer if applicable
		if not f.has_pollen then
			local seconds = flr(f.regen_timer / 60)
			print(seconds, world_x+4, world_y-6, 7)
		end
	end
end

-->8
--toast code

toast={
	txt1="",
	txt2="",
	txt3="",
	txt4="",
	showtime=0,
	st_time=0,
	enabled=false,
	persist=false,
	w=72,
	h=31
}

--------------------------------
function show_toast(txt1,txt2,txt3,txt4,stime)
	toast.txt1=txt1
	toast.txt2=txt2
	toast.txt3=txt3
	toast.txt4=txt4
	toast.showtime=stime
	toast.st_time=time()
	toast.enabled=true
	printh("toast start:"..txt1..","..txt2..","..txt3..","..txt4)
end

--------------------------------
function draw_toast()
	if toast.enabled==false then
		return
	end

	local elapsed=time()-toast.st_time

	if toast.showtime>=elapsed or toast.showtime==0 then
		local tx1=cam_x+32
		local ty1=cam_y+32
		local tx2=tx1+toast.w
		local ty2=ty1+toast.h

		rectfill(tx1-1,ty1-1,tx2+1,ty2+1,0)
		rect(tx1,ty1,tx2,ty2,11)

		local offset_x=toast_get_offset(toast.txt1)
		print(toast.txt1,tx1+offset_x,ty1+3,7)

		offset_x=toast_get_offset(toast.txt2)
		print(toast.txt2,tx1+offset_x,ty1+10,7)

		offset_x=toast_get_offset(toast.txt3)
		print(toast.txt3,tx1+offset_x,ty1+17,7)

		offset_x=toast_get_offset(toast.txt4)
		print(toast.txt4,tx1+offset_x,ty1+24,7)
	else
		printh("toast timeout")
		toast.enabled=false
	end
end

--------------------------------
function toast_get_offset(text)
	local offset=(toast.w-(#text*3))/2
	offset-=5
	return offset
end

--------------------------------
function toast_cancel()
	toast.enabled=false
	printh("toast cancelled")
end

-->8
--music tracks

music_tracks=4

--track metadata
--tracks display in this order
track_listing = {
	{
		trackname="arpument",
		start=0,
		finish=10,
	},
	{
		trackname="melancholy",
		start=11,
		finish=14,
	},
	{
		trackname="mission",
		start=15,
		finish=20,
	},
	{
		trackname="hijinx",
		start=21,
		finish=30,
	}
}

--------------------------------
function play_music_track(track)
	if track <= music_tracks then
		music(track_listing[track].start)
	end
end
-->8
--flicker sprites

flick_flop=0
flicker_timer=0
flicker_sprites={}

--------------------------------
function init_flicker_sprites()
	--count number of japaese lamps
	for mx=0,127 do
		for my=0,63 do
			local tile = mget(mx, my)
			if tile==78 then	--j. lantern
				add(flicker_sprites, {
					x=mx*8,
					y=my*8,
					sp={tile,76,108,110},
					w=2,
					h=2
				})
			elseif tile==84 then --torch
				add(flicker_sprites, {
					x=mx*8,
					y=my*8,
					sp={tile,tile,tile,tile},
					w=1,
					h=1
				})
			end
		end
	end
end

--------------------------------
function draw_flicker_sprites()
	--update pallet for each flickering sprite

	-- update flicker animation at a controlled rate
	flicker_timer+=1
	if flicker_timer>5 then -- adjust this number to control flicker speed
		flicker_timer=flr(rnd(5))
		flick_flop=1-flick_flop -- toggle between 0 and 1
	end

	if flick_flop==0 then
		pal(9,10,0) --yellows to orange
	end

	for i=1,#flicker_sprites do
		local x=flicker_sprites[i].x
		local y=flicker_sprites[i].y
		local sp=flicker_sprites[i].sp[seasons.season+1]
		local w=flicker_sprites[i].w
		local h=flicker_sprites[i].h

		spr(sp,x,y,w,h,false,false)
	end
	reset_pal()
end

-->8
--helper bees

show_bee_death_hint=true

hbee={}

hbee = {
	x=0,
	y=0,
	dx=0,
	dy=0,
	max_dx=1.2,
	max_dy=2.5,
	sprite=11,
	health=3,
	max_health=3,
	dir=1,
	h=8,
	w=8,
	window=9,
	id=0,  -- Unique identifier for each bee, used for formation positioning
	flight_timer=0,
	following=false,
	attacking=false,
	attack_cooldown=0,
	max_attack_cooldown=20,
	dead=false,
	healing=false,
	heal_timer=0,
	stuck_timer=0,

	------------------------
	-- Helper bee methods
	update = function(self, player)
		-- Check for death if health is depleted
		if self.health <= 0 and not self.dead then
			self.dead = true
			-- Play death sound
			sfx(62)
		end

		-- If helper bee is dead, make it fall and don't follow player
		if self.dead then
			-- Just apply gravity and friction, no other movement
			self.dx *= friction
			self.dy += gravity

			-- Move the helper bee
			self.x += self.dx
			self.y += self.dy

			-- Map boundaries
			if self.x < map_start_x then
				self.x = map_start_x
			end
			if self.x > map_end_x - self.w then
				self.x = map_end_x - self.w
			end
			if self.y < map_start_y then
				self.y = map_start_y
				self.dy = 0
			end
			if self.y > map_end_y - self.h then
				self.y = map_end_y - self.h
				-- If the bee is dead and reaches the bottom of the map, mark for removal
				self.remove_me = true
			end

			-- Skip the rest of the update logic if dead
			return
		end

		-- Check if we're near the hive to recharge health
		self:check_hive_healing()

		-- Decrement attack cooldown
		if self.attack_cooldown > 0 then
			self.attack_cooldown -= 1
		end

		-- Check for nearby flies in detection range
		local target_fly = nil
		local closest_dist = 9999

		for i=1, #flies do
			local f = flies[i]

			-- Skip check if fly has no health
			if f.health <= 0 then
				goto continue_fly
			end

			-- Check if fly is within detection range (128x128 window)
			local dist_x = abs(self.x - f.x)
			local dist_y = abs(self.y - f.y)
			local total_dist = dist_x + dist_y

			-- If within range and closer than current target
			if dist_x < 64 and dist_y < 64 and total_dist < closest_dist then
				target_fly = f
				closest_dist = total_dist
			end

			::continue_fly::
		end

		-- If we found a fly to attack
		if target_fly != nil then
			-- Calculate distance to fly
			local dist_x = abs(self.x - target_fly.x)
			local dist_y = abs(self.y - target_fly.y)

			-- If close enough to attack
			if dist_x < 8 and dist_y < 8 and self.attack_cooldown <= 0 then
				-- Attack the fly
				self:attack(target_fly)
			else
				-- Move toward fly instead of player
				if self.x < target_fly.x then
					self.dir = 1
					self.dx += 0.4  -- Faster when attacking
				else
					self.dir = -1
					self.dx -= 0.4
				end

				-- Vertical movement toward fly
				if self.y < target_fly.y then
					self.dy += 0.4
				else
					self.dy -= 0.4
				end

				-- We're targeting a fly, so don't follow player
				self.following = false
			end
		else
			-- Check if player is within detection range (128x128 window)
			local following_range = 128
			local dist_x = abs(self.x - player.x)
			local dist_y = abs(self.y - player.y)
			self.following = (dist_x < following_range and dist_y < following_range)

			-- Update flight timer
			self.flight_timer -= 1

			if self.following then
				-- FOLLOWING BEHAVIOR
				-- Calculate base target position (slightly offset from player)
				local target_x = player.x + (self.id % 3 - 1) * 12  -- Offset horizontally based on bee ID
				local target_y = player.y + 16 + (flr(self.id / 3) * 12)  -- Stay below player, offset by row

				-- Add small random movement for more natural look
				target_x += sin(time()/2 + self.id) * 4
				target_y += cos(time()/3 + self.id) * 3

				-- Move toward calculated position
				if target_x < self.x - 2 then
					self.dir = -1
					self.dx -= 0.3
				elseif target_x > self.x + 2 then
					self.dir = 1
					self.dx += 0.3
				end

				-- Vertical movement
				if target_y < self.y - 2 then
					self.dy -= 0.4
				elseif target_y > self.y + 2 then
					self.dy += 0.3
				end

				-- Avoid collisions with other helper bees
				self:avoid_other_bees()
			else
				-- ROAMING BEHAVIOR
				-- Random movement behavior
				if rnd(40) < 1 then
					self.dir = -self.dir
				end

				-- Apply movement based on direction
				self.dx += 0.2 * self.dir

				-- Flight behavior
				if self.flight_timer <= 0 or self.y > map_end_y - 50 then
					self.dy -= rnd(2.0) + 1.0
					self.flight_timer = flr(rnd(20)) + 10
				end
			end
		end

		-- Apply reduced gravity
		self.dy += gravity * 0.5
		self.dx *= friction

		-- Limit speed
		self.dx = limit_speed(self.dx, self.max_dx)
		self.dy = limit_speed(self.dy, self.max_dy)

		-- Collision checks (down)
		if self.dy > 0 then
			if collide_map(self, "down", flg.wall) then
				self.dy = -1.5  -- Immediate upward bounce when hitting ground
				self.y -= ((self.y + self.h + 1) % 8) - 1
			end
		elseif self.dy < 0 then
			if collide_map(self, "up", flg.wall) then
				self.dy = 0.5  -- Slight downward movement when hitting ceiling
			end
		end

		-- Collision checks (left/right)
		if self.dx < 0 then
			if collide_map(self, "left", flg.wall) then
				self.dx = 0.5  -- Bounce off walls
				self.dir = 1
				-- Add upward movement to try to navigate over obstacles
				self.dy = -1.8
				-- Move slightly away from the wall
				self.x += 2
			end
		elseif self.dx > 0 then
			if collide_map(self, "right", flg.wall) then
				self.dx = -0.5  -- Bounce off walls
				self.dir = -1
				-- Add upward movement to try to navigate over obstacles
				self.dy = -1.8
				-- Move slightly away from the wall
				self.x -= 2
			end
		end

		-- Check if the bee might be stuck (very little movement)
		if abs(self.dx) < 0.1 and abs(self.dy) < 0.1 then
			self.stuck_timer += 1

			-- If stuck for several frames, give a strong upward boost
			if self.stuck_timer > 20 then
				self.dy = -2.5
				self.stuck_timer = 0

				-- Random horizontal nudge
				if rnd(1) < 0.5 then
					self.dx = 1
					self.dir = 1
				else
					self.dx = -1
					self.dir = -1
				end
			end
		else
			-- Reset stuck timer if moving normally
			self.stuck_timer = 0
		end

		-- Move the helper bee
		self.x += self.dx
		self.y += self.dy

		-- Map boundaries
		if self.x < map_start_x then
			self.x = map_start_x
			self.dir = 1
		end
		if self.x > map_end_x - self.w then
			self.x = map_end_x - self.w
			self.dir = -1
		end
		if self.y < map_start_y then
			self.y = map_start_y
		self.dy = 0.5
		end
		if self.y > map_end_y - self.h then
			self.y = map_end_y - self.h
			self.dy = -2  -- Strong upward boost if touching bottom
		end
	end,

	------------------------
	-- Add healing method for helper bees
	check_hive_healing = function(self)
		-- Don't bother checking if already at max health
		if self.health >= self.max_health then
			self.healing = false
			return
		end

		-- Check if bee is in window 9 (hive window)
		local hive_col = (9 - 1) % 8
		local hive_row = flr((9 - 1) / 8)
		local hive_left = hive_col * 128
		local hive_top = hive_row * 128

		-- Check if bee is within hive window
		local in_hive_window = (
			self.x >= hive_left and
			self.x < hive_left + 128 and
			self.y >= hive_top and
			self.y < hive_top + 128
		)

		-- Alternative: precise collision check with honeycombs
		local touching_honeycomb = false

		-- Check all tiles around the bee's position
		for dx=-1,1 do
			for dy=-1,1 do
				local tx = flr((self.x + 4 + dx*4) / 8)
				local ty = flr((self.y + 4 + dy*4) / 8)
				local tile = mget(tx, ty)

				-- Check if this tile has the hive flag (bit 2) set
				if fget(tile, flg.hive) then
					touching_honeycomb = true
					break
				end
			end

			if touching_honeycomb then
				break
			end
		end

		-- If near hive or touching honeycomb, heal
		if in_hive_window or touching_honeycomb then
			self.healing = true

			-- Slow healing rate - increase heal timer
			self.heal_timer += 1

			-- Heal every 60 frames (about 1 second)
			if self.heal_timer >= 60 then
				self.health += 1
				self.heal_timer = 0

				-- Play healing sound
				sfx(59)
			end
		else
			-- Reset healing if moved away
			self.healing = false
			self.heal_timer = 0
		end
	end,

	------------------------
	-- Add an avoidance method to prevent stacking
	avoid_other_bees = function(self)
		for i=1, #hbees do
			local other = hbees[i]

			-- Skip self or dead bees
			if other == self or other.dead then
				goto continue_avoid
			end

			-- Calculate distance to other bee
			local dist_x = abs(self.x - other.x)
			local dist_y = abs(self.y - other.y)

			-- If too close (less than 10 pixels), move away
			if dist_x < 10 and dist_y < 10 then
				-- Apply repulsion force (stronger the closer they are)
				local force = 0.2 * (1 - (dist_x + dist_y) / 20)

				-- Horizontal avoidance
				if self.x < other.x then
					self.dx -= force
				else
					self.dx += force
				end

				-- Vertical avoidance
				if self.y < other.y then
					self.dy -= force
				else
					self.dy += force
				end
			end

			::continue_avoid::
		end
	end,

	------------------------
	-- Add attack method to helper bees
	attack = function(self, fly)
		-- Only attack if not on cooldown
		if self.attack_cooldown <= 0 and not self.dead then
			-- Set attacking flag for animation
			self.attacking = true

			-- Deal damage to fly
			fly.health -= 1

			-- Play attack sound
			sfx(60)

			-- Set cooldown
			self.attack_cooldown = self.max_attack_cooldown

			-- Push back from fly slightly
			if self.x < fly.x then
				self.dx = -1.5
			else
				self.dx = 1.5
			end

			if self.y < fly.y then
				self.dy = -1.5
			else
				self.dy = 1.5
			end
		end
	end,

	------------------------
	draw = function(self)
		-- Draw dead helper bee
		if self.dead then
			spr(59, self.x, self.y, 1, 1, self.dir < 0)
			return
		end

		-- Draw attack animation or regular animation
		if self.attacking then
			-- Use attack sprite (use sprite 43 for attack pose or another appropriate sprite)
			spr(43, self.x, self.y, 1, 1, self.dir < 0)

			-- Reset attacking flag after a few frames
			if self.attack_cooldown > self.max_attack_cooldown - 5 then
				self.attacking = false
			end
		elseif self.healing then
			-- Use healing sprite (alternating colors to show healing effect)
			local t = time() * 10
			if flr(t) % 2 == 0 then
				-- Flash with a different color palette when healing
				pal(7, 11) -- white to blue
				pal(10, 14) -- yellow to pink
			end

			spr(self.sprite, self.x, self.y, 1, 1, self.dir < 0)
			reset_pal() -- Reset palette after drawing
		else
			-- Regular animation
			spr(self.sprite, self.x, self.y, 1, 1, self.dir < 0)
		end

		-- Draw indicator dots based on state
		if self.following then
			-- Blue dot for following player
			pset(self.x + 4, self.y - 2, 12)
		end

		-- Health indicator - show dots based on health (up to 3)
		for i=1, self.health do
			local color = 11 -- green for full health
			if self.health < self.max_health then
				color = 8 -- Red for damaged
			end
			pset(self.x + i*2, self.y - 2, color)
		end
	end,

	------------------------
	animate = function(self)
		if self.sprite == 11 then
			self.sprite = 27
		else
			self.sprite = 11
		end
	end
}

--------------------------------
function hbee_init()
	hbees = {}  -- Initialize array
end

--------------------------------
function hbee_spawn()
	local cx, cy = window_center(9)
	cy -= 64

	if #hbees >= max_hbees then
		return
	end

	-- Create a new table that inherits from hbee
	local new_hbee = {}
	for k,v in pairs(hbee) do
		new_hbee[k] = v
	end

	-- Assign a unique ID to this bee (used for formation spacing)
	new_hbee.id = #hbees + 1

	-- Put hbee in spawn point
	new_hbee.x = cx
	new_hbee.y = cy

	-- Add to hbees array
	add(hbees, new_hbee)

	--add extra pollen holding capability
	max_pollen+=1

	--printh("New bee spawned! Num bees:" .. #hbees)
end

--------------------------------
function hbee_update(player)
	-- Loop through the helper bees backwards to safely remove
	for i=#hbees, 1, -1 do
		if not hbees[i].dead then
			-- If return_to_player is active, override other behavior
			if hbees[i].return_to_player then
				-- Calculate direction vector to player
				local dir_x = player.x + player.w/2 - (hbees[i].x + hbees[i].w/2)
				local dir_y = player.y + player.h/2 - (hbees[i].y + hbees[i].h/2)

				-- Normalize and scale for faster return speed
				local length = sqrt(dir_x*dir_x + dir_y*dir_y)

				-- If the bee is very close to the player, stop return behavior
				if length < 20 then
					hbees[i].following = true
					hbees[i].return_to_player = false
				else
					-- Move towards player at increased speed
					local speed_mult = 1.5
					hbees[i].dx = (dir_x / length) * hbees[i].max_dx * speed_mult
					hbees[i].dy = (dir_y / length) * hbees[i].max_dy * speed_mult

					-- Update direction for sprite flipping
					if dir_x < 0 then
						hbees[i].dir = -1
					else
						hbees[i].dir = 1
					end
				end
			end
		end

		-- Update and animate the helper bee
		hbees[i]:update(player)
		hbees[i]:animate()

		-- Check if this helper bee is marked for removal
		if hbees[i].remove_me then
			-- Remove the helper bee from the array
			del(hbees, hbees[i])

			sfx(62)
			--printh("Helper bee died!")
			if show_bee_death_hint==true then
				show_toast("a bee died!","heal them","at the","hive!",5)
				show_bee_death_hint=false
			end

			--printh("helper bee removed, remaining: " .. #hbees)
		end
	end
end

--------------------------------
function draw_hbees()
	for i=1, #hbees do
		hbees[i]:draw()
		-- Add return indicator if bee is returning to player
		if hbees[i].return_to_player and not hbees[i].dead then
			-- Draw a small blinking indicator above the bee
			local blink = flr(time() * 10) % 2 == 0
			if blink then
				circfill(hbees[i].x + 4, hbees[i].y - 3, 1, sonar.color)
			end
		end
	end
end
-->8
--instructions

--------------------------------
function draw_info_screen()
	local y=0
	cls()
	camera(0,0)

	print("goal:",1,y,9)
	print("collect pollen to make",(3*8),y,12)	y+=8
	print("      honey and survive winter!",1,y)

	y+=8
	print("CONTROLS:",1,y,9)	y+=8
	print("⬅️➡️:move  ❘:fly  🅾️:call bees",1,y,12)

	y+=8
	print("COLLECTING:",1,y,9)	y+=8
	print("* land on flowers for pollen",1,y,12)	y+=8
	print("* return to hive to deposit",1,y)	y+=8
	print("* 16 pollen = 1 helper bee",1,y)		y+=8
	print("* 4 pollen = 1 honey unit",1,y)		y+=8
	print("* need "..honey_goal.." honey by winter's end!",1,y)

	y+=8
	print("TIPS:",1,y,9)	y+=8
	print("* helper bees fight enemies",1,y,12)	y+=8
	print("* press 🅾️ to keep bees from",1,y)	y+=8
	print("  fighting to save them!",1, y)		y+=8
	print("* bring helper bees to hive",1,y)	y+=8
	print("* to heal them!",1,y)
end
-->8
--snow flake effect

snowflakes = {}	--all snowflakes

-----------------------------------------
function add_snowflake(start_x,start_y,color)
	snowflake = {
		x = start_x,
		y = start_y,
		dx = 0,
		dy = rnd(2),
		c = color,
	}

	add(snowflakes, snowflake)
end

----------------------
function init_snowflakes()
	--clear any exiting snowflake table
	snowflakes = {}
	--add some snowflakes
	for i=1,(25*8) do
		local new_x=rnd(map_end_x)
		local new_y=0
		local new_c=7 --flr(rnd(14)+1)
		add_snowflake(new_x,new_y,new_c)
	end
end

------------------------
function update_snowflakes()
	--update position of snowflakes
	for i=1,#snowflakes do
		snowflakes[i].y+=snowflakes[i].dy
		snowflake_bounds_check(snowflakes[i])
	end
end

----------------------
function draw_snowflakes()
	--draw snowflakes
	for i=1,#snowflakes do
		pset(snowflakes[i].x, snowflakes[i].y, snowflakes[i].c)
	end
end

------------------------------
function snowflake_bounds_check(s)
	if s.y > map_end_y then
		s.y=0
		--calc a new randome x position
		s.x=rnd(map_end_x)
	end
end

-->8
--title screen

logo_txt="beeventure!"
logo_px=nil
tt=0
tclouds={{10,44},{78,68}}
tflowers={-2,26,60,94,112}
season_flr={78,76,108,110}

--------------------------------
function title_init()
	tt=0

	--the logo is just the normal font blown
	--up 2x: print it once, read the pixels
	--back, and remember them so we can stamp
	--each one as a fat 2x2 block later.
	if not logo_px then
		logo_px={}
		camera(0,0)
		cls()
		print(logo_txt,0,0,7)
		for y=0,5 do
			for x=0,#logo_txt*4-1 do
				if pget(x,y)==7 then
					add(logo_px,{x,y,flr(x/4)})
				end
			end
		end
		cls()
	end
end

--------------------------------
function title_update()
	tt+=1

	--drift through the seasons to show them off
	if tt%210==0 then
		seasons.season=(seasons.season+1)%4
		change_season(seasons.season)
	end
	if seasons.season==seasons.wint then
		update_snowflakes()
	end

	for c in all(tclouds) do
		c[1]+=0.1
		if c[1]>140 then
			c[1]=-30
		end
	end
end

--------------------------------
--where a bee sits on the figure eight at
--time a. returns the top left of an 8x8
--sprite, plus which way it is facing.
function bee_path(a)
	return 60+sin(a)*46,60+sin(a*2)*15,cos(a)>0
end

--------------------------------
function draw_cloud(x,y)
	circfill(x+8,y+2,7,6)
	circfill(x,y,5,7)
	circfill(x+8,y-3,7,7)
	circfill(x+16,y,5,7)
	rectfill(x,y,x+16,y+5,7)
end

--------------------------------
function draw_logo()
	for p in all(logo_px) do
		--each letter nods on its own wave
		local x=20+p[1]*2
		local y=14+p[2]*2+flr(sin(tt/150-p[3]/22)*2.5)
		rectfill(x+2,y+2,x+3,y+3,0)
		rectfill(x,y,x+1,y+1,10-(p[2]\4))
	end
end

--------------------------------
function draw_splash_screen()
	camera(0,0)
	cls(current_pal)

	circfill(118,9,8,10)

	for c in all(tclouds) do
		draw_cloud(c[1],c[2])
	end

	--snow, but only in winter
	if seasons.season==seasons.wint then
		for f in all(snowflakes) do
			pset(f.x%128,f.y%117,7)
		end
	end

	--ground
	rectfill(0,117,127,127,11)
	rectfill(0,126,127,127,3)

	--a row of flowers, alternating the
	--seasonal one with a pollen flower
	for i=1,5 do
		spr(i%2==0 and season_flr[seasons.season+1] or 69,tflowers[i],104,2,2)
	end

	--the helper bees, strung out behind...
	for i=1,4 do
		local x,y,f=bee_path((tt-16-i*12)/300)
		spr(11+16*((tt\5+i)%2),x,y,1,1,f)
	end

	--...and the player's bee leading them
	local x,y,f=bee_path(tt/300)
	spr(1+2*(tt\4%3),x-4,y-4,2,2,f)

	draw_logo()
	print("a bee adventure",34,30,7)

	--prompts alternate so they fit on one line
	if (tt\90)%2==0 then
		print("press ❘ to start",30,96,7)
	else
		print("press 🅾️ for help",30,96,7)
	end

	print("by charlie w.",38,121,3)
end