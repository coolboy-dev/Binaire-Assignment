--"the zone"
--squishyam 9/9/2026 

scroll=0
timer=0
tmax=125
speed=1
d=1
c=0
char="●"
things={}
x=78
stopped=false

function _update60()
	if stopped==false then
		if (c>=3) speed=2 tmax=100
		if (c>=7) speed=3 tmax=80
		if (c>=15) speed=3.5 tmax=50 d=2
		if (c>=20) speed=4 tmax=30
		if (c>=27) char="웃"
		scroll+=speed
		if timer>=tmax then 
			timer=-35 add_coin()
		else 
			timer+=1
		end
		if (btn(0)) x-=d
		if (btn(1)) x+=d
		if (x<0) x=0
		if (x>120) x=120
		if (speed>=3) tmax=70
		if (speed>=5.5) char="웃"
		for t in all(things) do
			t.y+=speed
			if t.y>98 and t.y<116
			and t.x>=x-2 and t.x<x+8 then
				if char=="웃" then 
					stopped=true
				else 
					c+=1
					timer=0
					del(things,t)
				end
			end
			if (t.y>128) del(things,t)
		end
	end
end

function _draw()
	cls()
	if stopped==false then
		--center line
		rect(64,0,65,127,5)
		for i=-1,8 do
			local y=1+(scroll%20)+i*20
			rectfill(64,y,65,y+6,0)
		end
			--"road" outline
		rect(32,-1,96,128,5)
	end
	--car
	print("\^o1ff🐱",x,104,1)
	print("\^o1ff⬆️",x,109,1)
	--number
	if c<10 then
		print("0"..c,x,107,0)
	else
		print(c,x,107,0)
	end
	for t in all(things) do
		print(char,t.x-3,t.y-2,10)
		if stopped==true then
			pset(t.x-1,t.y-1,9)
			pset(t.x+1,t.y-1,9)
		end
	end
end

function add_coin()
	thing={
		y=-5,
		x=rnd(58)+35  
	}

	add(things,thing)
	return thing
end