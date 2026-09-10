--ame shoot 1.0.0
--by cheeseb0y

--this game is an independent, non-profit fan-made game created as a derivative work of hololive production.
--it is not endorsed, affiliated, or sponsored by cover corp.
--all rights, characters, and assets associated with hololive production are the property of cover corp.

-- main --

function _init()
	game_state = "title"
	music_playing = false
	player = spawn_player()
	bullets = {}
	grenades = {}
	enemies = {}
	cache_enemies = {}
	e_projects = {}
	cache_signals = {}
	pickups = spawn_pickups()
	candlesticks = spawn_candlesticks()
	stalactites = spawn_stalactites()
	messages = {}
	gun_parts = {}
	explosion_parts = {}
	e_parts = {}
	gravity = 0.5
	cam = {x = player.x - 63, y = player.y - 63}
	fog_map = {}
	shake = 0
	scene_state = "normal"
end

function _update()
	if game_state == "title" then
		handle_title()
		start_music(0)
	elseif game_state == "game" then
		stop_music()
		handle_player()
		handle_bullets()
		handle_grenades()
		handle_reload()
		handle_enemies()
		handle_enemy_projects()
		handle_pickups()
		handle_gun_parts()
		handle_explosion_parts()
		handle_e_parts()
		handle_messages()
		handle_camera()
		handle_visibility()
		handle_shake()
	elseif game_state == "died" then
		handle_player_death()
	elseif game_state == "end" then
		handle_game_over()
	end
end

function _draw()
	if game_state == "title" then
		draw_title()
	elseif game_state == "game" then
		cls(1)
		map(0, 0)
		draw_candlesticks()
		draw_stalactites()
		draw_tutorial_messages()
		draw_player()
		draw_bullets()
		draw_grenades()
		draw_enemies()
		draw_enemy_projects()
		draw_pickups()
		draw_gun_parts()
		draw_explosion_parts()
		draw_e_parts()
		draw_fog_mask()
		draw_messages()
		draw_health_bar()
		draw_score_count()
		draw_coin_count()
		draw_lives_remaining()
		draw_ammo_display()
		draw_reload()
		-- show_collision_box(player)
		-- show_player_debug()
	elseif game_state == "died" then
		cls()
		print("you died", cam.x + 48, cam.y + 56, 8)
		print(player.lives.." lives remaining", cam.x + 30, cam.y + 62, 7)
		print("press any button to continue", cam.x + 8, cam.y + 68, 7)
	elseif game_state == "end" then

	end
end

-->8
-- player --

function init_player(x, y)
    return {
        name = "player",
        x = x,
        y = y,
        dx = 0,
        dy = 0,
        invuln = 0,
        shoot_cd = 0,
		ammo = 8,
		max_ammo = 8,
		reload_frame = 0,
		reloading = false,
		last_shoot_time = 0,
        grenade_cd = 0,
        max_speed_x = 3,
        max_speed_y = 10,
		max_speed_ads = 1.5,
        health = 10,
        max_health = 10,
        lives = 3,
        score = 0,
        coins = 0,
        kills = 0,
        deaths = 0,
        time = 0,
		spawn_cd = 15,
        respawn = {x = x, y = y},
        col = {2, 0, 7, 7},
        flp = false,
        state = "normal",
		jframes = 0,
        is_airborne = false,
        grenades_unlocked = false,
        last_tx = -1,
        last_ty = -1,
        last_ls = "",
    }
end

function spawn_player()
	for tx = 0, 127 do
		for ty = 0, 63 do
			local tile = mget(tx, ty)
			if fget(tile, 6) then
				mset(tx, ty, 0)
				return init_player(tx * 8, ty * 8)
			end
		end
	end
	return init_player(64, 64)
end

function handle_player()
	local lx = player.x
	local ly = player.y
	
	if btn(⬅️) and btn(➡️) then
		player.dx = player.dx * 0.75
	elseif btn(⬅️) then
		if not player.flp then
			player.flp = true
			if player.state == "normal" or player.state == "crouch" then
				player.x -= 8
				lx -= 6
			end
		end
		if player.dx > 0 then
			player.dx -= 0.5
		else
			player.dx -= 0.25
		end
	elseif btn(➡️) then
		if player.flp then
			player.flp = false
			if player.state == "normal" or player.state == "crouch" then
				player.x += 8
				lx += 6
			end
		end
		if player.dx < 0 then
			player.dx += 0.5
		else
			player.dx += 0.25
		end
	else
		player.dx = player.dx * 0.75
	end

	update_player_collision()

	local max_dx = player.max_speed_x
	
	if player.state == "aim_up" and not player.is_airborne then max_dx = player.max_speed_ads end

	if player.dx > max_dx then
		player.dx = max_dx
	elseif player.dx < -max_dx then
		player.dx = -max_dx
	end
	
	player.x += player.dx
	
	if collide(player, 0) then
		if collide(player, 2) and not is_invuln() then
			take_damage(player, 1)
			start_invuln(5)
		end
		player.x = lx
		player.dx *= -0.2
	end

	if player.dy > player.max_speed_y then
		player.dy = player.max_speed_y
	elseif player.dy < -player.max_speed_y then
		player.dy = -player.max_speed_y
	end
	
	player.y += player.dy

	if player.dy >= 3 or (player.dy < 0 and player.jframes == 0) then
		player.is_airborne = true
	end

	if not collide(player, 0) then
		if player.dy > 0 then
			player.dy += gravity * 2
		else
			player.dy += gravity
		end
	else
		if collide(player, 2) and not is_invuln() then
			take_damage(player, 1)
			start_invuln(5)
		end
		if ly < player.y then player.is_airborne = false end
		player.y = ly
		player.dy = 0
	end
	
	if btn(⬆️) and player.state != "aim_up" then
		player.state = "aim_up"
		player.y-=8
		if player.flp then player.x += 8 end
	elseif not btn(⬆️) and player.state == "aim_up" then
		player.state = "normal"
		player.y+=8
		if player.flp then
			player.x -= 8 
		end
	end

	update_player_collision()
	
	if btn(⬇️) and player.state != "crouch" and player.state != "aim_up" then
		player.state = "crouch"
	elseif not btn(⬇️) and player.state == "crouch" then
		player.state = "normal"
	end
	
	if btnp(❘) then
		if player.state == "crouch" and player.grenade_cd <= 0 and player.greades_unlocked then
			drop_grenade()
			player.grenade_cd = 60
		elseif (player.state == "normal" or player.state == "aim_up") and player.shoot_cd <= 0 then
			shoot()
			player.shoot_cd = 4
		end
	end

	if player.grenade_cd > 0 then player.grenade_cd -= 1 end
	if player.shoot_cd > 0 then player.shoot_cd -= 1 end
	
	if player.spawn_cd <= 0 then
		if btn(🅾️) and not player.is_airborne and player.state != "aim_up" then
			if player.jframes == 0 then sfx(3) end
			player.jframes += 1
			if player.jframes < 6 then
				player.dy = -4
			else 
				player.is_airborne = true
			end
		else
			player.jframes = 0
		end
	else
		player.spawn_cd -= 1
	end
	
	if is_invuln() then
		player.invuln -= 1
		if player.invuln >= 15 then
			player.dx = 0
		end
	else
		for e in all(enemies) do
			if collide_obj(e, player) then
				take_damage(player, e.dict.dmg)
				start_invuln(20)
			end
		end
		for p in all(e_projects) do
			if collide_obj(p, player) then
				del(e_projects, p)
				take_damage(player, p.dmg)
				start_invuln(20)
			end
		end
	end

	player.time += 1
end

function clamp_score()
	if player.score < 0 then player.score = 0 end
end

function is_invuln()
	return player.invuln > 0
end

function start_invuln(frames)
	if not is_invuln() then
		player.invuln = frames
	end
end

function player_died()
	player.deaths += 1
	if player.lives <= 0 then
			player.dx -= 0.25
		game_over()
	else
		sfx(18)
		player.lives -= 1
		game_state = "died"
	end
end

function handle_player_death()
	if btnp(🅾️) or btnp(❘) then
		respawn_player()
		game_state = "game"
	end
end

function respawn_player()
	player.x = player.respawn.x
	player.y = player.respawn.y
	player.dx = 0
	player.dy = 0
	player.invuln = 0
	player.shoot_cd = 0
	player.grenade_cd = 0
	player.health = player.max_health
	player.col = {2, 0, 7, 7}
	player.flp = false
	player.state = "normal"
	player.is_airborne = false
	player.last_tx = -1
    player.last_ty = -1
	player.ammo = player.max_ammo
	player.reload_frame = 0
	player.reloading = false
	player.spawn_cd = 15
	enemies = {}
	bullets = {}
	grenades = {}
	e_projects = {}
	gun_parts = {}
	explosion_parts = {}
	fog_map = {}
	for signal in all(cache_signals) do
		add(pickups, signal)
	end
	if scene_state != "normal" then
		deconstruct_scene(scene_state)
		scene_state = "normal"
	end
	for e in all(cache_enemies) do
        mset(e.x / 8, e.y / 8, e.sprite)
    end
end

function game_over()
	sfx(20)
	print_stats(false)
end

function player_win()
	sfx(19)
	print_stats(true)
end

function print_stats(win)
	cls()
	if win then
		print("you win!", cam.x + 48, cam.y, 10)
		player.score += (player.lives * 100)
	else
		print("game over", cam.x + 46, cam.y, 8)
	end
	final_time = player.time \ 30
	print("score: "..pad_int(player.score, 6).."00", cam.x, cam.y + 8, 7)
	print("coins: "..player.coins, cam.x, cam.y + 14, 7)
	print("kills: "..player.kills, cam.x, cam.y + 20, 7)
	print("deaths: "..player.deaths, cam.x, cam.y + 26, 7)
	print("time: "..(pad_int(final_time \ 60, 2))..":"..(pad_int(final_time % 60, 2)), cam.x, cam.y + 32, 7)
	frame_counter = 0
	game_state = "end"
end

function handle_game_over()
	frame_counter += 1
	if frame_counter % 30 <= 15 then
		print("press any button to play again", cam.x + 4, cam.y + 110, 7)
	else
		print("press any button to play again", cam.x + 4, cam.y + 110, 0)
	end
	if btnp(❘) or btnp(🅾️) then
		run()
	end
end

function clone(obj)
  if type(obj) != "table" then return obj end
    local res = {}
    for k, v in pairs(obj) do
        res[k] = clone(v)
    end
    return res
end

function update_player_collision()
	if player.state == "normal" or player.state == "crouch" then
		if player.flp then
			player.col = update_collision({8, 0, 13, 7})
		else
			player.col = update_collision({2, 0, 7, 7})
		end
	elseif player.state == "aim_up" then
		if player.flp then
			player.col = update_collision({0, 8, 5, 15})
		else
			player.col = update_collision({2, 8, 7, 15})
		end
	end
end

function draw_player()
	if is_invuln() and player.invuln % 4 < 2 then
		pal(4, 8)
		pal(5, 8)
		pal(7, 8)
		pal(10, 8)
		pal(12, 8)
		pal(15, 8)
	end
	if player.state == "normal" then
		spr(1, player.x, player.y, 2, 1, player.flp)
	elseif player.state == "aim_up" then
		spr(16, player.x, player.y, 1, 2, player.flp)
	elseif player.state == "crouch" then
		spr(1, player.x, player.y, 2, 1, player.flp)
	end
	pal()
end

function draw_health_bar()
	local current_health = flr((player.health / player.max_health) * (player.max_health * 3))
	local color = 11
	if current_health / (3 * player.max_health) <= 0.5 then color = 10 end
	if current_health / (3 * player.max_health) <= 0.25 then color = 8 end
	rect(cam.x + 1, cam.y + 1, cam.x + (player.max_health * 3) + 3, cam.y + 6, 0)
	rectfill(cam.x + 2, cam.y + 2, cam.x + current_health + 2, cam.y + 5, color)
end

function draw_score_count()
	print(pad_int(player.score, 6).."00", cam.x + 96, cam.y + 1, 7)
end

function draw_lives_remaining()
	sspr(24, 0, 5, 5, cam.x + 114, cam.y + 9, 5, 5)
	if player.lives < 10 do
		print("x"..player.lives, cam.x + 120, cam.y + 9, 7)
	else
		print(player.lives, cam.x + 120, cam.y + 9, 7)
	end
end

function draw_coin_count()
	sspr(16, 16, 8, 8, cam.x + 94, cam.y + 9, 5, 5)
	print(pad_int(player.coins, 3), cam.x + 100, cam.y + 9, 7)
end

function pad_int(val, len)
  local s = tostr(val)

  while #s < len do
    s = "0"..s
  end

  return s
end

-- testing --

function show_player_debug()
	print("x: "..player.x, cam.x, cam.y + 16, 8)
	print("y: "..player.y, cam.x, cam.y + 24, 8)
	print("dx: "..player.dx, cam.x, cam.y + 32, 8)
	print("dy: "..player.dy, cam.x, cam.y + 40, 8)
	print("flp: "..tostring(player.flp), cam.x, cam.y + 48, 8)
	print("state: "..player.state, cam.x, cam.y + 56, 8)
	print("is_airborne: "..tostring(player.is_airborne), cam.x, cam.y + 64, 8)
	print("health: "..player.health, cam.x, cam.y + 72, 8)
end

-->8
-- collision physics and destruction--

function collide(o, f)
	local x1 = (o.x + o.col[1]) / 8
	local y1 = (o.y + o.col[2]) / 8
	local x2 = (o.x + o.col[3]) / 8
	local y2 = (o.y + o.col[4]) / 8
	return fget(mget(x1, y1), f) or fget(mget(x1, y2), f) or fget(mget(x2, y2), f) or fget(mget(x2, y1), f) 
end

function collide_obj(a, b)
	return not (a.x + a.col[1] > b.x + b.col[3] or 
        a.x + a.col[3] < b.x + b.col[1] or 
        a.y + a.col[2] > b.y + b.col[4] or 
        a.y + a.col[4] < b.y + b.col[2])
end

function update_collision(c)
	return {c[1], c[2], c[3], c[4]}
end

function handle_bullet_destruction(o)
	if collide(o, 1) then
		if fget(mget(o.x / 8, o.y / 8), 1) then
			mset(o.x / 8, o.y / 8, 0)
			sfx(16)
			player.last_tx = -1
		end
	end
end

function handle_grenade_destruction(o)
    for i = (o.x + o.col[1]) / 8, (o.x + o.col[3]) / 8 do
        for j = (o.y + o.col[2]) / 8, (o.y + o.col[4]) / 8 do
            if fget(mget(i, j), 1) then
                mset(i, j, 0)
				sfx(16)
				player.last_tx = -1
            end
        end
    end 
end


-- testing --

function show_collision_box(o)
	local x1 = (o.x + o.col[1])
	local y1 = (o.y + o.col[2])
	local x2 = (o.x + o.col[3])
	local y2 = (o.y + o.col[4])
	pset(x1, y1, 8)
	pset(x2, y2, 8)
	pset(x1, y2, 8)
	pset(x2, y1, 8)
end
-->8
-- weapons --

-- gun --

function init_bullet()
	local dir = 0
	if player.state == "aim_up" then
		col = {0, 0, 2, 4}
	elseif player.state == "normal" then
		if player.flp then
			dir = -1
			col = {3, 2, 7, 0}
		else 
			dir = 1
			col = {0, 0, 4, 2}
		end
	end
	off = gun_offset(player)
	x = player.x + off.x
	y = player.y + off.y
	if player.state == "aim_up" then
		dx = 0
		dy = 5
	elseif player.state == "normal" then
		dx = dir * 5
		dy = 0
	end
	return {
		x = x,
		y = y,
		dx = dx,
		dy = dy,
		col = col,
		dropoff = 60,
	}
end

function shoot()
	if player.ammo > 0 then
		player.ammo -= 1
		player.last_shoot_time = player.time
		player.reloading = false
		player.reload_frame = 0
		b = init_bullet()
		add(bullets, b)
		melee_range_blast()
		sfx(1)
		gun_blast(player)
		player.dx -= b.dx / 5
		player.dy += b.dy / 5
	else
		reload()
	end
end

function melee_range_blast()
	if player.state == "aim_up" then
		c = {
			x = -1,
			y = -1,
			col = {player.x, player.y, player.x + 8, player.y + 8}
		}
	else
		c = {
			x = -1,
			y = -1,
			col = {player.x + ((player.flp and -1 or 1) == 1 and 4 or 2), player.y, player.x + ((player.flp and -1 or 1) == 1 and 1 or -1) + 12, player.y + 6},
		}
	end

    for tx = flr(c.col[1] / 8), flr(c.col[3] / 8) do
        for ty = flr(c.col[2] / 8), flr(c.col[4] / 8) do
            if fget(mget(tx, ty), 1) then
                mset(tx, ty, 0)
                sfx(16)
                player.last_tx = -1
            end
        end
    end

	for e in all(enemies) do
		if collide_obj(c, e) then
			take_damage(e, 1)
			del(bullets, b)
		end
	end
end

function handle_reload()
	if player.ammo <= 0 then reload() end
	if player.time - player.last_shoot_time >= 300 and player.ammo < player.max_ammo then reload() end
	if player.reloading then
		player.reload_frame += 1
	end
	if player.reload_frame >= 30 then
		player.ammo = player.max_ammo
		player.reload_frame = 0
		player.reloading = false
	end
end

function reload()
	if not player.reloading then
		sfx(7)
		player.reloading = true
	end
end

function handle_dropoff(b)
	if b.dropoff > 0 then
		b.dropoff -= 1
	else
		del(bullets, b)
	end
end

function handle_bullets()
	for b in all(bullets) do
		b.x += b.dx
		b.y -= b.dy
		handle_bullet_destruction(b)
		handle_bullet_collision(b)
		handle_dropoff(b)
	end
end

function draw_bullets()
	for b in all(bullets) do
		if b.dx != 0 then
			spr(18, b.x, b.y, 1, 1, b.dx < 0)
		else
			spr(17, b.x, b.y, 1, 1)
		end
	end
end

function gun_blast(p)
	for i=1,10 do
		init_gun_part(p)
	end
end

function gun_offset(p)
	if p.state == "normal" then
		if p.flp then
			x_off = 0
			y_off = 1
		else
			x_off = 15
			y_off = 1
		end
	elseif p.state == "aim_up" then
		if p.flp then
			x_off = 4
			y_off = 1
		else
			x_off = 3
			y_off = 1
		end
	end
	return {
		x = x_off,
		y = y_off,
	}
end

function init_gun_part(p)
	off = gun_offset(p)
	add(gun_parts, {
		x = p.x + off.x,
		y = p.y + off.y,
		dx = rnd(2) - 1,
		dy = rnd(2) - 1,
		frame = 0,
	})
end

function handle_gun_parts()
	for p in all(gun_parts) do
		p.x += p.dx
		p.y += p.dy
		p.frame += 1
		if p.frame >= 10 then
			del(gun_parts, p)
		end
	end
end

function draw_gun_parts()
	for p in all(gun_parts) do
		circfill(p.x, p.y, 1, 7)
	end
end

function draw_ammo_display()
	local x = 2
	local color = 13
	for i = 1, player.max_ammo do
		if i <= player.ammo then color = 6 else color = 13 end
		line(cam.x + x, cam.y + 10, cam.x + x, cam.y + 14, color)
		x += 4
	end
end

function draw_reload()
	if player.reloading then
		rect(cam.x + 2, cam.y + 16, cam.x + 30, cam.y + 20, 0)
		rectfill(cam.x + 3, cam.y + 17, cam.x + player.reload_frame, cam.y + 19, 8)
	end
end

function handle_bullet_collision(b)
	if collide(b, 0) and not collide(b, 1) then
		del(bullets, b)
	end
end

-- grenade --

function init_grenade()
	local dir = 1
	if player.flp then
		dir = -1
	end
	return {
		x = player.x,
		y = player.y-8,
		dx = player.dx + (4 * dir),
		dy = player.dy + 4,
		dir = dir,
		countdown = 60,
		col = {0, 0, 7, 7},
	}
end

function drop_grenade()
	g = init_grenade()
	add(grenades, g)
end

function handle_grenades()
	for g in all(grenades) do
		local lx = g.x
		local ly = g.y

		g.x += g.dx
		if collide(g, 0) then
			g.x = lx
		end
		if g.dx > 0 and g.dir == 1 or  g.dx < 0 and g.dir == -1 then
			g.dx *= 0.9
		else
			g.dx = 0
		end

		g.y += g.dy
		if not collide(g, 0) then
			g.dy += gravity
		else
			g.y = ly
			g.dy *= -0.5
		end

		g.countdown -= 1
		if g.countdown <= 0 then
			explode(g)
		end
	end
end

function explode(g)
	g.col = {-32, -32, 32, 32}
	for e in all(enemies) do
		if collide_obj(g, e) then
			take_damage(e, 2)
		end
	end
	handle_grenade_destruction(g) -- this doesn't work
	explosion(g)
	shake_screen(10)
	sfx(5)
	del(grenades, g)
end


function explosion(g)
	for i = 1,25 do
		add(explosion_parts, init_explosion_part(g))
	end
end

function init_explosion_part(g)
	add(explosion_parts, {
		x = g.x,
		y = g.y,
		c = rnd({7, 9, 10}),
		r = rnd(3) + 3,
		dx = (rnd(2) - 1) / 2,
		dy = (rnd(2) - 1) / 2,
		frame = 0,
	})
end

function handle_explosion_parts()
	for p in all(explosion_parts) do
		p.x += p.dx
		p.y += p.dy
		p.frame += 1
		if p.frame >= 30 then
			del(explosion_parts, p)
		end
	end
end

function draw_explosion_parts()
	for p in all(explosion_parts) do
		circfill(p.x, p.y, p.r, p.c)
	end
end

function draw_grenades()
	for g in all(grenades) do
		if g.countdown % 10 < 5 then
			spr(33, g.x, g.y, 1, 1, false, false)
		else
			spr(33, g.x, g.y, 1, 1, true, true)
		end
	end
end

-- testing --

function show_gun_shoot(p)
	off = gun_offset(p)
	pset(off.x + p.x, off.y + p.y, 8)
end
-->8
-- enemies --

function init_enemy_dict()
	return {
		[4] = {
			name = "investigator",
			type = "normal",
			health = 2,
			dmg = 1,
			points = 3,
			dx = -1,
			dy = 0,
			sx = 1,
			sy = 1,
			col = {1, 0, 6, 7},
			fcol = {2, 0, 6, 7},
		},
		[5] = {
			name = "takodachi",
			type = "crawler",
			health = 2,
			dmg = 1,
			points = 4,
			dir = 1,
			dx = {1, 0, -1, 0},
			dy = {0, 1, 0, -1},
			sx = 1,
			sy = 1,
			col = {0, 0, 7, 7},
			fcol = {0, 0, 7, 7},
		},
		[6] = {
			name = "ebi_chan",
			type = "normal",
			health = 1,
			dmg = 1,
			points = 2,
			dx = -1,
			dy = 0,
			sx = 1,
			sy = 1,
			col = {0, 0, 7, 7},
			fcol = {0, 0, 7, 7},
		},
		[7] = {
			name = "kfp",
			type = "normal",
			health = 2,
			dmg = 1,
			points = 3,
			dx = -1,
			dy = 0,
			sx = 1,
			sy = 1,
			col = {1, 0, 6, 7},
			fcol = {1, 0, 6, 7},
		},
		[12] = {
			name = "cursed_bubba",
			type = "flier",
			health = 30,
			dmg = 5,
			cd = 60,
			points = 100,
			dx = rnd(4) - 2,
			dy = rnd(4) - 2,
			sx = 2,
			sy = 2,
			col = {0, 0, 15, 15},
			fcol = {0, 0, 15, 15},
			signal = true,
		},
		[14] = {
			name = "dino_gura",
			type = "normal",
			health = 30,
			dmg = 4,
			cd = 45,
			points = 50,
			dx = -0.8,
			dy = 0,
			sx = 2,
			sy = 2,
			col = {0, 0, 15, 15},
			fcol = {0, 0, 15, 15},
			signal = true,
		},
		[20] = {
			name = "bee_ame",
			type = "flier",
			health = 1,
			dmg = 1,
			points = 2,
			dx = rnd(4) - 2,
			dy = rnd(4) - 2,
			sx = 1,
			sy = 1,
			col = {0, 0, 7, 7},
			fcol = {0, 0, 7, 7},
		},
		[21] = {
			name = "takodachi",
			type = "crawler",
			health = 2,
			dmg = 1,
			points = 4,
			dir = 2,
			dx = {1, 0, -1, 0},
			dy = {0, 1, 0, -1},
			sx = 1,
			sy = 1,
			col = {0, 0, 7, 7},
			fcol = {0, 0, 7, 7},
		},
		[22] = {
			name = "pumpkin_ame",
			type = "normal",
			health = 4,
			dmg = 2,
			points = 5,
			dx = -1,
			dy = 0,
			sx = 1,
			sy = 1,
			col = {0, 0, 7, 7},
			fcol = {0, 0, 7, 7},
		},
		[23] = {
			name = "death_sensei",
			type = "flier",
			health = 2,
			dmg = 1,
			points = 4,
			dx = rnd(4) - 2,
			dy = rnd(4) - 2,
			sx = 1,
			sy = 1,
			col = {0, 0, 7, 7},
			fcol = {0, 0, 7, 7},
		},
	}
end

function init_enemy(x, y, sprite)
	return {
		name = init_enemy_dict()[sprite].name,
		health = init_enemy_dict()[sprite].health,
		dict = init_enemy_dict()[sprite],
		x = x,
		y = y,
		dx = init_enemy_dict()[sprite].dx,
		dy = init_enemy_dict()[sprite].dy,
		col = init_enemy_dict()[sprite].col,
		flp = false,
		flph = false,
		sprite = sprite,
		signal = init_enemy_dict()[sprite].signal
	}
end

function spawn_enemy(tx, ty)
	local tile = mget(tx, ty)
	if fget(tile, 7) then
		add(enemies, init_enemy(tx * 8, ty * 8, tile))
		add(cache_enemies, init_enemy(tx * 8, ty * 8, tile))
		for x = 0, init_enemy_dict()[tile].sx - 1 do
			for y = 0, init_enemy_dict()[tile].sy - 1 do
				mset(tx + x, ty + y, 0)
			end
		end
	end
end

function handle_enemies()
	for e in all(enemies) do
		local lx = e.x
		local ly = e.y
		check_player_in_range(e)
		if e.dict.type == "flier" then
			if e.dx < 1 and e.dx > -1 then
				e.dx = rnd(4) - 2
			end
			if e.dy < 1 and e.dy > -1 then
				e.dy = rnd(4) - 2
			end

			if e.dx > 0 then
				e.flp = false
			elseif e.dx < 0 then
				e.flp = true
			end

			e.x += e.dx
			if collide(e, 0) then
				e.x = lx
				e.dx = -e.dx
			end

			e.y += e.dy
			if collide(e, 0) then
				e.y = ly
				e.dy = -e.dy
			end
		elseif e.dict.type == "crawler" then
			if e.x % 8 == 0 and e.y % 8 == 0 then
				local side = e.dict.dir % 4 + 1

				local cx = e.x + 4
				local cy = e.y + 4

				local side_solid = check_is_solid(cx + e.dx[side] * 6, cy + e.dy[side] * 6)
				local front_solid = check_is_solid(cx + e.dx[e.dict.dir] * 6, cy + e.dy[e.dict.dir] * 6)

				if not side_solid then
					e.dict.dir = side

				elseif front_solid then
					e.dict.dir = (e.dict.dir + 2) % 4 + 1
				end
			end

			local move_x = e.dx[e.dict.dir]
			local move_y = e.dy[e.dict.dir]

			e.x += move_x
			e.y += move_y

			if e.dict.dir == 1 then
				e.sprite = 5
				e.flp = false
				e.flph = false
			elseif e.dict.dir == 2 then
				e.sprite = 21
				e.flp = false
				e.flph = false
			elseif e.dict.dir == 3 then
				e.sprite = 5
				e.flp = true
				e.flph = true
			elseif e.dict.dir == 4 then
				e.sprite = 21
				e.flp = true
				e.flph = true
			end
		elseif e.dict.type == "normal" then
			local ground_solid = check_is_solid(e.x + (e.dx * 4), e.y + 8)
			if not ground_solid and e.name != "dino_gura" then
				e.dx *= -1
			end
			if check_player_in_range(e) then
				face_player_direction(e)
			end
			e.x += e.dx
			if collide(e, 0) then
				e.x = lx
				e.dx *= -1
			end
			e.y += e.dy
			if not collide(e, 0) then
				e.dy += gravity
			else
				e.y = ly
				e.dy = 0
			end
			if e.dx > 0 then
				e.flp = false
			else
				e.flp = true
			end
		end
		if e.name == "dino_gura" then
			if e.dict.cd <= 0 then
				shoot_enemy_project(e, 2, e.dx * 2.5, 0)
				e.dict.cd = init_enemy_dict()[e.sprite]["cd"]
			else
				e.dict.cd -= 1
			end
		end
		if e.name == "cursed_bubba" then
			if e.dict.cd <= 0 then
				for dx = -1, 1, 1 do
					for dy = -1, 1, 1 do 
						shoot_enemy_project(e, 3, dx, dy)
					end
				end
				e.dict.cd = init_enemy_dict()[e.sprite]["cd"]
			else
				e.dict.cd -= 1
			end
		end
	end
	for b in all(bullets) do
		for e in all(enemies) do
			if collide_obj(b, e) then
				del(bullets, b)
				take_damage(e, 1)
			end
		end
	end
end

function check_player_in_range(e)
	local range = {
		col = {-32, -32, 32, 32},
		x = e.x,
		y = e.y,
	}
	if collide_obj(range, player) then
		return true
	else
		return false
	end
end

function face_player_direction(e)
	local playerx = player.x
	if player.flp and player.state != "aim_up" then playerx = player.x + 8 end
	if e.x > playerx and e.dx > 0 then
		e.dx *= -1
	elseif e.x < playerx and e.dx < 0 then
		e.dx *= -1
	end
end

function init_enemy_project(e, dmg, dx, dy)
	if dx == 0 and dy == 0 then return end
	return {
		x = e.x,
		y = e.y + 8,
		dx = dx,
		dy = dy,
		dmg = dmg,
		col = {0, 0, 7, 7},
	}
end

function shoot_enemy_project(e, dmg, dx, dy)
	p = init_enemy_project(e, dmg, dx, dy)
	add(e_projects, p)
end

function handle_enemy_projects()
	for p in all(e_projects) do
		p.x += p.dx
		p.y += p.dy
		handle_e_project_collision(p)
	end
end

function handle_e_project_collision(p)
	if collide(p, 0) then
		del(e_projects, p)
	end
end

function draw_enemy_projects()
	for p in all(e_projects) do
		circfill(p.x, p.y, 3, 10)
		circfill(p.x, p.y, 2, 9)
		circfill(p.x, p.y, 1, 8)
	end
end

function init_e_part(e)
	add(e_parts, {
		x = e.x,
		y = e.y,
		r = rnd(3) + 1,
		dx = rnd(2) - 1,
		dy = rnd(2) - 1,
		frame = 0,
	})
end

function handle_e_parts()
	for p in all(e_parts) do
		p.x += p.dx
		p.y += p.dy
		p.frame += 1
		if p.frame >= 20 do
			del(e_parts, p)
		end
	end
end

function init_gun_part(p)
	off = gun_offset(p)
	add(gun_parts, {
		x = p.x + off.x,
		y = p.y + off.y,
		dx = rnd(2) - 1,
		dy = rnd(2) - 1,
		frame = 0,
	})
end

function draw_e_parts()
	for p in all(e_parts) do
		circfill(p.x, p.y, p.r, 7)
	end
end

function e_blast(e)
	for i=1,10 do
		init_e_part(e)
	end
end

function check_is_solid(x, y)
	local tx = flr(x / 8)
	local ty = flr(y / 8)
	return fget(mget(tx, ty), 0)
end

function take_damage(o, v)
	o.health -= v
	if o.name == "player" then
		sfx(6)
	end
	if o.health <= 0 then
		die(o)
	end
end

function die(o)
	if o.name == "player" then
		o.score -= 10
		clamp_score()
		game_state = "died"
		player_died()
	else
		player.score += o.dict.points
		player.kills += 1
		init_message(o.dict.points * 100, o.x, o.y, 0)
		if o.signal then
			trigger_signal(o)
		end
		e_blast(o)
		del(enemies, o)
		sfx(4)
	end
end

function draw_enemies()
	for e in all(enemies) do
		if fget(e.sprite, 5) then
			palt(13, true)
			palt(0, false)
		end
		spr(e.sprite, e.x, e.y, e.dict.sx, e.dict.sy, e.flp, e.flph)
		palt()
	end
end

-->8
-- camera title and music --

function handle_camera()
	if player.state == "normal" or player.state == "crouch" then
		if player.flp then
			cam.x = player.x - 55
			cam.y = player.y - 63
		else
			cam.x = player.x - 63
			cam.y = player.y - 63
		end
	elseif player.state == "aim_up" then
		cam.x = player.x - 63
		cam.y = player.y - 55
	end
	if player.y > 447 then
		cam.y = 384
	elseif player.y < 63 then
		cam.y = 0
	end
	if player.flp and player.x < 55 then
		cam.x = 0
	elseif not player.flp and player.x < 63 then
		cam.x = 0
	end
	if player.flp and player.x > 952 then
	 cam.x = 896
	elseif not player.flp and player.x > 960 then
		cam.x = 896
	end
end

function shake_screen(i)
	shake += i
end

function handle_shake()
	shake *= 0.75
	if shake < 0.1 then shake = 0 end
	local sx = rnd(shake) - shake / 2
	local sy = rnd(shake) - shake / 2
	camera(cam.x + sx, cam.y + sy)
end

function handle_visibility()
    local col_center_x = player.x + (player.col[1] + player.col[3]) / 2
    local col_center_y = player.y + (player.col[2] + player.col[4]) / 2
    local tx_int = flr(col_center_x / 8)
	local ty_int = flr(col_center_y / 8)

    if player.last_tx == tx_int and player.last_ty == ty_int and player.last_ls == player.state then
        return 
    end

    player.last_tx = tx_int
	player.last_ty = ty_int
	player.last_ls = player.state

    fog_map = {}
    local frontier = {{tx_int, ty_int, 0}} 
    fog_map[tx_int + ty_int * 128] = true

    local head = 1
    while head <= #frontier do
        local curr = frontier[head]
        head += 1
        
        local cx = curr[1]
		local cy = curr[2]
		local dist = curr[3]

		spawn_enemy(cx, cy)

        if dist < 12 then
            local neighbors = {{0,1},{0,-1},{1,0},{-1,0},{1,1},{1,-1},{-1,1},{-1,-1}}
            for n in all(neighbors) do
                local nx = cx + n[1]
				local ny = cy + n[2]
                local id = nx + ny * 128
                
                if nx >= 0 and nx <= 127 and ny >= 0 and ny <= 63 then
                    if not fog_map[id] then
                        fog_map[id] = true

                        if not fget(mget(nx, ny), 3) then
                            add(frontier, {nx, ny, dist + 1})
                        end
                    end
                end
            end
        end
    end
end

function draw_fog_mask()
    local start_x = flr(cam.x / 8)
    local start_y = flr(cam.y / 8)
    
    for sx = 0, 16 do
        for sy = 0, 16 do
            local tx = start_x + sx
            local ty = start_y + sy
            local id = tx + ty * 128
            
            if not fog_map[id] then
                rectfill(tx * 8, ty * 8, tx * 8 + 7, ty * 8 + 7, 0)
            end
        end
    end
end

function handle_title()
	if btnp(🅾️) then
		game_state = "game"
	end
end

function draw_title()
	cls()  
	sspr(0, 32, 64, 32, 0, 0, 128, 64)
	sspr(64, 32, 64, 32, 0, 64, 128, 64)
	print("press 🅾️ to start", 60, 110, 0)
end

function start_music(song)
	if music_playing == false then
	 music(song)
	 music_playing = true
	end
end

function stop_music()
	if music_playing == true then
		music(-1)
		music_playing = false
	end
end

-->8
-- pickups --

function init_pickup_dict()
	return {
		[19] = {
			name = "ten_coin",
			coins = 10,
			points = 10,
			sx = 1,
			sy = 1,
		},
		[33] = {
			name = "grenade",
			sx = 1,
			sy = 1,
		},
		[34] = {
			name = "coin",
			coins = 1,
			points = 1,
			sx = 1,
			sy = 1,
		},
		[35] = {
			name = "coin",
			coins = 1,
			points = 1,
			sx = 1,
			sy = 1,
		},
		[36] = {
			name = "pocket_watch",
			sx = 1,
			sy = 1,
		},
		[37] = {
			name = "teacup",
			health = 2,
			sx = 1,
			sy = 1,
		},
		[38] = {
			name = "syringe",
			max_health = 2,
			sx = 1,
			sy = 1,
		},
		[39] = {
			name = "ame_up",
			lives = 1,
			sx = 1,
			sy = 1,
		},
		[64] = {
			name = "s_gura",
			sx = 1,
			sy = 1,
			signal = true,
		},
		[65] = {
			name = "s_bubba",
			sx = 1,
			sy = 1,
			signal = true,
		},
		[66] = {
			name = "game_win",
			sx = 1,
			sy = 1,
			signal = true
		}
	}
end

function init_pickup(x, y, sprite)
	return {
		name = init_pickup_dict()[sprite].name,
		coins = init_pickup_dict()[sprite].coins,
		points = init_pickup_dict()[sprite].points,
		health = init_pickup_dict()[sprite].health,
		max_health = init_pickup_dict()[sprite].max_health,
		lives = init_pickup_dict()[sprite].lives,
		x = x,
		y = y,
		sx = init_pickup_dict()[sprite].sx,
		sy = init_pickup_dict()[sprite].sy,
		col = {0, 0, 7, 7},
		fcol = {0, 0, 7, 7},
		flp = false,
		flph = false,
		sprite = sprite,
		a_frame = 0,
		signal = init_pickup_dict()[sprite].signal,
	}
end

function spawn_pickups()
	pickups = {}
	for tx = 0, 127 do
		for ty = 0, 63 do
			local tile = mget(tx, ty)
			if fget(tile, 4) then
				add(pickups, init_pickup(tx * 8, ty * 8, tile))
				if init_pickup_dict()[tile].signal then add(cache_signals, init_pickup(tx * 8, ty * 8, tile)) end
				for x = 0, init_pickup_dict()[tile].sx - 1 do
					for y = 0, init_pickup_dict()[tile].sy - 1 do
						if tile == 66 then
							mset(tx + x, ty + y, 44)
						else
							mset(tx + x, ty + y, 0)
						end
					end
				end
			end
		end
	end
	return pickups
end

function pickup_item(o)
	if o.name == "grenade" then
		player.greades_unlocked = true
		sfx(17)
		init_message("grenades unlocked!", o.x, o.y, 0)
	elseif o.name == "coin" then
		player.coins += o.coins
		player.score += o.points
		if player.coins % 100 == 0 then
			player.lives += 1
			sfx(2)
			init_message("+1up", o.x, o.y, 11)
		else
			sfx(0)
			init_message(o.points * 100, o.x, o.y, 0)
		end
	elseif o.name == "ten_coin" then
		player.coins += o.coins
		player.score += o.points
		if player.coins % 100 < 10 then
			player.lives += 1
			sfx(2)
			init_message("+1up", o.x, o.y, 11)
		else
			sfx(0)
			init_message(o.points * 100, o.x, o.y, 0)
		end
	elseif o.name == "pocket_watch" then
		player.respawn = {x = o.x, y = o.y}
		sfx(10)
		init_message("checkpoint", o.x, o.y, 0)
	elseif o.name == "teacup" then
		player.health += o.health
		if player.health > player.max_health then player.health = player.max_health end
		sfx(8)
		init_message("♥", o.x, o.y, 14)
	elseif o.name == "syringe" then
		player.max_health += o.max_health
		player.health += o.max_health
		sfx(9)
		init_message("+max hp", o.x, o.y, 11)
	elseif o.name == "ame_up" then
		player.lives += o.lives
		sfx(2)
		init_message("+1up", o.x, o.y, 11)
	end
	if o.signal then
		trigger_signal(o)
	end
	del(pickups, o)
end

function handle_pickups()
	for p in all(pickups) do
		if collide_obj(p, player) then
			pickup_item(p)
		end
	end
end

function draw_pickups()
	for p in all(pickups) do
		if p.signal then goto continue end
		if p.name == "coin" then
			if p.a_frame % 16 > 8 then
				p.sprite = 35
			else
				p.sprite = 34
			end
			p.a_frame += 1
		end
		if p.name == "ten_coin" then
			if p.a_frame % 16 > 8 then
				p.sprite = 35
			else
				p.sprite = 19
			end
			p.a_frame += 1
		end
		spr(p.sprite, p.x, p.y, p.sx, p.sy, p.flp, p.flph)
		::continue::
	end
end

-->8
-- messages, tutorials, signals and helpers --

function init_message(message, x, y, color)
	add(messages, {
			message = message,
			x = x,
			y = y,
			color = color,
			frames = 20,
		}
	)
end

function handle_messages()
	for m in all(messages) do
		if m.frames >= 0 then
			m.y -= 1
			m.frames -= 1
		else
			del(messages, m)
		end
	end
end

function draw_messages()
	for m in all(messages) do
		print(m.message, m.x, m.y, m.color)
	end
end

function draw_tutorial_messages()
	print("press 🅾️ to jump", 145, 474, 0)
	print("press ❘ to shoot", 11, 458, 0)
	print("press ⬇️ + ❘ to", 664, 272, 0)
	print("drop a grenade", 668, 280, 0)
end

function trigger_signal(o)
	if o.name == "s_gura" and not gura_defeated then
		construct_scene("gura_fight")
		clear_stale_signals("s_gura")
	end
	if o.name == "dino_gura" then
		deconstruct_scene()
		gura_defeated = true
	end
	if o.name == "s_bubba" and not bubba_defeated then
		construct_scene("bubba_fight")
		clear_stale_signals("s_bubba")
	end
	if o.name == "cursed_bubba" then
		deconstruct_scene()
		bubba_defeated = true
		construct_scene("final_boss_defeated")
	end
	if o.name == "game_win" then
		construct_scene("game_win")
	end
	player.last_tx = -1
end

function block_rect(x1, x2, y1, y2, sprite)
	for i = x1, x2 do
		for j = y1, y2 do
			mset(i, j, sprite)
		end
	end
end

function clear_stale_signals(name)
	for p in all(pickups) do
		if p.name == name then del(pickups, p) end
	end
end

function construct_scene(scene)
	if scene == "gura_fight" then
		shake_screen(100)
		block_rect(64, 64, 38, 39, 40)
        block_rect(82, 82, 32, 39, 40)
		add(enemies, init_enemy(78 * 8, 38 * 8, 14))
	end
	if scene == "bubba_fight" then
		shake_screen(100)
		block_rect(75, 75, 12, 13, 40)
		add(enemies, init_enemy(64 * 8, 8 * 8, 12))
	end
	if scene == "final_boss_defeated" then
		shake_screen(200)
		sfx(5)
		block_rect(75, 75, 4, 8, 0)
	end
	if scene == "game_win" then
		player_win()
	end
	scene_state = scene
end

function deconstruct_scene()
	if scene_state == "gura_fight" then
		block_rect(64, 64, 38, 39, 0)
        block_rect(82, 82, 32, 39, 0)
	end
	if scene_state == "bubba_fight" then
		block_rect(75, 75, 12, 13, 0)
	end
	scene_state = "normal"
end

function init_candlestick(x, y)
	return {
		x = x,
		y = y,
		sprite = 52,
		a_frame = 0,
	}
end

function spawn_candlesticks()
	candlesticks = {}
	for tx = 0, 127 do
		for ty = 0, 63 do
			if mget(tx, ty) == 52 then
				add(candlesticks, init_candlestick(tx * 8, ty * 8))
				mset(tx, ty, 0)
			end
		end
	end
	return candlesticks
end

function draw_candlesticks()
	for c in all(candlesticks) do
		if c.a_frame % 15 <= 5 then
			c.sprite = 52
		elseif c.a_frame % 15 >= 10 then
			c.sprite = 54
		else
			c.sprite = 53
		end
		c.a_frame += 1
		spr(c.sprite, c.x, c.y)
	end
end

function init_stalactite(x, y)
	return {
		x = x,
		y = y,
		sprite = 10,
		a_frame = 0,
	}
end

function spawn_stalactites()
	stalactites = {}
	for tx = 0, 127 do
		for ty = 0, 63 do
			if mget(tx, ty) == 10 then
				add(stalactites, init_stalactite(tx * 8, ty * 8))
				mset(tx, ty, 0)
			end
		end
	end
	return stalactites
end

function draw_stalactites()
	for c in all(stalactites) do
		if c.a_frame % 120 <= 105 then
			c.sprite = 10
		elseif c.a_frame % 120 > 105 and c.a_frame % 120 <= 110 then
			c.sprite = 11
		elseif c.a_frame % 120 > 110 and c.a_frame % 120 <= 115 then
			c.sprite = 26
		else
			c.sprite = 27
		end
		c.a_frame += 1
		spr(c.sprite, c.x, c.y)
	end
end
