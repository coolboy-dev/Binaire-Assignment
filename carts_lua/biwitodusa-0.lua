function _init()
	pal(14, 142, 1)
	pal(15, 136, 1)
	pal(5, 132, 1)
	pal(2, 129,1)
	
	frame=0
	shake=0
	score=0
	old_score=0
	hi_score=0
	
	game_state="menu"
	
	music(0)
	
	stars={}
	
	--dark stars
	for i=0,64 do
		add(stars, star:new({
			x=rnd(128),
			y=rnd(128),
			clr=1
		}))
	end
	
	--darkest stars
	for i=0,32 do
		add(stars, star:new({
			x=rnd(128),
			y=rnd(128),
			clr=2
		}))
	end
	
	--and bright ones
	for i=0,16 do
		add(stars, star:new({
			x=rnd(128),
			y=rnd(128),
			clr=12
		}))
	end
	
	--planets
	
	for i=0,0 do
		add(stars, star:new({
			x=rnd(128),
			y=rnd(128),
			clr=12,
			rad=3+rnd(10)
		}))
	end
	
	level_gen()
	
	if game_state!="menu" and not musicplayed then
		music(0)
		musicplayed=true
	end
	
	flames={}
	
	explosions={}
	
	confettis={}
	
	
end

function _update()

	frame+=1

	for human in all(humans) do
		human:update()
	end

	if game_state!="menu"  then
		game_update()
	else
		menu_update()
	end
	
end

function _draw()
	cls()

	for star in all(stars) do
		star:draw()
	end

	level_draw()
	


	if game_state!="menu" then
		game_draw()
	else
		menu_draw()
	end
	
end

function var_reset()
	shake=0
	celebrated=false

	level_gen()
	game_state="playing"
	
	player.x=63
	player.y=30
	player.velx=0
	player.vely=0.005
	player.sprite=3
	player.fuel=100
	player.maxvel=1
	player.targetvelx=0
	player.targetvely=0
	player.grav=3
	player.spdy=0
	player.oldy=0
	player.vertical_vel=.005
	player.horizontal_vel=.005
	player.exploded=false
	player.dead=false
	

	
end
-->8
player={
	x=63,
	y=30,
	velx=0,
	vely=0.005,
	sprite=3,
	fuel=100,
	maxvel=1,
	targetvelx=0,
	targetvely=0,
	grav=3,
	spdy=0,
	oldy=0,
	vertical_vel=.005,
	horizontal_vel=.005,
	exploded=false,
	dead=false,
	
	
	update=function(self)
		if game_state=="playing" or game_state=="out of fuel" then
			
			self.sprite=3
			self.oldy=self.y
			
			if btn(⬅️) then
				player:side_btn(self.vertical_vel, 0)
				sfx(0)
			elseif btn(➡️) then
				player:side_btn(-self.vertical_vel, 0)
				sfx(0)
			elseif btn(⬆️) then
				sfx(0)
				player:side_btn(0, self.horizontal_vel)
			else
				sfx(-1)
			end
			
		
			--gravity
			
			self.vely+=self.grav/1000
			if self.vely>self.grav then
				self.vely=self.grav
			end
		
		
			self.x-=lerp(self.velx, self.targetvelx, 2)
			self.y-=lerp(self.vely, self.targetvely, 2)
			
			self.spdy=abs(self.oldy-self.y)
			
		end
		
		if self.fuel==0 then
			game_state="out of fuel"
		end

		if self.dead then
			self.will_explode=true
			self.sprite=4
			if not self.exploded and self.will_explode then
				sfx(-1)
				shake=.4
				score=0
				for i=0,64 do
					sfx(2)
					add(explosions, explosion:new({
						x=self.x-5+rnd(10),
						y=self.y-5+rnd(10),
						dx=-3+rnd(6),
						dy=-3+rnd(6),
						rad=rnd(3),
						clr=7+flr(rnd(3)+.5),
						lifetime=10+rnd(20)
					}))
				end
				self.exploded=true
				self.will_explode=false
			end
		end		
		
		if game_state!="playing" then
			if btn(❘) then
				var_reset()
			end
		end

	end,
	
	side_btn=function(self, a, b)
		if self.fuel>0 then
			self.fuel-=1
			if self.targetvelx<self.maxvel then
				self.targetvelx+=a
				self.targetvely+=b
			end
			
			--flames
			for i=0,.1 do
				add(flames, flame:new({
					x=self.x+3+rnd(2),
					y=self.y+6+rnd(6),
					dx=a,
					dy=b,
					clr=8+flr(rnd(2)+.5),
					lifetime=rnd(10)
				}))
				end
			end
	end,
	
	cir_screen=function(self)
		if self.x>127 then
			self.x=-8
		end
		if self.x<-9 then
			self.x=126
		end
	end,
	
	draw=function(self)
		spr(self.sprite, self.x, self.y)
	end

}
-->8
function lerp(a,b,c)
	local result=a+c*(b-a)
	return result
end

function level_gen()
	terrain={}
	
	local rough=25
	
	
	for i=0,18 do
		terrain[i]=90+flr(rnd(rough)+.5)
	end
	
	pad_index=1+flr(rnd(16))
	
	terrain[pad_index+1] = terrain[pad_index]
	
end


function level_draw()
 for i=0, #terrain-1 do
  local x1=(i-1)*8
  local x2=i*8
  local col=14
    
  if i==pad_index then
  -- col=11
   
  end
    
  for x=x1,x2 do
   local t=(x-x1)/(x2-x1)
   local cury=flr(terrain[i] * (1 - t) + terrain[i+1] * t)
   
   --background
   line(x, cury-4, x, 127, 5)
   --actual ground
   line(x, cury, x, 127, 4)
   --foreground
   line(x, cury+4, x, 127, col)
   --drawing pad
   if i==pad_index then
   	spr(5, x, cury)
   end
   
  end
 end
end

function ground_collision()
 local p_cx=flr(player.x+4)
 
 if p_cx<0 then p_cx=0 end
 if p_cx>127 then p_cx=127 end
  
 local segment=flr(p_cx/8)+1
  
 local x1=(segment-1)*8
 local x2=segment*8
  
 local t=(p_cx-x1)/(x2-x1)
 local ground_y=flr(terrain[segment]*(1-t)+terrain[segment+1]*t)
  
 local player_bottom=player.y+8
  
 if player_bottom>=ground_y then
  player.y=ground_y-8
  player.vx=0
  player.vy=0
    
 	if segment==pad_index then
   if player.spdy<.35 then
    game_state="win"
    
    
   else
   	game_state="loose"
   	player.dead=true
   end
  else
  	game_state = "loose"
  	player.dead=true
 	end
 end
end
-->8
function game_over_txt()
	local clr=8
	
	if game_state=="win" then
		if not celebrated then
			sfx(-1)
			shake=.01
			sfx(1)
			old_score=score
			score+=50+player.fuel
			if score>old_score and score>hi_score then
				hi_score=score
			end
			for i=0,64 do
				add(confettis, confetti:new({
					x=player.x-5+rnd(10),
					y=player.y-5+rnd(10),
					dx=-1+rnd(2),
					dy=-2,
					rad=.1,
					clr=2+flr(rnd(10)+.5),
					lifetime=50
				}))
			end
			celebrated=true
		end
	clr=11
	end
	
	if game_state!="playing" then
		print(game_state, 53, 53, clr)
		print("press ❘ to play again", 20, 63, 7)
	end
end

	star={
		x=64,
		y=63,
		rad=.1,
		clr=1,
	
		new=function(self, tbl)
			tbl=tbl or {}
			setmetatable(tbl, {
				__index=self
			})
			return tbl
		end,
		
		update=function(self)
			
		end,
		
		draw=function(self)
			circfill(self.x, self.y, self.rad, self.clr)
		end
}

	flame={
		x=63,
		y=63,
		rad=.1,
		clr=9,
		dx=0,
		dy=0,
		lifetime=0,
	
		new=function(self, tbl)
			tbl=tbl or {}
			setmetatable(tbl, {
				__index=self
			})
			return tbl
		end,
			
		update=function(self)
			self.x+=self.dx*100
			self.y+=self.dy*100
			self.lifetime-=.5
			if self.lifetime<0 then
				del(flames, self)
			end
		end,
		
		draw=function(self)
			circfill(self.x, self.y, self.rad, self.clr)
		end
		
}

function fuel_bar()
	print("fuel", 4, 4, 7)

	rectfill(20,4,70,8,8)
	rectfill(20,8,70,8,15)
	rectfill(20,4,20+player.fuel/2,8,11)
	rectfill(20,8,20+player.fuel/2,8,3)
end

	explosion={
		x=0,
		y=0,
		dx=0,
		dy=0,
		clr=7,
		
		new=function(self, tbl)
			tbl=tbl or {}
			setmetatable(tbl, {
				__index=self
			})
			return tbl
		end,
			
		update=function(self)
			self.x+=self.dx
			self.y+=self.dy
			self.lifetime-=.5
			if self.lifetime<0 then
				del(explosions, self)
			end
		end,
		
		draw=function(self)
			circfill(self.x, self.y, self.rad, self.clr)
		end
}

function doshake()
	local shakex
	local shakey
	
	shakex=-4+rnd(8)
	shakey=-4+rnd(8)
	
	shakex*=shake
	shakey*=shake
	
	camera(shakex, shakey)
	
	shake*=.80
	
	if shake<=.005 then
		shake=0
	end
	
end

	confetti={
		x=0,
		y=0,
		dx=0,
		dy=0,
		clr=7,
		
		new=function(self, tbl)
			tbl=tbl or {}
			setmetatable(tbl, {
				__index=self
			})
			return tbl
		end,
			
		update=function(self)
			self.x+=self.dx
			self.y+=self.dy
			self.lifetime-=.5
			self.dy+=.1
			if self.dy>1 then
				self.dy=1
			end
			
			if self.lifetime<0 then
				del(confettis, self)
			end
			
		end,
		
		draw=function(self)
			circfill(self.x, self.y, self.rad, self.clr)
		end
		
}
-->8
function game_update()
	player:update()
	ground_collision()
	player:cir_screen()
	for star in all(stars) do
		star:update()
	end
	for flame in all(flames) do
		flame:update()
	end
	
	for explosion in all(explosions) do
		explosion:update()
	end
	
	for confetti in all(confettis) do
		confetti:update()
	end
end

function game_draw()
	doshake()
	
	player:draw()
--	print(player.spdy)
	
	for flame in all(flames) do
		flame:draw()
	end
	
	for explosion in all(explosions) do
		explosion:draw()
	end
	
	for confetti in all(confettis) do
		confetti:draw()
	end
	
	fuel_bar()
	
	print("score:", 86, 4, 7)
	print(score, 110, 4, 7)
		print("hi score:", 74, 10, 7)
	print(hi_score, 110, 10, 7)
	
	if player.spdy>.35 then
		print("too fast!", 4, 10, 8)
	end
	
	game_over_txt()
end

function menu_draw()

	for human in all(humans) do
		human:draw()
	end
	
	local signx
	local signy
	
	signx=41
	signy=58
	--sign
	rectfill(signx, signy, 93, 72, 6)
	--upper left nail
	rectfill(signx+2, signy+2, 44, 61, 13)
	circfill(signx+3, signy+2, .1, 7)
	--lower left nail
	rectfill(signx+2, signy+11, 44, 70, 13)
	circfill(signx+3, signy+11, .1, 7)
	--upper right nail
	rectfill(signx+49, 60, signy+33, 61, 13)
	circfill(signx+50, 60, .1, 7)
	--lower right nail
	rectfill(signx+49, 69, signy+33, 70, 13)
	circfill(signx+50, 69, .1, 7)
	
		--spr(3, 63, 30)
	
	--text
	print("mars lander", signx+5, 63, 15)
	
	print("press any btn to start", signx-20, 75, 7)
	
end

function menu_update()
	if btnp(❘) or btnp(🅾️) or btnp(⬆️) or btnp(⬇️) or btnp(⬅️) or btnp(➡️) then
		game_state="playing"
	end
end