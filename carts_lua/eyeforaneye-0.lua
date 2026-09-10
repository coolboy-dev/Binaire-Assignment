--main

function _init()
	
	round=1
	lives=3
	
	earn=0
	money=0
	
	earnttl=0
	shotsttl=0
	killsttl=0
	
	cam={
	x=0,
	y=0}
	
	bg_init()
	canon_init()
	ball_init()
	en_init()
	shop_init()
	popup_init()
	hud_init()
	menu_init()
	
	state="menu"
	
	
end

function _update()

	stats={
	{name="total money earned:",
	num=earnttl},
	{name="total kills:",
	num=killsttl},
	{name="total times shot:",
	num=shotsttl}
	}
	
	canon_update()
	ball_update()
	en_update()
	spark_update()
	profit_update()
	hud_update()
	bg_update()
	
	if state=="game" then
		if lives<=0 then
			state="gameover"
			sfx(3)
			gameover_init()
		end
	end
	
	if state=="gameover" then
		gameover_update()
	end
	
	if state=="shop" then
		shop_update()
	end
	
	if state=="popup" then
		popup_update()
	end
	
	if state=="menu" then
		menu_update()
	end
end

function _draw()
	if state=="game" then
		screen_shake()
	end
	cls(0)
	camera(cam.x,cam.y)
	bg_draw()
	canon_draw()
	en_draw()
	ball_draw()
	hud_draw()
	spark_draw()
	profit_draw()
	
	if state=="shop" then
		shop_draw()
	end
	
	if state=="popup" then
		popup_draw()
	end
	
	if state=="gameover" then
		gameover_draw()
	end
	
	if state=="menu" then
		menu_draw()
	end
	
end
-->8
--canon

function canon_init()
	canon={
	y=128,
	x=64,
	goalx=64,
	t=0.25,
	l=20,
	w=3,
	c=7,
	
	move=false,
	aim=false,
		
	angle=0.1,
	
	rot=0.0075,
	
	timer=60,
	counter=0}
end

function canon_update()

	if round>= 10 then
		canon.move=true
	end
	
	if round>= 5 then
		canon.aim=true
	end
	
	
	
	if state=="game" then
		if btn(➡️) then
			canon.t-=canon.rot
		end
		if btn(⬅️) then
			canon.t+=canon.rot
		end
		if btnp(❘) and canon.counter<0 and enemy.kills<enemy.quota then
			shoot(canon.x,canon.y,canon.t)
			canon.counter=canon.timer
			spark_init(canon.x+cos(canon.t)*canon.l,canon.y+sin(canon.t)*canon.l)
			shake=2
			shotsttl+=1
			sfx(0)
		end
		
	
		--counter/cooldown
		canon.counter-=1
		
		--move to ball
		if canon.move==true then
			if canon.x<canon.goalx then
				canon.x+=5
			elseif canon.x>canon.goalx then
				canon.x-=5
			end
		end
		
		if canon.x<canon.w then
			canon.x=canon.w
		elseif canon.x>128-canon.w then
			canon.x=128-canon.w
		end
		
	end
	
	if abs(canon.goalx-canon.x)<5 then
		canon.goalx=canon.x
	end
	
	--limit
	if canon.t<0.25-canon.angle then
		canon.t=0.25-canon.angle
	elseif canon.t>0.25+canon.angle then
		canon.t=0.25+canon.angle
	end
end

function canon_draw()
	if state =="game" then
		
		--right
		line(
		canon.x+cos(canon.t-(canon.w/100))*canon.l,
		canon.y+sin(canon.t-(canon.w/100))*canon.l,
		canon.x-cos(canon.t+(canon.w/100))*canon.l,
		canon.y-sin(canon.t+(canon.w/100))*canon.l,
		canon.c)
		
		--left
		line(
		canon.x+cos(canon.t+(canon.w/100))*canon.l,
		canon.y+sin(canon.t+(canon.w/100))*canon.l,
		canon.x-cos(canon.t-(canon.w/100))*canon.l,
		canon.y-sin(canon.t-(canon.w/100))*canon.l,
		canon.c)
		
		--top
		line(
		canon.x+cos(canon.t-(canon.w/100))*canon.l,
		canon.y+sin(canon.t-(canon.w/100))*canon.l,
		canon.x+cos(canon.t+(canon.w/100))*canon.l,
		canon.y+sin(canon.t+(canon.w/100))*canon.l,
		canon.c)
	end
	
	
	if canon.aim==true then
		for i=1,128,5 do
			pset(
			canon.x+cos(canon.t)*i,
			canon.y+sin(canon.t)*i,
			1)
		end
	end
	
end
-->8
--ball


	
function ball_init()
	ball={
	speed=3,
	c=7}
	
	balls={}
end

function ball_update()
	for i in all(balls) do
		i.x+=i.dx*ball.speed
		i.y+=i.dy*ball.speed
		
		if i.x<0 then
			i.x=0
			i.dx=-i.dx
			spark_init(0,i.y)
			sfx(2)
		elseif i.x>128 then
			i.x=128
			i.dx=-i.dx
			spark_init(128,i.y)
			sfx(2)
		end
		
		if i.y<10 then
			i.y=10
			i.dy=-i.dy
			spark_init(i.x,10)
			sfx(2)
		elseif i.y>128 then
			canon.goalx=i.x
			del(balls,i)
		end
	end
	
	for i=1, #balls do
		for j=i+1, #balls do
			if dist(balls[i].x,balls[i].y,balls[j].x,balls[j].y)<canon.w*2 then
				local dx=balls[i].x-balls[j].x
				local dy=balls[i].y-balls[j].y
				local t=atan2(dx,dy)
				
				balls[i].dx=cos(t)
				balls[i].dy=sin(t)
				
				balls[j].dx=-cos(t)
				balls[j].dy=-sin(t)
			end
		end
	end
end

function ball_draw()
	for i in all(balls) do
		circ(i.x,i.y,i.size,i.c)
	end
	
end
-->8
--random

function shoot(x,y,t)
	add(balls,{
	x=x,
	y=y,
	dx=cos(t),
	dy=sin(t),
	size=canon.w,
	c=ball.c})
end

function dist(x1,y1,x2,y2)
	dx=x1-x2
	dy=y1-y2
	
	distance=sqrt((dx*dx)+(dy*dy))
	
	return distance
end

function left_txt(text,x,y,c)
	local text=tostr(text)
	print(text,x-#text*4,y,c)
end

function center_txt(text,x,y,c)
	local text=tostr(text)
	print(text,x-#text*2,y,c)
end


shake=0
function screen_shake()
	shakex=-2+rnd(4)
	shakey=-2+rnd(4)
	
	shakex*=shake
	shakey*=shake
	
	shake*=0.8
	if abs(shake)<0.5 then
		shake=0
	end
	
	cam.x=shakex
	cam.y=shakey
end

txt_t =0 
function wobble_txt(text,x,y,c,sp,h)
	local text=tostr(text)
	txt_t+=sp
	
	for i=1,#text do
		print(
		text[i],
		x+i*4-(#text*2)-3,
		y+5+sin(txt_t-i/10)*h,
		c)
	end
end

function new_round()
	round+=1
	earn=0
	state="game"
	en={}
	enemy.kills=0
	enemy.quota+=3
	enemy.max+=1
	enemy.speed+=0.05
		
	canon.x=64
	canon.goalx=64
	canon.t=0.25
end


function new_game()
	round=1
	earn=0
	money=0
	lives=3
	state="game"
	
	earnttl=0
	killsttl=0
	shotsttl=0
	
	ball={
	speed=3,
	c=7}
	
	enemy={
	max=round,
	speed=0.250,
	size=4,
	c=7,
	reward=1,
	kills=0,
	quota=round*3}
	
	
	canon={
	y=128,
	x=64,
	goalx=64,
	t=0.25,
	l=20,
	w=3,
	c=7,
	move=false,
	aim=false,
	angle=0.1,
	rot=0.0075,
	timer=60,
	counter=0}
	
	
end


-->8
--enemies

function en_init()
	enemy={
	max=round,
	speed=0.25,
	size=4,
	c=7,
	
	reward=1,
	
	kills=0,
	quota=round*3}
	
	en={}
end

function en_update()
	if state=="game" then
		if #en < enemy.max then
			add(en,{
			x=5+rnd(118),
			y=-10-(round*5)+rnd(round*5),
			speed=enemy.speed,
			size=enemy.size,
			c=enemy.c})
		end 
		
		for i in all(en) do
			i.y+=i.speed
			
			if enemy.kills>=enemy.quota then
				i.y-=i.speed
				if #balls==0 then
					sfx(4)
					state="popup"
					popup_init()
				end
			end
			
			if i.y>128 then
				del(en,i)
				spark_init(7,6+lives*9)
				lives-=1
				sfx(5)
			end
			
			for j in all(balls) do
				if dist(i.x,i.y,j.x,j.y)<(i.size+j.size) and i.y>1 then
					local profit=enemy.reward+flr(i.y/20)
					profit_init("+"..profit,i.x,i.y,7)
					money+=profit
					earn+=profit
					earnttl+=profit
					spark_init(i.x,i.y)
					del(en,i)
					enemy.kills+=1
					killsttl+=1
					face.mood="pain"
					face.counter=face.timer
					shake=1
					sfx(1)
				end
			end
		end
	end
	
	for i=1, #en do
		for j=i+1, #en do
			if dist(en[i].x,en[i].y,en[j].x,en[j].y)<enemy.size*2 and en[i].y>1 and en[j].y>1 then
				if en[i].x<en[j].x then
					en[i].x-=1
					en[j].x+=1
				end
				if en[j].x<en[i].x then
					en[j].x-=1
					en[i].x+=1
				end		
				if en[i].y<en[j].y then
					en[i].y-=1
					en[j].y+=1
				end
				if en[j].y<en[i].y then
					en[j].y-=1
					en[i].y+=1
				end			
			end
		end
	end
end

function en_draw()
	for i in all(en) do
		spr(8,i.x-4,i.y-4)
	end
end
-->8
--hud/bg

function bg_init()
	face={
	y=30,
	mood="neutral",
	lpupilx=49,
	lpupily=8,
	rpupilx=78,
	rpupily=8,
	
	
	timer=30,
	counter=20}
end

function bg_update()
	if face.mood=="pain" then
		face.counter-=1
	end
	
	if face.counter<0 then
		face.mood="neutral"
	end
	
	if #balls>0 then
	--lpupil
		lpupildx=balls[1].x-face.lpupilx
		lpupildy=balls[1].y-(face.y+face.lpupily)
		lpupilt=atan2(lpupildx,lpupildy)
		
		--rpupil
		rpupildx=balls[1].x-face.rpupilx
		rpupildy=balls[1].y-(face.y+face.rpupily)
		rpupilt=atan2(rpupildx,rpupildy)
	end
	
	if #balls==0 then
		lpupilt=0.75
		rpupilt=0.75
	end
end

function bg_draw()

	--face
	if face.mood=="neutral" then
		spr(1,41,face.y,2,2)
		spr(1,71,face.y,2,2,true,false)
	elseif face.mood=="pain" then
		spr(3,41,face.y,2,2)
		spr(3,71,face.y,2,2,true,false)
	end
	
	--eyes
	if face.mood=="neutral" then
		circfill(
		face.lpupilx+cos(lpupilt)*2,
		face.y+face.lpupily+sin(lpupilt)*2,
		2,
		0)
			
		circfill(
		face.rpupilx+cos(rpupilt)*2,
		face.y+face.rpupily+sin(rpupilt)*2,
		2,
		0)
	end
	
	if enemy.kills>=enemy.quota then
		spr(5,40,face.y-10,2,2)
		spr(5,72,face.y-10,2,2,true)
	end
	
	
	--lines at bottom
	for i=1,4,2 do
		line(3,126-i,124,126-i,5)
	end
	
	--lines at top
	for i=1,4,2 do
		line(3,15-i,124,15-i,5)
	end
end
	
	


--hud----------------
function hud_init()
end

function hud_update()
end


function hud_draw()

	--thing to cover above
	rectfill(0,0,128,-64,0)
	
	rect(0,0,127,127,7)
	
	rect(0,0,127,10,7)
	rectfill(1,1,126,9,5)
	
	center_txt("round "..round,64,3,7)
	
	--kills
	print(enemy.kills.."/"..enemy.quota,4,3,7)

	--money
	left_txt("$"..money,125,3,7)

	for i=1, lives do
		spr(7,3,6+i*9)
	end
end





-->8
--shop/popup

function shop_init()
	upgrades={
		{name="+ball speed",
		price=7*round,
		c=7},
		
		{name="+max angle",
		price=10*round,
		c=7},
		
		{name="+reward",
		price=11*round,
		c=12},
		
		{name="-cooldown",
		price=9*round,
		c=7},
		
		{name="+rotation speed",
		price=5*round,
		c=7},
		
		{name="+ball size",
		price=8*round,
		c=7},
		
		{name="+1 life",
		price=6*round,
		c=7},
		}
		
		
	display={}
	
	disp={
	var=20}
		
	for i=1,3 do
		local index=flr(rnd(#upgrades))+1
		add(display,
		upgrades[index])
		del(upgrades,upgrades[index])
	end
			
	marked=1
end

function shop_update()
	if btn(❘) then
		new_round()
	end
	
	if btnp(⬇️) and marked != 3then
		marked+=1
	elseif btnp(⬆️) and marked!= 1 then
		marked-=1
	end
	
	-- buying upgrades
	if btnp(➡️) and money>=display[marked].price then
		new_round()
		sfx(1)
		profit_init("-$"..display[marked].price,100,20,8)
		if display[marked].name=="+ball speed" then
			money-=display[marked].price
			ball.speed+=1
		end
		if display[marked].name=="+max angle" then
			money-=display[marked].price
			canon.angle+=0.02
		end
		if display[marked].name=="+reward" then
			money-=display[marked].price
			enemy.reward+=1
		end
		if display[marked].name=="-cooldown" then
			money-=display[marked].price
			canon.timer-=15
		end
		if display[marked].name=="+rotation speed" then
			money-=display[marked].price
			canon.rot+=0.0015
		end
		if display[marked].name=="+ball size" then
			money-=display[marked].price
			canon.w+=1
		end
		if display[marked].name=="+1 life" then
			money-=display[marked].price
			lives+=1
			spark_init(7,6+lives*9)
		end
	end
	
	
end

function shop_draw()
	cam.x=128
	local txtc=7
	if btnp(➡️) and money<display[marked].price then
		txtc=8
		sfx(2)
	end
	
	rect(128,1,255,127,7)
	
	rect(128,0,255,10,7)
	rectfill(129,1,254,9,5)
	center_txt("shop",192,3,7)
	line(128,117,256,117,7)
	center_txt("(x) continue",192,120,7)
	
		--money
	left_txt("$"..money,253,3,txtc)
	
	--display
	for i=1,#display do 
		center_txt(display[i].name,192,2+i*disp.var,display[i].c)
		
		if i==marked then
			rectfill(
			130,
			marked*disp.var,
			253,
			16+marked*disp.var,
			5)
			
			rect(
			130,
			marked*disp.var,
			253,
			16+marked*disp.var,
			7)
			
			--show price
			left_txt("$"..display[i].price.." ➡️",247,1+marked*disp.var+6,0) 
			left_txt("$"..display[i].price.." ➡️",247,marked*disp.var+6,txtc) 
			
			--arrows
			print("⬇️",133,1+marked*disp.var+10,0)
			print("⬆️",133,1+marked*disp.var+2,0)
			print("⬇️",133,marked*disp.var+10,txtc)
			print("⬆️",133,marked*disp.var+2,txtc)
			
			
			wobble_txt(display[i].name,192,1+i*disp.var,0,04,1.5)
			wobble_txt(display[i].name,192,i*disp.var,txtc,0.04,1.5)
	
		else
			display[i].c=7
		end
		
	end
	
	
	
end



--ball speed
--angle
--multiplier
--cooldown
--rot speed
--ball thickness
--life


--aim
--show cash
--move canon
--trap
--explosive ball


-------pop up-----------

function popup_init()
	popup={
	goaly=60,
	y=128,
	size=80,
	c=1}
end

function popup_update()
	if btnp(🅾️) then
		shop_init()
		state="shop"
		popup.y=128
		sfx(1)
	end
	
	if popup.y>popup.goaly then
		popup.y-=3
	end
	
	if abs(popup.y-popup.goaly)<3 then
		spark_init(64,popup.y-popup.size/2)
		popup.y=popup.goaly
	end
end

function popup_draw()
	
	rect(
	64-(popup.size/2)-1,
	popup.y-(popup.size/2)-1,
	64+(popup.size/2)+1,
	popup.y+(popup.size/2)+1,
	7)
	
	rectfill(
	64-(popup.size/2),
	popup.y-(popup.size/2),
	64+(popup.size/2),
	popup.y+(popup.size/2),
	popup.c)
	
	line(
	64-(popup.size/2),
	popup.y-(popup.size/2)+9,
	64+(popup.size/2),
	popup.y-(popup.size/2)+9,
	7)
	
	--completed
	center_txt(
	"round "..tostr(round).." completed!",
	64,
	popup.y-popup.size/2+2,
	7)
	
	
	if round==4 then
		--unlocked
		center_txt(
		"    aim \n unlocked!",
		64+16,
		popup.y-popup.size/2+40,
		11)
	end
	
		if round==9 then
		--unlocked
		center_txt(
		"movable canon\n  unlocked",
		64+22,
		popup.y-popup.size/2+40,
		11)
	end
	--money earned
	center_txt(
	"money earned:",
	64,
	popup.y-(popup.size/2)+13,
	7)
	center_txt(
	"$"..tostr(earn),
	64,
	popup.y-(popup.size/2)+21,
	7)
	--shop
	center_txt(
	"(z/c) continue",
	64,
	popup.y+(popup.size/2)-5,
	7)
end
-->8
--particles

spark={}
function spark_init(x,y)
	for i=1,10 do
		add(spark,{
		x=x-3+rnd(6),
		y=y-3+rnd(6),
		dx=-2+rnd(4),
		dy=-2+rnd(4),
		c=7,
		life=5+rnd(10)})
	end
end

function spark_update()
	for i in all(spark) do
		i.x+=i.dx
		i.y+=i.dy
		
		i.life-=1
		if i.life<0 then
			del(spark,i)
		end
	end
end

function spark_draw()
	for i in all(spark) do
		pset(i.x,i.y,i.c)
	end
end


profit={}
function profit_init(text,x,y,c)
	local text=tostr(text)
	add(profit,{
	text=text,
	x=x,
	y=y,
	c=c,
	life=30})
end

function profit_update()
	for i in all(profit) do
		i.y-=0.5
		
		i.life-=1
		if i.life<1 then
			del(profit,i)
		end
	end
end

function profit_draw()
	for i in all(profit) do
		print(i.text,i.x,i.y,i.c)
	end
end
-->8
--gameover/main menu

function gameover_init()
	en={}
	balls={}
end

function gameover_update()
	if btn(❘) then
		new_game()
	end
end

function gameover_draw()
	cam.y=128
	
	--outline
	rect(0,128,127,255,7)
	
	--square up
	rectfill(1,129,126,138,5)
	rect(0,0,128,138,7)
	
	center_txt("game over",64,131,7)
	
		--money
	left_txt("$"..money,125,131,7)
	
	line(0,245,128,245,7)
	center_txt("(x) restart",64,248,7)


	--display
	for i=1,#stats do 
		center_txt(stats[i].name,64,120+i*27,7)
		center_txt(stats[i].num,64,126+i*27,7)
	
	end
end

function menu_init()
	eye={
	y=20,
	move=false}	
end

function menu_update()
	if btn(❘) and eye.move==false then
		eye.move=true
		sfx(4)
	end
	
	if eye.move==true then
		if eye.y>=0 then
			eye.y-=0.5
		end
		
		if eye.y<=0 then
			state="game"
		end
	end
end

function menu_draw()
	rectfill(0,0,128,128,0)
	center_txt("eye for an eye!",64,8,7)
	wobble_txt("(x) start",64,110,7,0.04,2)


	--eyes
	spr(3,41,face.y+eye.y,2,2)
	spr(3,71,face.y+eye.y,2,2,true,false)
	
end
