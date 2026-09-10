

function _init()
	mode="title"
	mapsize=512
	
	px=64
	py=64
	rad=10
	meter=17
	mcol=2
	mbcol=1
	mline=20
	bedx=0
	bedy=0
	csfx=false
	
	interacting=false
	itime=0
	hungry=false
	
	ctimer=0
	timetimer=0
	
	ti=0
	
end

function _update60()
	if mode=="title" then
		if (btnp(5)) music(0) mode="game"
	elseif mode=="game" then
	ti+=1
		--movement
		local m=0.5
		if (btn(0)) px-=m
		if (btn(1)) px+=m
		if (btn(2)) py-=m
		if (btn(3)) py+=m
		--map wrap
		local mmax=512
		if (px<=0) px=mmax
		if (py<=0) py=mmax
		if (px>mmax) px=0.5
		if (py>mmax) py=0.5
		--interact
		if btnp(5) then
			if interacting==false then
				if meter==20 then
					music(-1) sfx(-1) 
					interacting=true 
					sfx(7) timetimer=time()
					mode="cutscene"
					
				else
					sfx(1) interacting=true
				end
			end 
		end
		--meter debug
		--if (btn(4)) meter-=1
		--if (btn(4)) bed(px/8\1,py/8\1)
		
		if interacting==true then
			if itime<60 then
				itime+=1
			else
				interacting=false
				itime=0
			end
		end
		if meter<=0 then
			meter=0
		elseif meter<10 then
			if (hungry==false) music(2) hungry=true spawnbed()
			if interacting==false then
			 meter-=0.01 mbcol=6
			else
				mbcol=1
			end
		elseif meter<21 then
			meter-=0.0025
		end
		if hungry==true 
		and fget(mget(px/8\1,py/8\1))==1
		and interacting==true then
			meter+=0.05 mbcol=11
		end
		if hungry==true and meter>19 then
			meter=20
			--if interacting==false and btnp(5) then
				--music(-1) sfx(-1) mode="cutscene"
			--end
		end
	elseif mode=="cutscene" then
		ctimer=time()-timetimer
		if (ctimer>20) sfx(-1) mode="end"
		if btnp(5) then
			if interacting==false then
				sfx(7) interacting=true
			end 
		end
		if interacting==true then
			if itime<60 then
				itime+=1
			else
				interacting=false
				itime=0
			end
		end
	elseif mode=="wait" then
		ctimer=time()-timetimer
		if (ctimer<21) mode="end"
	elseif mode=="end" then
		
	end
end

function _draw()
	if mode=="title" then
		cls(0)
		pal(0,false)
		rectfill(0,0,127,127,0)
		print("\"shadow\"\nby squishyam\n\ngame poem jam sept. 2026\n\nmove with arrow keys\ninteract with (x)\n\npress (x) to begin game",10,35,9)
	elseif mode=="game" then
		local coff=32
		poke(0x5f2c,3)
		cls()
		camera(px-coff,py-coff,py)
		draw_map()
		if (hungry==true) line(px,py,(bedx*8)+8,(bedy*8)+16,mcol)
		draw_player(px,py)
		--print(meter,px,py,8)
		--[[
		print(fget(mget(px/8\1,py/8\1)),px,py,8)
		print(meter,px,py,8)
		print(px/8\1,px,py,8)
		print(py/8\1)
		print(bedx)
		print(bedy)
		--[[
		print(px/8\1,px,py,8)
		print(py/8\1)
		--]]
		camera()
		--change meter color
		if stat(50)%2==0 then mcol=8
		else mcol=2 end
		--draw meter/line when hungry
		if (hungry==true) draw_meter()
		--
		--pset(px,py,7)
		--]]
	elseif mode=="cutscene" then
		poke(0x5f2c,0)
		cls(9)
		palt(0,false)
		palt(11,true)
		spr(10,56,48,2,4)
		
		local tx=24
		local ty=30
		
		if ctimer>8 then 
			spr(46,56,48,2,2)
			if (ctimer<8.1) csfx=true
		end
		if ctimer>11 then
			print("good morning, shadow.",tx,ty,0)
			if (ctimer<11.1) csfx=true

		end
		if ctimer>15 then
			print("time for breakfast?")
			if (ctimer<15.1) csfx=true
		end
		if interacting==true then
			spr(3,54,58,2,2)
		else
			spr(1,54,58,2,2)
		end
		if (csfx==true) sfx(9) csfx=false
		--print(ctimer)
	elseif mode=="end" then
		cls()
		pal()
		pal(11,true)
		if btn(5) then
			spr(35,56,80,2,2)
		else
			spr(33,56,80,2,2)
		end
		spr(21,57,92,2,2)
		print("fin",59,64,7)
		
	end
	--[[
	line(0,64,128,64,1)
	rect(0,0,127,127,1)
	--]]
end

function draw_map()
	for y=-1,1 do
		for x=-1,1 do
			map(0,0,x*mapsize,y*mapsize,64,64)
		end
	end
end

function draw_meter()
	--[
	local m=32 --middle of screen
	local w=10 --meter width
	local b=63 --bottom of screen
	local h=3 --meter height
	if mline>1 then
		if interacting==true then
			mline-=0.25
		else
			mline-=1
		end
	elseif mline<=1 then
		mline=20
	end
	--inner bg
	rectfill(m-w,b,m+w,b-h,0)
	--emphasis line
	line((m-w)+mline,b,(m-w)+mline,b-h,mbcol)
	--inner fill
	rectfill(m-w,b-1,m-w+(meter),b-h,mcol)
	--outline
	rect(m-w,b,m+w,b-h,mbcol)
	print("(x)",m-5,b-h-6,mbcol)
	--]]
end

function draw_player(x,y)
	--shadow color
	local mcol=0
	--update circle radius
	rad=11+sin(t()/4)*3.1
	local ecol=7
	--switch fillp() every frame
	if ti%2==0 then
		fp=(0xa5a5.8) ecol=10
	else
		fp=(0x5a5a.8) ecol=8
	end
	--draw echo
	fillp(fp)
	--draw shadow
	circfill(x,y,rad,mcol)
	fillp()
	circ(x,y,itime,5)
	--draw solid circle
	circfill(x,y,rad/1.5,mcol)
	--[[
	--draw eyes
	pal(10,ecol)
		spr(5,px-3,py-2)
	pal()
	--]]
end

function bed(x,y)
	mset(x,y,10)
	mset(x+1,y,11)
	mset(x,y+1,26)
	mset(x+1,y+1,27)
	mset(x,y+2,42)
	mset(x+1,y+2,43)
	mset(x,y+3,58)
	mset(x+1,y+3,59)
end

function spawnbed()
	local p=256
	local x=px/8\1
	local y=py/8\1
	if px<p and py<p then
		bedx=x+32 bedy=y+32
	elseif px<p and py>p then
		bedx=x+32 bedy=y-32
	elseif px>p and py>p then
		bedx=x-32 bedy=y-32
	elseif px>p and py<p then
		bedx=x-32 bedy=y+32
	end
	bed(bedx,bedy)
end
