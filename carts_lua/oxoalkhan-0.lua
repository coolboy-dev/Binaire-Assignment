-- oxo
-- by alkhan

screen_splash=0
screen_menu=1
screen_play=2
screen_result=3

col_black=0
col_dim=3
col_cream=7
col_green=11

wins={
 {1,2,3},{4,5,6},{7,8,9},
 {1,4,7},{2,5,8},{3,6,9},
 {1,5,9},{3,5,7}
}

difficulty_names={"easy","normal","hard"}
charset="abcdefghijklmnopqrstuvwxyz0123456789!.:"

function glyph_index(ch)
 return ord(ch)-97<0 and
  (ch=="!" and 36 or ch=="." and 37 or ch==":" and 38 or ord(ch)-22) or
  ord(ch)-97
end

function text_width(s)
 local w=0
 for i=1,#s do
  w+=sub(s,i,i)==" " and 4 or 6
 end
 return max(0,w-1)
end

function sprite_text(s,x,y,c)
 pal(7,c)
 for i=1,#s do
  local ch=sub(s,i,i)
  if ch==" " then
   x+=4
  else
   local n=glyph_index(ch)
   local sx=(n%16)*6
   local sy=flr(n/16)*8
   sspr(sx,sy,5,7,x,y)
   x+=6
  end
 end
 pal()
end

function centred_text(s,y,c)
 sprite_text(s,flr((128-text_width(s))/2),y,c)
end

function draw_title()
 pal(7,col_green)
 sspr(0,32,17,20,34,6)
 sspr(20,32,17,20,55,6)
 sspr(0,32,17,20,76,6)
 pal()
end

function draw_mark(mark,x,y,size,c)
 pal(7,c)
 if size=="small" then
  sspr(mark==1 and 82 or 72,32,9,9,x,y)
 else
  sspr(mark==1 and 56 or 40,32,14,14,x,y)
 end
 pal()
end
function clear_board()
 board={0,0,0,0,0,0,0,0,0}
 winner_cells={}
 result=0
end

function start_match(kind)
 mode=kind
 score_x=0
 score_o=0
 round_no=1
 starter=1
 start_round(2)
end

function start_round(sound_id)
 clear_board()
 turn=starter
 cursor=5
 cpu_wait=turn==2 and mode>0 and 12 or 0
 screen=screen_play
 pulse_cell=0
 pulse_time=0
 invalid_time=0
 if sound_id then sfx(sound_id) end
end

function board_winner(b)
 for line in all(wins) do
  local a,bx,c=line[1],line[2],line[3]
  if b[a]!=0 and b[a]==b[bx] and b[a]==b[c] then
   return b[a],line
  end
 end
 return 0,nil
end

function board_full(b)
 for i=1,9 do
  if b[i]==0 then return false end
 end
 return true
end

function finish_round(w,line)
 result=w
 winner_cells=line or {}
 if w==1 then score_x+=1 end
 if w==2 then score_o+=1 end
 screen=screen_result
 result_time=0
 if w==1 then sfx(7)
 elseif w==2 then sfx(8)
 else sfx(9) end
end

function place_at(cell)
 if cell<1 or cell>9 or board[cell]!=0 then
  invalid_time=8
  sfx(5)
  return false
 end
 board[cell]=turn
 pulse_cell=cell
 pulse_time=7
 sfx(turn==1 and 3 or 4)
 local w,line=board_winner(board)
 if w!=0 then
  finish_round(w,line)
 elseif board_full(board) then
  finish_round(0)
 else
  turn=3-turn
  if mode>0 and turn==2 then cpu_wait=12 sfx(6) end
 end
 return true
end

function empty_cells(b)
 local out={}
 for i=1,9 do if b[i]==0 then add(out,i) end end
 return out
end

function minimax(b,who,depth)
 ai_nodes+=1
 local w=board_winner(b)
 if w==2 then return 10-depth end
 if w==1 then return depth-10 end
 if board_full(b) then return 0 end
 local key=who
 for i=1,9 do key=key*3+b[i] end
 local cached=mm_cache[key]
 if cached!=nil then return cached end
 local best=who==2 and -99 or 99
 for cell in all(empty_cells(b)) do
  b[cell]=who
  local value=minimax(b,3-who,depth+1)
  b[cell]=0
  if who==2 then best=max(best,value) else best=min(best,value) end
 end
 mm_cache[key]=best
 return best
end

function best_cpu_move()
 local free=empty_cells(board)
 if #free==0 then return 0 end
 ai_nodes=0
 if mode==1 then return free[flr(rnd(#free))+1] end
 if mode==2 and rnd(1)<.2 then return free[flr(rnd(#free))+1] end
 if #free==8 then
  if board[5]==0 then return 5 end
  local corners={1,3,7,9}
  return corners[flr(rnd(4))+1]
 end
 mm_cache={}
 local best=-99
 local choices={}
 for cell in all(free) do
  board[cell]=2
  local value=minimax(board,1,0)
  board[cell]=0
  if value>best then
   best=value choices={cell}
  elseif value==best then
   add(choices,cell)
  end
 end
 return choices[flr(rnd(#choices))+1]
end

function next_round()
 round_no+=1
 starter=3-starter
 start_round(10)
end
function input_init()
 poke(0x5f2d,1)
 old_mouse=stat(34)
end

function read_input()
 mouse_x=stat(32)
 mouse_y=stat(33)
 local mb=stat(34)
 mouse_click=band(mb,1)!=0 and band(old_mouse,1)==0
 old_mouse=mb
 any_press=btnp()!=0 or stat(30) or mouse_click
end

function cell_from_mouse()
 if mouse_x<19 or mouse_x>109 or mouse_y<16 or mouse_y>106 then return 0 end
 local col=flr((mouse_x-19)/30)
 local row=flr((mouse_y-16)/30)
 if col>2 or row>2 then return 0 end
 return row*3+col+1
end

function update_splash()
 if any_press then
  screen=screen_menu
  sfx(2)
 end
end

function update_menu()
 if btnp(2) or btnp(3) then
  menu_focus=3-menu_focus
  sfx(0)
 end
 if menu_focus==1 then
  if btnp(0) then difficulty=(difficulty+2)%3 sfx(1) end
  if btnp(1) then difficulty=(difficulty+1)%3 sfx(1) end
  if btnp(5) then start_match(difficulty+1) end
 else
  if btnp(5) then start_match(0) end
 end
 if mouse_click then
  if mouse_y>=89 and mouse_y<=101 then
   menu_focus=1
   if mouse_x<50 then difficulty=(difficulty+2)%3 sfx(1)
   elseif mouse_x>78 then difficulty=(difficulty+1)%3 sfx(1)
   else start_match(difficulty+1) end
  elseif mouse_y>=104 and mouse_y<=116 then
   menu_focus=2
   start_match(0)
  end
 end
end

function move_cursor(dx,dy)
 local col=(cursor-1)%3
 local row=flr((cursor-1)/3)
 col=(col+dx+3)%3
 row=(row+dy+3)%3
 cursor=row*3+col+1
 sfx(0)
end

function update_play()
 if mode>0 and turn==2 then
  cpu_wait-=1
  if cpu_wait<=0 then place_at(best_cpu_move()) end
  return
 end
 if btnp(0) then move_cursor(-1,0) end
 if btnp(1) then move_cursor(1,0) end
 if btnp(2) then move_cursor(0,-1) end
 if btnp(3) then move_cursor(0,1) end
 if btnp(5) then place_at(cursor) end
 if btnp(4) then screen=screen_menu sfx(11) end
 if mouse_click then
  local cell=cell_from_mouse()
  if cell>0 then cursor=cell place_at(cell) end
 end
end

function update_result()
 result_time+=1
 if btnp(5) then next_round() end
 if btnp(4) then screen=screen_menu sfx(11) end
 if mouse_click then
  if mouse_x<64 then next_round() else screen=screen_menu sfx(11) end
 end
end
function update_effects()
 if pulse_time>0 then pulse_time-=1 end
 if invalid_time>0 then invalid_time-=1 end
end

function winning_colour(cell)
 for n in all(winner_cells) do
  if n==cell then
   return flr(result_time/8)%2==0 and col_cream or col_green
  end
 end
 return col_green
end
function dot_h(x0,x1,y,c)
 for x=x0,x1,2 do pset(x,y,c) end
end

function dot_v(x,y0,y1,c)
 for yy=y0,y1,2 do pset(x,yy,c) end
end

function dot_box(x0,y0,x1,y1,c)
 dot_h(x0+1,x1-1,y0,c)
 dot_h(x0+1,x1-1,y1,c)
 dot_v(x0,y0+1,y1-1,c)
 dot_v(x1,y0+1,y1-1,c)
 pset(x0,y0,c) pset(x1,y0,c)
 pset(x0,y1,c) pset(x1,y1,c)
end

function draw_arrow(x,y,dir,c)
 for i=0,2 do
  pset(x+dir*i,y+i,c)
  pset(x+dir*i,y+4-i,c)
 end
end

function draw_small_board()
 local bx,by,cell=38,33,17
 for off=0,51,17 do
  dot_h(bx,bx+51,by+off,col_dim)
  dot_v(bx+off,by,by+51,col_dim)
 end
 local demo={2,1,2,1,2,1,2,1,2}
 for i=1,9 do
  local x=bx+((i-1)%3)*cell+4
  local y=by+flr((i-1)/3)*cell+4
  draw_mark(demo[i],x,y,"small",col_green)
 end
end

function draw_splash()
 draw_title()
 draw_small_board()
 local c=capture_mode and col_green or (flr(t()/0.45)%2==0 and col_green or col_dim)
 dot_box(13,96,114,108,c)
 centred_text("press any button",99,col_cream)
end

function draw_menu()
 draw_title()
 draw_small_board()
 local c1=menu_focus==1 and col_green or col_dim
 local c2=menu_focus==2 and col_green or col_dim
 dot_box(29,89,98,101,c1)
 centred_text(difficulty_names[difficulty+1],92,col_green)
 draw_arrow(36,93,-1,c1)
 draw_arrow(91,93,1,c1)
 dot_box(29,104,98,116,c2)
 centred_text("2 players",107,col_green)
 centred_text("x play",120,col_cream)
end

function draw_score()
 sprite_text("x",3,4,col_green)
 sprite_text(tostr(score_x),13,4,col_cream)
 centred_text("round "..round_no,4,col_dim)
 local right="o "..score_o
 sprite_text(right,125-text_width(right),4,col_green)
end

function draw_cursor(cell,c)
 local col=(cell-1)%3
 local row=flr((cell-1)/3)
 local x0=22+col*30
 local y0=19+row*30
 local x1=x0+24
 local y1=y0+24
 line(x0,y0,x0+4,y0,c) line(x0,y0,x0,y0+4,c)
 line(x1,y0,x1-4,y0,c) line(x1,y0,x1,y0+4,c)
 line(x0,y1,x0+4,y1,c) line(x0,y1,x0,y1-4,c)
 line(x1,y1,x1-4,y1,c) line(x1,y1,x1,y1-4,c)
end

function draw_large_board()
 local bx,by,cell=19,16,30
 for off=0,90,30 do
  dot_h(bx,bx+90,by+off,col_dim)
  dot_v(bx+off,by,by+90,col_dim)
 end
 for i=1,9 do
  if board[i]!=0 then
   local x=bx+((i-1)%3)*cell+8
   local y=by+flr((i-1)/3)*cell+8
   local c=screen==screen_result and winning_colour(i) or col_green
   if pulse_time>0 and pulse_cell==i and pulse_time%2==1 then c=col_cream end
   draw_mark(board[i],x,y,"large",c)
  end
 end
 if screen==screen_play and not(mode>0 and turn==2) then
  draw_cursor(cursor,invalid_time>0 and col_green or col_cream)
 end
end

function draw_game()
 draw_score()
 draw_large_board()
 local status
 if screen==screen_result then
  status=result==1 and "x wins!" or result==2 and "o wins!" or "draw"
  centred_text(status,112,col_cream)
  centred_text("x next  o menu",121,col_dim)
 elseif mode>0 and turn==2 then
  centred_text("thinking...",112,col_green)
 else
  status=mode==0 and "player "..(turn==1 and "x" or "o") or "your turn"
  centred_text(status,112,col_green)
 end
end

function _draw()
 cls(col_black)
 if screen==screen_splash then draw_splash()
 elseif screen==screen_menu then draw_menu()
 else draw_game() end
end
function _init()
 screen=screen_splash
 menu_focus=1
 difficulty=0
 score_x=0
 score_o=0
 round_no=1
 result_time=0
 pulse_time=0
 invalid_time=0
 input_init()
 music(-1)
end

function _update60()
 read_input()
 update_effects()
 if screen==screen_splash then update_splash()
 elseif screen==screen_menu then update_menu()
 elseif screen==screen_play then update_play()
 else update_result() end
end