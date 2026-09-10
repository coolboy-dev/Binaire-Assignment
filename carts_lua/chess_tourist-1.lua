-- chess tourist
-- by lyrdl

function _init()
	board = nil
	game_index = 1
	games = {
		"the immortal game",
		"another game"
	}
	game_moves = nil
	move_index = 1
	annotation = nil
	annotation_scroll = 0
end

function _update()
 if(board == nil) then
  select_screen_input()
 elseif(annotation != nil) then
  annotation_screen_input()
 else
  game_screen_input()
 end
end

function _draw()
 cls()
 if(board == nil) then
  select_screen_draw()
 else
  game_screen_draw()
  if(annotation != nil) then
   annotation_screen_draw()
  end
 end
end

function select_screen_input()
 if btnp(⬅️) then
  game_index -= 1
 elseif btnp(➡️) then
  game_index += 1
 end 
 game_index = ((game_index + 1) % count(games)) + 1
 if btnp(❘) then
  start_game()
 end
end

function select_screen_draw()
 print("select game:",40,40)
 print(games[game_index],40, 60)
 print(game_index,40, 80)
end

function game_screen_draw()
 for x = 1,8 do
  for y = 1,8 do
   if(x % 2 == y % 2) then
    color(7)
		  spr(7,x*16-16,y*16-16,2,2)
   else
    color(5)
		  spr(9,x*16-16,y*16-16,2,2)
   end

   local p = board[y][x]
   local s = nil
   if p == 'p' then s = 17 end
   if p == 'r' then s = 18 end
   if p == 'n' then s = 19 end
   if p == 'b' then s = 20 end
   if p == 'q' then s = 21 end
   if p == 'k' then s = 22 end
   if p == 'P' then s = 1 end
   if p == 'R' then s = 2 end
   if p == 'N' then s = 3 end
   if p == 'B' then s = 4 end
   if p == 'Q' then s = 5 end
   if p == 'K' then s = 6 end
   
   if(s != nil) then
		  spr(s,x*16-12,y*16-12)
  	end
  end
 end
end

function game_screen_input()
 if btnp(❘) then
  if move_index <= count(game_moves) then
   step_game()
  end
 end
 if btnp(🅾️) then
  if move_index > 1 then
   unstep_game()
  end
 end
end

function annotation_screen_input()
	if btnp(❘) or btnp(🅾️) then
  annotation = nil
  annotation_scroll = 0
  if btnp(🅾️) then
   move_index -= 1
	 end
 end
 if btnp(⬇️) then 
  annotation_scroll += 8
 end
 if btnp(⬆️) then 
  annotation_scroll -= 8
 end
end

function annotation_screen_draw()
	rectfill(16,0,112,128,1)
	rect(16,-1,112,128,13)
	local words = split(sub(annotation,3)," ")
	local index = 1
	local line_count = 1
	while (index <= count(words)) do
	 local lyne = ""
	 local can_fit_next_word = true
	 while (can_fit_next_word and index <= count(words)) do
	  lyne = lyne.." "..words[index]	  
 	 index += 1
 	 if(index <= count(words)) then
  	 can_fit_next_word = #lyne + #(""..words[index]) < 20
  	else 
   	can_fit_next_word = false
  	end
	 end
	 if(lyne == "") then index += 1 end
	 print(lyne,20,line_count*8-annotation_scroll)
	 line_count += 1
	end
end

function start_game()
 board = {
 	split("rnbqkbnr",1),
 	split("pppppppp",1),
 	split("        ",1),
 	split("        ",1),
 	split("        ",1),
 	split("        ",1),
 	split("PPPPPPPP",1),
 	split("RNBQKBNR",1)
 }
 game_moves = split(immortal,"|")
end

function step_game()
 local move = game_moves[move_index]
 if #move > 5 then
  -- annotation
  sfx(0)
  annotation = move
 else
	 -- move
  sfx(1)
	 local fx = ord(move,1)-96
	 local fy = 9-(ord(move,2)-48)
	 local tx = ord(move,3)-96
	 local ty = 9-(ord(move,4)-48)

	 board[ty][tx] = board[fy][fx]
	 board[fy][fx] = " "
 end
 move_index += 1
end

function unstep_game()
 local new_index = move_index - 1
 move_index = 1
 start_game()
 while (move_index < new_index) do
  step_game()
  annotation = nil
  annotation_scroll = 0
 end
end

immortal = [[
e2e4|e7e5|f2f4|

this is the king's gambit: anderssen offers his pawn in exchange for faster development. this was one of the most popular openings of the 19th century and is still occasionally seen, though defensive techniques have improved since anderssen's time.

|e5f4|f1c4|

the bishop's gambit; this line allows 3...qh4+, depriving white of the right to castle, and is less popular than 3.nf3. this check, however, also exposes black's queen to attack with a gain of tempo on the eventual ng1-f3.

|d8h4|e1f1|b7b5|

this is the bryan countergambit, deeply analysed by kieseritzky, and which sometimes bears his name. it is not considered a sound move by most players today.

|c4b5|g8f6|g1f3|

this is a common developing move, but in addition the knight attacks black's queen, forcing black to move it instead of developing his other pieces.

|h4h6|d2d3|

with this move, white solidifies control of the critical center of the board. german grandmaster robert huebner recommends 7.nc3 instead.

|f6h5|

this move threatens ...ng3+, and protects the pawn on f4, but also sidelines the knight to a poor position at the edge of the board, where knights are the least powerful, and does not develop a new piece.

|f3h4|h6g5|

better was 8...g6, according to kieseritzky.

|h4f5|c7c6|

this simultaneously unpins the queen pawn and attacks the bishop. modern chess engines suggest 9...g6 would be better, to deal with a very troublesome knight.

|g2g4|h5f6|h1g1|

this is an advantageous passive piece sacrifice. if black accepts, his queen will be boxed in, giving white a lead in development.

|c6b5|

huebner believes this was black's critical mistake; this gains material but lacks in development, at a point where white's strong development is able to quickly mount an offensive. huebner recommends 11...h5 instead.

|h2h4|

white's knight at f5 protects the pawn, which attacks black's queen.

|g5g6|h4h5|g6g5|d1f3|

white now has two threats: bxf4, trapping black's queen (the queen having no safe place to go); e5, attacking black's knight at f6 while simultaneously exposing an attack by white's queen on the unprotected black rook on a8.

|f6g8|

this deals with the threats, but undevelops black even further -- now the only black piece not on its starting square is the queen, which is about to be put on the run, while white has control over a great deal of the board.

|c1f4|g5f6|b1c3|f8c5|

an ordinary developing move by black, which also attacks the rook at g1.

|c3d5|

white responds to the attack with a counterattack. this move threatens the black queen and also nc7+, forking the king and rook. richard reti recommends 17.d4 followed by 18.nd5, with advantage to white, although if 17.d4 bf8 then 18.be5 would be a stronger move.

|f6b2|

black gains a pawn, and threatens to gain the rook on a1 with check.

|f4d6|

with this move white offers to sacrifice both of his rooks. huebner comments that, from this position, there are actually many ways to win, and he believes there are atleast three better moves than 18.bd6: 18.d4, 18.be3, or 18.re1, which lead to strong positions or checkmate without needing to sacrifice so much material. the chessmaster computer program annotation says "the main point [of 18. bd6] is to divert the black queen from the a1-h8 diagonal. now black cannot play 18...bxd6? 19.nxd6+ kd8 20.nxf7+ ke8 21.nd6+ kd8 22.qf8#." garry kasparov comments that the world of chess would have lost one of its "crown jewels" if the game had continued in such an unspectacular fashion. 18. bd6! is surprising, because white is willing to give up so much material.

|c5g1|

wilhelm steinitz suggested in 1879 that a better move would be 18...qxa1+; likely moves to follow are 19.ke2 qb2 20.kd2 bxg1.  the continuation played is still winning for white, however, despite having many complications. the variation continues 21.e5! ba6 22.bb4! qxe5 (22...be3+ 23.qxe3+/-; 22...nh6 23.nd6+ kf8 24.g5+-) 23.nd6+ qxd6 24.bxd6+/-.

|e4e5|

this sacrifices yet another white rook. more importantly, this move blocks the queen from participating in the defense of the king, and threatens mate in two: 20.nxg7+ kd8 21.bc7#.

|b2a1|f1e2|

at this point, black's attack has run out of steam; black has a queen and bishop on white's back rank, but cannot effectively mount an immediate attack on white, while white can storm forward. according to kieseritzky, he resigned at this point. huebner notes that an article by friedrich amelung in the journal baltische schachblaetter, 1893, reported that kiesertizky probably played 20...na6, but anderssen then announced the mating moves. the oxford companion to chess also says that black resigned at this point, citing an 1851 publication. in any case, it is suspected that the last few moves were not actually played on the board in the original game.

|b8a6|

the black knight covers c7 as white was threatening 21.nxg7+ kd8 22.bc7#. another attempt to defend is 20...ba6, allowing the black king to flee via c8 and b7, although white has enough with the continuation 21.nc7+ kd8 and 22.nxa6, where if now 22...qxa2 (to defend f7 against bc7+, nd6+ and qxf7#) white can play 23.bc7+ ke8 24.nb4, winning; or, if 22...bb6 (stopping bc7+), 23.qxa8 qc3 24.qxb8+ qc8 25.qxc8+ kxc8 26.bf8 h6 27.nd6+ kd8 28.nxf7+ ke8 29.nxh8 kxf8, with a winning endgame for white.

|f5g7|e8d8|f3f6|

this queen sacrifice forces black to give up his defense of e7.

|g8f6|d6e7|

at the end, black is ahead in material by a considerable margin: a queen, two rooks, and a bishop. but the material does not help black. white has been able to use his remaining pieces -- two knights and a bishop -- to force mate.
]]