-- berliner luft
-- by moods plateau

-- main

function _init()

	automatic = true
	
	music(0)
	beatcol = {8,10,11,12}
	b = 0
	lastbeattick = -1

 --scroller_init
 scrolltext = "this is fine! moods plateau "..
 		"prepares you for the..." .. 
 		"apocalypso at deadline 2026 in berlin!! " ..
 		"october 2-4 at orwohaus, frank-zappa-strasse 19. " ..
 		"greetings fly out to computerkunst ev, rabenauge, gnumpf-posse, trbl and everybody at evoke! " ..
 		"come to deadline! ..scroller restarts..        "
 		
 
 
 sti = 1 --scrolltextindex
 scrollchars = {}
 zeit = 0
 t=0
	customfont = 1
 --end_scroller_init
	
	--fenster...
	winx = -2
	winy = -5
	windelx = 25
	windely = 45

	--zug
	train = {
		x = 300,
		hoehe = 6,
		breite = 295,
		tiefe = 66
	}

	karren={} --hier kommen die autoobj rein
	leute={}

end

function _update()
	
	--scroller_update
	update_scroller()
 zeit+=1
 t+=0.01
 --end scroller update
	
	
		
	if automatic then
		train.x -=10
		if btnp(❘) then
		 automatic = false 
	 end
	else
		if btn(⬅️) then
			train.x -=2
		end
		if btn(➡️) then
			train.x +=2
		end
		if btnp(❘) then
		 automatic = true
	 end
	end
	
	if train.x < -3500 then
	 train.x = 300
	end

	--neue autos erzeugen
 if rnd(1)<0.03 then
  add(karren,init_karre())
 end
	--alle autos bewegen
 for k in all(karren) do
  update_karre(k)
  --entfernen, wenn rechts raus
  if k.d == 0 then
  	if k.x<-50 then
   	del(karren,k)
  	end
 	elseif k.d == 1 then
 		if k.x>128 then
   	del(karren,k)
  	end
 	end
 end
 
 	--neue leute erzeugen
 if rnd(1)<0.02 then
  add(leute,init_leut())
 end
	--alle leute bewegen
 for l in all(leute) do
  update_leut(l)
  --entfernen, wenn rechts raus
  if l.x>128 then
   del(leute,l)
  elseif l.x < 60 then
   del(leute,l)
  end
 end
	
end --ende von _update()

function _draw()
	
 cls(12)
	
	
	
 layer_plattenbau()
 layer_telespargel()
	print("mds",92,19,7)
 layer_colhouses()
 
 for l in all(leute) do
  draw_leut(l)
 end
 
 layer_house()
 draw_lampen()

 if train.x > -1000 then
  draw_train(train.x,train.hoehe,train.breite,train.tiefe)
  draw_train(train.x+300,train.hoehe,train.breite,train.tiefe)
  draw_train(train.x+600,train.hoehe,train.breite,train.tiefe)
 end
 --print (train.x,110,0)
 
	--autos von rechts nach links,
	--hinter den pfeilern
 for k in all(karren) do
  if k.d == 0 then
  	draw_karre(k)
  end
 end

	layer_metro()

	--autos links nach rechts
	--vor den pfeilern
 for k in all(karren) do
 	if k.d == 1 then
  	draw_karre(k)
  end
 end
	
	if automatic == false then
		print ("⬅️ u-drive ➡️",39,60)
	end

	

end

----------------
-- funktionen --
----------------



function layer_telespargel()
	line(97,0,97,9,6)           --antenne
    rectfill(95,9,98,127,6)     --spargelstange
    line(99,9,99,13,6)          --oben muss 1 breiter
    circfill(97,21,9,6)         --die Kugel
    rectfill(94,32,99,33,6)     --plattform  
    line(94,70,94,94,6)         --unten ist 1 breiter
    rectfill(92,83,99,94,6)     --dito
end



function layer_plattenbau()

	-- linke platte
	rectfill (60,75,94,100,6)
	local x = 76
	local y = 77
	for j = 0,8 do
		for i = 0,5 do 
			line (x+3*i,y+2*j,x+3*i+1,y+2*j,0)
		end
	end
	
	--rechteplatte
	rectfill (107,78,128,100,6)
		local x = 109
		local y = 80
		for j = 0,5 do
			for i = 0,3 do
				line (x+3*i, y+j*2, x+3*i+1, y+j*2, 0)
				line (x+3*i+2, y+j*2, x+3*i+1+3, y+j*2, 5)
			end
		end
			
	
	-- mittelplatte
	rectfill (94,60,106,100,13)
		local x = 95
		local y = 71
		for j = 0,6 do
			for i = 0,2 do
				line (x+4*i,y+j*3 ,x+2+4*i,y+j*3,5)
				line (x+4*i,y+1+j*3,x+2+4*i,y+1+j*3,2)
				pset (x+12,y+1+j*3,4)
			end
		end
end
	



function draw_train(x,h,b,t)
 
 rectfill(x,h,x+b,t,10) --der gelbe kasten
 
 local tuerbreite = 19
 local fensterbreite = 37
 local fensterbreite_klein = 20
 local abstand = 10
 local t1 = 4
 local t2 = t1+tuerbreite+abstand
 local t3 = t2+tuerbreite
 local f1 = t3+tuerbreite+abstand
 local t4 = f1+fensterbreite+abstand
 local t5 = t4+tuerbreite
 local f2 = t5+tuerbreite+abstand
 local t6 = f2+fensterbreite+abstand
 local t7 = t6+tuerbreite
 local f3 = t7+tuerbreite+abstand
 
 local tueren = {t1,t2,t3,t4,t5,t6,t7} -- startpunkte der tueren vom zuganfang aus gesehen
 for i in all(tueren) do
  rect (x+i,h+3,x+i+tuerbreite,t,0) --rahmen
  rectfill(x+i+2,h+5,x+i+tuerbreite-2,h+25,0) --tuerfenster
 end
 
 local fenster = {f1,f2}
 for i in all(fenster) do
  rectfill(x+i+2,h+5,x+i+fensterbreite,h+25,0) --grosses fenster
 end
 
 local fenster_back = f3
 --for i in all(fenster_back) do
 rectfill(x+f3+2,h+5,x+f3+fensterbreite_klein,h+25,0) --kleines fenster hinten
 
end

function layer_colhouses()

		--gen_colhouse(75,89,3)
		--gen_colhouse(94,89,5)	
		gen_colhouse(68,99,9)	
		gen_colhouse(87,102,5)
		gen_colhouse(106,99,14)
		--gen_colhouse(10,99,5)

end

function gen_colhouse(x,y,c)
	rectfill(x,y,x+18,128,c)
	rectfill(x,y-7,x+18,y-1,2)
	spr(1,x,y-7)
	spr(1,x+6,y-7)
	spr(1,x+12,y-7)
	--fenster
	rectfill(x+3,y+3,x+15,y+23,0)
	line(x+5,y+3,x+5,128,c)
	line(x+13,y+3,x+13,128,c)
	rectfill(x+8,y+3,x+10,128,c)
	rectfill(x+3,y+12,x+15,y+14,c)
	line(x,y+7,x+15,y+7,c)
	line(x,y+19,x+15,y+19,c)
	
end

function layer_metro()
	th = 35 --hoehe gelaender
	rectfill(0,th,128,th+1,3)
	rectfill(0,58,128,65,3)
	--stangen
	x=1
	for a=0,25 do
		line(x+5*a,th+2,x+5*a,57,3)
	end
	
	--unterbau
	rectfill(0,66,128,69,1)
	saeule(-11)
	saeule(53)
	saeule(117)
	
end

function saeule(x)
	rectfill(x,70,x+14,77,1)
	rectfill(x+4,78,x+10,128,1)
end

function layer_house()

	rectfill(0,0,74,128,15)
	
	rect(-1,-1,74,128,7)
	line(0,20,73,20,4)
	rectfill(0,21,74,22,7)
	line(0,23,73,23,6)
	line(0,73,73,73,7)

	farbe()

	for j=0,1 do
		for i=0,2 do 
			windows(winx+windelx*i,winy+windely*j,24,14)
		end
	end
	
	--shoptuer
	rectfill(-1,91,12,128,7)
	rectfill(0,93,10,128,0)
	rectfill(-1,100,10,101,7)	

	--shopfenster
	rectfill(17,91,69,126,7)
	rectfill(19,93,67,125,0)
	
	--text tests
	for i=0,5 do
		 spr(80+i,3+i*8,80)
	end
			spr(86,49,80)
			spr(86,54,80)
			spr(87,62,80)

	--print2("geil!",20,100)
	--print(ord("z"),115,1,0) --hilfsanzeige oben rechts

	--scrolltext
	clip(22,91,43,125)
	scrollimolli()
	clip()

end

	

function windows(x,y,h,b)
	rect(x,y,x+b,y+h,7)
	rectfill(x+1,y+1,x+b-1,y+h-1,0)						
	line(x+b/2,y,x+b/2,y+h,7)
	line(x,y+h/2,x+b,y+h/2,7)
end

function farbe()
	x = -1

	for i = 0,6 do
		spr(2,x+i*10,24)	
		spr(2,x+i*10+5,23,1,1,true,true)
		spr(2,x+i*10+8,24,1,1,true,false)
	end

end

-->8
function scrollimolli()
	for c in all(scrollchars) do
 	draw_char(c)
 end
	print(sin(t),1,1)
end

function init_char(sti)
	local c={}
    c.nr = scrolltext[sti]
    c.x = 100 --start eines buchstabens
    c.y = 108
    return c
end

function draw_char(c)	   
  if customfont == 1 then
  	write(c.nr,c.x,c.y)
  else
	  print(c.nr,c.x,c.y)
	 end
end

function update_char(c)
    c.x-= 1
   	c.y = c.y+sin((c.x)/12)*1.5
end

function update_scroller()
-- neue chars ggf. erzeugen und dann immer alle bewegen
    if zeit%10==0 then --1x pro sekunde then
        zeit=0
        add(scrollchars,init_char(sti))
        sti+=1
        if sti > #scrolltext then
            sti = 1
        end
    end
    
    for c in all(scrollchars) do
        update_char(c)
        --entfernen, wenn links raus
        if c.x<-5 then
   	        del(scrollchars,c)
        end
    end   
end


function write(txt, x, y)
 for i=1,#txt do
     local c = sub(txt, i)
     local spr_id = asciiconv(c)
     spr(spr_id,x+(i-1)*9,y)
 end
end

function asciiconv(c)
	--hier werden die buchstaben 
	--in asciicodes konvertiert
	--sprite offsets
	local buchoff = 36
	local numoff = 3
	--die konvertierung des
	--aktuellen char in ascii
	local x = ord(c) 
	if x >= 97 and x <= 122 then --buchstaben (klein! daher 97 (=a, 122=z)
		return x-97+buchoff -- offset, wo im spritesheet buchst anfangen
	elseif x >= 32 and x<=64 then --von leerzeichen (32) bis "at" (64)
		return x-32+numoff
	end
end
-->8

-->8

-->8
--karren

function init_karre()
	local k={}
 k.d = flr(rnd(2))
	if k.d == 0 then
		k.x = 129 --start
		k.y =	113+rnd(2)  --hoehe
	else
		k.x = -50 --start
		k.y =	114+rnd(2)  --hoehe
	end
		
	k.s = 4+rnd(2) --speed
	k.c = 8+flr(rnd(8)) --color
	return k
end

function draw_karre(k)	 
  
  pal(1,k.c)
 	if k.d == 0 then
 		spr(128,k.x,k.y,7,2,1)
 	else
 		sspr(0,64,56,16,k.x,k.y,62,18,false,false)
 	end
		pal()
end

function update_karre(k)
	if k.d == 0 then
		k.x-=k.s
	else
		k.x+=k.s
	end
end







-->8
--leute

function init_leut()
	local l={}
	l.d = flr(rnd(2))
	l.x = 60+l.d*68 --x-start
	l.y = 120 --hoehe
	l.s = 0.1+rnd(1)*0.2 --speed
	--color=0, alle silhouette
	l.step = 0
	l.frame = 112
	return l
end

function draw_leut(l)
	pal(7,0)
	if l.d == 0 then
		spr(l.frame,l.x,l.y)
	else
		spr(l.frame,l.x,l.y,1,1,1)
	end
	pal()
end

function update_leut(l)
	if l.d == 0 then
		l.x+=l.s
	else
			l.x-=l.s
	end
 l.step+=1
 if(l.step%3==0) l.frame+=1
 if(l.frame>116) l.frame=112
 if l.step == 100 then
 	l.step = 0
 end
end
-->8
-- lampen


function draw_lampen()
 -- t = ticks
 t = flr((stat(56)/14)) --14 sind die eingestellten ticks...meh
 
 if t%8==0 and t!=lastbeattick	then
 	lastbeattick = t
		b+=1
	end

	for i = 0,23 do
		pset(20+i*2,94,i-b)
		pset(20+i*2,124,i+b)
	end
	for i = 0,13 do
		pset(20,96+i*2,i+13+b)
		pset(66,96+i*2,i-b)
	end

end