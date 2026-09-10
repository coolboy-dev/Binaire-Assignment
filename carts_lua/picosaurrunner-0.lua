--picosaur runner
--by ry.s

function _init()
	gravity=.5
	speed=0
	acceleration=0.0015
	maxaccel=5
	ground={
		x=0,
		y=77,
		gy=87 --y visual
	}
	groundtiles={}
	
	score=0
	highscore=0
	currentscore=flr(score)
	
	istart()
	iobs()
	idino()
	ianim()
	
	mode="start"
	
	ground_form(8)
end


function _update()
	cloud_anim()
	
	if mode=="start" then
		ustart()
	elseif mode=="game" then
		ugame()
	elseif mode=="dead" then
		udead()
	end
end


function _draw()
	cls(7)
	map()
	
	for acloud in all(clouds) do
		spr(acloud.n,acloud.x,acloud.y,2,1,acloud.f)
	end
	
	if mode=="start" then
		dstart()
	elseif mode=="game" then
		dgame()
	elseif mode=="dead" then
		ddead()
	end
end


function collision(r1,r2)
	if  r1.x < r2.x+r2.w
	and r1.x+r1.w > r2.x
	and r1.y < r2.y+r2.h 
	and r1.y+r1.h > r2.y then  
		return true
	else
		return false
	end
end
-->8
--player

function idino()
	dino={
		x=15, 
		y=ground.y,
		xvel=0,
		yvel=0,
		jump=5.3,
		fall=1.25,
		--dinosaur action status
		act="m",
		--i=idle
		--m=moving
		--j=jump
		--c=crouch
		alive=true
		}
		--sprite table
	dino.sp={}
		dino.sp.n=1
		dino.sp.w=2
		dino.sp.h=2
	
	dino.h={}
	
	--[[
	buffer data for when the
	player presses crouch +
	jump	at the same time]]
	crouch_check=false
		--[[this actually checks if 
						crouching *and* jumping]]
	cb_time=3
	cbuffer=cb_time
	
	jump_check=false
end

--update function for dino--
function udino()
	dino.yvel+=gravity
	dino.y+=dino.yvel
	
	--ground detection
	if dino.y>ground.y then
		dino.y = ground.y
		dino.yvel=0
		--only for start of game
		if dino.act~="i" then
			dino.act="m"
		end
	end
	
	--collision
	if dino.act=="m" then
		dino.h.x=dino.x+3
		dino.h.y=dino.y+3
		dino.h.w=8
		dino.h.h=10
	elseif dino.act=="j" then
		dino.h.x=dino.x+4
		dino.h.y=dino.y+1
		dino.h.w=7
		dino.h.h=8
	elseif dino.act=="c" then
		dino.h.x=dino.x+5
		dino.h.y=dino.y+8
		dino.h.w=9
		dino.h.h=7
	end
	
	
	
	--checks if jump buttons held
	if (btn(❘) or btn(⬆️)) then
		jump_check=true
	else
		jump_check=false
	end
	
	--player controller--
	if (btn(🅾️) or btn(⬇️)) and dino.act=="m" then
	--[[prevents crouch anim ^
					in air]]
		crouch()
	elseif (btn(❘) or btn(⬆️)) and dino.act=="m" then
		if crouch_check==false then
			jump(dino.jump)
		end
	--[[checks if the player
					is currently crouching]]
	elseif dino.act=="j" and (btn(🅾️) or btn(⬇️)) then
		dino.yvel+=dino.fall
		dino.h.h=12
		sfx(2)
	--[[accelerate down when 
					crouching in air]]
	elseif not jump_check
	and dino.act=="j" 
 and dino.yvel<0
	then

			if dino.yvel<-0.75 then
				dino.yvel=-0.75
			else
				dino.yvel=0
			end

	--[[stops velocity when not 
					jumping (checks if jump 
					button is pressed, if 
					dinos in j status {prob 
					not needed lol} and if 
					velocity is less than 0 
					{meaning the players jump 
					hasnt peaked}) ]]
	end
	
	--checks if crouching
	if crouch_check and not (btn(❘) or btn(⬆️))	 then
		crouch_check=false
		cbuffer=cb_time
		--resets crouch check+buffer
	elseif (btn(❘) or btn(⬆️)) and dino.act=="c" then
		crouch_check=true
		cbuffer-=1
			if cbuffer>0 then
				crouch_check=false
			elseif cbuffer<0 then
				cbuffer=0
			end
	--[[if crouching and pressing 
					jump button, disallows 
					jump if the buffer has 
					ended]]
	end
	
end



function ddino()
	spr(dino.sp.n,dino.x,dino.y,dino.sp.w,dino.sp.h)
	
end


function jump(h)
	dino.act="j"
	
	dino.yvel-=h
	
	cbuffer=cb_time
	sfx(0)
end


function crouch()
	dino.act="c"
	if not (btn(❘) or btn(⬆️)) then
		cbuffer=cb_time
	end
	if speed>=3 then
		sfx(1)
	end
	--!!!insert hitbox change!!!
end
-->8
--obstacles
function iobs()
	obs={
	x=128,
	y=76
	}
	obs.h={}
	obs.timer=1
	
end


function uobs()
	--[[varies the obstacle spawn 
					interval depending on the 
					speed of the game]]
	if speed<3.5 then
		obs.time=flr(rnd(52))+(26-(speed*2.5))
	elseif speed<5 then
		obs.time=flr(rnd(47))+(26-(speed*4))
	else
		obs.time=flr(rnd(47))+8
	end
	birdsp=rnd(1.5)
	
	for anobs in all(obs) do
		--movement of obstacles
		if anobs.n==72 or anobs.n==74 then
			anobs.x-=speed+birdsp
			anobs.h.x-=speed+birdsp
		else
			anobs.x-=speed
			anobs.h.x-=speed
		end
		
		--collision check
		if	collision(dino.h,anobs.h) then
			dino.alive=false
		end
		
		--culling
		if anobs.x<-16 then
			del(obs,anobs)
		end
	end

end


function dobs()
	for anobs in all(obs) do
		spr(anobs.n, anobs.x, anobs.y,2,2)
	end
end


function create_obs(l)
	local v = flr(rnd(4))
	local newobs={}
 newobs.h={}
	if v==3 then
		if l>0 then
		--birds
			newobs.n=72
			newobs.x=obs.x
			newobs.y=rnd(33)+50
			
				newobs.h.x=newobs.x+1
				newobs.h.y=newobs.y+2
				newobs.h.w=13
				newobs.h.h=6
		else
		--cactus 1 of 2
			newobs.n=64
			newobs.x=obs.x
			newobs.y=obs.y
			
				newobs.h.x=newobs.x+3
				newobs.h.y=newobs.y+2
				newobs.h.w=9
				newobs.h.h=13
		end
	elseif rnd(1) > 0.9 then
	--bush
		newobs.n=70
		newobs.x=obs.x
		newobs.y=obs.y
		
			newobs.h.x=newobs.x+4
			newobs.h.y=newobs.y+5
			newobs.h.w=6
			newobs.h.h=9
	elseif v==2 then
	--cactus 2 of 2
		newobs.n=64
		newobs.x=obs.x
		newobs.y=obs.y
			
			newobs.h.x=newobs.x+3
			newobs.h.y=newobs.y+2
			newobs.h.w=9
			newobs.h.h=13
	elseif v==1 then
	--2 cacti
		newobs.n=66
		newobs.x=obs.x
		newobs.y=obs.y
			
			newobs.h.x=newobs.x+2
			newobs.h.y=newobs.y+3
			newobs.h.w=11
			newobs.h.h=12
	elseif v==0 then
	--3 cacti
		newobs.n=68
		newobs.x=obs.x
		newobs.y=obs.y
		
			newobs.h.x=newobs.x+1
			newobs.h.y=newobs.y+11
			newobs.h.w=13
			newobs.h.h=8
	end
	add (obs,newobs)
end

function small_obs()
 local sv=flr(rnd(3))
	
end
-->8
--animation

function ianim()
	a={}
		a.m={}
		a.m.time=4
		a.m.timer=1
		a.m.check=false
		a.c={}
		a.c.check=false
		
	birdtime=7
	birdtimer=1

	blinktime=10
	blinktimer=blinktime
	
	bg={}
	bg.x=0
	bg.y=53
	
	clouds={}
	clouds.x=127
	clouds.timer=1
	clouds.time=flr(rnd(50))+100
end


function uanim()
	if dino.act=="i" then
		anim_i()
	elseif dino.act=="m" then
		anim_m()
	elseif dino.act=="j" then
		anim_j()
	elseif dino.act=="c" then
		anim_c()
	end
	
	bg_anim()
	ground_anim()
	bird_anim()
	
end


function danim()
	for atile in all(groundtiles) do
		spr(atile.n,atile.x,atile.y,2,1)
	end
	spr(144,bg.x,bg.y,16,3)
	spr(144,bg.x+128,bg.y,16,3)
	
end


function bird_anim()
	if birdtimer<0 then
		birdtimer=birdtime
		for anobs in all(obs) do
			if anobs.n==72 then
				anobs.n=74
				birdtime=3
			elseif anobs.n==74 then
				anobs.n=72
				birdtime=14
			end
		end
	else
		birdtimer-=1
	end
end


function blink_anim()
	if blinktimer<0 then
		blinktimer=blinktime
		if dino.sp.n==45 then
			dino.sp.n=1
			blinktime=8
		elseif dino.sp.n==1 then
			dino.sp.n=45
			blinktime=40
		end
	else
		blinktimer-=1
	end
end


function anim_i()
	dino.sp.n=1
	a.m.check=false
	a.c.check=false
end

function anim_m()
	a.c.check=false
	
	if not a.m.check then
		a.m.timer=1
		a.m.check=true
	end
	
	a.m.timer-=1
	
	if speed>2.5 then
	a.m.time=3
	elseif speed>3 then
	a.m.time=2
	end
	--[[changes speed of anim
	 			based on game speed]]
	
	if a.m.timer==0 then
		if dino.sp.n==3 then
			dino.sp.n=5
			a.m.timer=a.m.time
		else
			dino.sp.n=3
			a.m.timer=a.m.time
		end
	end
end

function anim_j()
	dino.sp.n=9
	a.m.check=false
	a.c.check=false
end

function anim_c()
	a.m.check=false

	if not a.c.check then
		a.m.timer=1
		a.c.check=true
	end
	
	a.m.timer-=1
	
	if speed>2.5 then
	a.m.time=3
	elseif speed>3 then
	a.m.time=2
	end
	--[[changes speed of anim
	 			based on game speed]]
	
	if a.m.timer==0 then
		if speed<3 then
			if dino.sp.n==43 then
				dino.sp.n=41
				a.m.timer=a.m.time
			else
				dino.sp.n=43
				a.m.timer=a.m.time
			end
		else
			if dino.sp.n==11 then
				dino.sp.n=7
				a.m.timer=a.m.time
			else
				dino.sp.n=11
				a.m.timer=a.m.time
			end
		end
	end
end


function ground_form(a)
	for i=0, a-1, 1 do
		local tile={}
		local t=flr(rnd(22))
		if t<19 then
			if t<9 then
				tile.n=33
				tile.x=ground.x+(i*16)
				tile.y=ground.gy
			else
				tile.n=35
				tile.x=ground.x+(i*16)
				tile.y=ground.gy
			end
		elseif t==20 then
			tile.n=37
			tile.x=ground.x+(i*16)
			tile.y=ground.gy
		else
			tile.n=39
			tile.x=ground.x+(i*16)
			tile.y=ground.gy
		end
		add(groundtiles,tile)
		--[[creates 'a' tiles at
						ground.x, determines
						which tile it will be
						based on rnd value:
						0-10 are 50/50 normal
						tiles and 11 + 12 are
						special tiles]]
	end
end


function ground_anim()
	ground.x-=speed
	if ground.x<0 then
		local xx=ground.x
		--[[for any speed values that
						do not evenly turn 
						ground.x into 0, it saves 
						the	amount	ground.x 
						surpasses 0 {xx} and adds
						that amount to ground.x
						when it loops for a 
						seamless loop of ground. 
						
						this does	sometimes cause
					 a flicker at the right
					 edge of the screen but
					 it works well enough
					 and i cant think of
					 a better solution :p ]]
		if xx<0 then
			ground.x=127+xx
		else
			ground.x=127
		end
		ground_form(8)
	end
	
	--renders and culls ground
	for atile in all(groundtiles) do
		atile.x-=speed
		if atile.x<-16 then
			del(groundtiles,atile)
		end
	end
end


function death_anim()
	if youdied>0 then
		spr(104,31,35,8,2)
		youdied-=1
	elseif youdied==0 then
		spr(96,31,35,8,2)
	end
end


function bg_anim()
	bg.x-=(speed/4)
	if bg.x<-128 then
		local xx=(bg.x+128)
		if xx<0 then
			bg.x=0+xx
		end
	end
end


function cloud_anim()
	if clouds.timer<0 then
		clouds.timer=flr(rnd(20))+75
		cloud_gen()
	else
		clouds.timer-=1
	end
	
	for acloud in all(clouds) do
		acloud.x-=(acloud.speed+(speed/8))
		if acloud.x<-16 then
			del(clouds,acloud)
		end
	end
end

function cloud_gen()
	local c=flr(rnd(5))
	local s=(rnd(1)+0.1)/4
	local f=flr(rnd(1))
	local newcloud={}
	newcloud.x=clouds.x
	newcloud.y=flr(rnd(63))
	newcloud.speed=s
	if c==0 then
		newcloud.n=128
	elseif c==1 then
		newcloud.n=130
	elseif c==2 then
		newcloud.n=132
	elseif c==3 then
		newcloud.n=134
	elseif c==4 then
		newcloud.n=136
	end
	if f>0 then
		newcloud.f=true
	else
		newcloud.f=false
	end
	add(clouds,newcloud)
end
-->8
--overall
function istart()
	game_check=true
	death_check=true
	death_buffer=50
	
	score_anim_timer=12
end

function ustart()
	if (btn(❘) or btn(⬆️)) then
		mode="game"
	end
		blink_anim()
end

function ugame()
	if game_check then
		score=0
		speed=2
		dino.alive=true
		
		jump(dino.jump)

		for anobs in all(obs) do
			del(obs,anobs)
		end
		
		game_check=false
	end
	
	speed+=acceleration
	if speed>maxaccel then
		acceleration=0
		speed=maxaccel
	end
	
	if obs.timer>0 then
		obs.timer-=1
	else
		if score<125 then
			create_obs(0)
			obs.timer=obs.time
		else
			create_obs(1)
			obs.timer=obs.time
		end
	end
	
	if highscore<=score then
		highscore=flr(score)
	end
	
	currentscore=flr(score)
	
	udino()
	uobs()
	uanim()
	
	if not dino.alive then
		mode="dead"
	else
		score+=0.25
	end
	
	death_check=true
	death_buffer=33
	youdied=6
end

function udead()
	if death_check and dino.alive==false then
		dino.sp.n=76
		death_check=false
		dino.yvel=0
		jump(3.5)
		speed=0
		sfx(3)
	end
	
	if currentscore>=highscore then
		highscore=currentscore
	end
	
	dino.yvel+=gravity
	dino.y+=dino.yvel
	
	--ground detection
	if dino.y>ground.y then
		dino.y = ground.y
		dino.yvel=0
		--only for start of game
		if dino.act~="i" then
			dino.act="m"
		end
	end
	
	if death_buffer>0 then
		death_buffer-=1
	else
		if (btn(❘) or btn(⬆️)) then
			mode="game"
		end
		dino.sp.n=13
	end
		
	game_check=true
	
end


function dstart()
	danim()
	ddino()
	
	spr(194,3,23,4,4)
	
	print("press ❘ or ⬆️ to start",29,25,7)
	print("❘/⬆️ to jump",39,42)
	print("🅾️/⬇️ to duck")
	
	print("press ❘ or ⬆️ to start",28,24,6)
	print("❘/⬆️ to jump",38,41)
	print("🅾️/⬇️ to duck")
end

function dgame()
	danim()
	dobs()
	ddino()
	
	local sc=flr(score)
	score_mod=flr(score)-flr(score)%100
	if sc%100<12 and score_mod~=0 then
		sc=score_mod
		if flr((score%100)%3)==(0 or 1) then
			print("",7,23)
		else
			print(sc,7,23,5)
		end
	else
		print(flr(score),7,23,5)
	end
	
	print(highscore,6)
	
	
end

function ddead()
	danim()
	dobs()
	
	bird_anim()
	for anobs in all(obs) do
		--movement of obstacles
		if (anobs.n==72 or anobs.n==74) then
			anobs.x-=speed
			if anobs.x<-16 then
				del(obs,anobs)
			end
		end
	end
	
	spr(dino.sp.n,dino.x,dino.y,3,2)
	
	death_anim()
	
	print("your score: "..currentscore,34,68,7)
	print("your score: "..currentscore,33,67,5)
	if currentscore>=highscore then
		print("-new high score!-",28,76,7)
		print("-new high score!-",27,75,6)
	end
	
	
	if death_buffer==0 then
		print("press ❘ or ⬆️ to reset", 18, 57, 7)
		print("press ❘ or ⬆️ to reset", 17, 56, 5)
	end
	
end