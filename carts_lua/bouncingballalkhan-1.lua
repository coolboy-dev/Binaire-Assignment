-- bouncing ball
-- a pico-8 take on the 1950s
-- bouncing ball simulation
-- v1.0

-- ===== tuning =====
gravity=0.12
ground_y=94
hud_b=19
sky_t=20
grd_b=112
hole_depth=8
trail_max=140

-- ===== boot =====
function _init()
 poke(0x5f2d,1)
 t=0
 shake=0
 pmb=0
 mx,my,wheel,kchar=0,0,0,""
 mclick=false
 calc_hops()
 make_stars()
 make_specks()
 parts={}
 trail={}
 msel=1
 best=0
 run=0
 level=1
 attempt=1
 freq=4
 load_level()
 demo={x=-6,y=44,vy=0,vx=0.8}
 state="splash"
end

function make_stars()
 stars={}
 local cols={6,7,12,13,14,8,9,11,10,3}
 for i=1,72 do
  add(stars,{
   x=flr(rnd(128)),
   y=2+flr(rnd(ground_y-6)),
   c=rnd()<0.5 and 5 or cols[flr(rnd(#cols))+1],
   tw=flr(rnd(240))
  })
 end
end

function make_specks()
 specks={}
 for i=1,600 do
  local r=rnd()
  add(specks,{
   x=flr(rnd(128)),
   y=ground_y+3+flr(rnd(grd_b-ground_y-2)),
   c=r<0.5 and 1 or (r<0.82 and 0 or (r<0.95 and 13 or 14))
  })
 end
end

-- ===== levels =====
-- order the powers so the extremes
-- show up early: every one of 1..8
-- owns a level inside the first eleven
freq_plan={2,6,1,7,3,8,5,4}

function ceilx(a)
 return -flr(-a)
end

-- a bounce always takes the same whole
-- number of frames, so touchdowns sit
-- on an arithmetic grid
function calc_hops()
 hop_f={}
 for f=1,8 do
  local y,vy=ground_y-2,-(1.2+f*0.35)
  for n=1,300 do
   vy+=gravity
   y+=vy
   if y+2>=ground_y and vy>0 then
    hop_f[f]=n
    break
   end
  end
 end
end

function fall_f(sy)
 local y,vy=sy,0
 for n=1,300 do
  vy+=gravity
  y+=vy
  if y+2>=ground_y and vy>0 then
   return n
  end
 end
 return 300
end

-- where the ball lands if the player
-- just holds power f the whole way
function grid_spots(t0,vx,f)
 local out,k={},0
 while true do
  local x=8+vx*(t0+k*hop_f[f])
  if x>128 then break end
  add(out,x)
  k+=1
 end
 return out
end

-- put the hole on a touchdown of the
-- target power, preferring spots no
-- other power can reach by itself
function place_hole(base,f,vxn,w1,w2)
 local bn,bd,bw,cands=99,999,9,{}
 local nalt,dalt,mark={},{},{}
 for wi=0,(w2 and 1 or 0) do
  local w=(wi==0) and w1 or w2
  for si=0,8 do
   local sy=30+si*3
   local t0=fall_f(sy)
   for vi=0,vxn-1 do
    local vx=min(1,base+vi*0.05)
    for hx=55,120-w do
     nalt[hx]=0 dalt[hx]=0 mark[hx]=0
    end
    for g=1,8 do
     if g!=f then
      for v in all(grid_spots(t0,vx,g)) do
       -- the rim rule commits a ball whose
       -- previous centre was over the hole,
       -- so the catch window is one frame
       -- of travel wider than the hole
       local a=max(55,ceilx(v-w-vx))
       local b=min(120-w,flr(v))
       for hx=a,b do
        if mark[hx]!=g then
         mark[hx]=g
         nalt[hx]+=1
         dalt[hx]+=abs(g-f)
        end
       end
      end
     end
    end
    for s in all(grid_spots(t0,vx,f)) do
     local a=max(55,ceilx(s-w+2))
     local b=min(120-w,flr(s-2))
     for hx=a,b do
      local n,d=nalt[hx],dalt[hx]
      if n<bn or (n==bn and d<bd) then
       bn,bd,bw,cands=n,d,wi,{}
      end
      if n==bn and d==bd and wi==bw then
       add(cands,{sy=sy,vx=vx,hx=hx,w=w})
      end
     end
    end
   end
  end
 end
 if #cands>0 then
  local c=cands[flr(rnd(#cands))+1]
  start_y,lvx=c.sy,c.vx
  hole_x,hole_w=c.hx,c.w
 else
  start_y,lvx,hole_w=40,base,w1
  hole_x=flr(rnd(50))+65
 end
end

function level_setup()
 local base,w1
 if level==1 then
  w1,base,target_freq=14,0.7,4
 elseif level==2 then
  w1,base,target_freq=12,0.75,3
 elseif level==3 then
  w1,base,target_freq=10,0.8,5
 else
  if level<=6 then
   w1,base=12,0.75
  elseif level<=9 then
   w1,base=10,0.8
  else
   w1,base=8,min(0.95,0.85+(level-10)*0.02)
  end
  target_freq=freq_plan[(level-4)%8+1]
 end
 hole_w=w1
 -- the tutorial keeps the documented
 -- speed and width; later levels may
 -- run a touch faster or tighten the
 -- hole by 2px if that is what makes
 -- the power unique
 if level<=3 then
  place_hole(base,target_freq,1,w1)
 else
  place_hole(base,target_freq,4,w1,
   w1>8 and w1-2 or nil)
 end
 hole_x=mid(55,hole_x,120-hole_w)
end

function load_level()
 attempt=1
 freq=4
 level_setup()
 reset_ball()
 state="ready"
end

function reset_ball()
 ball={x=8,y=start_y,vx=lvx,vy=0,r=2,
  sq=0,sunk=false}
 trail={}
 parts={}
 shake=0
end

function bounce_power()
 return 1.2+freq*0.35
end

-- ===== input =====
function upd_input()
 mx,my=stat(32),stat(33)
 local b=stat(34)
 mclick=(b&1)>0 and (pmb&1)==0
 pmb=b
 kchar=stat(31)
 wheel=stat(36)
end

function ok_press()
 return btnp(5) or btnp(4) or mclick or kchar==" "
end

function any_press()
 return ok_press() or btnp(0) or btnp(1)
  or btnp(2) or btnp(3) or kchar!=""
end

function upd_freq()
 local d=0
 if btnp(0) then d=-1 end
 if btnp(1) then d=1 end
 if wheel!=0 then
  d=wheel>0 and 1 or -1
 end
 if d!=0 then
  local nf=mid(1,freq+d,8)
  if nf!=freq then
   freq=nf
   sfx(3)
  end
 end
end

-- ===== physics =====
function over_hole()
 return ball.x>=hole_x
  and ball.x<=hole_x+hole_w
end

function upd_ball()
 if ball.sq>0 then ball.sq-=1 end
 local py,px=ball.y,ball.x
 ball.vy+=gravity
 ball.x+=ball.vx
 ball.y+=ball.vy
 -- the centre decides: if it was over
 -- the hole when the ball reached the
 -- rim, the pit walls hold it inside
 local was=px>=hole_x
  and px<=hole_x+hole_w
 if (was or over_hole())
 and ball.y+ball.r>=ground_y then
  ball.sunk=true
 end
 if ball.sunk then
  ball.x=mid(hole_x+ball.r,ball.x,
   hole_x+hole_w-ball.r)
 elseif not over_hole()
 and ball.y+ball.r>=ground_y
 and ball.vy>0
 and py+ball.r<=ground_y+2 then
  ball.y=ground_y-ball.r
  ball.vy=-bounce_power()
  ball.sq=3
  sfx(flr((freq-1)/3))
  dust()
 end
end

function upd_trail()
 add(trail,{x=ball.x,y=ball.y})
 if #trail>trail_max then
  deli(trail,1)
 end
end

function check_win()
 if over_hole() and ball.y>ground_y+4 then
  state="win"
  sfx(4)
  shake=3
  -- the run counts levels cleared
  -- without a single miss
  if attempt==1 then
   run+=1
   if run>best then best=run end
  else
   run=0
  end
  local cols={10,7,11,9}
  for i=1,10 do
   add(parts,{
    x=ball.x,y=ground_y+2,
    dx=rnd(3)-1.5,dy=-rnd(2)-0.5,
    l=20+flr(rnd(12)),
    c=cols[flr(rnd(4))+1]
   })
  end
 end
end

function check_lose()
 if ball.x>132 or ball.y>132 then
  state="lose"
  run=0
  sfx(5)
 end
end

function upd_sink()
 local fl=ground_y+hole_depth-ball.r
 ball.x=mid(hole_x+ball.r,ball.x,
  hole_x+hole_w-ball.r)
 ball.vy+=gravity
 ball.y+=ball.vy
 if ball.y>=fl then
  ball.y=fl
  if abs(ball.vy)>0.4 then
   ball.vy=-ball.vy*0.35
  else
   ball.vy=0
  end
 end
end

function dust()
 for i=1,4 do
  add(parts,{
   x=ball.x,y=ground_y-1,
   dx=rnd(2)-1,dy=-rnd(1)-0.2,
   l=8+flr(rnd(6)),c=11
  })
 end
end

function upd_parts()
 for p in all(parts) do
  p.x+=p.dx
  p.y+=p.dy
  p.dy+=0.08
  p.l-=1
  if p.l<=0 then del(parts,p) end
 end
end

function upd_demo()
 demo.vy+=gravity
 demo.x+=demo.vx
 demo.y+=demo.vy
 if demo.y>=ground_y-2 then
  demo.y=ground_y-2
  demo.vy=-2.8
 end
 if demo.x>134 then
  demo.x=-6
  demo.y=40
  demo.vy=0
 end
end

-- ===== menu =====
function menu_items()
 return {
  "start game",
  "how to play"
 }
end

function upd_menu()
 if btnp(2) then
  msel=msel>1 and msel-1 or 2
  sfx(6)
 end
 if btnp(3) then
  msel=msel<2 and msel+1 or 1
  sfx(6)
 end
 for i=1,2 do
  local y=60+(i-1)*12
  if my>=y-4 and my<=y+8
  and mx>20 and mx<108 and msel!=i then
   msel=i
   sfx(6)
  end
 end
 if ok_press() then
  menu_pick()
 end
end

function menu_pick()
 sfx(7)
 if msel==1 then
  level=1
  run=0
  load_level()
 else
  state="help"
 end
end

-- ===== update =====
function _update()
 t+=1
 upd_input()
 upd_parts()
 if shake>0 then
  shake*=0.85
  if shake<0.1 then shake=0 end
 end
 if state=="splash" then
  upd_demo()
  if any_press() then
   state="menu"
   msel=1
   sfx(7)
  end
 elseif state=="menu" then
  upd_demo()
  upd_menu()
 elseif state=="help" then
  if ok_press() then
   state="menu"
   sfx(6)
  end
 elseif state=="ready" then
  upd_freq()
  if ok_press() then
   state="playing"
   sfx(7)
  end
 elseif state=="playing" then
  upd_freq()
  upd_ball()
  upd_trail()
  check_win()
  check_lose()
  if btnp(4) then
   attempt+=1
   run=0
   reset_ball()
   state="ready"
  end
 elseif state=="win" then
  upd_sink()
  if ok_press() then
   level+=1
   load_level()
  end
 elseif state=="lose" then
  if ok_press() then
   attempt+=1
   reset_ball()
   state="ready"
  end
 end
end

-- ===== text helpers =====
function txtw(s)
 return print(s,0,-30)
end

function ctext(s,y,c)
 print(s,64-txtw(s)/2,y,c)
end

function n2(v)
 return (v<10 and "0" or "")..v
end

-- ===== drawing =====
function draw_moon(cx,cy)
 circfill(cx,cy,6,13)
 circfill(cx-4,cy-3,6,1)
 pset(cx+3,cy-4,12)
 pset(cx+5,cy+3,12)
end

function draw_ground(ingame)
 rectfill(0,ground_y,127,grd_b,2)
 for s in all(specks) do
  pset(s.x,s.y,s.c)
 end
 rectfill(0,ground_y,127,ground_y+1,11)
 line(0,ground_y+2,127,ground_y+2,3)
 for x=0,127,2 do
  if (x*7)%5<2 then
   pset(x,ground_y-1,11)
  end
 end
 if ingame then
  local hl,hr=hole_x,hole_x+hole_w
  rectfill(hl+1,ground_y,hr-1,ground_y+hole_depth,0)
  line(hl,ground_y,hl,ground_y+hole_depth,11)
  line(hr,ground_y,hr,ground_y+hole_depth,11)
  line(hl,ground_y+hole_depth,hr,ground_y+hole_depth,11)
 end
 rectfill(0,grd_b+1,127,127,0)
 for x=0,127,3 do
  pset(x,grd_b+1,2)
 end
end

function draw_scene(ingame)
 local top=ingame and sky_t or 0
 rectfill(0,top,127,ground_y-1,1)
 for s in all(stars) do
  if s.y>=top+1 then
   local c=s.c
   if (t+s.tw)%240<6 then c=7 end
   pset(s.x,s.y,c)
  end
 end
 draw_moon(ingame and 105 or 114,ingame and 33 or 62)
 draw_ground(ingame)
 if not ingame then
  circfill(demo.x,demo.y,3,9)
  circfill(demo.x,demo.y,2,10)
  pset(demo.x-1,demo.y-1,7)
 end
end

function draw_trail()
 local n=#trail
 for i=1,n do
  local f=i/n
  local c=5
  if f>0.9 then
   c=7
  elseif f>0.6 then
   c=6
  elseif f<0.25 then
   c=13
  end
  pset(trail[i].x,trail[i].y,c)
 end
end

function draw_parts()
 for p in all(parts) do
  pset(p.x,p.y,p.l<5 and 5 or p.c)
 end
end

function draw_ball()
 local bx,by=ball.x,ball.y
 if ball.sq>0 then
  ovalfill(bx-4,by-1,bx+4,by+3,9)
  ovalfill(bx-3,by-1,bx+3,by+2,10)
 else
  circfill(bx,by,3,9)
  circfill(bx,by,2,10)
 end
 pset(bx-1,by-1,7)
end

function draw_slider()
 local y=7
 line(4,y,4,y+4,8)
 line(3,y+1,3,y+3,8)
 pset(2,y+2,8)
 line(41,y,41,y+4,8)
 line(42,y+1,42,y+3,8)
 pset(43,y+2,8)
 rect(6,y,39,y+4,1)
 for i=1,8 do
  local cx=7+(i-1)*4
  if i==freq then
   rectfill(cx,y+1,cx+2,y+3,7)
  elseif i<freq then
   rectfill(cx,y+2,cx+2,y+2,12)
  else
   pset(cx+1,y+2,5)
  end
 end
end

function draw_hud()
 rectfill(0,0,127,hud_b,0)
 print("freq",2,1,13)
 draw_slider()
 print(n2(freq),21,13,10)
 print("*",33,1,10)
 print("bouncing ball",39,1,14)
 print("*",93,1,10)
 print("attempt",98,1,13)
 print(n2(attempt),108,7,10)
 print("run "..n2(run),50,13,12)
 print("best "..n2(best),98,13,11)
 for x=0,127,3 do
  pset(x,hud_b,(x%6==0) and 13 or 2)
 end
end

function draw_footer()
 local msg,c="aim for hole",12
 if state=="ready" then
  msg="press x to drop"
  c=10
 elseif state=="win" then
  msg="x - next level"
  c=11
 elseif state=="lose" then
  msg="x - retry"
  c=8
 end
 local w=txtw(msg)
 local x=64-w/2
 print(msg,x,120,c)
 print("<",x-8,120,8)
 print(">",x+w+4,120,8)
 print("lv"..n2(level),2,120,5)
end

function banner(l1,c1,l2)
 local w=max(txtw(l1),txtw(l2))+16
 local x0=64-w/2
 rectfill(x0,42,x0+w,62,0)
 rect(x0,42,x0+w,62,c1)
 rect(x0+2,44,x0+w-2,60,1)
 ctext(l1,47,c1)
 ctext(l2,55,6)
end

function draw_splash()
 ctext("\^w\^t\^o0ffbouncing ball",28,14)
 ctext("physics arcade",48,12)
 for x=32,96 do
  if x%2==0 then pset(x,58,2) end
 end
 if t%40<30 then
  rect(27,70,100,81,2)
  ctext("press any button",73,7)
 end
end

function draw_menu()
 ctext("\^w\^t\^o0ffbouncing ball",22,14)
 local it=menu_items()
 for i=1,2 do
  local y=60+(i-1)*12
  local c=(i==msel) and 10 or 6
  ctext(it[i],y,c)
  if i==msel then
   local w=txtw(it[i])
   circfill(64-w/2-7,y+2,2,10)
   pset(64-w/2-8,y+1,7)
  end
 end
 ctext("x select    up/down move",120,6)
end

function draw_help()
 rectfill(6,24,121,102,0)
 rect(6,24,121,102,13)
 ctext("how to play",28,10)
 local lines={
  "the ball bounces on its own",
  "and drifts right by itself.",
  "",
  "left/right set freq 1-8. it",
  "changes only the next hop,",
  "and resets to 4 each level.",
  "",
  "each level fits one power.",
  "clear it first try to grow",
  "your run. best = longest."
 }
 for i=1,#lines do
  print(lines[i],11,34+(i-1)*6,6)
 end
 ctext("o restart    x back",94,12)
end

function draw_corners()
 for i=0,1 do
  for j=0,1-i do
   pset(i,j,0)
   pset(127-i,j,0)
   pset(i,127-j,0)
   pset(127-i,127-j,0)
  end
 end
end

function _draw()
 cls(0)
 if shake>0 then
  camera(rnd(shake)-shake/2,rnd(shake)-shake/2)
 else
  camera()
 end
 if state=="splash" then
  draw_scene(false)
  draw_splash()
 elseif state=="menu" then
  draw_scene(false)
  draw_menu()
 elseif state=="help" then
  draw_scene(false)
  draw_help()
 else
  draw_scene(true)
  draw_trail()
  draw_parts()
  draw_ball()
  draw_hud()
  draw_footer()
  if state=="win" then
   banner("hole!",10,attempt==1
    and "run "..n2(run) or "run reset")
  elseif state=="lose" then
   banner("missed!",8,"run reset")
  end
 end
 camera()
 draw_corners()
end