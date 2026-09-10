--do not win this tic tac toe
--by bios

function _init()
	cls()
	cartdata("bios_tictacpow")--★
	secr=dget(0)
	countwin=dget(1)
	countlose=dget(2)
	powunlock=dget(3)
	if powunlock==0 then powunlock=3 end
	if	powunlock<=3 then powi=1 else powi=powunlock end
	
	--add hidden color by nerdyteacher
	poke(0x5f2e,1)
	custom_pal={[0]=0,1,2,140,130,129,6,7,8,128,10,9,12,5,14,141}
	reset_pal()
	
	poke(0x5f34,0x2)--invert fill
	bx,by,bw,bh=37,37,18,18	
	curx,cury,cx,cy,s,bg=0,0,0,0,0,secr
 winner=0
 exscore=0
	t=0
	ai_tick=0
	tbuffer=0
	shake=0
	totalround=powunlock+2
		
	p1={
		tindex=10,
		tspr={5,9},
		pspr={64,66},
		px=8,
		py=84,
		score=0,
		c=12,
		cmed=1,
		cdark=5,
		pow=nil,
		stomp=1,
		gamba=0,
		sfxn=1
	}
	
	p2={
		tindex=20,
		tspr={7,11},
		pspr={68,70},
		px=105,
		py=84,
		score=0,
		c=14,
		cmed=4,
		cdark=9,
		pow=nil,
		stomp=1,
		gamba=0,
 	sfxn=2
	}
	
	game={
		turn=p1,
		round=1,
		state="scrn",
		mode=nil,
		over=false,
		winner=nil
	}

	score={
		win=5,
		pow1=4,--king
		pow2=1,--cross
		pow3=1,--side
		pow4=5,--peace
		pow5=1,--potion
		pow7=1	--rabbit
	}
	
	pow={
		pow_king,
		pow_cross,
		pow_side,
		pow_peace,
		pow_potion,
		pow_stomp,
		pow_rabbit,
		pow_gamble
	}
	
	powspr={--split2d
		{120,11,7,5,4,-3,0,0},--king
		{120,17,5,10,12,5,2,-2},--cross
		{104,0,4,7,1,7,2,-1},--side
		{104,13,15,11,3,-12,-4,-2},--peace
		{117,0,11,11,10,0,-2,-3},--potion
		{111,0,6,8,10,4,0,-1},--stomp
		{104,7,7,6,4,-4,0,-1},--rabbit
		{104,26,7,6,4,7,0,0},--gamble
	}
		
	powname={--split2d
		{"king","+4 PTS,IF YOU PLACE,A TILE ON,THE CENTER"},
		{"crossbow","+1 PTS FOR,EVERY TILES,PLACE ON,EACH CORNER"},
		{"sideman","+1 PTS FOR,EVERY TILES,PLACE ON,EACH SIDE"},
		{"peacemaker","+5 PTS EVEN,IF THE GAME,ENDS IN,A DRAW","WIN A GAME"},
		{"magician","EVERY TURN:,ENEMY ONLY,HAS 3 TILES,YOUR PTS -1,FOR EVERY,VANISHED,TILES","LOSE A GAME"},
		{"stomper","EVERY ROUND:,YOU CAN,REPLACE ENEMY,TILE ONCE,(EXCEPT FOR,THE MOST,RECENT ONE)","WIN A GAME,BY 10 PTS OR LESS"},
		{"rabbit","ALWAYS GOES,FIRST.,RANDOMISE IF,THE ENEMY,IS ALSO,A RABBIT","LOSE A GAME,BY 10 PTS OR LESS"},
		{"gambler","EVERY TURN:,THERE IS A,10% CHANCE,TO PLACE,2 TILES","WIN A GAME,BY 5 PTS OR LESS"},
	}
	
	--fade by lazydevs
	fadetabledark=split2d"0,0,0,0,0,0,0,0,129,129,129,129,129,129,129|1,1,1,1,1,1,1,1,129,129,129,129,129,129,129|2,2,2,2,133,133,130,130,130,130,130,130,129,129,129|140,140,140,140,140,131,131,131,1,1,1,1,1,129,129|130,130,130,130,130,130,130,129,129,129,129,129,129,129,129|129,129,129,129,129,129,129,129,129,129,129,129,129,129,129|6,6,6,13,13,13,13,13,5,5,5,133,1,1,129|7,6,6,6,6,134,13,13,13,141,5,5,133,1,1|8,8,136,136,136,136,2,2,2,2,130,130,130,130,129|128,128,128,128,128,128,128,128,129,129,129,129,129,129,129|10,10,138,138,138,138,4,4,5,5,5,133,133,133,129|9,9,9,4,4,4,4,4,132,132,132,133,133,130,129|12,12,12,140,140,140,140,140,140,131,131,131,1,1,129|5,5,5,5,133,133,133,133,133,133,1,1,129,129,129|14,14,14,134,134,134,141,141,141,141,141,133,133,1,129|141,141,141,5,133,133,133,133,133,133,130,1,129,129,129"
	fadetablewhite=split2d"0,128,130,133,5,5,5,134,134,134,134,6,6,6,7|1,1,5,5,13,13,13,13,13,6,6,6,6,6,7|2,141,141,134,134,134,134,134,6,6,6,6,6,7,7|140,140,140,13,13,13,13,13,6,6,6,6,6,7,7|133,133,5,141,141,134,134,134,134,6,6,6,6,7,7|1,1,133,5,5,141,13,13,13,134,6,6,6,6,7|6,6,6,6,6,6,6,6,7,7,7,7,7,7,7|7,7,7,7,7,7,7,7,7,7,7,7,7,7,7|8,8,8,142,142,14,14,14,14,14,15,15,15,7,7|128,133,133,5,5,141,134,134,134,134,6,6,6,6,7|10,10,10,135,135,135,135,135,135,15,15,15,7,7,7|9,9,9,10,10,143,143,135,135,15,15,15,15,7,7|12,12,12,12,12,12,6,6,6,6,6,6,7,7,7|13,13,13,13,6,6,6,6,6,6,6,6,7,7,7|14,14,14,14,14,15,15,15,15,15,15,7,7,7,7|141,141,13,134,134,134,134,6,6,6,6,6,6,7,7"	
	fadeperc=0

	--one off gfx by heracleum
	scr="-bx8y81                \n                \n    15.\0\0\0\0\0?8-#c.\0\0\0\0\0\0??15.\0\0\0█|\0\0-#c.\0\0\0\0█???-#e.\0\0\0\0\0\0\0,15.\0\0??\0\0\0\0-#6.\0\0\0\0\0\0\0-#c.\0\0\0????\0-#e.\0\0\0\0\0\0?15.\0\0?\0\0\0\0\0-#6.\0\0\0\0\0\0\0-#c.\0\0\0???0?-#e.\0\0\0\0\0?a15.\0\0?\0\0\0\0\0-#c.\0\0\0???ol-#e.\0\0\0\0\0\0…⧗15.\0\0?\0\0\0\0-#c.\0\0\0??○?-#e.\0\0\0\0\0\0█_15.\0\0\0>?\0\0-#c.\0\0\0\0???-#e.\0\0\0\0\0\015.\0\0\0\0\0、?-#c.\0\0\0\0\0\0゜1    \n  15.\0\0\0█`「-#6.\0\0\0\0\0\0☉?-#c.\0\0\0\0\0\0@\0-#e.\0\0\0\0█?015.?「\0\0\0\0-#6.\0\0\0\0????-#c.\0?x゛\0「-#e.\0\0█??\0\0\067.\0\0\0\0\0\0\0-#c.゜\0\0?p\0\0-#e.?<\0\0\0\0\06c.L6\0\0\0-#e.??p、\0\0\06c.\0\0█?0\0-#e.\0\0\0?\0\0\067.\0\0\0\0\0\0█?-#c.?G!0\0\0\0\0-#e.8☉F\0\0\0\067.\0\0\0\0\0\0\0?-#c.w2•」\0-#e.☉L$\"▮\0\0\067.\0\0\0\0\0\0??-#c.?\0▮\0\0\0\0\0-#e.^?\0▮\0\0\0\067.\0\0\0\0\0\0\0-#c.}?█\0\0\0\0\0-#e.🐱.@█\0\0\0\06c.??█\0\0\0\0\0-#e.「\0\0\0\0\0\061.??█\0\0\0\0\0-#5.「`█\0\0\0\0-#c.\0゜|?@\0\0-#e.\0\0\0\0\0██\015.\0\0\0「 ?-#c.\0\0\0\0゜8-#e.\0\0\0\0\0\0\01  \n5.\0\0\0\0\0\0\0█1.█`▮\0-#6.\0\0█?????-#e.\0█`\0\0\0\0\06c.▮\0\0\0\0\0\0-#e.K▮\0\0\0\0\067.\0\0??????.???????.X???????.x゜??????.q<??????7  6.?\0\0\0\0\0\0\0.????█\0\0\0.????????6c.??\0█\0\0\0\0-#e.0\0█\0\0\0\0\061.?????█\0\0-#5.▮ @█\0-#c.\0$-#e.\0\0 \015.\0\0\0\0\0\0\0\n1.@  ▮-#6.█???????67.\0\0\0\0\0██?.@???????7         6.█\0\0\0\0\0\0\0.????????6c.\0 \0\0\0\0\0\0-#e. \0\0\0\0\0\0\061.????????-#5.▮▮  \n61.\0\0\0\0\0-#5.67.????????7           6.██\0\0\0\0\0\0.????????15.@@@█████-#6.???○○○○○\n6 7.????????7            6.????????6 \n 7.????????7            6.????????6 \n 7.????????7            6.????????6 \n 7.????????7           6.\0\0\0\0\0\0\0█.????????6 \n 7.????????7 76.\0\0\0\0??゛-#c.\0\0\0\0\0\0??76.\0\0\0??\0\0-#c.\0\0\0\0\0??\0-#e.\0\0\0\0\0\0\0?76.\0\0\0○?\0\0-#c.\0\0\0\0\0??-#e.\0\0\0\0\0\0\0?76.\0\0\0\0\0\0-#c.\0\0\0\0\0\0\07  76.\0\0\0\0\0?0▮-#c.\0\0\0\0\0\0?`-#e.\0\0\0\0\0\0\0█76.\0\0\0\0?\0@-#c.\0\0\0\0\0??\0-#e.\0\0\0\0\0\0\0?76.\0\0\0\0??\0\0-#c.\0\0\0\0\0??-#e.\0\0\0\0\0\0\076.\0\0\0\0゛p-#c.\0\0\0\0\0\076.██\0\0\0\0\0\06  \n 7.???█\0\0\0█6.○?゜゜゜???-#c.\0\0█\0\0\0\0\0-#e.\0\0\0?\0\0\0\061.\0\0\0\0\0\0\0?-#5.\0\0\0\0\0\0?「-#7.\0\0????-#c.゛\0\0\0\0\0\0-#e.?<\0\0\0\0\061.\0\0\0\0\0\0○?-#5.\0\0\0\0\0?\0\0-#7.?????\0█\061.\0\0\0\0\0\0-#5.\0\0\0\0\0>?-#7.??????8-#e.?\0\0\0\0\0\0\065.\0\0\0\0\0\0\0-#7.????????-#e.\0\0\0\0\0\0\07  75.\0\0\0\0\0\0\0?-#6.…?\0\0\0\0\0\0-#e.`\0\0\0\0\0\0\071.\0\0\0\0\0\0??-#5.\0\0\0\0\0?>■-#6.??\0\0\0\0\0\071.\0\0\0\0\0\0_?-#5.\0\0\0\0\0○█\0-#6.?\0\0\0\0\0\0-#e.?\0\0\0\0\0\0\071.\0\0\0\0\0\0\0-#5.\0\0\0\0\0\0-#6.?▒??\0\0\0\0-#c.>`\0\0\0\0\0\0-#e.゛\0\0\0\0\0\076.\0▒▒█████6  \n 7.█████???65.\0\0\0\0███\0-#7.?○○???゜゜-#c.\0\0█\0@\0@\015.&#A▒\0\0\0?-#7.」、>~???\015.\0\0\0?>\0??-#6.\0\0\0\0\0\0\0?-#7.\0\0\0\0???\015.?p\0-#6.\0\0\0\0█?~゜-#7.????█?56.\0\0\0\0\0-#7.????????7  75. ▮▮?\0\0\0\0-#6.\0\0\0▮?█\0\071.??█\0\0\0\0\0-#5.▮ @▒8?\0-#6.\0\0\0\0\0<?71.???>\0\0\0\0-#5.\0\0\0?>\0?-#6.\0\0\0\0\0\0\071.\0\0\0\0\0\0-#5.2bA@██\0?-#6.\0██\0\0\0\0\0-#c.\0\0\0█\0\0\0\075.\0\0\0\0\0\0\0-#6.███▒\0-#c.\0\0\0\0\0\076.????????6 \n 7.????████.゜゜??????.\0\0\0?????.\0█??????.????????7 6.\0\0\0\0███?.\0 .?\0\0\0\0\0\0\0.???\0\0\0\0\0.??○\0\0\0\0\0.\0\0\0\0\0\0.????????6 \n 7.\0\0███\0\0\0.????????7   75.\0\0\0██@@ -#6.\0\0█@`08、75.\0\0\0\0\0\0\0-#6.??\0\0\0\0\07.???\0\0\0\0\075.\0\0\0-#6.\0\0、x7   .\0\0\0\0\0█??.????????6 "
	
	ray={}
	parts={}
	powparts={}
	float={}
	bubble={}
	pop={}

	echoes={}--★
		
	_upd=update_menu
	_drw=draw_menu
	music(0)
end
	
function _update60()
	self=game.turn
	enemy=self==p1 and p2 or p1
	f=1+flr(time())%2

	_upd()
	doshake()
end

function _draw()
	_drw()
	print_echoes(2,20,7)--★

	if fadeperc>0 then 
		fadeperc=max(0,fadeperc-0.05)
		fade()
 end

	draw_echo()--★

end

function initstory()
	music(1)
	_upd=update_story
	_drw=draw_story
end

function initpowcheck()
	_upd=update_powcheck
	_drw=draw_powcheck
end

function initrndzer()
	t=0
	dur=0

	initboard()

	--randomise who starts
	if	rnd()<0.5 then	game.turn=p1 else game.turn=p2 end

	--randomise power
	rndpow1=flr(rnd(powunlock))+1
	if game.round==1 then 
		p1.pow=powunlock 
	else
		p1.pow=rndpow1
	end
	rndpow2=flr(rnd(powunlock))+1
	p2.pow=rndpow2
	
	--rabbit gamba triggers before game start
	p1.stomp=1
	p2.stomp=1
	p1.gamba=0
	p2.gamba=0

	pow_rabbit()
	check_gamba(p1)
	check_gamba(p2)
	
	_upd=update_rndzer
	_drw=draw_rndzer

end

function initgame()
	
	if game.round==1 then
		music(3,300)
	end

	_upd=update_game
	_drw=draw_game
	initparts()
	menuitem(2,"restart",function() _init() end)
end

function initinfo()
	_upd=update_info
	_drw=draw_info
end

function initexround()
	music(15,300)
	_upd=update_exround
	_drw=draw_exround
end

function initboard()
	board={
		{0,0,0},
		{0,0,0},
		{0,0,0},
	}
	
	lines=
	{{{1,1},{1,2},{1,3}},
  {{2,1},{2,2},{2,3}},
  {{3,1},{3,2},{3,3}},
  {{1,1},{2,1},{3,1}},
  {{1,2},{2,2},{3,2}},
  {{1,3},{2,3},{3,3}},
  {{1,1},{2,2},{3,3}},
  {{1,3},{2,2},{3,1}}
	}
	
	history={}
	winline={} --col 1-3, row 4-6, tl-br 7, tr-bl 8
end

function initend()

	if p1.score>p2.score then	
		countwin+=1
		dset(1,countwin)
	end
	
	if p1.score<p2.score then	
		countlose+=1
		dset(2,countlose)
	end

	checkpowunlock()
		
	if p1.score==p2.score and powunlock>=8 then
		secr=1
		bg=1
		fadeout(true,0.02)
		dset(0,secr)
	end

	_upd=update_ending
	_drw=draw_ending
	music(2)
end

function initparts()
	addray()
	addparts(self.px+rnd(12),-2,(rnd()-0.5)/4,rnd()+2,rnd(3),120,self.cdark)
end
-->8
--update--

function update_menu()
	t+=1
	if game.state!="slct" then
		if btnp(❘) then
			game.state="slct"
			sfx(20)
		end
	
	elseif game.state=="slct" then
		if btnp(➡️) then
			s=(s+1)%4
		elseif btnp(⬅️) then
			s=(s-1)%4
		end
	
		if btnp(❘) then
			if s==0 then
				game.mode="comp"
				initstory()
				fadeout()
				t=0
			elseif s==1 and powunlock==8 then
				game.mode="2plyr"
				initstory()
				fadeout()
				t=0
			end
		end
		
		if btnp(❘) and s==2 and secr==1 then
			bg=1-bg
			dset(0,secr)
			sfx(20)
		end
	end
	
	if btnp(⬅️) or btnp(➡️) then
		sfx(20)
	end
	
end

function update_story()
	if btnp(❘) then
		initpowcheck()
		fadeout()
	end
end

function update_powcheck()
	if btnp(➡️) then
		powi=powi%8+1
		sfx(20)
	elseif btnp(⬅️) then
		powi=(powi+6)%8+1
		sfx(20)
	end
	
	if btnp(❘) then
		initrndzer()
	end
end

function update_rndzer()
	t+=1
	if t>=45 and t<=300 then
		if btnp(❘) then t=300 end
	end
	if btnp(❘) and t>300 then
		initgame()
		dur=120
	end
end

function update_game()
	cx=bx+(curx*bw)
	cy=by+(cury*bh)

	--gameplay	
	t+=1
	
	if btnp(🅾️) then
		initinfo()
		dur=0
	end
	
	if not game.over then
		if game.mode=="comp" and self==p2 then
			aicheck()
			ai_tick+=1
			if self.pow!=8 then
				addbubble("••",#aimoves)
			end
			if self.pow==5 or self.pow==8 then
				if ai_tick>=70 then
					doai()
				end
			else
				if ai_tick>=#aimoves*10 then
					doai()
				end
			end
		else
			move_cursor()
			if btnp(❘) then
				update_tile()
			end
		end
	end

	if not game.over then tbuffer=t+120 end
	
	update_round()
		
	dofloat()
	doray()
	doparts()
	dobubble()
	dopop()
	
	--music swap
	if game.round>=4 and stat(24)==6 and stat(21)==31 then
		music(-1,900)
		music(7,900)
	elseif game.round>=7 and stat(24)==10 and stat(21)==31 then
		music(-1,900)
		music(11,900)
	end

end

function update_info()
	if btnp(🅾️) then
		initgame()
		dur=120
	end
end

function update_round()
	local diff=abs(p1.score-p2.score)

	if t==tbuffer then
		game.round+=1
		if game.round==11 and diff<=5 then
			initexround()
		else
		tbuffer=0
		game.over=false
		powuse=false
		initrndzer()
		end
	end
	
	if (game.round<11 and game.round==totalround+1) or
				(game.round==11 and diff>5) 
				or game.round>12 then
		initend()
	end
end

function update_exround()

	if btnp(➡️) then
		exscore=(exscore+1)%6
	elseif btnp(⬅️) then
		exscore=(exscore-1)%6
	end
	
	if btnp(❘) then
		if exscore==0 then
			update_round()
			initend()
		elseif exscore>0 then
			update_round()
			p1.score-=exscore
		end
	end

end

function update_ending()
	t+=1
	if btnp(❘) then
		if bg==1 then
		fadeout(true)
		else fadeout() end
		_init()
	end
end

function move_cursor()
	local _nx,_ny=curx,cury
	if btnp(➡️) then	
		_nx=min(_nx+1,2) 
	end
	if btnp(⬅️) then
		_nx=max(_nx-1,0) 
	end
	if btnp(⬇️) then	
		_ny=min(_ny+1,2) 
 end
	if btnp(⬆️) then	
		_ny=max(_ny-1,0) 
 end
 if _nx!=curx or _ny!=cury then
 	curx,cury=_nx,_ny
 end
end

function update_tile()
	local _curboard=board[curx+1][cury+1]
	if _curboard==0 or canstomp(curx+1,cury+1) then
		
		--update tile and track
		tile_age()
		track_history()
		pow[game.turn.pow]()
		aicheck()
		sfx(self.sfxn)

		--update round and score
		check_win()
	 update_score()
		
		if #winline!=0 then
			game.over=true
		elseif check_tie() then
			game.over=true
			pow_peace()
		end
		
		if self.gamba==0 and not game.over then
			toggleturn()
			check_gamba(self)
			dur=60
		end
		
		--update particles
		initparts()
		ai_tick=0
			
	else
		sfx(self.sfxn+2)
	end
end

function tile_age()
	for tile in all(history) do
		if enemy.pow==5 and	tile.tindex==self.tindex then
			tile.age-=1
		end
		if self.pow==6 and tile.tindex==enemy.tindex then
			tile.age=2
		end
	end
end

function canstomp(x,y)
	for tile in all(history) do
		if self.pow==6 and
					self.stomp==1 and
					curx==tile.x and
				 cury==tile.y and
				 tile.tindex==enemy.tindex and 
				 tile.stomp==true then
			return tile
		end
	end
	return false
end

function track_history()
	add(history,{
		tindex=self.tindex,
		x=curx,
		y=cury,
		age=3,
		stomp=false,
		stomped=false
	})
	
	for tile in all(history) do
		local _curx=tile.x+1
		local _cury=tile.y+1
		board[_curx][_cury]=tile.tindex
		
		if tile.age==2 then
			tile.stomp=true
		end
		
		if canstomp(_curx,_cury)==tile then
			board[_curx][_cury]=self.tindex
			tile.tindex=self.tindex
			tile.stomped=true
			self.stomp-=1
		end
		
		--if enemy.pow=5 aging till 0 then available
		if tile.age==0 then
			board[_curx][_cury]=0
			tile.tindex=0
		end
		
		--if enemy.pow=5 then -score once tile aged
		if enemy.pow==5 and tile.age==0 then
			enemy.score-=score.pow5
			addfloat(score.pow5,tile.x,tile.y,enemy.c,1)
			tile.age=-1
		end
	
	for i=1,#history do
		if history[i].stomp and history[i].stomped then
			history[i].tindex=0
		end
	end
	
	end	
end

function toggleturn()
	game.turn = game.turn == p1 and p2 or p1
end

function check_win()
 -- columns

 for i=1,3 do
  if board[i][1] != 0 and
     board[i][1] == board[i][2] and
     board[i][2] == board[i][3] then
			add(winline,i)
  end
 end

 -- rows
 for j=1,3 do
  if board[1][j] != 0 and
     board[1][j] == board[2][j] and
     board[2][j] == board[3][j] then
			add(winline,j+3)
  end
 end

 -- diagonals tl-br
 if board[1][1] != 0 and
    board[1][1] == board[2][2] and
    board[2][2] == board[3][3] then
			add(winline,7)
 end

 -- diagonals tr-bl
 if board[1][3] != 0 and
    board[1][3] == board[2][2] and
    board[2][2] == board[3][1] then
			add(winline,8)
 end	
 
	game.winner=self
end

function check_tie()
	for x=1,3 do
		for y=1,3 do	
			if board[x][y]==0 then
				return false
			end
		end
	end
	if #winline==0 then
		return true
	end
end
-->8
--draw--

function draw_menu()
	cls()
	poke(0x5f54,0)
	draw_bg()

	if game.state=="scrn" then
		sspr(0,52,12,12,45,43)
		sspr(12,52,10,12,58,43)
		sspr(22,52,12,12,71,43)
		pal(12,7)
		sspr(0,52,12,12,45,57)
		sspr(34,52,11,12,58,57)
		sspr(22,52,12,12,71,57)
		pal(12,14)
		sspr(0,52,12,12,45,71)
		sspr(46,52,11,12,58,71)
		sspr(58,52,11,12,71,71)
		reset_pal()
	end
	
	if game.state=="slct" then
		
		if s==0 then
			cprint("VERSUS",64,42,12)
			cprint("COMPUTER",64,48,12)
			spr(64,46,64,2,2)
			sspr(64,16,12,14,66,66)
		elseif s==1 then
			if powunlock==8 then
				cprint("OFFLINE",64,42,12)
				cprint("2 PLAYER",64,48,12)
				spr(64,46,64,2,2)
				spr(68,64,64,2,2)
			else
				cprint("OFFLINE 2P",64,44,12)
				local txt=split("UNLOCK|ONCE|YOU GET|ALL 8|ABILITIES","|",false)
				for i=1,#txt do
					cprint(txt[i],64,46+i*6,7)
				end				
			end
		elseif s==2 then
			if secr==0 then
				local txt=split("TRUE ENDING?|THESE|DO NOT|MATTER","|",false)
				for i=1,#txt do
					cprint(txt[i],64,34+i*6,7)
				end
				cprint("games won:"..countwin,64,72,12)
				cprint("games lost:"..countlose,64,80,14)
			elseif secr==1 then
				if bg==1 then
					palt(0,nil)
					spr(128,47,44,4,4)	
				else
					spr(132,47,44,4,4)	
				end
				reset_pal()
			cprint("CHANGE?",64,80,7)
			end
		elseif s==3 then
			cprint("credit",64,52,7)
			cprint("game by",64,66,12)
			cprint("bios",64,72,12)
		end
		print("⬅️",38,60+f,7)
		print("➡️",82,60+f,7)
	
		if btn(⬅️) then
			print("⬅️",38,60+f,13)
		elseif btn(➡️) then
			print("➡️",82,60+f,13)
		end
	end
	
	if btn(❘) or btn(⬅️) or btn(➡️) then
		glitch(40)
	end
		
	glitch(0.5)
	cprint("press ❘ to continue",64,112+f,14)

end
	
function draw_story()
	cls(5)
	local story="HUMAN AND ALIENS HAVE BEEN|FIGHTING FOR CENTURIES.||WE COULD HAVE BLOWN THEM UP.|INSTEAD, THEY CHOSE SOMETHING|MORE CIVILISED.|||||wHY? nOBODY REMEMBERS WHY.||THE ONLY THING YOU|REMEMBERED TILL TODAY IS...|EVERY LINES +5 PTS, MASTER|ALL 8 ABILITIES TO UNLOCK|THE TRUE ENDING..."	
	local story2="HUMAN AND ALIENS HAVE|COEXIST FOR A YEAR.||THEY COULD HAVE BLOWN US UP.|INSTEAD, THEY USE OUR|GENES TO CREATE BABY|WITH BIG FOREHEARD||wHY? nOBODY KNOWS WHY.||THE ONLY THING YOU|REMEMBERED TODAY IS...|YOU CAN STOP PLAYING"
	local line1=split(story,"|",false)
	local line2=split(story2,"|",false)
	
	if secr==1 then
		for i=1,#line2 do
			cprint(line2[i],64,i*6,6)
			draw_ttt(90)
		end
	else
		for i=1,#line1 do
			cprint(line1[i],64,i*6,6)
			draw_ttt(48)
		end
		print("EVERY LINES +5 PTS, MASTER",12,90,11)
		print("ALL 8 ABILITIES",14,96,11)
	end
	
	cprint("press ❘ to continue",64,112+f,10)

end

function draw_ttt(y)--★
	sspr(0,52,12,12,8,y)
	sspr(12,52,10,12,20,y)
	sspr(22,52,12,12,31,y)
	pal(12,7)
	sspr(0,52,12,12,45,y)
	sspr(34,52,11,12,58,y)
	sspr(22,52,12,12,71,y)
	pal(12,14)
	sspr(0,52,12,12,84,y)
	sspr(46,52,11,12,97,y)
	sspr(58,52,11,12,109,y)
	reset_pal()
end

function draw_bg()
	if bg==1 then
		print(scr,0,0)
		rrectfill(36,38,55,51,2,13)
	else
			--sky
		rectfill(-1,0,128,128,15) --32px
		rectfill(-1,32,128,128,2) --24px
		rectfill(-1,56,128,128,4) --16px
		rectfill(-1,72,128,128,9)	--16px
		map() --buildings
		
		--floor
		--right half
		for i=0,40 do
			tline(63,88+i,128,88+i,
									0,16+(i/4),
									1/(8+i/3),0)
		end
		--left half
		for i=0,40 do
			tline(64,88+i,0,88+i,
									0,16+(i/4),
									1/(8+i/3),0)
		end
		
		--monitor
		palt(0,false)
		rrectfill(41,93,44,5,3,13)
		rrect(41,93,44,5,3,0)
		rrectfill(32,32,63,63,3,13)
		rrect(32,32,63,63,3,0)
		rrectfill(36,36,55,55,2,0)
		palt()
		
		--signboard
		sspr(72,43,21,21,40,10)
		if f-1==0 then pal(8,14) pal(14,8) end
		sspr(94,32,24,15,65,15)
		reset_pal()
		rectfill(49,31,51,31,9)
		rectfill(70,30,72,31)
		rectfill(81,30,83,31)
	end
end

function draw_board()
	local _bx,_by
	for x=0,2 do
		for y=0,2 do
			_bx=bx+(x*bw)
			_by=by+(y*bh)
			rrectfill(_bx,_by,17,17,1,5)
		end
	end
end

function draw_powcheck()
	cls()
	fillp(0b101101101011111)
	rectfill(0,0,128,128,0x51)
	fillp(0b111111111011111)
	rectfill(3,3,123,123,0x51)		
	fillp()
	rectfill(8,8,119,119,5)

	local desc1=split(powname[powi][2],",",false)
	local desc2=split(powname[min(8,powunlock+1)][3],",",false)
	local ms=powspr[powi]
	
	if powi<=powunlock then
		for i=1,#desc1 do	cprint(desc1[i],64,42+i*6,6) end
		cprint(powname[powi][1],64,18,11)
		cprint("unlocked",64,96,11)
		sspr(ms[1],ms[2],ms[3],ms[4],60+ms[7],32+ms[8]+f)
		if powi>3 and powi==powunlock and secr==0 then
			print("new!",100,18,10)
		end
	else
		for c=7,12 do pal(c,0) end
		if powi==powunlock+1 do
			for i=1,#desc2 do cprint(desc2[i],64,54+i*6,2) end
		else
			cprint("???",64,58,2)
		end
		sspr(ms[1],ms[2],ms[3],ms[4],60+ms[7],32+ms[8]+f)
		cprint("???",64,18,2)
		cprint("locked",64,96,2)
		reset_pal()
	end
	
	print("⬅️",4,60+f,6)
	print("➡️",116,60+f,6)
	cprint("press ❘ to continue",64,112+f,10)
	
	if btn(⬅️) then
		print("⬅️",4,60+f,13)
		glitch(20)
	elseif btn(➡️) then
	print("➡️",116,60+f,13)	
		glitch(20)
	end
	
	if powi>powunlock then
		fullglitch()
	end
end

function draw_rndzer()
	slidein(2)
			
	--randomizer done, show pow
	if t>300 then
		if game.turn==p1 then
			p1_powblink()
			print("START\nFIRST",30,88,7)
		else
			p2_powblink()
			print("START\nFIRST",78,88,7)
		end
	end
	
	if t>=30	then
		local dt=17-(t*15/600)
		local blink=flr(t/60*dt)%2

		--randomizer blink effect
		if t>=45 and t<=300 then
			if blink==0 then
				p1_powblink()
				sfx(21)
			end
			if blink==1 then
				p2_powblink()
				sfx(22)
			end
		end
		cprint("player 1",32,16,7)
		cprint("player 2",96,16,7)
		draw_player()
		if t>=45 and t<=300 then
			draw_powspr(1+(flr(t/60*dt)%8),p1)
			draw_powspr(1+(flr(t/60*dt)%7),p2)
		end
	end

		--center print pow info
	if t>300 then
		drawpowinfo()
		cprint("press ❘ to start",64,112+f,game.turn.c)
	elseif game.round>1 and t>30 then
		cprint("press ❘ to skip",64,112+f,10)		
	end
end

function draw_game()
	draw_bg()
	draw_board()
	draw_tile()
	draw_cursor()
	slideout(3)
	draw_ray()
	draw_player()
	draw_parts()
	draw_powparts()
	draw_pop()
	draw_powuse(self.pow,self,10)
	if (enemy.pow==4 and check_tie()) then
		draw_powuse(enemy.pow,enemy,10)
	end
	draw_powspr(p1.pow,p1)
	draw_powspr(p2.pow,p2)
	draw_bubble()
	draw_winline()
	draw_draw()
	draw_score()
	draw_round()
	print("🅾️ INFO",3,120,14)
	draw_float()
	
	--add ray particles
	if flr(t%60)==0 then
		for i=1,5 do
			addparts(self.px+rnd(12),-2,(rnd()-0.5)/4,rnd()+2,rnd(3),120,self.cdark)
		end
	end
	
	if self.pow==8 and dur<0 and not game.over then
		addbubble(tostr(self.gamba),5)
	end

end

function draw_exround()
	draw_bg()
	draw_player()
	draw_bubble()
	draw_score()
	draw_round()
	
	cprint("SACRIFICE",64,44,14)
	print("\^w\^t"..exscore,61,52,7)
	print("⬅️",38,52+f,7)
	print("➡️",82,52+f,7)
	cprint("POINTS FOR",64,64,14)
	cprint("1 MORE",64,70,14)
	cprint("ROUND?",64,76,14)
	
	if btn(❘) or btn(⬅️) or btn(➡️) then
		glitch(40)
	end
	
	fullglitch()
end

function draw_player()
	spr(p1.pspr[f],p1.px,p1.py,2,2)
	spr(p2.pspr[f],p2.px,p2.py,2,2)
end

function draw_tile()
	local _tx,_ty

	for tile in all(history) do
		_tx=bx+(tile.x)*bw
		_ty=by+(tile.y)*bh
				
		if tile.tindex==p1.tindex then
			pal(3,12)
			spr(p1.tspr[1],_tx+1,_ty+1,2,2)
			reset_pal()
		elseif tile.tindex==p2.tindex then
			pal(2,14)
			spr(p2.tspr[1],_tx+1,_ty+1,2,2)
			reset_pal()
		end
		
		if tile.age==1 and tile.tindex==p1.tindex then
			spr(p1.tspr[f],_tx+1,_ty+1,2,2)
		elseif tile.age==1 and tile.tindex==p2.tindex then
			spr(p2.tspr[f],_tx+1,_ty+1,2,2)
		end
	end
end

function draw_cursor()
	if #winline==0 then
		spr(game.turn.tspr[1],cx+1,cy+1,2,2)
	end
end

function draw_score()
	print("\^w\^t\^o7ff"..p1.score,2,2,p1.c)
	local	_p2length =	print("\^t\^w"..p2.score,2,129)
	print("\^w\^t\^o7ff"..p2.score,130-_p2length,2,p2.c)
end

function draw_winline()
	local lne=(t-tbuffer+120)*3
	local anic=flr(t/10)%2==0 and 7 or 10
	for i,v in ipairs(winline) do
		for v=1,3 do
		
			--winline for cols
			for i=1,3 do
				local _x=bx+6+18*(i-1)
				if winline[v]==i then
					rrectfill(_x,by+1,5,min(1+lne,51),2,anic)
					rrectfill(_x+1,by+2,3,min(1+lne,49),1,game.winner.c)
				end
			end
		
			--winline for rows
			for i=4,6 do
				local _y=by+1+18*(i-4)
				if winline[v]==i then
					rrectfill(bx+1,_y+5,min(5+lne,51),5,2,anic)
					rrectfill(bx+2,_y+6,min(3+lne,49),3,1,game.winner.c)
				end
			end
			
			if winline[v]==7 then
				local _bx1=bx+3--40
				local _by1=by+3--40
				local _bx2=min(bx+lne,86)
				local _by2=min(bx+lne,86)
				local _c=game.winner.c
				local _tbl={--★
				{2,0,0,-2,anic},
				{0,2,-2,0,anic},
				{1,0,0,-1,anic},
				{0,1,-1,0,anic},
				{1,1,-1,-1,_c},
				{2,1,-1,-2,_c},
				{1,2,-2,-1,_c},
				}
				for l in all(_tbl) do
					line(_bx1+l[1],_by1+l[2],_bx2+l[3],_by2+l[4],l[5])
				end
			end
			
			if winline[v]==8 then
				local _bx1=bx+49
				local _by1=by+3
				local _bx2=max(_bx1-lne,40)
				local _by2=min(_by1+lne,86)
				local _c=game.winner.c
				local _tbl={--★
				{-1,-1,-1,-1,anic},
				{1,1,1,1,anic},
				{0,-1,-1,0,anic},
				{1,0,0,1,anic},
				{0,0,0,0,_c},
				{0,1,1,0,_c},
				{-1,0,0,-1,_c},
				}
				for l in all(_tbl) do
					line(_bx1+l[1],_by1+l[2],_bx2+l[3],_by2+l[4],l[5])
				end
			end
			
		end
	end
end

function draw_draw()
	local txt1="\^w\^t\^o7ffdraw"
	local txt2="\^w\^t\^oaffdraw"
	local _text=t\20%2==0 and txt1 or txt2

	if check_tie() then
		print(_text,49,58,self.c)
	end
end

function draw_round()
	if game.round>=11 then
		cprint("round ??/??",64,2,7)		
	else
		cprint("round "..game.round.."/"..totalround,64,2,7)
	end
end

function draw_ending()
	
	local _p1ending="AS THE HERO RETURNS HOME,\nTHE ALIENS HAVE CONVENED\nON THEIR NEXT GAME.\n\n\"SHALL WE PLAY GLOBAL\nTHERMONUCLEAR WAR INSTEAD?\"\n\n       THE NEXT BUTTON WAS\n       DIFFERENT. IT WAS A\n       NUKE BY ALIENS...\n\n       mAYBE... THE ONLY\n       WINNING MOVE IS..."
	local _p2ending="ALIENS WERE NOT IMPRESSED.\nTHEY HAVE SEEN THIS\nSCENARIO 14,000,000 TIMES.\n\nTHIS IS PERFECTLY BALANCED\nFOR ALIENS. HOWEVER, HUMANS\nARE APPROACHING THE ENDGAME.\n\n\"i GUESS WE SHOULD\nRESET THE RUN...\"\n\n(GUNSHOT ECHOES IN\nTHE DISTANCE)"
	local drawending=split("THE ALIENS WERE VISIBLY|CONFUSED BY THE OUTCOME.||YOU ARE NOT SUPPOSED|TO BE HERE. YOUR|VISION STARTS TO|GET BLURRY.||MAYBE IF YOU UNLOCK|MORE ABILITIES, YOU WILL|KNOW WHAT TO DO...","|",false)
	local drawending2=split("THE ALIENS WERE VISIBLY|IRRITATED BY THE OUTCOME.||YOU OUTPLAYED THE ALIENS.|THEY ARE KIDNAPPING YOU TO|CONDUCT GENETIC EXPERIMENT.||WELL, AT LEAST ALIENS ARE|NOT POPPING OUT OF HUMANS|STOMACH...RIGHT?","|",false)
	local rad=max(124-t*3,12)

	draw_bg()
	draw_board()
	draw_tile()
	draw_winline()
	draw_draw()
	draw_player()

	if p1.score>p2.score then
		circfill(15,92,rad,5+6144)
		if rad==12 then
			print("\^w\^tyou win",36,6,12)
			cprint("BUT AT WHAT COST",64,18,12)
			print(_p1ending,10,30,7)
			cprint("press ❘ to restart",64,116+f,12)
		end
	elseif p2.score>p1.score then
		circfill(112,92,rad,4+6144)
		if rad==12 then
			print("\^w\^tyou lost",32,6,14)
			cprint("AS EXPECTED",64,18,14)
			print(_p2ending,10,30,7)
			cprint("press ❘ to restart",64,116+f,14)
		end
	end
	
	if p1.score==p2.score and powunlock<8 then
		cls()
		print("\^w\^tyou draw",32,6,7)
		for i=1,#drawending do
			cprint(drawending[i],64,29+i*6,6)
		end	
		cprint("BUT YOU LACK THE POWER",64,18,7)
		cprint("press ❘ to restart",64,116+f,0)
		fullglitch()
	end
	
	
	--update secret
	if p1.score==p2.score and secr==1 then
		cls(7)
		for i=1,#drawending2 do
			cprint(drawending2[i],64,29+i*6,13)
		end
		print("\^w\^tyou draw",32,6,13)
		cprint("YOU SOLVED THE GAME",64,18,13)
		cprint("press ❘ to restart",64,116+f,0)
	end
	draw_score()

end
-->8
--powers--

function checkpowunlock()
	local diff=abs(p1.score-p2.score)
	local check=p1.score-p2.score
	
	if powunlock==3 and check>0 then
		powunlock=4
	elseif powunlock==4 and check<0 then
		powunlock=5
	elseif powunlock==5 and check>0 and diff<=10 then
		powunlock=6
	elseif powunlock==6 and check<0 and diff<=10 then
		powunlock=7
	elseif powunlock==7 and check>0 and diff<=5 then
		powunlock=8
	end
	dset(3,powunlock)
end

function update_score()
	if #winline!=0 then
		self.score+=score.win*#winline
		addfloat(score.win*#winline,curx,cury,self.c)
	end
end

function pow_king()
	if self.pow==1 and
				cury+1==2 and curx+1==2 and
				board[2][2]==self.tindex then
		self.score+=score.pow1
		addfloat(score.pow1,curx,cury,self.c)
	end
end

function pow_cross()
	local _x=curx+1
	local _y=cury+1
	if self.pow==2 and
		 	(_x==1 or _x==3) and 
			 (_y==1 or _y==3) and
				board[_x][_y]==self.tindex then
		self.score+=score.pow2
		addfloat(score.pow2,curx,cury,self.c)
	end
end

function pow_side()
	local _x=curx+1
	local _y=cury+1
	if self.pow==3 and
				(_y==2 and (_x==1 or _x==3)) or
				(_x==2 and (_y==1 or _y==3)) and
				board[_x][_y]==self.tindex then
		self.score+=score.pow3
		addfloat(score.pow3,curx,cury,self.c)
	end
end

function pow_peace()
	if check_tie() and game.over then
		if p1.pow==4 then
			p1.score+=score.pow4
			addfloat(score.pow4,-2,2,p1.c)
		end
		if p2.pow==4 then
			p2.score+=score.pow4
			addfloat(score.pow4,3,2,p2.c)
		end
	end
end

function pow_potion()
	--check tileage func
end

function pow_stomp()
--check canstomp and history
end

function pow_rabbit()
	if #history==0 then
		if p1.pow==7 then game.turn=p1 end
		if p2.pow==7 then game.turn=p2 end
	 if p1.pow==7 and p2.pow==7 then
			if	rnd()<0.5 then	game.turn=p1 else game.turn=p2 return end
		end
	end
end

function pow_gamble()
	if self.gamba>0 then 
		self.gamba-=1
	end
end

function check_gamba(p)
	if game.over then p.gamba=0 return end

	if p.pow==8 then
		p.gamba=(rnd()<0.8) and 1 or 2	
	end
end

function draw_info()
	slidein(3)
	draw_player()
	draw_score()
	drawpowinfo()
	if dur>=60 then
		cprint("player 1",32,16,7)
		cprint("player 2",96,16,7)
	end
	cprint("press 🅾️ to exit",64,112,game.turn.c)
end

function drawpowinfo()
	local desc1=split(powname[p1.pow][2],",",false)
	local desc2=split(powname[p2.pow][2],",",false)
	if dur>=60 then
		for i=1,#desc1 do
			cprint(desc1[i],32,30+i*6,p1.c)
		end
		for i=1,#desc2 do
			cprint(desc2[i],96,30+i*6,p2.c)
		end
		cprint(powname[p1.pow][1],32,24,p1.c)
		cprint(powname[p2.pow][1],97,24,p2.c)
	end
	draw_powspr(p1.pow,p1)
	draw_powspr(p2.pow,p2)
end

function draw_powspr(powi,player)
	local ms=powspr[powi]
	sspr(ms[1],ms[2],ms[3],ms[4],player.px+ms[5],player.py+ms[6]+f)
	if powi==4 then
		if player==p1 then 
			line(11,84,11,93+f,8)
		else
			line(108,84,108,93+f,8)
		end
	end
	
	if player.stomp<1 then
		sspr(98,16,6,8,player.px+10,player.py+4+f)
	end
	
	if self.pow==8 and dur<=30 and dur>=-90 then
		sspr(112,25,7,7,self.px+4,self.py+7+f)
	end
	
	if self.pow==8 and dur==30 then
		addpop(16)
		for i=0,2 do
			addparts(self.px+6,self.py+7,-0.2+i*0.2,-6,1,30,10)
		end
	end
end

function draw_powuse(powi,player,col)
	for c=1,15 do pal(c,col) end
	local _tabx={1,0,-1,0}
	local _taby={0,1,0,-1}
	local powuse={}
	local ms=powspr[powi]
	local _x,_y=curx+1,cury+1
	
	--conditions for all pow
	if player.pow==1 and
	 _x==2 and _y==2 then
	 add(powuse,player)
	end
	
	if player.pow==2 and
 	(_x==1 or _x==3) and 
	 (_y==1 or _y==3) then
	 add(powuse,player)
	end
	
	if player.pow==3 and
		((_y==2 and (_x==1 or _x==3)) or
		(_x==2 and (_y==1 or _y==3))) then
	 add(powuse,player)
	end
	
	if canstomp() then
		add(powuse,player)			
	end

	if player.pow==4 and check_tie() then
	 add(powuse,player)
	end
	
	if player.pow==5 and #history>6 then
		add(powuse,player)
	end

	if player.pow==7 and #history==0 then
		add(powuse,player)
	end
	
	if player.pow==8 and player.gamba==2 then
		add(powuse,player)
	end

	for p in all(powuse) do
		--draw outlines
		for i=1,4 do
			pal(8,10)
			sspr(ms[1],ms[2],ms[3],ms[4],p.px+ms[5]+_tabx[i],p.py+ms[6]+_taby[i]+f)
			if p.pow==4 and p==p1 then
				line(11+_tabx[i],84+_taby[i],11+_tabx[i],93+_taby[i]+f,8)
			elseif p.pow==4 and p==p2 then
				line(108+_tabx[i],84+_taby[i],108+_tabx[i],93+_taby[i]+f,8)
			end
		end
		
		--add parts
		if flr(t%30)==0 then
			addpowparts(p.px+8+rnd(12),100-rnd(10),0,-2,0,90,10)
			addpowparts(p.px+8-rnd(12),100-rnd(10),0,-2,0,90,10)
		end
		reset_pal()
		glitch(0.2)
	end

	--ani parts
	for pow in all(powparts) do
		pow.x+=pow.sx
		pow.y+=pow.sy/15
		pow.life-=2
		if pow.life<=0 or dur>=20 then
			del(powparts,pow)
		end
	end

	reset_pal()
end
-->8
--particles and ui--

function addfloat(_t,_curx,_cury,_c,_minus)
	add(float,{
		txt=_t,
		x=bx+(_curx*bw)+16,
		y=by+(_cury*bw),
		c=_c,
		ty=by+(_cury*bw)-10,
		t=0,
		minus=_minus==1 and "-" or "+"
	})
end

function dofloat()
	for f in all(float) do
		f.y+=(f.ty-f.y)/10
		f.t+=1
		if f.t>70 then
			del(float,f)
		end
	end
end

function draw_float()
	for f in all(float) do
		print("\^o7ff"..f.minus..f.txt,f.x,f.y,f.c)
	end
end

function addray()
	add(ray,{
		p=game.turn,
		x=0,
		y=-2,
		w=0,
		h=0,
		t=0
	})
end

function doray()
	--ray
	for r in all(ray) do
		local _rt=r.t
		if _rt<8 then
		 r.t+=1
			r.x=r.p.px+8-_rt
		 r.w=_rt*2
		 r.h=flr(r.t)*13
		elseif _rt>=8 then
			r.t=8
			r.x=r.p.px+1
			r.w=13
		end
		
		if r.p==enemy then r.t-=1.5 end
--		if _rt>6 and _rt<7 then
--			for i=1,10 do
--				addparts(self.px+rnd(12),self.py+12,(rnd()-0.5)/2,-6,rnd(3),90,self.cdark)
--			end
--			shake=1
--	 end
		if r.t==0 then	deli(ray,1) end
	end
end

function draw_ray()
	for r in all(ray) do
		local _rx=r.x
		local _ry=r.y
		local _rw=r.w
		local _rh=r.h
	 local _rp=r.p
	
		rrectfill(_rx,_ry,_rw,_rh,1,_rp.cdark)
--		fillp(0b1010101001010101+0b.1)
		rrectfill(_rx+3-f,_ry,_rw-6+f*2,_rh,1,_rp.cmed)
--		fillp()
		line(_rp.px-1,0,_rp.px-1,_rh-5,_rp.c)
		line(_rp.px+15,0,_rp.px+15,_rh-5,_rp.c)
		
		if _rh>90 then
			ovalfill(_rx-2-f,_rh-3,_rx+1+_rw+f,_rh-6,_rp.cdark)
		end
	end
end

function addparts(_x,_y,_sx,_sy,_r,_life,_c)
	add(parts,{
		x=_x,
		y=_y,
		sx=_sx,
		sy=_sy,
		r=_r,
		life=_life,
		c=_c
	})
end

function doparts()
	--ray particles
	for p in all(parts) do
		p.x+=p.sx
		p.y+=p.sy/15
		p.life-=rnd()*2

		if p.y>=8 and p.y<=30 then
			p.r=1
			p.c=self.c
		end
		
		if p.life<=0 or game.turn==enemy then
			del(parts,p)
		end
		
	end
end

function draw_parts()	
	for p in all(parts) do
		circfill(p.x,p.y,p.r,p.c)
	end
end

function addpowparts(_x,_y,_sx,_sy,_r,_life,_c)
	add(powparts,{
		x=_x,
		y=_y,
		sx=_sx,
		sy=_sy,
		r=_r,
		life=_life,
		c=_c
	})
end

function dopowparts()
	for p in all(powparts) do
		p.x+=p.sx
		p.y+=p.sy/15
		p.life-=rnd()*2

		if p.life<=0 then
			del(powparts,p)
		end
	end
end

function draw_powparts()
	for p in all(powparts) do
		line(p.x,p.y,p.x+p.sx,p.y+p.sy,p.c)
	end
end

function addbubble(_t,_life)
	add(bubble,{
		txt=_t,
		x=self.px,
		y=self.py-16,
		c=self.c,
		life=_life
	})
end

function dobubble()
	for b in all(bubble) do
		b.life-=1
		if b.life<=0 then
			del(bubble,b)
		end
	end
end

function draw_bubble()
	for b in all(bubble) do
		if b.c==14 then	pal(12,14) end
		spr(42,b.x,b.y,2,2)
		cprint(b.txt,b.x+8,b.y+3,b.c)
		reset_pal()
	end
end

function addpop(_life)
	add(pop,{
		x=self.px+7,
		y=self.py+10,
		r=16,
		life=_life,
		c=10
	})
end

function dopop()
	for c in all(pop) do
		c.life-=1
		if c.life<=0 then
			del(pop,c)
		end
	end
end

function draw_pop()
	for c in all(pop) do
		circ(c.x,c.y,c.r-c.life,c.c)
		fillp(0b1111101111111111+0b.1)
		circfill(c.x,c.y,c.r-c.life,7)
		fillp()
	end
end

function p1_powblink()
	fillp(0b101101101011111)
	rectfill(0,0,63,128,0x13)
	fillp(0b111111111011111)
	rectfill(3,3,59,123,0x13)		
	fillp()
	rectfill(8,8,55,119,1)
end

function p2_powblink()
	fillp(0b101101101011111)
	rectfill(64,0,128,128,0x42)
	fillp(0b111111111011111)
	rectfill(68,3,123,123,0x42)		
	fillp()
	rectfill(72,8,119,119,4)
end

function slidein(_dur)
	dur+=_dur
	rectfill(0,0,min(0+dur,63),128,1)
	rectfill(max(64,128-dur),0,128,128,4)
	if dur>=60 and dur<=64 then shake=2 end
end

function slideout(_dur)
	dur-=_dur
	rectfill(-1,0,max(dur-64,-1),128,1)
	rectfill(min(184-dur,128),0,128,128,4)
end

function glitch(g)
	poke(0x5f54,0x60)
	local f,g=t%flr(rnd(120/g)),g
	if f==0 then
		for i=0,10+g do
			sspr(40,38+rnd(50),49,rnd(5),38,40+rnd(50),51,1)
		end
	end
	poke(0x5f54,0)
end

function fullglitch()--by lazydevs
	poke(0x5f54,0x60)
	sspr(0,0,128,128,0,0)
		for i=0,1 do
			sspr(0,rnd(128),128,rnd(2),0,rnd(128),128,1)
		end
	poke(0x5f54,0)
end

-->8
--ai--

function doai()	
	local totalscore,bestmove=0,0
	
	for m in all(aimoves) do
		totalscore+=m.score
		if rnd(totalscore)<m.score then
			bestmove=m
		end
	end
	
	curx=bestmove.x
	cury=bestmove.y
	update_tile()
end

function aicheck()
	 
	aimoves={}
	for x=1,#board do
		for y=1,#board do
			if board[x][y]==0 then
				add(aimoves,{
						x=x-1,
						y=y-1,
						score=ai_scores(x,y),
					})
			end
		end
	end
	
	if p2.pow==6 and p2.stomp==1 and #history>2 then
		for tile in all(history) do
			if tile.tindex==p1.tindex and tile.stomp then
				add(aimoves,{
						x=tile.x,
						y=tile.y,
						score=60,
					})
				end
		end
	end
	
end
	
function ai_scores(x,y)
	local score=0
	
	if #history<=1 and x==2 and y==2 then
		score+=5
	end
	--prioritise pow
	if p2.pow==1 or p2.pow==7 then
		if x==2 and y==2 then
			score+=59
		end
	end
		
	if p2.pow==2 then
		if (x==1 or x==3) and 
			 	(y==1 or y==3) then
			score+=15
		end
	end
	
	if p2.pow==3 then
		if (y==2 and (x==1 or x==3)) or
					(x==2 and (y==1 or y==3)) then
			score+=25
		end
	end
	
	score+=findtile(x,y,20)--find win
	score+=findtile(x,y,10)--find block
	score+=1
	
	return score
end

function findtile(x,y,target)
	local score=0
	
	for i=1,8 do --for each possible win
		local empty_pos=0
		local count_target=0 --if this reach 3 then possible win
		local count_empty=0

		for tile=1,3 do
			local pos=lines[i][tile]
			local index=board[pos[1]][pos[2]]

			if index==target then
    count_target+=1
			elseif index==0 then
    count_empty+=1
    empty_pos=pos
			end
		end

		if count_target==2 and count_empty==1 then
			if x==empty_pos[1] and y==empty_pos[2] then
				if target==10 then --if p1 is one away from win
		  	if p2.pow==4 then	--if p2 is draw then higher score
		  		score+=199
		  	else
		  		score+=99 -- block score
		  	end
		  else
	  		score+=199 -- win score
		  end
			end
		end
	end

	return score
end
-->8
--tools--

function draw_echo()--by nerdy teachers

end

function echo(val)
	add(echoes,tostr(val))
end

function print_echoes(x,y,c)
	local cx,cy,cc=cursor()
	cursor(x or cx,y or cy,c or cc)
	for i=1,#echoes do
		print(tostr(echoes[i]))
	end
	echoes={}
end

function reset_pal()
	pal()
	pal(custom_pal,1)
end

function cprint(t,x,y,c)
	print(t,x-#t*2,y,c)
end

function lerp(a,b,t)
	local result=a+t*(b-a)
	return ceil(result)
end

function doshake()
 local shakex=rnd(shake)-(shake/2)
 local shakey=0
 
 camera(shakex,shakey)
 
 shake-=0.3
 if shake<0 then
  shake=0
 end
end

function fade(typ)--by lazydevs
	local i=fadeperc*16
 for c=0,15 do
  if flr(i+1)>=16 then
   pal(c,17,1)
  else
  	if not typ then
   	pal(c,fadetabledark[c+1][flr(i+1)],1)
   else
   	pal(c,fadetablewhite[c+1][flr(i+1)],1)
 		end 	
  end
 end
end

function fadeout(typ,spd,_wait)--by lazydevs
	local spd,_wait=spd or 0.04,_wait or 0
	repeat
		fadeperc=min(fadeperc+spd,1)
		fade(typ)
		flip()
	until fadeperc==1
	wait(_wait)
end

function wait(_wait)
	repeat
		_wait-=1
		flip()
	until _wait<0
end

function split2d(s)--by lazydevs
	local arr=split(s,"|",false)
	for k,v in pairs(arr) do
		arr[k] = split(v)
	end
	return arr
end