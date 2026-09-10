-- dragon crawler carla
-- by knight vision, 2026 v1.0

function draw_logo()
  pic="0aaaa0000000000000aaaaaaaaaaaa000000000aaaaaaaa000000000000aaaaaaa000000aaaaaaaa000000000aaaa000000000aa0000000000000000000000000aaaaaaa0000000000aaaaaaaaaaaaa0000000aaaaaaaaaa000000000aaaaaaaaa0000aaaaaaaaaaaaa000000aaaa0000000aaaa0000000000000000000000000aaaaaaaaaa0000000aaaaaaa00aaaaa000000aaaa00aaaaa0000000aaaaaaaaaa0000aaaaaaaaaaaaa000000aaaaa000000aaaa0000000000000000000000000aaaaaaaaaaaa00000aaaa000000aaaa00000aaaa0000aaaa000000aaaaaaa0000000aaaaaaaaaaaaaaa00000aaaaaa00000aaaa0000000000000000000000000aaaaaaaaaaaaa0000aaaa0000000aaa0000aaaaa0000aaaa00000aaaaaa000000000aaaaaa0000aaaaaa0000aaaaaa00000aaaa00000000000000000000000000aaaaaaaaaaaaa0000aaa0000000aaa0000aaaa000000aaa00000aaaaa000000000aaaaaa000000aaaaa0000aaaaaaa0000aaaa00000000000000000000000000aaaaaaa0aaaaa0000aaa0000000aaa0000aaaa000000aaaa000aaaaa0000000000aaaaa0000000aaaaa0000aaaaaaaa000aaaa00000000000000000000000000aaaa00000aaaaa000aaa000000aaaa0000aaa0000000aaaa000aaaa00000000000aaaaa0000000aaaaaa000aaaaaaaa000aaaa00000000000000000000000000aaaa000000aaaa000aaaaaaaaaaaaa000aaaa0000000aaaa000aaaa00000000000aaaaa0000000aaaaaa000aaaaaaaaa00aaaa000000000000000000000000000aaa0000000aaa000aaaaaaaaaaaaa000aaaaa0000aaaaaa000aaaa00000000000aaaaa0000000aaaaaa000aaaa0aaaa00aaaa000000000000000000000000000aaa0000000aaaa000aaaaaaaaaa00000aaaaaaaaaaaaaaa000aaaa00000000000aaaaa0000000aaaaaa000aaaa0aaaaa0aaaa000000000000000000000000000aaa0000000aaaa000aaaaaaaaaa00000aaaaaaaaaaaaaaaa00aaaa0000aaaaaa0aaaaa0000000aaaaaa00aaaaa00aaaaaaaaa000000000000000000000000000aaa0000000aaaa000aaaaaaaaaaa0000aaaaaaaaaaaaaaaa00aaaa0000aaaaaa0aaaaa0000000aaaaa000aaaaa00aaaaaaaaa000000000000000000000000000aaa0000000aaaa000aaaa00aaaaaaa00aaaaaa000000aaaa000aaa0000aaaaaa00aaaaa00000aaaaaa000aaaaa000aaaaaaaa000000000000000000000000000aaa0000000aaaa000aaaa000aaaaaaa0aaaa00000000aaaa000aaa0000000aaa00aaaaa0000aaaaaaa000aaaaa0000aaaaaaa000000000000000000000000000aaa000000aaaa00000aaa0000aaaaaa0aaaa000000000aaa000aaaa00000aaaa00aaaaaaaaaaaaaaa0000aaaaa00000aaaaaa000000000000000000000000000aaa00000aaaaa00000aaa00000aaaaa0aaaa000000000aaa000aaaaa000aaaaa000aaaaaaaaaaaaaa0000aaaaa000000aaaaa000000000000000000000000000aaa0aaaaaaaaa0000aaaaa00000aaaa0aaaa000000000aaa000aaaaaaaaaaaaa0000aaaaaaaaaaaa00000aaaaa0000000aaaa00000000000000000000000000aaaaaaaaaaaaaa0000aaaaa000000aaa0aaa0000000000aaa0000aaaaaaaaaaa000000aaaaaaaaaa000000aaaaa00000000aaa00000000000000000000000000aaaaaaaaaaaaaa0000aaaaa000000aaa0aaa0000000000aaa00000aaaaaaaaa00000000aaaaaaaa00000000aaaa000000000aa00000000000000000000000000aaaaaaaaaaaaa00000aaaaa000000aaa0aaa000000000000000000000000000000000000000000000000000aaa000000000000000000000000000000000000000aaaaaaaaaa0000000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaaa0000aaaaaaaa0000000000aaaa00000aa000000000aa00aaaa00000000000aaaa0000aaaaaa000000000000000000000000000000000000000000000000aaaaaaa00aaaaaaaa00000000aaaaaaa0000aa000000000aa00aaaa00000000aaaaaaa000aaaaaaaa000000000000000000000000000000000000000000000aaaaaaaaa00aa0000aaa000000aaaaaaaa0000aa000000000aa00aaaa000000aaaaaaaaa000aaaaaaaaa00000000000000000000000000000000000000000000aaaa00aaa00aa0000aaa000000aaaaaaaa0000aa000000000aa000aaa000000aaaa00000000aaa000aaaa000000000000000000000000000000000000000000aaa000000000aa000aaaa00000aaa000aaa0000aa000000000aa000aaa000000aa0000000000aaa0000aaa000000000000000000000000000000000000000000aaa000000000aaaaaaaaa00000aaa000aaaa000aa000000000aa000aa0000000aaaa00000000aaa0000aaa000000000000000000000000000000000000000000aaa000000000aaaaaaaa000000aaa0000aaa000aa000aa0000aa000aa00000000aaaaa000000aaa000aaaa000000000000000000000000000000000000000000aaa000000000aaaaaa00000000aaa0aa0aaa000aa000aa0000aa000aa000000000aaaa000000aaaaaaaaa0000000000000000000000000000000000000000000aaa000000000aaaaaaa0000000aaaaaaaaaa000aa000aa0000aa000aa00000000aaaa0000000aaaaaaaa00000000000000000000000000000000000000000000aaa000000000aaa0aaaa00000aaaaaaaaaaa000aa00aaaa000aa000aa00000000aaa00000000aaaaaaa000000000000000000000000000000000000000000000aaaa0000aa00aaa00aaaaa000aaaa000aaaa000aaa0aaaa00aaa000aa00000000aa000000000aaa0aaaa00000000000000000000000000000000000000000000aaaaa0aaaa00aaa0000aaaa00aaaa00000aa000aaaaaaaaaaaaa000aaaaaaaa00aaa000aaa00aaa00aaaa00000000000000000000000000000000000000000000aaaaaaaaa00aaa00000aaa00aaaa00000aaa000aaaaaaaaaaa0000aaaaaaaa00aaaaaaaaa00aaa000aaaa00000000000000000000000000000000000000000000aaaaaa0000aaa000000aa00aaaa00000aaa0000aaa000aaaa0000aaaaaaaa000aaaaaaa000aaa0000aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000000aaaa00000000000000000000000000aaaaa000000aaa0000000000000000aa0000000000000000000000000000000000000000000000000000000000000000aaaaaaaaa00000000000aaaa0000aaaaaaaaaa00000aaa000000000000000aaaa0000000000000000000000000000000000dddddd000000000000000000000aaaaaaaaaaaa00000000aaaaaaa000aaaaaaaaaaa0000aaa00000000000000aaaaaa00000000000000000000000000000000dddddddd0000000000000000000aaaaa0000aaaaa000000aaaaaaaaa00aaaaaaaaaaa0000aaa0000000000000aaaaaaa00000000000000000000000000000ddddddddddd0000000000000000000aaaa0000000aaa00000aaaaaaaaaa00aaaaa000aaaa000aaa000000000000aaaa00aaa0000000000000000000000000000000dddd7f7d0000000000000000000aaaa00000000aa0000aaaaa00aaaaa0aaa00000aaaa000aaaa00000000000aaa000aaa0000000000000000000000000000d0dddd70f1700000ff00000000000aaaa000000000000000aaaa0000aaaa0aaa00000aaaa000aaaa00000000000aaa0000aa00000000000000000000000000000ddddffffff0000fff00000000000aaa0000000000000000aaa00000aaaa0aaa0000aaaaa000aaaa0000000000aaa00000aaa0000000000000000000000000d000dddffffff000005500000000000aaa000000000000000aaaa000000aaa0aaaaaaaaaaaa0000aaa0000000000aaaa0000aaa00000000000000000000000044dddddddff88f000005500000000000aaa000000000000000aaaaaaaaaaaaa0aaaaaaaaaaa00000aaa0000000000aaaa00aaaaa00000000000000000000000000400ddddffff0000055500000000000aaaa00000000000000aaaaaaaaaaaaa00aaaaaaaaa000000aaa00000000000aaaaaaaaaa00000000000000000000404000400ddd545ff4555555500000000000aaaa000000000aa000aaaaaaaaaaaaa00aaaaaaaaa000000aaa00000000000aaaaaaaaaa00000000000000000000eee40444dd5d5a455a555555000000000000aaaa00000000aaa000aaaa000000aaa00aaaaaaaaaa00000aaa00aaaaa0000aaaaaaaaaa00000000000000000000e4e44440055d55a55a555550000000000000aaaaaa000aaaaaa000aaa00000000aa00aaaa0aaaaaa0000aaaaaaaaaaa000aaaaaa00aa00000000000000000000444444405555555aa555000f0000000000000aaaaaaaaaaaaaa000aaa00000000aa00aaaa00aaaaaa000aaaaaaaaaaa000aaaa0000aa000000000000000000000040404255555288855500fff0000000000000aaaaaaaaaaaa000aaaa00000000aa00aaaa000aaaaa000aaaaaaaaaaa000aaaa0000aa00000000000000000000004442225550088855550dfff000000000000000aaaaaaaa00000aaaa00000000aa00aaaa0000aaaa000aaaaaaaaaaa000aaaa0000aa0000000000000000000000002222000099855555dafff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002200000aa0555555adfff00000060000000000ccc00000000006668666866600000000066000000000000000000000000000000000000000000000000000000002000bee00555adda80ff0000006050000000666660000000006668868866600000006666660000000000000000000000000000000000000000000000000000000006bb000dd8adda80ff00006666600000000555005000000056585858565000000006cc6000000000005555550000000000000000000000000000000000000000066000daaaaa0000ff00005555500006666666666660000056585658565000066666666666600000005555550000000000000000000000000000000000000000000000fddad00000ff0ff0666660000055555556565000005656565656500006000066000060000055555555000000006656666000000000000000000000000000000fffda00000fffff0066666000006666666656500000565656565650000666666666666000009595966600000666665555000000000000000000000000000000ffffd000000ff0000066666000005555555656600000565656565650000600006600006000005555566600000555555666600000000000000000000000000000fff0000000000000006666600000666666665650000056565656565000066666666666600000959596660000060065555500000000000000000000000000000fff0000000000000000666660000055555556566000005656565656500006000066000060000055555666000006606556666000000000000000000000000000ff00000000000000000066666000006666666656500000565656565650000666666666666000009595966600000600655555500000000000000000000000000ff000000000000000000066666000005555555656500000565656565650000600006600006000005555566600000606655556600000000000000000000000000ff0000000000000000000666660000066666666565000005656565656500006666666666660005555555555555006006560c00000000000000000000000000000ff000000000000000000666660000055555556565000005656565656500006000066000060005555666666666006666565060000000000000000000000000000fff0000000000000000055555000006666666656500000565656565650000666666666666000566566969696600555555666600000000000000000000000000000000000000000000006666666000055555556565000005656565656500006666666666660005665666666666006666556006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

  txt_to_pic(pic)
  print("hit ❘ to start",36,104,6)
  print("by brett king, 2026",50,114,7)   
  print("v1.0",4,114,6)
  
  print("get carla to her events",16,80,10)
  print("before time expires, collect",6,88,10)
  print("ribbons, and have fun!",18,96,10)
end

function txt_to_pic(txt)
 cls(0)
 local d={
 a=10,
 b=11,
 c=12,
 d=13,
 e=14,
 f=15
 }
 d['0']=0
 d['1']=1
 d['2']=2
 d['3']=3
 d['4']=4
 d['5']=5
 d['6']=6
 d['7']=7
 d['8']=8
 d['9']=9
	local x=0
	local y=2
	for i=0,#txt do
		if x>128 then 
			x=1
			y+=1
		end
 c=d[sub(txt,i,i)]
 pset(x+7,y,c)
 x+=1
	end
end

function _init()
  scr_max=2
  
  pal(1,0)
  
  logo=true
  music(0)
  
  mobs={}
  mobs.fr=1
  mobs.fc=0
    
  pl={}
  pl.fr=1
  pl.fc=0
  pl.fl=1
  pl.x=0
  pl.y=24
  pl.h=16
  pl.w=8
  pl.frozen=true
  pl.failed=true
  pl.elev=0
  pl.escal=0
  pl.dir=0
  pl.event_cnt=0
  pl.health=20
  pl.ribbons={}
  pl.timer=10
  pl.scr_cnt=1
  pl.time=1
  pl.fail_str="you were too slow!"
  -- sfx(4)
  pl.face_left=false  
  pl.done=false
  fail_played=false
  robot_onscreen=false
  crp_comm={}
  crp_comm[1]="do you even#read dcc?"
  crp_comm[2]="not canon"
  crp_comm[3]="who are you#supposed to be?"
  
  pbox={}
  pbox.x=pl.x+5
  pbox.y=pl.y
  pbox.w=8
  pbox.h=16
  
  speed=8
  --debug("begin",true)
  num_sprs=13
  mob_spr={3,5,7,9,11,13,64,66,68,70,72,74,76}
  h_spd={2,2,1,3,1,2,1,0,1,1,1,2,1}

  init_maps()  
  init_elev()
  init_cars()
  init_pics()
end

function update_pl_fr()
  pl.fr=3-pl.fr
end

function update_mobs_fr()
  mobs.fc+=1
  if mobs.fc>=5 then
    mobs.fc=0
    mobs.fr=3-mobs.fr
  end
end

function _update()
  if logo then
    for i=0,5 do
      if btn(i) then       
        logo=false
        music(-1)
        break
      end
    end
  elseif pl.map==maps.win then
    if btnp(❘) then
       stop()
    end
  elseif pl.timer>0 and
	      pl.done!=true and 
	      pl.map!=maps.sched then
	    --debug("decr timer")
	    pl.timer-=0.01
	    if pl.timer<5 and
	      stat(46)==-1 then
	      sfx(7)
	    end
	 end
	 
	 if not pl.frozen and not
	    pl.done and
	    pl.timer>0 and
	    pl.map!=maps.win then
	    update_pl()
	 end  
	
	 if pl.done==true then
	    update_done()
	 elseif pl.timer<=0 then
	    update_fail()
	 else
	    update_maps()
	 end
end

function update_pl()
  pl.cx=0
  pl.cy=0
  
  if btnp(⬆️) then   
    if pl.map==maps.elev then
      for i=1,3 do
        if pl.fl==elev[i].fl and
         pl.x==elev_xs[i] and
         elev[i].mob==0 and
         elev[i].door!=door.closed then
           -- enter elevator
           pl.frozen=true
           pl.elev=i
           break           
        elseif pl.fl==1 and
            pl.x==escal[1].bot.x then
            -- board escalator
	           board_escal(1,1)        
        elseif pl.fl==2 and
            pl.x==escal[2].bot.x then
            -- board escalator
            board_escal(2,1)
        end
      end       
    elseif pl.map==maps.street or
           pl.map==maps.lobby then
      if pl.y>24 then
        pl.cy-=speed
      end
    elseif pl.y>32 then
    	 pl.cy-=speed      
    end
  elseif btnp(⬇️) then
    if pl.map==maps.lobby and
       pl.y<100 then 
       pl.cy=speed
    elseif pl.map==maps.street then
       if pl.y<100 then
          pl.cy=speed
       end
    elseif pl.map!=maps.elev 
       and pl.y<92 then
       pl.cy=speed
    elseif pl.map==maps.elev then     
         if pl.fl==2 and
            pl.x==escal[1].top.x then
            -- board escalator
	           board_escal(1,2)        
         elseif pl.fl==3 and
            pl.x==escal[2].top.x then
            -- board escalator
            board_escal(2,2)
         end
    end       
  end
  if btnp(➡️) then 
    pl.face_left=false
    if pl.elev>0 then
      pl.elev=0
    end
    if exit_map() then
       pl.cx=0
       next_map()
    else
       if pl.x<=exit.x then
         pl.cx=speed
       end
    end          
  elseif
    btnp(⬅️) and pl.x>7 then
    if pl.elev>0 then
      pl.elev=0
    end
    pl.cx=0-speed
    if pl.map==maps.elev then
      pl.face_left=true
    end
  end
  
  pl.x+=pl.cx
  pl.y+=pl.cy

  if pl.map==maps.lobby then
    ty=find_pl_i(pl.y)
    tx=find_pl_j(pl.x)
    if rows[ty][tx].mob_num !=0 then
      --debug("tx/ty="..tx.." "..ty)
      --debug(rows[ty][tx].mob_num)
      halt()
    end
  end

  pl.fl=flr((88-(pl.y-24))/32)+1  

  if pl.cx!=0 or pl.cy!=0 then
    sfx(1,1)
    update_pl_fr()
  end
end

function debug(str,init)
  printh(str,"debug.txt",init)
end

function _draw()
  if logo then
    draw_logo()
  else
    draw_maps()
    if pl.map!=maps.sched and
       pl.map!=maps.win and
       pl.done==false and
       pl.timer>0 then  
      draw_status()
    end
  end
end

function draw_pl()
  sprite=(pl.fr-1)*32+1
  spr(sprite,pl.x,pl.y,2,2,pl.face_left)  
  -- rect(pl.x,pl.y,pl.x+15,pl.y+15,12)
end

function draw_status()
  rectfill(0,16,127,23,6)
  rectfill(0,120,127,127,5)
  draw_bar(31,pl.event_cnt,0,8)
  draw_ribbons(15,1)
  if pl.timer>5 then
    draw_bar(47,pl.timer,2,10)  
  else
    draw_bar(47,pl.timer,2,8+npcs.fr)
  end
    
  print(locs[pl.loc].."/"..map_names[pl.map].." -->"..sched[pl.time].name,1,17,0)
  -- print("e:"..elev.fl.." "..elev.sprt,100,17,0)
  draw_minimap()
end

function draw_minimap()
  for i=1,#paths[pl.path_start][pl.path_end] do
    spr(loc_spr[paths[pl.path_start][pl.path_end][i]],i*16,0,2,2)
    if pl.loc==paths[pl.path_start][pl.path_end][i] then
      rect(i*16,0,i*16+15,15,11)
    end
  end
end  

function draw_bar(sprt,val,coln,clr)
  start=coln*44+1
  staty=120
  spr(sprt,start,staty)
  --rectfill(start+9,staty+1,start+29,staty+6,1)
  if val>0 then
    rectfill(start+9,staty+1,start+9+val,staty+6,clr)
  end
  print(round(val),start+10,staty+2,15-clr)
end  

function draw_ribbons(sprt,coln)
  start=coln*44+1
  staty=120
  spr(sprt,start,staty)
  if #pl.ribbons>0 then  
    for i=1,#pl.ribbons do
      line(start+8+i,staty+1,start+8+i,staty+6,pl.ribbons[i])
    end
  end  
  --print(#pl.ribbons,start+10,staty+2,7)
end  

function round(n)
  lwr=n-flr(n)
  if lwr<0.5 then
    return flr(n) 
  else
    return flr(n+1)
  end
end
-->8
function random(r)
  return flr(rnd(r))+1
end

-- see if box1 and box2 collide
function collide(box1,box2)
  -- check all 4 corners
  return chk_pnt(box1,box2.x,box2.y) or
  							chk_pnt(box1,box2.x+box2.w-1,box2.y) or
         chk_pnt(box1,box2.x,box2.y+box2.h-1) or
  							chk_pnt(box1,box2.x+box2.w-1,box2.y+box2.h-1) 
end

-- see if point b is inside box of a
function chk_pnt(a,x,y)
  return chk_pnt_x(a.x,a.w,x) and
         chk_pnt_x(a.y,a.h,y)
end
  
-- check to see if x2 is within x1->x1+w  
function chk_pnt_x(x1,w,x2)
  return x2<x1+w and
         x2>=x1
end     

function draw_bubble(chatstr,px,py)
  local lines=split(chatstr,"#",false)

  if py==32 then
    chatstr=""
    for i=1,#lines do
      chatstr=chatstr.." "..lines[i]
    end
    lines={chatstr}
    py+=2
  end

  local width=0
  for i=1,#lines do
    if #lines[i]>width then
      width=#lines[i]
    end
  end
  
  local x1,x2,y1,y2,y
  x1=px-flr(width*2)
  if x1<1 then 
    -- oob on the left
    -- debug("oob l")
    x1=1
  elseif x1+(width*4)+3>127 then
    -- oob on the right
    -- debug("oob r")
    x1=127-(width*4+3)
  end
  x2=x1+(width*4)+3
  
  -- debug("x1="..x1..",x2="..x2..",px="..px..",cx="..cx..",w="..width)
  y2=py-6
  y1=y2-(6*#lines)
  y3=y2+5
  
		rectfill(x1,y1+1,x2-1,y2+1,7)
	 rect(x1-1,y1+3,x2,y2,7)
	 line(px+2,y3,px-4,y2,7)
  line(px+2,y3,px-2,y2,7)
  line(px+2,y3,px,y2,7)  
 	
  for i=1,#lines do
    str=lines[i]
    y=py-(6*(#lines-i+1))-6
 		 print(str,x1+2,y+2,2)
 	end
end


-->8
-- hallways / habit trails
function init_h_mobs()    
  h_mobs={}
  robot_onscreen=false
  for i=1,5 do
     num_mobs=i --flr(rnd(i))+1
     h_mobs[i]={}
     for j=1,num_mobs do
       --debug("i,j "..i.." "..j)
       h_mobs[i][j]={}
    		 h_mobs[i][j].x=start_loc(16)
    		
    		 new_mob(h_mobs[i][j],true,i)
       --debug("mob: "..h_mobs[i][j].mob_num)
       --debug("  size: "..h_mobs[i][j].h)       
    	end
  end
end

function start_loc(offset)
		return (flr(rnd(6))+1)*16+offset
end


function new_mob(m,first,row)
  m.mob_num=random(num_sprs)
  if m.mob_num==10 then
    if robot_onscreen then
       -- only one robot at a time
       m.mob_num=4
    else
       robot_onscreen=true
       if pl.map==maps.hall then
         sfx(3,2)
       end
    end
  end
  -- creeper
  m.comm=random(3)
  
  dy=0
  if pl.map==maps.street then
     if m.mob_num==10 or
        m.mob_num==5 or
        m.mob_num==6 then
       m.mob_num=8
     end
     if row==1 then
       dy=-8
     elseif row>3 then
       dy=8
     end
  end
     
  m.y=row*16+16+dy
  m.h=16
 	m.w=16
 	m.ribbon=(m.mob_num==6)

  if not first and m.mob_num==8 then
    m.mob_num=1 -- skip the standing guy
  end
  m.spd=h_spd[m.mob_num]
  m.spr=mob_spr[m.mob_num]
  if m.mob_num==10 then
     -- robot mob - oversized
     if row==5 then
        m.y-=8
     end
     m.h=24
     m.w=24         
  end 
end

function move_h_mobs() 
  for i=1,3 do
    if i==2 and
       pl.map==maps.street then
       break
       -- do nothing
    else
    for v in all(h_mobs[i]) do
     if v.x>0 then
       v.x-=v.spd
       pbox.x=pl.x+5
       pbox.y=pl.y   
       if collide(v,pbox) then
         if v.ribbon then
           -- get a ribbon
           sfx(6,2)
           add(pl.ribbons,random(15)+1)
           --pl.event_cnt+=1
           v.ribbon=false
         else
           sfx(0,2)
         end
         if pl.map==maps.street then
           pl.x+=(speed/2)-random(speed)
         elseif pl.x>=speed then
           pl.x-=speed 
         end         
       end       
     else
       -- scroll mobs off scr
       if v.mob_num==10 then
         sfx(-1,2)
         robot_onscreen=false
       end
     	 v.x=start_loc(120)
     	 new_mob(v,false,i)
     end
    end
   end  
  end
  for i=4,5 do
    for v in all(h_mobs[i]) do
     if v.x<120 then
       v.x+=v.spd
       if v.x>0 then
         pbox.x=pl.x+5
         pbox.y=pl.y   
         if collide(v,pbox) then
           sfx(0,2)
           if pl.map==maps.street then
             pl.x+=(speed/2)-random(speed)           
           elseif pl.x<120 and 
             pl.x>=speed then
             pl.x-=speed 
           end
         end
       end       
     else
       -- reset mob when it scrolls off screen
       if v.mob_num==10 then
          sfx(-1,2)
          robot_onscreen=false
       end
  
     	 v.x=0-start_loc(0)
					  new_mob(v,false,i)
     end
    end
  end  
end

function draw_hall()
  rectfill(0,24,127,31,5)
  rectfill(0,113,127,127,5)
  for j=2,6 do
    for i=0,7 do
      --rectfill(i*16+1,j*16+9,i*16+14,j*16+14+8,13)
      line(i*16+14,j*16+1,i*16+1,j*16+14,13)
    end 
  end   
  draw_arrow(117,24)
end

function draw_arrow(x,y)
  spr(32,x+npcs.fr,y)
end

function draw_h_mobs()
  for i=1,5 do
   if (i==2 or i==3) and
      pl.map==maps.street then
      -- do nothing
      --debug("do nothing")
   else
    for v in all(h_mobs[i]) do
     if v.x>0 then
      sp=v.spr+((mobs.fr-1)*32)
      if v.mob_num==10 then
        sx=find_sx(sp)
        sy=find_sy(sp)
        sspr(sx,sy,16,16,v.x,v.y,24,24,i>3)
--        rect(v.x,v.y,v.x+v.w-1,v.y+v.h-1,13)
      else
        spr(sp,v.x,v.y,2,2,i>3)
        --if i==1 then
        --  debug("x/y"..v.x.."/"..v.y)
        --end
        if v.y==pl.y and i<=3 then
          if v.mob_num==5 and v.x>pl.x and v.x<127 then
            draw_bubble(crp_comm[v.comm],v.x,v.y)
          elseif v.ribbon and v.x>pl.x and v.x<127 then
            spr(16,v.x,v.y+8,1,1)
            draw_bubble("\135".." your cosplay!",v.x,v.y)       
          end
--        rect(v.x,v.y,v.x+v.w-1,v.y+v.h-1,13)
        end
				  end
				 end
    end
   end
  end 
end

-->8
function init_elev()
  elev_fc=0
  elev_sprts={163,165,167}
  elev_xs={16,32,48}
		elev_ys={88,56,24}
  door={closed=1,opening=2,closing=3}
  elev={}
  local el={}
  for i=1,3 do
    elev[i]={}
    el=elev[i]
		  el.fl=random(3)
		  el.x=16
		  el.y=elev_ys[el.fl]
		  el.w=16
		  el.h=16
    if el.fl==1 then
       el.dir=1
	   else
	      el.dir=-1
	   end
		  el.sprt=163
		  el.mob=0
		  el.door=door.closed
		  el.full=false
  end
  
  escal={}
  init_escal(1,104,72,72,104)
  init_escal(2,72,40,104,72)
  
  esc_dir={up=1,down=2}
  esc_cx={}
  esc_cx[1]={1,0}
  esc_cx[2]={-1,-1}
  esc_cx[3]={0,1}
  esc_cy={}
  esc_cy[1]={-1,0}
  esc_cy[2]={-1,1}
  esc_cy[3]={0,1}
  reset_escal()
end

function init_escal(n,tx,ty,bx,by)
  escal[n]={}
  local es=escal[n]  
  es.bot={}
  es.bot.x=bx
  es.bot.y=by
  es.bot.w=1
  es.bot.h=1
  es.top={}
  es.top.x=tx
  es.top.y=ty
  es.top.w=1
  es.top.h=1
end


function reset_escal()
  broken=random(5)
  --if random(6)<=3 then
    -- elevator broken
  --else
    -- 4=bottom escalator
    -- 5=top escalator
    -- escalator broken
end


function board_escal(esc_num,dir)
  if broken==4 and esc_num==1 then  
    return
  end
  if broken==5 and esc_num==2 then
    return
  end
  pl.escal=esc_num
  pl.frozen=true
  pl.dir=dir
end

function update_escal()
  if pl.escal!=0 then
    pl.cx=esc_cx[pl.fl][pl.dir]
    pl.cy=esc_cy[pl.fl][pl.dir]   
  
    pl.face_left=(pl.cx<0)  
    
    pl.x+=pl.cx
    pl.y+=pl.cy
    if pl.dir==1 then
      ty=escal[pl.escal].top.y-8
    else
      ty=escal[pl.escal].bot.y-8
    end
    if pl.y==ty then
      -- reached end of escal
      pl.frozen=false
      pl.escal=0
      pl.dir=0
    end  
  end             
end

function draw_escal()
  if broken>=4 then
    spr(187,escal[broken-3].bot.x,escal[broken-3].bot.y)
    spr(187,escal[broken-3].top.x,escal[broken-3].top.y)
  end  
end

function update_elev()
  -- update the elev flr periodically
  elev_fc+=1
  local el={}
  if elev_fc>=45 then
   elev_fc=0   
   for i=1,3 do
    el=elev[i]
    if broken==i then
      el.door=door.closed
    else
      if el.door==door.closed then
		      el.fl+=el.dir      
		      el.y=elev_ys[el.fl]+8
		      if el.fl==1 then
		        el.dir=1
		      elseif el.fl==3 then
		        el.dir=-1
		      end
		      if el.fl==pl.fl then
		        el.door=door.opening
		        if rnd(3)>2 then
		          -- elevator full
		          el.mob=flr(rnd(num_sprs))+1
		        else
		          el.mob=0
		        end
		      elseif pl.elev>0 then
		        el.door=door.opening
		        pl.frozen=false
		        pl.fl=el.fl
		        pl.y=el.y
		      end   
		    else
		      if el.door==door.opening then
		        el.door=door.closing
		      else
		        if el.door==door.closing then
		          el.door=door.closed
		        end
		      end
		    end
		  end
		 end		  
		end
end

function draw_elev()
  draw_arrow(exit.x-2,exit.y-8)
  local elj={}
  for j=1,3 do
   elj=elev[j]
   -- j=elev column
   for i=1,3 do
    -- i = elev floor
    elj.sprt=elev_sprts[1]

    spr(elj.sprt,elev_xs[j],elev_ys[i],2,1)

    if elj.fl==pl.fl and
       elj.fl==i then
 
      -- draw up/down arrows 
      if elj.door!=door.closed then
       if elj.dir==1 then
        -- up
        spr(169,elev_xs[j],elev_ys[i],2,1)
       else
        -- down
        spr(185,elev_xs[j],elev_ys[i],2,1)
       end     
      end
      -- open elev
      if elj.door==door.opening then
        if stat(46+2)==-1 and elev_fc<5 then
          sfx(2,2)
        end
        elj.sprt=elev_sprts[flr(elev_fc/15)+1]
      elseif elev[j].door==door.closing then
        elj.sprt=elev_sprts[4-(flr(elev_fc/15)+1)]     
      end
      -- elevator full or not
      if elj.door!=door.closed and elev[j].mob!=0 then
         spr(mob_spr[elj.mob],elev_xs[j],elev_ys[pl.fl]+8,2,2)
      end  
    end        
    spr(elj.sprt+16,elev_xs[j],elev_ys[i]+8,2,1)
    spr(elj.sprt+16,elev_xs[j],elev_ys[i]+16,2,1)
    if broken==j then
      for i=1,3 do
       spr(187,elev_xs[j]+4,elev_ys[i]+16)
      end
    end           
   end
  end
end

-->8
function init_maps()
  
  maps={parade=1,
        panel=2,
        vendors=3,
        concert=4,
        party=5,
        autograph=6,
        photoshoot=7,
        food_ct=8,
        gaming=9,
        sleep=10,
        masquerade=11,
        hall=12,
        elev=13,
        lobby=14,
        street=15,
        sched=16,
        win=17}

  map_names={"parade",
        "panel",
        "vendors",
        "concert",
        "party",
        "autographs",
        "photoshoot",
        "food",
        "gaming",
        "hotel room",
        "masquerade",
        "hall",
        "elevators",
        "lobby",
        "street",
        "schedule",
        "you win!"}

  pl.map=maps.sched
  npcs={}
  npcs.fr=1
  npcs.fc=0
  cross_cnt=0
  cross_go=330
  cross_max=400
  
  exit={}
  init_locs()
  init_sched()
  init_paths()
  init_concert()
  init_map_funcs()
end

function init_map()
  if pl.map==maps.elev then 
     pl.y=rnd(elev_ys)+8
     pl.x=0
     exit.x=120
     exit.y=rnd(elev_ys)+8
     reset_escal()
  elseif pl.map==maps.hall then
     pl.y=32
     pl.x=0
     exit.x=120
     exit.y=-1
     init_h_mobs()
  elseif pl.map==maps.street then
     pl.y=104
     pl.x=0
     exit.x=120
     exit.y=24
     init_h_mobs()
  elseif pl.map==maps.lobby then
     pl.y=24
     pl.x=0
     exit.x=120
     exit.y=-1
     init_lobby()
  end
end

function exit_map()
  if pl.x>=exit.x and
     (pl.y==exit.y or
      exit.y==-1) then
    --debug("exit map")  
    return true
  else
    return false
  end
end


function update_maps()
  npcs.fc+=1
  if npcs.fc>=20 then
    npcs.fr=3-npcs.fr
    npcs.fc=0
  end
  if pl.map==maps.hall then
     update_mobs_fr()
     move_h_mobs(1)
  elseif pl.map==maps.street then
     update_mobs_fr()
     move_h_mobs(4)
     update_cars()
  elseif pl.map==maps.elev then
     update_escal()
     update_elev()
  elseif pl.map==maps.sched then
     update_sched()     
  elseif pl.map==maps.lobby then
     update_lobby()
  end
end


function draw_maps()
  cls(0)
  if pl.map==maps.hall then
    draw_hall()
    draw_h_mobs(1)
    draw_pl()
  elseif pl.map==maps.elev then
    map(16, 0, 0, 0, 128, 32)
    if pl.elev>0 and not (elev[pl.elev].door==door.closed) then
      draw_pl()
    end
    draw_elev()
    if pl.elev==0 then
      draw_pl()
    end
    draw_escal()
  elseif pl.map==maps.street then
    --map()
    draw_street()
    draw_h_mobs(4)
    draw_pl()
  elseif pl.map==maps.lobby then
    map()
    draw_lobby()
    draw_pl()
   else
    map_funcs[pl.map]()
  end

  if pl.done==true then
    draw_done()
  end
  
  if pl.timer<=0 then
    draw_fail()
  end
  
--  if not pl.elev 
--    draw_pl()
--  end
  if pl.escal!=0 then
    -- draw the escalator over the player
    map(25,4,72,32,6,9)
    draw_escal()
  end
end

function draw_panel()
  draw_success(ev_ids.panel)
    
  dy=16
  dy48=48
  
  rectfill(0,32,32,59,6)
  rectfill(0,54+dy,127,127,4)
  rectfill(32,48+dy,96,53+dy,5)
  --draw_stage()
    
  mirror=true
  mod={234,234}
  shat={194,226}
  if npcs.fr==1 then 
    spr(238,50,17+dy,2,2)
    spr(mod[npcs.fr],40,dy48,2,2)
    spr(shat[npcs.fr],80,dy48,2,2)
  else
    spr(238,70,17+dy,2,2,true)
    spr(mod[npcs.fr],40,dy48,2,2)
    spr(shat[npcs.fr],80,dy48,2,2)   
  end

  sx=find_sx(shat[npcs.fr])
  sy=find_sy(shat[npcs.fr])
  sspr(sx,sy,16,8,2,34,32,24)
  --draw audience
  for i=0,2 do
   mirror=not mirror
   for j=1,3 do
    mirror=not mirror
    spr(204,16+(i*32),34+(j*16)+dy,4,2,mirror)
   end
  end
end

function find_sx(spr)
  return (spr % 16) * 8
end

function find_sy(spr)
  return (spr \ 16) * 8
end

function draw_stage()
  rectfill(32,64,96,76,5)
end


function draw_autograph()
  draw_success(ev_ids.autograph)
  
  rectfill(0,96+16,127,96+16,5)
  -- map()
  if npcs.fr==1 then
    spr(192,96,96,2,2)
  else
    spr(224,96,96,2,2)
  end  
  
  for i=1,5 do
    spr(mob_spr[i],
        i*14+12,96,2,2,true)
  end
end

function init_concert() 
  fans={}
  for i=1,20 do
    fans[i]={}
    fans[i].spr=mob_spr[random(num_sprs)]
    fans[i].x=random(80)+16
    fans[i].y=random(40)+52+16
  end
end

function draw_concert()
  draw_success(ev_ids.concert)
  draw_stage()
  if stat(46)==-1 then
    sfx(5)
  end
  -- draw floor
  for i=0,15 do
    for j=7,13 do
      spr(172,i*8,(j*8)+20)
    end
  end  
  --lights
  spr(200,-npcs.fr+15+18,32,4,2,npcs.fr==2)
  spr(200,-npcs.fr+47+18,32,4,2,npcs.fr==2)

  if npcs.fr==1 then
    spr(196,60,48,2,2)
  else
    spr(228,60,48,2,2)
  end    

  --draw audience
  for fan in all(fans) do
    spr(fan.spr,fan.x,fan.y,2,2,npcs.fr==1)
  end
end

function draw_party()
  draw_success(ev_ids.party)
  draw_stage()
  if stat(46)==-1 then
    sfx(5)
  end
  -- draw floor
  for i=0,15 do
    for j=7,12 do
      spr(172,i*8,(j*8)+20)
    end
  end  
  --lights
  spr(200,-npcs.fr+15+18,32,4,2,npcs.fr==2)
  spr(200,-npcs.fr+47+18,32,4,2,npcs.fr==2)

  if npcs.fr==1 then
    spr(72,50,48,2,2,true)
    spr(104,60,48,2,2)
  else
    spr(104,50,48,2,2,true)
    spr(72,60,48,2,2)
  end    

  --draw audience
  for fan in all(fans) do
    if npcs.fr==1 then
      spr(72,fan.x,fan.y,2,2,npcs.fr==1)
    else
      spr(104,fan.x,fan.y,2,2,npcs.fr==1)
    end  
  end
end



function draw_success(en)
  st="new achievement!"
  print(st,center_str(st),8,8)
  st="you've reached the "..map_names[en]  
  print(st,center_str(st),16,8)
  st="reward? +1\135 hit ❘ to continue"
  print(st,center_str(st),24,8)
end


function draw_photoshoot()
  draw_success(ev_ids.photoshoot)
  
  for i=1,5 do
    if i!=5 then
      rectfill(120-(i*16),
             i*16+32,
             127,
             i*16+39,6)
      rectfill(112-(i*16),
             i*16+40,
             127,
             i*16+48,6)
      line(120-(i*16),i*16+32,
           127,i*16+32,5)
    end
    for j=1,i do
      spr(33,116-(i*16)+((j-1)*12),
    						i*16+16,
    						2,2,true)
    end
  end

  rectfill(0,112,127,114,5)
  
  if npcs.fr==1 then
    spr(66,10,96,2,2)
  else
    spr(98,10,96,2,2)
  end    
end


function draw_sleep()
  draw_success(ev_ids.sleep)
  
  spr(232,60,96,2,2)
  rect(42,90,76,112,5)
end


function center_str(str)
  return (64-(#str*2))
end

function draw_masquerade()
  draw_success(ev_ids.masquerade)
  draw_stage()
  
  if stat(46)==-1 then
    sfx(3)
  end
  -- draw floor
  for i=0,15 do
    for j=7,12 do
      spr(172,i*8,(j*8)+20)
    end
  end
  spr(234,32,48,2,2)
  
  if npcs.fr==1 then
    sp=70
  else
    sp=102
  end
  
  sx=find_sx(sp)
  sy=find_sy(sp)
  sspr(sx,sy,16,16,60,40,24,24)

  mirror=true
  --draw audience
  for i=0,2 do
   mirror=not mirror
   for j=1,3 do
    mirror=not mirror
    spr(204,16+(i*32),56+(j*16),4,2,mirror)
   end
  end    
end

function draw_food()
  draw_success(ev_ids.food_ct)
  
  
  rectfill(0,112,127,114,5)

  draw_shop("pizza",0,70,8)
  draw_shop("sushi",36,70,0)
  draw_shop("subs",70,70,3)
  draw_shop("buffet",100,70,2)

  spr(3,20,96,2,2,true)
  draw_table(30,96)
  spr(5,38,96,2,2)
  spr(9,48,96,2,2,true)
  draw_table(60,96) 
  spr(11,70,96,2,2)
  spr(74,80,96,2,2,true)
  draw_table(90,96)
  spr(13,100,96,2,2)
end

function draw_shop(str,x,y,col)
  rectfill(x,y,x+(#str*4)+2,y+8,7)
  rect(x,y,x+(#str*4)+2,y+32,5)
  rect(x,y+8,x+(#str*4)+2,y+31,5)
  print(str,x+2,y+2,col)
end

function draw_table(x,y)
  spr(230,x,y,2,2)
end

function draw_gaming_table(x,y)
  line(x,y,x+19,y,6)
  line(x,y,x,y+6,6)
  line(x+19,y,x+19,y+6,6)
end


function draw_parade()
  draw_success(ev_ids.parade)
  
  --rectfill(0,0,127,32,6)
  rectfill(0,127-26,127,127,6)
  rectfill(0,67,127,68,10)
  rectfill(0,70,127,71,10)
  
  -- draw crowd
  for j=0,1 do
    for i=0,14 do
      --spr(78,i*16,0,2,2,(i/2==i\2))
      -- spr(78,i*16,16,2,2,(i/2==i\2))
      spr(78,i*18,127-32,2,2,(i/2==i\2))
      spr(78,i*18,127-16,2,2,(i/2==i\2))
    end
  end
  -- draw 300
  for i=0,3 do
    for j=0,3 do
      if (npcs.fr==1) then
        if (i/2==i\2) then
   	  	   spr(76,i*16,j*16+33,2,2)
       	else
          spr(108,i*16,j*16+33,2,2)
        end
      else
        if (i/2==i\2) then
   	  	   spr(108,i*16,j*16+33,2,2)
       	else
          spr(76,i*16,j*16+33,2,2)
        end
      end      
    end 
  end  
    
  -- blue car
  --sspr(find_sx(142),find_sy(142),16,8,20,40,32,16)
  -- red car
  spr(194,98,38+npcs.fr,2,1)
  sspr(find_sx(158),find_sy(158),16,8,80,40+npcs.fr,32,16)  
  -- ghostbusters
  sspr(find_sx(173),find_sy(173),24,16,76,60-npcs.fr,48,32)    
end

function draw_gaming()
  draw_success(ev_ids.gaming)
  
  rectfill(0,112,127,114,5)
  
  spr(11,8,96,2,2,true)
  draw_gaming_table(20,105)  
  spr(204,23,96,2,2)

  spr(41,40,96,2,2,true)
  draw_gaming_table(52,105)  
  spr(206,55,96,2,2)

  spr(13,100,96,2,2)
  draw_gaming_table(82,105)  
  spr(204,85,96,2,2,true)

end

function draw_vendors()
  draw_success(ev_ids.vendors)
  rectfill(0,112,127,114,5)
  

  for i=1,16 do
    spr(198,i*16,96,2,2)
  end
  for i=1,10 do
    spr(mob_spr[i],i*16+(i/3),96,2,2,true)
  end 
end

function draw_win()
  spr(128,10,0,14,2)
  rectfill(0,16,127,20,5)
  rectfill(0,123,127,127,5)
  st="new achievement!"
  print(st,center_str(st),28,8+npcs.fr)
  st="you win! you survived the day!"
  print(st,center_str(st),38,9)
  st="reward? a lifetime of memories"
  print(st,center_str(st),48,9)
  print("events:"..pl.event_cnt.." of 11",9,59,8)
  print("ribbons:"..#pl.ribbons,84,59,10)
  spr(31,0,57)
  spr(15,75,58)
  for i=1,9 do
    draw_pic(i)
  end   
  print("hit ❘ to exit",36,123,6)
end

function init_pics()
  pics={}
  for i=1,5 do
    pics[i]={}
    pics[i].x=(i-1)*24+4
    pics[i].y=86-random(16)
    pics[i].spr=rnd(mob_spr)
  end
  celebs={192,194,196,236}
  for i=6,9 do
    pics[i]={}
    pics[i].x=(i-6)*24+22
    pics[i].y=96+random(8)
    pics[i].spr=celebs[i-5]
  end
end

function draw_pic(i)
  rectfill(pics[i].x+2,pics[i].y-2,pics[i].x+20,pics[i].y+18,0)
  if i<6 then
    spr(1,pics[i].x,pics[i].y,2,2)
  end
  spr(pics[i].spr,pics[i].x+6,pics[i].y,2,2)
  rect(pics[i].x+2,pics[i].y-2,pics[i].x+21,pics[i].y+17,7)
end

-->8
function draw_street()
               
  rectfill(0,103,127,127,6)
  rectfill(0,24,127,40,6)

  rectfill(0,69,127,70,10)
  rectfill(0,73,127,74,10)
  for i=4,6 do
    rectfill((6-i)*3+94,i*10+4,(6-i)*3+110,i*10+7,7)
  end
  for i=7,9 do
    rectfill((9-i)*3+84,i*10+6,(9-i)*3+100,i*10+9,7)
  end
  line(0,24,127,24,5)
  line(0,40,127,40,5)
  for i=0,5 do
    line(i*24+6,103,i*24,127,5)
    line(i*24+3,24,i*24,40,5)
  end
  draw_cars()
  rectfill(102,90,118,96,5)
  rectfill(109,96,111,108,5)
  if cross_cnt<cross_go then
    print("wait",103,91,8)
  else  
    print("walk",103,91,11)
  end
  draw_arrow(exit.x-4,exit.y)
end

function init_cars()
  cars={}
  car_sprs={142,158}
  
  --cars[1]=top
  --cars[2]=bottom
  for i=1,2 do
    cars[i]={}
    cars[i].spr=rnd(car_sprs)
    cars[i].crashed=false
    cars[i].ambulance=false
  end  
  cars[2].swap=true
  cars[1].swap=false
  cars[1].x=-10
  cars[1].y=48
  cars[2].x=140
  cars[2].y=80
end

function update_cars()  
  --cars[1]=top
  --cars[2]=bottom

  cross_cnt+=1
  if cross_cnt>cross_max then
    cross_cnt=0
  end

  if (pl.y>=cars[1].y-12 and
     pl.y<=cars[1].y+4) and
     pl.x>=cars[1].x-16 and
     pl.x<=cars[1].x+8 then
     -- collission
     if not cars[1].crashed then
       if cross_cnt<cross_go then
         sfx(8,0)
         sfx(9,2)

         cars[1].crashed=true
         pl.fail_str="hit by a car!"
         pl.frozen=true
       else
         pl.y+=16
       end
     else
       pl.x-=32
     end
  end

  if (pl.y>=cars[2].y-12 and
     pl.y<=cars[2].y+4) and
     pl.x>=cars[2].x and
     pl.x<=cars[2].x+24 then
     -- collission
     if not cars[2].crashed then
       if cross_cnt<cross_go then
         sfx(8,0)
         sfx(9,2)
         cars[2].crashed=true
         pl.fail_str="hit by a car!"
         pl.frozen=true
       else
         pl.y+=16
       end
     else
       pl.x+=32
     end
  end
  
  -- move cars
  -- car 1 is top lane
  -- car 2 is bottom lane
  if cars[2].x<127-speed then  
    if cars[2].ambulance then
      cars[2].x+=speed/4
    elseif (cross_cnt>=cross_go and
      (cars[2].x<(84-32-speed) or
       cars[2].x>100)) or
      cross_cnt<cross_go then         
      cars[2].x+=speed
    end
  elseif cars[2].crashed then
      cars[2].crashed=false
      cars[2].ambulance=true
      cars[2].x=-10-random(30)
      sfx(11,2)
  elseif cars[2].ambulance then
      -- ambulance has left the screen
      pl.timer=0
      cars[2].crashed=false
      cars[2].ambulance=false
  else  
      cars[2].spr=rnd(car_sprs)
      cars[2].x=-10-random(30)
  end

  if cars[1].x>speed then 
    if cars[1].ambulance then
       cars[1].x-=(speed/4)
    elseif (cross_cnt>=cross_go and
      (cars[1].x>140) or
       cars[1].x<84-32) or
      cross_cnt<cross_go then           
      cars[1].x-=speed
      if stat(47)==-1 then
        sfx(12,1)
      end
    end
  elseif cars[1].crashed then
      cars[1].crashed=false
      cars[1].ambulance=true
      cars[1].x=140+random(30)      
      sfx(11,2)
  elseif cars[1].ambulance then
      -- ambulance has left the screen
      pl.timer=0
      cars[1].crashed=false
      cars[1].ambulance=false
  else  
      cars[1].x=140+random(30)
      cars[1].spr=rnd(car_sprs)
  end  
end

function draw_cars()  
  for i=1,2 do
    if cars[i].ambulance then
      -- ghostbusters
      sspr(find_sx(173),find_sy(173),24,16,cars[i].x,cars[i].y-16,48,32,cars[i].swap)    
    else
      sspr(find_sx(cars[i].spr),find_sy(cars[i].spr),16,8,cars[i].x,cars[i].y,32,16,cars[i].swap)  
    end
  end
end


function init_lobby()    
  mdx={0,1,0,-1}
  mdy={-1,0,1,0}
  rows={}
  num_rows=6
  num_cols=8
  --debug("init_lobby")
  
  for i=1,num_rows do
     rows[i]={}     
     row_y=find_y(i)
     --debug("i:"..i.." y:"..row_y)
     for j=1,num_cols do
       row_x=find_x(j)
       --debug("i,j "..i.." "..j)
       rows[i][j]={}
       
       if j==1 then
         rows[i][j].mob_num=0
       elseif random(3)==3 then       
    		   add_lobmob(rows[i][j],row_x,row_y)
    		 else
    		   rows[i][j].mob_num=0
    		 end
    		 --debug("j:"..j.." mob:"..rows[i][j].mob_num)
    		 --debug("   x:"..row_x)
    	end
  end
end

function find_x(j)
  return (j-1)*16
end

function find_y(i)
  return (i-1)*16+24
end

function find_pl_i(y)
  return flr((y-24)/16)+1
end

function find_pl_j(x)
  return flr(x/16)+1
end

function add_lobmob(m,x,y)
  -- debug("add mob "..x..","..y)
  m.mob_num=random(num_sprs)
  m.x=x
  m.y=y
  m.h=16
 	m.w=16
  m.spr=mob_spr[m.mob_num]
  m.flip=random(2)==2 
  
--  if m.mob_num==10 then
     -- robot mob - oversized
--     m.y-=8
     --sfx(3,2)
--     m.h=24
--     m.w=24         
--  end 
end

function update_lobby()

  if npcs.fc!=10 then
     return
  end
  --debug("update_lobby")
  for i=1,num_rows do
    for j=1,num_cols do
      if rows[i][j].mob_num!=0 then
         if random(3)==3 then
           move_lobmob(i,j)       
         end
      end
    end
  end
end   
        
function move_lobmob(i,j)
  mt=random(4)
  open_space={}

  ty=i+mdy[mt]
  tx=j+mdx[mt]
  
  morph=false
  if ty==0 then
    ty=num_rows
    morph=true
  elseif ty>num_rows then
    ty=1
    morph=true
  end
  if tx==0 then
    tx=num_cols
    morph=true
  elseif tx>num_cols then
    tx=1
    morph=true
  end
    
  if rows[ty][tx].mob_num==0 then
     --debug("moving "..j..","..i.." to "..tx..","..ty)
     rows[i][j].x=find_x(tx)
     rows[i][j].y=find_y(ty)
     if morph then
        rows[i][j].mob_num=random(num_sprs)
     end
     rows[ty][tx]=rows[i][j]
     chk_collide(rows[ty][tx])
     rows[i][j]={}
     rows[i][j].mob_num=0
  end
end

function chk_collide(tmob)
  if collide(tmob,pl) then
    bump()
  end
end

function bump()
  sfx(0,2)
  if pl.x>=speed then
    pl.x-=speed 
  end
end

function halt()
  if pl.x>=speed then
    pl.x-=pl.cx 
  end
  if pl.y>=speed then
    pl.y-=pl.cy
  end
end

function draw_lobby()
  rectfill(0,16,127,23,6)
  for i=0,15 do
    for j=0,13 do
      spr(172,i*8,j*8+24) --rnd(2)>1)
    end
  end
  for i=1,num_rows do
    for j=1,num_cols do
      if rows[i][j].mob_num!=0 then      
        spr(188,rows[i][j].x,rows[i][j].y,1,1)
        spr(rows[i][j].spr,rows[i][j].x,rows[i][j].y,2,2,rows[i][j].flip)
      end  
      -- rect(rows[i][j].x,rows[i][j].y,rows[i][j].x,rows[i][j].y,12)
    end
  end
  draw_arrow(117,0)  
end



       

-->8
function init_locs()
  locs={}
  locs={"amer mart","wstn","hytt",
        "mrrott","food ct","hltn",
        "crtlnd"}
  loc_ids={amer_mart=1,westin=2,hyatt=3,
        marriott=4,food_ct=5,hilton=6,
        courtland=7}
  loc_spr={136,140,128,130,138,132,134}
end

function init_sched()
  events={"autograph", --
          "parade", -- 
          "panel", --
          "vendor hall",
          "photoshoot", --
          "food", --
          "gaming hall", --
          "concert", --
          "party", --
          "hotel room", --
          "masquerade"} --

  ev_ids=maps
  
  morning={ev_ids.autograph,
           ev_ids.parade,
           ev_ids.panel,
           ev_ids.vendors,
           ev_ids.photoshoot,
           ev_ids.food_ct,
           ev_ids.gaming}
  afternoon={ev_ids.autograph,
             ev_ids.panel,
             ev_ids.vendors,
             ev_ids.photoshoot,
             ev_ids.food_ct,
             ev_ids.gaming,
             ev_ids.sleep}
  evening={ev_ids.food_ct,
           ev_ids.sleep,
           ev_ids.party,
           ev_ids.panel,
           ev_ids.gaming,
           ev_ids.concert,
           ev_ids.masquerade}
  ev_locs={}
  ev_locs[ev_ids.autograph]={loc_ids.marriott}
  ev_locs[ev_ids.concert]={loc_ids.hyatt,loc_ids.marriott}
  ev_locs[ev_ids.food_ct]={loc_ids.food_ct}
  ev_locs[ev_ids.gaming]={loc_ids.amer_mart}
  ev_locs[ev_ids.panel]={loc_ids.westin,loc_ids.hilton,loc_ids.marriott,loc_ids.hyatt,loc_ids.courtland}
  ev_locs[ev_ids.parade]={loc_ids.hyatt}
  ev_locs[ev_ids.party]={loc_ids.westin,loc_ids.hilton,loc_ids.marriott,loc_ids.hyatt,loc_ids.courtland}
  ev_locs[ev_ids.photoshoot]={loc_ids.hilton}
  ev_locs[ev_ids.masquerade]={loc_ids.marriott}
  ev_locs[ev_ids.sleep]={loc_ids.hyatt}
  ev_locs[ev_ids.vendors]={loc_ids.amer_mart}
         
  sched={}
  local sch={} 
  for i=1,11 do
    sched[i]={}
    sch=sched[i]
    sch.time=8+i
    if i<=3 then
      evt_id=rnd(morning)
    elseif i<=7 then
      evt_id=rnd(afternoon)
    else
      evt_id=rnd(evening)
    end          
    sch.name=map_names[evt_id]
    sch.evt_id=evt_id
    eloc=rnd(ev_locs[evt_id])
    sch.loc=locs[eloc]
    sch.loc_id=eloc
  end
end

function update_sched()
  -- debug("update_sched")
  
  if btnp(❘) then
    next_path()
    next_loc()
    next_map()
    pl.timer=#paths[pl.path_start][pl.path_end]*8
  end
end

function update_done()
  -- debug("update_done")
  npcs.fc+=1
  if npcs.fc>=20 then
    npcs.fr=3-npcs.fr
    npcs.fc=0
  end
  
  if btnp(❘) then
    pl.done=false
    --debug("update_done,pl.done=false")
    sfx(-1)
    pl.event_cnt+=1
    pl.time+=1
    if pl.time>11 then
      pl.map=maps.win
      music(0)
    else
      pl.map=maps.sched
    end
  end
end

function update_fail()
  -- debug("update fail")
  if not fail_played then
    sfx(-1)
    sfx(16)
    fail_played=true
  end
  if btnp(❘) then
    --debug("fail btnp")
    sfx(-1)
    pl.done=false
    fail_played=false
    pl.time+=1
    pl.timer=20
    pl.failed=true
    if pl.time>11 then
      pl.map=maps.win
      music(0)
    else
      pl.map=maps.sched
    end
  end
end


function draw_done()
  spr(1,0,96,2,2)
end

function draw_fail()
  cls()
  str=pl.fail_str
  print(str,center_str(str),8,8)
  str="you missed the "..sched[pl.time].name
  print(str,center_str(str),21,6)
  str="no \135 for you!"
  print(str,center_str(str),33,8)
  str="on to the next event"
  print(str,center_str(str),45,6)
  str="hit ❘ to continue"
  print(str,center_str(str),51,6)
end

function draw_sched()
  -- debug("draw sched")
  rectfill(0,15,127,15,14)
  st="my schedule - hit ❘ to go!"
  print(st,center_str(st),1,14)
  print("time   event        location",1,9,14)
  for i=1,11 do
    if i%2==0 then
      rowclr=6
    else
      rowclr=14
    end
    if pl.time==i then
      rowclr=13
    end
    local ly=i*8+9
    rectfill(0,ly-1,127,ly+7,rowclr)
    print(sched[i].time..":00",2,ly,0)
    print(sched[i].name,29,ly,0)
    print(sched[i].loc,81,ly,0)
  end 
end  
   
-->8
function init_paths()
  -- going into a hotel
  -- 1. street or habit trail
  -- 2. random hall, elev, floor
  -- 3. random hall, elev, floor
  stage_options={maps.hall,maps.elev,maps.lobby}
  
  --pl.path_start=loc_ids.hyatt
  --pl.path_end=loc_ids.hilton
  --pl.path_end=pl.path_start
  
  pl.path_stage=0
  pl.map_stage=0
  pl.loc=loc_ids.hyatt
  pl.done=false  
  --debug("init_paths,pl.done=false")    
  paths={}
  paths[loc_ids.amer_mart]={}
  --paths[pl.path_start][pl.path_end]
  for i=1,7 do
    paths[i]={}
  end
  path=paths[1]
  -- loc_ids.amer_mart
  add(path,{1})
  add(path,{1,loc_ids.westin})
  add(path,{1,loc_ids.hyatt})
  add(path,{1,loc_ids.hyatt,loc_ids.marriott})
  add(path,{1,loc_ids.hyatt,loc_ids.food_ct})
  add(path,{1,loc_ids.hyatt,loc_ids.marriott,loc_ids.hilton})
  add(path,{1,loc_ids.courtland}) 

  --paths[loc_ids.westin]={}
  path=paths[2]
  add(path,{2,loc_ids.amer_mart})
  add(path,{2})
  add(path,{2,loc_ids.hyatt})
  add(path,{2,loc_ids.hyatt,loc_ids.marriott})
  add(path,{2,loc_ids.food_ct})
  add(path,{2,loc_ids.hyatt,loc_ids.marriott,loc_ids.hilton})
  add(path,{2,loc_ids.courtland})

  --paths[loc_ids.hyatt]={}
  path=paths[3]
  add(path,{3,loc_ids.amer_mart})
  add(path,{3,loc_ids.westin})
  add(path,{3})
  add(path,{3,loc_ids.marriott})
  add(path,{3,loc_ids.food_ct})
  add(path,{3,loc_ids.marriott,loc_ids.hilton})
  add(path,{3,loc_ids.marriott,loc_ids.courtland})

  --paths[loc_ids.marriott]={}
  path=paths[4]
  add(path,{4,loc_ids.hyatt,loc_ids.amer_mart})
  add(path,{4,loc_ids.hyatt,loc_ids.westin})
  add(path,{4,loc_ids.hyatt})
  add(path,{4})
  add(path,{4,loc_ids.food_ct})
  add(path,{4,loc_ids.hilton})
  add(path,{4,loc_ids.courtland})

  --paths[loc_ids.food_ct]={}
  path=paths[5]  
  add(path,{5,loc_ids.hyatt,loc_ids.amer_mart})
  add(path,{5,loc_ids.westin})
  add(path,{5,loc_ids.hyatt})
  add(path,{5,loc_ids.marriott})
  add(path,{5})
  add(path,{5,loc_ids.hilton})
  add(path,{5,loc_ids.courtland})

  --paths[loc_ids.hilton]={}
  path=paths[6]  
  add(path,{6,loc_ids.marriott,loc_ids.hyatt,loc_ids.amer_mart})
  add(path,{6,loc_ids.marriott,loc_ids.hyatt,loc_ids.westin})
  add(path,{6,loc_ids.marriott,loc_ids.hyatt})
  add(path,{6,loc_ids.marriott})
  add(path,{6,loc_ids.marriott,loc_ids.food_ct})
  add(path,{6})
  add(path,{6,loc_ids.courtland})
  
  --paths[loc_ids.courtland]={}
  path=paths[7]
  add(path,{7,loc_ids.amer_mart})
  add(path,{7,loc_ids.westin})
  add(path,{7,loc_ids.marriott,loc_ids.hyatt})
  add(path,{7,loc_ids.marriott})
  add(path,{7,loc_ids.food_ct})
  add(path,{7,loc_ids.hilton})
  add(path,{7})
end

function next_loc()
  pl.map_stage=0
  pl.path_stage+=1
  --debug("next_loc:"..pl.path_start.." to "..pl.path_end)
  --debug(#paths[pl.path_start][pl.path_end])
  if pl.path_stage>#paths[pl.path_start][pl.path_end] then
    -- reached the end
    --debug("next loc-reset-pl.done=true")
    pl.done=true
    sfx(-1)
    sfx(15)
    pl.map=sched[pl.time].evt_id
  else  
    pl.loc=paths[pl.path_start][pl.path_end][pl.path_stage]
    --debug("pl.loc="..pl.loc)
    --debug("hotel="..locs[pl.loc])
    --debug("pl.path_stage="..pl.path_stage)
    --debug("pl.map_stage="..pl.map_stage)   
  end
end

function next_map()
  -- each hotel has 4 maps
  -- except the 1st, which 
  -- has two
  pl.map_stage+=1

  --map / testmode
  --pl.map=maps.win
  
  init_map()
  --if pl.map==maps.win then
   -- return
  --end

  --debug(">nextmap "..pl.loc.." "..pl.path_end)
  --debug("   "..pl.path_stage.."/"..pl.map_stage) 
  if pl.path_stage==1 then
    if pl.map_stage==1 then
    -- first hotel is just two
    -- stages/map - the hall
      pl.map=maps.hall
      init_map()
      return
    elseif pl.map_stage==2 then
      -- skip 2 and 3
      pl.map_stage=4
    end
  end
  if pl.map_stage==2 or
     pl.map_stage==3 then     
     -- then move
     -- to a hall,elev,or lobby       
     pl.map=rnd(stage_options)
     init_map()      
  elseif pl.map_stage==4 then
     if pl.path_end==pl.loc then  
       -- reached destination
       --debug("reached dest")
       next_loc()
     else
       -- move to next hotel via 
       -- street or habit trail
       if pl.path_start==loc_ids.hyatt and 
       (pl.path_end==loc_ids.food_ct or
        pl.path_end==loc_ids.marriott) then
       pl.map=maps.hall -- habit trail
       elseif
       pl.path_start==loc_ids.marriott and
       (pl.path_end==loc_ids.hyatt or
        pl.path_end==loc_ids.hilton) then
       pl.map=maps.hall
       elseif
       pl.path_start==loc_ids.food_ct and
       pl.path_end==loc_ids.hyatt then
       pl.map=maps.hall
       elseif
       pl.path_start==loc_ids.hilton and
       pl.path_end==loc_ids.marriott then
       pl.map=maps.hall
       else
         pl.map=maps.street
         init_map()
       end
     end
  elseif pl.map_stage==5 then
     next_loc()
     next_map()
  end
  --debug("<next map "..pl.path_stage..">"..pl.map_stage.." "..pl.map)
end

function next_path()
  -- if failed last path, start at 
  -- current loc
  if pl.failed then
    pl.path_start=pl.loc
  else
    pl.path_start=pl.path_end
  end
  pl.frozen=false
  pl.failed=false
  pl.fail_str="you were too slow!"
  pl.path_end=sched[pl.time].loc_id
  pl.path_stage=0
  pl.map_stage=0
  pl.loc=pl.path_start
end

-->8
function init_map_funcs()
  map_funcs={draw_parade,
        draw_panel,
        draw_vendors,
        draw_concert,
        draw_party,
        draw_autograph,
        draw_photoshoot,
        draw_food,
        draw_gaming,
        draw_sleep,
        draw_masquerade,
        draw_hall,
        draw_elev,
        draw_lobby,
        draw_street,
        draw_sched,
        draw_win}
end