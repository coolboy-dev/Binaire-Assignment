--kairu
--by sgchild9
marbmap={{0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0}}

tilemap={{0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0},
         {0,0,0,0,0,0,0,0,0,0}}

function _init()
 
 boardnum=1
	pagenum=1
	page_max=5
	ai=false
	difficulty=0

 lturn={x=-1,y=-1} --coord of last marble placed
 pturn={x=-1,y=-1} --cord of penultimate marble placed

 state="menu"
 player=1
 
 gridx=0  --pixel coord of where to start drawing marbles
 gridy=0  --pixel coord of where to start drawing marbles
 xy_x=0   -- start point for x/y line helper
 xy_y=0   -- start point for x/y line helper

	red =28  -- red marbles left
	blue=28  -- blue marbles left
	
	cx=4 --cursor pos, 0,0 is top left tile
	cy=4 --cursor pos, 0,0 is top left tile
	
	score={r=0,b=0} -- score of current game
	
	--animation and dialog initializations
	dialog = {active=false,
	          x=0, y=0,
	          l=0, h=0}
	
 selec = {active=false,
          loc=1, max=1,x=0,y=0,
          curx=0,cury=0, 
          deltax=0,deltay=0}

	pass_a = {active=false, tick=0,
											sec=3}
											
 end_a = {active=false, tick=0,
											phase=0,r=0,b=0,
											small=false}


 marb_a = {active=false, tick=0,
           x0=0,y0=0,x1=0,y1=0,
           dx=0,dy=0}

 think_a = {active=false, tick=0,
           text="",length=0}
	--state="end"
	--end_a.active=true
	--pass_a.active=true

end

function restart()
 lturn={x=-1,y=-1}
 pturn={x=-1,y=-1}
 state="p1"
 player=1
	red=28
	blue=28
	cx=4
	cy=4
	score={r=0,b=0}
 end_a =  {active=false, tick=0,
											phase=0,  r=0,b=0,
											small=false}
 zero_marbs()
 del_dialog()
end

function _update()

	if (state=="menu") then
 	set_selec(3,28,99,0,8)
	 if btnp(🅾️) then
	 	if(selec.loc==1) then
	 		ai=true
	 		sfx(2)
	 		stop_selec()
	 		state="layout"	 	
	 	elseif(selec.loc==2) then
	 		sfx(2)
	 		stop_selec()
	 		state="layout"
	 	else
	 		stop_selec()
	 		state="rules"	 		
	 	end
	 elseif btnp(⬆️) then
	  sfx(0)
	 	dec_selec()
	 elseif btnp(⬇️) then
	  sfx(0)
	 	inc_selec()
	 	elseif (btnp(⬅️) or btnp(➡️)) then
	 	 if (selec.loc==1) then
	 	  difficulty=(difficulty+1)%2
	    sfx(0)
	 	 end
	 end	

	elseif (state=="layout") then
 	set_selec(4,39,67,0,8)
	 if btnp(🅾️) then
	 	boardnum=selec.loc
	 	sfx(2)
 		stop_selec()
 		del_dialog()
 		state="p1"
	 elseif btnp(❘) then
 		stop_selec()
 		del_dialog()
 		state="menu"
  elseif btnp(⬆️) then
	  sfx(0)
	 	dec_selec()
	 elseif btnp(⬇️) then
	  sfx(0)
	 	inc_selec()
	 end	
	 
	elseif (state=="p1" or state=="p2") then

	 if (btnp(🅾️) and marb_a.active==false) then
	
   if (is_legal(p,cx,cy)) then
     marb_place(cx,cy)
   else
     sfx(1)
   end

  end

	 if btnp(⬅️) then
		 movecursor(0)
	 end

	 if btnp(➡️) then
		 movecursor(1)
	 end

	 if btnp(⬆️) then
		 movecursor(2)
	 end

	 if btnp(⬇️) then
		 movecursor(3)
	 end

	elseif (state=="ai") then
	
	 if (marb_a.active==false) then
	  local move = find_ai_move()
		 marb_place(move.x,move.y)
		end

	elseif (state=="end" and end_a.phase==5) then
	 if btnp(🅾️) then
	 	-- restart game
	 	restart()
	 end	
	 if btnp(❘) then
	  restart()
	  state="menu"
	 end	
	 if (btnp(⬇️) and end_a.small==false) then
	  end_a.small=true
	 end	
	 if (btnp(⬆️) and end_a.small) then
	  end_a.small=false
	 end	

	elseif (state=="rules") then
	 if btnp(❘) then
	 	state="menu"
	 	del_dialog()
	 	pagenum=1
	 elseif btnp(🅾️) then
	 	if (pagenum~=page_max) then
	 		pagenum+=1
	 	else
		 	state="menu"
		 	del_dialog()
		 	pagenum=1
	 	end
	 elseif btnp(⬅️) then
	 	if (pagenum~=1) then
	 		pagenum-=1
	 	end
	 elseif btnp(➡️) then
	 	if (pagenum~=page_max) then
	 		pagenum+=1
	 	end
		end	  

	end
	
	if (pass_a.active) then
		pass_tick()
	end
	if (end_a.active) then
		end_tick()
	end
	if (marb_a.active) then
		marb_tick()
	end
	if (think_a.active) then
		think_tick()
	end
	
end

function _draw()
	if (state=="menu") then
	 drawmenu(selec.active,1) 
	elseif (state=="p1" or state=="p2" or state=="pass" or state=="end" or state=="think" or state=="ai") then
		drawboard(boardnum)
		drawgui()
		drawmarbles()
		if (state=="p1" or state=="p2") then
		 drawcursor(state,cx,cy)
		end
				
	end

 if (dialog.active) then
 	draw_dialog()
 end
 if (state=="layout") then
 	drawlayout()
	elseif (state=="rules") then
		drawrules(pagenum)
 end
 
	drawthink()
	if (state=="pass") then
	 draw_pass(pass_a.sec)			
	end

	if (state=="end") then
	 draw_end(end_a.phase,end_a.r,end_a.b)			
	end
	
-- debug section 
--	score = get_score()
--	print(score.r)
--	print(score.b)
--	if (state=="pass") then
--	  print ("pass")
--	end
	
--	if (state=="end") then
--		print ("end")
--	end
-- set_dialog(2,4,10,2)
--	print("  no valid moves\n\nending game in 3 ...",25,39,7)
end

-- helpers

function get_tile(x,y)
 if (x==-1 or y==-1) then
  return -1
 end
	return tilemap[y+1][x+1]
end

function get_marb(x,y)
	return marbmap[y+1][x+1]
end

function set_marb(x,y,p)
	marbmap[y+1][x+1]=p
end

function set_selec(max,x,y,deltax,deltay)
	if (selec.active==false) then
		selec.max=max
		selec.loc=1
		selec.x=x
		selec.y=y
		selec.curx=x
		selec.cury=y
		selec.deltax=deltax
		selec.deltay=deltay
		selec.active=true
	end
end

function stop_selec()
	selec.loc=1
	selec.active=false
end

function inc_selec()
 selec.loc+=1
 if (selec.loc>selec.max) then
 	selec.loc=1
 end
 selec.curx=selec.x+((selec.loc-1)*selec.deltax)
 selec.cury=selec.y+((selec.loc-1)*selec.deltay)
end

function dec_selec()
 selec.loc-=1
 if (selec.loc<1) then
 	selec.loc=selec.max
 end
 selec.curx=selec.x+((selec.loc-1)*selec.deltax)
 selec.cury=selec.y+((selec.loc-1)*selec.deltay)
end

function draw_selec()
 if(selec.active) then
		spr(10,selec.curx,selec.cury)
	else
		rectfill(selec.curx,selec.cury,selec.curx+8,selec.cury+8,1)
	end
end

function zero_marbs()
	marbmap={{0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0}}
end

function zero_tiles()
	tilemap={{0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0},
	         {0,0,0,0,0,0,0,0,0,0}}
end
-->8
function drawmenu(curs_on)
	cls(1)
	myspr(67,0,10,27,32)
	myspr(70,27,10,27,32)
	myspr(71,54,10,27,32)
	myspr(72,77,10,27,32)
	myspr(73,104,10,27,32)
	
	myspr(1,42,60,16,16)
	myspr(1,59,60,16,16)
	myspr(1,42,77,16,16)
	myspr(1,59,77,16,16)
	myspr(2,42,60,16,16)
	myspr(2,59,77,16,16)
	myspr(3,59,60,16,16)
	myspr(3,42,77,16,16)
	
	print("a fan implementation of",18,42,7)
	print("the kulami board game",20,50,7)
	if (difficulty==0) then
	 print("1 player",40,100,7)
	 print("⬅️easy➡️",80,100,12)
	else
	 print("1 player",40,100,7)
	 print("⬅️hard➡️",80,100,8)
	end
	print("2 players",40,108,7)
	print("how to play",40,116,7)
	
	draw_selec()	
end

function drawlayout()
	local s=34
	local t=48
	local u=s+16
	local o =t+20
	set_dialog(3,5,8,7)
 print("select a layout",s,t,7)
 print("classic",u,o,7)
 print("layout a",u,o+8,7)
 print("layout b",u,o+16,7)
 print("layout c",u,o+24,7)
 
 draw_selec()
end

function drawboard(n)
		cls(1)

		if (n==1) then
		 camera(128,0)
  	gridx=32
  	gridy=8
  	xy_x=32
  	xy_y=8

			tilemap={
			{ 1, 1, 2, 3, 3, 3, 4, 4,0,0},
			{ 1, 1, 2, 6, 6, 7, 4, 4,0,0},
			{ 5, 5, 2, 6, 6, 7, 4, 4,0,0},
			{ 5, 5, 8, 8, 8, 9, 9, 9,0,0},
			{10,10, 8, 8, 8,11,11,12,0,0},
			{13,14,14,15,15,11,11,12,0,0},
			{13,14,14,16,16,16,17,17,0,0},
			{13,14,14,16,16,16,17,17,0,0},
			{ 0, 0, 0, 0, 0, 0, 0, 0,0,0},
			{ 0, 0, 0, 0, 0, 0, 0, 0,0,0}
			        }
	 	map()
	 	camera()
			xline(0,0,8) xline(3,1,3)
			xline(0,2,2)	xline(2,3,6)
			xline(0,4,2)	xline(5,4,3)
			xline(0,5,5)	xline(3,6,5)
			xline(0,8,8)	yline(0,0,8)
			yline(0,0,8)	yline(1,5,3)
			yline(2,0,5)	yline(3,0,3)
			yline(3,5,3)	yline(5,1,5)
			yline(6,0,3)	yline(6,6,2)
			yline(7,4,2)	yline(8,0,8)
  elseif (n==2) then
		 camera(0,0)
  	gridx=24
  	gridy=8
  	xy_x=32
  	xy_y=8
 	
			tilemap={
			{0, 0, 0, 1, 1, 2, 2, 0, 0,0},
			{0, 3, 3, 1, 1, 4, 4, 4, 0,0},
			{0, 3, 3, 5, 5, 6, 6, 7, 7,0},
			{8, 3, 3, 5, 5, 6, 6, 7, 7,0},
			{8, 9, 9, 9,10,10,10, 7, 7,0},
			{8, 9, 9, 9,11,11,11,12, 0,0}, 
			{0,13,13,13,11,11,11,12, 0,0},
			{0,14,14,15,15,16,16,17,17,0},
			{0, 0, 0,15,15,16,16, 0, 0,0},
			{0, 0, 0, 0, 0, 0, 0, 0 ,0,0}
			        }
		 map()
		 camera()
			xline(2,0,4)		xline(0,1,2)
			xline(4,1,3)		xline(2,2,6)
			xline(-1,3,1)	xline(0,4,6)
			xline(3,5,5)		xline(-1,6,4)
			xline(0,7,8)		xline(0,8,2)
			xline(6,8,2)		xline(2,9,4)
			yline(-1,3,3)	yline(0,1,7)
			yline(2,0,4)		yline(2,7,2)
			yline(3,4,3)		yline(4,0,4)
			yline(4,7,2)		yline(6,0,1)
			yline(6,2,7)		yline(7,1,1)
			yline(7,5,2)		yline(8,2,3)
			yline(8,7,1)
  elseif (n==3) then
		 camera(256,0)
  	gridx=24
  	gridy=0
  	xy_x=24
  	xy_y=16

			tilemap={
			{ 0, 0, 0, 0, 1, 1, 0, 0, 0, 0},
			{ 0, 0, 2, 2, 1, 1, 3, 0, 0, 0},
			{ 4, 4, 2, 2, 5, 5, 3, 0, 0, 0},
			{ 4, 4, 6, 7, 7, 7, 3, 8, 8, 8},
			{ 4, 4, 6, 7, 7, 7, 9, 9, 9, 0},
			{10,10, 6,11,11,11, 9, 9, 9, 0},
			{ 0, 0,12,12,13,14,14,15,15, 0},
			{ 0, 0,12,12,13,14,14,15,15, 0},
			{ 0, 0, 0,16,16,17,17,15,15, 0},
			{ 0, 0, 0, 0, 0,17,17, 0, 0, 0}
			        }
		 map()
		 camera()
			xline(4,-2,2) xline(2,-1,2)
			xline(6,-1,1)	xline(0,0,2)
			xline(4,0,2)		xline(2,1,4)
			xline(7,1,3)		xline(6,2,4)
			xline(0,3,2)		xline(3,3,3)
			xline(0,4,9)		xline(2,6,5)
			xline(3,7,2)		xline(7,7,2)
			xline(5,8,2)  yline(0,0,4)
			yline(2,-1,7) yline(3,1,3)
			yline(3,6,1)  yline(4,-2,3)
			yline(4,4,2)  yline(5,4,4)
			yline(6,-2,6) yline(7,-1,3)
			yline(7,4,4)  yline(9,2,5)
			yline(10,1,1)
  elseif (n==4) then
		 camera(384,8) 
  	gridx=24
  	gridy=0
  	xy_x=24
  	xy_y=16

			tilemap={
			{ 0, 0, 1, 1, 0, 0, 0, 0, 0, 0},
			{ 0, 0, 1, 1, 2, 3, 3, 0, 0, 0},
			{ 4, 4, 5, 5, 2, 3, 3, 6, 0, 0},
			{ 4, 4, 7, 7, 7, 8, 8, 6, 0, 0},
			{ 9, 9, 9,10,10, 8, 8, 6,11,11},
			{12,13,13,10,10,14,14,15,15,15},
			{12,13,13,10,10,14,14,15,15,15},
			{12, 0,16,16,16,14,14, 0, 0, 0},
			{ 0, 0,16,16,16,17, 0, 0, 0, 0},
			{ 0, 0, 0, 0, 0,17, 0, 0, 0, 0}
			        }
		 map()
		 camera()
		 xline(2,-2,2) xline(4,-1,3)
		 xline(4,-1,3) xline(0,0,4)
		 xline(7,0,1)	 xline(2,1,5)
		 xline(0,2,5)	 xline(8,2,2)
		 xline(0,3,3)	 xline(5,3,5)
		 xline(1,5,4)	 xline(7,5,3)
		 xline(0,6,1)	 xline(5,6,2)
		 xline(2,7,3)	 xline(5,8,1)

		 yline(0,0,6)		 yline(1,3,3)
		 yline(2,-2,4)  yline(2,5,2)
		 yline(3,2,3)		 yline(4,-2,3)
		 yline(5,-1,9)	 yline(6,6,2)
		 yline(7,-1,7)	 yline(8,0,3)
		 yline(10,2,3)
  end
end

function xline(x,y,l)
		local x0=xy_x
		local y0=xy_y
		local sw=8
		line (x0+(x*sw),y0+(y*sw),x0+(x*sw)+(l*sw),y0+(y*sw),5)
end

function yline(x,y,l)
		local x0=xy_x
		local y0=xy_y
		local sw=8
		line (x0+(x*sw),y0+(y*sw),x0+(x*sw),y0+(y*sw)+(l*sw),5)
end

function drawgui()
	spr(7,0,90)
	spr(7,0,120,1,1,false,true)
	spr(7,54,90,1,1,true,false)
	spr(7,54,120,1,1,true,true)
	for i=1,6 do
		spr(8,0+(i*8),90)
		spr(8,0+(i*8),120,1,1,false,true)
	end
	for i=1,3 do
		spr(9,0,90+(i*8))
		spr(9,54,90+(i*8),1,1,true,false)
	end
	
	spr(7,65,90)
	spr(7,65,120,1,1,false,true)
	spr(7,120,90,1,1,true,false)
	spr(7,120,120,1,1,true,true)
	for i=1,6 do
		spr(8,65+(i*8),90)
		spr(8,65+(i*8),120,1,1,false,true)
	end
	for i=1,3 do
		spr(9,65,90+(i*8))
		spr(9,120,90+(i*8),1,1,true,false)
	end
	
	for i=1,red do
		local t=(i-1)%7
		local u=flr((i-1)/7)
		spr(2,6+(7*t),96+(6*u))
	end
	for i=1,blue do
		local t=(i-1)%7
		local u=flr((i-1)/7)
		spr(3,71+(7*t),96+(6*u))
	end
end

function drawcursor(state,px,py)
	local snum=4
	if (state=="p2") then snum=5 end

	local x0=(gridx+2)+(px*8)
	local y0=(gridy+5)+(py*8)
	if (marb_a.active==false) then
		spr(snum,x0,y0)
	end
end

function drawmarbles()

	for y=0,9 do
		for x=0,9 do

		 n=get_marb(x,y)
			if (n~=0) then
--				if ( (lturn.x==x and lturn.y==y and state~="end") or 
--				     (pturn.x==x and pturn.y==y and state~="end")                                 ) then
--					spr(6,gridx+(x*8),gridy+(y*8))
--				end
				if (lturn.x==x and lturn.y==y and state~="end") then
					spr(6,gridx+(x*8),gridy+(y*8))
				elseif (pturn.x==x and pturn.y==y and state~="end") then
					spr(11,gridx+(x*8),gridy+(y*8))
				end
				spr(n+1,gridx+(x*8),gridy+(y*8))
			end

		end
	end
	
	if (marb_a.active) then
		if (player==1) then
			spr(2,marb_a.x0,marb_a.y0)
		else
			spr(3,marb_a.x0,marb_a.y0)
		end
	end

end

function draw_dialog()
 locx=dialog.x*8
 locy=dialog.y*8
 pl  =dialog.l*8
 ph	 =dialog.h*8

	palt(0,false)
	rectfill(locx,locy,locx+pl+8,locy+ph+8,0)
	
 spr(7,locx,locy)
	for i=1,dialog.l do
		spr(8,locx+(8*i),locy)
	end
	spr(7,locx+pl+8,locy,1,1,true,false)
	
 for i=1,dialog.h do
  spr(9,locx,locy+(8*i))
  spr(9,locx+pl+8,locy+(8*i),1,1,true,false)
 end 

 spr(7,locx,locy+ph+8,1,1,false,true)
	for i=1,dialog.l do
		spr(8,locx+(8*i),locy+ph+8,1,1,false,true)
	end
 spr(7,locx+pl+8,locy+ph+8,1,1,true,true)
	
	
	palt(0,true)
end

function draw_pass(sec)
 set_dialog(2,4,10,2)
	print("  no valid moves\n\nending game in "..sec.." ...",25,39,7)
end

function draw_end(phase,r,b)
 if (end_a.small) then
  set_dialog(1,11,12,2)
 	print("🅾️ play again\n"..
        "❘  main menu\n"..
        "⬆️   maximize",37,94,7)
		return 
 else
  set_dialog(1,1,12,12)
 end
 if (phase==0) then
 	return
 end
 if (phase>=1) then
		print("game over!",45,16,7)
	end
	if (phase >=2) then
 	print("final score",42,30,7)
 end
	if  (phase >=3) then
		local r_ten = flr(r/10)
		local r_one = r%10
		local b_ten = flr(b/10)
		local b_one = b%10
		
	 myspr(16+r_ten,18,45,18,24)
	 myspr(16+r_one,38,45,18,24)
	 myspr(32+b_ten,71,45,18,24)
	 myspr(32+b_one,91,45,18,24)
	
	end
	
	if (phase>=4) then
	 if (score.r>score.b) then
	  print("red wins !!!",41,80,8)
	 elseif (score.r<score.b) then
	  print("blue wins !!!",37,80,12)
	 else
	  print("it's a tie !!!",37,80,7)
	 end
	end
	
	if (phase >=5) then
  	print("🅾️ play again\n"..
	        "❘  main menu\n"..
	        "⬇️   minimize",37,94,7)
	end
end

function set_dialog(x,y,l,w)
	dialog.active=true
	dialog.x=x
	dialog.y=y
	dialog.l=l
	dialog.h=w
end

function del_dialog()
	dialog.active=false
	dialog.x=0
	dialog.y=0
	dialog.l=0
	dialog.h=0
end

function myspr(n,x,y,dw,dh)
	local sx = (n % 16) * 8
	local sy = (n \ 16) * 8
	sspr(sx,sy,8,8,x,y,dw,dh)
end

function drawthink()
 if (think_a.active) then
 	print(think_a.text,76,82,12)
 end
end

function drawrules(pagenum)
	local tx=10
	local	ty=10

	set_dialog(0,0,14,14)
	rectfill(9,0,21,4,0)
	print(pagenum.."/"..page_max,10,0,7)
	if (pagenum==1) then
		rectfill(99,122,119,128,0)
		print("❘/➡️",100,123,7)
	elseif (pagenum==page_max) then
		rectfill(99,122,119,128,0)
		print("❘/⬅️",100,123,7)
	else
		rectfill(87,122,119,128,0)
		print("❘/⬅️/➡️",88,123,7)
	end
	
	if (pagenum==1) then
	print(
	"kairu rules\n"..
	"-----------\n"..
	"goal:2 players place marbles\n"..
	"on a field of panels,\n"..
	"attempting to control as\n"..
	"many panels as possible\n\n"..
	"first turn: red places a\n"..
	"marble in any position"	
	,tx,ty,7)
	
	makeboard()
	spr(2,52,96)
	
	elseif (pagenum==2) then
	print(
	"second turn: blue must\n"..
	"place their marble in the\n"..
	"same row or column as\n"..
--	"red and cannot place theirs\n"..
--	"in the last panel played\n"
	"red but not in the panel\n"..
	"where red just played\n"
	,tx,ty,7)

	makeboard()
	spr(2,52,96)
	spr(6,52,96)
	spr(12,44,96)
	spr(12,36,96)
	spr(12,52,88)
	spr(13,52,80)
	spr(13,52,74)
	spr(13,60,96)
	spr(13,68,96)
	spr(13,76,96)
	print("blue may play in any",20,117,12)
	spr(13,101,116)
	print("yellow ring shows\nopponent's last move",28,55,10)
	
	elseif (pagenum==3) then
	print(
	"remaining turns: players\n"..
	"continue placing marbles\n"..
	"as before, but cannot play\n"..
	"in their opponent's last\n"..
	"panel, *nor* can they return\n"..
	"to the panel of their\n"..
	"own previous turn"
	,tx,ty,7)


	makeboard()
	spr(2,52,96)
	spr(3,60,96)
	spr(6,60,96)
	spr(11,52,96)
	print("red may play in any",20,117,8)
	spr(13,101,116)
	print("pink ring shows current\nplayer's last move",18,55,15)
	spr(12,44,96)
	spr(12,36,96)
	spr(12,68,96)
	spr(12,76,96)
	spr(12,60,104)
	spr(13,60,88)
	spr(13,60,80)
	spr(13,60,72)
	
	elseif (pagenum==4) then
	print(
	"game end: the game ends\n"..
	"immediately when:\n\n"..
	" - all marbles have been \n   played\n\n"..
	" - or when a player cannot\n"..
	"   make a legal move\n\n"..
	"scoring: points are gained\n"..
	"by having a majority of\n"..
	"marbles in each panel\n\n"..
	"for each panel a player\n"..
	"controls, they score points\n"..
	"equal to the size of the\n"..
	"panel (size=# of spaces)"
	,tx,ty,7)

	elseif (pagenum==5) then
	print(
	"if a panel is tied, it is\n"..
	"not scored.\n\n"..
	"some examples:\n\n\n\n\n\n\n\n\n\n\n\n\n"..
	"the player with the highest\n"..
	"score is the winner."
	,tx,ty,7)
	
	local sx=15	local sy=48

	for i=0,2 do
		spr(1,sx,sy+(8*i))    spr(1,sx+8,sy+(8*i))
	end	
	print("   red\n controls\n  (6 pts)",6,sy+28,8)
	spr(2,sx,sy)     spr(3,sx+8,sy)
	spr(2,sx,sy+8)   spr(3,sx+8,sy+8)
	spr(2,sx,sy+16 ) spr(2,sx+8,sy+16 )

	sx=60 	
	for i=0,2 do
		spr(1,sx+4,sy+(8*i))
	end	
	print("   blue\n controls\n  (3 pts)",49,sy+28,12)
 spr(3,sx+4,sy+16)
	
	sx=97 	
	spr(1,sx,sy+4) spr(1,sx+8,sy+4)
	spr(1,sx,sy+4+8) spr(1,sx+8,sy+4+8)
	print("   tie\n (0 pts)",88,sy+34,7)
	spr(2,sx,sy+4) spr(3,sx+8,sy+4)
	spr(3,sx,sy+12) spr(2,sx+8,sy+12)
	end
end

function makeboard()
	local sx=36
	local sy=88
	xy_x=sx
	xy_y=sy

	spr(1,sx+16,sy-8)
	spr(1,sx+16,sy-16)
	spr(1,sx+24,sy-8)
	spr(1,sx+24,sy-16)


	spr(1,sx,sy)
	spr(1,sx+8,sy)
	spr(1,sx+16,sy)

	spr(1,sx+24,sy)
	spr(1,sx+32,sy)
	spr(1,sx+40,sy)

	spr(1,sx,sy+8)
	spr(1,sx+8,sy+8)
	spr(1,sx+16,sy+8)

	spr(1,sx+24,sy+8)
	spr(1,sx+32,sy+8)
	spr(1,sx+40,sy+8)
	spr(1,sx+24,sy+16)
	spr(1,sx+32,sy+16)
	spr(1,sx+40,sy+16)
	
	xline(0,0,6)
	xline(0,2,3)
	xline(3,1,3)
	xline(3,3,3)
	xline(2,-2,2)
	yline(0,0,2)
	yline(3,0,3)
	yline(3,0,3)
	yline(6,0,3)
	yline(2,-2,2)
	yline(4,-2,2)
end
-->8
function movecursor(direc)
 if (marb_a.active) then
 	return
 end
 local x1=cx
 local y1=cy  
	if (direc==0) then
		x1-=1
		if (x1==-1) then x1=9 end

  while (get_tile(x1,y1)==0) do
  	x1-=1
  	if (x1==-1) then x1=9 end
  end

	elseif (direc==1) then
		x1+=1	
		if (x1==10) then x1=0 end
  while (get_tile(x1,y1)==0) do
  	x1+=1
  	if (x1==10) then x1=0 end
  end
		
	elseif (direc==2) then
	 y1-=1
		if (y1==-1) then y1=9 end
  while (get_tile(x1,y1)==0) do
  	y1-=1
  	if (y1==-1) then y1=9 end
  end

	elseif (direc==3) then
		y1+=1
		if (y1==10) then y1=0 end
  while (get_tile(x1,y1)==0) do
  	y1+=1
  	if (y1==10) then y1=0 end
  end
	
	end

	sfx(0)
	cx=x1
	cy=y1
end

function marb_place(x,y)
	local sx=6
	local i=red

 if (player==2) then
 	sx=71
 	i=blue
 end
 
 local t=(i-1)%7
 local u=flr((i-1)/7)

 marb_a.x0=sx+(7*t)
 marb_a.y0=96+(6*u)
	marb_a.x1=gridx+(x*8)
	marb_a.y1=gridy+(y*8)
	marb_a.active=true
 marb_a.cx=x
 marb_a.cy=y

	--set_marb(x,y,player)
	if (player==1) then
	 red-=1
	else
	 blue-=1
	end
end
-->8
function is_legal(p,x,y)
 --check if off the board -impossible situation unless checking entire board
 if (get_tile(x,y)==0) then
 	return false
 end

 --check first if spot is occupied
	if (get_marb(x,y)~=0) then
	 return false
	end

 --if first move, all spots are good
	if (lturn.x==-1 and lturn.y==-1) then
		return true
	end
	
	--check if at least row or col = last turn
	if (lturn.x~=x and lturn.y~=y) then
		return false
	end
	
 --make sure not on the tile of the last 2 turns
	last_tile =get_tile(lturn.x,lturn.y)
 pen_tile  =get_tile(pturn.x,pturn.y)	
 cur_tile  =get_tile(x,y)
 if (last_tile==cur_tile or pen_tile==cur_tile) then
 	return false
 end

	return true
end

-- list of all legal moves
function get_legal_moves(p)
	local moves={}
	for j=0,9 do
		for i=0,9 do
			if (is_legal(p,i,j)) then
				add(moves,{x=i,y=j})
			end
		end
	end
	
	return moves	
end

--calculate player scores
function get_score()
	
	local t_count={}
	for i=1,17 do
	 t_count[i]={r=0,b=0,z=0}
	end
	
	for j=0,9 do
		for i=0,9 do
			id=get_tile(i,j)
		 if (id~=0) then
		  m=get_marb(i,j)
		  if (m==1) then
		   t_count[id].r+=1
		  elseif (m==2) then
		   t_count[id].b+=1
		  end
		  t_count[id].z+=1
		 end
		end
	end
	
	local score = {r=0,b=0}
	
	for tile in all(t_count) do
		if (tile.r>tile.b) then
			score.r+=tile.z
		elseif (tile.b>tile.r) then
			score.b+=tile.z
		end	
	end
	
	return score
	
end

-- ai function: iterate over board,
-- return array of structs
-- z=x r=x b=x empties=x
-- owner=1/2 secured=f/t (is it still possible for tile to flip)
function get_tile_status()
	local tilelist={}
	for i=1,17 do
		tilelist[i]= { z=0, r=0,
		               b=0, empty=0,
		               owner=0, secured=false} 
 end
 
	for y=0,9 do
		for x=0,9 do
			local tile = get_tile(x,y)

			if (tile~=0) then
				local marb = get_marb(x,y)
				tilelist[tile].z+=1			
				if (marb==1) then
					tilelist[tile].r+=1
				elseif (marb==2) then
					tilelist[tile].b+=1
				else
				 	tilelist[tile].empty+=1
				end
			end

	 end
	end
	
	--iterate again, calc owner and security
	for e in all(tilelist) do
		if (e.r>e.b) then
			e.owner=1
		elseif (e.b>e.r) then
			e.owner=2
		else
			e.owner=0
		end
		
		if ( (e.b>e.r+e.empty) or 
		     (e.r>e.b+e.empty) ) then
			e.secured=true	
		end
		
	end

	return tilelist
end


function evaluate_pos()

	-- ai version 1: simple score eval
	-- local score = get_score()
	-- return score.b-score.r 
	if (difficulty==0) then
		local score = get_score()
		local val_easy = score.b-score.r 
		if (rnd(1)<0.33) then
		  val_easy -= 6
		end
	 return val_easy
	end

	-- ai version 2
	local score = get_score()
	local val = score.b-score.r
	local status=get_tile_status()

	for e in all(status) do
		if (e.owner==2) then
			val+= (1*e.z)
			if (e.secured) then
				val+= e.z
			else
			 val+= e.z\2
			end
		elseif (e.owner==1) then
			val-= (1*e.z)
			if (e.secured) then
				val-= e.z
			else
			 val-= e.z\2
			end
		end
	end	

	return val
end

function find_ai_move()
 -- ai 1: dumb ass ai
 -- local m = {x=0,y=0}
 -- local moves=get_legal_moves()
 -- m.x = moves[1].x
 -- m.y = moves[1].y

 -- ai 2: first attempt at 1ply ai
 -- local result = {x=0,y=0}
 -- local best_eval=-999

 -- local moves=get_legal_moves()
 -- for move in all(moves) do
 -- set_marb(move.x,move.y,2)

 -- local eval = evaluate_pos()
 -- if (eval>best_eval) then
 -- 	best_eval=eval
 -- 	result={x=move.x,y=move.y}
 -- end

 -- set_marb(move.x,move.y,0)
 -- end 
 -- return result
 
 --ai 3: simple minimax
 local result = {x=0,y=0}
 local best_eval=-999
 local moves=get_legal_moves()
 
 for move in all(moves) do
  set_marb(move.x,move.y,2)
		
		local old_lturn = {x=lturn.x, y=lturn.y}
		local old_pturn = {x=pturn.x, y=pturn.y}
		pturn = {x=lturn.x, y=lturn.y}
		lturn = {x=move.x, y=move.y}

  blue-=1

 	local eval  --= minimax(3,1,-9999,9999)
 	local turns = 56-red-blue
 	
 	if (difficulty==0) then
		 eval  = minimax(1,1,-9999,9999)
	 else
		 
	 	if (turns<8) then
	 		eval  = minimax(2,1,-9999,9999)
	 	elseif (turns < 20) then
	 		eval  = minimax(3,1,-9999,9999)
	 	elseif (turns < 38) then
	 		eval  = minimax(4,1,-9999,9999)
	 	elseif (turns < 44) then
	 		eval  = minimax(5,1,-9999,9999)
	 	else
	 		eval  = minimax(6,1,-9999,9999) 	
	 	end 

 	end
 	
 
  set_marb(move.x,move.y,0)
		lturn = old_lturn
		pturn = old_pturn
		blue+=1
  
  if (eval>best_eval) then
  	best_eval=eval
  	result = {x=move.x, y=move.y}
  end
  
 end
 
	think_a.text=""
	think_a.tick=0
	think_a.active=false

	--printh(best_eval,"debug.txt")
 return result
  
end

function minimax(depth, player, alpha, beta)

	--check game end	
	if (depth==0) then
		return evaluate_pos()
	end

	local moves=get_legal_moves()
	if (red==0 or blue==0 or #moves==0) then
		return evaluate_pos()
	end

	local best_eval=0
	if (player==1) then
		best_eval=9999
	else
		best_eval=-9999
	end
	
	
	-- check for nul and return here?
	
	for move in all(moves) do

		local old_lturn = {x=lturn.x, y=lturn.y}
		local old_pturn = {x=pturn.x, y=pturn.y}
		pturn = {x=lturn.x, y=lturn.y}
		lturn = {x=move.x, y=move.y}
  set_marb(move.x,move.y,player)

  if (player==1) then
   red-=1
  else
   blue-=1
  end
  
 	local eval = minimax(depth-1,3-player,alpha,beta)
 
  set_marb(move.x,move.y,0)
		lturn = old_lturn
		pturn = old_pturn

  if (player==1) then
 		red+=1
	  if eval < best_eval then
	      best_eval=eval
	  end
	  if best_eval < beta then
	    beta = best_eval
	  end
	  if beta <= alpha then
	   break
	  end
 	else
 	 blue+=1
	  if eval > best_eval then
	      best_eval=eval
	  end
	  if best_eval>alpha then
	  	alpha = best_eval
	  end
	  if beta<= alpha then
	   break
	  end
 	end

	end
	
	return best_eval
end
-->8
function pass_tick()
	pass_a.tick+=1
	
	if (pass_a.tick==30) then
		pass_a.sec=2
	elseif (pass_a.tick==60) then
		pass_a.sec=1
	elseif (pass_a.tick==90) then
		pass_a.sec=0
	elseif (pass_a.tick==120) then
		pass_a.active=false
		pass_a.tick=0
		pass_a.sec=3
		del_dialog()
		state="end"
		end_a.active=true
	end
end

function end_tick()
 end_a.tick+=1

	if (end_a.tick==1*30) then
	 end_a.phase=1
	elseif (end_a.tick==2*30) then
	 end_a.phase=2
	elseif (end_a.tick>=3*30 and 
	        end_a.tick<(5*30)+15) then
	 end_a.phase=3

	 if (score.r~=end_a.r) then
	  end_a.r+=1
	  sfx(1)
	 end
	 if (score.b~=end_a.b) then
	  end_a.b+=1
	  sfx(1)
	 end
	 
	elseif (end_a.tick==(5*30)+15) then
	 end_a.phase=4
	 if (score.r~=score.b) then
   music(3)
	 end
	elseif (end_a.tick==9*30) then
	 end_a.phase=5
		end_a.active=false
	end
end

function marb_tick()
 local t = marb_a
 
 t.tick+=1
 
 local speed=0.8
 local frames=speed*30
 if (t.tick<=1) then
 	t.dx=sgn(t.x1-t.x0)*ceil(abs(t.x1-t.x0)/frames)
 	t.dy=sgn(t.y1-t.y0)*ceil(abs(t.y1-t.y0)/frames)
 end
 
	if (t.x0<t.x1 and t.dx>0) then
  t.x0+=t.dx
 elseif (t.x0>t.x1 and t.dx<0) then
  t.x0+=t.dx
 else
 	t.dx=0 
 end

	if (t.y0>t.y1) then
  t.y0+=t.dy
 else
 	t.dy=0
 end
 
 if (t.dx==0 and t.dy==0) then
 	t.active=false
 	t.tick=0
 	
	 set_marb(t.cx,t.cy,player)

  sfx(2)
	
	 pturn={x=lturn.x,y=lturn.y}
	 lturn={x=t.cx,y=t.cy}
	 
	 --check for game end or valid moves?
	 moves = get_legal_moves(player)

	 if (red==0 and blue==0) then
	 	state="end"
	 	score=get_score()
	 	end_a.active=true
	 elseif (#moves==0) then
	 	state="pass"
	 	score=get_score()
			pass_a.active=true
	 end

	 -- bug: if p1 runs out of marble it still activates
	 -- the thinking timer
		if (state=="p1") then
			if (ai) then
			 state="think"
			 think_a.active=true;
			else
				state="p2"
			end
			player=2
		elseif (state=="p2" or state=="ai") then
			state="p1"
			player=1
		end

 end
end

function think_tick()
 local t = think_a
 
 t.tick+=1
 
 if (t.tick<=1) then
 	t.text = "thinking"
 	local i = flr(rnd(3))
 	if (i==0) then
 		t.length= 22
 	elseif (i==1) then
 		t.length= 35
 	elseif (i==2) then
 		t.length= 50
 	end
 elseif (t.tick>1 and (t.tick%4 == 0)) then
   if (t.text == "thinking") then
   	t.text="thinking ."
   elseif (t.text == "thinking .") then
   	t.text="thinking .."
   elseif (t.text == "thinking ..") then
   	t.text="thinking ..."
   elseif (t.text == "thinking ...") then
   	t.text="thinking"
   end
 end
 
 if (t.tick>t.length) then
 	--t.text=""
 	--t.tick=0
 	--t.active=false
 	
 	state="ai"
 	--sfx(1)
 end
 
end