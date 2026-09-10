-- marienbad
-- by alkhan
-- marienbad rules constants

min_rows=2
max_rows=8
min_start_matches=1
max_matches=15
standard_rows={1,3,5,7}

player_state="player"
anim_state="animating"
ai_state="ai"
over_state="game_over"

anim_frames=15 -- 250ms at 60fps
ai_delay_frames=42 -- 700ms at 60fps

easy_mode="easy"
perfect_mode="perfect"
duel_mode="2 players"
-- marienbad rules and turn state
-- deliberately independent from input, drawing, effects and audio

function config_valid(a)
 if type(a)!="table" or #a<min_rows or #a>max_rows then return false end
 for n in all(a) do
  if type(n)!="number" or n!=flr(n)
   or n<min_start_matches or n>max_matches then return false end
 end
 return true
end

function copy_rows(a)
 local out={}
 for n in all(a) do add(out,n) end
 return out
end

function good_difficulty(d)
 return d==easy_mode or d==perfect_mode or d==duel_mode
end

function new_game(config,difficulty)
 local old_diff=g and g.difficulty or perfect_mode
 local chosen=config_valid(config) and config or standard_rows
 local d=good_difficulty(difficulty) and difficulty or old_diff
 g={
  rows=copy_rows(chosen),
  caps=copy_rows(chosen),
  start_config=copy_rows(chosen),
  difficulty=d,
  player_number=1,
  state=player_state,
  current="player",
  winner=nil,
  selected_row=0,
  selected_from=0,
  pending=nil,
  anim_ticks=0,
  ai_ticks=0,
  round_id=(g and g.round_id or 0)+1,
  move_count=0,
  last_move=nil
 }
 return g
end

function restart_game()
 local config=g and g.start_config or standard_rows
 local difficulty=g and g.difficulty or perfect_mode
 return new_game(config,difficulty)
end

function set_difficulty(d)
 if not good_difficulty(d) then return false end
 g.difficulty=d
 return true
end

function match_total()
 local total=0
 for n in all(g.rows) do total+=n end
 return total
end

function nim_sum()
 local total=0
 for n in all(g.rows) do total=total^^n end
 return total
end

function legal_move(row,count)
 return type(row)=="number" and row==flr(row)
  and type(count)=="number" and count==flr(count)
  and row>=1 and row<=#g.rows
  and g.rows[row]>0
  and count>=1 and count<=g.rows[row]
end

function can_select(row,from)
 return g.state==player_state
  and type(row)=="number" and row==flr(row)
  and type(from)=="number" and from==flr(from)
  and row>=1 and row<=#g.rows
  and from>=1 and from<=g.rows[row]
end

function select_match(row,from)
 if not can_select(row,from) then return false end
 g.selected_row=row
 g.selected_from=from
 return true
end

function clear_selection()
 g.selected_row=0
 g.selected_from=0
end

function apply_move(actor,row,count)
 local human=actor=="player" or actor=="player1" or actor=="player2"
 local expected=human and player_state or ai_state
 if not human and actor!="computer" then return false end
 if g.state!=expected or not legal_move(row,count) then return false end

 local before=g.rows[row]
 g.rows[row]-=count
 g.pending={actor=actor,row=row,count=count,before=before}
 g.last_move={actor=actor,row=row,count=count,before=before,after=g.rows[row]}
 g.move_count+=1
 g.state=anim_state
 g.current=actor
 g.anim_ticks=anim_frames
 g.ai_ticks=0
 clear_selection()
 return true
end

function player_take(row,count)
 local actor="player"
 if g.difficulty==duel_mode then actor="player"..g.player_number end
 return apply_move(actor,row,count)
end

function player_take_from(row,from)
 if type(row)!="number" or row!=flr(row)
  or type(from)!="number" or from!=flr(from)
  or row<1 or row>#g.rows then return false end
 return player_take(row,g.rows[row]-from+1)
end

function finish_animation()
 if g.state!=anim_state or not g.pending then return false end
 local actor=g.pending.actor
 g.anim_ticks=0

 if match_total()==0 then
  g.state=over_state
  g.winner=actor
  g.current=nil
  g.ai_ticks=0
 elseif actor!="computer" and g.difficulty==duel_mode then
  g.player_number=3-g.player_number
  g.state=player_state
  g.current="player"..g.player_number
  g.ai_ticks=0
 elseif actor=="player" then
  g.state=ai_state
  g.current="computer"
  g.ai_ticks=ai_delay_frames
 else
  g.state=player_state
  g.current="player"
  g.ai_ticks=0
 end
 g.pending=nil
 return true
end

function random_ai_move()
 local live={}
 for row=1,#g.rows do
  if g.rows[row]>0 then add(live,row) end
 end
 if #live==0 then return nil end
 local row=live[1+flr(rnd(#live))]
 return row,1+flr(rnd(g.rows[row]))
end

function perfect_ai_move()
 local sum=nim_sum()
 if sum!=0 then
  for row=1,#g.rows do
   local target=g.rows[row]^^sum
   if target<g.rows[row] then return row,g.rows[row]-target end
  end
 end
 return random_ai_move()
end

function choose_ai_move()
 if match_total()==0 then return nil end
 if g.difficulty==easy_mode then return random_ai_move() end
 return perfect_ai_move()
end

function ai_take()
 if g.difficulty==duel_mode or g.state!=ai_state or match_total()==0 then return false end
 local row,count=choose_ai_move()
 if not row then return false end
 return apply_move("computer",row,count)
end

function update_game()
 if g.state==anim_state then
  g.anim_ticks-=1
  if g.anim_ticks<=0 then finish_animation() end
 elseif g.state==ai_state then
  g.ai_ticks-=1
  if g.ai_ticks<=0 then ai_take() end
 end
end

function advance_frames(n)
 for i=1,n do update_game() end
end
-- marienbad stage 1 drawing layer
-- every screen accepts literal view data now and live game data later

function skin()
 pal()
 pal(0,129,1)
end

function ctext(s,y,c)
 print(s,64-#s*2,y,c)
end

function bigtext(s,y,c,shadow)
 local x=64-#s*4
 if shadow then print("\^w\^t"..s,x+2,y+2,shadow) end
 print("\^w\^t"..s,x,y,c)
end

function box(x0,y0,x1,y1,edge,fill)
 rectfill(x0+2,y0,x1-2,y1,fill)
 rectfill(x0,y0+2,x1,y1-2,fill)
 rect(x0+1,y0+1,x1-1,y1-1,edge)
 pset(x0+1,y0+1,7) pset(x1-1,y0+1,7)
 pset(x0+1,y1-1,edge) pset(x1-1,y1-1,edge)
end

function deco_border(c)
 rect(3,3,124,124,c)
 line(3,11,11,3,c) line(116,3,124,11,c)
 line(3,116,11,124,c) line(116,124,124,116,c)
 pset(7,7,10) pset(120,7,10)
 pset(7,120,10) pset(120,120,10)
end

function base_bg()
 skin() cls(0)
 rectfill(0,0,127,18,1)
 for i=0,7 do
  local x=9+i*17
  local twinkle=(app_t or 0)%40
  pset(x,11,(i%2==0 and twinkle<30) and 10 or 2)
 end
 deco_border(4)
end

function ornament(y,c)
 line(25,y,48,y,c) line(80,y,103,y,c)
 line(40,y-3,48,y,c) line(80,y,88,y-3,c)
 circfill(64,y,2,c)
 line(52,y,60,y,c) line(68,y,76,y,c)
 pset(64,y,7)
end

function wordmark(y,small)
 local col=small and 7 or 10
 if small then
  ctext("m a r i e n b a d",y,col)
 else
  bigtext("MARIENBAD",y,col,2)
  line(26,y+15,101,y+15,2)
  line(35,y+17,92,y+17,10)
 end
end

function vmatch(x,y,hot,burnt)
 -- y is the head centre; long vertical silhouette stays readable at 1x
 if burnt then
  line(x+1,y+2,x,y+10,5)
  line(x,y+9,x+2,y+11,1)
  circfill(x,y,2,5)
  pset(x-1,y-1,1)
  return
 end
 local stick=hot and 9 or 15
 local head=hot and 10 or 8
 line(x+1,y+3,x+2,y+12,1)
 line(x,y+2,x,y+11,stick)
 line(x+1,y+3,x+1,y+11,4)
 circfill(x,y,3,2)
 circfill(x,y-1,2,head)
 pset(x-1,y-2,hot and 7 or 14)
 if hot then
  local pulse=(app_t or 0)%12<8
  if pulse then pset(x-4,y,9) pset(x+4,y,9) end
  pset(x,y-4,pulse and 10 or 9)
 end
end

function hmatch(x,y,hot,burnt)
 if burnt then
  line(x,y,x+16,y+1,5)
  circfill(x+17,y+1,2,5)
  return
 end
 local stick=hot and 9 or 15
 line(x,y+1,x+17,y+1,4)
 line(x,y,x+17,y,stick)
 circfill(x+19,y,3,2)
 circfill(x+20,y-1,2,hot and 10 or 8)
 pset(x+20,y-2,hot and 7 or 14)
end

function centered_hmatch(y,hot,burnt)
 -- burnt art is four pixels shorter than a live match
 hmatch(burnt and 54 or 52,y,hot,burnt)
end

function matchdisplay(y)
 -- a straight, symmetrical row: no accidental letterform
 box(34,y-7,93,y+17,4,1)
 for i=1,5 do
  vmatch(44+(i-1)*10,y,i==3,false)
 end
end

function draw_splash(v)
 base_bg()
 ornament(27,10)
 wordmark(36,false)
 ctext(v.subtitle or "a game of the last match",58,6)
 matchdisplay(76)
 box(22,101,105,115,10,1)
 ctext(v.prompt or "press any button",106,7)
 ctext("mouse / touch welcome",119,5)
end

function draw_menu(v)
 base_bg()
 wordmark(8,true)
 ornament(17,2)
 box(15,29,112,112,4,1)
 ctext("the last match wins",35,15)
 centered_hmatch(47,true,false)
 for i=1,3 do
  local y=61+(i-1)*16
  local active=v.selected==i
  box(25,y,102,y+12,active and 10 or 4,0)
  if i==1 then ctext("start game",y+4,active and 10 or 7)
  elseif i==2 then
   ctext("< "..v.difficulty.." >",y+4,active and 10 or 7)
  else ctext("how to play",y+4,active and 10 or 7) end
 end
 ctext("arrows + x  /  mouse",118,5)
end

function draw_help(v)
 base_bg()
 wordmark(8,true)
 ornament(17,2)
 box(12,27,115,109,10,1)
 ctext("how to play",33,10)
 ctext("pick one row",47,7)
 ctext("take one or more matches",57,7)
 ctext("only from that row",67,7)
 for i=1,5 do vmatch(42+(i-1)*11,78,i>=3,false) end
 line(62,94,85,94,10)
 print(">",87,91,10)
 ctext("last match wins",99,15)
 ctext(v.back or "o  back",116,6)
end

function matchx(cap,i)
 return 64-(cap-1)*5+(i-1)*10
end

function board(v)
 for r=1,#v.rows do
  local y=34+(r-1)*16
  print(r,11,y+2,6)
  local n=v.rows[r]
  local cap=v.caps[r]
  if n==0 then
   for x=31,96,8 do pset(x,y+5,5) end
   print("spent",99,y+2,5)
  else
   for i=1,n do
    local hot=v.pick_row==r and i>=v.pick_from
    vmatch(matchx(cap,i),y,hot,false)
   end
  end
 end
end

function game_frame(v)
 base_bg()
 box(25,4,102,17,v.status_col or 10,1)
 ctext(v.status,9,v.status_col or 7)
 print("matches "..v.total,5,23,6)
 print(v.difficulty,v.difficulty=="2 players" and 87 or 94,23,6)
 camera(fx_shake_x or 0,fx_shake_y or 0)
 board(v)
 camera()
 line(6,103,121,103,4)
 if v.note then ctext(v.note,107,v.note_col or 15) end
 box(5,113,44,123,4,1)
 print("o restart",8,117,6)
end

function draw_play(v)
 game_frame(v)
 -- cursor brackets identify the first match that will be taken
 if v.pick_row and v.pick_row>0 then
  local x=matchx(v.caps[v.pick_row],v.pick_from)
  local y=34+(v.pick_row-1)*16
  line(x-5,y-5,x-2,y-5,10) line(x-5,y-5,x-5,y-2,10)
  line(x+5,y+15,x+2,y+15,10) line(x+5,y+15,x+5,y+12,10)
 end
end

function draw_take(v)
 game_frame(v)
 -- loudest readable removal frame: matches travel right and become sparks
 for i=1,#v.flying do
  local f=v.flying[i]
  line(f.x-8,f.y+7,f.x+3,f.y-2,15)
  circfill(f.x+5,f.y-4,2,10)
  pset(f.x+9,f.y-6,14) pset(f.x+11,f.y,9)
  pset(f.x+4,f.y-9,7)
 end
 box(37,92,90,102,10,1)
 ctext(v.take_label,95,10)
end

function draw_ai(v)
 game_frame(v)
 box(22,90,105,102,8,1)
 ctext("house is thinking",94,15)
 for i=1,3 do
  circfill(54+i*7,110,1,i<=v.lit_dots and 10 or 4)
 end
end

function result_back(v)
 game_frame(v)
 rectfill(3,27,124,124,0)
 box(10,29,117,123,v.edge,0)
 ornament(41,v.edge)
end

function draw_win(v)
 result_back(v)
 bigtext("VICTORY",47,10,2)
 ctext(v.win_label or "you struck the last match",66,7)
 centered_hmatch(79,true,false)
 ctext(v.scoreline,91,15)
 box(36,98,92,111,10,1)
 ctext("play again",103,7)
 ctext("x again   o menu",116,6)
end

function draw_loss(v)
 result_back(v)
 bigtext("THE HOUSE",45,8,2)
 bigtext("WINS",58,8,2)
 ctext("the last flame is gone",76,6)
 centered_hmatch(88,false,true)
 box(36,98,92,111,8,1)
 ctext("try again",103,7)
 ctext("x again   o menu",116,5)
end

function draw_pointer(x,y)
 line(x,y,x+5,y+3,7)
 line(x,y,x+1,y+6,7)
 pset(x+2,y+3,10)
end
-- sound ids are authored by tools/audio.py

function audio_init()
 music(0,700,7)
end

function audio_nav() sfx(0) end
function audio_confirm() sfx(1) end
function audio_player_take() sfx(2) end
function audio_house_take() sfx(3) end
function audio_restart() sfx(4) end
function audio_win() sfx(5) end
function audio_loss() sfx(6) end
function audio_flare() sfx(7) end
-- mechanic-linked feedback; intensity follows JUICE.md

function effects_init()
 fx_parts={}
 fx_matches={}
 fx_shake=0 fx_shake_x=0 fx_shake_y=0
 fx_flash=0 fx_flash_col=10 fx_border=0
 fx_last_x=64 fx_last_y=64
 result_lock=0
end

function effects_reset()
 fx_parts={} fx_matches={}
 fx_shake=0 fx_shake_x=0 fx_shake_y=0
 fx_flash=0 fx_border=0 result_lock=0
end

function spark(x,y,vx,vy,c,life)
 add(fx_parts,{x=x,y=y,vx=vx,vy=vy,c=c,l=life,m=life})
end

function feedback_move(move)
 local player=move.actor!="computer"
 local dir=player and 1 or -1
 local y=34+(move.row-1)*16
 local first=move.after+1
 local colour=player and 10 or 8

 for i=first,move.before do
  local x=matchx(g.caps[move.row],i)
  fx_last_x=x fx_last_y=y
  add(fx_matches,{x=x,y=y,vx=dir*(0.7+rnd(0.8)),vy=-0.4-rnd(0.7),
   a=0.25,av=dir*(rnd(0.08)-0.02),l=anim_frames,m=anim_frames,
   head=player and 10 or 8,stick=player and 9 or 15})
  for p=1,3 do
   spark(x,y,dir*(0.4+rnd(1.7)),rnd(1.8)-0.9,
    rnd(1)<0.25 and 7 or colour,8+rnd(10))
  end
 end

 fx_shake=max(fx_shake,2.5)
 fx_border=8
 if player then audio_player_take() else audio_house_take() end
end

function feedback_finish(winner)
 fx_shake=max(fx_shake,6)
 fx_flash=5
 fx_flash_col=winner!="computer" and 10 or 8
 fx_border=18
 result_lock=30
 local c=winner!="computer" and 10 or 8
 for i=1,28 do
  local a=rnd(1)
  local speed=0.5+rnd(2.5)
  spark(fx_last_x,fx_last_y,cos(a)*speed,sin(a)*speed,
   rnd(1)<0.3 and 7 or c,18+rnd(16))
 end
 audio_flare()
 if winner!="computer" then audio_win() else audio_loss() end
end

function effects_update()
 if result_lock>0 then result_lock-=1 end
 if fx_flash>0 then fx_flash-=1 end
 if fx_border>0 then fx_border-=1 end
 fx_shake*=0.86
 if fx_shake>0.3 then
  fx_shake_x=rnd(fx_shake)-fx_shake/2
  fx_shake_y=rnd(fx_shake)-fx_shake/2
 else
  fx_shake_x=0 fx_shake_y=0
 end

 for p in all(fx_parts) do
  p.x+=p.vx p.y+=p.vy
  p.vx*=0.92 p.vy=p.vy*0.92+0.025
  p.l-=1
  if p.l<=0 then del(fx_parts,p) end
 end
 for m in all(fx_matches) do
  m.x+=m.vx m.y+=m.vy
  m.vx*=0.96 m.vy+=0.07 m.a+=m.av
  m.l-=1
  if m.l<=0 then del(fx_matches,m) end
 end
end

function draw_flying_match(m)
 local dx=cos(m.a)*11
 local dy=sin(m.a)*11
 line(m.x+1,m.y+1,m.x+dx+1,m.y+dy+1,1)
 line(m.x,m.y,m.x+dx,m.y+dy,m.stick)
 circfill(m.x,m.y,2,2)
 circfill(m.x,m.y-1,1,m.head)
end

function draw_effects()
 camera(fx_shake_x or 0,fx_shake_y or 0)
 for m in all(fx_matches) do draw_flying_match(m) end
 for p in all(fx_parts) do
  local c=p.l<5 and 4 or p.c
  line(p.x,p.y,p.x-p.vx*2,p.y-p.vy*2,c)
  pset(p.x,p.y,p.l>p.m-3 and 7 or c)
 end
 camera()
end

function draw_effect_overlay()
 if fx_border>0 then
  local c=fx_border%4<2 and 10 or 2
  rect(1,1,126,126,c)
 end
 if fx_flash>0 then
  if fx_flash>=4 then
   rectfill(0,0,127,127,7)
  else
   rect(0,0,127,127,fx_flash_col)
   rect(2,2,125,125,fx_flash_col)
   for x=7,120,8 do
    pset(x,5,fx_flash_col) pset(x,122,fx_flash_col)
   end
  end
 end
end
-- keyboard, gamepad, mouse and touch-facing input

function input_init()
 poke(0x5f2d,1)
 mx=stat(32) my=stat(33)
 last_mx=mx last_my=my
 old_mouse_buttons=stat(34)
 mouse_pressed=false
 mouse_active=false
end

function input_update()
 mx=stat(32) my=stat(33)
 local buttons=stat(34)
 mouse_pressed=(buttons&1)>0 and (old_mouse_buttons&1)==0
 if mx!=last_mx or my!=last_my or mouse_pressed then mouse_active=true end
 last_mx=mx last_my=my
 old_mouse_buttons=buttons
end

function any_button_pressed()
 return btnp()!=0 or mouse_pressed
end

function mouse_in(x0,y0,x1,y1)
 return mx>=x0 and mx<=x1 and my>=y0 and my<=y1
end

function controller_used()
 if btnp(0) or btnp(1) or btnp(2) or btnp(3) or btnp(4) or btnp(5) then
  mouse_active=false
  return true
 end
 return false
end

function next_live_row(from,delta)
 for step=1,#g.rows do
  local row=(from-1+delta*step)%#g.rows+1
  if g.rows[row]>0 then return row end
 end
 return from
end

function pointer_match()
 for row=1,#g.rows do
  if g.rows[row]>0 then
   local y=34+(row-1)*16
   if my>=y-4 and my<=y+13 then
    for i=1,g.rows[row] do
     if abs(mx-matchx(g.caps[row],i))<=5 then return row,i end
    end
   end
  end
 end
 return 0,0
end

function cursor_repair()
 if cursor_row and g.rows[cursor_row] and g.rows[cursor_row]>0 then
  cursor_from=mid(1,cursor_from,g.rows[cursor_row])
  return
 end
 cursor_row=next_live_row(cursor_row or 1,1)
 cursor_from=1
end

function update_player_selection()
 local old_row=g.selected_row
 local old_from=g.selected_from
 controller_used()
 if mouse_active then
  local row,from=pointer_match()
  clear_selection()
  if row>0 then select_match(row,from) end
  if g.selected_row>0 and (g.selected_row!=old_row or g.selected_from!=old_from) then audio_nav() end
  return
 end

 cursor_repair()
 if btnp(0) then cursor_from=max(1,cursor_from-1) end
 if btnp(1) then cursor_from=min(g.rows[cursor_row],cursor_from+1) end
 if btnp(2) then
  cursor_row=next_live_row(cursor_row,-1)
  cursor_from=min(cursor_from,g.rows[cursor_row])
 end
 if btnp(3) then
  cursor_row=next_live_row(cursor_row,1)
  cursor_from=min(cursor_from,g.rows[cursor_row])
 end
 clear_selection()
 select_match(cursor_row,cursor_from)
 if g.selected_row!=old_row or g.selected_from!=old_from then audio_nav() end
end

function player_input()
 update_player_selection()
 if mouse_pressed and g.selected_row>0 then
  return player_take_from(g.selected_row,g.selected_from)
 elseif btnp(5) then
  return player_take_from(cursor_row,cursor_from)
 end
 return false
end
-- marienbad application flow

function app_init()
 app_t=0
 effects_init()
 audio_init()
 ui_screen="splash"
 menu_selected=1
 menu_difficulty=perfect_mode
 cursor_row=1 cursor_from=1
 new_game(standard_rows,menu_difficulty)
 input_init()
end

function start_match()
 effects_reset()
 new_game(standard_rows,menu_difficulty)
 ui_screen="game"
 cursor_row=1 cursor_from=1
 mouse_active=false
 select_match(cursor_row,cursor_from)
 audio_confirm()
end

function restart_match()
 effects_reset()
 restart_game()
 cursor_row=1 cursor_from=1
 mouse_active=false
 select_match(cursor_row,cursor_from)
 audio_restart()
end

function cycle_mode(delta)
 local modes={easy_mode,perfect_mode,duel_mode}
 local index=1
 for i=1,3 do if menu_difficulty==modes[i] then index=i end end
 index=(index-1+delta)%3+1
 menu_difficulty=modes[index]
end

function menu_input()
 local old_selected=menu_selected
 local old_difficulty=menu_difficulty
 controller_used()
 if btnp(2) then menu_selected=(menu_selected+1)%3+1 mouse_active=false end
 if btnp(3) then menu_selected=menu_selected%3+1 mouse_active=false end
 if menu_selected==2 and btnp(0) then cycle_mode(-1) end
 if menu_selected==2 and btnp(1) then cycle_mode(1) end

 if mouse_active then
  for item=1,3 do
   local y=61+(item-1)*16
   if mouse_in(25,y,102,y+12) then menu_selected=item end
  end
 end

 if mouse_pressed then
  if mouse_in(25,61,102,73) then start_match()
  elseif mouse_in(25,77,102,89) then
   cycle_mode(1)
  elseif mouse_in(25,93,102,105) then ui_screen="help" end
 elseif btnp(5) then
  if menu_selected==1 then start_match()
  elseif menu_selected==2 then
   cycle_mode(1)
  else ui_screen="help" end
 end
 if menu_selected!=old_selected or menu_difficulty!=old_difficulty then audio_nav() end
end

function game_input()
 if g.state!=over_state
  and (btnp(4) or (mouse_pressed and mouse_in(5,113,44,123))) then
  restart_match()
  return
 end

 if g.state==player_state then
  if player_input() then feedback_move(g.last_move) end
 elseif g.state==anim_state or g.state==ai_state then
  local old_state=g.state
  local old_moves=g.move_count
  update_game()
  if g.move_count>old_moves then feedback_move(g.last_move) end
  if old_state==anim_state and g.state==over_state then feedback_finish(g.winner) end
  if g.state==player_state then cursor_repair() end
 elseif g.state==over_state then
  if result_lock<=0 and (btnp(5) or (mouse_pressed and mouse_in(36,98,92,111))) then
   restart_match()
  elseif result_lock<=0 and (btnp(4) or (mouse_pressed and mouse_in(78,112,112,122))) then
   ui_screen="menu"
   menu_difficulty=g.difficulty
  end
 end
end

function _init()
 app_init()
end

function _update60()
 app_t+=1
 input_update()
 effects_update()
 if ui_screen=="splash" then
  if any_button_pressed() then ui_screen="menu" audio_confirm() end
 elseif ui_screen=="menu" then
  menu_input()
 elseif ui_screen=="help" then
  if btnp(4) or btnp(5) or mouse_pressed then ui_screen="menu" audio_nav() end
 else
  game_input()
 end
end

function base_game_view(status,status_col,note,note_col)
 return {
  status=status,status_col=status_col,
  rows=g.rows,caps=g.caps,total=match_total(),difficulty=g.difficulty,
  pick_row=g.selected_row,pick_from=g.selected_from,
  note=note,note_col=note_col
 }
end

function current_play_view()
 local count=0
 if g.selected_row>0 then count=g.rows[g.selected_row]-g.selected_from+1 end
 local note=count>0 and "take "..count.." matches" or nil
 local status="your move"
 local col=10
 if g.difficulty==duel_mode then
  status="player "..g.player_number.." turn"
  col=g.player_number==1 and 10 or 8
 end
 return base_game_view(status,col,note,15)
end

function current_take_view()
 local actor=g.pending and g.pending.actor or g.current
 local count=g.pending and g.pending.count or (g.last_move and g.last_move.count or 1)
 local human=actor!="computer"
 local status=human and "your move" or "house turn"
 local label=human and "you took " or "house took "
 if actor=="player1" or actor=="player2" then
  local n=sub(actor,#actor,#actor)
  status="player "..n.." move"
  label="p"..n.." took "
 end
 local v=base_game_view(status,human and 10 or 8,"a clean strike",10)
 v.take_label=label..count
 v.flying={}
 if stage3_static then
  local preset={{79,72},{88,67},{97,75}}
  for i=1,min(count,3) do add(v.flying,{x=preset[i][1],y=preset[i][2]}) end
 end
 return v
end

function current_ai_view()
 local v=base_game_view("house turn",8,nil,nil)
 v.lit_dots=2
 return v
end

function current_result_view()
 local human=g.winner!="computer"
 local v=base_game_view("game over",human and 10 or 8,nil,nil)
 v.edge=human and 10 or 8
 if g.winner=="player1" or g.winner=="player2" then
  local n=sub(g.winner,#g.winner,#g.winner)
  v.win_label="player "..n.." struck last"
  v.scoreline="player "..n.." takes the table"
 else
  v.scoreline="guest  1 : 0  house"
 end
 return v
end

function _draw()
 if ui_screen=="splash" then
  draw_splash({subtitle="a game of the last match",prompt="press any button"})
 elseif ui_screen=="menu" then
  draw_menu({selected=menu_selected,difficulty=menu_difficulty})
 elseif ui_screen=="help" then
  draw_help({back="o  back"})
 elseif g.state==player_state then
  draw_play(current_play_view())
 elseif g.state==anim_state then
  draw_take(current_take_view())
 elseif g.state==ai_state then
  draw_ai(current_ai_view())
 elseif g.winner!="computer" then
  draw_win(current_result_view())
 else
  draw_loss(current_result_view())
 end
 if ui_screen=="game" then draw_effects() end
 if mouse_active then draw_pointer(mx,my) end
 draw_effect_overlay()
end