function _init()
	poke(0x5f2d, 1)
	
	if rnd(1)>0.5 then
		music(16)
		sfxchannel=2
	else
		music(0)
		sfxchannel=-1
	end
	
	max_hp = 50
	player = {x=50,y=50,dx=0,dy=0, rad=2, hp=max_hp}
	dhp = player.hp
	
	prevs = {}
	
	healcooldown=0
	iframes=0
	ticks=0
	dashtime=0
	
	boss = {x=64,y=64}
	
	potion_sickness=20
	dmg_mult=1
	mult_interval = 30
	autoheal=false
	
	function autohealfxn()
		autoheal=not autoheal
		local s = "enable"
		if (autoheal) s="disable"
		menuitem(1,s.." autoheal", autohealfxn)
	end
	
	autohealfxn()
end
function damage(amt)
	player.hp-=flr(amt*dmg_mult)
	sfx(15, sfxchannel)
end

function _update60()
	ticks+=1
	
	flypress = btn(⬆️) or btn(❘)
	dmg_mult = flr(time()/mult_interval)+1
	--mx, my = stat(32), stat(33)
	healcooldown=max(healcooldown-1,0)
	dashtime=max(dashtime-1,0)
	
	accel=0.2
	if player.hp>0 then
		if (btn(➡️)) player.dx+=accel player.flp=flp
		if (btn(⬅️)) player.dx-=accel player.flp=true
		if (flypress) player.dy-=0.2
		if (btnp(🅾️)) then
			player.dx=4
			if (player.flp) player.dx=-4
			dashtime=20
		end
		if ((btnp(⬇️) or (autoheal and player.hp<=max_hp-10))and player.hp<max_hp and healcooldown<=0) sfx(14, sfxchannel) player.hp+=10 healcooldown=60*potion_sickness
		
	end
	
	player.dy+=0.1
	
	if (abs(player.dx)>1) player.dx*=0.9
	player.dy=mid(player.dy,-1,(0.2 and flypress) or 2)
	
	player.x+=player.dx
	player.y+=player.dy
	if (player.hp>0) then
		player.y%=128
		player.x%=128
	else
		player.y=-100
	end
	
	add(prevs, {x=player.x,y=player.y, vis=ticks%2==0 and dashtime>0, flp=player.flp})
	while #prevs>10 do deli(prevs, 1) end
	
	
	start = (time()>5 and ticks%120==0) or (time()>30 and ticks%60==0) 
	
	if start and #projectiles<=10 and player.hp>0 then
		choice = flr(rnd(4))
		if choice==0 then
			blossom(player.x,player.y,75,6, spiral)
			sfx(18, sfxchannel)
		elseif choice==1 then
			wall(rnd(1), 10,3,grav)
			sfx(19, sfxchannel)
		elseif choice==2 then
			rain(4,bounce)
			sfx(17, sfxchannel)
		else
			blossom(player.x,player.y,100,3, grav2)
			sfx(16, sfxchannel)
		end
		
	end
	update_p()
	
	iframes = max(iframes-1,0)
	player.hp=mid(player.hp,0,max_hp)
end

function _draw()
	cls()
	--camera(player.x-64,player.y-64)
	--pset(mx,my,7)
	
	if (iframes>0) pal(7,8)
	local flap = ticks%20>10
	
	boss.x+=cos(time()/5)*0.1
	boss.y+=cos(time()/10)*0.1
	
	local w,h = 24,48
	local sx = 0
	sx+=flr((ticks%40)/10)*24
	
	pal(7,1)
	sspr(sx,32,w,h,boss.x-24,boss.y-16, w,h)
	sspr(sx,32,w,h,boss.x-24+w-3,boss.y-16, w,h, true)
	pal()
	
	for p in all(prevs) do
		if (p.vis) spr(4,p.x-4,p.y-4, 1,1, p.flp)
	end
	
	draw_p()
	
	
	if time()<5 then
		print("⬆️", player.x-4,player.y-16,5)
		print("⬅️", player.x-12,player.y-10,5)
		print("➡️", player.x+4,player.y-10,5)
		if (time()>2.5) print("🅾️ to dash", player.x-20,player.y+16,5)
	elseif time()<7 then
		print("survive as long as possible!", 0,120,7)
		
	end
	
	if (time()>mult_interval and time()%mult_interval<2) print("attacks now hurt "..dmg_mult.."X more", 0,120,2)
	--
	if (player.hp>0) sspr(8,flap and flypress and 8,20,8, player.x-10,player.y-4, 20,8, player.flp)
	pal()
	--pset(player.x, player.y, 12)
	if player.hp>0 then
		time_survived=time()
		color(7)
		if (iframes>0) color(8)
		
		print("hp: "..player.hp,0,0)
		
		rectfill(0,5,max_hp,8,1)
		dhp+=(player.hp-dhp)*0.05
		
		if player.hp-1>dhp then
			rectfill(0,5,player.hp,8,11)
			
			rectfill(0,5,flr(dhp+0.5),8,4)
			rectfill(0,5,dhp,8,8)
			
			
		else
			rectfill(0,5,flr(dhp+0.5),8,4)
			rectfill(0,5,dhp,8,9)
			
			rectfill(0,5,player.hp,8,8)
			
		end
		
		color(5)
		
		if healcooldown>0 then
			spr(6,0,10)
			print("- "..flr(healcooldown/6)/10, 10,12)
		else
			if player.hp==max_hp then
				spr(6,0,10)
			else
				spr(5,0,10)
				if (time()%0.5>0.25 and player.hp<max_hp-10) color(6)
			
			end
			
			print("- ⬇️", 10,12)
		
		end
	else
		music(-1)
		print("you died!", 0,0,8)
	end
	
	print("time: "..time_survived, 0,20,5)
end
-->8
projectiles = {}

function shoot(x,y, ai)
	p = {
		x=x,y=y,dx=0,dy=0,ai=ai,col=col or 8, rad=rad or 4,
		life=0, tx=player.x, ty=player.y
	}
	add(projectiles, p)
	return p
	
end




function update_p()
	for p in all(projectiles) do
		p.x+=p.dx
		p.y+=p.dy
		p.life+=1
		
		if (p.ai!=nil) p:ai()
		
		dx, dy = p.x-player.x, p.y-player.y
		dist = dx^2 + dy^2
		
		if iframes==0 and abs(dx)<15 and abs(dy)<15 and dist<player.rad^2+p.rad^2 then
			iframes=5
			player.x-=dx
			player.y-=dy
			damage(p.rad)
			del(projectiles, p)
		elseif p.rad<=0 or (p.life>200 and (abs(p.x-64)>70 or abs(p.y-64)>100)) then
			del(projectiles, p)
		end
		
	end
end

function draw_p()
	for p in all(projectiles) do
		circfill(p.x,p.y,p.rad,p.col)
		if p.ai==grav or p.ai==nil then
			line(p.x,p.y,p.x+p.dx*100,p.y+p.dy*100,p.col)
		end
		
	end
end
-->8
function bounce(p)
	if (p.life==0) p.rad=15
	p.dy+=0.02
	p.col=3
	
	if p.y+p.rad>128 then
		p.y=128-p.rad
		p.dy*=-1
		
	end
	
	if (p.dy<0 and p.dy>-1) p.rad=0
end

function grav(p)
	if p.life<100 then
		dx,dy=p.x-player.x,p.y-player.y
		theta = atan2(dy,dx)
		
		p.dx-=sin(theta)*0.1
		p.dy-=cos(theta)*0.1
	else
		p.rad-=1
	end
end

function grav2(p)
	p.col=10
	if p.life<100 then
		p.rad=2
	
		dx,dy=p.x-p.tx,p.y-p.ty
		theta = atan2(dy,dx)
		
		p.dx-=sin(theta)*0.03
		p.dy-=cos(theta)*0.03
	else
		p.rad-=0.1
	end
end

function spiral(p)
	dx,dy=p.x-p.tx,p.y-p.ty
		
	if abs(dx)+abs(dy)>5 then
		p.rad=2 p.col=13
		
		theta = atan2(dy,dx)-0.05
		
		local factor = 1
		if (p.life<25) factor=25/p.life
		p.dx=cos(theta)*factor
		p.dy=-sin(theta)*factor
		
		
	else
		p.rad-=1
		
	end
end


--patterns
function blossom(x,y,rad,steps,ai)
	for i=1,steps do
		theta = i/steps
		
		shoot(x+cos(theta)*rad,y+sin(theta)*rad,ai)
	end
end

function wall(theta,steps,speed, ai)
	local x,y = 64+cos(theta)*120, 64+sin(theta)*120
	for i=2,steps do
		amount = (i/(steps-1)*2 - 1) * 100
		local nx, ny = x-sin(theta)*amount,y+cos(theta)*amount
		
		proj = shoot(nx,ny,ai)
		--proj.dx, proj.dy=-cos(theta)*speed,-sin(theta)*speed
		
	end
end

function rain(steps, ai)
	local flp = flr(rnd(2))==0 
	
	for i=0,steps do
		amount = (i/steps) * 128
		local x = amount
		if (flp) x = 128-x
		proj=shoot(x,-10-amount*2,ai)
		proj.dy=2
	end
	
	
end