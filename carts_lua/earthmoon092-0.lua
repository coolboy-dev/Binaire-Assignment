-- earthmoon
-- by pixel_from_earth

-- version 0.9.2

function _init()
  turn=1
  chapter=1
  block_turn=false

  --animations:
  frame=0
  sequence=0

  msg_need_shuttle=false

  --globals (nil):
  -- msg_coolant
  -- msg_ast_too_big
  -- msg_max_ships
  -- msg_already_prod

  wrld=4
  
  view=1
  view_ship=nil
  view_col=1

		cur_loc=0
		cur=1
		cur_opt={}

  msg={}
  
  stars={}
  
  --mission status:
  mss_stt_earth=0

  res_name={
		  "aluminium",
		  "iron",
		  "titanium",
		  "hydrogen",
		  "nitrogen",
		  "uranium"}
  
		res_rat={ --extr. rate kg/d
		  200, --aluminium
		   50, --iron
		   75, --titanium
		  150, --hydrogen
		   75, --nitrogen
		   30} --uranium

		body={
    {"mercury",
		    {"small planet",
	      "extreme heat",
	      "iron ore"},
	     true,
	     0,
	     3,
	     2,
	     false,false,
	     {{1,1},50},
	     {1,129}
	   },
		  {"venus",
		    {"planet",
		     "hostile atmosph.",
		     "uninhabitable"},
      false,
      0,
      7,
      nil,
	     false,false,
	     {{1,1},51},
	     {1,130}
	   },
		  {"earth",
		    {"planet",
		     "extr. conditions",
		     "uninhabitable"},
		    false,
		    0,
		    11,
		    nil,
	     false,false,
	     {{1,1},52},
	     {1,131}
	   },
		  {"the moon",
		    {"moon",
		     "main base",
		     "aluminium rich"},
		    true,
		    3,
		    nil,
		    1,
	     true,true,
	     {{1,1},49},
	     {1,128}
	   },
		  {"mars",
		    {"planet",
		     "thin atmosphere",
		     "titanium ore"},
		    true,
		    0,
		    16,
		    3,
	     false,false,
	     {{1,1},53},
	     {1,132}
	   },
		  {"asteroids",
		    {"asteroids",
		     "in several sizes",
	      "iron + titanium"},
	     false,
	     0,
	     22,
	     nil,
	     true,true,
	     {{1,1},34},
	     {1,138}
	   },
    {"jupiter",
		    {"gas giant",
		     "largest planet",
		     "uninhabitable"},
		    false,
		    0,
		    28,
		    nil,
	     false,false,
	     {{2,2},38},
	     {1,133}
	   },
		  {"ganymede",
		    {"moon",
		     "large and icy",
		     "hydrogen rich"},
		    true,
		    7,
		    nil,
		    4,
	     false,false,
	     {{1,1},49},
	     {1,128}
	   },
		  {"callisto",
		    {"moon",
		     "old+dark surface",
		     "nitrogen source"},
		    true,
		    7,
		    nil,
		    5,
	     false,false,
	     {{1,1},49},
	     {1,128}
	   },
    {"saturn",
      {"gas giant",
       "large rings",
		     "uninhabitable"},
		    false,
		    0,
		    35,
		    nil,
	     false,false,
	     {{4,2},40},
	     {2,134}
	   },
		  {"titan",
		    {"moon",
		     "thick atmosph.",
		     "uranium"},
		    true,
		    10,
		    nil,
		    6,
	     false,false,
	     {{1,1},49},
	     {1,128}
	   },
    {"uranus",
      {"gas giant",
       "highly inclined",
		     "uninhabitable"},
		    false,
		    0,
		    43,
		    nil,
	     false,false,
	     {{2,2},44},
	     {1,136}
	   },
    {"neptune",
		    {"gas giant",
		     "blue and stormy",
		     "uninhabitable"},
		    false,
		    0,
		    60,
		    nil,
	     false,false,
	     {{2,2},46},
	     {1,137}
	   },
    {"triton",
		    {"moon",
		     "extreme cold",
		     "far away"},
		    true,
		    13,
		    nil,
		    nil,
	     false,false,
	     {{1,1},49},
	     {1,128}}}

		prod={
		  { --1
		    "probe",
		    true,
		    5, --days
		    {1}, --t aluminium
		    {"explores worlds,",
       "not reusable"},
		    1, --weight (t)
		    2, --type
		    {2,70}, --sprite
		    true --producible
		  },
		  { --2
		    "grazer",
		    false,
		    9, --days
		    {4}, --t aluminium
		    {"extracts resources",
		     "from asteroids"},
		    4, --weight (t)
		    2, --type
		    {2,74}, --sprite
		    true --producible
		  },
		  { --3
		    "shuttle",
  		  false,
		    11, --days
		    {4,1},
  		  {"fast and small",
		     "transportation"},
	  	  8, --weight (t)
		    2, --type
		    {2,72}, --sprite
		    true --producible
		  },
		  { --4
		    "freighter",
		    false,
		    15,
		    {10,4,8},
		    {"heavy and slow",
		     "transportation"},
		    30, --weight (t)
		    2,  --type
		    {4,76},
		    true --producible
		  },
		  { --5
		    "i.s. colonizer",
		    false,
		    21,
		    {0,40,0,0,15,5},
		    {"interstellar",
		     "colonisation"},
		    60, --weight (t)
		    2,  --type
		    {4,204},
		    true --producible
		  },
				{ --6
		    "coolant",
		    false,
  		  7, --days
	  	  {nil,nil,nil,nil,1},
	  	  {"coolant for","mercury base"},
		    1, --weight (t)
		    1, --type
		    {1,100},
		    true --producible
		  },
		  { --7
		    "scanner",
		    false,
		    10, --days
		    {nil,nil,2,7},
		    {"enhanced scanner",
		     "for shuttle"},
		    1,  --weight (t)
		    1,  --type
		    {2,171},
		    true --producible
		  },
		  { --8
		    "rescue pod",
      false,
		    0, --days
		    {},
		    {"found in orbit",
		     "around earth"},
		    1,  --weight (t)
		    1,  --type
		    {2,141},
		    false --not producible
		  }
		}

  sta={}
		create_station(4)

		ship_type={
		  {1, --probe
		   2,
		   0,
		   false,
		   nil},
		  {2, --grazer
		   1,
		   20,
		   false,
		   nil},
		  {3, --shuttle
		   2,
		   10,
		   true,
		   nil},
		  {4, --freighter
		   1,
		   100,
		   true,
		   nil},
		  {5, --i.s. colonizer
		   1,
		   12,
		   true,
		   nil}}

	 ship={}
	 ship_cnt={}

--  producing --product or nil
  prod_prog=0 --progress

  sci={
    {"grazer", --1
		   {nil,  --compl. science
		    nil,  --explored world
		    {},   --establ. colonies
		    false},--additional cond.
		   7, --days
		   false, --completed
		   1, --tech. research
		   2, --prod-id
		   0, --progress
		   1},--category
		  {"shuttle", --2
		   {1,    --compl. science
		    nil,  --explored world
		    {},   --establ. colonies
		    false},--additional cond.
		   8, --days
		   false, --completed
		   1, --tech. research
		   3, --prod-id
		   0, --progress
		   1},--category
		  {"freighter", --3
		   {2, --tech. shuttle
		    nil,--explored world
		    {},  --establ. colonies
		    true},--additional cond.
		   13, --days
		   false,
		   1, --tech. research
		   4, --prod-id
		   0, --progress
		   1},--category
		  {"i.s. colonizer", --4
		   {nil,--no compl. sci.
		    nil,--expl. world
		    {},--establ. col.
		    true},--additional cond.
		   15, --days
		   false,
		   1, --tech. research
		   5, --prod-id
		   0, --progress
		   2}, --category
		  {"coolant", --5
		    {nil,--no compl. sci.
		     nil,--expl. world
		     {1,9},--establ. col.
		     false},--additional cond.
		    9, --days
		    false,
		    1, --tech. research
		    6,--prod-id
		    0,--progress
		    4},--other
		  {"scanner", --6
		    {nil,--no compl. sci.
		     nil,--expl. world
		     {},--establ. col.
		     true},--additional cond.
		    9, --days
		    false,
		    1, --tech. research
		    7,--prod-id
		    0,--progress
		    4}--other
  }
  for i=1,#body do
    if i~=4 and i~=6 then
		    sci[#sci+1]={body[i][1],
		     {nil,  --compl. science
		      nil,  --explored world
		      {},   --establ. colonies
		      true},--additional cond.
		     7, --days
		     false, --completed
		     2, --world exploration
		     i, --id of world
		     0, --progress
		     3}
    end
  end

  --create for colonizers:
  -- - products
  -- - ship_types
		for w=1,#body do
		  if w~=4 and w~=6 and body[w][3] then
		    local p=#prod+1
		    prod[p]={
		      sub(body[w][1],1,2).." colonizer",
		      false, --visibility
		      15, --days to prod.
		      {5,1,1}, --resources
		      {"builds colony",
		       "on "..body[w][1]},
		      7, --mass (t)
		      2, --type: ship
		      {4,108},
		      true --producible
		    }
		    ship_type[#ship_type+1]={
		      p,
		      1, --speed
		      0, --capacity
		      false,--cant load items
		      w} --world
		    local x=nil
		    for j=1,#sci do
		      if sci[j][5]==2 and sci[j][6]==w then
		        --world explor.  --id
		        x=j
		        break
		      end
		    end
		    sci[#sci+1]={
  		    sub(body[w][1],1,2).." colonizer",
  		    {x, --completed sci.
  		     nil,
  		     {},
  		     nil},
		      9,
		      false,
		      1, --tech research
		      p, --id of prod.
		      0, --progress
		      2} --category
		    if w==8 or w==9 or w==11 then
		      --extra conditions for
		      --outer colonies
		      --(except triton)
		      sci[#sci][2][3]={
		       1, --mercury
		       5} --mars
		    elseif w==14 then
		      --triton
		      sci[#sci][2][3]={
		       8, --ganymede
		       9,--callisto
		       11}--titan
		    end
		  end
		end
		
		show_view(1)
  
  sci_prj=nil
  sci_cat=1
  sci_ttl={
   "ship",
   "colonizer",
   "world",
   "other"}
  sci_des={
    {"space ship",
     "explore and transport"},
    {"colonization ship",
     "builds station"},
    {"worlds to explore",
     "process probe data"},
    {"other technologies",
     "see descriptions"}
  } 
end

function _update()
  if chapter==3 then
    return
  end
  if btn(❘)==false and block_turn then
    block_turn=false
  end
  if btnp(❘) then
    sfx(2,3)
    msg_ast_too_big=false
    msg_max_ships=false
    msg_already_prod=false
    if cur_loc==0 then
      if cur<6 then
        if cur==1 then
          wrld=4
        end
        show_view(cur)
      else
        if block_turn==false then
          next_turn()
        end
      end
    elseif cur_loc==1 then
      --main view
      if view==1 then      
        if cur_opt[cur]=="hangar" then
          show_view(10)
        elseif cur_opt[cur]=="storage" then
          show_view(9)
        elseif cur_opt[cur]=="resources" then
          show_view(7)
        elseif cur_opt[cur]=="production" then
          show_view(8)
        elseif cur_opt[cur]=="research" then
          show_view(15)
        elseif cur_opt[cur]=="use coolant" then
          local s=find_sta_of_body(wrld)
          sta[s][3][6]-=1
          sta[s][4]=true
          res_rat[2]=350
          show_view(7)
        end
      elseif view==2 then
        --stations
        show_view(1)
        wrld=sta[cur_opt[cur]][1]
      elseif view==3 then
        --ships
        view_ship=cur_opt[cur]
        show_view(11)
      elseif view==8 then
        --production
        if producing then
          --already producing this
          msg_already_prod=true
          sfx(9,3)
        else
        local p=0
        for i=1,#prod do
          if prod[i][2] and prod[i][9] then
            -- visible  and  producible
            p+=1
            if p==cur then
              local ok=true
              if prod[i][7]==2 and #ship>=16 then
                --to many ships?
                msg_max_ships=true
                sfx(9,3)
                break                  
              end
              if producing then
                --already producing
                sfx(9,3)
                break
              end
              for j=1,#prod[i][4] do
                local a=prod[i][4][j]
                if a and a>sta[1][2][1][j] then
                  ok=false
                  break
                end
              end
              if ok then
		              for j=1,#prod[i][4] do
		                local a=prod[i][4][j]
		                if a then
		                  sta[1][2][1][j]-=a
		                end
		              end
		              producing=i
		              sfx(8,2)
                prod_prog=0
              end
              break
            end
          end
          end
        end
      elseif view==10 then
        --hangar
        local s=find_sta_of_body(wrld)
        for i=1,#ship do
          if ship[i][3][1]==1 and ship[i][3][2]==s and ship[i][3][3]==cur then
            view_ship=i
            cur=1
            show_view(11)
            break
          end
        end
      elseif view==11 then
        --ship
        if cur_opt[cur]=="out" then
          show_view(3)
        elseif cur_opt[cur]=="launch" then
          --launch from station to orbit
          ship[view_ship][3][1]=2
          local s=ship[view_ship][3][2]
          ship[view_ship][3][2]=sta[s][1]
          show_view(11)
        elseif cur_opt[cur]=="resources" then
          wrld=sta[ship[view_ship][3][2]][1]
          show_view(13)
        elseif cur_opt[cur]=="items" then
          wrld=sta[ship[view_ship][3][2]][1]
          show_view(14)
        elseif cur_opt[cur]=="explore" then
          body[ship[view_ship][3][2]][7]=true
          deli(ship,view_ship)
          show_view(1)
          wrld=4
        elseif cur_opt[cur]=="land" then
          --land in station
          local w=ship[view_ship][3][2]
          local s=find_sta_of_body(w)
          if s then
            --if station is present
            local h=find_free_hangar(s)
            if h then
              ship[view_ship][3]={1,s,h}
              show_view(10)
              wrld=w
            end
          end
        elseif cur_opt[cur]=="colonize" then
          --colonize world
          wrld=ship[view_ship][3][2]
          create_station(wrld)
          deli(ship,view_ship)
          if wrld==11 and mss_stt_earth==0 then
            mss_stt_earth=1
            add_message "detecting signal from"
            add_message " earth - we should search"
            add_message " with shuttle and scanner"
            add_message " (scanner tech available)"
            show_view(5)
          elseif not msg_coolant and is_available_sci(5) then
            add_message "coolant for mercury"
            add_message " research available"
            msg_coolant=true
            show_view(5)
          else
            show_view(1)
          end
        elseif cur_opt[cur]=="mine" then
          local a=ship[view_ship][3][3]
          local free=get_ship_free_cap(view_ship)
          local total_mass=a[1]+a[2]
          if total_mass<=free then
            ship[view_ship][4][1][2]+=a[1]
            ship[view_ship][4][1][3]+=a[2]
            ship[view_ship][3][3]=nil
          else
            msg_ast_too_big=true    
          end
        elseif cur_opt[cur]=="start" then
          --in orbit: start
          show_view(12)
        elseif cur_opt[cur]=="change" then
          --in flight: change
          show_view(12)
        elseif cur_opt[cur]=="leave" then
          --leave asteroid
          ship[view_ship][3][3]=nil
        elseif cur_opt[cur]=="activate isd" then
          --activate i.s. drive
          frame=0
          sequence=0
          chapter=3
        elseif cur_opt[cur]=="collect pod" then
          local s=nil
          for i=1,#ship do
            if ship[i][1]==3 and ship[i][3][1]==2 and ship[i][3][2]==3 then
              --shuttle in earth orbit
              if get_ship_free_cap(i)>0 then
                s=i
                break
              end
            end
          end
          
          if s then
            --put pod into shuttle
            ship[s][4][2][8]=1
            mss_stt_earth=3
            msg_need_shuttle=false
            prod[8][2]=true
          else
            msg_need_shuttle=true
          end
        end
      elseif view==12 then
        --ship course
        local s=ship[view_ship]
		      if s[3][1]==2 then
		        --orbit
		        s[3][3]=get_body_pos(s[3][2])
 	      end
        s[3][1]=3 --flight
        s[3][2]=cur
        show_view(11)
      elseif view==13 then
        --ship load resources
        if cur<7 then
          local s=ship[view_ship][3][2]
          if ship[view_ship][1]!=5 or cur==4 then
		          --not i.s. colonizer, but allways hydrogen
		          if view_col==1 then
		            --[+]
		            local f=get_ship_free_cap(view_ship)
		            local r=sta[s][2][1][cur]
		            if f>0 and r>0 then
		              ship[view_ship][4][1][cur]+=1
		              sta[s][2][1][cur]-=1
		            end
		          else
		            --[-]
		            if ship[view_ship][4][1][cur]>0 then
		              ship[view_ship][4][1][cur]-=1
		              sta[s][2][1][cur]+=1
		            end
		          end
		        end
        end
        if cur==7 then
          show_view(11)
        end
      elseif view==14 then
        --ship load items
        if cur<#cur_opt then
          --transfer items
          local s=ship[view_ship][3][2]
          local f=get_ship_free_cap(view_ship)
          local t={}
          for i=1,#prod do
            if prod[i][2] and prod[i][7]==1 then
              t[#t+1]=i
            end
          end
          local p=t[cur]
          if view_col==1 then
            --[+]
            if sta[s][3][p]>0 and prod[p][6]<=f then
		            ship[view_ship][4][2][p]+=1
		            sta[s][3][p]-=1
            end
          else
            --[-]
            if ship[view_ship][4][2][p]~=nil and ship[view_ship][4][2][p]>0 then
              ship[view_ship][4][2][p]-=1
              sta[s][3][p]+=1
              if p==8 then
                --rescue pod
                mss_stt_earth=4
                add_message "saved scientists from"
                add_message " rescue pod: new research"
                add_message " project available"
                show_view(5)
              end
            end
          end
        else
          --back
          show_view(11)
        end
      elseif view==15 then
        --research
        if cur_opt[cur]==0 then
          --switch category
          sci_cat+=1
          if (sci_cat>4) sci_cat=1
        else
          if sci[cur_opt[cur]][4]==false then
            sci_prj=cur_opt[cur]
          end
        end
      end
    end
  end
  if cur_loc==1 then
		  if btnp(⬇️) then
		    cur+=1
		  elseif btnp(⬆️) then
		    cur-=1
		  end
    if cur>#cur_opt then
      cur_loc=0
      cur=1
    elseif cur<1 then
	     cur_loc=0
      cur=1
    end
		  if btnp(➡️) then
		    view_col=2
		  elseif btnp(⬅️) then
		    view_col=1
		  end
  elseif cur_loc==0 then
  		if btnp(➡️) then
		    cur+=1
		    if (cur>6) cur=1
		  elseif btnp(⬅️) then
		    cur-=1
		    if (cur<1) cur=6
		  end
    if btnp(⬇️) then
      if #cur_opt>0 then
        cur_loc=1
        cur=1
      end
    elseif btnp(⬆️) then
      if #cur_opt>0 then
        cur_loc=1
        cur=#cur_opt
      end
    end
  end
end

function _draw()
  cls() 
  if chapter==1 then
    play_intro()
  elseif chapter==2 then
    draw_view()
    draw_menu()
  else
    play_end_sequence()
  end
end
-->8
function draw_view()
  local title
  if view==1 then
    local x=72
    title=body[wrld][1]
    cur_opt={}
    local end_pnt={}
    if wrld==4 then
      cur_opt[1]="production"
      end_pnt={
        {{54,47},{105,47},{118,60}},
        {{42,59},{79,59},{89,59}},
        {{38,71},{87,71},{97,71}},
        {{50,83},{76,83},{86,83}},
        {{46,95},{105,95},{111,89}}
      }
    else
      end_pnt={
        {{42,59},{79,59},{89,59}},
        {{38,71},{87,71},{97,71}},
        {{50,83},{76,83},{86,83}},
      }
    end
    cur_opt[#cur_opt+1]="storage"
    cur_opt[#cur_opt+1]="hangar"
    cur_opt[#cur_opt+1]="resources"
    draw_stars(80,42)
		  rectfill(80,48,127,96,0)
    local h=192
    if wrld==4 then
      h=101
    elseif wrld==8 or wrld==9 then
      h=208
    elseif wrld==11 then
      h=224
    elseif wrld==14 then
      h=240
    end
    spr(h,80,48,6,1)
    spr(117,80,56,6,1)
    rect(79,41,127,97,12)
    if wrld==4 then
      cur_opt[5]="research"
		    if producing then  
		      print(prod[producing][1],16,51,12)
		      line(12,41,12,43,12)
		      line(50,41,50,43,12)
		      line(13,42,49,42,1)
		      local l=prod_prog/prod[producing][3]*37
		      line(13,42,13+l,42,12)
		    end
      spr(68,x+38,52,2,2)
      if sci_prj==nil then
        local cnt=0
        for i=1,#sci do
          if sci[i][4]==false and is_available_sci(i) then
            cnt+=1
          end
        end
        if (cnt>0) print(cnt.." available", 16,99,12)
      else
        --show sci project
  		    print(sci[sci_prj][1],16,99,12)
		      line(12,89,12,91,12)
		      line(42,89,42,91,12)
		      line(13,90,41,90,1)
		      local l=sci[sci_prj][7]/sci[sci_prj][3]*29
		      line(13,90,13+l,90,12)
  		  end
      spr(68,x+33,76,2,2)
    elseif wrld==1 then
      local s=find_sta_of_body(wrld)
      if sta[s][3][6]>0 and sta[s][4]==false then
        cur_opt[#cur_opt+1]="use coolant"
        end_pnt[#end_pnt+1]=nil
      end
      if sta[s][4]==true then
        spr(100,x+38,55,1,2)
      end
    end
    spr(68,x+12,53,2,2)
    spr(64,x+18,56,4,4)
    spr(68,x+10,71,2,2)
    local y=33
    if (wrld~=4 ) y+=12
    for i=1,#cur_opt do
      print(cur_opt[i],12,y+i*12,6)
    end
    if cur_loc==1 then
      spr(33,3,y+cur*12-1)
      if end_pnt[cur]~=nil then
        local p=end_pnt[cur]
        line(p[1][1],p[1][2],p[2][1],p[2][2],11)
        line(p[3][1],p[3][2],11)
      end
    end
  elseif view==2 then
    title="stations"
    cur_opt={}
    for i=1,#sta do
      local t=body[sta[i][1]][1]
      cur_opt[i]=i
      print(t,12,20+8*i,6)
    end
    if cur_loc==1 then
      spr(33,2,19+8*cur)
    end
  elseif view==3 then
    title="ships"
    cur_opt={}
    local y0=28
    local y,yd=y0,6
    if #ship==0 then
      print("no ships",16,y,6)
    else
		    for s=1,#ship do
		      cur_opt[s]=s    
		      if s==cur then  
				      local t=ship[s][1]
				      local p=ship_type[t][1]
				      local sz=prod[p][8][1]
				      local sp=prod[p][8][2]
				      line(127,28,127,46,12)
				      line(88,46,127,46,12)
				      spr(sp,111-sz*4,29,sz,2)
				      rectfill(88,47,127,59,1)
				      local tx={}
				      if ship[s][3][1]==1 then
				        --in station
				        tx[1]="in hangar"
				        tx[2]=body[sta[ship[s][3][2]][1]][1]
				      elseif ship[s][3][1]==2 then
				        --at orbit
				        tx[1]="orbiting"
				        tx[2]=body[ship[s][3][2]][1]
				      elseif ship[s][3][1]==3 then
				        --in flight
				        tx[1]="flying to"
				        tx[2]=body[ship[s][3][2]][1]
		        end
				      print(tx[1],89,48,6)
				      print(tx[2],89,54,6)
		      end
		      print(ship[s][2],17,y,6)
		      local snx,sny=24,16
		      if ship[s][3][1]==2 then
		        if ship[s][1]==2 and ship[s][3][2]==6 and ship[s][3][3]~=nil then
		          --grazer at asteroids found something
		          snx,sny=28,20
		        else
  		        snx,sny=24,20
  		      end
		      end
		      if (ship[s][3][1]==3) snx,sny=28,16
		      sspr(snx,sny,4,4,11,y+1)
		      y+=yd
		    end
    end
    if cur_loc==1 then
      spr(33,2,y0+yd*cur-yd-1)
    end
  elseif view==4 then
    title="worlds"
    cur_opt={}
    local x=12
    local y=28
    for i=1,14 do
      if body[i][4]==0 then
        x=12
      else
        x=16
      end
      local c=6
      if body[i][7] then
        if body[i][8] then
          c=12
        else
          c=9
        end
      end
      print(body[i][1],x,y,c)
      cur_opt[i]=i
      y+=6
    end
    if cur_loc==1 then
      y=cur*6+22
      spr(33,3,y-1)
      local b=body[cur]
      spr(b[9][2],96-8*b[9][1][1],28,
          b[9][1][1],
          b[9][1][2])
      print(b[2][1],64,52,6)
      if b[8] then
        print(b[2][2],64,58,6)
        print(b[2][3],64,64)
      else
        if b[7] then
          print("probe landed...",64,58,6)
        else
          print("unexplored",64,58,9)
        end
      end
    end
  elseif view==5 then
    title="messages"
    cur_opt={}
    for i=1,#msg do
      local c=6
      local m=msg[i]
      if (m.trn==turn) c=12
      local y=20+i*8
      print(m.txt,24,y,c)
      if m.txt[1]~=" " then
        print(m.trn,20-4*#tostr(m.trn),y,c)
      end
    end
  elseif view==7 then
    title=body[wrld][1].." - resources"
    local rt1=""
    local rt2=""
    if wrld~=14 then
      rt1="  rate"
      rt2="  kg/d"
    end
    print("           amount"..rt1,6,38,5)
    print("resource     tons"..rt2,6,44,5)
    cur_opt={}
    local y=50
    local s=find_sta_of_body(wrld)
    for i=1,6 do
      if sta[s][2][1][i]>0 or body[wrld][6]==i then
        print(res_name[i],6,y,6)
        print(sta[s][2][1][i],60,y,6)
        if i==body[wrld][6] then
          print(res_rat[body[wrld][6]],85,y,6)
        end
        y+=6
      end
  	 end
  elseif view==8 then
    title=body[wrld][1].." - production"
    local y0=28
    local y=y0
    local visible={}
    if msg_already_prod then
      print("already\nproducing",73,28,8)
    elseif msg_max_ships then
      print("maximum count\nships reached",73,28,8)
    end
    for i=1,#prod do
      local p=prod[i]
      if p[2] and p[9] then
        --visible+producible
        print(p[1],16,y,6)
        if i==producing then
          local s=100*prod_prog\p[3]
          local xt=20+4*#p[1]
          print(s.." %",xt,y,12)
        end
        visible[#visible+1]=i
        y+=6
      end
    end
    cur_opt=visible
    if cur_loc==1 then
      if (cur>#visible) cur=#visible
      spr(33,7,y0+cur*6-7)
      local p=prod[visible[cur]]
      y=90
      print(p[1],50,y+2,7)
      local w=8*p[8][1]
      local x=127-w
      rect(x-1,y-17,x+w,y,17,5)
      spr(p[8][2],x,y-16,p[8][1],2)
      for i=1,6 do
        local amount=p[4][i]
        if amount and amount>0 then
          y+=6
          local col=11
          if amount>sta[1][2][1][i] then
            col=8
          end
          print(amount.." "..res_name[i],58,y+2,col)
        end
      end
      print(p[5][1],53,y+8,6)
      print(p[5][2],53,y+14,6)
    end
  elseif view==9 then
    title=body[wrld][1].." - storage"
    cur_opt={}
    local s=find_sta_of_body(wrld)
    local y=28
    for i=1,#prod do
	     if prod[i][2] and prod[i][7]==1 then
        print(prod[i][1],24,y,6)
        print(sta[s][3][i],12,y,6)
        y+=6
      end
    end
  elseif view==10 then
    title=body[wrld][1].." - hangar"
    cur_opt={0,0,0,0,0,0,0,0}
    local s=find_sta_of_body(wrld)
    for i=1,#ship do
      if ship[i][3][1]==1 then
        --ship is in hangar
        if ship[i][3][2]==s then
          --hangar of current st.
          local h=ship[i][3][3]
          local x=16
          local y=h*6+22
          print(ship[i][2],x,y,6)
          cur_opt[h]=i
        end
      end
    end
    for i=1,8 do
      if cur_opt[i]==0 then
        print("vacant",18,i*6+22,13)
      end
    end
    if cur_loc==1 then
      spr(33,7,cur*6+21)
    end
  elseif view==11 then
    title="ship - "..ship[view_ship][2]
    local s=ship[view_ship]
    local t=ship_type[s[1]]
    print("location: ",0,28,6)
    cur_opt={}
				rectfill(0,81,49,93,1)
				
    rect(0,94,49,127,12)
				if s[3][1]==2 then
      --at orbit
      local b=body[s[3][2]][10]
      draw_stars(1,95)
      spr(b[2],49-b[1]*8,95,b[1],4,true)
				end
				
				--collect content
				local cont={} --content
    for i=1,6 do
      if s[4][1][i]>0 then
        cont[#cont+1]={
          res_name[i],
          s[4][1][i]}
      end
    end
    for i=1,#prod do
      if s[4][2][i]>0 then
        cont[#cont+1]={
          prod[i][1],
          s[4][2][i]}
      end
    end
    
    if t[3]>0 do
		    --show content if this
		    --ship type has storage
		    local x=64
		    local y=114-6*#cont
		    rectfill(x-1,y-1,127,127,1)
		    local tot=0
		    print("content        t",x,y,6)
		    y+=7
		    for i=1,#cont do
		      print(cont[i][1],x,y,6)
		      local cs=tostr(cont[i][2])
		      print(cs,x+64-4*#cs,y,6)
		      tot+=cont[i][2]
		      y+=6
		    end
		    y+=1
		    print("free",x,y,6)
		    local cs=tostr(t[3]-tot)
		    print(cs,x+64-4*#cs,y,6)
    end
    
    if t[1]==5 then
      --i.s. colonizer
      
      --check list
      local x=63
      local r=true
      rectfill(x-1,34,127,64,1)
      print("check list:",x,35,12)
      if s[3][1]==2 and s[3][2]==14 then
        print("◆ orbit triton",x,41,11)
      else
        r=false
        print("⧗ orbit triton",x,41,8)
      end
      --orbit triton
      if s[4][2][6]>0 then
        print("◆ coolant",x,47,11)
      else
        r=false
        print("⧗ coolant",x,47,8)
      end
      if s[4][2][7]>0 then
        print("◆ scanner",x,53,11)
      else
        r=false
        print("⧗ scanner",x,53,8)
      end
      if s[4][1][4]>=10 then
        --10 t hydrogen
        print("◆ 10 t hydrogen",x,59,11)
      else
        r=false
        print("⧗ 10 t hydrogen",x,59,8)
      end
      if (r) cur_opt[#cur_opt+1]="activate isd"
    end
    
    --text for blue info box
    local blu1
    local blu2

    if s[3][1]==1 then
      local b=sta[s[3][2]][1]
      print("station "..body[b][1],40,28,6)
      blu1="in hangar"
      spr(198,1,95,6,4)
      cur_opt[#cur_opt+1]="launch"
      if t[3]>0 then
        cur_opt[#cur_opt+1]="resources"
      end
      if t[4] then
        cur_opt[#cur_opt+1]="items"
      end
    elseif s[3][1]==2 then
      print("orbit "..body[s[3][2]][1],40,28,6)
      blu1="in orbit"
      if s[1]==1 then
        --probe
        if body[s[3][2]][7]==false then
          --unprobed world
          cur_opt[#cur_opt+1]="explore"
        end        
      elseif s[1]==2 and s[3][1]==2 then
        --grazer orbiting
        if s[3][2]==6 then
          --asteroids
          blu1="scanning"
          blu2="asteroids"
          if s[3][3] then
            --found one:
            cur_opt[#cur_opt+1]="mine"
            cur_opt[#cur_opt+1]="leave"
            rectfill(71,35,127,53,1)
            print("found asteroid",72,36,11)
            print("iron     "..s[3][3][1].." t",76,42,6)
            print("titanium "..s[3][3][2].." t",76,48,6)
            spr(139,26,102,2,2)
            if msg_ast_too_big then
              spr(236,10,102,2,2)
            end
          end
        elseif s[3][2]==3 and mss_stt_earth==2 then
          --earth
          spr(141,21,101,2,2)
          blu1="detecting"
          blu2="rescue pod"
          cur_opt[#cur_opt+1]="collect pod"
          if cur_loc==1 and cur==1 then
		          if msg_need_shuttle then
		            print("need shuttle",80,35,8)
		            print("to load the",84,41,8)
		            print("pod into it",84,47,8)
		          else
		            print("loads pod",80,35,12)
		            print("into shuttle",80,41,12)
		          end
          end
        end
      elseif s[1]==3 and s[3][1]==2 and s[3][2]==3 then
        --shuttle orbiting earth
        if mss_stt_earth==1 then
          if s[4][2][7]>0 then
            --scanner on board
            blu1="scanning"
            rect(5,99,44,122,3)
          end
        else
          if mss_stt_earth==2 then
            spr(141,21,101,2,2)
            print("needs a grazer",72,34,10)
            print("to collect pod",72,40,10)
          end
        end
      elseif t[5]~=nil then
        --colonizer
        if t[5]==s[3][2] then
          cur_opt[#cur_opt+1]="colonize"
        end
      end
      cur_opt[#cur_opt+1]="start"
      
      --if station is present
      --show land option:     
      for i=1,#sta do
        if sta[i][1]==s[3][2] then
          cur_opt[#cur_opt+1]="land"
          break
        end
      end
    else --s[3][1]==3
      local dest=s[3][2]
      print("flight to "..body[dest][1],40,28,6)
      blu1="in flight"
      local eta=ceil(abs(get_body_pos(dest)-s[3][3])/ship_type[s[1]][2])
      if (eta==0) eta=1
      blu2="eta "..eta.." d"
      cur_opt[#cur_opt+1]="change"
      draw_stars(1,95)
    end
    
    --show text in blue box
    if blu2 then
      --2 lines
      print(blu1,25-#blu1*2,82,6)
      print(blu2,25-#blu2*2,88,6)      
    elseif blu1 then
      --1 line
      print(blu1,25-#blu1*2,85,6)
    end
    
    cur_opt[#cur_opt+1]="out"
    for i=1,#cur_opt do
      print(cur_opt[i],14,30+i*6,6)
    end
				
    if cur_loc==1 then
      spr(33,5,cur*6+29)
    end
  elseif view==12 then
    --ship course
    title=ship[view_ship][2].." - course"
    cur_opt={}
    local w=nil
    if ship[view_ship][3][1]==2 then
      --mark orbited world
      w=ship[view_ship][3][2]
    end
    for i=1,14 do
      local x=10
      if (body[i][4]~=0) x+=4
      local c=6
      if (w==i) c=12
      print(body[i][1],x,(i-1)*6+28,c)
      cur_opt[i]=i
    end
    if cur_loc==1 then
      spr(33,2,cur*6+21)
    end
  elseif view==13 then
    --ship load resources
    title=ship[view_ship][2].." - cargo"
    cur_opt={1,2,3,4,5,6,0}
    local s=find_sta_of_body(wrld)
    print("station",92,28,13)
    for i=1,6 do
      local y=29+i*6
      print("+ - "..res_name[i],6,y,6)
      print(ship[view_ship][4][1][i],62,y,6)
      print(sta[s][2][1][i],96,y,6)
    end
    local f=get_ship_free_cap(view_ship)
    print("free: "..f.." t",34,77,6)
    print("back",14,71,6)
    if cur_loc==1 then
      if cur<7 then
        local x=6
        local c="+"
        if view_col==2 then
          x+=8
          c="-"
        end
        print("\^i"..c,x,29+cur*6,11)
        print(c,x,29+cur*6,0)
      elseif cur==7 then
        spr(33,6,70)
      end
    end
  elseif view==14 then
    --ship load items
    title=ship[view_ship][2].." - cargo"
    cur_opt={}
    local s=find_sta_of_body(wrld)
    local y=27
    local l=0
    print("ship  station",75,y,13)
    for i=1,#prod do
      if prod[i][2] and prod[i][7]==1 then
         --visible      --items
        l+=1
        y+=6
        print("+ - "..prod[i][1],6,y,6)
        print(ship[view_ship][4][2][i] or 0,78,y,6)
        print(sta[s][3][i],104,y,6)
        cur_opt[#cur_opt+1]=i
        if cur_loc==1 and cur==l then
          line(127,104,127,127,12)
          line(104,127,127,127,12)
          spr(prod[i][8][2],111,111,prod[i][8][1],2)
          rectfill(0,108,72,127,1)
          print("mass: "..prod[i][6].." t",1,109,12)
          print(prod[i][5][1],1,116,12)
          print(prod[i][5][2],1,122,12)
        end
      end
    end
    cur_opt[#cur_opt+1]=0
    print("back",14,y+#cur_opt*6,6)
    local f=get_ship_free_cap(view_ship)
    print("free: "..f.." t",54,y+6+#cur_opt*6,6)
    if cur_loc==1 then
      if cur>#cur_opt then
        cur=#cur_opt
      end
      if cur==#cur_opt then
        spr(33,0,y-1+cur*6)
      else
        local r="+"
        local x=6
        if view_col==2 then
          x+=8
          r="-"
        end
        print("\^i"..r,x,27+cur*6,11)
        print(r,x,27+cur*6,0)
      end
    end
  elseif view==15 then
    --research
    title="research"
    print("category:",16,28,9)
    print(sci_ttl[sci_cat],56,28,10)
    local y=36
    local l=0
    cur_opt={0}
    for i=1,#sci do
      if is_available_sci(i) then
        if sci[i][8]==sci_cat then
          if sci_cat~=3 or sci[i][4]==false then
            --dont show researched worlds
		          local s=sci[i][1]
		          local c=6 --color
		          if sci[i][4] then
		            c=3
		          elseif sci_prj==i then
		            s=s.." ("..sci[sci_prj][7].."/"..sci[i][3]..")"
		            c=12
	  	    			 else
		            s=s.." ("..sci[i][3]..")"
		          end
		          print(s,16,y+l*6,c)
		          l+=1
		          cur_opt[#cur_opt+1]=i
		        end
        end
      end
    end
    if cur_loc==1 then
      if (cur>#cur_opt) cur=#cur_opt
      if cur==0 then
        cur_loc=0
        cur=1
      else
		      local s=cur_opt[cur]
		      if s==0 then
  		      spr(33,6,21+cur*6)
          print(sci_des[sci_cat][1],16,112,6)
          print(sci_des[sci_cat][2],16,118,6)
		      else
  		      spr(33,6,23+cur*6)
  		      if sci[s][5]==1 then
				        local p=sci[s][6]
				        print(prod[p][5][1],16,112,6)
				        print(prod[p][5][2],16,118,6)
				      else
				        local i=sci[s][6]
				        print("analyze data",16,112,6)
				        print("about "..body[i][1],16,118,6)
				      end
				    end
      end
    end
  end
  print(title,0,0,6)
end

function draw_menu()
  spr(0,0,6,16,2)
  local t="day "..turn
  local x=104-flr(#t*2)
  print(t,x,11,7)
  if cur_loc==0 then
    x=cur*16-12
    spr(32,x,20)
  end
end
-->8
function next_turn()
  turn+=1
  
  --missions
  if mss_stt_earth==1 then
 		 for i=1,#ship do
  		  if ship[i][1]==3 and ship[i][4][2][7]>0 then
   		   --shuttle          --scanner
  		    if ship[i][3][1]==2 and ship[i][3][2]==3 then
    		     --orbit              --earth
          add_message(ship[i][2].." found rescue pod")
          mss_stt_earth=2
		      end
   		 end
   	end
  end
  
  --resources
  for s=1,#sta do
    local b=sta[s][1]
    local r=body[b][6]
    local sr=sta[s][2]
    if r then
		    sr[2][r]+=res_rat[r]
		    if sr[2][r]>999 then
		      local f=sr[2][r]\1000
		      if f>0 then
		        sr[1][r]+=f
		        sr[2][r]-=f*1000
		      end
		    end
    end
  end

  --production
  if producing then
    prod_prog+=1
    if prod_prog>=prod[producing][3] then
      add_message("produced "..prod[producing][1])
      if prod[producing][7]==1 then
        --items
        sta[1][3][producing]=1+(sta[1][3][producing] or 0)
        producing=nil
        prod_prog=0
      else
        --ship
        local h_place=find_free_hangar(1)
        if h_place then
		        local s_type=find_ship_type(producing)
		        create_ship(
		          s_type,
		          create_ship_name(s_type),
		          {1,1,h_place})
		        --finish prod
		        if ship_type[s_type][5]~=nil then
		          --unique colonizer
		          prod[producing][2]=false
		        end
		        producing=nil
		        prod_prog=0
				    else
				      --no free hangar
				      --set progress to 100%
				      prod_prog=prod[producing][3]
		      end
		    end
    end
  end

  --flights
  for i=1,#ship do
    local s=ship[i]
    if s[3][1]==3 then
      --flight
      local dest=s[3][2]
      local dist=get_body_pos(dest)
      if dist>s[3][3] then
        s[3][3]+=ship_type[s[1]][2]
		      if s[3][3]>=dist then
		        add_message(s[2].." arrived")
		        s[3][1]=2
		        s[3][3]=nil
		      end
      else
        s[3][3]-=ship_type[s[1]][2]
        if s[3][3]<=dist then
          add_message(s[2].." arrived")
          s[3][1]=2
          s[3][3]=nil
        end
      end
    elseif s[3][1]==2 then
      --orbit
      if s[1]==2 and s[3][2]==6 then
        --grazer at asteroids
        if s[3][3]==nil then
          --scanning
          if rnd()>0.9 then
            add_message(s[2].." found minable a.")
            s[3][3]={
              flr(rnd(8))+1,
              flr(rnd(8))+1}
          end
        end
      end
    end
  end

  --research
  if sci_prj~=nil then
    local sp=sci[sci_prj]
    sp[7]+=1
    if sp[7]>=sp[3] then
      --research completed
      add_message("researched "..sp[1],15)
      sp[4]=true
      if sp[5]==1 then
        --technological project
        local p=sp[6]
        prod[p][2]=true
      elseif sp[5]==2 then
        --world exploration
        body[sp[6]][8]=true
      end
      sci_prj=nil
    end
  end

  --message handling
  if #msg>0 and msg[#msg].trn==turn then
    show_view(5)
    block_turn=true
  end
end

function create_ship_name(stn)
  --stn: ship_type_number
  local nm=prod[ship_type[stn][1]][1]
  ship_cnt[nm]=1+(ship_cnt[nm] or 0)
  local cnt=ship_cnt[nm]
  return nm.."-"..cnt
end

function find_sta_of_body(b)
  --b: body
  --returns false, if no station
  --was found at given body
  for s=1,#sta do
    if sta[s][1]==b then
      return s
    end
  end
  return false
end

function find_free_hangar(s)
  --s: station
  
  --prepare list
  local free={}
  for i=1,8 do
    free[i]=true
  end
  
  --search occupied
  for i=1,#ship do
    if ship[i][3][1]==1 then
      --ship in hangar
      if ship[i][3][2]==s then
        free[ship[i][3][3]]=false
      end
    end
  end
  
  --find next free
  for i=1,8 do
    if (free[i]) return i
  end
  
  --or found no free
  return false
end

function get_body_pos(b)
  if body[b][4]==0 then
    --if circling the sun
    return body[b][5]
  else
    --otherwise circling planet
    return body[body[b][4]][5]
  end
end

function get_ship_free_cap(s)
  --return free ship capacity

  --sum up loaded resources
  local r=0
  for j=1,6 do
    r+=ship[s][4][1][j]
  end

  --sum up loaded items
  local i=0
  for j=1,#prod do
    i+=ship[s][4][2][j]*prod[j][6]
  end

  return ship_type[ship[s][1]][3]-r-i
end

function is_available_sci(s)
  --returns true, if science
  --project s is available
  --or already researched
 
  --check completed science
  if sci[s][2][1]~=nil then
    local c=sci[s][2][1]
    if sci[c][4]==false then
      return false
    end
  end

  --check explored world
  if sci[s][2][2]~=nil then
    local w=sci[s][2][2]
    if body[w][7]==false or body[w][8]==true then
       --not probed or already researched
      return false
    end
  end
  
  --check establ. colonies
  if #sci[s][2][3]>0 then
    for i=1,#sci[s][2][3] do
      local sta_find=false
      for j=1,#sta do
        if sta[j][1]==sci[s][2][3][i] then
          sta_find=true
          break
        end
      end
      if sta_find==false then
        return false
      end
    end
  end
  
  --check additional condition
  if sci[s][2][4] then
    if sci[s][5]==2 and sci[s][4]==false then
      --world expl. not compl.
      return body[sci[s][6]][7]
    end
    if s==3 then
      --freighter
      local f=false
      for i=1,#sta do
        if sta[i][1]>6 then
          --station beyond mars
          f=true
          break
        end
      end
      if f==false then
        return false
      end
    elseif s==4 then
      --i.s. colonizer
      if mss_stt_earth<4 then
        return false
      end
    elseif s==6 then
      --rescue pod
      if mss_stt_earth<1 then
        return false
      end
    end
  end
  
  --otherwise:
  return true
end

function find_ship_type(p)
  --p: product-id
  for i=1,#ship_type do
    if ship_type[i][1]==p then
      return i
    end
  end
end

function create_station(b)
  --b: body
  local s=#sta+1
	 sta[s]={b,
		  {{0,0,0,0,0,0}, --res (t)
		   {0,0,0,0,0,0}},--res (kg)
		  {}, --prepare storage
		  false --mission state
		}
		
		--initialize storage
		for i=1,#prod do
		  sta[s][3][i]=0
		end
end

function create_ship(t,name,location)
  local s=#ship+1
  ship[s]={
    t,
    name,
    {location[1],
     location[2],
     location[3]},
    {{0,0,0,0,0,0},
     {}}
  }
  for i=1,#prod do
    ship[s][4][2][i]=0
  end
end

function play_end_sequence()
  if (sequence==20) sfx(15,3)
  if (sequence==40) sfx(12,0)
  if (sequence==80) sfx(11,1)
  if (sequence==120) sfx(14,2)
  if sequence==210 then
    sfx(-1,1)
    sfx(-1,2)  
    sfx(-1,3)
    sfx(13,0)
  end
  if (sequence==240) sfx(-1,0)

  local t={
    "navigation started...",
    "ship aligned...",
    "i.s. drive activated...",
    "energy increased...",
    "i.s. travel initiated!"}
  frame+=1
  
  if sequence<135 then
    srand(1)
    for _=1,60 do
      local x=rnd(42)
      local y=rnd(42)
      local c=rnd({7,6,5})
      pset(x*3,y*3,c)
    end
  end
  
  if sequence<120 then
		  for i=1,#t do
		    if i*20<=sequence then
		      rectfill(0,i*8-1,#t[i]*4+1,i*8+6,0)
		      print(t[i],0,i*8,10)
		    end
		  end
  end
  
  if sequence<130 then
    circfill(63,63,(sequence-120)*8,1)
  else
    local bg=1
    if (sequence>135) bg=13
    if (sequence>140) bg=12
    if (sequence>145) bg=7
    rectfill(0,0,127,127,bg)
  end
  if sequence>126 and sequence<=135 then
    circfill(63,63,(sequence-126)*8,13)
  end
  if sequence>131 and sequence<=140 then
    circfill(63,63,(sequence-131)*8,12)
  end
  if sequence>136 and sequence<=145 then
    circfill(63,63,(sequence-136)*8,7)
  end
  
  if frame>3 then
    sequence+=1
    frame=0
  end

  if (sequence>180) print("ship entered hyperspace",18,10,1)

  if (sequence>210) print("connection lost",34,20,1)

  if (sequence>240) print("success!",48,110,1)

end

function play_intro()
  if sequence==0 then
   music(1,4000)
  end
  draw_stars(40,48)
  rect(39,47,88,80,5)
  if sequence>0 and sequence<200 then
    print("earth",41,41,12)
    spr(143,40,48,1,4)
  end
  if sequence>=200 and sequence<400 then
    print("earth",41,41,12)
    print("lost",72,82,9)
    spr(131,40,48,1,4)
  end
  if sequence>=400 and sequence<600 then
    print("last hope",41,41,9)
  end
  if sequence>=600 and sequence<800 then
    print("last hope",41,41,9)
    print("the moon",56,82,12)
    spr(128,80,48,1,4,true)
  end
  if sequence>700 then
    music(-1,750)
  end
  if sequence>=800 then
    chapter=2
    music(-1)
    sfx(0,1)
  end
  sequence+=1
  if btn(❘) or btn(🅾️) then
    sequence=800
  end
end

function add_message(t)
  msg[#msg+1]={
    txt=t,
    trn=turn}
  while #msg>10 do
    for j=2,#msg do
      msg[j-1]=msg[j]
    end
    msg[#msg]=nil
  end
end

function show_view(v)
  if chapter~=2 then
    return
  end
  if v~=view then
    --background sound
    if v==1 or v>8 and v<11 then
      sfx(0,1)
      sfx(-1,2)
    elseif v==4 then
      sfx(5,1)
      sfx(-1,2)
    elseif v==5 then
      sfx(6,1)
      sfx(-1,2)
    elseif v==7 then
      if wrld~=14 then
        sfx(0,1)
        sfx(3,2)
      end
    elseif v==8 then
      sfx(0,1)
      if producing then
        sfx(8,2)
      else
        sfx(-1,2)
      end
    elseif v>10 and v<13 then
      sfx(-1,2)
      local s=ship[view_ship]
      if s[3][1]==3 then
        sfx(4,1)
      elseif v==11 and s[1]==3 and s[3][1]==2 and s[3][2]==3 and s[4][2][7]>0 and mss_stt_earth==1 then
        --scanner-shuttle in earth orbit
        sfx(10,1)
      elseif v==11 and s[1]==2 and s[3][1]==2 and s[3][2]==6 then
        --grazer scanning asteroids
        sfx(7,1)
      else
        sfx(-1,1)
      end
    elseif v==15 then
      sfx(0,1)
      sfx(1,2)
    else
      sfx(-1,1)
      sfx(-1,2)
    end
  end
  view=v
end

function draw_stars(x,y)
  if #stars==0 then
    srand(2)
    for i=1,32 do
      stars[#stars+1]={
        rnd(48),rnd(32)}
    end
  end

  for i=1,32 do
    pset(x+stars[i][1],
         y+stars[i][2],
         5+i%3)
  end
end