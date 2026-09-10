--initializing

function _init() menu_init() end

function game_init()

	_update=game_update
	_draw=game_draw
	cls()

	player={
	 sp=1,
		x=63,
		y=100,
		f=false, --flip spr--
	}
	
	dtrail={
	 x=player.x,
	 xf=player.x,
		sp=17,
		f=false, --flip spr--
	}
	
	cart={
 	t=0,
 	ttext=0,
 	ttextend="/10",
 	inv=0,
 	sp=10,
 	ding=false, --checkout sound--
 	reg=false, --register alarm--
	}

	
 score=0
 misses=0
 miss_sc="♥♥♥♥"
 dash_m=false
 mtimer=1 --powerup msg timer--
 
 dbtimer=1 --db time countdown--
 m_dbtimer=1 --db time msg timer--
 
 reset_coin()
 
 
end




function over_init()
 _update=over_update
 _draw=over_draw
end


function reset_coin()
	cx=rnd(60)+30
 cy=-8
 if score>=11 then
 cx=rnd(112)
 end
end



function wall_bounds()
	if player.x<=0 then player.x=0 end
	if player.x>=112 then player.x=112 end
end
-->8
--main update and draw

function menu_init()

	_update=menu_update
	_draw=menu_draw
	music(0)
	
end

function game_update()


	--coin drop--
	if dbtimer<=2400 then
 	cy+=2
 elseif dbtimer>2400 then --spd up--
  cy+=2.8
	end
	
	--double speed--
	
 dbtimer+=1


 --wall bounds--
 
	wall_bounds()

	--player update--
	
	if btn(➡️) then
		player.x+=1
		dtrail.x+=4
		player.f=false
	elseif btn(⬅️) then
		player.x-=1
		dtrail.x-=4
		player.f=true
	end
	
	
	--speed up--
	
	if score>=10 and btn(❘) and btn(➡️) then
	 player.x+=3
	 dtrail.x=player.x-9
	elseif score>=10 and btn(❘) and btn(⬅️) then
		player.x-=3
		dtrail.xf=player.x+9
	else
		dtrail.x=player.x
	end
	
	--cart full check--	
	if cart.inv>=10 then
		cart.t=1
		cart.ttext="full"
		cart.ttextend=""
	end
	
	if cart.t==1 then
	 if cart.inv==10 then
	 sfx(02)
		end
	end
	

	
	
	--cart clear check--
	if cart.inv>0 and abs(player.x)>=112 then
	 sfx(03) --checkout sound--
		cart.ding=true
		cart.t=0
		cart.ttext=0
		cart.ttextend="/10"
		cart.inv=0
		cart.reg=false
--	elseif cart.t==0 then
--		cart.ding=false
--		cart.reg=false
	end
	
	--checkout sound--
--	if cart.ding==true and cart.sp~=10 then

	
	--cash register spr--
	if cart.t==1 and cart.sp<12.5  then
		cart.sp+=0.5
		player.sp=16 --cart full spr--
	elseif cart.t==1 and cart.sp>=12.5 then
		cart.sp=11
		player.sp=16
	elseif cart.t==0 then
		cart.sp=10
		player.sp=1
	end

	--catch the coin--
	if abs(player.x-cx)<4 and abs(player.y-cy)<4 and cart.inv<10
		then
		reset_coin()
		sfx(04)
		score+=1
		cart.inv+=1
		cart.ttext+=1
	end
	
	--coin out of bounds--
	if cy>=124 then
		reset_coin()
		misses+=1
		sfx(05)
	end
	
	if misses==1 then
		miss_sc="♥♥♥"
	elseif misses==2 then
	 miss_sc="♥♥"
	elseif misses==3 then
		miss_sc="♥"	
	end
	

	
	--game over--
	if misses>3 or cart.t>1 then	
		cy=-8
		miss_sc=""
		over_init()
		music(10)
	end


		
end





-->8
--updates

function menu_update()

 
 if btnp(❘) then
  game_init()
  sfx(00)
 end

end


function over_update()
	
	if btnp(🅾️) then
	 game_init()	
	 sfx(00)
	 music(0)
	end
end

-->8
--draws

function menu_draw()
	cls(10)
	print("7-eleven rush",38,40,3)
	print("press ❘ to start",30,60,8)
end

function game_draw()
	cls()
	map(1)
	spr(player.sp,player.x,player.y,1,1,player.f)
	spr(2,cx,cy)
	spr(cart.sp,120,88)
	print("soda:"..score,2,113,10)
	print("cart:"..cart.ttext..cart.ttextend,2,120,10)
 print("lives:",95,113,10)
 print(miss_sc,94,120,10)
 
  --dash trail animation--
	if dtrail.sp<23 and btn(❘) and btn(➡️) and dash_m==true then
		spr(dtrail.sp,dtrail.x,player.y,1,1,dtrail.f)
		dtrail.sp+=0.5
		dtrail.f=false
	elseif dtrail.sp<23 and btn(❘) and btn(⬅️) and dash_m==true then
		spr(dtrail.sp,dtrail.xf,player.y,1,1,dtrail.f)
	 dtrail.sp+=0.5
	 dtrail.f=true
	else
		dtrail.sp=17
	end
	
	if dash_m==true and btnp(❘) then
  sfx(01)
	end
	
	
	
	--text for powerup--
	if score>=10 then
	 dash_m=true
	end
	
	if dash_m==true and mtimer<=120 then
		print("power up: press ❘ to dash",12,20,8)
	 mtimer+=1		
	 
	end
	
	if dbtimer>2400 and m_dbtimer<=45 then
	 print("go faster!",40,20,8)
	 m_dbtimer+=1
	 music(4)
	end
 
end

function over_draw()
	rectfill(16,56,110,72,10)
	print("game over!",45,58,8)
 print("press 🅾️ to restart",26,66,8)

end