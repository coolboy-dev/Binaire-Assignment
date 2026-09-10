--intervium
--bY jACKIE dALTON
--mAIN
function _init()
	game_screen=0
	sound_mode=0
	game_menu_selection=1
	game_difficulty_selection=1
	game_preview_seed=flr(rnd(32768))
	game_help_selection=1
	game_menu_t=0
	game_pending_difficulty=1
	cartdata("play_times")
	load_difficulty_times()
	update_audio_menu()
end

function update_audio_menu()
	menuitem(1,"sound: "..(sound_mode==0 and "both" or sound_mode==1 and "music" or "sfx"),toggle_sound)
	menuitem(2,"walk speed: "..p_speed,update_walk_speed)
	menuitem(3,"explorer: "..(explorer_toggle and "toggle" or "hold"),
		toggle_explorer_mode)
	menuitem(4,"solid deco: "..(solid_deco and "on" or "off"),
		toggle_solid_deco)
end

function toggle_sound()
	sound_mode=(sound_mode+1)%3
	if sound_mode==2 then
		music(-1,500)
	elseif game_screen==2 and not game_won and not game_over
	and not goal_anim_active then
		music(0,1000)
	end
	update_audio_menu()
	return true
end

function play_sfx(n,c,o,l)
	if sound_mode==1 then return end
	if l then sfx(n,c,o,l)
	elseif c then sfx(n,c)
	else sfx(n) end
end

function update_walk_speed(buttons)
	local step=buttons&2>0 and 0.1 or buttons&1>0 and -0.1 or 0
	if step!=0 then
		p_speed=mid(0.5,flr((p_speed+step)*10+0.5)/10,2.5)
		update_audio_menu()
	end
	return true
end

function toggle_explorer_mode()
	explorer_toggle=not explorer_toggle
	map_control_active=false
	update_audio_menu()
	return true
end

function toggle_solid_deco()
	solid_deco=not solid_deco
	update_audio_menu()
	return true
end

--not A CHEAT CODE WHATSOEVER
function update_NOT_cheat()
	local zp=btnp(4) and not cz
	cz=btn(4)
	if cheat_result>0 then
		cheat_result_timer+=1
		if cheat_result==1 and cheat_result_timer>=15
		or cheat_result==2 and cheat_result_timer>=15 then
			cheat_result=0
			cheat_inputs={}
		end
		return true
	end
	if cheat_active then
		cheat_cursor_timer+=1
		local input=-1
		for b=0,5 do
			if b==4 and zp or b!=4 and btnp(b) then input=b break end
		end
		if input>=0 then
			cheat_inputs[cheat_index+1]=cheat_input_sprites[input+1]
			play_sfx(15)
			cheat_failed=cheat_failed or input!=totally_not_a_cheatcode[cheat_index+1]
			cheat_index+=1
			if cheat_index>=10 then
				if cheat_failed then
					play_sfx(28)
					cheat_result=1
				else
					play_sfx(17)
					reveal_special_rooms()
					cheat_result=2
				end
				cheat_active=false
				cheat_result_timer=0
				cheat_index=0
				cheat_failed=false
			end
		end
		return true
	end
	if cheat_tap_timer>0 then cheat_tap_timer-=1 end
	if zp then
		if btn(5) then
			cheat_tap_timer=0
		elseif cheat_tap_timer>0 then
			cheat_active=true
			cheat_cursor_timer=0
			cheat_inputs={}
			cheat_result=0
			cheat_index=0
			cheat_failed=false
			cheat_tap_timer=0
			play_sfx(27)
			return true
		else
			cheat_tap_timer=12
		end
	end
	return false
end

function draw_cheat_input()
	if not cheat_active and cheat_result==0 then return end
	local ox=0
	if cheat_result==1 then
		ox=cheat_wiggle[flr(cheat_result_timer/2)%4+1]
	elseif cheat_result==2 and flr(cheat_result_timer/2)%2==1 then
		return
	end
	for i=1,#cheat_inputs do
		local x=(i-1)%5*10+ox+70
		local y=flr((i-1)/5)*10+106
		spr(cheat_inputs[i],x,y)
	end
	if cheat_active then
		local i=cheat_index
		spr(163+flr(cheat_cursor_timer/2)%7,
			70+(i%5)*10,106+flr(i/5)*10)
	end
end

function start_game()
	game_screen=2
	if sound_mode!=2 then music(0,1000) end
	game_run_time=time()
	game_elapsed_time=0
	game_clear_time=0
	discovered={}
	discovered_lookup={}
	map_flags={}
	map_flag_lookup={}
	game_won=false
	game_over=false
	goal_anim_active=false
	goal_anim_timer=0
	cz=false
	to=false
	tp=false
	tc=0
	cheat_tap_timer=0
	game_keys_collected=0
	lives=3
	fall_active=false
	world_map_ready=false
	map_control_active=false
	map_control_x=3
	map_control_y=3
	world_size=difficulty_world_size
	local seed=flr(rnd(32768))
	srand(seed)
	world_seed=seed
	world_goal_x=1+room_hash(0,0,500)%(world_size-2)
	world_goal_y=1+room_hash(0,0,501)%(world_size-2)
	setup_special_rooms()
	world_root_mask=room_hash(0,0,400)%15+1
	if (world_root_mask==1 or world_root_mask==2
	 or world_root_mask==4 or world_root_mask==8)
	 and room_hash(0,0,402)%100>=25 then
		local dir=room_hash(0,0,403)%4
		while room_mask_has(world_root_mask,dir) do
			dir=(dir+1)%4
		end
		world_root_mask+=1<<((2-dir)%4)
	end
	world_root_dir=room_root_direction(world_root_mask)
	setup_safe_paths()
	load_room(0,0,-1)
end

function _update()
	if game_won or game_over then
		if btnp(5) then
			start_game()
		elseif btnp(4) then
			game_won=false
			game_over=false
			game_screen=0
		end
		return
	end
	if goal_anim_active then
		update_goal_anim()
		return
	end
	if to then
		uto()
		return
	end
	if game_screen==2 then
		game_elapsed_time=time()-game_run_time
	end
	if fall_active then
		update_fall()
		return
	end
	if game_screen==0 then
		update_main_menu()
		return
	elseif game_screen==1 then
		update_difficulty_menu()
		return
	elseif game_screen==6 then
		update_help_menu()
		return
	elseif game_screen>=3 then
		update_menu_transition()
		return
	end
	if update_NOT_cheat() then
		tc=0
		return
	end
	if utp() then return end
	if explorer_toggle then
		if btnp(5) then
			map_control_active=not map_control_active
			if map_control_active then
				map_control_x=3
				map_control_y=3
			end
		end
	elseif btn(5) then
		if not map_control_active then
			map_control_active=true
			map_control_x=3
			map_control_y=3
		end
	else
		map_control_active=false
	end
	if map_control_active then
		if p_x!=p_nx or p_y!=p_ny then
			p_x=approach(p_x,p_nx,p_speed)
			p_y=approach(p_y,p_ny,p_speed)
		end
		move_map_control()
		if btnp(4) then toggle_map_flag() end
	else
		p_move()
	end
	collect_keys()
	update_key_animations()
	check_win()
	update_room_tag()
	update_world_map()
end

function _draw()
	cls(0)
	if game_screen==0 then
		draw_main_menu(0)
	elseif game_screen==1 then
		draw_difficulty_menu(0)
	elseif game_screen==3 then
		draw_main_menu(-128*game_menu_t)
		draw_difficulty_menu(128*(1-game_menu_t))
	elseif game_screen==4 then
		draw_main_menu(-128+128*game_menu_t)
		draw_difficulty_menu(128*game_menu_t)
	elseif game_screen==5 then
		draw_difficulty_menu(128*game_menu_t)
	elseif game_screen==6 then
		draw_help_menu()
	else
		draw_game()
	end
	draw_cheat_input()
end

function draw_game()
	draw_room()
	if world_x==0 and world_y==0 then
		spr(128,room_center_x(),room_center_y())
	end
	draw_goal_marker()
	if to then spr(154-min(4,tt),room_center_x(),room_center_y()) end
	draw_key_marker()
	draw_room_tag()
	draw_world_map()
	draw_key_ui()
	draw_lives_ui()
	local elapsed=game_won and game_clear_time or game_elapsed_time
	print(format_time(elapsed),70,100,7)
	if fall_active then
		draw_falling_player()
	elseif not game_over and not game_won
	and not goal_anim_active and not to then
		if p_x!=p_nx or p_y!=p_ny then
			p_a_ct=p_a_ct or 0
			p_a_st=p_a_st or 0
			p_a_ct+=1
			if p_a_ct%2==0 then
				p_a_st+=1
				if p_a_st==4 then p_a_st=0 end
			end
			spr(p_a_sf+p_a_st,p_x,p_y)
		else
			spr(p_s,p_x,p_y)
		end
	end
	if game_won or game_over then
		rectfill(24,46,104,80,0)
		rect(24,46,104,80,10)
		if game_won then print("yOU win!",44,54,7)
		else print("gAME oVER",44,54,7) end
		print("pRESS x TO RETRY",28,62,7)
		print("pRESS z TO qUIT",28,70,7)
	end
end

-->8
--mENU
function update_main_menu()
	if btnp(2) or btnp(3) then
		game_menu_selection=3-game_menu_selection
		play_sfx(14)
	end
	if btnp(5) then
		play_sfx(16)
		if game_menu_selection==1 then
			game_screen=3
			game_menu_t=0
			game_difficulty_selection=1
			game_preview_seed+=1
		else
			game_screen=6
			game_help_selection=1
		end
	end
end

function update_help_menu()
	local d=btnp(1) and 1 or btnp(0) and -1
	if d then
		game_help_selection=(game_help_selection+d-1)%8+1
		play_sfx(15)
	end
	if game_help_selection==8 then
		cheat_hint_timer=(cheat_hint_timer+1)%250
	else
		cheat_hint_timer=0
	end
	if btnp(4) then
		game_screen=0
		play_sfx(18)
	end
end

function update_difficulty_menu()
	local d=btnp(1) and 1 or btnp(0) and -1
	if d then
		game_difficulty_selection=(game_difficulty_selection+d-1)%4+1
		game_preview_seed+=1
		play_sfx(15)
	end
	if btnp(4) then
		game_screen=4
		game_menu_t=0
		play_sfx(18)
		return
	end
	if btnp(5) then
		play_sfx(17)
		game_pending_difficulty=game_difficulty_selection
		game_screen=5
		game_menu_t=0
	end
end

function update_menu_transition()
	game_menu_t=min(game_menu_t+0.08,1)
	if game_menu_t<1 then return end
	if game_screen==3 then
		game_screen=1
	elseif game_screen==4 then
		game_screen=0
	else
		local choice=difficulty_options[game_pending_difficulty]
		difficulty_world_size=choice[2]
		difficulty_required_keys=choice[3]
		difficulty_mine_chance=choice[4]
		start_game()
	end
	game_menu_t=0
end

function draw_main_menu(offset)
	draw_menu_button("play",48,76-offset,game_menu_selection==1,
		btn(5) and game_menu_selection==1)
	draw_menu_button("help",48,94-offset,game_menu_selection==2,
		btn(5) and game_menu_selection==2)
	rectfill(0,0,125,9+offset,3)
	sspr(64,112,64,16,0,10+offset,128,32)
	sspr(64,96,64,16,0,offset,128,32)
	sspr(0,96,64,16,0,40+offset,128,32)
end

function draw_help_menu()
	for i=1,8 do
		spr(149,24+(i-1)*10,110)
	end
	spr(148,24+(game_help_selection-1)*10,110)
	if game_help_selection==3 then
		for i=0,8 do
			local c=map_tag_colors(i)
			if c==0 then c=7 end
			print(i<8 and i or 'x',27+i*9,41,c)
		end
		for i=0,8 do spr(50+i*3,24+i*9,48) end
	else
		local m=help_maps[game_help_selection]
		if m[1] then map(m[1],m[2],m[3],m[4],m[5],m[6]) end
	end
	if game_help_selection==8 then draw_cheat_hint() end
	print(help_titles[game_help_selection],0,70,12)
	print(help_bodies[game_help_selection],0,78,7)
end

function draw_cheat_hint()
	for i=0,5 do rectfill(40+i*8,40,35+i*8,45,0) end
	local t=cheat_hint_timer
	if t<160 then
		local p=t%16
		local c=p<4 and 7 or p<8 and 6 or p<12 and 5 or 0
		local x=30+totally_not_a_cheatcode[flr(t/16)+1]*8
		rectfill(x,40,x+5,45,c)
	end
end



function draw_difficulty_menu(offset)
	local choice=difficulty_options[game_difficulty_selection]
	draw_difficulty_preview(offset)
	print('bEST tIME:',47,94+offset,10)
	print(format_time(times[game_difficulty_selection]),50,102+offset,11)
	draw_menu_button(choice[1],48,80+offset,true,btn(5))
end

function draw_difficulty_preview(offset)
	local ol,ot,otg,otf,ott,osm,ost,ob=
		room_left,room_top,room_tag,room_tag_frame,
		room_tag_timer,room_smudges,room_stones,room_blocks
	local odn,ode,ods,odw=
		room_doors_north,room_doors_east,room_doors_south,room_doors_west
	local ox,oy,os,ose,orm,ord=
		world_x,world_y,world_size,world_seed,world_root_mask,world_root_dir
	local choice=difficulty_options[game_difficulty_selection]
	room_left=46
	room_top=24-offset
	room_tag=choice[5]
	room_tag_frame=2
	room_tag_timer=0
	room_smudges={}
	room_stones={}
	room_blocks={}
	world_size=choice[2]
	world_seed=game_preview_seed
	world_x=0
	world_y=0
	world_root_mask=1+room_hash(0,0,1801)%15
	world_root_dir=room_root_direction(world_root_mask)
	room_generate_doors()
	setup_room_smudges()
	setup_room_obstacles(1)
	setup_room_obstacles(2)
	draw_room()
	local dir=room_hash(0,0,1800+game_difficulty_selection)%4
	spr(75+dir,room_center_x(),room_center_y())
	room_left,room_top,room_tag,room_tag_frame,
		room_tag_timer,room_smudges,room_stones,room_blocks=
		ol,ot,otg,otf,ott,osm,ost,ob
	room_doors_north,room_doors_east,room_doors_south,room_doors_west=
		odn,ode,ods,odw
	world_x,world_y,world_size,world_seed,world_root_mask,world_root_dir=
		ox,oy,os,ose,orm,ord
end

function load_difficulty_times()
	times={}
	for i=1,4 do
		local t=dget(i-1)
		times[i]=t==0 and 99*60*60 or t
	end
end

function format_time(value)
	value=value or 0
	local hours=flr(value/3600)
	local minutes=flr(value/60)%60
	local seconds=flr(value)%60
	return (hours<10 and "0" or "")..hours..":"..
		sub("0"..minutes,-2)..":"..sub("0"..seconds,-2)
end

function draw_menu_button(label,x,y,hover,pressed)
	if hover then
		local arrow_shift=flr(sin(time())+1)-2
		spr(132,x+arrow_shift,y,1,1,true)
		spr(132,x+27-arrow_shift,y)
	end
	if pressed then
		rectfill(x+8,y+2,x+26,y+10,13)
		print(label,x+10,y+4,2)
	else
		rectfill(x+8,y+7,x+26,y+9,13)
		rectfill(x+8,y-2,x+26,y+6,7)
		print(label,x+10,y,13)
	end
end

function spr_r(s,x,y,a,w,h,scale,flip_x)
	w=w or 1
	h=h or 1
	scale=scale or 1
	if scale<=0 then return end
	local sw=w*8
	local sh=h*8
	local dw=max(1,flr(sw*scale))
	local dh=max(1,flr(sh*scale))
	local sx=(s%16)*8
	local sy=flr(s/16)*8
	local x0=flr(x+(sw-dw)/2)
	local y0=flr(y+(sh-dh)/2)
	local angle=a/360
	local sa=sin(angle)
	local ca=cos(angle)

	for ix=0,dw-1 do
		for iy=0,dh-1 do
			local dx=(ix+0.5-dw/2)/scale
			local dy=(iy+0.5-dh/2)/scale
			local xx=flr(dx*ca-dy*sa+sw/2)
			local yy=flr(dx*sa+dy*ca+sh/2)
			if xx>=0 and xx<sw and yy>=0 and yy<sh then
				if flip_x then xx=sw-1-xx end
				local col=sget(sx+xx,sy+yy)
				if col!=0 then pset(x0+ix,y0+iy,col) end
			end
		end
	end
end


function set_facing(dir)
	p_s=75+dir
	p_a_sf=79+dir*4
end

function p_move()
	if p_x==p_nx and p_y==p_ny then
		local dir=-1
		local tx=p_nx
		local ty=p_ny

		if btn(1) then --eAST
			dir=1
			tx+=8
		elseif btn(0) then --wEST
			dir=3
			tx-=8
		elseif btn(3) then --sOUTH
			dir=0
			ty+=8
		elseif btn(2) then --nORTH
			dir=2
			ty-=8
		end

		if dir>=0 then
			set_facing(dir)
			if room_sprite_at(tx,ty)==109 then
				p_nx=tx
				p_ny=ty
			elseif try_room_transition(dir) then
				return
			end
			p_a_st=0
			p_a_ct=0
		end
	end

	p_x=approach(p_x,p_nx,p_speed)
	p_y=approach(p_y,p_ny,p_speed)
end

-->8
--mAIN GAME LOOP
function move_map_control()
	if btnp(1) then map_control_x=min(map_control_x+1,6) end
	if btnp(0) then map_control_x=max(map_control_x-1,0) end
	if btnp(3) then map_control_y=min(map_control_y+1,6) end
	if btnp(2) then map_control_y=max(map_control_y-1,0) end
end


function utp()
	if tp then
		local dx=btnp(1) and 1 or btnp(0) and -1 or 0
		local dy=btnp(3) and 1 or btnp(2) and -1 or 0
		if dx!=0 then tx=wrap_coord(tx+dx) end
		if dy!=0 then ty=wrap_coord(ty+dy) end
		if dx!=0 or dy!=0 then
			world_map_target_x=tx
			world_map_target_y=ty
		end
		if btnp(5) then
			tp=false
			to=true
			tt=0
			play_sfx(13,0)
		end
		update_world_map()
		return true
	end
	if btn(4) and p_x==p_nx and p_y==p_ny
	and not btn(0) and not btn(1) and not btn(2) and not btn(3) then
		tc+=1
		if tc>=45 then
			tc=0
			tp=true
			goal_anim_active=true
			goal_anim_timer=0
			music(-1,1000)
			return true
		end
	else
		tc=0
	end
end

function uto()
	tt+=1
	if tt>=5 then
		load_room(tx,ty,-1,true)
		local x=room_center_x()
		local y=room_center_y()
		if room_has_obstacle(x,y) then
			for d=0,3 do
				local dx=d==1 and 8 or d==3 and -8 or 0
				local dy=d==0 and 8 or d==2 and -8 or 0
				if room_sprite_at(x+dx,y+dy)==109 then
					x+=dx
					y+=dy
					break
				end
			end
		end
		p_x=x
		p_y=y
		p_nx=x
		p_ny=y
		to=false
	end
end

function lose_life()
	if lives<=0 then return end
	lives=max(lives-1,0)
end

function begin_fall(entry_side)
	fall_active=true
	fall_timer=0
	fall_entry_side=entry_side
	fall_start_x=p_x
	fall_start_y=p_y
	fall_flip_x=false
	fall_sprite=entry_side==2 and 95 or entry_side%2==1 and 97 or 99
	fall_dx=entry_side==1 and -1 or entry_side==3 and 1 or 0
	fall_dy=entry_side==0 and -1 or entry_side==2 and 1 or 0
	fall_flip_x=entry_side==1
	fall_center_x=fall_start_x+fall_dx*10
	fall_center_y=fall_start_y+fall_dy*10
end

function update_fall()
	fall_timer+=1
	fall_angle=(fall_angle+12)%360
	if fall_timer<32+28 then return end
	fall_active=false
	if lives<=0 then
		game_over=true
	else
		load_room(world_x,world_y,fall_entry_side,true)
	end
end

function draw_falling_player()
	local frame
	local t=fall_timer
	local pf=32
	local x=fall_start_x
	local y=fall_start_y
	if t<pf then
		frame=fall_sprite+flr(t/4)%2
		local step=flr(t*10/pf)
		x+=fall_dx*step
		y+=fall_dy*step
		spr(frame,x,y,1,1,fall_flip_x)
	else
		local progress=(t-pf)/28
		progress=min(progress,1)
		x=fall_center_x
		y=fall_center_y
		local size=flr(8*(1-progress))
		if size>0 then
			frame=101+flr((t-pf)/1)%8
			spr_r(frame,x,y,fall_angle,1,1,size/8,fall_flip_x)
		end
	end
end

function map_flag_at(x,y)
	x=wrap_coord(x)
	y=wrap_coord(y)
	return map_flag_lookup[x+y*world_size]
end

function remove_map_flag(x,y)
	x=wrap_coord(x)
	y=wrap_coord(y)
	local id=x+y*world_size
	local flag=map_flag_lookup[id]
	if flag then
		del(map_flags,flag)
		map_flag_lookup[id]=nil
	end
end

function toggle_map_flag()
	local x=wrap_coord(flr(world_map_camera_x)+map_control_x-3)
	local y=wrap_coord(flr(world_map_camera_y)+map_control_y-3)
	local id=x+y*world_size
	local flag=map_flag_lookup[id]
	if flag then
		remove_map_flag(x,y)
	elseif room_is_discovered(x,y) then
		return
	else
		flag={x=x,y=y}
		add(map_flags,flag)
		map_flag_lookup[id]=flag
	end
end

function approach(value,target,amount)
	if value<target then
		return min(value+amount,target)
	elseif value>target then
		return max(value-amount,target)
	end
	return value
end

-->8
--rOOMS LOGIC
function room_is_hole(col,row)
	return room_tag==8
		and col>0 and col<5-1
		and row>0 and row<5-1
end

function room_is_door_tile(col,row)
	return (row==0 and room_doors_north==col)
		or (row==5-1 and room_doors_south==col)
		or (col==0 and room_doors_west==row)
		or (col==5-1 and room_doors_east==row)
end

function draw_room()
	local inner,outer,middle=map_tag_colors(room_tag)
	local l=room_left
	local t=room_top
	local s=5
	local wx=world_x
	local wy=world_y
	pal(13,inner)
	pal(1,outer)

	for row=0,s-1 do
		for col=0,s-1 do
			if not room_is_hole(col,row) then
				spr(109,l+col*8,t+row*8)
			end
		end
	end
	pal(1,middle)
	pal(2,outer)
	for smudge in all(room_smudges) do
		spr(smudge.sprite,smudge.x,smudge.y)
	end
	for stone in all(room_stones) do
		if solid_deco or stone.sprite<143 then
			spr(stone.sprite,stone.x,stone.y)
		end
	end
	if solid_deco then
		for block in all(room_blocks) do
			spr(block.sprite,block.x,block.y)
		end
	end
	pal(0)
	pal(13,inner)
	pal(1,outer)
	pal(2,middle)

	for col=0,s-1 do
		local north=114
		local south=115
		if room_doors_north==col then
			north=110
		elseif room_hash(wx,wy,1500+col)%4==0 then
			north=147
		end
		if room_doors_south==col then south=112 end
		spr(north,l+col*8,t-8)
		spr(south,l+col*8,t+s*8)
	end

	for row=0,s-1 do
		local west=116
		local east=117
		if room_doors_west==row then
			west=113
		elseif room_hash(wx,wy,1600+row)%4==0 then
			west=145
		end
		if room_doors_east==row then
			east=111
		elseif room_hash(wx,wy,1700+row)%4==0 then
			east=146
		end
		spr(west,l-8,t+row*8)
		spr(east,l+s*8,t+row*8)
	end

	spr(118,l-8,t-8)
	spr(119,l+s*8,t-8)
	spr(120,l+s*8,t+s*8)
	spr(121,l-8,t+s*8)

	if room_tag==8 then
		for col=1,s-2 do
			spr(115,l+col*8,t+8)
		end
	end
	pal(0)
end

function setup_room_smudges()
	room_smudges={}
	local s=5
	local wx=world_x
	local wy=world_y
	local occupied={}
	local amount=room_hash(wx,wy,800)%3
	local tries=0
	local max_tries=s*s*4
	while #room_smudges<amount and tries<max_tries do
		local col=room_hash(wx,wy,801+tries*2)%s
		local row=room_hash(wx,wy,802+tries*2)%s
		local id=col+row*s
		if not room_is_hole(col,row) and not occupied[id] then
			occupied[id]=true
			local sprite=141+room_hash(wx,wy,900+tries)%2
			add(room_smudges,{sprite=sprite,
				x=room_left+col*8,y=room_top+row*8})
		end
		tries+=1
	end
end

function setup_room_obstacles(kind)
	local list=kind==1 and room_stones or room_blocks
	local source=kind==1 and room_smudges or room_stones
	list={}
	if kind==1 then room_stones=list else room_blocks=list end
	local s=5
	local wx=world_x
	local wy=world_y

	local occupied={}
	for object in all(source) do
		local col=(object.x-room_left)/8
		local row=(object.y-room_top)/8
		occupied[col+row*s]=true
	end

	local salt=kind==1 and 1000 or 1300
	local amount=3+room_hash(wx,wy,salt)%3
	local tries=0
	local max_tries=s*s*4
	while #list<amount and tries<max_tries do
		local col=room_hash(wx,wy,salt+1+tries*2)%s
		local row=room_hash(wx,wy,salt+2+tries*2)%s
		local id=col+row*s
		local door_tile=room_is_door_tile(col,row)
		if not room_is_hole(col,row) and not occupied[id] and not door_tile then
			occupied[id]=true
			local variant=room_hash(wx,wy,salt+100+tries)%5
			local sprite=kind==1 and
				(variant<3 and 138+variant or 143+variant-3) or 133+variant
			add(list,{sprite=sprite,x=room_left+col*8,
				y=room_top+row*8})
		end
		tries+=1
	end
	if kind==2 then repair_room_obstacles() end
end

function room_walkable_cell(col,row)
	if col<0 or col>=5 or row<0 or row>=5 then
		return false
	end
	if room_is_hole(col,row) then
		return false
	end
	local x=room_left+col*8
	local y=room_top+row*8
	return not room_has_obstacle(x,y)
end

function room_has_obstacle(x,y)
	if not solid_deco then return false end
	for stone in all(room_stones) do
		if stone.x==x and stone.y==y and stone.sprite>=143 then
			return true
		end
	end
	for block in all(room_blocks) do
		if block.x==x and block.y==y then
			return true
		end
	end
end
--mAZE GEN 😐⌂⧗
function room_doors_connected()
	local s=5
	local doors={}
	if room_doors_north!=nil then
		add(doors,{col=room_doors_north,row=0})
	end
	if room_doors_east!=nil then
		add(doors,{col=s-1,row=room_doors_east})
	end
	if room_doors_south!=nil then
		add(doors,{col=room_doors_south,row=s-1})
	end
	if room_doors_west!=nil then
		add(doors,{col=0,row=room_doors_west})
	end
	local special=room_is_special(world_x,world_y)
	if #doors<1 then return not special end
	if #doors<2 and not special then return true end
	if special then
		add(doors,{col=flr(s/2),row=flr(s/2)})
	end
	if not room_walkable_cell(doors[1].col,doors[1].row) then
		return false
	end

	local visited={}
	local queue={}
	local head=1
	local tail=1
	local start_id=doors[1].col+doors[1].row*s
	queue[1]=start_id
	visited[start_id]=true
	while head<=tail do
		local id=queue[head]
		head+=1
		local col=id%s
		local row=flr(id/s)
		for dir=0,3 do
			local next_col=col
			local next_row=row
			if dir==0 then next_row+=1 end
			if dir==1 then next_col+=1 end
			if dir==2 then next_row-=1 end
			if dir==3 then next_col-=1 end
			if room_walkable_cell(next_col,next_row) then
				local next_id=next_col+next_row*s
				if not visited[next_id] then
					visited[next_id]=true
					tail+=1
					queue[tail]=next_id
				end
			end
		end
	end

	for door in all(doors) do
		local id=door.col+door.row*s
		if not visited[id] then return false end
	end
	return true
end

function repair_room_obstacles()
	if room_doors_connected() then return end
	local obstacles={}
	for block in all(room_blocks) do
		add(obstacles,{list=room_blocks,item=block})
	end
	for stone in all(room_stones) do
		if stone.sprite>=143 then
			add(obstacles,{list=room_stones,item=stone})
		end
	end
	for obstacle in all(obstacles) do
		if room_doors_connected() then return end
		del(obstacle.list,obstacle.item)
	end
end

function room_is_special(x,y)
	x=wrap_coord(x)
	y=wrap_coord(y)
	return (x==0 and y==0)
	or (x==world_goal_x and y==world_goal_y)
	or is_key_room(x,y)
end

function room_is_protected(x,y)
	if room_is_special(x,y) then return true end
	for dy=-1,1 do
		for dx=-1,1 do
			if not (dx==0 and dy==0)
			and room_is_special(x+dx,y+dy) then
				return true
			end
		end
	end
	return false
end

function is_raw_mine_room(x,y)
	return not room_is_protected(x,y)
		and room_hash(x,y,700)%100<difficulty_mine_chance
end

function is_mine_room(x,y)
	x=wrap_coord(x)
	y=wrap_coord(y)
	local id=x+y*world_size
	if world_safe_path and world_safe_path[id] then return false end
	return is_raw_mine_room(x,y)
end

function find_room_path(target_x,target_y,avoid_mines)
	target_x=wrap_coord(target_x)
	target_y=wrap_coord(target_y)
	local target_id=target_x+target_y*world_size
	local parents={}
	local queue={}
	local head=1
	local tail=1
	queue[1]=0
	parents[0]=-1

	while head<=tail do
		local id=queue[head]
		head+=1
		if id==target_id then return parents end

		local x=id%world_size
		local y=flr(id/world_size)
		local first=room_hash(x,y,950)%4
		for offset=0,3 do
			local dir=(first+offset)%4
			if room_edge_open(x,y,dir) then
				local nx,ny=room_neighbor(x,y,dir)
				local next_id=nx+ny*world_size
				if parents[next_id]==nil
				and (not avoid_mines or not is_mine_room(nx,ny)) then
					parents[next_id]=id
					tail+=1
					queue[tail]=next_id
				end
			end
		end
	end
	return nil
end

function make_path_safe(target_x,target_y)
	local parents=find_room_path(target_x,target_y,true)
	if not parents then
		parents=find_room_path(target_x,target_y,false)
	end
	if not parents then return end

	local id=wrap_coord(target_x)+wrap_coord(target_y)*world_size
	while id>=0 do
		local x=id%world_size
		local y=flr(id/world_size)
		if is_raw_mine_room(x,y) then
			world_safe_path[id]=true
		end
		id=parents[id]
	end
end

function setup_safe_paths()
	world_safe_path={}
	for key in all(key_rooms) do
		make_path_safe(key.x,key.y)
	end
	make_path_safe(world_goal_x,world_goal_y)
end

function room_tag_at(x,y)
	if is_mine_room(x,y) then return 8 end
	local mines=0
	for dy=-1,1 do
		for dx=-1,1 do
			if not (dx==0 and dy==0)
			and is_mine_room(x+dx,y+dy) then
				mines+=1
			end
		end
	end
	return min(mines,7)
end

function update_room_tag()
	if room_tag_frame<2 then
		room_tag_timer+=1
		if room_tag_timer>=3 then
			room_tag_timer=0
			room_tag_frame+=1
		end
	end
end

function draw_room_tag()
	local x=120
	local y=32
	spr(48+room_tag*3+room_tag_frame,x,y)
end

function room_center_x()
	return room_left+flr(5/2)*8
end

function room_center_y()
	return room_top+flr(5/2)*8
end

function draw_goal_marker()
	if world_x==world_goal_x and world_y==world_goal_y then
		local goal_sprite=all_keys_collected() and 130 or 129
		spr(goal_sprite,room_center_x(),room_center_y())
	end
	if goal_anim_active then draw_goal_anim() end
end

function draw_key_marker()
	local key=is_key_room(world_x,world_y)
	if key and (not key.collected or key.animating) then
		local frame
		local y=room_center_y()
		if key.animating then
			frame=flr(key.anim_phase)%11
			local progress=key.anim_time/18
			y-=progress*16
		else
			frame=flr(time()*16)%11
			y+=sin(time()*2)*2
		end
		local flip_x=frame>=3 and frame<=7
		spr(key_sprites[frame+1],room_center_x(),y,1,1,flip_x)
	end
end

function draw_key_ui()
	for index=1,difficulty_required_keys do
		local y=40+(index-1)*8
		pal(5,index<=game_keys_collected and 10 or 5)
		spr(122,58,y)
		pal(0)
	end
end

function draw_lives_ui()
	for index=1,3 do
		spr(126+(index>lives and 1 or 0),
			70+(index-1)*8,33)
	end
end

-->8
--kEYS
function setup_special_rooms()
	key_rooms={}
	for index=1,difficulty_required_keys do
		local slot=1+room_hash(0,0,600+index)%(world_size*world_size-1)
		while true do
			local x=slot%world_size
			local y=flr(slot/world_size)
			if not (x==0 and y==0)
			and not (x==world_goal_x and y==world_goal_y)
			and not is_key_room(x,y) then
				add(key_rooms,{x=x,y=y})
				break
			end
			slot=(slot+1)%(world_size*world_size)
			if slot==0 then slot=1 end
		end
	end
end

function is_key_room(x,y)
	for key in all(key_rooms) do
		if key.x==x and key.y==y then return key end
	end
	return nil
end

function collect_keys()
	local key=is_key_room(world_x,world_y)
	if key and not key.collected
	and p_x==room_center_x() and p_y==room_center_y() then
		key.collected=true
		key.animating=true
		key.anim_time=0
		key.anim_phase=0
		game_keys_collected+=1
		play_sfx(9)
	end
end

function update_key_animations()
	for key in all(key_rooms) do
		if key.animating then
			local progress=key.anim_time/18
			local speed=16+8*progress
			key.anim_phase+=speed/30
			key.anim_time+=1
			if key.anim_time>=18 then
				key.animating=false
			end
		end
	end
end

function all_keys_collected()
	return game_keys_collected>=difficulty_required_keys
end

function check_win()
	if all_keys_collected()
	and world_x==world_goal_x and world_y==world_goal_y
	and p_x==room_center_x() and p_y==room_center_y()
	and not goal_anim_active then
		game_clear_time=game_elapsed_time
		if game_clear_time<times[game_pending_difficulty] then
			times[game_pending_difficulty]=game_clear_time
			dset(game_pending_difficulty-1,game_clear_time)
		end
		music(-1,1000)
		goal_anim_active=true
		goal_anim_timer=0
	end
end

function update_goal_anim()
	local t=goal_anim_timer
	local end_start=60+4
	local total=end_start+5
	if t<end_start then
		local p=t/max(1,end_start-1)
		local a=flr(63*p*p*p)
		local sound=11
		if a>=32 then
			sound=12
			a-=32
		end
		play_sfx(sound,0,a,a)
	elseif t==end_start then
		play_sfx(13,0)
	end
	goal_anim_timer+=1
	if goal_anim_timer>=total then
		goal_anim_active=false
		if tp then
			tx=world_x
			ty=world_y
		else
			game_won=true
		end
	end
end

function draw_goal_anim()
	local t=goal_anim_timer
	local lf=60
	local last=lf+4+5-1
	local y=room_center_y()-16*min(1,t/max(1,last))
	local frame
	local flash=false
	if t<lf then
		local start=4
		local finish=1
		local fs=start>finish and lf/2 or 0
		local phase
		if t<fs then
			local delay=ceil(start-t*(start-finish)/fs)
			phase=t/delay
		else
			local progress=(t-fs)/(lf-fs)
			local speed=1+progress
			phase=fs/finish+(t-fs)*speed/finish
		end
		frame=101+flr(phase)%8
	elseif t<lf+4 then
		frame=101+flr(t)%8
		flash=true
	else
		frame=150+min(4,t-lf-4)
	end
	if flash then
		local c=6
		if t>=lf+2 then c=7 end
		pal(1,c)
		pal(7,c)
		pal(9,c)
		pal(10,c)
		pal(12,c)
	end
	spr(frame,room_center_x(),y)
	if flash then pal() end
end

-->8
--mAPPING THE WORLDMAP
function room_generate_doors()
	room_doors_north=nil
	room_doors_east=nil
	room_doors_south=nil
	room_doors_west=nil

	if room_edge_open(world_x,world_y,2) then
		room_doors_north=room_door_position(2)
	end
	if room_edge_open(world_x,world_y,1) then
		room_doors_east=room_door_position(1)
	end
	if room_edge_open(world_x,world_y,0) then
		room_doors_south=room_door_position(0)
	end
	if room_edge_open(world_x,world_y,3) then
		room_doors_west=room_door_position(3)
	end
end

function room_hash(x,y,salt)
	local value=world_seed+x*92821+y*68917+salt*12347
	value=abs(value*37+17)%32768
	return value
end

function room_parent_dir(x,y)
	if x==0 and y==0 then return -1 end
	local target_x=0
	local target_y=0
	if world_root_dir==0 then target_y=1 end
	if world_root_dir==1 then target_x=1 end
	if world_root_dir==2 then target_y=world_size-1 end
	if world_root_dir==3 then target_x=world_size-1 end

	local dx=target_x-x
	local dy=target_y-y
	if dx==0 and dy==0 then return -1 end
	local chosen=-1
	if dx!=0 and dy!=0 then
		if room_hash(x,y,90)%2==0 then
			if dx>0 then chosen=1 else chosen=3 end
		else
			if dy>0 then chosen=0 else chosen=2 end
		end
	elseif dx!=0 then
		if dx>0 then chosen=1 else chosen=3 end
	else
		if dy>0 then chosen=0 else chosen=2 end
	end
	if room_would_enter_root(x,y,chosen) then
		return room_opposite(chosen)
	end
	return chosen
end

function room_would_enter_root(x,y,dir)
	local nx,ny=room_neighbor(x,y,dir)
	return nx==0 and ny==0
end

function wrap_coord(value)
	value=value%world_size
	if value<0 then value+=world_size end
	return value
end

function room_neighbor(x,y,dir)
	if dir==0 then return x,wrap_coord(y+1) end
	if dir==1 then return wrap_coord(x+1),y end
	if dir==2 then return x,wrap_coord(y-1) end
	return wrap_coord(x-1),y
end

function room_opposite(dir)
	return (dir+2)%4
end

function room_edge_open(x,y,dir)
	local nx,ny=room_neighbor(x,y,dir)
	if x==0 and y==0 then
		return room_mask_has(world_root_mask,dir)
	elseif nx==0 and ny==0 then
		return room_mask_has(world_root_mask,room_opposite(dir))
	end
	local parent=room_parent_dir(x,y)
	local neighbor_parent=room_parent_dir(nx,ny)

	if parent==dir or neighbor_parent==room_opposite(dir) then
		return true
	end

	local edge_x=x
	local edge_y=y
	local edge_dir=dir
	if dir==3 then
		edge_x=wrap_coord(x-1)
		edge_dir=1
	elseif dir==2 then
		edge_y=wrap_coord(y-1)
		edge_dir=0
	end
	return room_hash(edge_x,edge_y,edge_dir+100)%100<28
end

function room_door_position(dir)
	if room_tag==8 then
		return 1+room_hash(world_x,world_y,dir+200)%(5-2)
	end
	return room_hash(world_x,world_y,dir+200)%5
end

function room_mask_has(mask,dir)
	return mask&1<<((2-dir)%4)>0
end

function room_root_direction(mask)
	local first=room_hash(0,0,401)%4
	for offset=0,3 do
		local dir=(first+offset)%4
		if room_mask_has(mask,dir) then return dir end
	end
end

function load_room(x,y,entry_side,skip_hazard)
	x=wrap_coord(x)
	y=wrap_coord(y)
	world_x=x
	world_y=y
	if not world_map_ready then
		world_map_camera_x=x
		world_map_camera_y=y
		world_map_ready=true
	end
	local target_x=x
	local target_y=y
	while target_x-world_map_camera_x>world_size/2 do target_x-=world_size end
	while target_x-world_map_camera_x<-world_size/2 do target_x+=world_size end
	while target_y-world_map_camera_y>world_size/2 do target_y-=world_size end
	while target_y-world_map_camera_y<-world_size/2 do target_y+=world_size end
	world_map_target_x=target_x
	world_map_target_y=target_y
	room_tag=room_tag_at(x,y)
	room_tag_frame=entry_side<0 and 2 or 0
	room_tag_timer=0
	room_generate_doors()
	setup_room_smudges()
	setup_room_obstacles(1)
	setup_room_obstacles(2)
	mark_room_discovered(x,y)
	if entry_side>=0 then remove_map_flag(x,y) end
	if entry_side>=0 and room_tag==8 and not skip_hazard then lose_life() end
	if entry_side>=0 then play_sfx(room_tag) end

	local px=room_left
	local py=room_top
	if entry_side<0 then
		px=room_center_x()
		py=room_center_y()
	elseif entry_side==0 then
		px=room_left+room_doors_south*8
		py=room_top+(5-1)*8
	elseif entry_side==1 then
		px=room_left+(5-1)*8
		py=room_top+room_doors_east*8
	elseif entry_side==2 then
		px=room_left+room_doors_north*8
		py=room_top
	elseif entry_side==3 then
		px=room_left
		py=room_top+room_doors_west*8
	end

	p_x=px
	p_y=py
	p_nx=px
	p_ny=py
	if entry_side>=0 and room_tag==8 and not skip_hazard then
		begin_fall(entry_side)
	end
end

function try_room_transition(dir)
	local wx=world_x
	local wy=world_y
	local col=(p_nx-room_left)/8
	local row=(p_ny-room_top)/8

	if dir==0 and row==5-1 and room_doors_south==col then
		load_room(wx,wy+1,2)
		return true
	elseif dir==1 and col==5-1 and room_doors_east==row then
		load_room(wx+1,wy,3)
		return true
	elseif dir==2 and row==0 and room_doors_north==col then
		load_room(wx,wy-1,0)
		return true
	elseif dir==3 and col==0 and room_doors_west==row then
		load_room(wx-1,wy,1)
		return true
	end
end

function room_sprite_at(x,y)
	local col=(x-room_left)/8
	local row=(y-room_top)/8

	if col>=0 and col<5 and row>=0 and row<5 then
		if not room_is_hole(col,row) and not room_has_obstacle(x,y) then
			return 109
		end
	end
end

function unknown_room_mark_at(x,y)
	if room_is_discovered(x,y) then return false end
	if map_flag_at(x,y) then return false end
	local possible=false
	for dy=-1,1 do
		for dx=-1,1 do
			if not (dx==0 and dy==0) then
				local nx=wrap_coord(x+dx)
				local ny=wrap_coord(y+dy)
				local tag=discovered_lookup[nx+ny*world_size]
				if tag==0 then return false end
				if tag and tag<8 then
					if room_effective_tag(nx,ny,tag)==0 then
						return false
					end
					possible=true
				end
			end
		end
	end
	return possible
end

-->8
--wORLD MAP
function draw_world_map()
	local map_ax=71
	local map_ay=42
	local map_size=7
	local map_bx=map_ax+map_size*8-1
	local map_by=map_ay+map_size*8-1
	local map_center=(map_size-1)/2*8

	local center_x=map_ax+map_center
	local center_y=map_ay+map_center
	clip(map_ax,map_ay,map_size*8,map_size*8)
	if map_control_active then
		local cx=71+map_control_x*8
		local cy=42+map_control_y*8
		local rx=max(map_ax,min(cx-7,map_bx-21))
		local ry=max(map_ay,min(cy-7,map_by-21))
		rect(rx,ry,rx+21,ry+21,5)
	end
	local radius=flr(map_size/2)
	for ox=-radius,radius do
		for oy=-radius,radius do
			local x=wrap_coord(flr(world_map_camera_x)+ox)
			local y=wrap_coord(flr(world_map_camera_y)+oy)
			if unknown_room_mark_at(x,y) then
				local sx,sy=map_screen_pos(x,y,center_x,center_y)
				if map_in_view(sx,sy) then
					spr(131,sx,sy)
				end
			end
		end
	end
	for entry in all(discovered) do
		local sx,sy=map_screen_pos(entry.x,entry.y,center_x,center_y)
		if map_in_view(sx,sy) then
			local current=entry.x==world_x and entry.y==world_y
			draw_map_sprite(entry.sprite,sx,sy,entry.tag,current,
				map_special_inner_for_entry(entry))
		end
	end
	for flag in all(map_flags) do
		local sx,sy=map_screen_pos(flag.x,flag.y,center_x,center_y)
		if map_in_view(sx,sy) then
			spr(31,sx,sy)
		end
	end
	if map_control_active then
		spr(47,71+map_control_x*8,42+map_control_y*8)
	elseif tp and not goal_anim_active then
		local sx,sy=map_screen_pos(tx,ty,center_x,center_y)
		pal(10,8)
		pal(9,2)
		spr(47,sx,sy)
		pal()
	end
	clip()
	local outline_color=7
	if map_control_active then outline_color=10 end
	rect(map_ax-1,map_ay-1,map_bx+1,map_by+1,outline_color)
end

function map_coord_near(value,center)
	while value-center>world_size/2 do value-=world_size end
	while value-center<-world_size/2 do value+=world_size end
	return value
end

function map_in_view(x,y)
	return x>=63 and x<=126 and y>=34 and y<=97
end

function map_screen_pos(x,y,cx,cy)
	local mx=map_coord_near(x,world_map_camera_x)
	local my=map_coord_near(y,world_map_camera_y)
	return cx+(mx-world_map_camera_x)*8,
		cy+(my-world_map_camera_y)*8
end

function update_world_map()
	world_map_camera_x=approach(world_map_camera_x,world_map_target_x,0.1)
	world_map_camera_y=approach(world_map_camera_y,world_map_target_y,0.1)
end

function draw_map_sprite(sprite,x,y,tag,current,special)
	local inner,outer=map_tag_colors(tag)
	if tag==8 or special then
		pal(1,0)
		if current then
			pal(7,10)
		elseif tag==8 then
			pal(7,8) pal(9,8) pal(10,8)
		else
			pal(7,special) pal(9,7) pal(10,7)
		end
	else
		pal(1,inner)
		if current then pal(7,10) else
			pal(7,inner) pal(9,outer) pal(10,outer)
		end
	end
	spr(sprite,x,y)
	pal(0)
end

function map_special_inner_for_entry(entry)
	if entry.x==0 and entry.y==0 then return 12 end
	if entry.x==world_goal_x and entry.y==world_goal_y then
		return all_keys_collected() and 11 or 6
	end
	if entry.key then
		return entry.key.collected and 5 or 10
	end
end

function map_tag_colors(tag)
	return tag_inner[tag+1],tag_outer[tag+1],tag_middle[tag+1]
end

function room_mask_at(x,y)
	local mask=0
	if room_edge_open(x,y,2) then mask+=1 end
	if room_edge_open(x,y,1) then mask+=2 end
	if room_edge_open(x,y,0) then mask+=4 end
	if room_edge_open(x,y,3) then mask+=8 end
	return mask
end

function mark_room_discovered(x,y)
	if room_is_discovered(x,y) then return end
	add(discovered,{x=x,y=y,tag=room_tag,
		sprite=room_mask_at(x,y),
		key=is_key_room(x,y)})
	discovered_lookup[x+y*world_size]=room_tag
end

function reveal_room_on_map(x,y)
	x=wrap_coord(x)
	y=wrap_coord(y)
	if room_is_discovered(x,y) then return end
	local tag=room_tag_at(x,y)
	add(discovered,{x=x,y=y,tag=tag,
		sprite=room_mask_at(x,y),key=is_key_room(x,y)})
	discovered_lookup[x+y*world_size]=tag
end

function reveal_special_rooms()
	-- dEV REVEAL KEEPS THE PUBLISHED TOOL AVAILABLE WITHOUT CHANGING NORMAL DISCOVERY.
	for key in all(key_rooms) do
		reveal_room_on_map(key.x,key.y)
	end
	reveal_room_on_map(world_goal_x,world_goal_y)
end

function room_is_discovered(x,y)
	return discovered_lookup[x+y*world_size]!=nil
end

function room_effective_tag(x,y,tag)
	local flagged=0
	for dy=-1,1 do
		for dx=-1,1 do
			if not (dx==0 and dy==0)
			and (map_flag_at(x+dx,y+dy)
			or discovered_lookup[
				wrap_coord(x+dx)+wrap_coord(y+dy)*world_size
			]==8) then
				flagged+=1
			end
		end
	end
	return max(0,tag-flagged)
end



-->8
--dATA

p_s=75
p_speed=2





fall_active=false
fall_angle=0



difficulty_options={{"easy",13,1,13,0},{"norm",21,2,15,3},
	{"hard",31,4,18,4},{"crzy",51,8,22,7}}
key_sprites={123,124,125,125,124,123,124,125,125,124,124}

help_titles={"mOVEMENT 웃","fLAGGING ☉","iNDICATOR <!>","pATTERN ★","gOAL ✕",
	"dECORATION ˇ","aDDITION INFO █▒","???"}
help_bodies={
 "uSE THE ARROW KEYS (⬅️⬆️➡️⬇️) TO \nMOVE AROUND THE MAZE. eXPLORE \nEACH ROOM AND WATCH YOUR STEPS",
 "hOLD ❘ TO ENTER FLAGGING MODE \nON THE MINIMAP. mOVE THE CURSOR \nTO AN EMPTY TILE WITH THE ARROW \nKEYS, THEN PRESS 🅾️ TO MARK IT \nAS A HOLE. cHANGE MODE WITH `p`",
 "tHE SYMBOL IN THE TOP RIGHT OF \nTHE MINIMAP SHOWS HOW MANY HOLES\nSURROUND YOUR CURRENT ROOM (0-7). \nuSE THIS NUMBER TO SPOT AND \nAVOID DANGEROUS ROOMS",
 "lOOK FOR REPEATING PATTERNS LIKE \n1-2-1 OR 1-2-2-1. tHEY CAN \nREVEAL SAFE PATHS AND HELP YOU \nPREDICT WHERE THE HOLES ARE",
 "cOLLECT EVERY KEY TO OPEN THE \nFINISH GATE. rEMEMBER, SPECIAL \nROOMS ALWAYS COUNT AS 0 WHEN \nREADING THE NUMBERS",
 "tHERE'RE DECORATION IN THE ROOM,\nSOME ARE PASSABLE, SOME AREN'T.\niF THOSE ANNOY YOU, DISABLE \nTHEM IN THE MENU",
 "tHE GREY SQUARE AROUND A ROOM \nSUPPOSED TO REPRESENT UNKNOWN \nholes. iF YOU FLAG THEM \nCORRECTLY, TILE WITHOUT THEM ARE \nALWAYS SAFE TO VISIT",
 "..."
}
help_maps={
	{7,4,44,32,5,5},
	{0,0,34,10,7,7},
	{},
	{12,0,34,48,8,2},
	{7,0,44,32,5,4},
	{12,2,30,40,9,3},
	{12,5,28,28,8,5},
	{}
}



room_left=8
room_top=51

world_seed=0
world_root_mask=15
world_root_dir=1



goal_anim_active=false
goal_anim_timer=0
tag_inner={0,1,3,11,10,9,14,8,8}
tag_outer={7,2,1,3,9,4,8,2,0}
tag_middle={6,0,11,0,4,8,2,1,2}


















--tHIS IS not A CHEAT CODE
totally_not_a_cheatcode={2,2,0,3,4,0,5,1,1,3}

cheat_active=false
cheat_index=0
cheat_failed=false
cheat_tap_timer=0
cz=false
explorer_toggle=false
solid_deco=true
cheat_input_sprites={41,43,40,42,161,162}
cheat_wiggle={-1,2,-2,2}
cheat_inputs={}
cheat_result=0
cheat_result_timer=0
cheat_cursor_timer=0
cheat_hint_timer=0
--pLEASE, IGNORE THIS BLOCK