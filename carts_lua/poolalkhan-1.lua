-- pool 1954
-- arcade pool for pico-8,
-- after the 1954 simulation by
-- w.g.brown and t.lewis

-->8
-- config

tl=9 tr=118 tt=20 tb=101
brad=2.5
fricv=0.985
maxsp=2.2
wallb=0.92
ballb=0.96
prad=4
setfrm=10
cuex=35 cuey=60
rackx=83 racky=60
sfxcool=3

pockets={
 {9,20},{64,20},{118,20},
 {9,101},{64,101},{118,101}}

powr={0.55,0.88,1.21,1.54,1.87,2.2}

bcol={10,12,8,13,9,11,4,0,
      10,12,8,13,9,11,4}

respots={
 {35,60},{30,60},{25,60},
 {35,55},{35,65},{30,55},
 {30,65},{40,60},{35,45},
 {35,75},{16,60},{20,45},
 {20,75}}

-->8
-- main

function _init()
 poke(0x5f2d,1)
 t=0
 best=0
 vsai=false
 msel=1
 mdown=false
 usemouse=false
 pmx,pmy=-9,-9
 parts={}
 new_game()
 state="splash"
 music(0)
end

function _update60()
 t+=1
 tick_fx()
 read_mouse()
 if state=="splash" then
  upd_splash()
 elseif state=="menu" then
  upd_menu()
 elseif state=="help" then
  upd_help()
 elseif state=="aim" then
  upd_aim()
 elseif state=="strike" then
  upd_strike()
 elseif state=="moving" then
  upd_physics()
 elseif state=="resolve" then
  resolve_shot()
 elseif state=="gameover" then
  upd_gameover()
 end
end

function tick_fx()
 if msgt>0 then msgt-=1 end
 if shake>0 then shake-=1 end
 if sfxcd>0 then sfxcd-=1 end
 if flash then
  flash[3]-=1
  if flash[3]<=0 then flash=nil end
 end
 for b in all(balls) do
  if b.pop>0 then b.pop-=1 end
 end
 upd_parts()
end

function read_mouse()
 local mx,my=stat(32),stat(33)
 if abs(mx-pmx)+abs(my-pmy)>1 then
  usemouse=true
 end
 pmx,pmy=mx,my
 local d=band(stat(34),1)==1
 mclick=d and not mdown
 mdown=d
end

function anypress()
 for i=0,5 do
  if btnp(i) then return true end
 end
 return mclick
end

-->8
-- flow

function new_game()
 s1=0 s2=0
 player=1
 shots=0
 shotsc=0
 scratch=false
 aim=0
 plev=3
 longaim=false
 settle=0
 aitim=0
 hold=0
 gotim=0
 msg="" msgt=0
 shake=0
 sfxcd=0
 flash=nil
 parts={}
 rack_balls()
 state="aim"
end

function start_game(ai)
 vsai=ai
 music(-1,400)
 new_game()
 sfx(6)
end

function switch_player()
 player=3-player
 aitim=0
end

function setmsg(s)
 msg=s
 msgt=60
end

function addscore(n)
 if player==1 then
  s1+=n
 else
  s2+=n
 end
end

-- decide what happens once every
-- ball has come to rest
function resolve_shot()
 if shotsc>=3 then
  setmsg("combo x"..shotsc)
 elseif shotsc==2 then
  setmsg("double!")
 end
 if remaining<=0 then
  best=max(best,max(s1,s2))
  shotsc=0
  scratch=false
  gotim=0
  state="gameover"
  sfx(5)
  confetti()
  return
 end
 if scratch then
  switch_player()
  respot_cue()
  setmsg("foul!")
 elseif shotsc==0 then
  switch_player()
 end
 shotsc=0
 scratch=false
 aitim=0
 state="aim"
end

function winner()
 if s1>s2 then return 1 end
 if s2>s1 then return 2 end
 return 0
end

function pname(p)
 if p==2 and vsai then return "cpu" end
 return "p"..p
end

-->8
-- balls

function rack_balls()
 balls={}
 cue={x=cuex,y=cuey,vx=0,vy=0,
  r=brad,num=0,col=7,
  active=true,cue=true,pop=0}
 add(balls,cue)
 local nums={}
 for i=1,15 do nums[i]=i end
 for i=15,2,-1 do
  local j=1+flr(rnd(i))
  nums[i],nums[j]=nums[j],nums[i]
 end
 -- the 8 always racks in the middle
 for i=1,15 do
  if nums[i]==8 then
   nums[i],nums[5]=nums[5],nums[i]
  end
 end
 local k=1
 for c=0,4 do
  for r=0,c do
   local n=nums[k]
   k+=1
   add(balls,{
    x=rackx+c*4.5,
    y=racky+(r-c/2)*5,
    vx=0,vy=0,r=brad,
    num=n,col=bcol[n],
    active=true,cue=false,pop=0})
  end
 end
 remaining=15
end

function spot_free(x,y)
 if x-brad<tl or x+brad>tr then return false end
 if y-brad<tt or y+brad>tb then return false end
 for b in all(balls) do
  if b.active and not b.cue then
   local dx=b.x-x
   local dy=b.y-y
   if dx*dx+dy*dy<36 then return false end
  end
 end
 return true
end

function place_cue(x,y)
 cue.x=x cue.y=y
 cue.vx=0 cue.vy=0
 cue.active=true
 cue.pop=0
end

function respot_cue()
 for s in all(respots) do
  if spot_free(s[1],s[2]) then
   place_cue(s[1],s[2])
   return
  end
end
 for y=tt+3,tb-3,3 do
  for x=tl+3,tr-3,3 do
   if spot_free(x,y) then
    place_cue(x,y)
    return
   end
  end
 end
 place_cue(cuex,cuey)
end

function balls_stopped()
 for b in all(balls) do
  if b.active and (b.vx!=0 or b.vy!=0) then
   return false
  end
 end
 return true
end

function live_balls()
 local n=0
 for b in all(balls) do
  if b.active and not b.cue then n+=1 end
 end
 return n
end

-->8
-- physics

-- one frame: two substeps of
-- move -> pockets -> walls ->
-- ball collisions, then friction
function upd_physics()
 for s=1,2 do
  for b in all(balls) do
   if b.active then
    b.x+=b.vx*0.5
    b.y+=b.vy*0.5
    check_pocket(b)
    if b.active then check_wall(b) end
   end
  end
  local n=#balls
  for i=1,n-1 do
   local a=balls[i]
   if a.active then
    for j=i+1,n do
     local b=balls[j]
     if b.active then
      check_ball_collision(a,b)
     end
    end
   end
  end
 end
 apply_friction()
 if balls_stopped() then
  settle+=1
 else
  settle=0
 end
 if settle>=setfrm then
  state="resolve"
 end
end

function apply_friction()
 for b in all(balls) do
  if b.active then
   b.vx*=fricv
   b.vy*=fricv
   if abs(b.vx)<0.02 and abs(b.vy)<0.02 then
    b.vx=0 b.vy=0
   end
   local sp=sqrt(b.vx*b.vx+b.vy*b.vy)
   if sp>maxsp then
    b.vx*=maxsp/sp
    b.vy*=maxsp/sp
   end
   b.x=mid(tl+b.r,b.x,tr-b.r)
   b.y=mid(tt+b.r,b.y,tb-b.r)
  end
 end
end

function check_pocket(b)
 for p in all(pockets) do
  local dx=b.x-p[1]
  local dy=b.y-p[2]
  if dx*dx+dy*dy<=prad*prad then
   b.active=false
   b.vx=0 b.vy=0
   b.pop=4
   flash={p[1],p[2],5}
   if b.cue then
    scratch=true
    sfx(4)
    spark(p[1],p[2],6,8,0.8)
   else
    shotsc+=1
    remaining-=1
    addscore(1)
    sfx(3)
    spark(p[1],p[2],8,10,0.9)
    shake=max(shake,2)
   end
   return
  end
 end
end

function check_wall(b)
 local r=b.r
 local hit=0
 if b.x-r<tl then
  b.x=tl+r
  b.vx=abs(b.vx)*wallb
  hit=abs(b.vx)
 elseif b.x+r>tr then
  b.x=tr-r
  b.vx=-abs(b.vx)*wallb
  hit=abs(b.vx)
 end
 if b.y-r<tt then
  b.y=tt+r
  b.vy=abs(b.vy)*wallb
  hit=max(hit,abs(b.vy))
 elseif b.y+r>tb then
  b.y=tb-r
  b.vy=-abs(b.vy)*wallb
  hit=max(hit,abs(b.vy))
 end
 if hit>0.15 then
  play_hit(2)
 end
end

function check_ball_collision(a,b)
 local dx=b.x-a.x
 local dy=b.y-a.y
 local rr=a.r+b.r
 local d2=dx*dx+dy*dy
 if d2>=rr*rr then return end
 local d=sqrt(d2)
 local nx,ny
 if d<0.01 then
  nx,ny,d=1,0,0.01
 else
  nx=dx/d
  ny=dy/d
 end
 -- positional correction first
 local ov=(rr-d)/2
 a.x-=nx*ov a.y-=ny*ov
 b.x+=nx*ov b.y+=ny*ov
 -- equal masses, normal impulse
 local vn=(b.vx-a.vx)*nx+(b.vy-a.vy)*ny
 if vn>=0 then return end
 local imp=-(1+ballb)*vn*0.5
 a.vx-=imp*nx a.vy-=imp*ny
 b.vx+=imp*nx b.vy+=imp*ny
 local force=-vn
 if force>0.15 then
  play_hit(1)
  if force>1.1 then
   local cx=a.x+nx*a.r
   local cy=a.y+ny*a.r
   spark(cx,cy,2,7,0.6)
  end
 end
end

function play_hit(id)
 if sfxcd<=0 then
  sfx(id)
  sfxcd=sfxcool
 end
end

-->8
-- input

function arate()
 return 0.004167+hold*0.00009
end

function upd_aim()
 if vsai and player==2 then
  ai_aim()
  return
 end
 if btn(0) or btn(1) then
  hold=min(hold+1,90)
 else
  hold=0
 end
 if btn(0) then
  aim-=arate()
  usemouse=false
 end
 if btn(1) then
  aim+=arate()
  usemouse=false
 end
 if btnp(2) then set_power(plev+1) end
 if btnp(3) then set_power(plev-1) end
 local w=stat(36)
 if w!=0 then set_power(plev+w) end
 if btnp(4) then
  longaim=not longaim
  sfx(6)
 end
 if usemouse then
  local dx=pmx-cue.x
  local dy=pmy-cue.y
  if dx*dx+dy*dy>9 then
   aim=atan2(dx,dy)
  end
 end
 aim=aim%1
 if btnp(5) or mclick then shoot() end
end

function set_power(v)
 v=mid(1,v,6)
 if v!=plev then
  plev=v
  sfx(6)
 end
end

function shoot()
 state="strike"
 stimer=0
end

function upd_strike()
 stimer+=1
 if stimer>=6 then
  local p=powr[plev]
  cue.vx=cos(aim)*p
  cue.vy=sin(aim)*p
  shots+=1
  shotsc=0
  scratch=false
  settle=0
  sfx(0)
  if p>=1.87 then shake=3 end
  spark(cue.x-cos(aim)*3,
        cue.y-sin(aim)*3,3,7,0.5)
  state="moving"
 end
end

-- section 50 cpu: pick a ball,
-- aim at it, add a little error
function ai_aim()
 aitim+=1
 if aitim==1 then
  local tgt,n=nil,0
  for b in all(balls) do
   if b.active and not b.cue then
    n+=1
    if rnd(n)<1 then tgt=b end
   end
  end
  if tgt then
   aitgt=atan2(tgt.x-cue.x,tgt.y-cue.y)
    +rnd(0.05)-0.025
  else
   aitgt=rnd(1)
  end
  plev=4+flr(rnd(3))
 end
 local d=(aitgt-aim)%1
 if d>0.5 then d-=1 end
 aim=(aim+mid(-0.02,d,0.02))%1
 if aitim>40 and abs(d)<0.008 then
  shoot()
 elseif aitim>120 then
  shoot()
 end
end

-->8
-- screens

function upd_splash()
 if anypress() then
  state="menu"
  msel=1
  sfx(6)
 end
end

function upd_menu()
 if btnp(2) then
  msel=msel>1 and msel-1 or 3
  sfx(6)
 end
 if btnp(3) then
  msel=msel<3 and msel+1 or 1
  sfx(6)
 end
 if usemouse then
  local h=menu_hover()
  if h>0 then msel=h end
 end
 if btnp(5) or btnp(4) or
    (mclick and menu_hover()>0) then
  if msel==1 then
   start_game(false)
  elseif msel==2 then
   start_game(true)
  else
   state="help"
   sfx(6)
  end
 end
end

function menu_hover()
 for i=1,3 do
  local y=74+(i-1)*10
  if pmy>=y-3 and pmy<=y+5
   and pmx>=26 and pmx<=101 then
   return i
  end
 end
 return 0
end

function upd_help()
 if anypress() then
  state="menu"
  sfx(6)
 end
end

function upd_gameover()
 gotim+=1
 if gotim<20 then return end
 if btnp(5) or mclick then
  new_game()
  sfx(6)
 elseif btnp(4) then
  music(0)
  state="menu"
  sfx(6)
 end
end

-->8
-- fx

function spark(x,y,n,c,sp)
 if #parts>96 then return end
 for i=1,n do
  local a=rnd(1)
  local v=rnd(sp)+0.2
  add(parts,{x=x,y=y,
   vx=cos(a)*v,vy=sin(a)*v,
   l=8+rnd(12),c=c})
 end
end

function confetti()
 for i=1,40 do
  add(parts,{
   x=rnd(128),y=rnd(40)+20,
   vx=rnd(1)-0.5,vy=rnd(0.6)+0.2,
   l=40+rnd(40),
   c=({8,9,10,11,12,14})[1+flr(rnd(6))]})
 end
end

function upd_parts()
 for p in all(parts) do
  p.x+=p.vx
  p.y+=p.vy
  p.vx*=0.92
  p.vy*=0.92
  p.l-=1
  if p.l<=0 then del(parts,p) end
 end
end

function draw_parts()
 for p in all(parts) do
  pset(p.x,p.y,p.l<6 and 5 or p.c)
 end
end

-->8
-- draw

function _draw()
 cls(0)
 if state=="splash" then
  draw_splash()
  return
 end
 if state=="menu" then
  draw_menu()
  return
 end
 if state=="help" then
  draw_help()
  return
 end
 if shake>0 then
  camera(flr(rnd(3))-1,flr(rnd(3))-1)
 end
 draw_table()
 draw_balls()
 if state=="aim" then
  draw_aim()
  draw_cue(0)
 elseif state=="strike" then
  draw_cue(stimer<4
   and stimer*0.9 or (6-stimer)*1.8)
 end
 if flash then
  circ(flash[1],flash[2],6-flash[3],7)
 end
 draw_parts()
 camera()
 draw_hud()
 if state=="gameover" then
  draw_gameover()
 end
end

function draw_table()
 rectfill(1,14,126,107,4)
 rect(1,14,126,107,2)
 rect(2,15,125,106,15)
 rectfill(tl-3,tt-3,tr+3,tb+3,1)
 rectfill(tl-2,tt-2,tr+2,tb+2,3)
 -- rail diamonds
 for i=1,5 do
  local x=tl+i*(tr-tl)/6
  pset(x,tt-6,15)
  pset(x,tb+6,15)
 end
 for i=1,3 do
  local y=tt+i*(tb-tt)/4
  pset(tl-6,y,15)
  pset(tr+6,y,15)
 end
 -- head string and foot spot
 for y=tt,tb,3 do
  pset(cuex,y,1)
 end
 pset(rackx,racky,1)
 for p in all(pockets) do
  circfill(p[1],p[2],4,0)
  circ(p[1],p[2],4,5)
 end
end

function draw_ball(b)
 local x,y=b.x,b.y
 if b.pop>0 then
  circfill(x,y,b.pop/2,7)
  return
 end
 if not b.active then return end
 local c=b.col
 if b.cue then
  circfill(x,y,2,7)
  pset(x-1,y-1,6)
  return
 end
 if b.num>8 then
  -- stripe: white poles, colour band
  circfill(x,y,2,7)
  line(x-2,y,x+2,y,c)
  line(x-1,y-1,x+1,y-1,c)
  line(x-1,y+1,x+1,y+1,c)
 else
  circfill(x,y,2,c)
  if b.num==8 then
   pset(x,y,7)
  else
   pset(x-1,y-1,7)
  end
 end
end

function draw_balls()
 for b in all(balls) do
  draw_ball(b)
 end
end

function draw_aim()
 local dx,dy=cos(aim),sin(aim)
 local len=longaim and 46 or 26
 for i=5,len,4 do
  local x=cue.x+dx*i
  local y=cue.y+dy*i
  if x<tl or x>tr or y<tt or y>tb then
   break
  end
  pset(x,y,6)
 end
 if usemouse then
  local mx,my=pmx,pmy
  line(mx-2,my,mx+2,my,5)
  line(mx,my-2,mx,my+2,5)
 end
end

function draw_cue(off)
 local dx,dy=cos(aim),sin(aim)
 local b=5+off
 local x1=cue.x-dx*b
 local y1=cue.y-dy*b
 line(x1,y1,
  cue.x-dx*(b+18),
  cue.y-dy*(b+18),4)
 line(x1,y1,
  x1-dx*4,y1-dy*4,15)
end

function pad2(n)
 return (n<10 and "0" or "")..n
end

function draw_hud()
 rectfill(0,0,127,13,0)
 rectfill(0,108,127,127,0)
 line(0,108,127,108,5)
 -- top row
 local nm=pname(player)
 print(nm.." turn",3,2,
  player==1 and 10 or 12)
 print("pool",50,2,8)
 print("v1.0",108,2,5)
 -- power meter
 print("pwr",3,8,6)
 for i=1,6 do
  local x=19+(i-1)*5
  if i<=plev then
   rectfill(x,8,x+3,12,
    i>4 and 8 or 10)
  else
   rect(x,8,x+3,12,5)
  end
 end
 print("left "..pad2(remaining),
  96,8,6)
 -- bottom row
 print("p1 "..pad2(s1),6,112,
  player==1 and 10 or 6)
 local n2=pname(2)
 print(n2.." "..pad2(s2),
  116-#n2*4-12,112,
  player==2 and 10 or 6)
 print("shot "..pad2(shots),46,112,5)
 if msgt>0 then
  print(msg,64-#msg*2,120,
   7+(t\4)%2*3)
 end
end

function draw_gameover()
 rectfill(18,32,109,96,0)
 rect(18,32,109,96,7)
 rect(19,33,108,95,5)
 print("game over",46,38,7)
 print("p1",38,50,6)
 print(pad2(s1),56,50,10)
 local n2=pname(2)
 print(n2,38,58,6)
 print(pad2(s2),56,58,10)
 local w=winner()
 local txt="draw!"
 if w>0 then txt=pname(w).." wins!" end
 if gotim%60<42 then
  print(txt,64-#txt*2,70,
   w==2 and 12 or 10)
 end
 print("\151 rematch",26,82,6)
 print("\142 title",70,82,6)
end

-->8
-- title art

function bigtext(s,x,y,c,sc)
 print("\^w\^t"..s,x+1,y+1,sc)
 print("\^w\^t"..s,x,y,c)
end

function decoballs(y)
 for i=0,6 do
  local n=i+1
  local x=25+i*13
  local b={x=x,y=y+sin(t/180+i/7)*2,
   r=brad,num=n,col=bcol[n],
   active=true,cue=false,pop=0}
  draw_ball(b)
 end
end

-- a table stood up as a poster
function poster(y0,y1)
 rectfill(0,y0-6,127,y1+6,4)
 rect(0,y0-6,127,y1+6,2)
 rect(1,y0-5,126,y1+5,15)
 rectfill(6,y0-1,121,y1,1)
 rectfill(6,y0,121,y1,3)
 for i=0,2 do
  circfill(6+i*57.5,y0,4,0)
  circfill(6+i*57.5,y1,4,0)
 end
end

function draw_splash()
 poster(20,98)
 for i=1,26 do
  local x=8+(i*37+t\3)%112
  local y=24+(i*13)%72
  pset(x,y,11)
 end
 bigtext("pool",48,30,10,4)
 bigtext("1954",48,46,8,2)
 print("brown & lewis",40,64,7)
 decoballs(82)
 line(9,96,19,86,4)
 line(19,86,22,83,15)
 if t%60<40 then
  local s="press any button"
  print(s,64-#s*2,110,7)
 end
end

function draw_menu()
 bigtext("pool",48,10,10,4)
 print("1 9 5 4",48,28,8)
 rect(20,40,107,102,5)
 rect(21,41,106,101,1)
 local it={"2 players","vs cpu",
  "how to play"}
 for i=1,3 do
  local y=74+(i-1)*10
  local c=6
  if i==msel then
   c=10
   circfill(31,y+2,2,7)
   pset(30,y+1,6)
  end
  print(it[i],38,y,c)
 end
 print("15 balls, 6 pockets",26,46,7)
 print("pot one, shoot again",26,54,6)
 print("best "..pad2(best),50,110,5)
 decoballs(67)
end

function draw_help()
 print("how to play",40,8,10)
 line(38,15,89,15,5)
 local l={
  "\139\145 aim the cue",
  "\148\131 power, 6 levels",
  "\151 shoot the cue ball",
  "\142 long / short guide",
  "mouse: point and click",
  "",
  "pot a ball  +1 point",
  "and shoot again.",
  "miss  turn passes over.",
  "pot the cue ball  foul,",
  "it is spotted back and",
  "the turn passes over.",
  "",
  "all 15 potted ends the",
  "game. most points wins."}
 for i=1,#l do
  print(l[i],10,22+(i-1)*6,
   i<6 and 7 or 6)
 end
 if t%60<40 then
  print("press any button",32,118,10)
 end
end