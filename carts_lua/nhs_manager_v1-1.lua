-- nhs manager
-- a mighty pirate game
-- a tiny art-game about public healthcare in modern britain
-- creative commons zero license

slogan = "★ care.passion.excellence.★"

function _init()

-- save game
	cartdata("nhs_manager_mighty_pirate_1")
	init_events()
-- global var
	reading=false
	month_rnd=1

--main menu var
	main_menu=true
	flash_t=-200
	cls_clr=7
	flash_f=false
	
-- ui var
	menu_clr=8
	menu_itm=0
	menu_bud=0
	s_itm=0
	top_on=true
	
-- screen var
	screen=0
	poke(0x5f5c, 255) -- turn off repeat on btnp

--time vars
	tick = 0
	anim_t=0
	anim=0
	day = 20
	month  = 1
	year = 2026
	anim_amb=false
	
-- budget vars - all as 10,000s 
	b = {}
	b.staff= "0"
	b.dr= "0"
	b.nur= "0"
	b.man= "0"
	b.med= "939"
	b.pfi= "0"
	b.util= "540"
	b.mar= "500"
	b.it= "900"
	b.inc= "2000"
	b.pen= "0"
	b.out= "0"
	
	b.car = "0"
	b.shop = "0"
	b.cafe = "0"
	b.gov = "3550"
	
	b.rev = "0"
	b.cash = "10000"
	
-- staff vars 
	s = {}
	s.con = "100"
	s.dr = "200"
	s.nur = "500"
	s.man = "75"
	
	-- salaries, monthly, 10000s per 10 employees
	sal = {}
	sal.con= "11"
	sal.dr= "5"
	sal.nur = "4"
	sal.man = "10"
	
	--costs in 10,000
	cost = {}
	cost.bed=4
	cost.xray=8
	cost.amb= 15
	cost.wing=252
	cost.pfi = 100
	cost.int= 12 -- %
	cost.car = 100
	cost.shop = 30
	cost.cafe = 25

-- income vars

	inc = {}
	inc.car=50
	inc.cafe=40
	inc.shop=30

-- hospital vars
	h = {}
	h.drs = {}
	h.beds = 4
	h.floors = 1
	h.xray = 8
	h.amb = 1
	h.car = 1
	h.shop = 0
	h.cafe = 0
	h.pfi = 200
	
--monthly data (10s)
	h.inp = "200"
	h.outp = "420"
	h.death = "20"
	h.cor = "20"
	h.diff = "10"
	h.ref = "14" --weeks
	h.ambw = "27" -- minutes
	h.em = "10" -- hours
	h.scan = "10" -- weeks
	
--cqc

	cqc = {}
	cqc.r = 2
	cqc.safe = 3
	cqc.ef = 4
	cqc.car = 1
	cqc.res = 2
	cqc.well = 1
	cqc.fin = 3

--events
	event_num=1
	event_end=false
	
	strike_dr=false
	strike_con=false
	strike_nur=false
	corx=10
	diffx=10
	penx=10
	deathx=1
	staffx="1"
	salx="10"
	cls_out=false
	cls_in=false
	last_dec="❘"
	max_work="600"

	game_over=false
	
	if (dget(0)==1) then
		load_game()
	end
	
	music(0,10000)

end

function _update()
		if (game_over==true) then
		_draw=draw_game_over()
		update_game_over()
		elseif (main_menu==true) then
		_draw=draw_main_menu()
		update_main_menu()
	elseif (screen==0) then 
		_draw=draw_main_screen()
		update_main_screen()
	elseif (screen==1) then
		_draw=draw_status_screen()
		update_status_screen()
	elseif (screen==2) then
		_draw=draw_budget_screen()
		update_budget_screen()
	elseif (screen==3) then
		_draw=draw_staff_screen()
		update_staff_screen()
	elseif (screen==4) then
		_draw=draw_buy_screen()
		update_buy_screen()
	elseif (screen==5) then
		_draw=draw_cqc_screen()
		update_cqc_screen()
	elseif (screen==8) then
		_draw=draw_event_screen()
		update_event_screen()
	end
end

function _draw()

end

--
-->8
--helper functions

-- print centred, adapted from pico-8 wiki
function print_centered(str,y,clr)
  print(str, 64 - (#str * 2), y, clr) 
end

-- format millions

function format_m(str)
	local result
	local t = "0"
	local i = 0
	local neg = ""
	
	if (sub(str,1,1)=="-") neg="-"
	result = stringdiv(str, "100") 
	if (tonum(result)<=-1) neg=""
	
	t = sub(str,-2)
	
	if (sub(t,1,1)=="-") then
		t=sub(t,2)
	end
	
	if (#t>=2) then 
		t=sub(t,1,2)
	elseif (#t>=1) then
	 t= "0"..t
	end
	
	result = neg .. result .. "." .. t .. " million"
	
	return result

end

--format thousands

function format_t(str)

	local result
	local t = ""
	
	if (tonum(str)>=100) then
		result = stringdiv(str, "100")
		t = sub(str,-2)
		result = result .. "," .. t
	else
		result = str
	end
	
	result = result .. "0,000"
	
	return result

end

--format small numbers
function format_x(str)

	local result
	local t = ""
	local o = "0"
	
	if (str=="0") o=""
	
	if (tonum(str)>=100) then
		result = stringdiv(str, "100")
		t = sub(str,-2)
		result = result .. "," .. t 
	else
		result = str
	end
	
	result = result .. o
	
	return result

end

-- text box example
-- by profpatonildo
-- cc4-by-nc-sa
function tb_init(voice,string,col3) -- this function starts and defines a text box.
    reading=true -- sets reading to true when a text box has been called.
    tb={ -- table containing all properties of a text box. i like to work with tables, but you could use global variables if you preffer.
    str=string, -- the strings. remember: this is the table of strings you passed to this function when you called on _update()
    voice=voice, -- the voice. again, this was passed to this function when you called it on _update()
    i=1, -- index used to tell what string from tb.str to read.
    cur=0, -- buffer used to progressively show characters on the text box.
    char=0, -- current character to be drawn on the text box.
    x=0, -- x coordinate
    y=28, -- y coordginate
    w=127, -- text box width
    h=21, -- text box height
    col1=7, -- background color
    col2=7, -- border color
    col3=1, -- text color
    }
end


function tb_draw() -- this function draws the text box.
    if reading then -- only draw the text box if reading is true, that is, if a text box has been called and tb_init() has already happened.
        --rectfill(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col1) -- draw the background.
        --rect(tb.x,tb.y,tb.x+tb.w,tb.y+tb.h,tb.col2) -- draw the border.
        print(sub(tb.str[tb.i],1,tb.char),tb.x+2,tb.y+2,tb.col3) -- draw the text.
    end
end

function tb_update()  -- this function handles the text box on every frame update.
    if tb.char<#tb.str[tb.i] then -- if the message has not been processed until it's last character:
        tb.cur+=0.5 -- increase the buffer. 0.5 is already max speed for this setup. if you want messages to show slower, set this to a lower number. this should not be lower than 0.1 and also should not be higher than 0.9
        if tb.cur>0.9 then -- if the buffer is larger than 0.9:
            tb.char+=1 -- set next character to be drawn.
            tb.cur=0    -- reset the buffer.
            if (ord(tb.str[tb.i],tb.char)!=32) sfx(tb.voice) -- play the voice sound effect.
        end
        if (btnp(❘) or btnp(🅾️)) tb.char=#tb.str[tb.i] -- advance to the last character, to speed up the message.
    elseif (btnp(❘) or btnp(🅾️)) then -- if already on the last message character and button ❘/x is pressed:
        if #tb.str>tb.i then -- if the number of strings to disay is larger than the current index (this means that there's another message to display next):
            tb.i+=1 -- increase the index, to display the next message on tb.str
            tb.cur=0 -- reset the buffer.
            tb.char=0 -- reset the character position.
        else -- if there are no more messages to display:
             -- set reading to false. this makes sure the text box isn't drawn on screen and can be used to resume normal gameplay.
        				if(btnp(❘)) then
        					reading=false
        					lastdec="❘"
        					sfx(3)
        					call_trigger()
        				elseif(btnp(🅾️)) then
        					reading=false
        					lastdec="🅾️"
        					sfx(6)
        					call_trigger()
        				end
        				
        end
    end
end

function insert_str(str1,str2,pos)
	local str = sub(str1,1,pos)
	str = str .. str2
	str = str .. sub(str1,pos+1)
	return str
end

function call_trigger()
	if (events[event_num] and events[event_num]:trigger()) then
		events[event_num]:trigger()
	end
end

-- get month
function get_month(month)

if (month==1) return "jan"
if (month==2) return "feb"
if (month==3) return "mar"
if (month==4) return "apr"
if (month==5) return "may"
if (month==6) return "june"
if (month==7) return "july"
if (month==8) return "aug"
if (month==9) return "sep"
if (month==10) return "oct"
if (month==11) return "nov"
if (month==12) return "dec"
end


-- big integers
-- written by dw817 (12-03-21)
-- standard ⌂ pico-8 license

-- add 2 numeric strings
function stringadd(a,b)
  return tostr(tonum(a.."",2)+tonum(b.."",2),2)
end

-- subtract 2 numeric strings
function stringsub(a,b)
  return tostr(tonum(a.."",2)-tonum(b.."",2),2)
end

-- multiply 2 numeric strings
function stringmul(a,b)
  return tostr(tonum(a.."",2)*(tonum(b.."",2)<<16),2)
end

-- divide 2 numeric strings
function stringdiv(a,b)
  return tostr(tonum(a.."",2)/(tonum(b.."",2)<<16),2)
end

-- thanks to felice for
-- negative sub information.
function dec(a,b)
local m=" "
  if sub(a,1,1)=="-" then
    m="-"
    a=sub(a,2)
  end
  return m..sub("0000000"..a,-b)
end

-- return 1st character in
-- string a position b.
function fnc(a,b)
  return sub(a,b,b)
end

-- for debugging purposes
-- waits for 🅾️ to be pressed.
-- zep! please add btn() and
-- btnp() as commands to wait
-- for keystroke.
function bt4()
  repeat flip() until btnp(4)
end

function save_game()

	dset(0,1)
	dset(1,month)
	dset(2, year)
	dset(3, day)
	
	dset(4,strike_dr)
	dset(5,strike_con)
	dset(6,strike_nur)
	dset(7,corx)
	dset(8,diffx)
	dset(9,penx)
	dset(10,deathx)
	dset(11,tonum(staffx))
	dset(12,tonum(salx))
	dset(13, cls_out)
	dset(14, cls_in)
	dset(15, tonum(max_work))
	
	dset(16,h.beds)
	dset(17,h.floors)
	dset(18,h.xray)
	dset(19,h.amb)
	dset(20,h.car)
	dset(21,h.shop)
	dset(22,h.cafe)
	dset(23,h.pfi)
	
	dset(24,tonum(sal.con))
	dset(25,tonum(sal.dr))
	dset(26,tonum(sal.nur))
	dset(27,tonum(sal.man))
	
	dset(28,tonum(s.con))
	dset(29,tonum(s.dr))
	dset(30,tonum(s.nur))
	dset(31,tonum(s.man))
	
	dset(32,tonum(b.gov))
	dset(33,tonum(b.med))
	dset(34,tonum(b.pfi))
	dset(35,tonum(b.util))
	dset(36,tonum(b.mar))
	dset(37,tonum(b.it))
	dset(38, tonum(b.cash))
	
	dset(39, event_num)
	
	dset(40, cost.int)

end

function load_game()

	month=dget(1)
	year=dget(2)
	day=dget(3)
	
	strike_dr=dget(4)
	strike_con=dget(5)
	strike_nur=dget(6)
	corx=dget(7)
	diffx=dget(8)
	penx=dget(9)
	deathx=dget(10)
	staffx=tostr(dget(11))
	salx=tostr(dget(12))
	cls_out=dget(13)
	cls_in=dget(14)
	max_work=tostr(dget(15))
	
	h.beds=dget(16)
	h.floors=dget(17)
	h.xray=dget(18)
	h.amb=dget(19)
	h.car=dget(20)
	h.shop=dget(21)
	h.cafe=dget(22)
	h.pfi=dget(23)
	
	sal.con=tostr(dget(24))
	sal.dr=tostr(dget(25))
	sal.nur=tostr(dget(26))
	sal.man=tostr(dget(27))
	
	s.con=tostr(dget(28))
	s.dr=tostr(dget(29))
	s.nur=tostr(dget(30))
	s.man=tostr(dget(31))
	
	b.gov=tostr(dget(32))
	b.med=tostr(dget(33))
	b.pfi=tostr(dget(34))
	b.util=tostr(dget(35))
	b.mar=tostr(dget(36))
	b.it=tostr(dget(37))
	b.cash=tostr(dget(38))
	
	event_num=dget(39)
	
	cost.int=dget(40)
end
-->8
-- main menu and game over

function update_main_menu()
	flash_t+=1
	flash_screen()
	if (dget(0)==1) then
		if (btnp(❘) and main_menu==true) then
			music(-1,0)
			sfx(1)
			main_menu=false
			screen=1
			calc_budget()
			calc_stats()
			calc_cqc()
		end
		if (btnp(🅾️) and main_menu==true) then
			dset(0,0)
			sfx(1)
			run()
		end
	else
		if (btnp(❘) and main_menu==true) then
			music(-1,0)
			sfx(1)
			main_menu=false
			screen=8
			end_month()
		end
	end
end

function draw_main_menu()
	cls(cls_clr)
	spr(1,40, 44, 6,2)
	print_centered("manager", 64, 1)
	if (dget(0)==1) then
		print_centered("press ❘ to load save", 94, 1)
		print_centered("press 🅾️ to delete save", 102, 1)
	else
			print_centered("press ❘ to start new game", 94, 1)
	end
	if (flash_flag==true) print_centered("a mighty pirate game", 114, 6)
end


function flash_screen()
	if (flash_t>3+flr(rnd(5))) then
		pal()
		cls_clr=7
	end
	
	if (flash_t>80+flr(rnd(5))) then
		flash_t=0
		cls_clr=8
		sfx(5)
		pal(7,cls_clr)
		pal(1,7)
		flash_flag=true
	end
	
end

function update_game_over()
	music(-1)
	sfx(9)
	if (btnp(❘)) _init()

end

function draw_game_over()
	cls(cls_clr)
	cls_clr=8
	pal(7,cls_clr)
	pal(1,7)
	spr(1,40, 30, 6,2)
	print_centered("manager", 50, 1)
	print_centered(get_month(month) .. " " .. year .. ": you were fired", 66, 1)	
	spr(72,56, 92, 2,2)	
	print_centered("a mighty pirate game", 116, 1)
	if (btnp(❘) or btnp(🅾️)) then
		dset(0,0)
		sfx(1)
		run()
	end
end
-->8
-- main screen


function update_main_screen()
	update_t()
	update_menu(top_on)
end

function update_t()
	tick+=1
	anim_t+=1
	if (anim_t>60) then
		anim_t=0
	end
	if (anim_t>30) then
		anim+=0.5
	else
		anim-=0.5
	end
	if (tick>30) then
		tick = 0
		update_cal()
	end
end

function update_cal()
	day+=1
	if (day==4) then
		music(1)
	elseif (day==10) then
		music(-1)
	end
	
	if (day==20) then
		music(0)
	elseif (day==26) then
		music(-1)
	end
	if (month==2) then
		if (year%4==0 and day>29) then
			top_on=false
			day=1
			month+=1
			screen=8
			end_month()
		elseif (year%4!=0 and day>28) then
			top_on=false
			day=1
			month+=1
			screen=8
			end_month()
		end
	elseif (month==4 or month==6 or month==9 or month==11) then
		if (day>30) then
			top_on=false
			day=1
			month+=1
			screen=8
			end_month()
		end
	else
		if (day>31) then
			top_on=false
			day=1
			month+=1
			screen=8
			end_month()
		end
	end
	
	if (month>12) then
		month = 1
		day = 1
		year+=1
	end

end

function update_menu(on)
	if (on==true) then
		-- input
		if (btnp(⬅️) and s_itm==0) then
			if (menu_itm!=0) sfx(0)
			menu_itm-=1
			calc_budget()
			calc_stats()
			calc_cqc()
		end
		if (btnp(➡️) and s_itm==0)	then
			if (menu_itm!=5) sfx(0)
			menu_itm+=1
			calc_budget()
			calc_stats()
			calc_cqc()
		end
		
		if (menu_itm<0) menu_itm=0
		if (menu_itm>5) menu_itm=5
		if (s_itm==0) then
			if (menu_itm==0) then
				screen=0
			elseif (menu_itm==1) then
				screen=1
			elseif (menu_itm==2) then
				screen=2
			elseif (menu_itm==3) then
				screen=3
			elseif (menu_itm==4) then
				screen=4
			elseif (menu_itm==5) then
				screen=5
			end
		end
	else
		screen=8
	end
end

function draw_main_screen()
	cls(7)
	map((4-h.floors)*16,0)
	draw_top_menu(true)
	draw_bottom_menu()
	draw_beds()
	draw_extra()
	draw_amb()
	draw_drs()

end

function draw_top_menu(on)

		local clr=6
		rectfill(0,0, 128,12,1)
		spr(12,4,1,3,1)
		pal()
		if (menu_itm<3) then
			
			if (menu_itm==0 and on==true) clr=menu_clr
			print("home",36,4,clr)
			clr=6
			if (menu_itm==1 and on==true) clr=menu_clr
			print("status", 30+26,4,clr)
			clr=6
			if (menu_itm==2 and on==true) clr=menu_clr
			print("budget", 68+16,4,clr)
			clr=6
			print("➡️", 110,4,clr)
			
		else
			print("⬅️", 36,4,clr)
			
			if (menu_itm==3 and on==true) clr=menu_clr
			print("staff",50,4,clr)
			clr=6
			if (menu_itm==4 and on==true) clr=menu_clr
			print("buy", 74,4,clr)
			clr=6
			if (menu_itm==5 and on==true) clr=menu_clr
			print("cqc", 90,4,clr)
			clr=6
		end
			
end

function draw_bottom_menu()
		local clr=6
		local string=""
		rectfill(0,116, 128,128,1)
		print(day .." " .. get_month(month) .." " .. year, 4, 120,clr)
		
		string, clr = cqc_score(cqc.r)
	
		print("cqc:" .. string, 80-18, 120, clr)
end

function draw_drs()
	local left = false
	if (anim_t>40) left=true
	spr(50,20+(anim*-0.5),90,1,1,left)
end

function draw_beds()

local y = 0
local x = 0
	for i=1, h.beds do
	if (i>11 and i<23) then
		y=16
		x=88
	elseif (i>=23 and i<34) then
		y=32
		x=176
	elseif (i>=34) then
		y=48
		x=176+88
	end
			if (i%5==0) then
				 spr(35,10+(i*8)-x,76-y,1,1,false)
			else
					spr(34,10+(i*8)-x,76-y,1,1,false)
			end
	end
end

function draw_amb()
local left = false
	for i=1, h.amb do
			spr(54,(i*20)-12,106,2,1,left)
	end
end

function draw_extra()
	local left = false
	if (anim_t>30) left=true
	if (h.cafe>0) spr(64,20,88,2,2,false)
	if (h.shop>0) spr(66,96,88,2,2,false)
	if (strike_dr==true or strike_con==true or strike_nur==true) spr(112,100+(anim),100,1,1,left)
end



-->8
-- budget screen

function update_budget_screen()
	update_t()
	update_menu(top_on)
	
	--switch screens
	if (btnp(❘)) then
		if (menu_bud==0) then
			menu_bud=1
		else
			menu_bud=0
		end
	end
	
	if (btnp(🅾️)) then
		if (menu_bud==0) then
			menu_bud=2
		end
	end
end

function draw_budget_screen()
	cls(7)
	draw_top_menu(true)
	draw_budget()
	draw_bottom_menu()
end

function draw_budget()
	local out_off = 0
	if (menu_bud==0) then
		print("overview",8,20,1)
		print("monthly",64,20,1)
		--outgoings
		print("outgoings",10,32-3+out_off,1)
		spr(33, 50, 30-3+out_off)
		print("-" .. format_m(b.out),10+50,32-3+out_off,1)
	--income
		print("income",10,40-3,1)
		spr(33, 50, 38-3)
		print(format_m(b.inc),10+50,40-3,1)
		print("…………………………………", 8, 56-12, 1)
	--revenue
		print("revenue",8,52,1)
		if (sub(b.rev,1,1)=="-") pal(1,8)
		spr(33, 50, 50)
		print(format_m(b.rev),8+50,52,1)
		pal()
		print("…………………………………", 8, 56-12+16, 1)
		--cash
		print("total cash", 8, 70, 1)
		if (sub(b.cash,1,1)=="-") pal(1,8)
		spr(33, 50, 68)
		print(format_m(b.cash),10+50,70,1)
		pal()
		--controls
		print("❘ to outgoings | 🅾️ to income", 4, 90, 1) 
	elseif (menu_bud==1) then
		print("outgoings",8,20,1)
		print("monthly",64,20,1)
		--staff
		print("staff",10,32-3+out_off,1)
		spr(33, 50, 30-3+out_off)
		print("-" .. format_m(b.staff),10+50,32-3+out_off,1)
		--medicine
		print("medicines",10,40-3,1)
		spr(33, 50, 38-3)
		print("-" .. format_m(b.med),10+50,40-3,1)
		--ict
		print("ict",10,48-3,1)
		spr(33, 50, 46-3)
		print("-" .. format_m(b.it),10+50,48-3,1)
		--marketing
		print("marketing",10,56-3,1)
		spr(33, 50, 54-3)
		print("-" .. format_m(b.mar),10+50,56-3,1)
		--utilities
		print("utilities",10,64-3,1)
		spr(33, 50, 62-3)
		print("-" .. format_m(b.util),10+50,64-3,1)
		--pfi
		print("pfi",10, 72-3,1)
		spr(33, 50, 70-3)
		print("-" .. format_m(b.pfi),10+50,72-3,1)
		-- pensions
		print("pensions",10, 80-3,1)
		spr(33, 50, 78-3)
		print("-" .. format_m(b.pen),10+50,80-3,1)
		
		print("…………………………………", 8, 86, 1)
			
		--total
		print("total", 8, 92, 1)
		spr(33, 50, 90)
		print("-" .. format_m(b.out),10+50,92,1)
		--controls
		print("❘ to overview", 4, 105, 1) 
	elseif(menu_bud==2) then
		print("income",8,20,1)
		print("monthly",64,20,1)
		--gov
		print("goverment",10,32-3+out_off,1)
		spr(33, 50, 30-3+out_off)
		print(format_m(b.gov),10+50,32-3+out_off,1)
		--car
		print("car park",10,40-3,1)
		spr(33, 50, 38-3)
		print(format_m(b.car),10+50,40-3,1)
		--shop
		print("shop",10,48-3,1)
		spr(33, 50, 46-3)
		print(format_m(b.shop),10+50,48-3,1)
		--cafe
		print("cafe",10,56-3,1)
		spr(33, 50, 54-3)
		print(format_m(b.cafe),10+50,56-3,1)
		
		print("…………………………………", 8, 56-12+16, 1)
		--cash
		print("total", 8, 70, 1)
		spr(33, 50, 68)
		print(format_m(b.inc),10+50,70,1)
		--controls
		print("❘ to overview", 4, 105, 1) 
	end
end

function calc_budget()
	
	--outgoings
	b.nur = stringmul(sal.nur, s.nur)
	b.man = stringmul(sal.man, s.man)
	b.dr = stringadd(stringmul(sal.con, s.con), stringmul(sal.dr, s.dr))
	
	--adjust pay for strikes
	if (strike_dr==true or strike_con) b.dr=stringdiv(b.dr, "5")
	if (strike_nur==true) b.nur=stringdiv(b.nur, "5")
	
	b.staff = stringdiv(stringadd(stringadd(b.nur,b.man), b.dr),salx)
	b.pen = stringdiv(b.staff,penx)
	b.pfi = stringdiv(tostr(h.pfi),"10")
	b.out = stringadd(stringadd(stringadd(stringadd(stringadd(stringadd(b.staff,b.med), b.it), b.mar), b.util), b.pfi), b.pen)
	b.rev = stringsub(b.inc,b.out)
	
	--income
	b.shop = stringmul(h.shop,inc.shop)
	b.cafe = stringmul(h.cafe,inc.cafe)
	b.car = stringmul(h.car,inc.car)
	b.inc = stringadd(stringadd(stringadd(b.gov,b.car), b.cafe),b.shop)
end


function convert_sal(sal)

 local tab = {}
 
	tab.m = 0
 tab.t = sal
 tab.n = false
 
 if (tab.t>=1000) then
 	tab.m = flr(tab.t/1000)
 	tab.t = flr(tab.t%1000)
 end
 
 return tab

end


-->8
-- staff and buy screens

function update_staff_screen()
	update_t()
	update_menu(top_on)
	
	if (btnp(⬇️)) then
		sfx(0)
		s_itm+=1
	end
	
	if (btnp(⬆️)) then
		sfx(0)
		s_itm-=1
	end
	
	if (s_itm<0) s_itm=0
	if (s_itm>4) s_itm=4
	
	-- increase decrease
local point = ""

	if (s_itm>0 and s_itm <5) then
		if (s_itm==1) then
			point = "con"
		elseif (s_itm==2) then
			point = "dr"
		elseif (s_itm==3) then
			point = "nur"
		elseif (s_itm==4) then
			point = "man"
		end
		change_staff(point)
	end
	
end

function change_staff(point)
			if (point == "") return
			--if (not btnp(❘) and not btnp(🅾️)) return
			
			if (btnp(❘)) then
				if (tonum(s[point])<tonum(max_work)) then
					s[point] = stringadd(s[point], 10)
					sfx(4)
				end
			elseif (btnp(🅾️)) then
				if (tonum(s[point])>10) then
				s[point] = stringsub(s[point], 10)
				sfx(2)
				end
			end
			
			if (tonum(s[point])<10) then
				s[point]="10"
			elseif (tonum(s[point])>tonum(max_work)) then
				s[point]=tostr(max_work)
			else

			end

end



function draw_staff_screen()
	cls(7)
	draw_top_menu(top_on)
	draw_staff()
	draw_bottom_menu()
end

function draw_staff()
		local s_clr=1
		print("number of employees",8,20,1)
		
		print("consultants:", 10, 30,1)
		if (s_itm==1) s_clr=8 
		print(s.con,60,30,s_clr)
		s_clr=1
		
		if (strike_con==true) print("on strike", 86,30,8)
		
		print("junior drs:", 10, 38, 1)
		if (s_itm==2) s_clr=8 
		print((s.dr/tonum(salx)*10),60,38,s_clr)
		s_clr=1
		
		if (strike_dr==true) print("on strike", 86,38,8)
		
		print("nurses:", 10, 46, 1)
		if (s_itm==3) s_clr=8 
		print(s.nur,60,46,s_clr)
		s_clr=1
		
		if (strike_nur==true) print("on strike", 86,46,8)
		
		print("managers:", 10, 54, 1)
		if (s_itm==4) s_clr=8
		print(s.man,60,54,s_clr)
		s_clr=1
		
		print("salary per anum (fixed by nhs)", 8, 64, 1)
		
		print("consultant:", 10, 30+44,1)
		--fixed value
		spr(33, 54, 30+42)
		print(flr(sal.con*12) .. ",000",8+54,30+44,s_clr)
		
		print("junior dr:", 10, 38+44, 1)
		spr(33, 54, 30+50)
		
		print(flr(sal.dr*12) .. ",000",8+54,30+52,s_clr)
		
		print("nurse:", 10, 46+44, 1)
		spr(33, 54, 30+58)
		
		print(flr(sal.nur*12) .. ",000",8+54,30+60,s_clr)
		
		print("manager:", 10, 54+44, 1)
		
		spr(33, 54, 30+66)
		
		print(flr(sal.man*12) .. ",000",8+54,30+68,s_clr)
		
		print("❘ to increase | 🅾️ to decease", 6, 110-3, 1) 
end

-- buy screen

-- buy screen

function update_buy_screen()
	update_t()
	update_menu(top_on)

	if (btnp(⬇️)) then
		sfx(0)
		s_itm+=1
	end
	
	if (btnp(⬆️)) then
		sfx(0)
		s_itm-=1
	end
	
	
	if (s_itm<0) s_itm=0
	if (s_itm>8) s_itm=8
	
	if (btnp(❘)) buy(s_itm)

end

function draw_buy_screen()
	cls(7)
	draw_top_menu(top_on)
	draw_bottom_menu()
	draw_buy()
end

function draw_buy()

local s_clr=1
		print("cost",62,20,1)
		print("total",100,20,1)
		
		print("bed", 10, 30,1)
		spr(33, 54, 28)
		if (s_itm==1) s_clr=8
		print(format_t(cost.bed),61,30,s_clr)
		s_clr=1
		if (h.beds>10*h.floors) then
			print("@ max", 100,30,8)
		else
			print(h.beds,108,30,1)
		end
		
		print("x-ray", 10, 38, 1)
		spr(33, 54, 28+8)
		if (s_itm==2) s_clr=8
		print(format_t(cost.xray),61,38,s_clr)
		s_clr=1
		
		if (h.xray>19) then
			print("@ max", 100,38,8)
		else
			print(h.xray,108,38,1)
		end
		print("ambulance", 10, 46, 1)
		spr(33, 54, 28+8+8)
		if (s_itm==3) s_clr=8
		print(format_t(cost.amb),61,46,s_clr)
		s_clr=1
		
		if (h.amb>3) then
			print("@ max", 100,46,8)
		else
			print(h.amb,108,46,1)
		end
		
		print("new wing", 10, 54, 1)
		spr(33, 54, 28+8+8+8)
		if (s_itm==4) s_clr=8
		print(format_t(cost.wing),61,54,s_clr)
		s_clr=1
		
				if (h.floors>3) then
			print("@ max", 100,54,8)
		else
			print(h.floors,108,54,1)
		end
		
		print("car park", 10, 54+8, 1)
		spr(33, 54, 28+8+8+8+8)
		if (s_itm==5) s_clr=8
		print(format_t(cost.car),61,54+8,s_clr)
		s_clr=1
		
		if (h.car>2) then
			print("@ max", 100,54+8,8)
		else
			print(h.car,108,54+8,1)
		end
		
		print("cafe", 10, 54+16, 1)
		spr(33, 54, 28+8+8+8+8+8)
		if (s_itm==6) s_clr=8
		print(format_t(cost.cafe),61,54+16,s_clr)
		s_clr=1
		
				
		if (h.cafe>3) then
			print("@ max", 100,54+16,8)
		else
			print(h.cafe,108,54+16,1)
		end
		
		print("shop", 10, 54+16+8, 1)
		spr(33, 54, 28+8+8+8+8+8+8)
		if (s_itm==7) s_clr=8
		print(format_t(cost.shop),61,54+16+8,s_clr)
		s_clr=1
		
				if (h.shop>3) then
			print("@ max", 100,54+24,8)
		else
			print(h.shop,108,54+24,1)
		end
		
		print("loan (pfi)", 10, 54+16+8+8, 1)
		spr(33, 54, 28+8+8+8+8+8+8+8)
		if (s_itm==8) s_clr=8
		print(format_t(cost.pfi) .." @ ".. cost.int .. "%",61,54+16+8+8,s_clr)
		s_clr=1
		
		print("❘ to buy", 8, 110-3, 1) 

end

function buy(itm)
	
	if (itm==1) then
	
		if (h.beds<11*h.floors) then
			h.beds+=1
			b.cash = stringsub(b.cash,cost.bed)
			sfx(4)	
		end
	elseif (itm==2) then
		if (h.xray<20) then
			b.cash = stringsub(b.cash,cost.xray)
			h.xray+=1
			sfx(4)
		end
	elseif (itm==3) then
		if (h.amb<4) then
				b.cash = stringsub(b.cash,cost.amb)
				h.amb+=1
				sfx(4)
		end
	elseif (itm==4) then
			if (h.floors<4) then
				b.cash = stringsub(b.cash,cost.wing)
				h.floors+=1
				sfx(4)
			end
	elseif (itm==5) then
	--car park
			if (h.car<3) then
				b.cash = stringsub(b.cash,cost.car)
				h.car+=1
				sfx(4)
			end
	elseif (itm==6) then
	--cafe
		if (h.cafe<4) then
				b.cash = stringsub(b.cash,cost.cafe)
				h.cafe+=1
				sfx(4)
		end
	elseif (itm==7) then
	--shop
		if (h.shop<4) then
			b.cash = stringsub(b.cash,cost.shop)
			h.shop+=1
			sfx(4)
		end
	elseif (itm==8) then
		b.cash = stringadd(b.cash,cost.pfi)
		h.pfi=h.pfi+flr(cost.pfi) -- to make it have more effect... failed to check pfi contract?
		sfx(4)
	else
	
	end

end
-->8
--status and cqc screens

function update_status_screen()
	update_t()
	update_menu(top_on)
	calc_stats()
end

function draw_status_screen()
	cls(7)
	draw_top_menu(top_on)
		print("hospital stats",8,20,1)
		print("monthly",80,20,1)
		print("inpatient",10,30,1)
		if (h.inp=="0") then
			print("closed",86,30,8)
		else
			print(format_x(h.inp),86,30,1)
		end
		
		print("outpatient",10,38,1)
		if (h.outp=="0") then
			print("closed",86,38,8)
		else
			print(format_x(h.outp),86,38,1)
		end
		

		print("deaths",10,46,1)
		print(format_x(h.death),86,46,1)
		
		local clr = 1
		
		if (diffx>10) print("outbreak",40,54,8)
		print("c.diff",10,54,1)	
		print(format_x(h.diff),86,54,1)

		if (corx>10) print("outbreak",40,62,8)
		print("covid",10,62,1)
		print(format_x(h.cor),86,62,1)
		
		print("waiting time",8,72,1)
		print("referral",10,82,1)
		if (h.ref=="0") then
			print("closed",86,82,8)
		else
			print(h.ref .. " weeks",86,82,1)
		end
		print("scan",10,90,1)
		if (h.scan=="0") then
			print("closed",86,90,8)
		else
					print(h.scan .. " weeks",86,90,1)
		end
		print("ambulance",10,98,1)
		if (h.ambw=="0") then
			print("closed",86,98,1)
		else
			print(h.ambw .. " mins",86,98,1)
		end
		
		print("a+e",10,106,1)
		if (h.em=="0") then
			print("closed",86,106,8)
		else
			print(h.em .. " hours",86,106,1)
		end
	draw_bottom_menu()
end

function calc_stats()
	
	local drs = s.dr
	local con = s.con
	local nur = s.nur
	
	if (strike_dr==true) drs = stringdiv(s.dr,"5")
	if (strike_con==true) con = stringdiv(s.con,"5")
	if (strike_nur==true) nur = stringdiv(s.nur,"5")

	local staff = stringadd(con, stringadd(drs,nur))
	local pat
	--inpatients
	h.inp = stringmul(s.con,"10")
	if (cls_in==true) h.inp = "0"
	
	--outpatients
	h.outp = stringdiv(stringmul(stringadd(stringmul(drs,"2"), nur), h.beds), 5)
	if (cls_out==true) h.outp = "0"
	--coronavirus
	h.cor = stringmul(corx,stringdiv("10000",nur))
	
	--cdiff
	h.diff = stringmul(diffx,stringdiv("10000",staff))
	
	--deaths
	h.death = stringmul(stringadd(stringdiv(stringadd(h.cor,h.diff),"5"),stringmul(stringdiv(stringmul(stringadd(h.inp,h.outp),tostr(h.cafe)+1), staff),"10")),deathx)

	--refer
	h.ref = stringmul(stringdiv("4800", stringadd(drs,con)),staffx)
	
	--scan
	h.scan = stringmul(stringdiv(stringadd(h.inp, h.outp), tostr(h.xray*10)),staffx)
	
	--amb
	h.ambw = stringdiv("126", h.amb)
	
	--a+e
	h.em = stringmul(stringdiv("7800", stringadd(drs,nur)),staffx)
end

--cqc

function update_cqc_screen()
	update_t()
	update_menu(top_on)
	calc_stats()
end

function draw_cqc_screen()
	cls(7)
	draw_top_menu(top_on)
	
	print("care quality commission",8,20,1)
	print("overall rating",8,30,1)
	string, clr = cqc_score(cqc.r)
	print(string,72,30,clr)
	
	print("safe",10,40,1)
	string, clr = cqc_score(cqc.safe)
	print(string,72,40,clr)
	
	print("effective",10,48,1)
	string, clr = cqc_score(cqc.ef)
	print(string,72,48,clr)
	
	print("caring",10,56,1)
	string, clr = cqc_score(cqc.car)
	print(string,72,56,clr)
	
	print("responsive",10,64,1)
	string, clr = cqc_score(cqc.res)
	print(string,72,64,clr)
	
	print("well-led",10,72,1)
	string, clr = cqc_score(cqc.well)
	print(string,72,72,clr)
	
	print("finance",10,80,1)
	string, clr = cqc_score(cqc.fin)
	print(string,72,80,clr)
	draw_bottom_menu()
end

function calc_cqc()
	local drs = s.dr
	local con = s.con
	local nur = s.nur
	local diff= stringmul(h.diff,diffx)
	local cor = stringmul(h.cor,corx)
	
	if (strike_dr==true) drs = stringdiv(s.dr,"5")
	if (strike_con==true) con = stringdiv(s.con,"5")
	if (strike_nur==true) nur = stringdiv(s.nur,"5")

	local staff = stringadd(con, stringadd(drs,nur))
	local pat
	local var
	
	if (corx>1 or diffx>1) then
		cqc.safe=1
	else
		--cqc.safe = 1
		if (tonum(h.death)<20) then
			if ((tonum(stringadd(diff,cor))<30)) then
				cqc.safe=4
			else
				cqc.safe=3
			end
		elseif (tonum(h.death)<30) then
			cqc.safe=2
		else
			cqc.safe=1
		end
	end
	
	--cqc.ef
	cqc.ef = month_rnd -- a mystery!
	
	--cqc.car = 1
	var = tonum(stringsub(nur,s.man))
	if (var>400) then
	
		if (var>600) then
		
			if (var>800) then
				cqc.car=4
			else
				cqc.car=3
			end
			
		else
			cqc.car=3
		end
		cqc.car=2
	else
		cqc.car=1
	end
	
	--cqc.res = 1
	if (tonum(h.ref)<15) then
		
		if (tonum(h.scan)<20) then
			
			if (tonum(h.ambw)<30) then
				
				if (tonum(h.em)<8) then
						cqc.res=4
				else
					cqc.res=3
				end
			
			else
				cqc.res=2
			end
		
		else
			cqc.res=2
		end
		cqc.res=1
	else
		cqc.res=1
	end
	
	--cqc.well = 1
	var = tonum(stringsub(staff, s.man))
	
	if (var>700) then
		
		if (var>1000) then
			
			if (var>1500) then
				
				if (tonum(s.man)>200) then
					cqc.well=4
				else
					cqc.well=3
				end
				
			else
				cqc.well=3
			end
			
		else
			cqc.well=2
		end
		cqc.well=1
	else
		cqc.well=1
	end
	
	--cqc.fin
	if (tonum(b.rev)>0) then
		
		if (tonum(b.cash)>0) then
			
			if (tonum(b.rev)>100) then
				cqc.fin=4
			else
				cqc.fin=3
			end
		
		else
			cqc.fin=2
		end
			
			cqc.fin=2
	
	else
		
		cqc.fin=1
	
	end


	cqc.r = flr((cqc.safe+cqc.ef+cqc.car+cqc.res+cqc.well+cqc.fin)/6)

end

function cqc_score(score)

local string
local clr

		if(score==1) then
			clr=8
			string="inadequate"
		elseif (score==2) then
			clr=9
			string="need improve"
		elseif (score==3) then
			clr=3
			string="good service"
		elseif (score==4) then
			clr=11
			string="outstanding"
		end
		
		return string, clr

end

-->8
-- event screen

---actual events
function init_events()
events = {

{
	num = 1,
	title = "new ceo",
	text = {"welcome to footmouth unviersity\nhospital foundation trust.\n\n".. slogan .. "\n\nthank you for accepting our\noffer to be the new ceo.\n\nthe previous ceo left in a\nbit of a hurry.\n\nso we need you to hit the\nground running.\n\n▒▒▒▒▒▒", 
"but before you start, we need\nyou to complete the following\nonline training modules:\n\n★ health & safety\n★ diversity & inclusion\n★ fire safety\n★ data protection\n★ hand washing\n★ moving & handling\n★ prevent\n★ conflict resolution\n★ sageguarding\n★ corruption\n\n▒▒▒▒▒▒"},
	trigger = function(self) 
		month+=1
		day=1
		event_num+=1
		end_month()
		end
},
{
	num = 2,
	title = "care quality commission",
	text = {"thank you for completing all\nthe training modules.\n\nsorry it took you so long.\n\nin the meantime, the care\nquality commission (cqc)\nmade an inspection.\n\nunfortunately, they rated\nthe hospital:\n\ninadequate 😐\n\n▒▒▒▒▒▒", 
	"please help!\n\nwe need to improve our cqc\nrating. fast.\n\nthe people of footmouth are\ndepending on you.\n\nas you know, mangement bonuses\nare also linked to cqc ratings.\n\n--\nsigned, senior leadership team\nfootmouth hospital\n\n▒▒▒▒▒▒", 
	"ps: you'll probably need to\nknow how to control things.\n\nuse the arrow keys ⬅️➡️⬆️⬇️\nto select from the menu.\n\npress ❘ to confirm.\n\nthat's it. good luck!\n\nand don't forget:\n\n" .. slogan .. "\n\n▒▒▒▒▒▒"}, 
	trigger = function(self)
		day=1
		event_num+=1
		reset_e()
	end
},
{
	num = 3,
	title = "doctors strike",
	text = { "unfortunately, junior doctors\nare going on strike.\n\nonly 20% of junior doctors will\nbe available until the strike\nends.\n\nthey are asking for a 12%\npay increase.\n\nyou can either:\n\n❘ ignore strike \n🅾️ accept pay deal"}, 
	alt_text= { "junior doctors are still on\nstrike.\n\nonly 20% of junior doctors will\nbe available until the strike\nends.\n\nthey are asking for a 12%\npay increase.\n\nyou can either:\n\n❘ ignore strike \n🅾️ accept pay deal"},
	trigger = function(self)
		day=1
		if (lastdec=="❘") then
			strike_dr=true
		elseif (lastdec=="🅾️") then
			strike_dr=false
			sal.dr = stringadd(sal.dr,"1")
		end
		calc_budget()
		reset_e()
	end
},
{
	num = 4,
	title = "consultant strike",
	text = { "unfortunately, consultants are\ngoing on strike.\n\nonly 20% of consultants will\nbe available until the strike\nends.\n\nthey are asking for a 14%\npay increase.\n\nyou can either:\n\n❘ ignore strike \n🅾️ accept pay deal"}, 
	alt_text = { "consultants are still\non strike.\n\nonly 20% of consultants will\nbe available until the strike\nends.\n\nthey are asking for a 14%\npay increase.\n\nyou can either:\n\n❘ ignore strike \n🅾️ accept pay deal"}, 
trigger = function(self)
		day=1
		if (lastdec=="❘") then
			strike_con=true
		elseif (lastdec=="🅾️") then
			strike_con=false
			sal.con = stringadd(sal.con,"1")
		end
		calc_budget()
		reset_e()
	end
},
{
	num = 5,
	title = "nurse strike",
	text = { "unfortunately, nurses are\ngoing on strike.\n\nonly 20% of nurses will\nbe available until the strike\nends.\n\nthey are asking for a 9%\npay increase.\n\nyou can either:\n\n❘ ignore strike \n🅾️ accept pay deal"}, 
	alt_text = { "nurses are still\non strike.\n\nonly 20% of nurses will\nbe available until the strike\nends.\n\nthey are asking for a 9%\npay increase.\n\nyou can either:\n\n❘ ignore strike \n🅾️ accept pay deal"}, 
trigger = function(self)
		day=1
		if (lastdec=="❘") then
			strike_nur=true
		elseif (lastdec=="🅾️") then
			strike_nur=false
			sal.nur = stringadd(sal.nur,"1")
		end
		calc_budget()
		reset_e()
	end
},
{
	num = 6,--corona
	title = "coronavirus outbreak",
	text = { "a novel coronavirus has been\nidentified.\n\ninfections and deaths are\nrising.\n\nstaff sickness increased.\n\nyou can either:\n\n❘ ignore outbreak\n🅾️ close outpatients"}, 
	alt_text = { "the covid-19 outbreak is still\nongoing.\n\ninfections and deaths are\nrising.\n\nstaff sickness increased.\n\nyou can either:\n\n❘ ignore outbreak\n🅾️ close outpatients"}, 
trigger = function(self)
	
		if (lastdec=="❘") then
			corx+=5
		elseif (lastdec=="🅾️") then
			corx=10
			cls_out=true
		end
		calc_stats()
		day=1
		reset_e()
	end
},
{
	num = 7,--cdiff
	title = "c.diff outbreak",
	text = { "clostridioides difficile is\nout of control.\n\ninfections and deaths are\nrising.\n\nstaff sickness increased.\n\nyou can either:\n\n❘ ignore outbreak\n🅾️ close inpatients"}, 
	alt_text = { "the c.diff outbreak is still\nongoing\n\ninfections and deaths are\nrising.\n\nstaff sickness increased.\n\nyou can either:\n\n❘ ignore outbreak\n🅾️ close inpatients"}, 
trigger = function(self)
		
		if (lastdec=="❘") then
			diffx+=5
		elseif (lastdec=="🅾️") then
			diffx=10
			cls_in=true
		end
		calc_stats()
		day=1
		reset_e()
	end
},
{
	num = 8,--cdiff open
	title = "c.diff infections down",
	text = { "the c.diff outbreak is under\ncontrol.\n\nwe can now safely open\ninpatients.\n\n" .. slogan}, 
	alt_text={""},
trigger = function(self)
		
			diffx=10
			cls_in=false
		
		day=1
		calc_stats()
		reset_e()
	end
},
{
	num = 9,--cdiff open
	title = "covid infections down",
	text = { "the covid-19 outbreak is under\ncontrol.\n\nwe can now safely open\noutpatients.\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		
			diffx=10
			cls_out=false
		
		day=1
		calc_budget()
		reset_e()
	end
},
{
	num = 10,--marketing
	title = "new brand",
	text = { "the the marketing department\ncommissioned an external\nagency to develop a new brand.\n\nit cost 1 million, but we think\nit is money well spent.\n\nyou should make the final\ndecision.\n\nplease choose either:\n\n❘ passion.care.excellence.\n\n🅾️ excellence.together.care."}, 
	alt_text={""},
	trigger = function(self)
		if (lastdec=="❘") then
			slogan="★ passion.care.excellence ★"
		elseif (lastdec=="🅾️") then
			slogan="★ excellence.together.care. ★"
		end
		day=1
		b.cash=stringsub(b.cash,"100")
		b.mar=stringadd(b.mar,"50")
		init_events()
		calc_budget()
		reset_e()
	end
},
{
	num = 11,--american drugs cost
	title = "new medicines deal",
	text = { "the health minister has\nnegotiated a new contract\nfor medicines supplied by\namerican companies.\n\nthe us president and\nthe uk prime minister made\na statement celebrating\nthe new deal.\n\ncost of all medicines\nhas increased by 2 million.\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		day=1
		b.med=stringadd(b.med,"200")
		calc_budget()
		reset_e()
	end
},
{
	num = 12,--eu drugs cost
	title = "eu medicines legislation",
	text = { "the health minister has\nannounced that medicines\nimported from the european\nunion will be subject to\nimport tariffs.\n\ncost of all medicines\nhas increased by 1 million.\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		day=1
		b.med=stringadd(b.med,"100")
		calc_budget()
		reset_e()
	end
},
{
	num = 13,--legal case
	title = "legal case",
	text = { "the trust lost a major legal\ncase for clinical negligence.\n\nwe are required to pay:\n\n30 million compensation\n\n12 million in costs\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		day=1
		b.cash=stringsub(b.cash,"420")
		calc_budget()
		reset_e()
	end
},
{
	num = 14,--it costs
	title = "new it system",
	text = { "the it department has purchased\na new computer system from a\nmajor us supplier.\n\nthe monthly cost is 2 million\n\nstaff productivity has\ndecreased by 50% this month.\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		day=1
		b.it=stringadd(b.it,"200")
		staffx="2"
		calc_budget()
		reset_e()
	end
},
{
	num = 15,--pension
	title = "pay discrimination",
	text = { "the trust has lost a major\nlegal case for pay\ndiscrimination.\n\nwe were found to have paid male doctors\n30% more than female doctors.\n\nwe are now required to pay:\n\n20 million compensation\n\n30% pension uplift\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		day=1
		b.cash=stringsub(b.cash,"200")
		penx="6"
		calc_budget()
		reset_e()
	end
},
{
	num = 16,--gov funding
	title = "government funding",
	text = { "the health minister has\nannounced changes to government\nfunding.\n\na spokesperson said:\n\n\"we will cut down on waste in\nthe health service.\"\n\ngovernment funding has been\nreduced by 3 million.\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		day=1
		b.gov=stringsub(b.gov,"300")
		penx="6"
		calc_budget()
		reset_e()
	end
},
{
	num = 17,--border
	title = "border control",
	text = { "the home office has announced\nstrict quotas for foreign\nworkers.\n\ntotal available doctors\nand nurses reduced by 50%\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		day=1
		max_work="300"
		if (tonum(s.dr)>tonum(max_work)) s.dr=max_work
		if (tonum(s.con)>tonum(max_work)) s.con=max_work
		if (tonum(s.nur)>tonum(max_work)) s.nur=max_work
		calc_budget()
		reset_e()
	end
},
{
	num = 18,--border
	title = "manager pay",
	text = { "following a performance review\nthe government has agreed to\nincrease manager pay by 10%\n\nthis is excellent news!\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		day=1
		sal.man=stringadd(sal.man,"1")
		calc_budget()
		reset_e()
	end
},
{
	num = 19,--pfi
	title = "pfi interest rates",
	text = { "due to changes in the bond\nmarket, the interest rate for \nprivate finance initiative\n(pfi) loans has increased by 4%\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		day=1
		cost.int+=4
		calc_budget()
		reset_e()
	end
},
{
	num = 20,--energy
	title = "rising energy prices",
	text = { "global political instability\nhas caused a spike in\nenergy prices.\n\nthe cost of utilities has\nincreased by 10%\n\n" .. slogan}, 
	alt_text={""},
	trigger = function(self)
		day=1
		b.util = stringadd(b.util,"54")
		calc_budget()
		reset_e()
	end
},
{
	num = 21,--heating
	title = "heating problem",
	text = { "over the weekend, the hospital\nheating system failed.\n\nan external contractor has\nquoted 1 million to fix.\n\nchoose either:\n\n❘ to fix\n\n🅾️ to ignore\n\n" .. slogan}, 	
	alt_text={"the heating is still broken.\nthe number of patient deaths\nhas increased.\n\nan external contractor has\nquoted 1 million to fix.\n\nchoose either:\n\n❘ to fix\n\n🅾️ to ignore\n\n"},
	trigger = function(self)
		day=1	
		if (lastdec=="❘") then
			b.cash=stringsub(b.cash, "100")
			deathx="1"
		elseif (lastdec=="🅾️") then
			deathx="2"
		end
		calc_budget()
		reset_e()
	end
},
{
	num = 22,--minister visit
	title = "minister visit",
	text = { "the health minister plans to\nvisit our hospital this month.\n\nwe need to prepare and\nmake a good impression.\n\nstaff productivity decreased\nby 50% this month.\n\n" .. slogan}, 	
	alt_text={""},
	trigger = function(self)
		day=1	
		staffx="2"
		calc_budget()
		reset_e()
	end
},
{
	num = 23,--new gov
	title = "change of government",
	text = { "following the general election\na new government has been\nappointed.\n\nthe new prime minister said\nin a statement:\n\n\"the nhs is our top priority.\"\n\ngovernment funding is reduced\nby 10%.\n\n" .. slogan}, 	
	alt_text={""},
	trigger = function(self)
		day=1	
		b.gov=stringsub(b.gov,"700")
		calc_budget()
		reset_e()
	end
},
{
	num = 24,--physician associates
	title = "new healthcare professional",
	text = { "the general medical council has\nagreed to certify a new medical\nrole:\n\n\"physician associate\"\n\nthis could help us reduce staff\ncosts.\n\nchoose either:\n\n❘ replace 50% of doctors\n\n🅾️ keep current staff\n\n" .. slogan}, 	
	alt_text={""},
	trigger = function(self)
		day=1	
		if (lastdec=="❘") then
			salx="20"
			deathx="2"
		end
		calc_budget()
		reset_e()
	end
},
}

end
-- functions

function update_event_screen()

if reading	then
	tb_update() -- handle the text box on every frame update.
end

end

function draw_event_screen()
 cls(7)
 rectfill(0,0, 128,12,1)
	spr(12,4,1,3,1)
	print(get_month(month) .. " " .. year,8+26,4, 7)
	string, clr = cqc_score(cqc.r)
	print(string,72,4,clr)
	if reading then
		print("▒" .. events[event_num].title .. "▒",2, 20,1)
	end
	tb_draw() -- to draw text boxes, this function must be called. it is processed when reading is true, so there is no need to do a check here.
end

function end_month()
	local str
	month_rnd=flr(rnd(4))+1
	staffx="1" -- reset productivity
	if (month==2) month_rnd=1
	update_cash()
 calc_stats()
	calc_cqc()
	
	-- check for game over
	if (tonum(b.cash)<-1000) then
		game_over=true
		return
	end
	new_event()
	if(event_num==1) cqc.r=2
	if(event_num==2) cqc.r=1
	if not reading then -- if tb_init has been called, reading will be true and a text box is being displayed to the player. it is important to do this check here because that way you can easily separete normal game actions to text box inputs.
		str = events[event_num].text
		--switch to alt text for certain events
		if ((event_num==21 and tonum(deathx)>1) or (event_num==7 and diffx>10) or (event_num==6 and corx>10) or (event_num==5 and strike_nur==true) or (event_num==4 and strike_con==true) or (event_num==3 and strike_dr==true)) str = events[event_num].alt_text
		--don't repeat certain events
		if (event_num==24 and tonum(salx)>10) event_num=23
		-- if reading is false, then a text box is not being displayed. here you would put your normal game code. also, calls to brande new text boxes must be made only when reading is false, to avoid errors and conflicts.	
		tb_init(0,str) -- when calling for a new text box, you must pass two arguments to it: voice (the sfx played) and a table containing the strings to be printed. this table can have any number of strings separated with a comma.
	end

end

function update_cash()
	calc_budget()
	b.cash = stringadd(b.cash,b.rev)
end

function new_event()
		
		sfx(3)
		-- random event
		if(event_num>2) event_num=3+(flr(rnd(#events-2)))
		
		--overrides
		if (event_num==8 and cls_in==false) event_num=7
		if (event_num==9 and cls_out==false) event_num=6

		if (cls_in==true) event_num=8
		if (cls_out==true) event_num=9
		if (event_num==15 and tonum(penx)<10) event_num=14
		if (event_num==16 and tonum(b.gov)<500) event_num=10
		
end

function reset_e()
		screen=0
		top_on=true
		s_itm=0
		save_game()
end