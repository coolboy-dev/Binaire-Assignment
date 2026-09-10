function _init()
 state="start"
	plrset()
	ien()
	i_powerups()
	i_flame()
	i_boom()
	i_stars()
end 

function _update()
 if state=="play" then
	move()
	u_shoot()
	uen()
	u_amo()
	u_enemy_bullets()
	u_powerups()
	u_flame()
	u_boom()
	u_stars()
	elseif state=="start" then
		if btnp(❘) then
		music(1)
		state="play"
		end
	end
	
	if kills==30 and state=="play" then 
	state="win"
	music(-1)
	sfx(10)
	end
	
	if plr.hp==0 and state=="play" then
	state="lose"
	music(-1)
	sfx(9)
	end

end

function _draw()

  cls()
  
  if state=="play" then
  map()
  
  d_stars()
  spr(1,plr.x,plr.y,2,2)
  d_enemy_bullets()
  d_boom()
  d_shoot()
  den()
  d_flame()
  d_powerups()
  d_ui()
  
  
  print("kills:"..kills,95,6,10)
  
  elseif state=="start" then
  spr(34,36,30,7,2)
  
		print("press ❘ to start",31,60,8)
		print("❘ to shoot",31,70,9)
		print("⬅️⬆️➡️⬇️ to move",31,80,9)
		elseif state=="win" then
		spr(10,42,50,6,2)
		elseif state=="lose" then 
		spr(59,44,50,5,1)
		end
end

-->8

function plrset()

	plr={x=55,y=100,hp=3,max_hp=3,inv=0}
		lx=plr.x+8
		ly=plr.y
		
		amo=5
		max_amo=5

		amo_timer=0
		amo_delay=40
		
		shot_timer=0
		shot=false
end

function move()

	if plr.inv>0 then
		plr.inv-=1
	end

		if btn(➡️) then
			if plr.x<112 then plr.x+=1
			end
		end
  if btn(⬅️) then
  	if plr.x>0 then plr.x-=1 
  	end
  end
  if btn(⬆️) then
  	if plr.y>0 then plr.y-=1
  	end 
  end
  if btn(⬇️) then
  	if plr.y<112 then plr.y+=1
  	end 
  end
  
 	lx=plr.x+8
		ly=plr.y
    
end


function u_shoot()

	shot=false

	if amo>0 and btnp(❘) then

		amo-=1
		shot=true
		shot_timer=3
		sfx(1)

	end

	if shot_timer>0 then
		shot_timer-=1
	end


end

function d_shoot()

	if shot_timer>0 then
	if btnp(❘) then
	line (lx,ly,lx,0,9)
	end
	end
end


function u_amo()

	if amo<max_amo then

		amo_timer+=1

		if amo_timer>=amo_delay then
			amo+=1
			amo_timer=0
		end

	else

		amo_timer=0

	end

end
-->8

function ien()

	enemies={}
	enemy_bullets={}
	spawn_timer=0
	spawn_delay=80
	enemies_spawned=0
	max_enemies=30

	kills=0
	
	
	
end

function uen()

spawn_timer+=1

	if spawn_timer>=spawn_delay
	and enemies_spawned<max_enemies then
	add(enemies,{x=rnd(120),y=0,life=100,shot_timer=10+rnd(10)})
	enemies_spawned+=1
	spawn_timer=0
	end
	
for e in all(enemies) do

if e.x < plr.x+6 then
 e.x+=0.5
end

if e.x > plr.x+6 then
 e.x-=0.5
end

if e.y < plr.y+6 then
 e.y+=0.5
end

if e.y > plr.y+6 then
 e.y-=0.5
end

e.shot_timer-=1

	if e.shot_timer<=0 then

		enemy_shoot(e)

		e.shot_timer=40+rnd(20)

	end
 

end

push_enemies()


	if shot then
	 for e in all(enemies) do
			if abs(e.x+4-lx)<4 then
		 e.life-=50
		 
			end
		end
	end
	
	for e in all(enemies) do
  if e.life<=0 then
  	explosions(e.x,e.y)
  	kills+=1
  	if kills%5==0 then
			spawn_powerup(e.x,e.y)
			end
   del(enemies,e)
     
  end
	end
	
	
	for e in all(enemies) do
 	if col(plr,e) and plr.inv<=0 then
  	sfx(2)
  	plr.hp-=1
  	plr.inv=30
 	end
	end
end

function den()

	for e in all(enemies) do
	
		if e.life>50  then
			spr(3,e.x,e.y)
		
		else 
			spr(4,e.x,e.y)
			
		end
		
	end
	
	
end



function col(a,b)
	 if a.y>b.y+7 then return false end
	 if b.y>a.y+7 then return false end
	 if a.x>b.x+7 then return false end
	 if b.x>a.x+7 then return false end
 return true
end

function push_enemies()

 for a in all(enemies) do
  for b in all(enemies) do

   if a!=b and col(a,b) then
 		if a.x < b.x then
    a.x-=0.5
   else
    a.x+=0.5
   end

   if a.y < b.y then
    a.y-=0.5
   else
    a.y+=0.5
   end
		 end

  end
 end

end

function enemy_shoot(e)

	local dx=plr.x+8-(e.x+4)
	local dy=plr.y+8-(e.y+4)

	local dist=sqrt(dx*dx+dy*dy)

	if dist>0 then

		local speed=1.5

		add(enemy_bullets,{
			x=e.x+4,
			y=e.y+4,
			dx=dx/dist*speed,
			dy=dy/dist*speed
		})

	end

end

function u_enemy_bullets()

	for b in all(enemy_bullets) do

		b.x+=b.dx
		b.y+=b.dy

		
		if b.x<0 or b.x>127
		or b.y<0 or b.y>127 then

			del(enemy_bullets,b)

		else

			
			if b.x>plr.x
			and b.x<plr.x+16
			and b.y>plr.y
			and b.y<plr.y+16 then

				if plr.inv<=0 then
					plr.hp-=1
					plr.inv=30
					sfx(2)
				end

				del(enemy_bullets,b)

			end

		end

	end

end

function d_enemy_bullets()

	for b in all(enemy_bullets) do
		circfill(b.x,b.y,1,8)
	end

end
-->8
function i_flame()
 parts={}
 
 
end

function u_flame()
 
	add(parts,{x=plr.x+7+rnd(3),y=plr.y+13+rnd(1),r=rnd(3),c=10,l=6,speed=0.5+rnd(2)})
 
 
 for p in all(parts) do
 	p.y=p.y+p.speed
 	p.l-=0.7
 	p.r-=0.1
 	if p.l<0.5 then
 	 p.c=9
 	end
 	if p.l<0 then 
 		del(parts,p)
 	end
 end

end

function d_flame()
	for p in all(parts) do
	circfill(p.x,p.y,p.r,p.c)
	end

end


function i_smoke()
 smoke={}
 
 
end

function u_smoke()
 
	add(smoke,{x=plr.x+7+rnd(3),y=plr.y+13+rnd(1),r=rnd(3),c=10,l=6,speed=0.5+rnd(2)})
 
 
 for p in all(parts) do
 	p.y=p.y+p.speed
 	p.l-=0.7
 	p.r-=0.1
 	if p.l<0.5 then
 	 p.c=9
 	end
 	if p.l<0 then 
 		del(parts,p)
 	end
 end

end

function d_smoke()
	for p in all(parts) do
	circfill(p.x,p.y,p.r,p.c)
	end

end


-->8
function i_boom()
 boom={}
end

function explosions(x,y)
for b=1,8 do 
add(boom,{x=x+4,y=y+4,dx=rnd(2)-1,dy=rnd(2)-1,r=rnd(3),c=10,life=8,speed=0.5})
end

end

function u_boom()

for b in all(boom) do
		sfx(3)
	 b.x+=b.dx
  b.y+=b.dy
  
  b.r-=0.1
  
		b.life-=0.7
		if b.life<0.8 then
 	 b.c=9
 	end
		if b.life<=0 then
			del(boom,b)
		end
	end

end

function d_boom()
for b in all(boom) do
	circfill(b.x,b.y,b.r,b.c)
	end

end




-->8
function d_ui()


--hearts--
	for i=1,plr.max_hp do
		spr(20,2+(i-1)*9,2)
	end

	for i=1,plr.hp do
		spr(19,2+(i-1)*9,2)
	end
	
--ammo--
	for i=1,max_amo do
		spr(22,2+(i-1)*9,12)
	end

	for i=1,amo do
		spr(21,2+(i-1)*9,12)
	end

end
-->8
function i_stars()

	stars={}
	local gap=12

	for y=0,127,gap do
		for x=0,127,gap do
		
		add(stars,{x=rnd(128),y=rnd(128),spd=0.1+rnd(0.5),size=flr(rnd(2))})
	
 end
 end
end

function u_stars()

	for s in all(stars) do

		s.y+=s.spd

		if s.y>127 then
			s.y=-1
			s.x=rnd(128)
			s.spd=0.5+rnd(1.5)
		end
		
		if s.y>127 then
			del(stars,s)
		end

	end

end

function d_stars()

	for s in all(stars) do
		if  s.spd>0.8 then
		pset(s.x,s.y,13)
		else
		pset(s.x,s.y,1)
		end
	end

end
-->8
function i_powerups()

	powerups={}

end

function spawn_powerup(x,y)

	local kind="hp"

	if rnd(1)<0.5 then
		kind="ammo"
	end

	add(powerups,{x=x,y=y,kind=kind,spd=0.5})

end

function u_powerups()

	for p in all(powerups) do
	
	p.y=p.y+p.spd

		if player_powerup_col(p) then

			if p.kind=="hp" then
				plr.hp=min(plr.hp+1,plr.max_hp)
			end

			if p.kind=="ammo" then
				amo=min(amo+5,max_amo)
			end

			del(powerups,p)

		end

	end

end



function d_powerups()

	for p in all(powerups) do

		if p.kind=="hp" then
			spr(48,p.x,p.y,2,1)
		end

		if p.kind=="ammo" then
			spr(32,p.x,p.y)
		end

	end

end

function player_powerup_col(p)

	if plr.x>p.x+7 then return false end
	if p.x>plr.x+15 then return false end

	if plr.y>p.y+7 then return false end
	if p.y>plr.y+15 then return false end

	return true

end