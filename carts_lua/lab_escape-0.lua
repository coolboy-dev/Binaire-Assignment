--_init
function _init()
	
	--testing
	testing=false
	
	game_end=false
	
	
	extra_box_height=0
	
	
	music(16)
	player={
		sp=0,
		//spawn x=188 y=98 room=1
		x=188,
		y=98,
		room=1,
		w=4,
		h=8,
		flp=false,
		dx=0,
		dy=0,
		max_dx=2,
		max_dy=6,
		xacc=.32,
		jump=4,
		anim=0,
		running=false,
		jumping=false,
		falling=false,
		fric_sliding=false,
		cust_sliding=false,
		landed=false,
		spr_shift=2,
		last_door=0,
		health=1,
		max_health=100
	}
	in_room=0
	
	last_door_spawn_x=0
	last_door_spawn_y=0
	cam_limits={0,0,0,0}
	set_cam_limits()
	
	--uncomment while testing rooms
	--player.x=cam_limits[1]+20
	--player.y=cam_limits[3]+20
	
	item_text="test"
	item_box=false
	
	room_tracker={
	a1=false,
	a2=false,
	a3=false,
	a4=false,
	a5=false,
	a6=false,
	b1=false,
	b2=false,
	b3=false,
	b4=false,
	c1=false,
	c2=false,
	d1=false,
	d2=false,
	d3=false,
	e1=false,
	f1=false,
	g1=false,
	g2=false,
	h1=false,
	i1=false,
	j1=false,
	j2=false,
	j3=false,
	k1=false,
	k2=false,
	k3=false,
	k4=false,
	l1=false,
	l2=false,
	l3=false,
	l4=false
	}
	
	health_count=1
	
	
	
	move_room=false
	
	--door state
	tubex=75
	closex=74
	open1x=106
	open2x=107
	
	tubey=88
	closey=72
	open1y=104
	open2y=120
	
	
	tokens_collected=0
	
	--door1={
	--id=1,
	--sp1=close1x,
	--sp2=tubex,
	--x1=-128,
	--y1=-128,
	--x2=-128,
	--y2=-128,
	--w=1,
	--h=2,
	--xrot=false,
	--yrot=false,
	--dest=0
	--}
	
	--door2={
	--id=2,
	--sp1=closex,
	--sp2=tubex,
	--x=-128,
	--y=-128,
	--x2=-128,
	--y2=-128,
	--w=1,
	--h=2,
	--xrot=false,
	--yrot=false,
	--dest=0
	--}
	
	--door3={
	--id=3,
	--sp1=closey,
	--sp2=tubey,
	--x1=-128,
	--y1=-128,
	--x2=-128,
	--y2=-128,
	--w=2,
	--h=1,
	--xrot=false,
	--yrot=false,
	--dest=0
	--}
	
	--needed because door 4 id
	--notinitiallized in room 1
	door4={id=4,sp1=closey,p2=tubey,x1=-128,y1=-128,x2=-128,y2=-128,w=2,h=1,xrot=false,yrot=false,dest=0}
	
	
	
	mapcolor1=14
	mapcolor2=14
	mapcolor3=14
	mapcolor4=14
	mapcolor5=14
	mapcolor6=14
	mapcolor7=14
	mapcolor8=14
	mapcolor9=14
	mapcolor10=14
	mapcolor11=14
	mapcolor12=14
	
	
	brick1={
	id=1,
	sp1=125,
	broken=false,
	x=0,
	y=0
	}
	
	brick2={
	id=2,
	sp1=125,
	broken=false,
	x=0,
	y=0
	}
	
	
	brick3={
	id=3,
	sp1=125,
	broken=false,
	x=0,
	y=0
	}
	
	
	brick4={
	id=4,
	sp1=125,
	broken=false,
	x=0,
	y=0
	}
	
	
	brick5={
	id=5,
	sp1=125,
	broken=false,
	x=0,
	y=0
	}
	
	brick6={
	id=6,
	sp1=625,
	broken=false,
	x=0,
	y=0
	}
	
	temp_brick=brick1
	
	
	brick_breaker_item={
	id=1,
	obtained=false,
	x=104,
	y=88,
	sp=63
	}
	
	
	jump_item={
	id=2,
	obtained=false,
	x=592,
	y=472,
	--x=104,
	--y=88,
	sp=61
	}
	
	
	maghead_item={
	id=3,
	obtained=false,
	x=872,
	y=144,
	sp=60
	}
	
	
	runboots_item={
	id=4,
	obtained=false,
	x=312,
	y=448,
	sp=62
	}
	
	
	--blaster_item={
	--id=5,
	--obtained=false,
	--x=544,
	--y=152,
	--sp=59
	--}
	
	compass_item={
	id=6,
	obtained=false,
	x=368,
	y=320,
	--x=736,
	--y=96,
	sp=58
	}
	
	
	portal_item={
	id=7,
	obtained=false,
	x=200,
	y=296,
	sp=5
	}
	
	
	temp_item={
	id=0,
	obtained=false,
	x=0,
	y=0,
	sp=0
	}
	
	
	
	
	
	
	--tokens
	
	
	token1={
	id=1,
	sp1=47,
	collected=false,
	x=456,
	y=80,
	x2=8,
	y2=344
	}
	
	token2={
	id=2,
	sp1=47,
	collected=false,
	x=736,
	y=96,
	x2=24,
	y2=344
	}
	
	token3={
	id=3,
	sp1=47,
	collected=false,
	x=736,
	y=24,
	x2=40,
	y2=344
	}
	
	token4={
	id=4,
	sp1=47,
	collected=false,
	x=544,
	y=152,
	x2=56,
	y2=344
	}
	
	token5={
	id=5,
	sp1=47,
	collected=false,
	x=152,
	y=168,
	x2=72,
	y2=344
	}
	
	token6={
	id=6,
	sp1=47,
	collected=false,
	x=864,
	y=32,
	x2=88,
	y2=344
	}
	
	token7={
	id=7,
	sp1=47,
	collected=false,
	x=776,
	y=240,
	x2=104,
	y2=344
	}
	
	token8={
	id=8,
	sp1=47,
	collected=false,
	x=888,
	y=352,
	x2=120,
	y2=344
	}
	
	token9={
	id=9,
	sp1=47,
	collected=false,
	x=768,
	y=408,
	x2=8,
	y2=360
	}
	
	token10={
	id=10,
	sp1=47,
	collected=false,
	x=1008,
	y=392,
	x2=24,
	y2=360
	}
	
	token11={
	id=11,
	sp1=47,
	collected=false,
	x=624,
	y=392,
	x2=40,
	y2=360
	}
	
	token12={
	id=12,
	sp1=47,
	collected=false,
	x=416,
	y=392,
	x2=56,
	y2=360
	}
	
	token13={
	id=13,
	sp1=47,
	collected=false,
	x=520,
	y=416,
	x2=72,
	y2=360
	}
	
	token14={
	id=14,
	sp1=47,
	collected=false,
	x=328,
	y=448,
	x2=88,
	y2=360
	}
	
	token15={
	id=15,
	sp1=47,
	collected=false,
	x=744,
	y=312,
	x2=104,
	y2=360
	}
	
	token16={
	id=16,
	sp1=47,
	collected=false,
	x=16,
	y=312,
	x2=120,
	y2=360
	}
	
	
	
	--for tetsing purposes
	pointx1=0
	pointx2=0
	pointy1=0
	pointy2=0
	
	
	gravity=0.3
	friction=0.85
	cam_min_x=0
	cam_max_x=0
	cam_min_y=0
	cam_max_y=0
	
	
	
	update_room()
	
	
	start_game=true
	fisrt_frame=true
	
	
	--for tetsing purposes
	test=""
end



-->8
--_update & _draw
function _update()
	
	if first_frame==false and start_game then
		if btn(🅾️) then
			start_game=false
		else
			return
		end
	end
	
	if game_end then
		return
	end
	
	--testing
	if testing then
		brick_breaker_item.obtained=true
		jump_item.obtained=true
		
		compass_item.obtained=true
		maghead_item.obtained=true
		runboots_item.obtained=true
	end
	
	
	
	
	--game end
	if player.x>=197 and in_room==18 then
		game_end=true
		player.sp=127
	end
	
	
	--update_room()
	
	lastx=player.x
	lasty=player.y
	lastdx=player.dx
	lastdy=player.dy
	lastflip=player.flp
	lastsp=player.sp
	
	player_update()
	
	
	
	player_animate()
	
	map_maker()
	
	
	--items
	if brick_breaker_item.obtained then
		brick_breaker()
	end
	
	--maghead set in player_update()
	
	if jump_item.obtained then
		player.jump=04.5
	end
	
	if runboots_item.obtained then
		player.xacc=0.4
	end
	
	--simple camera
	cam_x=player.x-60
	cam_y=player.y-64
	
	
	set_cam_limits()
	
	
	--set x cam limit
	if cam_x<cam_min_x then
		cam_x=cam_min_x
	end
	if cam_x>cam_max_x then
		cam_x=cam_max_x
	end
	
	--set y cam limit
	if cam_y<cam_min_y then
		cam_y=cam_min_y
	end
	if cam_y>cam_max_y then
		cam_y=cam_max_y
	end
	
	
	
	
	camera(cam_x,cam_y)
	
	
	
	
	if tokens_collected==16 then
		fset(38,1,false)
	end
	
	
	
	
	
	
	if item_box==true then
		player.x=lastx
		player.y=lasty
		player.dx=lastdx
		player.dy=lastdy
		player.flp=lastflip
		player.sp=lastsp
	end
	
	
	
	
	--update map color
	--aaa
	if token1.collected and token2.collected and token3.collected then
		mapcolor1=3
	end
	--bbb
	if token5.collected then
		mapcolor2=3
	end
	--ccc
	if token16.collected then
		mapcolor3=3
	end
	--ddd
	if runboots_item.obtained and token14.collected then
		mapcolor4=3
	end
	--eee
	if compass_item.obtained then
		mapcolor5=3
	end
	--fff
	--no items
	mapcolor6=3
	--ggg
	if jump_item.obtained and token11.collected and token12.collected and token13.collected then
		mapcolor7=3
	end
	--hhh
	if token4.collected then
		mapcolor8=3
	end
	--iii
	--no items
	mapcolor9=3
	--jjj
	if token15.collected then
		mapcolor10=3
	end
	--kkk (yikes)
	if maghead_item.obtained and token6.collected and token7.collected and token8.collected and token9.collected then
		mapcolor11=3
	end
	--lll
	if token10.collected then
		mapcolor12=3
	end
	
	
	first_frame=false
end

function _draw()
	cls()
		
		if in_room==1 or in_room==2 or player.room==10 or (player.room==12 and in_room==32) or player.room==7 or player.room==3 then
			map(0,0)
			if item_box==true then
				spr(lastsp,lastx,lasty,1,1,player.flp)
			else
				if game_end==false then
					spr(player.sp,player.x,player.y,1,1,lastflip)
				end
			end
		else
			if item_box==true then
				spr(lastsp,lastx,lasty,1,1,lastflip)
			else
				if game_end==false then
					spr(player.sp,player.x,player.y,1,1,player.flp)
				end
			end
			map(0,0)
		end
		
		
		if game_end then
			powerup_collide(portal_item.obtained, portal_item.x, portal_item.y, portal_item.id)
			extra_box_height=58
		end
		
	
	
	
	
	function is_close(hatch)
			if abs(hatch.x1-player.x)<16 and abs(hatch.y1-player.y)<16 then
				if hatch.w==1 then
				hatch.sp1=open2x
				else
				hatch.sp1=open2y
				end
			elseif abs(hatch.x1-player.x)<24 and abs(hatch.y1-player.y)<24 then
				if hatch.w==1 then
				hatch.sp1=open1x
				else
				hatch.sp1=open1y
				end
			else
				if hatch.w==1 then
				hatch.sp1=closex
				else
				hatch.sp1=closey
				end
			end
	end
	
	
	
	is_close(door1)
	is_close(door2)
	is_close(door3)
	is_close(door4)
	
	
	
	--if abs(door1.x1-player.x)<16 then
	--	door1.sp1=open2x
	--	elseif abs(door1.x1-player.x)<24 then
	--	door1.sp1=open1x
	--	else
	--	door1.sp1=closex
	--end
	
	
	
	
	
	
	
	
	--draw doors
	spr(door1.sp1,door1.x1,door1.y1,door1.w,door1.h,door1.xrot,door1.yrot) 
	spr(door1.sp2,door1.x2,door1.y2,door1.w,door1.h,door1.xrot,door1.yrot)
	
	
	spr(door2.sp1,door2.x1,door2.y1,door2.w,door2.h,door2.xrot,door2.yrot)
	spr(door2.sp2,door2.x2,door2.y2,door2.w,door2.h,door2.xrot,door2.yrot)
	
	spr(door3.sp1,door3.x1,door3.y1,door3.w,door3.h,door3.xrot,door3.yrot)
	spr(door3.sp2,door3.x2,door3.y2,door3.w,door3.h,door3.xrot,door3.yrot)
	
	spr(door4.sp1,door4.x1,door4.y1,door4.w,door4.h,door4.xrot,door4.yrot)
	spr(door4.sp2,door4.x2,door4.y2,door4.w,door4.h,door4.xrot,door4.yrot)
	
	--bricks
	spr(brick1.sp,brick1.x,brick1.y)
	spr(brick2.sp,brick2.x,brick2.y)
	spr(brick3.sp,brick3.x,brick3.y)
	spr(brick4.sp,brick4.x,brick4.y)
	spr(brick5.sp,brick5.x,brick5.y)
	spr(brick6.sp,brick6.x,brick6.y)
	
	--powerups
	spr(brick_breaker_item.sp,brick_breaker_item.x,brick_breaker_item.y)
	spr(jump_item.sp,jump_item.x,jump_item.y)
	spr(maghead_item.sp,maghead_item.x,maghead_item.y)
	spr(runboots_item.sp,runboots_item.x,runboots_item.y)
	--spr(blaster_item.sp,blaster_item.x,blaster_item.y)
	spr(compass_item.sp,compass_item.x,compass_item.y)
	spr(portal_item.sp,portal_item.x,portal_item.y,1,3)

	
	spr(token1.sp1,token1.x,token1.y)
	spr(token2.sp1,token2.x,token2.y)
	spr(token3.sp1,token3.x,token3.y)
	spr(token4.sp1,token4.x,token4.y)
	spr(token5.sp1,token5.x,token5.y)
	spr(token6.sp1,token6.x,token6.y)
	spr(token7.sp1,token7.x,token7.y)
	spr(token8.sp1,token8.x,token8.y)
	spr(token9.sp1,token9.x,token9.y)
	spr(token10.sp1,token10.x,token10.y)
	spr(token11.sp1,token11.x,token11.y)
	spr(token12.sp1,token12.x,token12.y)
	spr(token13.sp1,token13.x,token13.y)
	spr(token14.sp1,token14.x,token14.y)
	spr(token15.sp1,token15.x,token15.y)
	spr(token16.sp1,token16.x,token16.y)

	
	
	if item_box==true then
		
		rectfill(cam_x+23,cam_y+29+extra_box_height,cam_x+105,cam_y+61+extra_box_height,2)
		rectfill(cam_x+24,cam_y+30+extra_box_height,cam_x+104,cam_y+60+extra_box_height,14)
		print(item_text,cam_x+25,cam_y+31+extra_box_height,5)
	end
	
	
	
	--player's map item
	draw_map()
	
	
	if fget(38,1) == false then
		for i=34,41 do
			mset(18,i,127)
		end
		mset(18,44,55)
	end

	
	
	--draw map
	--+10 left of the screem
	--+16 top of screen
	
	
	--health
	--if player.max_health<=50 then
	
	--	rectfill(cam_x+3,cam_y+3,cam_x+(player.max_health)+4,cam_y+7,13)
	--	rectfill(cam_x+4,cam_y+4,cam_x+(player.max_health)+3,cam_y+6,5)
	--	rectfill(cam_x+4,cam_y+4,cam_x+(player.health)+3,cam_y+6,8)
	
 --else
		
	--	bar1=player.health
	--	bar1_max=50
		
		
	--	if bar1>bar1_max then
	--		bar1=bar1_max
	--	end
		
		
	--	health2=player.health-50
	--	health2_min=0
		
		
	--	bar2_max=player.max_health-50
		
	--	if health2<health2_min then
	--		health2=health2_min
	--	end
		
		

	
	
	--testing
	--print(flr((player.x+2)/8),player.x-10,player.y-20,14)
	--print(flr(player.y/8),player.x-10,player.y-10,14)
	
	
	--openning text
	if start_game then
		rectfill(cam_x+23,cam_y+29+extra_box_height,cam_x+105,cam_y+61+extra_box_height,2)
		rectfill(cam_x+24,cam_y+30+extra_box_height,cam_x+104,cam_y+60+extra_box_height,14)
		print("oh no, the portal is\nbroken! find and\nactivate the backup\nportal\n            press 🅾️",cam_x+25,cam_y+31+extra_box_height,5)
	end
	
	if testing then
	tokens_collected=15
		print(player.x,player.x+10,player.y-20,14)
		print(in_room,player.x+10,player.y-10,14)
	end
	
	--print(in_room,player.x+20,player.y-0,14)
	--print(tokens_collected,player.x+10,player.y-30,14)
	--print(fget(38,1),player.x+10,player.y-40,14)
	
	
end

-->8
--player_update()
function player_update()
	if game_end==false then
	
	
	--physics
	player.dy+=gravity
	player.dx*=friction
	
	
	--cotrols
	if btn(⬅️) then
		player.dx-=player.xacc
		player.running=true
		player.flp=true
	end
	if btn(➡️) then
		player.dx+=player.xacc
		player.running=true
		player.flp=false
	end
	
	--friction slide
	if player.running
	and not btn(⬅️)
	and not btn(➡️)
	and not player.falling
	and not player.jumping then
		player.running=false
		player.fric_sliding=true
	end
	
	--jump(no hold)
	if btn(❘)
	and player.landed
	 then
		player.dy-=player.jump
		player.landed=false
		--sfx(25)
	end
	
	
	
	if btn(🅾️) then
		item_box=false
	end
	
	
	
 --check y collision
	if player.dy>0 then
		player.falling=true
		player.landed=false
		player.jumping=false
 		if new_collide(player,1) then 
		 player.landed=true
			player.falling=false
			player.dy=0
			--player.y-=(player.y+player.h)%8
		end
	end
	
	--going up
	if player.dy<0 then
		player.falling=false
		player.landed=false
		player.jumping=true
		if new_collide(player,1) then
		--if collide_map(player,"up",1) then
			player.dy=0
		end
	end
	
	--check x collisions
	if player.dx<0 then
		--if collide_map(player,"left",1) then
		if new_collide(player,0) then
			--player.x=(flr((player.x + 6)>>3)<<3)-player.spr_shift
		end
	elseif player.dx>0 then
		--if collide_map(player,"right",1) then
			if new_collide(player,0) then
			--player.dx=0
			--player.x=(flr((player.x + 6)>>3)<<3)-player.spr_shift-3.5
		end
	end
	
	--stop fric_sliding
	if player.fric_sliding then
		if abs(player.dx)<.2
		or player.running then
			player.dx=0
			player.fric_sliding=false
		end
	end
	
	
	
	--cap speed in y
	if player.dy>player.max_dy then
		player.dy=player.max_dy
	end
		
		
	player.x+=player.dx
	player.y+=player.dy
	
	
	door_collide(door1)
	door_collide(door2)
	door_collide(door3)
	door_collide(door4)
	
	
	
	
	
	
	
	
	
	--collide with powerups
	if brick_breaker_item.obtained==false then
		temp_item=brick_breaker_item
		--bick_breaker_item=powerup_collide(brick_breaker_item.obtained, brick_breaker_item.x, brick_breaker_item.y)
		powerup_collide(brick_breaker_item.obtained, brick_breaker_item.x, brick_breaker_item.y, brick_breaker_item.id)
		brick_breaker_item.obtained = temp_item.obtained
		brick_breaker_item.x = temp_item.x
		brick_breaker_item.y = temp_item.y
		brick_breaker_item.sp = temp_item.sp
	end
	
	
	if jump_item.obtained==false then
		temp_item=jump_item
		powerup_collide(jump_item.obtained, jump_item.x, jump_item.y, jump_item.id)
		jump_item.obtained=temp_item.obtained
		jump_item.x=temp_item.x
		jump_item.y=temp_item.y
		jump_item.sp=temp_item.sp
	end
	
	
	if maghead_item.obtained==false then
		temp_item=maghead_item
		powerup_collide(maghead_item.obtained, maghead_item.x, maghead_item.y, maghead_item.id)
		maghead_item.obtained=temp_item.obtained
		maghead_item.x=temp_item.x
		maghead_item.y=temp_item.y
		maghead_item.sp=temp_item.sp
	end
	
	if runboots_item.obtained==false then
		temp_item=runboots_item
		powerup_collide(runboots_item.obtained, runboots_item.x, runboots_item.y, runboots_item.id)
		runboots_item.obtained=temp_item.obtained
		runboots_item.x=temp_item.x
		runboots_item.y=temp_item.y
		runboots_item.sp=temp_item.sp
	end
	
	--if blaster_item.obtained==false then
	--	temp_item=blaster_item
	--	powerup_collide(blaster_item.obtained, blaster_item.x, blaster_item.y)
	--	blaster_item.obtained=temp_item.obtained
	--	blaster_item.x=temp_item.x
	--	blaster_item.y=temp_item.y
	--	blaster_item.sp=temp_item.sp
	--end
	
	if compass_item.obtained==false then
		temp_item=compass_item
		powerup_collide(compass_item.obtained, compass_item.x, compass_item.y, compass_item.id)
		compass_item.obtained=temp_item.obtained
		compass_item.x=temp_item.x
		compass_item.y=temp_item.y
		compass_item.sp=temp_item.sp
	end
	
	
	
	
	token_cycle()
	
	
	
	
	
	
	--view menu
	
	
	if btn(⬆️) then
		player.in_menu=true
		
	end
	
	if btn(⬆️)==false then
	 player.in_menu=false
	end
	
	
	
	--if game_end==false
	end
	
	
end




-->8
--new_collide  --door_collide

function new_collide(obj,dir)
	
	
	col_obj=obj
	col_dir=dir
	
	px1=player.x+3
	py1=player.y
	
	px2=player.x+5
	py2=player.y+player.h
	
	
	
	
	--t_left=mget(px1,py1)
	--t_right=mget(px2,py1)
	--b_left=mget(px1,py2)
	--b_right=mget(px2,py2)
	
	if col_dir==1 then
	
	--i need to change the "and" to 
	--a new "if" statement, but 
	--holy shit this is creates an 
	--awsome magentic effect when 
	--hitting your head on a tile
	
	--up
	
	if fget(mget(px1/8,(py2-4)/8),7) or fget(mget(px2/8,(py2-4)/8),7) then
					player.dx=0
					player.dy=0
					player.x=last_door_spawn_x
					player.y=last_door_spawn_y
	end
	
	if maghead_item.obtained==true then
	
		if player.dy<0 and fget(mget((px1)/8,(py1-1)/8),2) or fget(mget((px2-3)/8,(py1-1)/8),2) or fget(mget((px2)/8,(py1-1)/8),2) then




			return true
		end
	end
	
	if
			 player.dy<0 then
				if fget(mget(px1/8,(py1-1)/8),7) or fget(mget(px2/8,(py1-1)/8),7) then
					player.dx=0
					player.dy=0
					player.x=0
					player.y=0
				elseif fget(mget(px1/8,(py1-1)/8),0) or fget(mget(px2/8,(py1-1)/8),0) then
					if	abs(player.dy)<3.5 	then			
					--player.y=ceil(player.y/8)*8
								  player.y-=(player.y+player.h)%8

					else
					player.y=ceil(player.y/8)*8
			  --player.y-=(player.y+player.h)%8
					end
					return true
				end
			end	
		--down
		if player.dy>0 then
			if fget(mget(px1/8,py2/8),0) or fget(mget(px2/8,py2/8),0) then
							player.y-=(player.y+player.h)%8

				return true
			else
				return false
			end
 	end
 end	
	
	if col_dir==0 then
		
		--left
		if player.dx<0 then
			if fget(mget((px1-2)/8,(py1)/8),1) or fget(mget((px1-2)/8,(py2-1)/8),1) then
				player.dx=0
				if fget(mget((px1-1)/8,(py1)/8),1) or fget(mget((px1-1)/8,(py2-1)/8),1) then
					player.x+=(player.x+player.w)%8
				end
				return true
			end
			
			
			--check brick col left
			for i=1,6 do
				change_temp_brick(i)
				if  player.x<=temp_brick.x+6
				and player.x>=temp_brick.x-4
				and player.y<=temp_brick.y+4
				and player.y>=temp_brick.y-4
				and temp_brick.broken==false then
					player.dx=0	
					player.x=flr(player.x/8)*8+6
					
					return true
				end
				
			end
		end
		
		
		
		--right
		if player.dx>0 then
			if fget(mget((px1+3)/8,(py1)/8),1) or fget(mget((px1+3)/8,(py2-1)/8),1) then
				player.dx=0
				if fget(mget((px1+2)/8,(py1)/8),1) or fget(mget((px1+2)/8,(py2-1)/8),1) then
					player.x-=1
				end
				return true
			end
			--check brick col right
			for i=1,6 do
				change_temp_brick(i)
				if  player.x<=temp_brick.x+4
				and player.x>=temp_brick.x-6
				and player.y<=temp_brick.y+4
				and player.y>=temp_brick.y-4
				and temp_brick.broken==false then
					player.dx=0	
					player.x=flr(player.x/8)*8+2
					return true
				end
			end
		end
	end
end









function change_temp_brick(ctbi)
	if ctbi==1 then temp_brick=brick1
	elseif ctbi==2 then temp_brick=brick2
	elseif ctbi==3 then temp_brick=brick3
	elseif ctbi==4 then temp_brick=brick4
	elseif ctbi==5 then temp_brick=brick5
	else temp_brick=brick6
	end
end


	
--going through doors
function door_collide(door_obj)
	--check door 1 collision
	door=door_obj
	
	
	 
	
	if door.sp2==tubex then
		if (player.x>=door.x2-4) and (player.x<=door.x2+4) then
			if (player.y>=door.y2) and (player.y<=door.y2+8) then
				move_room=true
			end
		end
	end

	if door.sp2==tubey then
		if (player.x>=door.x2-8) and (player.x<=door.x2+12) then
			if (player.y>=door.y2) and (player.y<=door.y2+8) then
				move_room=true
			end
		end
	end

			if move_room==true then
				player.room=door.dest
				reset_door_state()
				update_room()
				--reset_door_state()
				move_room=false
			
			--this is needed since the door(#) values change mid way through
			if door.id==1 then door=door1
			elseif door.id==2 then door=door2
			elseif door.id==3 then door=door3
			else door=door4
			end
			
			
			if door.xrot==true and door.sp2==tubex then
				player.x=door.x1+8
				player.y=door.y1+8
			elseif door.xrot==false and door.sp2==tubex then
				player.x=door.x1-8
				player.y=door.y1+8
			elseif door.yrot==true and door.sp2==tubey then
				player.x=door.x1+4
				player.y=door.y1+8
			else
			 player.x=door.x1+4
				player.y=door.y1-12
			end
			
			last_door_spawn_x=player.x
			last_door_spawn_y=player.y
		end
	
	
	
	
	
	function brick_breaker()
		if btn(🅾️) then
			for p=1,6 do
					change_temp_brick(p)
				if player.x<=temp_brick.x+9
				and player.x>=temp_brick.x-9
				and player.y<=temp_brick.y+4
				and player.y>=temp_brick.y-4
				then
					temp_brick.broken=true
					sfx(26)
					
					
					
					--not sure why i dont
					--need the but whatever
					
					
					--set current brink (i) 
					--to temp_brick
					--if p==1 then brick1=temp_brick
				 --elseif p==2 then bick2=temp_brick
				 --elseif p==3 then bick3=temp_brick
				 --elseif p==4 then bick4=temp_brick
				 --else bick5=temp_brick
					
					--end
					update_room()
				end
			end
		end
		
		
		
	end
end

function powerup_collide(pu_obtained, pu_x, pu_y, pu_id)
	
	if player.x>=pu_x-5
	and player.x<=pu_x+5
	and player.y>=pu_y-5
	and player.y<=pu_y+5
	or game_end
	then
		temp_item.obtained=true
		temp_item.sp=127
		if game_end==false then
			sfx(29)
		end
		item_box=true
		if pu_id==1 then
			item_text="brick braker\n\npress 🅾️ to break\n certain blocks"
		elseif pu_id==2 then
			item_text="high jump\n\nyou can now jump\nhigher"
		elseif pu_id==3 then
			item_text="maghead\n\nyour head now sticks\nto electromagnet\nrails"
		elseif pu_id==4 then
			item_text="run boots\n\nrun faster and jump\n farther"
		elseif pu_id==6 then
			item_text="compass\n\npress ⬆️ to see\n where you are\n on the map"
		--this one works differently
		--activated when game_end==true
		elseif pu_id==7 then
		item_text="congratulations!\nyou beat the game! \n\npress crtl+r to\nrestart"
		else
			item_text="error"
		end
		
		return test_item
	end
end




function token_cycle()
	token_collide(token1)
	token_collide(token2)
	token_collide(token3)
	token_collide(token4)
	token_collide(token5)
	token_collide(token6)
	token_collide(token7)
	token_collide(token8)
	token_collide(token9)
	token_collide(token10)
	token_collide(token11)
	token_collide(token12)
	token_collide(token13)
	token_collide(token14)
	token_collide(token15)
	token_collide(token16)
end



function token_collide(token_obj)

	
	if player.x>=token_obj.x-5
	and player.x<=token_obj.x+5
	and player.y>=token_obj.y-5
	and player.y<=token_obj.y+5
	then
		sfx(24)
		token_obj.collected=true
		token_obj.x=token_obj.x2
		token_obj.y=token_obj.y2
		tokens_collected+=1
	end
end
-->8
--player_animate()
function player_animate()
	if player.jumping then
		player.sp=18
	elseif player.falling then
		player.sp=19
--	elseif player.fric_sliding then
--		player.sp=34
	elseif player.running then
		if time()-player.anim>.1 then
			player.anim=time()
			player.sp+=1
			if player.sp>3 then
				player.sp=2
			end
		end
		else
		player.sp=0
	end
end
-->8
--cam limits
function set_cam_limits()
	
	
	
	
	
	local room=player.room
	
	
	--x1,x2,y1,y2
	if room==1 then
		cam_limits={0,640,0,0}
	elseif room==2 then
		cam_limits={0,384,128,128}
	elseif room==3 then
		cam_limits={0,128,256,256}
	elseif room==4 then
		cam_limits={0,256,384,384}
	elseif room==5 then
		cam_limits={256,256,256,256}
	elseif room==6 then
		cam_limits={384,384,256,256}
	elseif room==7 then
		cam_limits={384,512,384,384}
	elseif room==8 then
		cam_limits={512,512,128,128}
	elseif room==9 then
		cam_limits={512,512,256,256}
	elseif room==10 then
		cam_limits={640,640,128,384}
	elseif room==11 then
		cam_limits={768,768,0,384}
	elseif room==12 then
		cam_limits={896,896,0,384}
	else
		cam_limits={10,10,10,10}
	end
	
	cam_min_x=cam_limits[1]
	cam_max_x=cam_limits[2]
	cam_min_y=cam_limits[3]
	cam_max_y=cam_limits[4]
	
end
-->8
--update_room
function update_room()

local room=player.room
	
	--brick1.broken=false
	--brick2.broken=false
	--brick3.broken=false
	--brick4.broken=false
	--brick5.broken=false
	
	if room==1 then
		door1={id=1,sp1=closex,sp2=tubex,x1=8,y1=24,x2=0,y2=24,w=1,h=2,xrot=true,yrot=false,dest=10}
		door2={id=2,sp1=closey,sp2=tubey,x1=440,y1=8,x2=440,y2=0,w=2,h=1,xrot=false,yrot=true,dest=5}
		door3={id=3,sp1=closey,sp2=tubey,x1=568,y1=112,x2=568,y2=120,w=2,h=1,xrot=false,yrot=false,dest=6}
		
		--brick1
		brick1.sp=125 brick1.x=64 brick1.y=88
		if brick1.broken then
			brick1.sp=127
		end
		--brick2
		brick2.sp=125 brick2.x=384 brick2.y=104
		if brick2.broken then
			brick2.sp=127
		end
		--brick3
		brick3.sp=124 brick3.x=536 brick3.y=104
		if brick3.broken then
			brick3.sp=127
		end
		--brick4
		brick4.sp=124 brick4.x=624 brick4.y=104
		if brick4.broken then
			brick4.sp=127
		end
		--brick5
		brick5.sp=124 brick5.x=640 brick5.y=24
		if brick5.broken then
			brick5.sp=127
		end
		--brick6
		brick6.sp=125 brick6.x=696 brick6.y=24
		if brick6.broken then
			brick6.sp=127
		end
		
	elseif room==2 then
		door1={id=1,sp1=closey,sp2=tubey,x1=56,y1=240,x2=56,y2=248,w=2,h=1,xrot=false,yrot=false,dest=5}
		door2={id=2,sp1=closey,sp2=tubey,x1=56,y1=136,x2=56,y2=128,w=2,h=1,xrot=false,yrot=true,dest=8}
		door3={id=3,sp1=closex,sp2=tubex,x1=496,y1=184,x2=504,y2=184,w=1,h=2,xrot=false,yrot=false,dest=11}
	
	
	elseif room==3 then
		door2={id=2,sp1=closey,sp2=tubey,x1=56,y1=264,x2=56,y2=256,w=2,h=1,xrot=false,yrot=true,dest=10}
	
	
	elseif room==4 then
		door1={id=1,sp1=closex,sp2=tubex,x1=8,y1=416,x2=0,y2=416,w=1,h=2,xrot=true,yrot=false,dest=9}
		door2={id=2,sp1=closey,sp2=tubey,x1=56,y1=392,x2=56,y2=384,w=2,h=1,xrot=false,yrot=true,dest=6}
		door3={id=3,sp1=closex,sp2=tubex,x1=368,y1=432,x2=376,y2=432,w=1,h=2,xrot=false,yrot=false,dest=12}
		door4={id=4,sp1=closex,sp2=tubex,x1=8,y1=464,x2=0,y2=464,w=1,h=2,xrot=true,yrot=false,dest=9}
		
		--brick1
		brick1.sp=124 brick1.x=256 brick1.y=472
		if brick1.broken then
			brick1.sp=127
		end
		--brick2
		brick2.sp=124 brick2.x=296 brick2.y=472
		if brick2.broken then
			brick2.sp=127
		end
		--brick3
		brick3.sp=125 brick3.x=336 brick3.y=472
		if brick3.broken then
			brick3.sp=127
		end
		
	
	elseif room==5 then
		door1={id=1,sp1=closey,sp2=tubey,x1=312,y1=264,x2=312,y2=256,w=2,h=1,xrot=false,yrot=true,dest=2}
		door2={id=2,sp1=closey,sp2=tubey,x1=312,y1=368,x2=312,y2=376,w=2,h=1,xrot=false,yrot=false,dest=1}
		
		--brick1
		brick1.sp=124 brick1.x=344 brick1.y=328
		if brick1.broken then
			brick1.sp=127
		end
		--brick2
		brick2.sp=124 brick2.x=328 brick2.y=328
		if brick2.broken then
			brick2.sp=127
		end
		--brick3
		brick3.sp=125 brick3.x=344 brick3.y=280
		if brick3.broken then
			brick3.sp=127
		end
		--brick4
		brick4.sp=124 brick4.x=328 brick4.y=280
		if brick4.broken then
			brick4.sp=127
		end
		
	elseif room==6 then
		door2={id=2,sp1=closey,sp2=tubey,x1=440,y1=368,x2=440,y2=376,w=2,h=1,xrot=false,yrot=false,dest=4}
		door3={id=3,sp1=closey,sp2=tubey,x1=440,y1=264,x2=440,y2=256,w=2,h=1,xrot=false,yrot=true,dest=1}
	
	
	elseif room==7 then
		door2={id=2,sp1=closex,sp2=tubex,x1=624,y1=472,x2=632,y2=472,w=1,h=2,xrot=false,yrot=false,dest=12}
	
	
	elseif room==8 then
		door2={id=2,sp1=closey,sp2=tubey,x1=568,y1=240,x2=568,y2=248,w=2,h=1,xrot=false,yrot=false,dest=2}
	
	
	elseif room==9 then
		door1={id=1,sp1=closex,sp2=tubex,x1=624,y1=288,x2=632,y2=288,w=1,h=2,xrot=false,yrot=false,dest=4}
		door4={id=4,sp1=closex,sp2=tubex,x1=624,y1=336,x2=632,y2=336,w=1,h=2,xrot=false,yrot=false,dest=4}
	
	elseif room==10 then
		door1={id=1,sp1=closex,sp2=tubex,x1=752,y1=152,x2=0760,y2=152,w=1,h=2,xrot=false,yrot=false,dest=1}
		door2={id=2,sp1=closey,sp2=tubey,x1=696,y1=496,x2=696,y2=504,w=2,h=1,xrot=false,yrot=false,dest=3}
	
	
	elseif room==11 then
		door1={id=1,sp1=closey,sp2=tubey,x1=824,y1=496,x2=824,y2=504,w=2,h=1,xrot=false,yrot=false,dest=12}
		door3={id=3,sp1=closex,sp2=tubex,x1=776,y1=184,x2=768,y2=184,w=1,h=2,xrot=true,yrot=false,dest=2}
		--brick1
		brick1.sp=124 brick1.x=888 brick1.y=336
		if brick1.broken then
			brick1.sp=127
		end
	
	
	elseif room==12 then
		door1={id=1,sp1=closey,sp2=tubey,x1=952,y1=8,x2=952,y2=0,w=2,h=1,xrot=false,yrot=true,dest=11}
		door2={id=2,sp1=closex,sp2=tubex,x1=904,y1=472,x2=896,y2=472,w=1,h=2,xrot=true,yrot=false,dest=7}
		door3={id=3,sp1=closex,sp2=tubex,x1=904,y1=176,x2=896,y2=176,w=1,h=2,xrot=true,yrot=false,dest=4}
	
	
	else
		door1={id=1,sp1=closex,sp2=tubex,x1=-128,y1=-128,x2=-128,y2=-128,w=1,h=2,xrot=true,yrot=false}
		door2={id=2,sp1=closex,sp2=tubex,x1=-128,y1=-128,x2=-128,y2=-128,w=1,h=2,xrot=false,yrot=false}
		door3={id=3,sp1=closex,sp2=tubex,x1=-128,y1=-128,x2=-128,y2=-128,w=2,h=1,xrot=false,yrot=false}
			
	end
	
	
	
end




function reset_door_state()

	brick1.broken=false
	brick2.broken=false
	brick3.broken=false
	brick4.broken=false
	brick5.broken=false
	brick6.broken=false
	
	
end
-->8
--map_maker
function map_maker()
	if player.y<128 then
		if player.x<126 then room_tracker.a1=true in_room=1
		elseif player.x<254 then room_tracker.a2=true in_room=2
		elseif player.x<382 then room_tracker.a3=true in_room=3
		elseif player.x<510 then room_tracker.a4=true in_room=4
		elseif player.x<638 then room_tracker.a5=true in_room=5
		elseif player.x<763 then room_tracker.a6=true in_room=6
		elseif player.x<894 then room_tracker.k1=true in_room=7
		else room_tracker.l1=true in_room=8
		end
	elseif player.y<256 then
		if player.x<126 then room_tracker.b1=true in_room=9
		elseif player.x<254 then room_tracker.b2=true in_room=10
		elseif player.x<382 then room_tracker.b3=true in_room=11
		elseif player.x<510 then room_tracker.b4=true in_room=12
		elseif player.x<638 then room_tracker.h1=true in_room=13
		elseif player.x<763 then room_tracker.j1=true in_room=14
		elseif player.x<894 then room_tracker.k2=true in_room=15
		else room_tracker.l2=true in_room=16
		end
	elseif player.y<384 then
		if player.x<126 then room_tracker.c1=true in_room=17
		elseif player.x<254 then room_tracker.c2=true in_room=18
		elseif player.x<382 then room_tracker.e1=true in_room=19
		elseif player.x<510 then room_tracker.f1=true in_room=20
		elseif player.x<638 then room_tracker.i1=true in_room=21
		elseif player.x<763 then room_tracker.j2=true in_room=22
		elseif player.x<894 then room_tracker.k3=true in_room=23
		else room_tracker.l3=true in_room=24
		end
	else
		if player.x<126 then room_tracker.d1=true in_room=25
		elseif player.x<254 then room_tracker.d2=true in_room=26
		elseif player.x<382 then room_tracker.d3=true in_room=27
		elseif player.x<510 then room_tracker.g1=true in_room=28
		elseif player.x<638 then room_tracker.g2=true in_room=29
		elseif player.x<763 then room_tracker.j3=true in_room=30
		elseif player.x<894 then room_tracker.k4=true in_room=31
		else room_tracker.l4=true in_room=32
		end
	end
	
end
	
function draw_map()
		
		
		if player.in_menu==true then
		rectfill(cam_x+8,cam_y+14,cam_x+119,cam_y+113,0)
		rect(cam_x+8,cam_y+14,cam_x+119,cam_y+113,1)
		--aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
		if room_tracker.a1 then
			rectfill(cam_x+22,cam_y+52,cam_x+33,cam_y+63,13)
			rectfill(cam_x+23,cam_y+53,cam_x+33,cam_y+62,mapcolor1)
		end
		if room_tracker.a2 then
			rectfill(cam_x+34,cam_y+52,cam_x+45,cam_y+63,13) 
			rectfill(cam_x+34,cam_y+53,cam_x+45,cam_y+62,mapcolor1)
		end
		if room_tracker.a3 then
			rectfill(cam_x+46,cam_y+52,cam_x+57,cam_y+63,13)
			rectfill(cam_x+46,cam_y+53,cam_x+57,cam_y+62,mapcolor1)
		end
		if room_tracker.a4 then	
			rectfill(cam_x+58,cam_y+52,cam_x+69,cam_y+63,13)
			rectfill(cam_x+58,cam_y+53,cam_x+69,cam_y+62,mapcolor1)
		end
		if room_tracker.a5 then
			rectfill(cam_x+70,cam_y+52,cam_x+81,cam_y+63,13)
			rectfill(cam_x+70,cam_y+53,cam_x+81,cam_y+62,mapcolor1)
		end
		if room_tracker.a6 then
			rectfill(cam_x+82,cam_y+52,cam_x+93,cam_y+63,13)
			rectfill(cam_x+82,cam_y+53,cam_x+92,cam_y+62,mapcolor1)
		end
--bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
		if room_tracker.b1 then
			rectfill(cam_x+58,cam_y+28,cam_x+69,cam_y+39,13)
			rectfill(cam_x+59,cam_y+29,cam_x+69,cam_y+38,mapcolor2)
		end
		if room_tracker.b2 then
			rectfill(cam_x+70,cam_y+28,cam_x+81,cam_y+39,13)
			rectfill(cam_x+70,cam_y+29,cam_x+81,cam_y+38,mapcolor2)
		end
		if room_tracker.b3 then
			rectfill(cam_x+82,cam_y+28,cam_x+93,cam_y+39,13)
			rectfill(cam_x+82,cam_y+29,cam_x+93,cam_y+38,mapcolor2)
		end
		if room_tracker.b4 then
			rectfill(cam_x+94,cam_y+28,cam_x+105,cam_y+39,13)
			rectfill(cam_x+94,cam_y+29,cam_x+104,cam_y+38,mapcolor2)
		end
--ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
		if room_tracker.c1 then 
			rectfill(cam_x+10,cam_y+88,cam_x+21,cam_y+99,13)
			rectfill(cam_x+11,cam_y+89,cam_x+21,cam_y+98,mapcolor3)
		end
		if room_tracker.c2 then
			rectfill(cam_x+22,cam_y+88,cam_x+33,cam_y+99,13)
			rectfill(cam_x+22,cam_y+89,cam_x+32,cam_y+98,mapcolor3)
		end
--ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
		if room_tracker.d1 then
			rectfill(cam_x+70,cam_y+76,cam_x+81,cam_y+87,13)
			rectfill(cam_x+71,cam_y+77,cam_x+81,cam_y+86,mapcolor4)
		end
		if room_tracker.d2 then
			rectfill(cam_x+82,cam_y+76,cam_x+93,cam_y+87,13)
			rectfill(cam_x+82,cam_y+77,cam_x+93,cam_y+86,mapcolor4)
		end
		if room_tracker.d3 then
			rectfill(cam_x+94,cam_y+76,cam_x+105,cam_y+87,13)
			rectfill(cam_x+94,cam_y+77,cam_x+104,cam_y+86,mapcolor4)
		end
--eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
		if room_tracker.e1 then
			rectfill(cam_x+58,cam_y+40,cam_x+69,cam_y+51,13)
			rectfill(cam_x+59,cam_y+41,cam_x+68,cam_y+50,mapcolor5)
		end
--fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
		if room_tracker.f1 then
			rectfill(cam_x+70,cam_y+64,cam_x+81,cam_y+75,13)
			rectfill(cam_x+71,cam_y+65,cam_x+80,cam_y+74,mapcolor6)
		end
--gggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg
		if room_tracker.g1 then
			rectfill(cam_x+82,cam_y+100,cam_x+93,cam_y+111,13)
			rectfill(cam_x+83,cam_y+101,cam_x+93,cam_y+110,mapcolor7)
		end
		if room_tracker.g2 then
			rectfill(cam_x+94,cam_y+100,cam_x+105,cam_y+111,13)
			rectfill(cam_x+94,cam_y+101,cam_x+104,cam_y+110,mapcolor7)
		end
--hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
		if room_tracker.h1 then
			rectfill(cam_x+58,cam_y+16,cam_x+69,cam_y+27,13)
			rectfill(cam_x+59,cam_y+17,cam_x+68,cam_y+26,mapcolor8)
		end
--iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii
		if room_tracker.i1 then
			rectfill(cam_x+58,cam_y+76,cam_x+69,cam_y+87,13)
			rectfill(cam_x+59,cam_y+77,cam_x+68,cam_y+86,mapcolor9)
		end
--jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj
		if room_tracker.j1 then
			rectfill(cam_x+10,cam_y+52,cam_x+21,cam_y+63,13)
			rectfill(cam_x+11,cam_y+53,cam_x+20,cam_y+63,mapcolor10)
		end
		if room_tracker.j2 then
			rectfill(cam_x+10,cam_y+64,cam_x+21,cam_y+75,13)
			rectfill(cam_x+11,cam_y+64,cam_x+20,cam_y+75,mapcolor10)
		end
		if room_tracker.j3 then
			rectfill(cam_x+10,cam_y+76,cam_x+21,cam_y+87,13)
			rectfill(cam_x+11,cam_y+76,cam_x+20,cam_y+86,mapcolor10)
		end
--kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
		if room_tracker.k1 then
			rectfill(cam_x+106,cam_y+16,cam_x+117,cam_y+27,13)
			rectfill(cam_x+107,cam_y+17,cam_x+116,cam_y+27,mapcolor11)
		end
		if room_tracker.k2 then
			rectfill(cam_x+106,cam_y+28,cam_x+117,cam_y+39,13)
			rectfill(cam_x+107,cam_y+28,cam_x+116,cam_y+39,mapcolor11)
		end
		if room_tracker.k3 then
			rectfill(cam_x+106,cam_y+40,cam_x+117,cam_y+51,13)
			rectfill(cam_x+107,cam_y+40,cam_x+116,cam_y+51,mapcolor11)
		end
		if room_tracker.k4 then
			rectfill(cam_x+106,cam_y+52,cam_x+117,cam_y+63,13)
			rectfill(cam_x+107,cam_y+52,cam_x+116,cam_y+62,mapcolor11)
		end
--llllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll
		if room_tracker.l1 then
			rectfill(cam_x+106,cam_y+64,cam_x+117,cam_y+75,13)
			rectfill(cam_x+107,cam_y+65,cam_x+116,cam_y+75,mapcolor12)
		end
		if room_tracker.l2 then
			rectfill(cam_x+106,cam_y+76,cam_x+117,cam_y+87,13)
			rectfill(cam_x+107,cam_y+76,cam_x+116,cam_y+87,mapcolor12)
		end
		if room_tracker.l3 then
			rectfill(cam_x+106,cam_y+88,cam_x+117,cam_y+99,13)
			rectfill(cam_x+107,cam_y+88,cam_x+116,cam_y+99,mapcolor12)
		end
		if room_tracker.l4 then
			rectfill(cam_x+106,cam_y+100,cam_x+117,cam_y+111,13)
			rectfill(cam_x+107,cam_y+100,cam_x+116,cam_y+110,mapcolor12)
		end
		
		
		if compass_item.obtained then
		
		if in_room==1 then
			rect(cam_x+21,cam_y+51,cam_x+34,cam_y+64,11)
		elseif in_room==2 then
			rect(cam_x+33,cam_y+51,cam_x+46,cam_y+64,11) 
		elseif in_room==3 then
			rect(cam_x+45,cam_y+51,cam_x+58,cam_y+64,11)
		elseif in_room==4 then
			rect(cam_x+57,cam_y+51,cam_x+70,cam_y+64,11)
		elseif in_room==5 then
				rect(cam_x+69,cam_y+51,cam_x+82,cam_y+64,11)
		elseif in_room==6 then
				rect(cam_x+81,cam_y+51,cam_x+94,cam_y+64,11)
	
		
		
		
		
		
		
		elseif in_room==9 then
			rect(cam_x+57,cam_y+27,cam_x+70,cam_y+40,11)
		elseif in_room==10 then
			rect(cam_x+69,cam_y+27,cam_x+82,cam_y+40,11)
		elseif in_room==11 then
			rect(cam_x+81,cam_y+27,cam_x+94,cam_y+40,11)
		elseif in_room==12 then
			rect(cam_x+93,cam_y+27,cam_x+106,cam_y+40,11)
		
		
		
		
		elseif in_room==17 then
			rect(cam_x+9,cam_y+87,cam_x+22,cam_y+100,11)
		elseif in_room==18 then
			rect(cam_x+21,cam_y+87,cam_x+34,cam_y+100,11)
		
		
		
		
		
		
		elseif in_room==25 then
			rect(cam_x+69,cam_y+75,cam_x+82,cam_y+88,11)
		elseif in_room==26 then
			rect(cam_x+81,cam_y+75,cam_x+94,cam_y+88,11)
		elseif in_room==27 then
			rect(cam_x+93,cam_y+75,cam_x+106,cam_y+88,11)
		
		
		
		
		
		elseif in_room==19 then
			rect(cam_x+57,cam_y+39,cam_x+70,cam_y+52,11)
		
		
		
		
		
		elseif in_room==20 then
			rect(cam_x+69,cam_y+63,cam_x+82,cam_y+76,11)
		
		
		
		
		elseif in_room==28 then
			rect(cam_x+81,cam_y+99,cam_x+94,cam_y+112,11)
		elseif in_room==29 then
			rect(cam_x+93,cam_y+99,cam_x+106,cam_y+112,11)
		
		
		
		
		elseif in_room==13 then
			rect(cam_x+57,cam_y+15,cam_x+70,cam_y+28,11)
		
		
		
		
		elseif in_room==21 then
			rect(cam_x+57,cam_y+75,cam_x+70,cam_y+88,11)
		
		
		
		elseif in_room==14 then
			rect(cam_x+9,cam_y+51,cam_x+22,cam_y+64,11)
		elseif in_room==22 then
			rect(cam_x+9,cam_y+63,cam_x+22,cam_y+76,11)
		elseif in_room==30 then
			rect(cam_x+9,cam_y+75,cam_x+22,cam_y+88,11)
		
		
		
		
		elseif in_room==7 then
			rect(cam_x+105,cam_y+15,cam_x+118,cam_y+28,11)
		elseif in_room==15 then
			rect(cam_x+105,cam_y+27,cam_x+118,cam_y+40,11)
		elseif in_room==23 then
			rect(cam_x+105,cam_y+39,cam_x+118,cam_y+52,11)
		elseif in_room==31 then
			rect(cam_x+105,cam_y+51,cam_x+118,cam_y+64,11)
		
		
		

		elseif in_room==8 then
			rect(cam_x+105,cam_y+63,cam_x+118,cam_y+76,11)
		elseif in_room==16 then
			rect(cam_x+105,cam_y+75,cam_x+118,cam_y+88,11)
		elseif in_room==24 then
			rect(cam_x+105,cam_y+87,cam_x+118,cam_y+100,11)
		elseif in_room==32 then
			rect(cam_x+105,cam_y+99,cam_x+118,cam_y+112,11)
		
		end
		
		end
	
	end
		
		
		
		
		
end