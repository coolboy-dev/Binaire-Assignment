function _init()
	reset_game()
end


function _update()
	if is_playing then
		movement()
		enemy()
		health()
		move_stars()
		
		if not stat(57) then
			music(1)
		end
	end

	if not is_playing then
		music(2)
		
		if btn(❘) then
			reset_game()
		end
	end
end


function _draw()
	if is_playing then
		cls()

		-- player
		draw_player()

		-- enemies
		for e in all(enemies) do
			spr(e.spr, e.x, e.y)
		end

		-- hearts
		spr(heart_one.spr, heart_one.x, heart_one.y)
		spr(heart_two.spr, heart_two.x, heart_two.y)
		spr(heart_three.spr, heart_three.x, heart_three.y)
	
		-- score
		print("round: " .. counting, 0, 8, 12)
		
		-- draw stars
	for s in all(stars) do
		pset(s.x,s.y,s.c)
	end

	else
		cls()

		local title = "game over"
		local score = "score: " .. counting
		local prompt = "press ❘ to continue"

		print(title, 64 - #title * 2, 55, 8)
		print(score, 64 - #score * 2, 63, 8)
		print(prompt, 64 - #prompt * 2, 71, 8)
	end
end


-- draw the player rotated toward its movement
function draw_player()
	local cx = guy.x + 3.5
	local cy = guy.y + 3.5

	-- sprite is 8x8
	for sy = 0, 7 do
		for sx = 0, 7 do

			local col = sget(
				guy.spr % 16 * 8 + sx,
				flr(guy.spr / 16) * 8 + sy
			)

			-- don't draw transparent pixels
			if col != 0 then

				-- pixel position relative to center
				local x = sx - 3.5
				local y = sy - 3.5

				-- rotate pixel
				local c = cos(guy.angle)
				local s = sin(guy.angle)

				local rx = x * c - y * s
				local ry = x * s + y * c

				-- draw rotated pixel
				pset(
					flr(cx + rx + 0.5),
					flr(cy + ry + 0.5),
					col
				)
			end
		end
	end
end


function movement()
	local dx = 0
	local dy = 0

	if btn(0) then dx -= 1 end
	if btn(1) then dx += 1 end
	if btn(2) then dy -= 1 end
	if btn(3) then dy += 1 end

	local is_diagonal = (dx != 0 and dy != 0)

	if is_diagonal then
		dx *= 1 / sqrt(2)
		dy *= 1 / sqrt(2)

		if not was_diagonal then
			guy.x = flr(guy.x + 0.5)
			guy.y = flr(guy.y + 0.5)
		end
	end

	-- move player
	guy.x += dx * speed
	guy.y += dy * speed


	-- rotate toward movement direction
	if dx != 0 or dy != 0 then
		local target_angle = atan2(dy, dx)

		-- make the sprite's "up" direction point forward
		target_angle -= 0.25

		-- find shortest rotation direction
		local difference = target_angle - guy.angle

		if difference > 0.5 then
			difference -= 1
		elseif difference < -0.5 then
			difference += 1
		end

		-- smooth rotation
		guy.angle += difference * 0.2

		-- keep angle between 0 and 1
		if guy.angle < 0 then
			guy.angle += 1
		elseif guy.angle >= 1 then
			guy.angle -= 1
		end
	end


	-- screen wrapping
	if guy.x < -8 then
		guy.x = 127
	elseif guy.x > 127 then
		guy.x = -8
	end

	if guy.y < -8 then
		guy.y = 127
	elseif guy.y > 127 then
		guy.y = -8
	end

	was_diagonal = is_diagonal
end


function spawn_enemy(x, y)
	local e = {
		x = x,
		y = y,
		vx = 0,
		vy = 0,
		accel = 0.05,
		spr = 2,
		max_spd = enemy_speed
	}

	add(enemies, e)
end


function enemy_logic(x, y)
	for e in all(enemies) do
		local dx = x - e.x
		local dy = y - e.y

		local dist = sqrt(dx * dx + dy * dy)

		if dist > 0 then
			dx /= dist
			dy /= dist

			e.vx += dx * e.accel
			e.vy += dy * e.accel
		end

		-- limit enemy speed
		local spd = sqrt(e.vx * e.vx + e.vy * e.vy)

		if spd > e.max_spd then
			e.vx = e.vx / spd * e.max_spd
			e.vy = e.vy / spd * e.max_spd
		end

		-- move enemy
		e.x += e.vx
		e.y += e.vy
	end
end


function enemy()
	delay += 1

	if delay == 15 then
		local sx = rnd(127)
		local sy = rnd(60)

		spawn_enemy(sx, sy)

		delay = 0
	end

	enemy_logic(guy.x, guy.y)

	-- wave complete
	if count(enemies) == enemy_limit then
		enemies = {}
		counting += 1
	end

	-- increase difficulty
	if counting >= next_difficulty then
		enemy_speed *= 1.5
		enemy_limit += 2

		counting_counting += 1

		if counting_counting == 2 then
			if counting_distance > 1 then
				counting_distance -= 2
			end

			counting_counting = 0
		end

		next_difficulty += counting_distance
	end
end


function health()
	for e in all(enemies) do
		if collision(guy, e) then
			hit_count += 1
			del(enemies, e)
			sfx(0)
		end
	
		if hit_count == 0 then
			heart_one.spr = 3
			heart_two.spr = 3
			heart_three.spr = 3
		elseif hit_count == 1 then
			heart_three.spr = 4
		elseif hit_count == 2 then
			heart_two.spr = 4
		else
			heart_one.spr = 4
			is_playing = false
		end
	end
end


function collision(p, e)
	return p.x < e.x + 8
	   and p.x + 8 > e.x
	   and p.y < e.y + 8
	   and p.y + 8 > e.y
end

function move_stars()
	-- move stars
	for s in all(stars) do
	 -- move star, based on z-order depth
	 s.y+=s.z*warp_factor/10
	 -- wrap star around the screen
	 if s.y>128 then
	  s.y=0
	  s.x=rnd(128)
	 end
	end
end

function reset_game()
	is_playing = true

	guy = {
		spr = 1,
		x = 64,
		y = 64,

		-- rotation angle
		angle = 0
	}

	heart_one = {
		spr = 3,
		x = 0,
		y = 0
	}

	heart_two = {
		spr = 3,
		x = 6,
		y = 0
	}

	heart_three = {
		spr = 3,
		x = 12,
		y = 0
	}

	was_diagonal = false

	speed = 1.5
	enemy_speed = 1
	delay = 0

	enemies = {}
	enemy_limit = 11

	counting = 0
	counting_distance = 5
	counting_counting = 0
	next_difficulty = 5

	hit_count = 0
	
	stars={}
	star_cols={1,2,5,6,7,12}
	warp_factor=3
	
	-- create starfield
	for i=1,#star_cols do
 	for j=1,10 do
  	local s={
   	x=rnd(128),
	   y=rnd(128),
	   z=i,
	   c=star_cols[i]
  	}
  	add(stars,s)
 	end 
	end
end