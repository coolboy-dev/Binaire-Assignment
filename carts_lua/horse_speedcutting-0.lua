function _init()
	cartdata("horse_speedcutting")
	_newrun()
	_reset()
	runcost=0
	quittime=0
	
	--train
	compnr=0
	tectrain=0
	statrain=0
	spdtrain=0
	diff=1
	--endtectrain
	savemess=0
	saveresettime=0
	--cowangry
	cowangry=false
	angrytime=0
	beenagry=false
	
	poke(0x5f5c, 255)
	
	chooseh={"shetland pony","qourter","connemara","smart little lena"}
	--menues
	
	menu={"compete","training",
	"care","check on horse","store","work","save"}
	store={"buy food","upgrade work gear","hire stableman","buy haybed","buy waterstation","buy foodstation","back"}
	care={"feed","give water","clean","rest (hold)","back"}
	training={"practice run","train technique","train stamina","train speed","exit"}
	competition={"amateur","novice","non-pro","open","super stakes","back"}
	sel=1 --selector

	_load()
	if horse==0 then
		_reset() 
		state="select_h"
	else state="menu"
	end

end

function _update()
	--competition/train comp
	if state=="play" then
		_movehorse()
		_movecow()
		
		if btn(4) or btn(5) then
			quittime+=1
			if quittime>=30*3 then
				quittime=0
				sel=1
				state="menu"
			end
		else quittime=0
		end
		
		if playtime<=0 then
			_wincalc()
		
			state="gameover"
		end
	end
	
	
	
	if state=="select_h" then
		if btnp(2) then sel-=1 end
		if sel<1 then sel=4 end
		if btnp(3) then sel+=1 end
		if sel>4 then sel=1 end
	
	
		if btnp(4) or btnp(5) then
			if sel==1 then
				horse=1
				tec=0
				sta=0
				spd=0
			end
			if sel==2 then
				horse=2
				tec=0
				sta=0
				spd=1
			end
			if sel==3 then
				horse=3
			 tec=0
				sta=1
				spd=0
			end
			if sel==4 then
				horse=4
			 tec=6
				sta=6
				spd=6
			end
			sel=1
			state="menu"
		end
	 --end select_h
	
	elseif state=="menu" then
		if btnp(2) then sel-=1 end
		if sel<1 then sel=7 end
		if btnp(3) then sel+=1 end
		if sel>7 then sel=1 end
	
				_checkmood()
	
	if savemess>0 then savemess-=1 end
		
	
		if btnp(4) or btnp(5) then
			if sel==1 then
				state="competition"
				sel=1
			end
			if sel==2 then
				state="training"
				sel=1
			end
			if sel==3 then
			 state="care"
			 sel=1
			end
			if sel==4 then
				sel=1
			 state="check"
			end
			if sel==5 then
				sel=1
			 state="store"
			end
			if sel==6 then
				sel=1
			 state="work"
			end
			if sel==7 then
				_save()
				savemess=30*1
			end
		end
		
			--resetsave
		if sel==7 and (btn(4) or btn(5)) then
			saveresettime+=1
			if saveresettime>30*7 then 
				_reset()
				_save()
				saveresettime=0
				sel=1
				state="select_h"
			end
		else saveresettime=0 end
		--endresetsave
		
	 --end menu
	elseif state=="care" then
		
	
			_checkmood()
	
		if btnp(2) then sel-=1 end
		if sel<1 then sel=5 end
		if btnp(3) then sel+=1 end
		if sel>5 then sel=1 end
	
		if (btn(4) or btn(5)) and sel==4 and ene<100 then
			 	ene+=0.4+workupg/10
			 	if ene>100 then ene=100 end
			 end
	
		if btnp(4) or btnp(5) then
			if sel==1 then
				if hun<100 and food>0 then
					food-=1
					hun+=35+workupg
					if hun>100 then hun=100 end
				end
				
				
			end
			if sel==2 then
				thu+=25+workupg*2
			 if thu>100 then thu=100 end
			end
			if sel==3 then
			 hyg+=5+workupg
			 if hyg>100 then hyg=100 end
			end
			if sel==4 then
			 --se ovan btn hold
			end
			if sel==5 then
				sel=3
			 state="menu"
			end
			
			
		end
	elseif state=="tdone" then
		_tdone()
	elseif state=="check" then
				local moodcalc=ene+hyg+hun+thu
				if moodcalc>=380 then mood="very happy"
				elseif moodcalc >300 then mood="happy" 
				elseif moodcalc >150 then mood="okey" 
				elseif moodcalc >80 then mood="sad" 
				else mood="dying"
				end
	
	
		if btnp(4) or btnp(5) then
			sel=4
			state="menu"
		end
	 --end check
	
	elseif state=="store" then
		if btnp(2) then sel-=1 end
		if sel<1 then sel=7 end
		if btnp(3) then sel+=1 end
		if sel>7 then sel=1 end
		
		if btnp(4) or btnp(5) then
			if sel==1 then
					if money>=2 then
					money-=2
					food+=1
					end
			end
			if sel==2 then
					local wup=(workupg+5)*10*(workupg+1)
					if money>=wup then
						money-=wup
						workupg+=1
					end
			end
			if sel==3 and money>=300 and caretaker==0 then
				money-=300
				caretaker=1
				hyg=100
			end
			if sel==4 and money>=100 and haybed==0 then
				money-=100
				haybed=1
				ene=100
			end
			if sel==5 and money>=200 and waterstation==0 then
				money-=200
				waterstation=1
				thu=100
			end
			if sel==6 and money>=200 and foodstation==0 then
				money-=200
				foodstation=1
				hun=100
			end
			if sel==7 then
				sel=5
				state="menu"
			end
		end--end store
		elseif state=="competition" then
		if btnp(2) then sel-=1 end
		if sel<1 then sel=6 end
		if btnp(3) then sel+=1 end
		if sel>6 then sel=1 end
		
		local md=ene+hyg+hun+thu
		
		if btnp(4) or btnp(5) then
			if sel==1 and money>=10 then
					_newrun()
					runcost=10
					money-=10
					cspd=-0.2
					cowrun=17
					playtime=30*25
					starttime=playtime
					state="play"
					compnr=1
					angrytime=rnd(playtime+300)
					if angrytime>playtime then angrytime=0 end
			end
			if sel==2 and money>=50 then
					_newrun()
					runcost=50
					money-=50
					cspd=-0.3
					cowrun=15
					playtime=30*30
					starttime=playtime
					state="play"
					compnr=2
					angrytime=rnd(playtime+300)
					if angrytime>playtime then angrytime=0 end
			end
			if sel==3 and money>=200 and md>150 then
					_newrun()
					runcost=200
					money-=200
					cspd=-0.4
					cowrun=12
					playtime=30*35
					starttime=playtime
					state="play"
					compnr=3
					angrytime=rnd(playtime+300)
					if angrytime>playtime then angrytime=0 end
			end
			if sel==4 and money>=500 and md>300 then
					_newrun()
					runcost=500
					money-=500
					cspd=-0.5
					cowrun=11
					playtime=30*50
					starttime=playtime
					state="play"
					compnr=4
					angrytime=rnd(playtime+300)
					if angrytime>playtime then angrytime=0 end
			end
			if sel==5 and money>=1000 and md>380 then
				_newrun()
				runcost=1000
				money-=1000
				cspd=-0.7
				cowrun=10
				playtime=30*60
				starttime=playtime
				state="play"
				compnr=5
				angrytime=rnd(playtime+300)
				if angrytime>playtime then angrytime=0 end
			end
			if sel==6 then
				sel=1
				state="menu"
			end
		end--end competition
		
		elseif state=="training" then
		if btnp(2) then sel-=1 end
		if sel<1 then sel=5 end
		if btnp(3) then sel+=1 end
		if sel>5 then sel=1 end
		
		if tec>=6 then teccost=0
		else teccost=tec*tec*20+5 end
		if sta>=6 then stacost=0
		else stacost=sta*sta*20+5 end
		if spd>=6 then  spdcost=0
		else spdcost=spd*spd*20+5 end
		
		
		if btnp(0) then--left
			if diff>1 then diff-=1 end
		end
		if btnp(1) then--right
			if diff<5 then diff+=1 end
		end
		
		if btnp(4) or btnp(5) then
			if sel==1 then
			
				if diff==1 then
						_newrun()
						runcost=0
						cspd=-0.2
						cowrun=17
						playtime=30*25
						starttime=playtime
						state="play"
						angrytime=rnd(playtime+300)
						if angrytime>playtime then angrytime=0 end
				end
				if diff==2 then
						_newrun()
					runcost=0
					cspd=-0.3
					cowrun=15
					playtime=30*30
					starttime=playtime
					state="play"
					angrytime=rnd(playtime+300)
					if angrytime>playtime then angrytime=0 end
				end
				if diff==3 then
						_newrun()
						runcost=0
						cspd=-0.4
						cowrun=12
						playtime=30*35
						starttime=playtime
						state="play"
						angrytime=rnd(playtime+300)
						if angrytime>playtime then angrytime=0 end
				end
				if diff==4 then
						_newrun()
						runcost=0
						cspd=-0.5
						cowrun=11
						playtime=30*50
						starttime=playtime
						state="play"
						angrytime=rnd(playtime+300)
						if angrytime>playtime then angrytime=0 end
				end
				if diff==5 then
						_newrun()
						runcost=0
						cspd=-0.7
						cowrun=10
						playtime=30*60
						starttime=playtime
						state="play"
						angrytime=rnd(playtime+300)
						if angrytime>playtime then angrytime=0 end
				end
				
			
			
			
			
			
			end
			if sel==2 and money>=teccost then
					tectrain=0
					money-=teccost
					state="traintec"
			end
			if sel==3 and money>=stacost then
					statrain=0
					money-=stacost
					state="trainsta"
			end
			if sel==4 and money>=spdcost then
					spdtrain=0
					money-=spdcost
					state="trainspd"
			end
			if sel==5 then
				sel=2
				state="menu"
			end
		end--end training
		elseif state=="traintec"then
			_traintec()
		elseif state=="trainsta"then
			_trainsta()
		elseif state=="trainspd"then
			_trainspd()
	elseif state=="work" then
		
	
		if btnp(workbtn) then
			money+=1+workupg 
			workbtn=flr(rnd(4))
			if money<-5000 or money>32000 then money=32000 end
		elseif btnp(0) and not btnp(workbtn) then
			money-=1+workupg
			if money<0 then money=0 end
		elseif btnp(1) and not btnp(workbtn) then
			money-=1+workupg
			if money<0 then money=0 end
		elseif btnp(2) and not btnp(workbtn) then
			money-=1+workupg
			if money<0 then money=0 end
		elseif btnp(3) and not btnp(workbtn) then
			money-=1+workupg
			if money<0 then money=0 end
		end
		
		if btnp(4) or btnp(5) then
			sel=6
			state="menu"
		end
	end 
	
	_gameover()
	
	
end

function _draw()
	drawtime+=1
	cls(0)
	
	
	--backgrounds and areas
	if state=="menu" or state=="care" or state=="check" then
		map(0)
		if drawtime<20 then
			spr(6,110,60)
		else 
			spr(20,110,60)
		end
		
		if caretaker==1 then
		spr(39,109,23)
		end
		if haybed==1 then
		spr(57,119,55)
		end
		if waterstation==1 then
		spr(56,105,80)
		end
		if foodstation==1 then
		spr(55,100,71)
		end
		
		--mood smiley
		if drawtime>20 then 
		if mood=="okey" then print ("😐",110,55)
		elseif mood=="sad" then 
		color(0)
		print ("ˇ",110,55)
		elseif mood=="dying" then 
		color(0)
		print ("▒",110,55)
		else 
		color(8)
		print("♥",110,55)
		color(7)
		end
		 
		
		end
		print("",0,0)
		if drawtime>40 then drawtime=0 end
	elseif state=="play" then
		--competition/train comp
		map(32)
		_drawpl()
	else
		map(16)
		
	end
	
	color(7)
	if state=="select_h" then
		print("-select your horse")
			print("")
			for i=1,4 do
			--	local y=10+(i*12)
				if i==sel then
					print(chooseh[i].."<-")
				else
					print(chooseh[i])
				end
			end
			print("")
			if sel==1 then print("no start bonus")end
			if sel==2 then print("+1 speed")end
			if sel==3 then print("+1 stamina")end
			if sel==4 then print("max stats (easy mode)")end
	end--end choose h
	
	if state=="gameover" then
		print("time up!")
		print("")
		print("judge score: "..score)
		if runcost>0 then print("you placed: "..place.."/10") end
		if runcost>0 then print("you won: "..winmoney) end
		print("")
		print("back<-")
	end
	
	if state=="menu" then
		cursor(0,0)
		print("-horse farm")
		print("")
			
			for i=1,7 do
			
				if i==sel then
					print(menu[i].."<-")
				else
					print(menu[i])
				end
			end
			print("")
			if saveresettime>30*1 then
			print("hold to delete save")
			end
			if savemess>0 then print("saved!") end
	end-- end menu
	
	if state=="store" then
		print("-what to purchase?")
		print("")
		print("money: "..money)
		print("")
		
		local wup=(workupg+5)*10*(workupg+1)
		
		
			for i=1,7 do
			
				if i==sel then
					print(store[i].."<-")
				else
					print(store[i])
				end
			end
			print("")
			if sel==1 then 
				print("cost: 2") 
				print("food: "..food)
			end
			if sel==2 then 
				print("cost: "..wup)
				print("working gear upg: "..workupg)
				print("gear increases work + care rate")
			end
			if sel==3 and caretaker==0 then 
				print("cost: 300")
				print("stableman: "..caretaker.."/1")
				print("keeps horse hygene up")
			end
			if sel==3 and caretaker==1 then 
				print("stableman: "..caretaker.."/1")
				print("keeps horse hygene up")
			end
			
			if sel==4 and haybed==0 then 
				print("cost: 100")
				print("haybed: "..haybed.."/1")
				print("keeps horse energy up")
			end
			if sel==4 and haybed==1 then 
				print("haybed: "..haybed.."/1")
				print("keeps horse energy up")
			end
			if sel==5 and waterstation==0 then 
				print("cost: 200")
				print("waterstation: "..waterstation.."/1")
				print("keeps horse thurst up")
			end
			if sel==5 and waterstation==1 then 
				print("waterstation: "..waterstation.."/1")
				print("keeps horse thurst up")
			end
			if sel==6 and foodstation==0 then 
				print("cost: 200")
				print("foodstation: "..foodstation.."/1")
				print("keeps horse hunger up")
			end
			if sel==6 and foodstation==1 then 
				print("foodstation: "..foodstation.."/1")
				print("keeps horse hunger up")
			end
	
	end-- end store
	
	if state=="competition" then
		print("-what competition?")
		print("")
		print("money: "..money)
		print("")

			for i=1,6 do
			
				if i==sel then
					print(competition[i].."<-")
				else
					print(competition[i])
				end
			end
			print("")
			if sel==1 then
			print("entry fee: 10")
			print("price money: 30/20/10")
			print("mood needed: n/a")
			if place1<99 then
			print("best place: "..place1)end
			elseif sel==2 then
			print("entry fee: 50")
			print("price money: 150/100/50")
			print("mood needed: n/a")
			if place2<99 then
			print("best place: "..place2)end
			elseif sel==3 then
			print("entry fee: 200")
			print("price money: 600/400/200")
			print("mood needed: okey")
			if place3<99 then
			print("best place: "..place3)end
			elseif sel==4 then
			print("entry fee: 500")
			print("price money: 1500/1000/500")
			print("mood needed: happy")
			if place4<99 then
			print("best place: "..place4) end
			elseif sel==5 then
			print("entry fee: 1000")
			print("price money: 3000/2000/1000")
			print("mood needed: very happy")
			if place5<99 then
			print("best place: "..place5)end
			end
			
	
	end-- end competition
	
	if state=="training" then
		
	
		print("-what to train?")
		print("")
			for i=1,5 do
			
				if i==sel then
					print(training[i].."<-")
				else
					print(training[i])
				end
			end
			
			
			print("")
			print("technique: "..tec.."/6")
			print("stamina: "..sta.."/6")
			print("speed: "..spd.."/6")
			print("")
			
			if sel==1 then
				print("dificulty: ⬅️"..diff.."➡️")
			end
			if sel==2 then 
			print("money: "..money)
			if tec<6 then print("training cost: "..teccost) end
			end
			if sel==3 then
			print("money: "..money)
			if sta<6 then print("training cost: "..stacost)end
			end
			if sel==4 then 
			print("money: "..money)
			if spd<6 then print("training cost: "..spdcost)end
			end
			
			
	end-- end training
	
	if state=="care" then
		cursor(0,0)
		print("-what to do?")
		print("")
		print("food: "..food)
		print("")
			for i=1,5 do
			
				if i==sel then
					print(care[i].."<-")
				else
					print(care[i])
				end
			end
			print("")
			print("hunger: "..flr(hun).."%")
			print("thurst: "..flr(thu).."%")
			print("hygene: "..flr(hyg).."%")
			print("energy: "..flr(ene).."%")
			if caretaker==1 then
				print("")
				print("stableman taking care")
			end
			
		
		print("")
	
	end-- end care
	
	if state=="check" then
		cursor(0,0)
		if horse==1 then
			print("-shetland pony")
		elseif horse==2 then
			print("-quarter")
		elseif horse==3 then
			print("-connemara")
		else
			print("-smart little lena")
	end
		
		print("")
		print("technique: "..tec.."/6")
		print("stamina: "..sta.."/6")
		print("speed: "..spd.."/6")
		print("")
		print("hunger: "..flr(hun).."%")
			print("thurst: "..flr(thu).."%")
			print("hygene: "..flr(hyg).."%")
			print("energy: "..flr(ene).."%")
		print("")
		print("mood: "..mood)
		print("")
		print("back<-")
		
	end--end stats
	
	if state=="traintec" then
		
		_drawtec()
	end
	
	if state=="trainsta" then
		
		_drawsta()
	end
	
	if state=="trainspd" then
		
		_drawspd()
	end
	
	if state=="tdone" then
		_drawtdone()
	end
	
	if state=="work" then
		local worktype=""
		print("-work")
		print("")
		if workbtn==0 then
		print("press ⬅️ to work")
		worktype="harvesting"
		elseif workbtn==1 then
		worktype="milking cows"
		print("press ➡️ to work")
		elseif workbtn==2 then
		worktype="planting"
		print("press ⬆️ to work")
		elseif workbtn==3 then
		worktype="fixing"
		print("press ⬇️ to work")
		end
		print("bad work = loose money")
		print("")
		print("money: "..money)
		print("")
		print("back<-")
		print("")
		
		
		print("-"..worktype.."-")
	end
	
end
-->8
--competition/game
function _gameover()
	if state=="gameover" then
		if btnp(4) or btnp(5) then
			sel=1
			state="menu"
		end
	end
end

function _checkmood()
		local moodcalc=ene+hyg+hun+thu
				if moodcalc>=380 then mood="very happy"
				elseif moodcalc >300 then mood="happy" 
				elseif moodcalc >150 then mood="okey" 
				elseif moodcalc >80 then mood="sad" 
				else mood="dying"
				end
end

function _wincalc()
	local winc=0
	place=10
	winc=rnd(100)+tec*2-(2*changedelay/30)
	
	score=flr(score+rnd(10+tec/2)-lost*5-changedelay/30)
	if score<60 then score=60 end
	if score>80 then score=80 end
	
	if lost==0 then
		if winc>25 and score>67+rnd(3) then place=1 
		else place=2
		end
	elseif lost==1 then
		if winc>50 then place=3 
		else place=4
		end
	elseif lost==2 then
		if winc>50 then place=5 
		else place=6
		end
	else
		if winc>80 then place=7
		elseif winc>60 then place=8
		elseif winc>30 then place=9
		else place=10
		end
	end
	
	if place==1 then winmoney=3*runcost
	elseif place==2 then winmoney=2*runcost
	elseif place==3 then winmoney=runcost
	else winmoney=0
	end	
	
	if compnr==1 then 
		if place<place1 then place1=place end
	end
	if compnr==2 then 
		if  place<place2 then place2=place end
	end
	if compnr==3 then 
		if place<place3 then place3=place end
	end
	if compnr==4 then 
		if place<place4 then place4=place end
	end
	if compnr==5 then 
		if place<place5 then place5=place end
	end
	
	money+=winmoney
	if money<-5000 or money>32000 then money=32000 end
	hun-=rnd(15)
	hyg-=rnd(20)
	thu-=rnd(20)
	if hun<0 then hun=0 end
	if hyg<0 then hyg=0 end
	if thu<0 then thu=0 end
	
	if caretaker==1 then
				hyg=100
			end
			if haybed==1 then
				ene=100
			end
			if waterstation==1 then
				thu=100
			end
			if foodstation==1 then
				hun=100
			end
	compnr=0
end

function _newrun()
	cowangry=false
	beenagry=false
	runcost=10
	newlost=true
	quittime=0
	score=70
	px=60
	py=60
	cx=60
	cy=80
	starttime=30*20
	lost=0
	drawtime=0
	pdirr=false
	anim=0
	pspr=48
	playtime=0
	place=10
	winmoney=0
	animc=0
	cspr=52
	cdirr=false
	cspd=-0.2
	cbeh=0
	cowstate="start"
	change=false
	changedelay=0
	changed=false
	
	cowrun=15 --change difficulty
end

function _movehorse()
	if state=="play" then
		playtime-=1
		
		local maff=1
		if mood=="dying" then maff=10
		elseif mood=="sad" then maff=2
		elseif mood=="okey" then maff=1.2
		elseif mood=="happy" then maff=1
		else maff=0.9
		end
		
		if btn(⬅️) and px>2 and ene>0 then 
			px-=0.5+spd/10
			pdirr=false
			anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame
   
   ene-=(0.4-sta/20)*maff
   if ene<=0 then ene=0 end
   
		elseif btn(➡️) and px<121 and ene>0 then
			px+=0.5+spd/10
			pdirr=true
			anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame 
   
   ene-=(0.4-sta/20)*maff
   if ene<=0 then ene=0 end
		elseif not (btn(⬇️) or btn(⬆️)) then --stand still
			if ene<100 and ene>0 then
				ene+=(0.1+sta/30)*((hun+thu)/400)
				if ene>100 then ene=100 end
			end
   pspr = 48         
   anim = 0
  end
  
  if btn(⬆️) and py>30 and ene>0 then
  	py-=0.5+spd/10
  	anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame 
  elseif btn(⬇️) and (py<cy-9 or cowstate=="fail") and ene>0 then
  	py+=0.5+spd/10
  	anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame 
  end
	
	
	
	end
end

function _movecow()
			if animc>=30*3 and cowstate=="start" then cowstate="play" end
			
			if playtime<angrytime and beenagry==false then
				if cowstate=="play" and change==false then cowangry=true end
			else cowangry=false end
			
			if cowangry==true then
				if abs(cy-py)>20 then 
				cowangry=false 
				beenagry=true
				end
			end
			
			if cowstate=="fail" and cowangry==true then
				cowangry=false 
				beenagry=true
			end
			
			animc+=1
			if animc<30*4 then cbeh=0
			elseif animc<30*8 then cbeh=2
			elseif animc<30*12 then cbeh=-2
			else animc=0
			end 
			
			local framec = flr(animc / 5) % 2
   cspr = 52 + framec
   
   --behaviour type
   
   --loosar om han nr kant?
   if (cowstate=="play" and ((abs((cx+3)-(px+3))>(cowrun+tec)or cy<py-4) or cx>117 or cx<10)) or cowstate=="fail" then
   	cy-=2
   	cowstate="fail"
   	if newlost==true then
   		newlost=false
   		if change==false then lost+=1 end
   	end
   elseif cowstate=="play" and px+3<cx+3+cbeh then
   	if change==true then cx-=cspd/2
   	elseif cowangry==true then cx-=cspd*1.5 
   	else cx-=cspd end
   	
   	cdirr=true
   elseif cowstate=="play" then
   	cdirr=false
   if change==true then	cx+=cspd/2
   elseif cowangry==true then cx+=cspd*1.5
   else cx+=cspd end
   end
   if cowstate=="play" and cy-py>12 then
   	
   	cy-=0.1
   end
   if cowstate=="play" and cy-py<10 and cy<105 then
   	
   	cy+=0.1
   end
   
   	--when to change cattle
   if playtime<=starttime/2 and changed==false and cowstate=="play" then
   		change=true
   end
   	
   if change==true and cowstate=="play" then
   		changedelay+=1
   end
   	
   	----
   	
   	if cy<=-50 then
   		if change==true then 
   		change=false 
   		changed=true
   		end
   		newlost=true
   		cx=60
					cy=80
					animc=0
					cowstate="start"
   	end
   
end

function _drawpl()
	print("time: "..flr(playtime/30))
	print("energy: "..flr(ene))
	spr(pspr,px,py,1,1,pdirr,false)
	if cowstate=="fail" then spr(36,cx,cy,1,1,cdirr,false)
	else spr(cspr,cx,cy,1,1,cdirr,false)
	end
	print("lost: "..lost)
	print("")
	if change==true then
		print("change cow!")
		print("delay: "..flr(changedelay/30))
	
	--draw cowstate
		if cowstate=="play" then print("😐",cx,cy-4)end		
		cursor(0,0)
	end
	if cowangry==true then
	print("angry cow!")
	print("move up!")
	print("🐱",cx,cy-4)
	end
	
	if ene==0 then print("🐱",px,py-6)
	elseif ene<=25 then print("ˇ",px,py-6)
	end
		cursor(0,0)
	if quittime>15 then print("hold to forfeit",38,100) end
end
-->8
--trainings
function _tdone()
	if btnp(4) or btnp(5) then
			state="training"
		end
end

function _drawtdone()
	print("training complete!")
	print("")
	print("back<-")
end

function _traintec()
	--movement
		if btn(⬅️) and px>2 then 
			px-=0.5+spd/10
			pdirr=false
			anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame
   
 
		elseif btn(➡️) and px<121 then
			px+=0.5+spd/10
			pdirr=true
			anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame 
   
		elseif not (btn(⬇️) or btn(⬆️)) then
   pspr = 48         
   anim = 0
  end
  
  if btn(⬆️) and py>10 then
  	py-=0.5+spd/10
  	anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame 
   
  elseif btn(⬇️) and py<120 then
  	py+=0.5+spd/10
  	anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame
    
  end
	--endmovement
	--win
		if btnp(⬇️)or btnp(⬆️) or btnp(⬅️) or btnp (➡️)then
			tectrain+=1
		end
		if tectrain>=tec*10+30 then
			ene-=rnd(20)
			hun-=rnd(15)
			hyg-=rnd(20)
			thu-=rnd(20)
			if ene<0 then ene=0 end
			if hun<0 then hun=0 end
			if hyg<0 then hyg=0 end
			if thu<0 then thu=0 end
		
			if caretaker==1 then
				hyg=100
			end
			if haybed==1 then
				ene=100
			end
			if waterstation==1 then
				thu=100
			end
			if foodstation==1 then
				hun=100
			end
		
			state="tdone"
			if tec<6 then tec+=1 end
			sel=1
			px=60
			py=60
		end
	--endwin
	
end

function _drawtec()
	print("swiftly switch directions")
	spr(pspr,px,py,1,1,pdirr,false)
	print(tectrain.."/"..tec*10+30)
end

function _trainsta()
	--movement
		if btn(⬅️) and px>2 then 
			px-=0.5+spd/10
			pdirr=false
			anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame
   statrain+=1
 
		elseif btn(➡️) and px<121 then
			px+=0.5+spd/10
			pdirr=true
			anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame 
   statrain+=1
		elseif not (btn(⬇️) or btn(⬆️)) then
   pspr = 48         
   anim = 0
  end
  
  if btn(⬆️) and py>10 then
  	py-=0.5+spd/10
  	anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame 
   statrain+=1
  elseif btn(⬇️) and py<120 then
  	py+=0.5+spd/10
  	anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame
    statrain+=1
  end
	--endmovement
	--win
		if statrain>=sta*30*2+30*10 then
			
			ene-=rnd(20)
			hun-=rnd(15)
			hyg-=rnd(20)
			thu-=rnd(20)
			if ene<0 then ene=0 end
			if hun<0 then hun=0 end
			if hyg<0 then hyg=0 end
			if thu<0 then thu=0 end
			
			if caretaker==1 then
				hyg=100
			end
			if haybed==1 then
				ene=100
			end
			if waterstation==1 then
				thu=100
			end
			if foodstation==1 then
				hun=100
			end
		
			
			state="tdone"
			sel=1
			if sta<6 then sta+=1 end
			px=60
			py=60
		end
	--endwin
	

	
end

function _drawsta()
	print("ride for a time")
	spr(pspr,px,py,1,1,pdirr,false)
	print(flr(statrain/30).."/"..flr((sta*30*2+30*10)/30))
end

function _trainspd()
	--movement
		if btn(⬅️) and px>2 then 
			px-=0.5+spd/10
			pdirr=false
			anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame
   spdtrain+=1
 
		elseif btn(➡️) and px<121 then
			px+=0.5+spd/10
			pdirr=true
			anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame 
   spdtrain+=1
		elseif not (btn(⬇️) or btn(⬆️)) then
   pspr = 48         
   anim = 0
  end
  
  if btn(⬆️) and py>10 then
  	py-=0.5+spd/10
  	anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame 
   spdtrain+=1
  elseif btn(⬇️) and py<120 then
  	py+=0.5+spd/10
  	anim+=1
			local frame = flr(anim / 5) % 2
   pspr = 48 + frame
   spdtrain+=1
  end
	--endmovement
	--win
		if spdtrain>=140-15*spd then
			
			ene-=rnd(20)
			hun-=rnd(15)
			hyg-=rnd(20)
			thu-=rnd(20)
			if ene<0 then ene=0 end
			if hun<0 then hun=0 end
			if hyg<0 then hyg=0 end
			if thu<0 then thu=0 end
			
			if caretaker==1 then
				hyg=100
			end
			if haybed==1 then
				ene=100
			end
			if waterstation==1 then
				thu=100
			end
			if foodstation==1 then
				hun=100
			end
		
			
			
			state="tdone"
			sel=1
			if spd<6 then spd+=1 end
			px=60
			py=60
		end
	--endwin
	
	if btnp(⬇️)or btnp(⬆️) or btnp(⬅️) or btnp (➡️)then
			spdtrain=0
		end
	
end

function _drawspd()
	print("ride straight!")
	spr(pspr,px,py,1,1,pdirr,false)
	print(flr(spdtrain).."/"..140-spd*15)
end
-->8
--misc
function _save()

	dset(0,horse)
	dset(1,tec)
	dset(2,sta)
	dset(3,spd)
	dset(4,ene)
	dset(5,hyg)
	dset(6,hun)
	dset(7,thu)
	dset(8,caretaker)
	dset(9,money)
	dset(10,mood)
	dset(11,workupg)
	dset(12,food)
	dset(13,workbtn)
	dset(14,teccost)
	dset(15,stacost)
	dset(16,spdcost)
	dset(17,haybed)
	dset(18,waterstation)
	dset(19,foodstation)
	dset(20,place1)
	dset(21,place2)
	dset(22,place3)
	dset(23,place4)
	dset(24,place5)

end

function _load()
	horse=dget(0)
	tec=dget(1)
	sta=dget(2)
	spd=dget(3)
	ene=dget(4)
	hyg=dget(5)
	hun=dget(6)
	thu=dget(7)
	caretaker=dget(8)
	money=dget(9)
	mood=dget(10)
	workupg=dget(11)
	food=dget(12)
	workbtn=dget(13)
	teccost=dget(14)
	stacost=dget(15)
	spdcost=dget(16)
	haybed=dget(17)
	waterstation=dget(18)
	foodstation=dget(19)
	place1=dget(20)
	place2=dget(21)
	place3=dget(22)
	place4=dget(23)
	place5=dget(24)
end

function _reset()
	horse=0
	tec=0
	sta=0
	spd=0
	ene=100
	hyg=100
	hun=100
	thu=100
	caretaker=0--0
	money=25--25
	mood="okey"
	workupg=0
	food=0
	workbtn=0
	teccost=0
	stacost=0
	spdcost=0
	haybed=0
	waterstation=0
	foodstation=0
	place1=99
	place2=99
	place3=99
	place4=99
	place5=99
end