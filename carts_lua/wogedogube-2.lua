
-- 1997 snake
-- by guy levy

--hello world!

function _init()
	pal()
	pal(1,128,1) --dark lcd pixels
	pal(2,138,1) --lcd background
	
	cartdata("snake_1997_highscore")
	highscore=dget(0)
	
	speed_level=3
	speed_delays={13,6.25,4,2.85,1.75}
	speed_delay=speed_delays[speed_level]
	
	snake_size=3
	move_dist=2
	board_spacing=4
	starting_segments=9
	
	board_x=25
	board_y=43
	board_cols=19
	board_rows=11
	board_right=board_x+(board_cols-1)*board_spacing
	board_bottom=board_y+(board_rows-1)*board_spacing
	
	menu_option=1
	menu_items={
		"new game",
		"speed",
		"top score",
		"instructions"
	}
	
	death_menu_items={
		"last view",
		"new game",
		"speed",
		"top score"
	}
	
	reset()
	screen="menu"
end



function reset()
	dx=1
	dy=0
	turns={}
	
	move_timer=0
	score=0
	
	body_pixels=(starting_segments-1)*board_spacing
	
	growth_left=0
	
	head_x=board_x+body_pixels
	head_y=board_bottom
	
	trail={}
	
	for i=body_pixels,0,-1 do
		add(trail,{
			x=head_x-i,
			y=head_y
		})
	end
	
	rebuild_collision_segments()
	
	food_x=board_x+flr((board_cols-1)/2)*board_spacing
	food_y=board_y+flr((board_rows-1)/2)*board_spacing
end



function add_turn(tx,ty)
	if #turns>=2 then return end
	
	local bx=dx
	local by=dy
	
	if #turns>0 then
		bx=turns[#turns].x
		by=turns[#turns].y
	end
	
	if tx==bx and ty==by then
		return
	end
	
	if tx==-bx and ty==-by then
		return
	end
	
	add(turns,{x=tx,y=ty})
end



function rebuild_collision_segments()
	collision_segments={}
	
	local full_segments=flr(body_pixels/board_spacing)
	
	for i=0,full_segments do
		local index=#trail-i*board_spacing
		
		if index>=1 then
			local p=trail[index]
			
			add(collision_segments,{
				x=p.x,
				y=p.y
			})
		end
	end
	
	if body_pixels%board_spacing~=0 then
		local index=#trail-body_pixels
		
		if index>=1 then
			local p=trail[index]
			
			add(collision_segments,{
				x=p.x,
				y=p.y
			})
		end
	end
end



function blocks_overlap(ax,ay,bx,by)
	return abs(ax-bx)<snake_size
		and abs(ay-by)<snake_size
end



function change_speed(amount)
	speed_level+=amount
	
	speed_level=mid(1,speed_level,#speed_delays)
	speed_delay=speed_delays[speed_level]
end



function cycle_speed()
	speed_level=speed_level%#speed_delays+1
	speed_delay=speed_delays[speed_level]
end



function update_menu_cursor(option,count)
	if btnp(2) then
		option-=1
		
		if option<1 then
			option=count
		end
	end
	
	if btnp(3) then
		option+=1
		
		if option>count then
			option=1
		end
	end
	
	return option
end



function update_speed_row(option,speed_row)
	if option~=speed_row then return end
	
	if btnp(0) then
		change_speed(-1)
	elseif btnp(1) then
		change_speed(1)
	end
end



function update_menu()
	menu_option=update_menu_cursor(
		menu_option,#menu_items
	)
	
	update_speed_row(menu_option,2)
	
	if btnp(4) or btnp(5) then
		if menu_option==1 then
			reset()
			screen="game"
		
		elseif menu_option==2 then
			cycle_speed()
		
		elseif menu_option==3 then
			topscore_return="menu"
			screen="topscore"
		
		elseif menu_option==4 then
			screen="instructions"
		end
	end
end



function update_death_menu()
	death_menu_option=update_menu_cursor(
		death_menu_option,#death_menu_items
	)
	
	update_speed_row(death_menu_option,3)
	
	if btnp(4) or btnp(5) then
		if death_menu_option==1 then
			screen="lastview"
		
		elseif death_menu_option==2 then
			reset()
			screen="game"
		
		elseif death_menu_option==3 then
			cycle_speed()
		
		elseif death_menu_option==4 then
			topscore_return="death_menu"
			screen="topscore"
		end
	end
end



function die()
	sfx(1)
	result_timer=150
	death_menu_option=1
	screen="gameover"
end



function _update60()
	if screen=="gameover"
	or screen=="win" then
		result_timer-=1
		
		if result_timer<=0 then
			screen="death_menu"
		end
		
		return
	end
	
	if screen=="menu" then
		update_menu()
		return
	end
	
	if screen=="death_menu" then
		update_death_menu()
		return
	end
	
	if screen=="lastview" then
		if btnp(4) or btnp(5) then
			screen="death_menu"
		end
		
		return
	end
	
	if screen=="topscore" then
		if btnp(4) or btnp(5) then
			screen=topscore_return
		end
		
		return
	end
	
	if screen=="instructions" then
		if btnp(4) or btnp(5) then
			screen="menu"
		end
		
		return
	end
	
	if screen~="game" then return end
	
	if btnp(0) then
		add_turn(-1,0)
	
	elseif btnp(1) then
		add_turn(1,0)
	
	elseif btnp(2) then
		add_turn(0,-1)
	
	elseif btnp(3) then
		add_turn(0,1)
	end
	
	move_timer+=1
	
	if move_timer>=speed_delay then
		move_timer-=speed_delay
		
		local on_cell=
			(head_x-board_x)%board_spacing==0
			and
			(head_y-board_y)%board_spacing==0
		
		if on_cell and #turns>0 then
			local turn=turns[1]
			deli(turns,1)
			
			dx=turn.x
			dy=turn.y
		end
		
		local next_x=head_x+dx*move_dist
		local next_y=head_y+dy*move_dist
		
		if next_x<board_x
		or next_x>board_right
		or next_y<board_y
		or next_y>board_bottom then
			die()
			return
		end
		
		for i=1,move_dist do
			head_x+=dx
			head_y+=dy
			
			add(trail,{
				x=head_x,
				y=head_y
			})
		end
		
		if growth_left>0 then
			local grow=min(move_dist,growth_left)
			
			body_pixels+=grow
			growth_left-=grow
		end
		
		rebuild_collision_segments()
		
		for i=3,#collision_segments do
			local p=collision_segments[i]
			
			if blocks_overlap(
				head_x,head_y,p.x,p.y
			) then
				die()
				return
			end
		end
		
		if head_x==food_x
		and head_y==food_y then
			sfx(0)
			
			growth_left+=board_spacing
			
			local grow=min(move_dist,growth_left)
			
			body_pixels+=grow
			growth_left-=grow
			
			rebuild_collision_segments()
			score+=1
			
			if score>highscore then
				highscore=score
				dset(0,highscore)
			end
			
			spawn_food()
		end
		
		local keep=body_pixels+growth_left+1
		
		while #trail>keep do
			deli(trail,1)
		end
	end
end



function spawn_food()
	if #collision_segments>=board_cols*board_rows then
		result_timer=150
		death_menu_option=1
		screen="win"
		return
	end
	
	repeat
		food_x=board_x+flr(rnd(board_cols))*board_spacing
		food_y=board_y+flr(rnd(board_rows))*board_spacing
		
		local blocked=false
		
		for i=1,#collision_segments do
			local p=collision_segments[i]
			
			if blocks_overlap(
				food_x,food_y,p.x,p.y
			) then
				blocked=true
				break
			end
		end
	until not blocked
end



function draw_lcd_panel()
	local border_left=board_x
	local border_top=board_y-2
	local border_right=board_right+2
	local border_bottom=board_bottom+4
	
	rectfill(
		border_left-5,
		border_top-3,
		border_right+5,
		border_bottom+3,
		2
	)
end



function draw_menu_indicator(option,count,menu_y,spacing)
	local x=98
	
	line(
		x,
		menu_y-2,
		x,
		menu_y+(count-1)*spacing+6,
		1
	)
	
	local y=menu_y+(option-1)*spacing
	
	line(x,y-2,x,y+6,2)
	
	pset(x,y-2,1)
	pset(x,y-1,1)
	pset(x,y+5,1)
	pset(x+1,y-1,1)
	
	line(
		x+2,
		y,
		x+2,
		y+4,
		1
	)
	
	pset(x+1,y+5,1)
	pset(x,y+6,1)
end



function draw_menu_list(items,option,menu_x)
	draw_lcd_panel()
	
	local menu_y=46
	local spacing=10
	
	for i=1,#items do
		local y=menu_y+(i-1)*spacing
		local label=items[i]
		
		if label=="speed" then
			label="speed: "..speed_level
		end
		
		if i==option then
			rectfill(
				menu_x-2,
				y-2,
				menu_x+#label*4,
				y+6,
				1
			)
			
			print(label,menu_x,y,2)
		else
			print(label,menu_x,y,1)
		end
	end
	
	draw_menu_indicator(
		option,
		#items,
		menu_y,
		spacing
	)
	
	print("select",52,84,1)
end



function draw_menu()
	draw_menu_list(
		menu_items,
		menu_option,
		31
	)
end



function draw_death_menu()
	draw_menu_list(
		death_menu_items,
		death_menu_option,
		29
	)
end



function draw_topscore()
	draw_lcd_panel()
	
	print("top score:",29,43,1)
	print(highscore,29,53,1)
end



function print_tight(text,x,y,col)
	for i=1,#text do
		local letter=sub(text,i,i)
		
		if letter==" " then
			x+=3
		else
			print(letter,x,y,col)
			x+=4
		end
	end
end



function draw_instructions()
	draw_lcd_panel()
	
	local lines={
		"make the snake grow",
		"longer by eating",
		"food. use the arrow",
		"keys. you can't stop",
		"the snake or make it",
		"go backwards. don't",
		"hit the walls or the",
		"tail."
	}
	
	for i=1,#lines do
		print_tight(
			lines[i],
			23,
			41+(i-1)*6,
			1
		)
	end
end



function draw_result(title)
	draw_lcd_panel()
	
	print(title,29,43,1)
	print("your score: "..score,29,53,1)
end



function draw_game()
	draw_lcd_panel()
	
	rect(
		board_x-2,
		board_y-2,
		board_right+4,
		board_bottom+4,
		1
	)
	
	local oldest=max(1,#trail-body_pixels)
	
	for i=oldest,#trail do
		local p=trail[i]
		
		rectfill(
			p.x,
			p.y,
			p.x+snake_size-1,
			p.y+snake_size-1,
			1
		)
	end
	
	pset(food_x+1,food_y,1)
	pset(food_x,food_y+1,1)
	pset(food_x+2,food_y+1,1)
	pset(food_x+1,food_y+2,1)
end



function _draw()
	cls(0)
	
	if screen=="gameover" then
		draw_result("game over!")
		return
	end
	
	if screen=="win" then
		draw_result("you win!")
		return
	end
	
	if screen=="menu" then
		draw_menu()
		return
	end
	
	if screen=="death_menu" then
		draw_death_menu()
		return
	end
	
	if screen=="topscore" then
		draw_topscore()
		return
	end
	
	if screen=="instructions" then
		draw_instructions()
		return
	end
	
	if screen=="game"
	or screen=="lastview" then
		draw_game()
	end
end