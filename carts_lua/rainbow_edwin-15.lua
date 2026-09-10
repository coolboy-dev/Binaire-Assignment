-- rainbow
-- by lyrdl

function _init()
	board = nil
	game_index = 1
	games = {
	 "colors",
	 "castle 1",
	 "rainbow castle",
	 "hearts",
	 "castle 2",
	 "roads",
		"rainbow",
		"night rainbow",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		"edwin"
	}
	last_frame = 0
	p = player(60,60)
	base_speed = 2
	speed = base_speed
	base_radius = 7
	brush_radius = base_radius
	music(0)
	frame = 1
	proc_image = {}
	ghosts = {}
	grid_hold = false -- sentinal to hold drawing proc images until black screen has a chance to draw once the ui thread is no longer stuck
	menuitem(0,"restart", function() start_game() end)
end

function player(x,y)
 return {
  x = x,
  y = y
 }
end

function _update()
 if(board == nil) then
  select_screen_input()
 else
  game_screen_input()
 end
 frame += 1
end

function _draw()
 cls()
 if(board == nil) then
  select_screen_draw()
 else
  game_screen_draw()
 end
end

function select_screen_input()
 if btnp(⬅️) then
  game_index -= 1
 elseif btnp(➡️) then
  game_index += 1
 end 
 game_index = (game_index-1)%count(games)+1
 if btnp(❘) then
  start_game()
 end
end

function select_screen_draw()
 print("select picture:",40,40)
 print(games[game_index],40, 60)
 --print(game_index,40, 80)
end

function game_screen_draw()
 -- hidden image
 if(game_index <= 3) then
  if grid_hold then
   draw_proc()
  else grid_hold = true end
 elseif(game_index <= 6) then
  if grid_hold then
   draw_grid()
  else grid_hold = true end
 else
  local g_i = game_index - 6
	 local in_x = 64
	 local in_y = 64
	 local sprite_x = in_x*(g_i-1)
	 if(g_i > 2) then
	  in_x = 32
	  in_y = 32
	  sprite_x = (in_x*g_i+in_x)%128
	  sprite_y = (flr((in_y*g_i+in_y)/128)-1)*in_y+64
	 end
	 sspr(
	  sprite_x,
	  sprite_y,
	  in_x,
	  in_y,
	  0,
	  0,
	  128,
	  128
	 )
	 
	end
	
	if game_index != 1 then
	 -- black pixels
	 for x = 1,128 do
	  for y = 1,128 do
	   if board[x][y] == "b" then
	    pset(x-1,y-1,0)
	   end
	  end
	 end
	end
	
	-- draw ghosts
	if(speed > base_speed) then
	 for i = 1,count(ghosts) do
	  local g = ghosts[i]
	  -- remap pallete to i
	  for c=0,15 do pal(c, i+7) end
	  draw_player(g.x,g.y,1)
	  pal()
	 end
 end
 
 add(ghosts,player(p.x,p.y))
 if(count(ghosts) > 8) then
  del(ghosts,ghosts[1])
 end
 draw_player(p.x,p.y,1)
end

function draw_player(x,y,scale)
 palt(5,true)
 palt(0,false)
 local p_s = 238
 if flr(frame/24) % 4 == 0 then
  p_s = 204
 elseif flr(frame/24) % 4 == 1 then
  p_s = 206
 elseif flr(frame/24) % 4 == 2 then
  p_s = 236
 end
	spr(p_s,x,y,2,2)
	-- duplicate offset by one screen width for screen wrapping
	spr(p_s,x-128,y,2,2)
	spr(p_s,x,y-128,2,2)
	spr(p_s,x-128,y-128,2,2)
 
 palt(5,false)
 palt(0,true)
end

function draw_proc()
 for x = 1,128 do
  for y = 1,128 do
   pset(x,y,proc_image[x][y]) 
  end
 end
end

function game_screen_input()
 if speed > base_speed then speed -= 1 end
 if brush_radius > base_radius then brush_radius -= 1 end
 if btnp(❘)
  and frame - last_frame > 4 then
  speed = 12
  if btn(⬆️) or btn(➡️) or btn(⬅️) or btn(⬇️) then
   brush_radius = 16
  else
   brush_radius = 20
  end
  last_frame = frame
  sfx(5)
 end
 if btnp(🅾️) then
 	start_game()
 end
 if btn(⬆️) then
  p.y -= speed
  --sfx(3)
 end
 if btn(➡️) then
  p.x += speed
  --sfx(3)
 end
 if btn(⬇️) then
  p.y += speed
  --sfx(3)
 end
 if btn(⬅️) then
  p.x -= speed
  --sfx(3)
 end
 if p.x > 128 then p.y += 6 end
 p.x = (p.x + 255) % 128 + 1
 p.y = (p.y + 255) % 128 + 1

 if game_index == 1 then
  -- update brush every 4 frames
  if frame % 4 == 0 then
   local colors = {}
   -- loop through brush to sample colors
   for x = p.x-brush_radius,p.x+brush_radius do
		  for y = p.y-brush_radius+3,p.y+brush_radius+3 do
		   local rx = x - p.x
		   local ry = y - p.y - 3
		   if x >= 1 and x <= 128
		    and proc_image[x][y] != nil
		    and proc_image[x][y] != 0
		    and rx*rx+ry*ry < brush_radius*brush_radius then
		    local c = proc_image[x][y]
		    --add(colors, c)
		    local rainbow = {
		     [8]={14,9},
		     [9]={8,10},
		     [10]={9,11},
		     [11]={12,10},
		     [12]={1,11},
		     [1]={12,2},
		     [2]={1,14},
		     [14]={2,8}
		    }
		    -- also add adjacent colors
		    add(colors, rainbow[c][1])
		    add(colors, rainbow[c][2])

		    -- delete others
					 
		   end
		  end
		 end
		 
		 if count(colors) < 1 then
		  add(colors,10)
		 end
	  -- loop through brush to paint
   brush_color = rnd(colors)
		end
	 -- loop through brush to paint
  for x = p.x-brush_radius,p.x+brush_radius do
	  for y = p.y-brush_radius+3,p.y+brush_radius+3 do
	   local rx = x - p.x
	   local ry = y - p.y - 3
	   if x >= 1 and x <= 128
	    and rx*rx+ry*ry < brush_radius*brush_radius then
     proc_image[x][y] = brush_color
	   end
	  end
	 end
 else
  -- clear black pixels
	 for x = p.x-brush_radius,p.x+brush_radius do
	  for y = p.y-brush_radius+3,p.y+brush_radius+3 do
	   local rx = x - p.x
	   local ry = y - p.y - 3
	   if x >= 1 and x <= 128
	    and rx*rx+ry*ry < brush_radius*brush_radius then
	    board[x][y] = " "
	   end
	  end
	 end
 end
end

function start_game()
 board = {}
 proc_image = {}
 if game_index == 2 do
  wfc_art(8,104,16,16)
 elseif game_index == 3 do
  wfc_art(104,72,16,16)
 elseif game_index == 4 do
  wfc2(64,64)
 elseif game_index == 5 do
  wfc2(32,96)
 elseif game_index == 6 do
  wfc2(64,96)
 elseif game_index == 1 do
	 for x = 1,128 do
	  proc_image[x] = {}
	  for y = 1,128 do
	   proc_image[x][y] = 0
	  end
	 end
 end
 for x = 1,128 do
  board[x] = {}
  for y = 1,128 do
   board[x][y] = "b"  
  end
 end
end

-->8
function wfc_art(sx,sy,sw,sh)
 ::start::
 cls()
 -- initialise entropy
 local grid = {}
 local slots = {}
 for x = 0,17 do
  grid[x] = {}
  for y = 0,17 do
   grid[x][y] = nil
   if x != 0 and x != 17
    and y != 0 and y != 17 then
    add(slots, slot(x,y,tiles))
   end
  end
 end
 while #slots > 0 do
	 -- find lowest entropy tile
	 local min = 5
	 local min_slots = {}
	 for i = 1,#slots do
	  if count(slots[i].tiles) < min then
	   min = count(slots[i].tiles)
	   min_slots = {}
	  end
	  if count(slots[i].tiles) == min then
	   add(min_slots,slots[i])
	  end
	 end
	 local min_slot = rnd(min_slots)
	 -- collapse it
	 local choice = rnd(min_slot.tiles)
  if choice == nil then
   -- deadend
   goto start
  end
	 grid[min_slot.x][min_slot.y] = choice.tag
	 color(8)
	 print(choice.tag, min_slot.x*8, min_slot.y*8)
	 flip()
	 del(slots,min_slot)
	 
	 -- propogate entropy
	 for s = 1,#slots do
	  local slot = slots[s]
	  local f_tiles = {}
	  for t = 1,#slot.tiles do
	   local tile = slot.tiles[t]

	   local left_tag = grid[slot.x-1][slot.y]
	   if left_tag != nil and
	    count(tile.n_left, left_tag) == 0 then
	     add(f_tiles, tile)
	   end
	   
	   local right_tag = grid[slot.x+1][slot.y]
	   if right_tag != nil and
	    count(tile.n_right, right_tag) == 0 then
	     add(f_tiles, tile)
	   end
	   
	   local up_tag = grid[slot.x][slot.y-1]
	   if up_tag != nil and
	    count(tile.n_top, up_tag) == 0 then
	     add(f_tiles, tile)
	   end
	   
	   local down_tag = grid[slot.x][slot.y+1]
	   if down_tag != nil and
	    count(tile.n_bottom, down_tag) == 0 then
	     add(f_tiles, tile)
	   end
	  end
	  for f = 1,#f_tiles do
	   del(slot.tiles, f_tiles[f])
	  end
	 end
 end
	 
 -- populate proc_image
 for x = 1,128 do
  proc_image[x] = {}
  for y = 1,128 do
   local tile = grid[flr(x/8)+1][flr(y/8)+1]
   if tile == 0 then
   	proc_image[x][y] = sget(sx+x%8,sy+y%8)
   elseif tile == 1 then
    proc_image[x][y] = sget(sx+x%8+8,sy+y%8)
   elseif tile == 2 then
    proc_image[x][y] = sget(sx+x%8,sy+y%8+8)
   elseif tile == 3 then
    proc_image[x][y] = sget(sx+x%8+8,sy+y%8+8)
   end
  end
 end
end

function slot(x,y,tiles)
 local copy = {}
 for t in all(tiles) do add(copy,t) end
 return {
  x = x,
  y = y,
  tiles = copy
 }
end

function tile(tag,n_top,n_left,n_right,n_bottom)
	return {
	  tag = tag,
		 n_top = n_top,
		 n_right = n_right,
		 n_bottom = n_bottom,
		 n_left = n_left
	}
end

tiles = {
 tile(
  0,
  {1},
  {1,2},
  {1,2},
  {2,3}
 ),
 tile(
  1,
  {1},
  {1,2,0},
  {1,2,0},
  {0,1,3}
 ),
 tile(
  2,
  {0,2},
  {0,1,2},
  {0,1,2},
  {2,3}
 ),
 tile(
  3,
  {0,1,2,3},
  {3},
  {3},
  {3}
 )
}
-->8
function wfc2(sx,sy)
 local deadends = 0
 ::start::
 grid = {} -- tile grid
 local slots = {} -- list of undefined tiles
 local tiles = {} -- possible tiles
 setup_tiles(tiles,sx,sy)
 initialise(grid,slots,tiles)
 -- loop until there are no free slots
 cls()
 while #slots > 0 do
  -- find next slot using entropy
  local next_slot = find_lowest_entropy(slots)
  -- collapse it into a fixed tile
  local choice_tiles = {}
  for t in all(next_slot.tiles) do
   for i = 0,t.weight + 1 do
    add(choice_tiles, t)
   end
  end
  local choice = rnd(choice_tiles)
  if choice == nil then
   -- deadend
   color(8)
   print(deadends,0,0)
   print(count(next_slot.tiles),0,8)
   print(#tiles,16,8)
   print(next_slot.x..","..next_slot.y,0,16)
   flip()
   deadends += 1
   
   if deadends > 5 or #slots < 150 then
    choice = rnd(tiles)
   else
    goto start
   --goto finish
   end
  end
	 grid[next_slot.x][next_slot.y] = choice
  -- paint debug
	 color(1)
	 rectfill(next_slot.x*7-10, next_slot.y*7-10,next_slot.x*7-2, next_slot.y*7-2)
	 color(3)
	 print(sub(choice.index,2), next_slot.x*7-9, next_slot.y*7-9)
	 flip()
	 --spr(choice.index, next_slot.x*7-10, next_slot.y*7-10,1,1,choice.flip_x,choice.flip_y)
	 -- slot is set, remove from list
	 del(slots,next_slot)
  
  -- update slot options
  for s = 1,#slots do
	  local slot = slots[s]
	  -- keep a list of tiles to remove
	  local f_tiles = {}
	  for t = 1,#slot.tiles do
	   local tile = slot.tiles[t]

	   local left = grid[slot.x-1][slot.y]
	   if left != nil and
	    count(tile.left_tags, left.tag) == 0 then
	     add(f_tiles, tile)
	   end
	   
	   local right = grid[slot.x+1][slot.y]
	   if right != nil and
	    count(tile.right_tags, right.tag) == 0 then
	     add(f_tiles, tile)
	   end
	   
	   local up = grid[slot.x][slot.y-1]
	   if up != nil and
	    count(tile.top_tags, up.tag) == 0 then
	     add(f_tiles, tile)
	   end
	   
	   local down = grid[slot.x][slot.y+1]
	   if down != nil and
	    count(tile.bottom_tags, down.tag) == 0 then
	     add(f_tiles, tile)
	   end
	  end
	  for f = 1,#f_tiles do
	   del(slot.tiles, f_tiles[f])
	  end
	 end
 end
 ::finish::
end

function draw_grid()
for x = 1,19 do
  for y = 1,19 do
   local tile = grid[x][y]
   if tile != nil then
    spr(tile.index, x*7-10,y*7-10,1,1,tile.flip_x,tile.flip_y)
   end
  end
 end
end

function find_lowest_entropy(slots)
 -- todo shannon entropy or equivalent
 local min = 1000
 local min_slots = {}
 for i = 1,#slots do
  if count(slots[i].tiles) < min then
   min = count(slots[i].tiles)
   min_slots = {}
  else
     rectfill(slots[i].x*7-10,slots[i].y*7-10,slots[i].x*7-3,slots[i].y*7-3,count(slots[i].tiles))
  end
  if count(slots[i].tiles) == min then
   add(min_slots,slots[i])
  end
 end
 return rnd(min_slots)
end

function initialise(grid,slots,tiles)
 -- it's a 19 by 19 tile grid because we need that many 8 by 8 tiles to cover 128 pixels if they overlap by 1 pixel (we have 3 overshoot pixels on each side which we trim when we generate the proc_image array)
 for x = 0,20 do
  grid[x] = {}
  for y = 0,20 do
   -- set grid coord to nill
   grid[x][y] = nil
   -- add grid coord as a slot
   -- check if its not a dummy coordinate (lazy way of avoiding array out of bounds)
   if x != 0 and x != 20
    and y != 0 and y != 20 then
    add(slots, slot(x,y,tiles))
   end
  end
 end
end

-- extract tiles from sprite sheet space
function setup_tiles(tiles,sx,sy)
 for x = 0,3 do
  for y = 0,3 do
   local left_x = sx+x*8
   local top_y = sy+y*8
   local sprite_index = flr(left_x/8)+flr(top_y/8)*16
   local can_flip_x = fget(sprite_index, 0)
   local can_flip_y = fget(sprite_index, 1)
   local weight = fget(sprite_index)
   local weight_mask = 224
   weight = band(weight, weight_mask)      
   if weight > 0 then
   assert("weight: "..weight)
   end
   -- init each tile with empty neighbours, we'll populate in the next pass
   -- base tile
   add(tiles,tile(sprite_index,left_x,top_y,false,false,{},{},{},{},weight))
   spr(sprite_index, x*8+32, y*8+32)  
   if can_flip_x then
    -- only x flip
    add(tiles,tile(sprite_index,left_x,top_y,true,false,{},{},{},{},weight))
    spr(sprite_index, x*8+64, y*8+32, 1, 1, true, false)
    if can_flip_y then
     -- flip both
     add(tiles,tile(sprite_index,left_x,top_y,true,true,{},{},{},{},weight))
     spr(sprite_index, x*8+32, y*8+64, 1, 1, true, true)
    end
   end
   if can_flip_y then
    -- only y flip
    add(tiles,tile(sprite_index,left_x,top_y,false,true,{},{},{},{},weight))
    spr(sprite_index, x*8+64, y*8+64, 1, 1, false, true)
   end
   flip()
  end
 end
 cls()
 -- now we loop back through the tiles and populate neighbor lists
 local amount = 0
 for this in all(tiles) do
  for that in all(tiles) do
   -- check if this and that are compatible
   -- compatible if their 1 pixel overlap matches (after flipping)
   
   -- check top border
   if border(this,0) == border(that,2) then
    add(this.top_tags, that.tag)
   end
   if border(this,1) == border(that,3) then
    add(this.right_tags, that.tag)
   end
   if border(this,2) == border(that,0) then
    add(this.bottom_tags, that.tag)
   end
   if border(this,3) == border(that,1) then
    add(this.left_tags, that.tag)
   end 
   amount += 1
   cls()
   color(8)
   print(amount.." of "..#tiles*#tiles,48,64)
  end
  -- add universal tile
  --add(this.left_tags, 
 end
end

function border(tile, side) -- 0 top, 1 right, etc
 local string = ""
 if tile.flip_x 
  and (side == 1 or side == 3) then 
  side = 4 - side
 end
 if tile.flip_y
  and (side == 0 or side == 2) then 
  side = 2 - side
 end
 local start_x = tile.flip_x and 7 or 0
 local end_x = tile.flip_x and 0 or 7
 local start_y = tile.flip_y and 7 or 0
 local end_y = tile.flip_y and 0 or 7
 local step_x = tile.flip_x and -1 or 1
 local step_y = tile.flip_y and -1 or 1

 if side == 3 then 
  start_x = 0
  end_x = 0
 elseif side == 1 then
  start_x = 7
  end_x = 7
 elseif side == 0 then
  start_y = 0
  end_y = 0
 elseif side == 2 then
  start_y = 7
  end_y = 7
 end
 for x = start_x,end_x,step_x do 
	 for y = start_y,end_y,step_y do
	  string = string..","..sget(x+tile.x,y+tile.y)
	 end
 end

 return string
end

function tile(
 index,
 x, -- sprite space x
 y, -- sprite space y
 flip_x,
 flip_y,
 top_tags,
 right_tags,
 left_tags,
 bottom_tags,
 weight
)
 return {
  tag = 't'..x..","..y..tostr(flip_x)..tostr(flip_y),
  index = index,
  x = x,
  y = y,
  flip_x = flip_x,
  flip_y = flip_y,
	 top_tags = top_tags,
	 right_tags = right_tags,
	 left_tags = left_tags,
	 bottom_tags = bottom_tags,
	 weight = weight
 }
end 

function slot(x,y,tiles)
 local copy = {}
 for t in all(tiles) do add(copy,t) end
 return {
  x = x, -- grid space x
  y = y, -- grid space y
  tiles = copy
 }
end