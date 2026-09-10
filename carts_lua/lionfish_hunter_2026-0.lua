--lionfish hunter 2026
--by sam hutcherson

--general design:
--player is you
--player is in scene
--scene has fish
--scene has objects
--player can shoot fish
--fish and objects can hurt player
--must catch lionfish to move to next scene

function _init()
 --set blue transparent
 palt(12, true)
 palt(0, false)
	
	--initialize game objects
 music(0,0,7)
	make_player()
	make_env()
	make_start()
	
	--set looping functions
	_update=start_update
	_draw=start_draw
	
	
end
-->8
--player
left=true
right=false
none=0
shoot=1
retract=2
hit_recovery_time=3
hit_flash_freq=4

function make_player()
	player={}
	player.map=0
	player.x=96
	player.y=48
	player.dx=0
	player.dy=0
	player.frame=0
	player.dir=right
	player.spear={}
	player.spear.move=none
	player.spear.dir=right
	player.spear.len=0
	--spear speed cannot go above 8
	player.spear.speed=6
	player.flipping=false
	player.kills=0
	player.friendly_fire=0
	player.last_t=0
	player.health=5
	player.hit=false
	player.hit_time=0
	player.dodge_rolling=false
	player.dodge_roll_t=0
	player.dodge_roll_sprite=98
	player.dodge_roll_frame=0
end

function get_player_box()
	return player.x,player.x+16,player.y+2,player.y+10
end

function draw_player()
	cur_t=time()
	moving=(player.flipping or abs(player.dx)>.3)
 if (cur_t - player.last_t) > .5 and moving then
		player.frame += 1
		player.last_t=cur_t
	end
	if player.dodge_rolling==true and (cur_t - player.dodge_roll_t) > .1 then
	 player.dodge_roll_frame+=1
	 player.dodge_roll_t=cur_t

	 if player.dodge_roll_frame==4 then
	  player.dodge_rolling=false
	  player.dodge_roll_frame=0
	 end
	end
	if player.hit and hit_recovery_time<(time()-player.hit_time) then
	 player.hit=false
	end
	show_hit=flr(time()*hit_flash_freq)%2==0
	if not player.hit or show_hit then
		if not player.dodge_rolling then
		 --normal player sprite
	 	sprite=(player.frame%2)*2+1
	 else
	  --dodge roll sprite
	  sprite=player.dodge_roll_sprite+player.dodge_roll_frame*2
	 end
	 spr(sprite,player.x,player.y,2,2,player.dir)

		--draw spear
		start_x, start_y = get_sprite_spear_end(player)
		end_x, end_y=get_spear_end(player)
		line(start_x, start_y, end_x, end_y, 6)
	
		--draw spear point
		pt_x, pt_y=get_moving_hook_pt(player)
		pset(pt_x, pt_y, 6)
	end
end

function move_player()
	player.flipping=false

	if(btnp(4)) and player.spear.move==none and player.dodge_rolling==false and (time()-player.dodge_roll_t)>.2 then
	 --dodge roll
	 player.dodge_rolling=true
	 player.dodge_roll_t=time()
	end
	
	if(btnp(0)) then
		--left
		player.dir=left
		player.flipping=true
		if player.dx>=-.6 then
			player.dx -= .15
		end
	end

	if(btnp(1)) then
		--right
		player.dir=right
		player.flipping=true
		if player.dx<=.6 then
			player.dx += .15
		end
	end

	if(btnp(2)) then
		--up
		if player.dy>=-.6 then
		 player.dy-=.15
		end
	end

	if(btnp(3)) then
		--down
		if player.dy<=.6 then
		 player.dy+=.15
		end
	end

	if(btnp(5)) and player.spear.move==none and player.dodge_rolling==false then
		--spear
		sfx(0)
		player.spear.move=shoot
		player.spear.dir=player.dir
		player.spear.len=0
	end


	
	--move the spear
	spear_x, spear_y=get_spear_end(player)
	if player.spear.move==shoot then
		if spear_x>=128 or spear_x<=0 then
			player.spear.move=retract
		else
			player.spear.len+=player.spear.speed
		end
	end
	if player.spear.move==retract then
		if player.spear.len<=0 then
			player.spear.move=none
			player.spear.len=0
		else
			player.spear.len-=player.spear.speed
		end
	end

	--change scene if needed
	if player.x>112 and (player.map+1)<num_maps then
		player.map+=1
		init_scene(player.map)
		player.x=0
	end
	
	--move diver if possible
	--fixme: update this logic
	--once there is solid material
	--in the map
	dx = player.dx
	dy = player.dy
	if player.dodge_rolling then
	 --boost when dodge rolling
	 dx*=3
	 dy*=3
	end

	if dx<0 and player.x>0 then
		player.x += dx
	elseif dx>0 and (player.x<106 or (scene_beat() and player.x<112)) then
		player.x += dx
	else
		player.dx=0
	end

	if dy<0 and player.y>curr_scene().top then
		player.y += dy
	elseif dy>0 and player.y<112 then
		player.y += dy
	else
		player.dy=0
	end
end
-->8
--fish
lionfish=5
dory=6
tang=7
gill=8
nemo=9
silver=10
purple=11
grouper=12
turtle=13
jellyfish=29
crab=31
shark=128
hook=122
super_lionfish=150
child_lionfish=151
diver=136

slowdown_time=1

function make_fish(fish_type,x,y,dir,launch_angle,size)
	fish={}
	fish.type=fish_type
	fish.move=fish_move
	fish.draw=fish_draw
	fish.is_shark=(fish_type==shark)
	fish.x=x
	fish.y=y
	fish.dir=dir
	fish.hit=false
	fish.caught=false
	fish.move_interval=flr(rnd(5))+5
	fish.move_time=time()-flr(rnd(10))
	if launch_angle!=nil then
	 fish.dx=.6*cos(launch_angle)
	 fish.dy=.6*sin(launch_angle)
	else
	 fish.dx=0
	 fish.dy=0
	end
	fish.hurts=(fish_type==lionfish or fish.type==jellyfish or fish.is_shark or fish.type==hook or fish.type==super_lionfish or fish.type==child_lionfish or fish.type==diver)
	fish.frame=0
	fish.frame_t=0
	fish.slow=false
	fish.slow_t=0
	if size!=nil then
	 fish.size=size
	else
	 fish.size=8
	end
	fish.split=false
	fish.spear={}
	fish.spear.move=none
	fish.spear.dir=right
	fish.spear.len=0
	fish.spear.speed=6
	fish.health=3
	return fish
end

function get_fish_box(fish)
	--get bounding box of fish
	if fish.is_shark or fish.type==diver then
	 return fish.x, fish.x+16, fish.y+2, fish.y+12
	else
	 return fish.x, fish.x+fish.size, fish.y, fish.y+fish.size
 end
end

function fish_draw(fish)
	if not fish.caught then
		if fish.is_shark then
		 spr(fish.type+fish.frame*2, fish.x, fish.y, 2, 2, fish.dir)
		elseif fish.type==diver then
		 spr(fish.type+fish.frame*2,fish.x,fish.y,2,2,fish.dir)
		 --draw speargun line
		 start_x,start_y=get_sprite_spear_end(fish)
		 end_x,end_y=get_spear_end(fish)
		 line(start_x,start_y,end_x,end_y,6)
		 --draw speargun point
		 pt_x,pt_y=get_moving_hook_pt(fish)
		 pset(pt_x,pt_y,6)
		 --draw health bar
		 line(fish.x+4,fish.y-4,fish.x+4+fish.health*3,fish.y-4,8)
		elseif fish.type==super_lionfish or fish.type==child_lionfish then
		 sspr(48,72,8,8,fish.x,fish.y,fish.size,fish.size,fish.dir)
		else
		 spr(fish.type, fish.x, fish.y, 1, 1, fish.dir)
	 end
	end
end

function fish_move(fish)
 if not fish.caught then
  if (fish.type==super_lionfish or fish.type==child_lionfish) and fish.split==true and fish.size>8 then
		 --check if lionfish boss was hit
		 --split into 2 more fish
		 angle=rnd(1)
	  add(scene.fishes,make_fish(child_lionfish,fish.x,fish.y,fish.dir,angle,fish.size/2))
			add(scene.fishes,make_fish(child_lionfish,fish.x,fish.y,fish.dir,angle+.5,fish.size/2))
	  fish.caught=true
	  player.kills+=1
		end

 	if fish.hit then
	 	--handle movement of fish
	 	--after being speared
	 	if(player.spear.dir==right) then
	 		fish.x-=player.spear.speed
	 	else
	 		fish.x+=player.spear.speed
	 	end
	 	fish.y+=player.dy
	 	if(player.spear.move==none) then
	 		--finished retracting
	 		if fish.type==lionfish or fish.type==child_lionfish or fish.type==diver then
	 			player.kills+=1
	 			if fish.type==diver then
	 			 --explosion
	 			 sfx(12)
	 			else
	 			 sfx(2)
	 			end
	 		else
	 			player.friendly_fire+=1
 				sfx(9)
 			end
 			fish.caught=true
 		end
 	elseif fish.is_shark or fish.type==diver then
 	 --shark/diver chases diver
 	 --shark slows when shot
 	 --diver shoots diver when lined up
 	 if fish.slow and (time()-fish.slow_t) > slowdown_time then
 	  fish.slow=false
 	 end

 	 if (time()-fish.frame_t)>.5 then
 	  fish.frame=(fish.frame+1)%2
 	  fish.frame_t=time()
 	 end

 	 if player.x<fish.x then
 	  fish.dir=left
 	  if fish.slow and fish.type==shark then
 	   fish.dx=-.1
 	  else
 	   fish.dx=-.3
 	  end
 	 elseif player.x>fish.x then
 	  fish.dir=right
 	  if fish.slow and fish.type==shark then
 	   fish.dx=.1
 	  else
 	   fish.dx=.3
 	  end
 	 else
 	  fish.dx=0
 	 end

 	 if player.y<fish.y then
 	  if fish.slow and fish.type==shark then
 	   fish.dy=-.1
 	  else
 	   fish.dy=-.3
 	  end
 	 elseif player.y>fish.y then
 	  if fish.slow and fish.type==shark then
 	   fish.dy=.1
 	  else
 	   fish.dy=.3
 	  end
 	 else
 	  fish.dy=0
 	 end

   if fish.type==diver then
			 spear_x,spear_y=get_spear_end(fish)
		 	if spear_y>player.y and spear_y<(player.y+16) and fish.spear.move==none then
			  sfx(0)
			  fish.spear.move=shoot
			  fish.spear.dir=fish.dir
			  fish.spear.len=0
		 	end
			
		 	if fish.spear.move==shoot then
		 	 if spear_x>=128 or spear_x<=0 then
		 	  fish.spear.move=retract
		 	 else
		 	  fish.spear.len+=fish.spear.speed
		 	 end
		 	end
		 	if fish.spear.move==retract then
		 	 if fish.spear.len<=0 then
		 	  fish.spear.move=none
		 	  fish.spear.len=0
		 	 else
		 	  fish.spear.len-=fish.spear.speed
		 	 end
		 	end
		 end

 	 fish.x+=fish.dx
 	 fish.y+=fish.dy
 	elseif fish.type==hook or fish.type==child_lionfish then
 	 --hook and lionfish splitter
 	 --have dvd logo movement
 	 if fish.x<=16 and fish.dx<0 then
 	  fish.dx=-fish.dx
 	 end
   if fish.x>=112 and fish.dx>0 then
    fish.dx=-fish.dx
   end
   if fish.y<=curr_scene().top and fish.dy<0 then
    fish.dy=-fish.dy
   end
   if fish.y>=112 and fish.dy>0 then
    fish.dy=-fish.dy
   end

	  fish.x+=fish.dx
	  fish.y+=fish.dy
	 else
	 	--have the fish move
	 	--at random intervals/speeds
	 	if(time() - fish.move_time) > fish.move_interval then
	 		fish.dir=rnd({left,right})
	 		if fish.dir==left then
	 			fish.dx=-.5
	 		else
	 			fish.dx=.5
	 		end

		 	fish.move_time=time()
		 	fish.move_interval=flr(rnd(5))+5
		 end

 		if fish.type==jellyfish and fish.y>36 and fish.y<120 then
 			--jellyfish move up/down
 			fish.y+=fish.dx			
 		elseif fish.type!=jellyfish and fish.x > 0 and fish.x<112 then
 			--fish move left/right
 			fish.x+=fish.dx
 		end
			
	 	--slow down the fish after
	 	--initial movement
	 	if fish.dx<0 then
	 		fish.dx+=.01
	 	elseif fish.dx>0 then
	 		fish.dx-=.01
	 	end
	 end
	end
end
-->8
--hit detection
function detect_hit()
	spr_x, spr_y = get_spear_end(player)
	scene=curr_scene()
	for fish in all(scene.fishes) do
		fsh_x_min,fsh_x_max,fsh_y_min,fsh_y_max=get_fish_box(fish)
		in_x=fsh_x_min<=spr_x and spr_x<=fsh_x_max
		in_y=fsh_y_min<=spr_y and spr_y<=fsh_y_max
		if not fish.hit and not fish.caught and in_x and in_y and player.spear.move==shoot then
			if fish.is_shark then
			 fish.slow=true
			 fish.slow_t=time()
			 player.spear.move=retract
			elseif fish.type==hook then
			 --do nothing
			elseif fish.type==super_lionfish or (fish.type==child_lionfish and fish.size > 8) then
			 fish.split=true
			 player.spear.move=retract
			elseif fish.type==diver and fish.health>1 then
			 fish.health-=1
			 player.spear.move=retract
			else
			 fish.hit=true
			 player.spear.move=retract
			end
		end
	end
end

function detect_damage()
 if player.dodge_rolling or player.hit then
  --no damage if currently hit
  --or dodge rolling
  return
 end
	for fish in all(scene.fishes) do
		if fish.hurts and not fish.hit and not fish.caught then
			dvr_x_min,dvr_x_max,dvr_y_min,dvr_y_max=get_player_box()
			fsh_x_min,fsh_x_max,fsh_y_min,fsh_y_max=get_fish_box(fish)
			right_in_x=(dvr_x_max<fsh_x_max and dvr_x_max>fsh_x_min)
			left_in_x=(dvr_x_min>fsh_x_min and dvr_x_min<fsh_x_max)
			top_in_y=(dvr_y_min>fsh_y_min and dvr_y_min<fsh_y_max)
			bottom_in_y=(dvr_y_max<fsh_y_max and dvr_y_max>fsh_y_min)
			in_x=right_in_x or left_in_x
			in_y=top_in_y or bottom_in_y
			if in_x and in_y then
				sfx(3)
				player.hit=true
				player.hit_time=time()
				player.health-=1
			end
			if fish.type==diver then
			 spr_x,spr_y = get_spear_end(fish)
				in_x=dvr_x_min<=spr_x and spr_x<=dvr_x_max
				in_y=dvr_y_min<=spr_y and spr_y<=dvr_y_max
				if in_x and in_y and fish.spear.move==shoot then
     sfx(3)
     player.hit=true
     player.hit_time=time()
     player.health-=1
     fish.spear.move=retract
    end
			end
		end
	end
end
-->8
--game loop
function game_update()
 if player.health > 0 then
	 move_player()
	 move_env()
	 detect_hit()
	 detect_damage()
	end
end

function game_draw()
	cls(12)
	--if player.map==0 then
		--fixme: add draw_environment function
		--spr(60, 8, 28, 4, 1)
	--end
	draw_env()
	draw_player()
	if player.health==0 then
	 print("game over",48,54,1)
	 print("you killed "..tostr(player.kills).." lionfish",24,60,1)
	 print("press 🅾️ to start again",20,72,1)
	 if btnp(4) then
	  --re-initialize evertyhing
	  --restart
	  make_player()
	  make_env()
	  make_start()
	  _update=start_update
	  _draw=start_draw
	 end
 elseif game_beat() then
  print("you win!",49,54,1)
 end
	
	--print health
	for i=1,player.health do
		spr(53,(i-1)*8,0)
	end
	--if player.kills>0 then
	--	spr(lionfish,2,8)
	--	print("x"..player.kills,11,10,1)
	--end
	
	--if player.friendly_fire > 0 then
	--	spr(54,20,8)
	--	print("x"..player.friendly_fire,30,10,1)
	--end
end
-->8
--menu loop
function make_start()
	started=false
	frame=0
	start_t=time()
end

function start_update()
	move_env()
	if btnp(4) then
		--start game
		sfx(1)
		started=true
		--add fish on title screen		
		menu_fish=make_fish(lionfish,106,70,0)
		scene=curr_scene()
		add(scene.fishes, menu_fish)
	end
end

function start_draw()
 cls(12)
	map(0, 0, 0, 0, 128, 128) 
	if started then
		if (time()-start_t)>.1 and frame<3 then
			--update diving animation
			--.1s frames
			start_t=time()
			frame+=1
		end
		if frame==3 and (time()-start_t)>.1 then
			--switch to game
			_update=game_update
		 _draw=game_draw
		end
		--flipping animation
		spr(21+frame*2, 96, 20+frame*8, 2, 2,true,false)
		if frame==2 then
			--splash
			spr(33, 96, 20, 2, 2,true,false)
		elseif frame==3 then
			spr(35, 96, 20, 2, 2,true,false)
		end
	else
		--default seated sprite
		spr(21, 96, 20, 2, 2, true, false)
	end
	--draw boat
	draw_env()
	if not started then
		--draw title
		print("lionfish hunter 2026",24,54,1)
		print("catch all the lionfish (  )",10,72,1)
		spr(5,106,70)
		print("don't die",46,82,1)
		print("🅾️=dodge,❘=shoot    🅾️ to start",0,122,1)	
	end
end
-->8
--environment
num_maps=7

function create_scene(fishes,objects,row,col,top)
	scene={}
	scene.fishes=fishes
	scene.objects=objects
	scene.map_row=row
	scene.map_col=col
	scene.top=top
	return scene
end

function make_env()
	--a really janky way of
	--labeling friendly fish
	friendly_fish={}
	for i=dory,turtle do
		add(friendly_fish,i)
	end

	--set up reef
	fishes={}
	objects={}
	generate_fishes(10)
	add(objects,make_boat(100,20,false))
	reef=create_scene(fishes,objects,0,0,28)
	
	--set up jellyfish
	fishes={}
	objects={}
	jelly_x={45,32,50,75, 48,100,78}
	jelly_y={64,50,40,100,87,45, 78}
	for i=1,7 do	
		fish_type=jellyfish
		x=jelly_x[i]
		y=jelly_y[i]
		dir=rnd(left,right)
		add(fishes,make_fish(fish_type,x,y,dir))
	end
	generate_fishes(6)
	add(fishes, make_fish(crab,16,112,left))
	add(fishes, make_fish(crab,108,112,right))
	add(fishes, make_fish(lionfish,64,64,left))
	add(objects,make_boat(100,20,false))
	jelly_map=create_scene(fishes,objects,16,0,28)
	
	--set up shark
	fishes={}
	objects={}
	generate_fishes(6)
	add(fishes,make_fish(shark,64,64,left))
	add(fishes,make_fish(lionfish,100,64,left))
	add(objects,make_boat(100,20,false))
	shark_map=create_scene(fishes,objects,32,0,28)

 --set up hooks
 fishes={}
 objects={}
 hook1=make_fish(hook,32,48,right,rnd(1))
 hook2=make_fish(hook,64,64,right,rnd(1))
 hook3=make_fish(hook,80,70,right,rnd(1))
 add(fishes,hook1)
 add(fishes,hook2)
 add(fishes,hook3)
 generate_fishes(10)
 add(objects,make_boat(100,20,false))
 add(objects,make_boat(0,20,true,hook1))
 add(objects,make_boat(0,20,true,hook2))
 add(objects,make_boat(0,20,true,hook3))
 add(fishes,make_fish(lionfish,64,64,left))
 hook_map=create_scene(fishes,objects,48,0,28)
 
 --set up lionfish boss
 fishes={}
 objects={}
 add(fishes,make_fish(super_lionfish,64,64,left,nil,64))
 add(objects,make_boat(100,20,false))
 lionfish_map=create_scene(fishes,objects,64,0,28)
 
 --set up combination room
 fishes={}
 objects={}
 generate_fishes(6)
 add(fishes,make_fish(jellyfish,60,80,left))
 add(fishes,make_fish(jellyfish,40,40,left))
 add(fishes,make_fish(jellyfish,100,60,left))
 hook1=make_fish(hook,32,48,right,rnd(1))
 hook2=make_fish(hook,80,70,right,rnd(1))
 add(fishes,hook1)
 add(fishes,hook2)
	add(fishes,make_fish(shark,64,64,left))
 add(fishes,make_fish(lionfish,64,64,left))
 add(objects,make_boat(0,20,true,hook1))
 add(objects,make_boat(0,20,true,hook2))
 add(objects,make_boat(100,20,false))
 combo_map=create_scene(fishes,objects,80,0,28)
 
 --set up final boss
 fishes={}
 objects={}
 generate_fishes(6)
 --add(fishes,make_fish(lionfish,100,64,left))
 add(fishes,make_fish(diver,64,64,left))
 add(objects,make_boat(74,20,false,nil,true))
 add(objects,make_boat(100,20,false))
 boss_map=create_scene(fishes,objects,96,0,28)
 scenes={[0]=reef,
 							 [1]=jelly_map,
 							 [2]=shark_map,
 							 [3]=hook_map,
 							 [4]=lionfish_map,
 							 [5]=combo_map,
 							 [6]=boss_map}
end

function curr_scene()
	return scenes[player.map]
end

function generate_fishes(num)
 for i=0,num do
		x=flr(rnd(120))
		y=flr(rnd(32))+86
		dir=rnd(left,right)
		fish_type=rnd(friendly_fish)
		add(fishes,make_fish(fish_type,x,y,dir))
	end
end

function move_env()
	scene=curr_scene()
	for fish in all(scene.fishes) do
		fish.move(fish)
	end
	for object in all(scene.objects) do
		object.move(object)
	end
end

function draw_env()
	scene=curr_scene()
	map(scene.map_row,scene.map_col,0,0,128,128)
	for fish in all(scene.fishes) do
		fish.draw(fish)
	end
	for object in all(scene.objects) do
		object.draw(object)
	end
end

function scene_beat()
 beat=true
 if started==false or player.map==(num_maps-1) then
  beat=false
 else
  scene=curr_scene()
  for fish in all(scene.fishes) do
   if (fish.type==lionfish or fish.type==super_lionfish or fish.type==child_lionfish) and not fish.caught then
    beat=false
   end
  end
 end
 return beat
end

function init_scene(num)
 --prevent all fish from moving immediately
 --when entering a new scene
 for fish in all(scenes[num].fishes) do
  fish.move_time=time()-flr(rnd(10))
 end
end

function game_beat()
 beat=true
 if player.map!=(num_maps-1) then
  beat=false
 else
  scene=curr_scene()
  for fish in all(scene.fishes) do
   if fish.type==diver and not fish.caught then
    beat=false
   end
  end
 end
 return beat
end
-->8
--objects
--stuff to include in scenes
--that aren't fish
explosion_sprite=160

function make_boat(x,y,fishing,hook,is_lionfish)
	boat={}
	boat.is_lionfish=is_lionfish
	if is_lionfish then
	 boat.sprite=168
	else
	 boat.sprite=45
	end
	boat.anchor_sprite=96
	boat.chain_sprite=97
	boat.is_fishing=fishing
	boat.hook=hook
	boat.line_sprite=123
	boat.x=x
	boat.y=y
	boat.anchor_y=112
	boat.move=move_boat
	boat.draw=draw_boat
	boat.pull_anchor=false
	boat.start_engine=false
	boat.start_pull=false
	boat.explode_frame=0
	boat.explode_time=0
	return boat
end

function move_boat(boat)
	if boat.is_fishing then
	 --fishing boat movement
	 boat.x=boat.hook.x-20
	else
	 --anchor boat movement
	 if scene_beat() and not boat.pull_anchor then
	  boat.pull_anchor=true
	  boat.start_pull=true
	 end
	 if boat.pull_anchor and boat.anchor_y>(boat.y+10) then
   if boat.start_pull then
    sfx(11)
    boat.start_pull=false
   end
	  boat.anchor_y-=1
	  boat.start_engine=true
  elseif boat.pull_anchor then
   if boat.start_engine then
    sfx(10)
    boat.start_engine=false
   end
   boat.x+=1
  end
 end
end

function draw_boat(boat)
 if not boat.is_lionfish or boat.explode_frame<4 then
	 --draw boat if it didn't explode
	 spr(boat.sprite, boat.x, boat.y, 3, 2,true,false)
	end
	if boat.is_fishing then
	 --draw fishing line
	 line(boat.x+24,boat.y+10,boat.x+24,boat.hook.y,6)
	elseif boat.is_lionfish then
	 --draw explosion if beat
	 if game_beat() and boat.explode_frame<4 then
	  spr(explosion_sprite+boat.explode_frame*2,boat.x+6,boat.y-6,2,2,false,false)
	  if (time()-boat.explode_time)>.1 then
	   boat.explode_frame+=1
	   boat.explode_time=time()
	  end
	 end
	else
	 --draw anchor line
	 spr(boat.anchor_sprite,boat.x+20,boat.anchor_y,1,1)
  for i=boat.y+10,boat.anchor_y,8 do
 	 spr(boat.chain_sprite,boat.x+20,i,1,1)
  end
 end
end
-->8
--shared
--functions that are shared between
--fish and player classes
--flayer = fish+player

function get_sprite_spear_end(flayer)
	if flayer.dir==right then
		return flayer.x+14, flayer.y+10
	else
		return flayer.x+1, flayer.y+10
	end
end

function get_spear_end(flayer)
	start_x, start_y=get_sprite_spear_end(flayer)
	if flayer.spear.dir==right then
		return start_x+flayer.spear.len, start_y
	else
		return start_x-flayer.spear.len, start_y
	end
end

function get_moving_hook_pt(flayer)
	x, y = get_spear_end(flayer)
	--if shooting, put pixel on spear direction
	--otherwise, sprite direction
	direction=left
	if(flayer.spear.move!=none and flayer.spear.dir==right) then
		direction=right
	elseif(flayer.spear.move==none and flayer.dir==right) then
		direction=right
	end
	
	if(direction==right) then
		return x-1, y-1
	else
		return x+1, y-1
	end
end
