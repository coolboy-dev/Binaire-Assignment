 --hypno sis
--urgurgurg

can_proceed = true

proceed_await = nil

function wait_to_proceed()
	timed_function(
		function()
			can_proceed = true
		end, 15
	)
end

function _init()
	poke(0x5f2e, 1)--[[use secret pallette]]
	poke(0x5f2c, 3)--[[use 64x64 graphics]]

	if cartdata("urgurgurg_hypno_sis_05") then
		levelnum = dget(0) or 1
	else
		levelnum = 1
		dset(0, 1)
	end

	menuitem(
		1, "reset progress", function()
			levelnum = 1
			set_state(title)
		end
	)

	--⬇️⬇️⬇️⬇️⬇️⬇️ debugging stuff ⬇️⬇️⬇️⬇️⬇️

	--[[➡️➡️➡️]]
	--levelnum=1 --[[⬅️⬅️⬅️]]

	---⬆️⬆️⬆️⬆️⬆️⬆️ comment out ⬆️⬆️⬆️⬆️⬆️⬆️

	set_state(title)
end

function set_state(t, trans)
	sfx(-1)
	music(-1)
	can_proceed = false
	timed = {}
	t.init()
	state = t

	if trans == nil then
		transition = cocreate(function()
			for i = 63, 0, -3 do
				fillp(░)
				rectfill(0, -50, i * 1.4, 63, 0)
				fillp(▒)
				rectfill(0, -50, i * 1.2, 63, 0)
				fillp()
				rectfill(0, -50, i, 63, 0)
				yield()
			end
		end)
	elseif trans == "spiral" then
		transition = cocreate(function()
			ox, oy, px, py, rad, nx, ny = 32, 32, 32, 32, 0, 0, 0
			for j = 64, 0, -2 do
				for i = j, 0, -1 do
					rad += 0.02
					nx, ny = ox + (sin(rad) * i), ox + (cos(rad) * i)
					line(px, py, nx, ny, 0)
					if i != j then
						px, py = nx, ny
					end
				end
				yield()
			end
		end)
	end
end

function _update()
	⧗ = sin(time())

	if state then
		state.update()
	end

	foreach(timed, coresume)
end

function _draw()
	state.draw()

	if can_proceed and ⧗ > 0 then
		outlinespr("press ❘", 15, 55, 12)
	end

	coresume(transition)
end

-->8
--helpers

function lerp(a, b, t)
	return mid(a, a + t * (b - a), b)
end

function spritecoords(sp)
	return (sp % 16) * 8, (sp \ 16) * 8
end

function timed_function(f, delay)
	add(
		timed, cocreate(function()
			for i = delay, 0, -1 do
				yield()
			end
			f()
		end)
	)
end

swingtime = 0

function set_up_pendulum()
	handx, handy = 32, 8
	swingtime = 0
	swing = 1
	power = 0
	dir = 1

	--chain

	chain = {}
	chainlen = 25
	chainsegs = 5
	angs = {}
	for i = 1, chainsegs do
		angs[i] = 1
	end
	clockx, clocky = 0, 0
end

function pendulum()
	local exert = function()
		power += 0.001
		swingtime = 0
	end

	if btn(⬅️) and handx > 0 then
		exert()
		swing -= power
		handx -= 1
		dir = -1
	elseif btn(➡️) and handx < 63 then
		exert()
		handx += 1
		dir = 1
		swing += power
	else
		swingtime += 0.02

		swing += sin(swingtime * dir) * power
	end

	swing = mid(0.6, swing, 1.4)

	power = mid(0, power - 0.0005, 0.5)

	swing = lerp(1, swing, 0.9)

	add(angs, swing, 1)
	deli(angs, #angs)

	--angs[1]=mid(0.75,swing,1.25)

	local prevx, prevy = handx, handy

	chain = {}

	local seglen = chainlen / chainsegs

	for a in all(angs) do
		local nx, ny = prevx + (sin(a) * seglen), prevy + (cos(a) * seglen)
		add(chain, { prevx, prevy, nx, ny, 10 })
		prevx, prevy = nx, ny
	end

	clockx, clocky = prevx, prevy
end

function reset_pal()
	palt()
	pal()
	pal({ [0] = 0, 1, 141, 3, 4, 5, 6, 7, 8, 143, 10, 11, 12, 13, 14, 15 }, 1)
end

function draw_pendulum()
	for c in all(chain) do
		line(unpack(c))
		pset(c[1], c[2], 4)
	end

	circfill(clockx, clocky + 1, 5, 4)
	circfill(clockx, clocky, 5, 10)

	spr(1, handx - 3, handy - 7)

	--print(swing,0,0,11)
end

--[[
		pendulum stuff
		swing=lerp(0,swing+sin(swingtime*dir)*power,min(1,power))
		limit = power*30


		if btn(⬅️) then
			if handx>0 then
				power=power+0.05
				handx-=1
				dir=1
			end
		elseif btn(➡️) then
			if handx<63 then
				power=power+0.05
				handx+=1
				dir=-1
			end
		else
		swingtime+=0.02
		end



	if dir==-1 and swing<-limit then
		dir=1
	elseif dir==1 and swing>limit then
		dir=-1
	end

	power=max(0,power-0.001)

	chain={}
	local angmod,prevx,prevy=1,handx,handy

	local seglen = chainlen/chainseg

	for i=0,chainseg do
		angmod*=1
		local ang = atan2(gravity,swing*angmod)
		local cx,cy = prevx+sin(ang)*seglen,prevy+cos(ang)*seglen
		add(chain,{x=cx,y=cy})
		prevx,prevy = cx,cy
	end

	clockx,clocky = chain[chainseg].x,chain[chainseg].y
	--]]

-->8
--visuals

valspr = 162
aikospr = 166
calispr = 170

encouragements = {}

function eyedraw(ex, ey)
	if progress < 50 then
		spr(character_sprite + 112, ex - 3.5, ey - 3.5)
	else
		spiral(ex, ey, 5, 0.05, 3)
	end
end

sprite_outline_color = 0

function outlinespr(...)
	local s, x, y, w, h, f = ...

	local text = type(s) == "string"

	if not text then
		for i = 0, 15 do
			if i != 11 then
				pal(i, sprite_outline_color)
			end
		end
		palt(0, false)
		palt(11, true)
	end

	for c in all({ { 0, -1 }, { 0, 1 }, { 1, 0 }, { -1, 0 } }) do
		local c1, c2 = unpack(c)
		if text then
			print(s, x + c1, y + c2, sprite_outline_color)
		else
			spr(s, x + c1, y + c2, w, h, f)
		end
	end

	if text then
		print(...)
	else
		pal()
		palt(0, false)
		palt(11, true)
		spr(...)
		reset_pal()
	end
end

rainbowish = { 8, 10, 11, 12, 2 }

function spiral(x, y, s, spiralgap, col)
	local rad = -time() / 2 % 1
	local prevx, prevy = x, y
	local linecol = col
	local finalgap = spiralgap
	for i = 1, s, spiralgap do
		rad += 0.02
		finalgap = i + (i * 0.1)
		local nx = ceil(x + (sin(rad) * finalgap))
		local ny = ceil(y + (cos(rad) * finalgap))
		if col == -1 then
			linecol = rainbowish[flr(1 + (i % #rainbowish))]
		end
		line(prevx, prevy, nx, ny, linecol)
		prevx, prevy = nx, ny
	end
end

function character(sp, x, y)
	palt(0, false)
	palt(11, true)

	palt(11, true)
	palt(0, false)
	for i = 0, 15 do
		if i != 11 then
			pal(i, 7)
		end
	end
	spr(sp, x + 15, y + 22, 2, 7)
	spr(sp, x + 32, y + 22, 2, 7, 1)
	reset_pal()
	palt(11, true)
	palt(0, false)
	spr(sp, x + 16, y + 22, 2, 7)
	spr(sp, x + 31, y + 22, 2, 7, 1)

	clip(x + 24, y + 30, 8, 8)
	rectfill(0, 0, 63, 63, 7)
	eyedraw(x + 28 + eyex, y + 28 + eyey + eyeline_offset)

	clip(x + 31, y + 30, 8, 8)
	rectfill(0, 0, 63, 63, 7)
	eyedraw(x + 34 + eyex, y + 28 + eyey + eyeline_offset)

	clip()
	--[[
	sprite_outline_color=7
	clip(0,0,x+31,63)
	spr(sp,x+16,y+22,2,7)
	clip(x+31,0,63,63)
	spr(sp,x+31,y+22,2,7,1)
	clip()
		palt(0,false)
	palt(11,true)
	--]]

	sprite_outline_color = 0
	local mouth, eye = -1, -1
	if character_action == "" then
		if progress < 50 then
			--blink
			if time() % 4 < 1.3 then
				eye = (sp + 2) + (⧗ + 0.5)
			end
		end
	elseif character_action == "grossedout" then
		eye = sp + 66
		mouth = sp + 51
	elseif character_action == "eating" then
		if progress < 75 then
			eye = sp + 2
		end
		mouth = (sp + 33) + (sin(time() * 2) + 2)
	elseif character_action == "openmouth" then
		if progress < 75 then
			eye = sp + 3
		end
		mouth = sp + 50
	elseif character_action == "queasy" then
		eye = sp + 2
		mouth = sp + 35
	end

	if eye != -1 then
		spr(eye, x + 24, y + 22, 1, 2)
		spr(eye, x + 31, y + 22, 1, 2, true)
	else
		spr(sp + 1, x + 24, y + 22, 1, 2)
		spr(sp + 1, x + 31, y + 22, 1, 2, true)
	end

	if mouth != -1 then
		spr(mouth, x + 24, y + 38, 1, 1, false)
		spr(mouth, x + 32, y + 38, 1, 1, true)
	end

	local ox, oy = x + 31, y + 62

	local stufflerp = stuffed / 100

	if stuffed > 0 then
		local bw = stufflerp * 16
		local bh = stufflerp * 5
		local bb = stufflerp * 4

		ovalfill(ox - bw, oy - (bh * 1.1), ox + bw, oy + (bh * 2.4), char_shade)
		ovalfill(ox - bw, oy - bh, ox + bw, oy + (bh * 2) + ⧗, char_skin)
		ovalfill(ox - 1, oy + bb, ox + 1, oy + bb + 1 + ⧗, char_shade)
	end

	palt()
end

function encouragetext()
	if 1 + rnd(5) > combo then
		return
	end

	local phrases = {
		[[
totally
 hyp!!
]],
		[[
defenses
dropping!!
]],
		[[
inhibitions
 fading!!!
]],
		[[
keep it
 up!!
]],
		[[
sin you
swinger!
]],
		[[
   in
control!!
]],
		[[
proble-
matical!!
]],
		[[
 totally
dubious!!!
]],
		[[
    hella
   ethical
implications?!!
]],
		[[
mesmo-
izing
]],
		[[
the power of
suggestion!!
]]
	}
	local p = rnd(phrases)
	local w = #split(p, "\n")[2] * 6
	local e = {
		phrase = p,
		x = mid(0, clockx - (w / 2), 63 - w),
		y = clocky + 20,
		col = rnd { 8, 11, 10, 12 },
		lifetime = 30
	}
	add(encouragements, e)
end

function eupdate(e)
	e.y -= 1
	e.lifetime -= 1
	printh(e.phrase)
end

function edraw(e)
	outlinespr(e.phrase, e.x, e.y, e.col)
end

credits = {
	init = function()
		music(6)
		creditroll = 0
		credits = [[
   a game by

   urgurgurg



   testing by

    shuaevae
     shadow
     peter
    morbiose



    made in

  pico-8 0.2.7

      for

  heavyweight
    jam 2026
 "take control"




no gen ai was
used in the
creation of this
game. the
responsibility
is sadly all my
own.


]]
	end,

	update = function()
		creditroll += -0.25

		if creditroll < -300 or btnp(🅾️) then
			extcmd("shutdown")
		end
	end,

	draw = function()
		cls(0)
		spiral(32, 32, 40, 0.25, 1)

		print(credits, 0, 70 + creditroll, 7)

		--print(creditroll,0,0,10)
	end
}

function shakescreen(amt, tim)
	add(
		timed,
		cocreate(function()
			local a, t = amt, tim
			for i = 1, t do
				camshake = lerp(sin(time() * 3) * a, 0, i / t)
				yield()
			end
			camshake = 0
		end)
	)
end
-->8
--level logic

level = {
	init = function()
		set_up_pendulum()

		levinfo = levelscreeninfo[levelnum]
		eyex, eyey = 0, 0
		clockx, clocky = 0, 0
		bg_progress = 0
		progress = 0
		time_began = time()
		food_timer = 0
		food_interval = 30

		food = 0

		character_action = ""

		character_sprite = levinfo[2] - 98
		char_skin = levinfo[6]
		cs = { [4] = 2, [15] = 9, [9] = 4, [12] = 1 }
		char_shade = cs[char_skin]
		progress_loss = levinfo[4]

		food = 0
		food_target = levinfo[5]
		stuffed = 0

		--bg_col = levinfo[7]
		bg_col = 0
		eyeline_offset = levinfo[8]

		combo = 0

		charoffx, charoffy = 0, -12

		food_prompt = ""

		goals = {}

		food_routines = {}

		food_draws = {}

		goal_routes = levinfo[9]

		music(1)
		goal(0)
		
		--spawn_block()
	end,

	update = function()
		pendulum()

		food_timer += 1

		if food_timer > food_interval then
			food_timer = 0
			fire_food()
		end

		eyex = mid(-2, lerp(-2, 2, clockx / 64), 2)
		eyey = mid(-2, lerp(-2, 2, clocky / 32), 2)

		for g in all(goals) do
			if g.dead then
				del(goals, g)
			end
		end

		foreach(goals, gupdate)

		for e in all(encouragements) do
			if e.lifetime < 1 then
				del(e, encouragements)
			end
		end

		foreach(encouragements, eupdate)

		food_draws = {}
		foreach(food_routines, coresume)

		bg_progress -= progress_loss

		bg_progress = mid(0, bg_progress, 150)

		if progress < flr(bg_progress) then
			progress += 0.5
		elseif progress > flr(bg_progress) then
			progress -= 0.5
		end

		local stuffed_targ = ceil((food / food_target) * 100)

		if stuffed < stuffed_targ then
			stuffed += 0.5
		elseif stuffed > stuffed_targ then
			stuffed -= 0.5
		end

		stuffed = mid(0, stuffed, 100)

		progress = mid(0, progress, 150)

		food_prompt = "   " .. flr(min(100, progress)) .. "%   " .. flr((food / food_target) * 100) .. "%"

		if progress > 99 then
			food_interval = 15 - ((progress - 100) / 50) * 10
		else
			food_interval = 60 - ((progress / 100) * 30)
		end

		if food >= food_target then
			set_state(winscreen)
		end
		
		for b in all(blocks) do
			b:update()
		end
		
	end,

	draw = function()
		camera(0,0)
		cls(bg_col)

		local spircol = 13
		if progress > 75 then
			spircol = -1
		end
		spiral(32, 22-charoffx, 64, lerp(0.7, 0.1, progress / 100), spircol)

		character(character_sprite, charoffx, charoffy)

		foreach(goals, gdraw)

		for fd in all(food_draws) do
			fd()
		end

		foreach(encouragements, edraw)

		draw_pendulum()
		
		for b in all(blocks) do
			b:draw()
		end

		--bar at bottom
		
		local barcol =12
		
		if progress >=100 then
			barcol= rainbowish[1 + flr(time() * 2) % #rainbowish]
		end
		--rectfill(0,56,63,63,0)
		palt(11,true)
		sprite_outline_color = 7
		outlinespr(6,0,56)
		outlinespr(22,56,56)
		sprite_outline_color = 0
		
		rectfill(9,58,9+min(21,(progress/100)*21),61,barcol)
		rect(9,58,30,61,7)
		
		rectfill(55-((stuffed/100)*21),58,55,61,14)
		rect(33,58,55,61,7)
		
			--
			--[[
			rectfill(0,61,63,63,0)
			if progress<99 then
				rectfill(1,62,(progress/100)*62,63,8)
			else
			fillp(░)
			rectfill(1-(⧗*4),62-(⧗*4),62+(⧗*4),63+(⧗*4),11)
			fillp()
			rectfill(1-⧗,62-⧗,62+⧗,63+⧗,11)
			end
			]]

		--food prompt
--[[
		if progress < 100 then
			outlinespr(6, 0, 56)
			outlinespr(22, 55, 56)
			outlinespr(food_prompt, 5, 58, 7)
		else
			outlinespr(6, 0, 56 - (⧗ * 3))
			outlinespr(22, 55, 56 - (⧗ * 3))
			outlinespr(food_prompt, 5, 58 - (⧗ * 3), rainbowish[1 + flr(time() * 2) % #rainbowish])
		end
	
	]]--
	end
}

encouragements = {}

function goal(delay)
	timed_function(
		function()
			local g = {
				x = 4 + rnd(56),
				y = 8 + rnd(chainlen-4),
				s = 1,
				timer = 20 - min(combo / 2, 10),
				proxim = 64,
				dest = 0,
				hit = false,
				dead = false,
				dir = rnd {-1,1},
				route = rnd(goal_routes)
			}
			--printh("gentlemen you have a goal")
			add(goals, g)
		end, delay
	)
end

function gupdate(g)
	g.timer -= 0.05
	g.s = 2 + (g.timer / 4) + (sin(time()) * 2)
	local gx, gy, gs, gr,dir = g.x, g.y, g.s, g.route,g.dir
	local gpx = abs(gx - clockx)
	local gpy = abs(gy - clocky)

	g.proxim = (gpx + gpy) / 2

	local gproxim = g.proxim

	g.hit = (gproxim <= (g.s + 1))

	if gr == 1 then
		--across
		g.x = 32 + ((sin(time() / 3) * 32)*dir)
	elseif gr == 2 then
		--diagonal
		g.x += (sin(time() / 4) * 0.4)*dir
		g.y += sin(time() / 4) * 0.4
	elseif gr == 3 then
	--circle
		g.x += (sin(time() / 4) * 0.8)*dir
		g.y += (cos(time() / 4) * 0.8)*dir
	elseif gr==4 then
	--little across
		g.x+=(sin(time()/4)*0.2)*dir
end


	if g.hit then
		sfx(31)
		g.dest += 0.2
	end

	if g.dest >= 1 and g.dead == false then
		encouragetext()
		g.dead = true
		combo += 1
		bg_progress += 4 * (combo / 2)
		goal(5)
		sfx(31, -2)
		sfx(30)
	elseif g.timer < 0.01 and g.dead == false then
		g.dead = true
		combo = 0
		goal(33)
		bg_progress -= 5
	end
end

function gdraw(g)
	circfill(g.x, g.y, g.s - 3, 12)
	fillp(▒)
	circfill(g.x, g.y, g.s, 12)
	fillp()
	circfill(g.x, g.y, g.s * g.dest - 1, 7)
	spiral(g.x, g.y, g.s, 0.05, 7)
	--print(g.dest.."\n"..g.proxim,g.x,g.y,8)
	if g.hit then
		for i = 1.2, 2 * g.dest, 0.2 do
			circ(g.x, g.y, g.s * i, 10)
		end
	end
end

function fire_food()
	add(
		food_routines,
		cocreate(function()
			local sp = rnd { 177, 181, 185, 51 }
			local outcome = flr(rnd(4))
			local startx, starty = -3 + rnd(69), -3 + rnd(69)
			if outcome == 0 then
				startx = -32
			elseif outcome == 1 then
				startx = 64
			elseif outcome == 2 then
				starty = -32
			else
				starty = 64
			end
			local goalx, goaly = charoffx + 31, charoffy + 38
			local startsize, goalsize = 32, 0
			local will_succeed = (rnd(95) < progress)
			for i = 0, 1, 0.03 do
				if i > 0.5 then
					if character_action != "eating" then
						if will_succeed then
							character_action = "openmouth"
						else
							character_action = "grossedout"
						end
					end
				end
				add(
					food_draws,
					function()
						local sx, sy = spritecoords(sp)
						local size = lerp(startsize, goalsize, i)
						sspr(
							sx, sy, 8, 8,
							lerp(startx, goalx, i), lerp(starty, goaly, i),
							size, size
						)
					end
				)
				yield()
			end
			local bounce = false
			if character_action == "eating" then
				bounce = true
			elseif will_succeed then
				bounce = false
			else
				character_action = "grossedout"
				bounce = true
			end
			timed_function(
				function()
					character_action = ""
				end, 5
			)
			if bounce then
				local ang = rnd()
				local fx, fy = goalx, goaly
				for i = 0, 1, 0.05 do
					fx += sin(ang) * 4
					fy += abs(cos(ang) * 5)
					add(
						food_draws, function()
							spr(sp, fx, fy)
						end
					)
					yield()
				end
			else
				food += 1
				if progress < 100 then
					character_action = "eating"
				else
					character_action = "openmouth"
				end
			end
		end)
	)
end
-->8
--cutscene engine

scene = nil
cutscene_queue = {}
message = "ffff"
cutscene_bg = -1
cutscene_closeup = -1
cutscene_sprites = {}
skip_timer = 0
speaking_char = ""
name_x = 0
tail = {}
oldx, oldy, oldspr = 0, 0, 0
mx1, my1, mx2, my2 = 0, 0, 0, 0
spiraltrans=1
state_after_cutscene = main

function play_cutscene(str, st)
	if type(str) == "number" then
		str = level_cutscenes[str]
	end
	cutscene_queue = {}
	cutscene_sprites = {}
	state_after_cutscene = st
	local q = split(str, "\n")
	for k, v in pairs(q) do
		local tab = split(v, "|")

		--[[check if a message]]
		if #tab == 1 then
			local name, body = unpack(split(v, ":"))

			local words = split(body, " ")
			local lines = {}
			local current_line = "\b"
			local longest_line = 0

			for word in all(words) do
				local nl = current_line .. word .. " "
				if #nl > 14 then
					add(lines, current_line)
					local len = #current_line
					if len > longest_line then
						longest_line = len
					end
					current_line = word .. " "
				else
					current_line = nl
				end
			end

			add(lines, current_line)
			local len = #current_line
			if len > longest_line then
				longest_line = len
			end

			body = ""
			for l in all(lines) do
				local lin = ""

				for i = 1, #l do
					local let = l[i]

					if ord(let) >= 128 and ord(let) <= 153 then
						local voff = { "g", "h", "i", "j" }
						local tn = voff[1 + flr(sin(time() + i) * #voff)]
						local lookup = {
							["➡️"] = "\f8",
							["∧"] = "\f0",
							["▤"] = "\fa",
							["◆"] = "\fe",
							["▒"] = "\f7",
							["●"] = "\f3"
						}
						lin ..= lookup[let]
					else
						lin ..= let
					end
				end
				body ..= lin .. "\n"
			end

			cutscene_queue[k] = {
				"message",
				name,
				body,
				#name * 4,
				longest_line * 4,
				#lines * 6
			}
		else
			--[[not message]]
			cutscene_queue[k] = tab
		end
	end
	music(-1)
	set_state(cutscene)
end

cutscene = {
	init = function()
		scene = cocreate(function()
			skip_timer = 0
			for c in all(cutscene_queue) do
				message = ""
				speaking_char = ""
				name_x = 0
				tail = {}
				oldx, oldy, oldspr = 0, 0, 0
				mx1, my1, mx2, my2, top_x, top_x2 = 0, 0, 0, 0, 0, 0
				camshake = 0
				spiraltrans=1

				local action_finished = false

				local first, p1, p2, p3, p4, p5 = unpack(c)

				local timer = 0

				while not action_finished do
					timer += 1

					if btn(🅾️) then
						skip_timer += 1
					else
						skip_timer = 0
					end

					if skip_timer > 25 then
						return
					end
		
					if first == "message" then
						speaking_char = p1

						mx1 = 32 - ceil(p4 / 2)
						mx2 = ceil(p4) + 1
						my1 = 6
						--my2 = 6 + ceil(p5)+3
						my2 = ceil(p5) + 6

						if speaking_char == "sheila" then
							name_x = 2
						else
							name_x = 61 - p3
						end

						local charspr = cutscene_sprites[speaking_char]
						if charspr != nil then
							top_x = charspr[2]
							tail.x, tail.y = charspr[2] + 6, charspr[3] + 5
							if charspr[2] > 31 then
								tail.x -= 6
								top_x -= 10
							else
								top_x += 10
							end
							top_x = mid(mx1 + 3, top_x, mx2 - 8)
							top_x2 = top_x + 5
						else
							tail.x = 20
							tail.y = 67
							top_x = 35
							top_x2 = 40
						end

						message = sub(p2, 1, timer)
						action_finished = btnp(❘)
					elseif first == "bg" then
						cutscene_closeup = -1
						cutscene_bg = p1
						cutscene_sprites = {}
						sfx(-1)
						action_finished = true
					elseif first == "wait" then
						action_finished = (timer > p1)
					elseif first=="trans" then
						spiraltrans-=0.025
						action_finished = (spiraltrans<0.025 or btnp(❘))
					elseif first == "closeup" then
						cutscene_closeup = p1
						action_finished = (timer > 30 or btnp(❘))
					elseif first == "spr" then
						cutscene_sprites[p1] = { p2, p3, p4, 1, 2, false, false }
						action_finished = true
					elseif first == "sfx" then
						sfx(p1)
						action_finished = true
								
					elseif first=="music" then
						music(p1)
						action_finished=true
					elseif first == "shake" then
						shakescreen(p1, p2)
						action_finished = true
					elseif first == "flp" then
						cutscene_sprites[p1][6] = not cutscene_sprites[p1][6]
						action_finished = true
					elseif first == "move" then
						if oldspr == 0 then
							oldx = cutscene_sprites[p1][2]
							oldy = cutscene_sprites[p1][3]
							oldspr = cutscene_sprites[p1][1]

							if oldx <= p2 then
								cutscene_sprites[p1][6] = false
							else
								cutscene_sprites[p1][6] = true
							end
						end

						local l = timer / p4

						cutscene_sprites[p1][2] = lerp(oldx, p2, l)
						cutscene_sprites[p1][3] = lerp(oldy, p3, l)
						cutscene_sprites[p1][1] = oldspr - flr(sin(time() * 3))

						if timer > 10 and btn(❘) then
							timer += 2
						end

						if timer > p4 then
							cutscene_sprites[p1][1] = oldspr
						end

						action_finished = (timer > (p4 + (p4 / 10)))
					elseif first == "end" then
						return
					end
					yield()
				end
			end
		end)
	end,

	update = function()
		if costatus(scene) != "dead" then
			coresume(scene)
		else
			set_state(
				--[[,"spiral"]]
				state_after_cutscene)
		end
	end,

	draw = function()
		cls(0)
		camera(camshake, camshake)

		--map
		if cutscene_bg != -1 then
			map(cutscene_bg, 0, 0, 0)
		end

		palt(11, true)
		palt(0, false)

		for k, v in pairs(cutscene_sprites) do
			outlinespr(unpack(v))
		end

		--close-ups
		if cutscene_closeup != -1 then
			rectfill(4, 25, 60, 62, 0)
			spr(cutscene_closeup, 16, 30, 4, 4)
			rect(4, 25, 60, 62, 7)
		end

		camera(0, 0)
		--dialogue
		if message != nil and message != "" then
			rrectfill(mx1, my1, mx2, my2, 4, 7)
			rrect(mx1, my1, mx2, my2, 4, 0)
			print("\#0" .. speaking_char .. ":", name_x, 1, 10)
			print(message, mx1 + 3, my1 + 3, 0)
			--line(29,my2+4,34,my2+4,7)

			if tail != {} and tail != nil and cutscene_closeup == -1 then
				if tail.y != nil and my2 < tail.y then
					for i = top_x, top_x2 do
						line(i, my2 + 5, tail.x, tail.y, 7)
					end

					line(top_x, my2 + 5, tail.x, tail.y, 0)
					line(top_x2, my2 + 5, tail.x, tail.y, 0)
				end
			end
		end

	if spiraltrans<1 then
		if spiraltrans<0.025 then
			rectfill(0,0,63,63,0)
		else
		spiral(32,32,40,spiraltrans)
	end
end
		
		
		if skip_timer > 0 then
			rectfill(18, 54, 60, 64, 0)
			rectfill(19, 62, lerp(18, 59, skip_timer / 25), 62, 8)
			rect(19, 61, 59, 63, 8)
			print("🅾️ SKIPPING", 18, 55)
		end
		
		
	end
}

-->8
--screens

winscreen = {
	init = function()
		local te = flr(time() - time_began)
		time_end = flr(te / 60) .. "M" .. flr(te % 60) .. "S"
		character_action = "queasy"
		progress = 0
		eyex, eyey = 0, 0
		stuffed = 100
		music(9)
		wait_to_proceed()
	end,

	update = function()
		if btnp(❘) and can_proceed then
			levelnum += 1
			dset(0, levelnum)
			local nextscr = main
			if levelnum > #levelscreeninfo then
				nextscr = credits
				dset(0, 1)
			end

			play_cutscene(level_cutscenes[levelnum], nextscr)
		end
	end,

	draw = function()
		cls(10)
		fillp(▒)
		circfill(30, 60, 40 + (⧗ * 20), 8)
		fillp()
		palt(0, false)
		palt(11, true)
		character(character_sprite, 0, -12)
		outlinespr("level complete\n  time: " .. time_end, 5, 5 + (⧗ * 4), 11)
	end
}

title = {
	init = function()
		music(5)
		wait_to_proceed()
	end,

	update = function()
		if btnp(❘) and can_proceed then
			--play_cutscene(intro_cutscene,main)
			play_cutscene(level_cutscenes[levelnum], main)
		end
	end,

	draw = function()
		cls()
		--map()
		spiral(50, 10 + (⧗ * 2), 40, 0.3, 1)
		outlinespr(11, 50, 10, 1, 2, true)

		outlinespr(valspr, 10, 30, 1, 2, true)
		outlinespr(aikospr, 30, 33, 1, 2)
		outlinespr(calispr, 50, 30, 1, 2)

		outlinespr("\^w\^thypno\n sis", 12, 6 + (sin(time() / 2) * 2), 10)
	end
}

levelscreeninfo = {
	[1] = {
		"valerie",
		162,
		"FONDEST WISH:\nA SEVENTEEN\n-STATE SOLUTION.",
		0.01,
		50,
		4,
		1,
		3,
		{ 0 }
	},

	[2] = {
		"aiko",
		166,
		"CAREER GOAL:\nHISTORY'S FINAL\nFEMALE PRESIDENT.",
		0.07,
		100,
		12,
		5,
		6,
		{ 0, 1, 0, 0, 0, 2, 1, 0 ,4,0,0}
	},

	[3] = {
		"calliope",
		170,
		"FORMER TITLES:\nMISS UNIVERSE\nMISS MULTIVERSE\nMISS TIME-TRAVEL\nMISS MARPLE\nMISS SPENT YOUTH",
		0.12,
		200,
		9,
		2,
		6,
		{ 0, 1, 2, 3, 4 ,1,2,3,4}
	}
}

campan = 0
anim = nil

main = {
	init = function()
		music(5)
		anim = cocreate(function()
			campan = 0
			for i = -20, 0 do
				campan = i
				yield()
			end
		end)
		wait_to_proceed()
	end,


	update = function()
		coresume(anim)

		if btn(❘) and can_proceed then
			set_state(level)
		end
	end,

	draw = function()
		local n, s, t = unpack(levelscreeninfo[levelnum])
		cls(3)
		camera(0, campan)
		fillp(▤)
		circfill(32, 60, 45, 11)
		fillp()
		print("level " .. levelnum, 18, 2, 1)
		outlinespr("target: " .. n, 2, 10, 7)
		outlinespr(s, 28, (⧗ * 1.6) + 15 + (campan * 0.7), 1, 2)
		print("\#0" .. t, 1, 34, 7)
	end
}
-->8
---cutscenes

level_cutscenes = {
	[[
bg|0
spr|sheila|42|10|30
sfx|7
move|sheila|25|30|30
sheila: i've got this pageant in the bag
move|sheila|20|30|6
closeup|200
judge 1: wow, that ballgown is a ten out of ten
sheila: ha, knew it. they're eating me up!
closeup|-1
judge 2: it's just such a shame that she decided to ruin it's silhouette...
sheila: whuh?? what are they whispering about?
judges: MUTTER MUTTER belly MUTTER
sheila: w-what's going on?
judges: MUTTER pregnant?? MUTTER MUTTER
sheila: oh no. oh please no...
shake|3|15
sfx|1
closeup|204
sheila: those damned croissants backstage...
sheila: they were in the bag. a-and i ate them up!!
closeup|-1
judges: MUTTER MUTTER MUTTER ahem!
judge: 5.5 points!
sheila: nooo *sob*
move|sheila|-8|30|30
judge: next girl please!!
music|10
bg|28
sheila: grrr, how can this be happening to me?!!
sheila: i ➡️know∧ it was those other jealous bitches...
bg|8
spr|sheila|9|-8|40
move|sheila|10|40|20
sheila: they knew about my ibs and affinity for laminated pastry!
sheila: they ➡️kneeeeww∧!!
move|sheila|8|41|5
sheila: *sniff*. at least i'm the first one back in the green room.
sheila: it gives me a chance to root around the stuff those woo-woo conference people left in the corner.
move|sheila|30|35|15
closeup|192
sheila: what on earth's this...
sheila: "hypnosis for bimbos"
sheila: this could be just what i need!
sheila: i'll hypnotize my competition! get them ➡️all∧ to stuff their faces before the next round!
sheila: it's just foolproof enough to work!!!
closeup|196
sheila: okay, lets' see here...
sheila: it says here the first step is to obtain an old-timey pocket-watch...
sheila: (GOOD JOB I JUST DID THE MS STEAMPUNK PAGEANT LAST WEEK)
sheila: and the second step is to swing said pocket watch back and forth in front of your victim's dumb face.
sheila: and... and that's actually pretty much it!
sheila: wow, it's even simpler than i thought. this'll be a piece of cake.
sheila: speaking of... let's test this out!!
closeup|-1
spr|valerie|162|70|40
move|valerie|40|40|30
valerie: hey sheila? you alright back here?
valerie: that was fucked up what the judges said to you!
valerie: food-babies are a natural part of life! haven't those asshats seen a single instagram post.
sheila: that's ◆so sweet∧ of you to say, valerie
sheila: almost as sweet as the baked goods you ➡️deliberately placed in my path∧ to ➡️sabotage∧ me!!
valerie: oh? you mean the croissants i baked for the tech crew? i ... um... glad you liked them?
sheila: they were ➡️diabolical!∧
valerie: WELL YOU DIDN'T HAVE TO EAT SIXTEE-
valerie: *ahem* anyway, i feel for you, hon!
valerie: especially since the swimsuit round is up next...
valerie: just bad timing i guess, huh?
sheila: oh don't you worry about my timing, val.
sheila: my timing is ◆just fine∧.
sheila: in fact. take a look at ◆my fancy, fancy new watch.∧
spr|sheila|11|30|34
wait|1
spr|sheila|11|30|35
wait|1
spr|sheila|11|30|36
wait|1
spr|sheila|11|30|35
valerie: umm... cool?
sheila: you are getting hungry!
sheila: verrrryyy ➡️huuungrryyyy∧
trans|17]],

	--[[1 --before fighting aiko]]
	[[
bg|10
music|15
spr|valerie|131|30|40
spr|sheila|11|22|40
flp|valerie
valerie: *buurrp* ughh... i'm soooo full
valerie: but... everything you're offering me is so...
valerie: *groan*... tempting... i just...
spr|aiko|166|70|40
aiko: oh em gee! val!!
move|aiko|35|45|30
aiko: what ➡️happened∧ to her??
sheila: oh... uhh...
spr|sheila|9|22|40
sheila: she just went ●crazy∧ and started eating ➡️food∧!!
sheila: and i tried to stop her! i was like "stop somehow finding and consuming all that food"
sheila: but she wouldn't listen because of how ●crraaazy∧ she went!
aiko: ...
sheila: it was ●crazy∧, aiko!!
aiko: it sounds like you're in some shock too, sheila.
aiko: val, don't worry. i'll grab my car keys, let's get you to a hospital!
move|aiko|45|45|15
sheila: hospital? b-but what about the curtain call?
flp|aiko
aiko: oh you're right!
aiko: tell the organizers where we are! they'll have to do the next round without us.
music|10
sheila: you're ➡️dropping out∧??
aiko: sheila i ●know∧ you want to take her yourself. but you're in ●shock∧!
sheila: uh... right. right.
sheila: true.
sheila: i would... ➡️totally∧ sacrifice my chance of getting that tiara if not for all the... shock.
aiko: we all would, sheils. that's what pageant girls ➡️do∧!
aiko: i know how reality tv likes to depict us...
aiko: but you know as well as i that we are a ➡️sisterhood∧!
aiko: and looking after each other comes first!
sheila: wow. that's... really kind of... cool of you.
sheila: i... uh... you'd better go get those keys.
aiko: right! be back in a flash, val!
valerie: ughhh...tummy feel baad...
aiko: understood. i'll try not to hit any potholes.
sheila: godspeed you noble goddess.
move|aiko|58|40|15
flp|sheila
sheila: I GUESS I CAN WIN WITHOUT INFLICTING TORTURE ON ➡️EVERYONE∧...
flp|aiko
aiko: i just feel bad for you and calliope.
flp|sheila
aiko: the stage'll feel kind of empty with just the two of you.
aiko: might make the victory feel less impressive.
sheila: oh damn! good point!
move|sheila|52|40|5
spr|sheila|11|50|40
aiko: what the-
sheila: ➡️look into my eeeyyyeeesss∧
trans|17]],
	--[[2 --- before fighting calliope]]
	[[
bg|11
spr|valerie|131|20|40
spr|aiko|135|40|40
spr|sheila|11|30|43
flp|aiko
music|15
sheila: yesss! ➡️feed∧! ➡️consume∧!!
aiko: where are you even... *urp*... getting all this pizza?
sheila: silence, thrall! now bark like a chicken!!
aiko: uhhh... CLUCK? WOOF? clu-oof?
valerie: it could be woo-uck?
sheila: okay discuss it amongst yourselves.
sheila: have your findings on my desk by five.
valerie: yes mistress.
aiko: yes mistress.
sheila: now where's that calliope...
sheila: it's time to keep rounding out this line-up...
spr|sheila|9|30|43
move|sheila|70|35|35
bg|20
spr|sheila|9|48|33
spr|calliope|170|7|43
flp|calliope
move|sheila|48|43|30
flp|sheila
sheila: and so it comes down to this.
sheila: i know it was valerie who baked the croissants.
move|sheila|32|43|15
sheila: i know it was aiko who started the tradition of giving gifts to the tech peons.
move|sheila|27|43|15
sheila: but the one thing i just couldn't figure until now...
sheila: how did that first tantalizing pastry end up on my make-up table?
move|sheila|20|43|15
sheila: who knocked over that first domino?
calliope: i.. don't deny it.
sheila: it's alright, calliope. i understand why you did it.
spr|sheila|11|27|39
wait|1
spr|sheila|11|27|41
wait|1
spr|sheila|11|27|43
flp|sheila
calliope: you... do?
sheila: you and i. we're alike. we think the same way.
calliope: we... do?
sheila: we ●feel∧ the same way about ●each other∧.
calliope: OH MY GOD...
sheila: and we both know what it means to be ➡️fixated∧ on our desires.
calliope: it's just... you're so... perfect...
sheila: shhh, i know. and you were intimidated.
calliope: i was so scared of not measuring up.
sheila: so you planted the croissant...
calliope: YES.
sheila: because you're ➡️obsessed∧ with me.
calliope: YES...*whimper*
sheila: and even though i've always placed below you, ➡️you∧ saw my potential.
sheila: and deep down you just wanted me to suf-
flp|calliope
music|19
calliope: ◆be happy!!∧
calliope: i admit it. i admit it! i'm so sorry, sheila!
calliope: i didn't mean to trigger a binge! i had no idea...
calliope: i just... know you love val's baking.
calliope: and i... didn't want you to miss out.
sheila: ... uhh.
move|calliope|15|43|15
calliope: i've yearned for you ever since the first time we competed.
calliope: it's... it's been so painful to carry around.
calliope: i never dared to imagine you might... ◆love me back∧.
sheila: uuuuhhhhhhhh
calliope: although...
calliope: i guess i ➡️might∧ have twigged sooner if i'd seen how masc your taste in jewelry was.
calliope: that pocket watch is ◆so∧ fucking butch, babe. i love it.
move|calliope|8|43|15
calliope: wait. wait. shit. i'm sorry, it's too soon for babe
flp|calliope
calliope: b-but we should go on a date!! th-there's this cafe near the hotel...
calliope: it does these ◆adorable∧ little pastries and...
calliope: and you... look... confused.
calliope: ...
calliope: OH FUCK.
calliope: so i..um... seem to have got the wrong idea and... um..
calliope: *choke* oh shit. fuck. um... man. *sigh*
calliope: can we maybe just... forget this conversation happened?
sheila: eh, ➡️you∧ certainly can.
spr|sheila|11|10|43
wait|1
spr|sheila|11|11|43
sheila: ooga booga, hypno powers activate!!
trans|17]],
	--[[3 --- ending]]
	[[
bg|0
music|15
spr|sheila|9|20|27
spr|2|131|30|28
spr|3|135|40|27
spr|4|139|50|28
judge: welcome back, ladies!
judge: our next round is a very special one!
sheila: ESPECIALLY FOR ME!!!
closeup|76
sheila: hee heee, look at these bloated sows!
sheila: why compared to them my paltry pastry paunch looks at svelte as a...
sheila: ... belt??!
sheila: should probably stop muttering to myself while the judges are talking...
closeup|-1
judge: that's right folks, because this round will be ➡️entirely∧ judged by our ●special celebrity guest∧!!
judge: everybody give a warm welcome to...
closeup|140
music|10 
judge: world-famous gaming streamer and noted chubby chaser ●fuegoskeptical∧ !!!!
fuegoskeptical: i love fat biiitcheees!!
closeup|-1
spr|sheila|41|20|25
wait|3
spr|sheila|41|20|26
wait|1
spr|sheila|41|20|27
wait|1
sheila: noooooooooooooo!!
]]
}

-->8
--mental block

blocks={}

function spawn_block()

	add(blocks,
	{
		x=10 + rnd(43),
		y=20,
		timer=0,
		
		update=function(self)
			self.timer+=0.1
		end,
		
		draw=function(self)
		local x,y,t = self.x,self.y,self.timer%3
		fillp(▒)
			for i=5,40 do
				local l = 3 + rnd(6)
				local r = -1+rnd(2)
				line(x,y,
				x+(sin(r)*l),
				y+(cos(r)*l),rnd {1,2})
			end
			
			line(x-t,y-6-(t/3),x-t,y+6+(t/3),14)
		line(x+t,y-6-(t/3),x+t,y+6+(t/3),14)
			fillp()
			line(self.x,self.y-5,self.x,self.y+5,14)
		end,
		})

end