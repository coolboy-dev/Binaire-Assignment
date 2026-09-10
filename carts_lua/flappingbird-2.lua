--flapping bird

function _init()
 gravity = .25
 groundy = 103
 score = 0
 
 pipes={}
 
 ianim()
 ibird()
 ipipe()
 
 mode="start"
 death_check=true
 game_check=true
end


function _update()
	uanim()
	if mode=="start" then
		ustart()
	elseif mode=="game" then
		ugame()
	elseif mode=="dead" then
		udead()
	end
end



function _draw()
	cls(12)
	map()
	
	if mode == "start" then
		dstart()
	elseif mode =="game" then
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

function ibird()
--player init
	bird={--table of player traits
	x=31,
	y=63,
	xvel=0,
	yvel=0,
	jump=2.7,
	sprite=1,
	alive=true
	}

	bird.h={
		x=bird.x,
		y=bird.y+2,
		w=7,
		h=5
	}
	--bird hitbox

end


function ubird()
--player update

--gravity
	bird.yvel+=gravity

--actual falling
	bird.y+=bird.yvel
	
	bird.h.y=bird.y+2
	bird.h.x=bird.x
	
--[[
ˇˇˇˇˇˇˇˇˇˇˇˇˇ
!!!!!!!!this must go after
the gravity and velocity!!!!!
ˇˇˇˇˇˇˇˇˇˇˇˇˇ
]]
	
 local gdb
 =mget
 ((bird.x+4)/8,(bird.y+8)/8)
--ground detection bottom
		
	
	if fget(gdb,0) then
		bird.alive = false
		bird.y = flr((bird.y)/8)*8
		bird.yvel=0
	end
--[[
checks sprite flag 0 and the
bottom center of the bird for
the ground sprites
]]

if bird.y > -6 then
	if btnp(⬆️) 
	or btnp(❘) 
	or btnp(🅾️) then
		jump(bird.jump)
	end
end
--only allow jump within screen
--^calls jump on button press

	bird_anim()
	
--	if bird.alive==false then
	--	bird.sprite=bird.sprite+3
--	end
	
--[[
checks the birds velocity
to determine if it faces up,
down, or forward
]]
	
	for apipe in all(pipes) do
		if 
			collision(bird.h,apipe.top.h)
			or
			collision(bird.h,apipe.bottom.h)
			then
				bird.alive = false
		end
	end
	--collision

end



function dbird()
--player draw
	spr(bird.sprite,bird.x,bird.y)
--draws sprite 1 at bird x/y
--	print("velocity = ".. bird.yvel)
--	print("x: ".. bird.x)
--	print("y: ".. bird.y)
	
--print("alive?: "..(bird.alive and 'true' or 'false'))
	
--	pset(bird.x+4,bird.y+8,8)
--.. allows you to use 2 vars
end


function jump(h)

	bird.yvel=0
	sfx(0)
--[[
sets velocity to 0, 
so that the jump height
doesnt vary
]]
	bird.yvel-=h
	
end

function bird_anim()
	if bird.yvel < 0 then
		bird.sprite=2
	elseif bird.yvel > 1.7 then
		bird.sprite=3
	else
		bird.sprite=1
	end
end
-->8
--obstacles

function ipipe()
	pipes={}
	pipespeed=1
	pipeinterval=54
	pipetime=flr(pipeinterval*.75)
end


function upipe()
	
--create pipe timer
	if pipetime == pipeinterval then
		make_pipe()
		pipetime = 0
	else
		pipetime += 1
	end
	
	--moves pipes
	for apipe in all(pipes) do
		pipe_move(apipe)
	end
	
	--culls pipes
	for apipe in all(pipes) do
		if apipe.x<-16 then
			del(pipes,apipe)
		end
	end

	--score check	
	for apipe in all(pipes) do
		if flr(apipe.x+12)==flr(bird.x) then
			score+=1
			sfx(2)
		end	
	end

end


function dpipe()

	for apipe in all(pipes) do
		
		spr(20,apipe.top.x,apipe.top.y,2,1,false,true)
		spr(20,apipe.bottom.x,apipe.bottom.y,2,1)
		--draws the ends of the pipes
		
		for i=((apipe.bottom.y/8)+1),13 do
			spr(22,apipe.bottom.x,i*8,2,1)
		end
		for i=((apipe.top.y/8)-1),-1,-1 do
			spr(22,apipe.top.x,i*8,2,1)
		end
		--[[
		creates the pipes body by
		looping through the pipes
		height through the ground
		value (13)
		divided by 8 to use the tile
		instead of pixel location
		]]
		
--spr(1,apipe.x,apipe.y,1,1)
		
--[[
		pset(apipe.top.h.x, apipe.top.h.y, 8)
		pset(apipe.top.h.x+apipe.top.h.w, apipe.top.h.y, 8)
		pset(apipe.top.h.x, apipe.top.h.y+apipe.top.h.h, 8)
		pset(apipe.top.h.x+apipe.top.h.w, apipe.top.h.y+apipe.top.h.h, 8)


		pset(bird.h.x, bird.h.y, 8)
		pset(bird.h.x+bird.h.w, bird.h.y, 8)
		pset(bird.h.x, bird.h.y+bird.h.h, 8)
		pset(bird.h.x+bird.h.w, bird.h.y+bird.h.h, 8)
]]


	end 
	--[[
	apipe is a variable that
	represents a given/each
	]]
	
end


function make_pipe()
	local newpipe={}
	newpipe.x=132+(flr(rnd(2)))*8
--sets x offscreen(132)+3rand tiles
	newpipe.y=(flr(rnd(10))+2)*8
--math does a random tile inbounds
	
	newpipe.top={}
	newpipe.top.x=newpipe.x
	newpipe.top.y=newpipe.y-16
	--move up 2 tiles (16)
	newpipe.top.h={
		x=newpipe.top.x,
		y=newpipe.top.y-96,
		w=15,
		h=103
	}
	
	newpipe.bottom={}
	newpipe.bottom.x=newpipe.x
	newpipe.bottom.y=newpipe.y+16
--move down 2 tiles
	newpipe.bottom.h={
		x=newpipe.bottom.x,
		y=newpipe.bottom.y,
		w=15,
		h=96
	}
	
	add(pipes,newpipe)
end

function pipe_move(pipe)
	local apipe=pipe
	apipe.x-=pipespeed
		apipe.top.x-=pipespeed
		apipe.bottom.x-=pipespeed
			apipe.top.h.x-=pipespeed
			apipe.bottom.h.x-=pipespeed
end
-->8
--overall

function ustart()
	if btn(❘) then
		mode="game"
	end
end


function ugame()
	if game_check==true then
		if bird.alive==false then
			bird.y=63
		end
		score=0
		bird.alive=true
		game_check=false
		
		for apipe in all(pipes) do
			del(pipes,apipe)
		end
		
		jump(bird.jump)
		
	end

	ubird()
	upipe()
	if bird.alive==false then
		mode="dead"
	end
	
	death_check=true
end


function udead()
	if death_check==true and bird.alive==false then
		bird.sprite+=3
		sfx(1)
		jump(bird.jump/1.5)
		death_check=false
	end
	
	if btn(❘) then
		mode="game"
	end

if bird.y<132 then
	bird.yvel+=gravity/3
	bird.y+=bird.yvel
end

	game_check=true

end


function dstart()
	
	spr(192,0,32,16,3)
	
	print("press ❘ to start",29,84,1)--shadow		
	print("press ❘ to start",31,80,12)
	
	danim()
	dbird()
	
	print("use 🅾️ ❘ or ⬆️ to jump",19,121,1)
	print("use 🅾️ ❘ or ⬆️ to jump",19,119,1)
	print("use 🅾️ ❘ or ⬆️ to jump",18,121,1)
	print("use 🅾️ ❘ or ⬆️ to jump",17,121,1)
	print("use 🅾️ ❘ or ⬆️ to jump",17,119,1)
	--shadow		
	print("use 🅾️ ❘ or ⬆️ to jump",18,120,4)
	
end


function dgame()
		danim()
		dpipe()
		dbird()
		
		print(score,65,17,12)
		print(score,64,17,12)
		print(score,63,17,12)
		print(score,62,17,12)
		
		print(score,65,14,12)
		print(score,64,14,12)
		print(score,63,14,12)
		print(score,62,14,12)
--bg box top/bottom
		print(score,62,16,12)
		print(score,62,15,12)
		print(score,62,14,12)

		print(score,65,16,12)
		print(score,65,15,12)
		print(score,65,14,12)
--bg box left/right
		print(score,64,16,9) --shadow
		print(score,63,15,10)
end


function ddead()
	danim()
	dpipe()
	dbird()
	print("your score was:",34,32,9)
	print(score,60,42,9)
	print("press ❘ to retry!",28,81,1)

	print("your score was:",35,31,10)
	print(score,61,41,10)
	print("press ❘ to retry!",30,80,12)
end
-->8
--animations

function ianim()
	ground_timer=0
	
	city_timer=0
	cityx=0
	
	cloud_timer=0
	cloudx=0
	
	start_timer=20
end


function uanim()
	if mode=="start" then
		start_anim()
		ground_anim()
		city_anim()
		cloud_anim()
	elseif mode=="game" then
		ground_anim()
		city_anim()
		cloud_anim()
	elseif mode=="dead" then
	
	end
end


function danim()

	spr(128,cloudx,48,16,4)
	spr(128,cloudx+128,48,16,4)
	
	spr(64,cityx,80,16,4)
	spr(64,cityx+128,80,16,4)
end


function ground_anim()
	if ground_timer==pipespeed*2 then
		ground_timer=0
		for x=0, 15 do
			for y=0, 15 do
				if mget(x,y)==18 then
					mset(x,y,19)
				elseif mget(x,y)==19 then
					mset(x,y,18)
				end
			end
		end
	else
		ground_timer+=1
	end
	
end


function city_anim()
	if city_timer == pipespeed*6 then
		cityx-=1
		city_timer=0
	else
		city_timer+=1
	end
	
	if cityx<-128 then
		cityx=0
	end
end


function cloud_anim()
	if cloud_timer == pipespeed*15 then
		cloudx-=1
		cloud_timer=0
	else
		cloud_timer+=1
	end
	
	if cloudx<-128 then
		cloudx=0
	end
end


function start_anim()
	bird_anim()
	
	if bird.y<64 then
		bird.yvel+=gravity
		bird.y+=bird.yvel
	end
	
	if start_timer == 21 then
		bird.y=63
		jump(bird.jump)
		start_timer=0	
	else
		start_timer+=1
	end
end