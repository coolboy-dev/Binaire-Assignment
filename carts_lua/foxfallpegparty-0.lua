-- fox fall: peg party!
pgrav=0.12 flen=14 pmaxstep=2
tl=0  -- test level: 0=normal start, n=jump straight to level n
gst="title" title_t=0 hi_apples=0 hi_score=0 hi_elvl=0 g=nil shop_sel=1 msg="" msg_t=0
ach_bits=0 ach_msg="" ach_t=0 ach_sel=1 title_sel=1
-- achievements: {key,name,desc}. index-1 = bit number.
achs={
 {"first steps","clear level 1"},
 {"halfway","reach level 10"},
 {"champion","clear all 20 levels"},
 {"combo master","hit a x3 combo"},
 {"apple hoarder","bank 100 apples"},
 {"juggler","3+ balls at once"},
 {"demolitionist","use a bomb"},
 {"hot streak","get fire chicken"},
 {"jackpot!","land a 1000 slot"},
 {"high roller","reach 7777 pts"},
 {"bonus hunter","hit a purple peg"},
 {"never give up","use continue"},
}

lvlseeds={1,2,4,5,6,7,8,9,10,11,13,14,15,16,18,19,20,21,22,23}

powers={"flippers","bigbasket","fire","slow","multiball"}
function roll_power() return powers[1+flr(rnd(5))] end

function _init()
 cartdata("foxfall_pegrl2_v1")
 hi_apples=dget(0)
 ach_bits=dget(1)
 hi_score=dget(2)
 hi_elvl=dget(3)
 gst="title"
end

function new_run(endless)
 srand(t()*1000+flr(rnd(9999)))
 g={
  lvl=(tl>0) and tl or 1, maxlvl=20,
  endless=endless, seed=flr(rnd(32000))+1,
  balls_left=10, apples=0, fires=1, score=0,
  shop_bumps={ball=0,fire=0,bspd=0,bsize=0},
  aim_v=0, base_x=64,
  balls={}, aiming=true, fire_armed=false,
  pegs={}, basket=nil, particles={}, combo=0, afall={}, settle=0,
  bigbasket=false, flippers=nil, slowmo=0, cleared=false, fireworks={},
  score_reward=0,      -- last 7777 milestone that granted a ball
  clear_timer=0,       -- grace countdown after last orange cleared
  bsk_w=7, bsk_spd=0.8,
 }
 build_level(g.lvl)
 gst="play"
end

function gen_picture(seed)
 srand(seed)
 local a=1+flr(rnd(9))
 -- build a 10-row x 12-col fill grid ("x"=apple, "."=empty)
 local g={}
 for y=1,10 do g[y]={} for x=1,12 do g[y][x]="." end end
 if a==1 then -- diamond
  local rad=3+seed%2
  for y=1,10 do for x=1,12 do if abs(y-5)+abs(x-6.5)<=rad+0.5 then g[y][x]="x" end end end
 elseif a==2 then -- oval
  local ry=3+seed%2 local rx=4+seed%2
  for y=1,10 do for x=1,12 do local dy=(y-5)/ry local dx=(x-6.5)/rx if dy*dy+dx*dx<=1.05 then g[y][x]="x" end end end
 elseif a==3 then -- heart
  local h={"............","..xx....xx..",".xxxxxxxxxx.",".xxxxxxxxxx.","..xxxxxxxx..","...xxxxxx...","....xxxx....",".....xx.....","............","............"}
  for y=1,10 do for x=1,12 do if sub(h[y],x,x)=="x" then g[y][x]="x" end end end
 elseif a==4 then -- plus
  local t=1+seed%2
  for y=3,8 do for x=1,12 do if abs(x-6.5)<=t+0.5 or (abs(y-5)<=t+0.5 and x>=3 and x<=10) then g[y][x]="x" end end end
 elseif a==5 then -- triangle
  for y=2,8 do local w=(y-1)*1.2 for x=1,12 do if abs(x-6.5)<=w then g[y][x]="x" end end end
 elseif a==6 then -- hourglass
  for y=2,9 do local w=abs(y-5.5)+1 for x=1,12 do if abs(x-6.5)<=w then g[y][x]="x" end end end
 elseif a==7 then -- fish
  for y=1,10 do for x=1,12 do local dy=(y-5)/3.5 local dx=(x-5.5)/4 if dy*dy+dx*dx<=1.05 then g[y][x]="x" end end end
  for y=3,7 do for x=9,11 do if abs(y-5)<=(x-8)*1.3 then g[y][x]="x" end end end
 elseif a==8 then -- arrow
  for y=2,6 do local w=y-1 for x=1,12 do if abs(x-6.5)<=w then g[y][x]="x" end end end
  for y=6,9 do for x=1,12 do if abs(x-6.5)<=2 then g[y][x]="x" end end end
 else -- mushroom
  for y=2,5 do for x=1,12 do local dx=(x-6.5)/5 if dx*dx<=1 then g[y][x]="x" end end end
  for y=6,8 do for x=5,8 do g[y][x]="x" end end
 end
 -- outline pass: border apples -> blue ("o")
 local mark={}
 for y=1,10 do for x=1,12 do
  if g[y][x]=="x" then
   local edge=false
   if y==1 or g[y-1][x]=="." then edge=true end
   if y==10 or g[y+1][x]=="." then edge=true end
   if x==1 or g[y][x-1]=="." then edge=true end
   if x==12 or g[y][x+1]=="." then edge=true end
   if edge then mark[y*100+x]=true end
  end
 end end
 for y=1,10 do for x=1,12 do if mark[y*100+x] then g[y][x]="o" end end end
 -- to string rows
 local grid={}
 for y=1,10 do local r="" for x=1,12 do r=r..g[y][x] end grid[y]=r end
 return grid
end

-- fox fall scene background (real sprites, animated)
function gen_ffbg(seed)
 srand(seed)
 local s={cl={},tr={},bu={},gp={},mo={}}
 s.sx=4+flr(rnd(88)) s.sy=8+flr(rnd(6))
 for i=1,flr(rnd(3)) do add(s.gp,{x=1+flr(rnd(12)),w=2}) end
 for i=1,2 do add(s.cl,{x=flr(rnd(128)),y=8+flr(rnd(22)),s=54+flr(rnd(2))}) end
 for tx=0,15 do
  if ffsol(s,tx) then
   local r=rnd(1)
   if r<0.14 then add(s.tr,{x=tx*8})
   elseif r<0.32 then add(s.bu,{x=tx*8,s=43+flr(rnd(3))}) end
  end
 end
 -- monsters: patrol only within a run of solid tiles (never cross a gap)
 for i=1,1+flr(rnd(2)) do
  local lo=1+flr(rnd(10))
  if ffsol(s,lo) and ffsol(s,lo+1) and ffsol(s,lo+2) then
   add(s.mo,{x=lo*8,x0=lo*8,x1=(lo+2)*8,s=5+flr(rnd(11)),d=1})
  end
 end
 s.fox=-8 s.foxt=300+flr(rnd(600)) s.fj=0
 return s
end

function ffsol(s,tx)
 for gp in all(s.gp) do if tx>=gp.x and tx<gp.x+gp.w then return false end end
 return true
end

function draw_ffbg()
 local s=g and g.ffbg
 if not s then cls(12) return end
 cls(12)
 -- sun
 spr(21,s.sx,s.sy)
 -- clouds (drift slowly)
 for cl in all(s.cl) do spr(cl.s,(cl.x+flr(title_t/8))%136-4,cl.y) end
 -- ground: grass row at y=112, dirt at 120, with gaps
 for tx=0,15 do
  if ffsol(s,tx) then spr(2,tx*8,112) spr(18,tx*8,120) end
 end
 -- trees & bushes
 for tr in all(s.tr) do spr(51,tr.x,104) end
 for bu in all(s.bu) do spr(bu.s,bu.x,104) end
 -- walking monsters (patrol stays on solid ground)
 for m in all(s.mo) do
  m.x=m.x+m.d*0.3
  if m.x>m.x1 then m.d=-1 elseif m.x<m.x0 then m.d=1 end
  spr(m.s,m.x,104,1,1,m.d==-1)
 end
 -- fox strolls across every 10-30s, hopping over gaps & enemies
 s.foxt=s.foxt-1
 if s.foxt<=0 then
  -- start a hop when grounded and a gap/foe is just ahead
  if s.fj<=0 then
   local jmp=not ffsol(s,flr((s.fox+10)/8))
   for m in all(s.mo) do if abs(m.x-s.fox)<12 then jmp=true end end
   if jmp then s.fj=20 end
  end
  if s.fj>0 then s.fj=s.fj-1 end
  spr(1,s.fox,104+sin(s.fj/40)*14)
  s.fox=s.fox+1
  if s.fox>132 then s.fox=-8 s.fj=0 s.foxt=300+flr(rnd(600)) end
 end
end

function build_level(n)
 g.pegs={}
 local grid
 if g.endless then
  grid=gen_picture(g.seed*131+n*977)
 else
  grid=gen_picture(lvlseeds[((n-1)%#lvlseeds)+1])
 end
 for row=1,#grid do
  local ln=grid[row]
  for col=1,#ln do
   local ch=sub(ln,col,col)
   if ch~="." then
    local x=14+(col-1)*9
    local y=30+(row-1)*9
    local kind=(ch=="x") and "orange" or "blue"
    add(g.pegs,{x=x,y=y,r=3,hit=false,kind=kind})
   end
  end
 end
 srand(t()*1000+n)
 for p in all(g.pegs) do
  if p.kind=="orange" then
   local r=rnd(1)
   if r<0.10 then p.kind="green"
   elseif r<0.12 then p.kind="bomb"
   elseif r<0.14 then p.kind="purple" end
  end
 end
 g.ffbg=gen_ffbg((g.seed or 1)*29+n*53)
 g.basket={x=64,dir=1}
 g.afall={} g.flippers=nil g.fireworks={} g.slowmo=0 g.cleared=false
 g.balls={} g.aiming=true g.bigbasket=false g.dbl=false
 g.paddle_hidden=false g.bonus_pending=false g.bonus_ball=nil g.bonus_got=nil
 g.aim_v=0 g.base_x=64 g.combo=0 g.fire_armed=false
end

function peg_collide(b,p,fire)
 local dx=b.x-p.x local dy=b.y-p.y
 local d=sqrt(dx*dx+dy*dy)
 if d<b.r+p.r and d>0 then
  local solid=(not fire) or p.kind=="orange" or p.kind=="green"
  if solid then
   local nx=dx/d local ny=dy/d
   b.x=p.x+nx*(b.r+p.r) b.y=p.y+ny*(b.r+p.r)
   local dot=b.dx*nx+b.dy*ny
   b.dx=(b.dx-2*dot*nx)*0.9
   b.dy=(b.dy-2*dot*ny)*0.9
   b.dx=b.dx+(rnd(1)-0.5)*0.8
  end
  if not p.hit then p.hit=true sfx(1) return true end
 end
 return false
end

function flipper_bounce(b,f)
 local tx=f.x+cos(f.a)*flen
 local ty=f.y+sin(f.a)*flen
 for s=0,1,0.25 do
  local px=f.x+(tx-f.x)*s
  local py=f.y+(ty-f.y)*s
  local dx=b.x-px local dy=b.y-py
  local d=sqrt(dx*dx+dy*dy)
  if d<b.r+3 then
   local ang=atan2(dx,dy)
   local swung=abs(f.a-f.active)<0.05
   local force=swung and 5 or 2
   b.dx=cos(ang)*force
   b.dy=sin(ang)*force-2
   b.x=px+cos(ang)*(b.r+3)
   b.y=py+sin(ang)*(b.r+3)
   return
  end
 end
end

function upd_flippers()
 if not g.flippers then return end
 local pressed=btn(4)
 for f in all(g.flippers) do
  local tgt=pressed and f.active or f.rest
  f.a=f.a+(tgt-f.a)*0.5
 end
end

function pwall(b)
 if b.x-b.r<2 then b.x=2+b.r b.dx=-b.dx*0.9 end
 if b.x+b.r>126 then b.x=126-b.r b.dx=-b.dx*0.9 end
 if b.y-b.r<10 then b.y=10+b.r b.dy=-b.dy*0.9 end
end

function ball_speed(b)
 local s=b.age/30
 if s<10 then return 1.0
 elseif s<22 then return 1.1+(s-15)/12*0.9
 elseif s<33 then return 2.0+(s-25)/11*1.0
 else return 3.0 end
end

function step_pball(b)
 b.age=(b.age or 0)+1
 if b.straight and b.straight>0 then b.straight=b.straight-1
 else b.dy=b.dy+pgrav end
 local slowf=b.slowp and 0.5 or 1
 local ramp=ball_speed(b)
 local vx=b.dx*slowf*ramp local vy=b.dy*slowf*ramp
 local sp=sqrt(vx*vx+vy*vy)
 local steps=max(1,ceil(sp/pmaxstep))
 local sdx=vx/steps local sdy=vy/steps
 for st=1,steps do
  b.x=b.x+sdx b.y=b.y+sdy
  pwall(b)
  paddle_bounce(b)
  if g.flippers then for f in all(g.flippers) do flipper_bounce(b,f) end end
  for p in all(g.pegs) do
   if peg_collide(b,p,b.fire) then on_peg_hit(p) end
  end
 end
 if b.fire then
  b.trail=b.trail or {}
  add(b.trail,{x=b.x,y=b.y})
  while #b.trail>6 do del(b.trail,b.trail[1]) end
 end
end

function paddle_bounce(b)
 if g.paddle_hidden then return end
 local pw=cur_bw()
 if b.dy>0 and b.y+b.r>=122 and b.y<128 and abs(b.x-g.basket.x)<pw/2 then
  b.y=122-b.r
  b.dy=-abs(b.dy)-0.75
  local off=(b.x-g.basket.x)/(pw/2)
  b.dx=mid(-4,b.dx+off*1.5,4)
  sfx(4)
  spawn_p(b.x,122,3,7)
 end
end

function cur_bw()
 return g.bigbasket and g.bsk_w*2 or g.bsk_w
end

function on_peg_hit(p)
 g.combo=g.combo+1
 if g.combo>=20 then unlock(4) end
 local base=(p.kind=="blue") and 2 or 8
 local mult=min(3,1+0.1*g.combo)
 local award=base*mult
 if g.dbl then award=award*2 end
 g.score=min(32767,g.score+flr(award))
 if p.kind=="orange" then spawn_apple(p.x,p.y) end
 spawn_p(p.x,p.y,5,p.kind=="orange" and 9 or 12)
 if p.kind=="green" then
  if rnd(1)<0.5 then g.balls_left=g.balls_left+1 sfx(5) popmsg("+1 ball!") spawn_p(p.x,p.y,10,11)
  else activate_power(roll_power(),p.x,p.y) end
 end
 if p.kind=="bomb" then explode_bomb(p.x,p.y) end
 if p.kind=="purple" then g.dbl=true popmsg("2x score!") spawn_p(p.x,p.y,10,14) unlock(11) end
 p.ttl=60
 if p.kind=="orange" and oranges_left()==0 and not g.cleared then
  g.cleared=true
  sfx(6)
  g.slowmo=100
  g.balls_left=g.balls_left+1
  g.bonus_pending=true
  g.clear_timer=150   -- ~5s grace to catch the last apple, then auto-transition
  setup_bonus()
  start_fireworks()
 end
end

-- bomb power: detonate at a given point, clearing pegs within radius.
-- used by the x-triggered bomb (ball position) and any peg-based trigger.
function explode_bomb(bx,by)
 sfx(3)
 spawn_p(bx,by,14,8)
 for other in all(g.pegs) do
  if not other.hit then
   local dx=other.x-bx
   local dy=other.y-by
   local d=sqrt(dx*dx+dy*dy)
   if d<28 then
    other.hit=true
    on_peg_hit(other)
   end
  end
 end
end

function activate_power(pw,x,y)
 if pw=="flippers" then
  g.flippers={
   {x=28,y=104,rest=-0.10,active=0.044,a=-0.10,side="l"},
   {x=100,y=104,rest=0.60,active=0.456,a=0.60,side="r"}
  }
  popmsg("flippers!")
 elseif pw=="bigbasket" then
  g.bigbasket=true popmsg("2x basket!")
 elseif pw=="fire" then
  for b in all(g.balls) do b.fire=true end popmsg("fire chicken!") unlock(8)
 elseif pw=="slow" then
  for b in all(g.balls) do b.slowp=true end popmsg("slow ball!")
 elseif pw=="multiball" then
  local src=g.balls[1] or {x=x,y=y}
  add(g.balls,{x=src.x,y=16,dx=-1.5,dy=2,r=2,straight=0,fire=false,age=0,slowp=false})
  add(g.balls,{x=src.x,y=16,dx=1.5,dy=2,r=2,straight=0,fire=false,age=0,slowp=false})
  popmsg("multiball!")
  if #g.balls>=3 then unlock(6) end
 end
 spawn_p(x,y,10,11)
end

function oranges_left()
 local c=0 for p in all(g.pegs) do if p.kind=="orange" and not p.hit then c=c+1 end end return c
end

function _update()
 title_t=title_t+1
 if msg_t>0 then msg_t=msg_t-1 end
 if gst=="title" then
  if btnp(2) then title_sel=max(1,title_sel-1) end
  if btnp(3) then title_sel=min(3,title_sel+1) end
  if btnp(4) then
   if title_sel==1 then new_run(false)
   elseif title_sel==2 then new_run(true)
   else gst="achs" end
  end
 elseif gst=="play" then upd_play()
 elseif gst=="bonus" then upd_bonus()
 elseif gst=="shop" then upd_shop()
 elseif gst=="achs" then
  if btnp(2) then ach_sel=max(1,ach_sel-1) end
  if btnp(3) then ach_sel=min(#achs,ach_sel+1) end
  if btnp(4) or btnp(5) then gst="title" end
 elseif gst=="gameover" then
  if btnp(4) then continue_run()     -- z: continue (lose score, keep level+apples)
  elseif btnp(5) then gst="title" end -- x: back to title
 elseif gst=="win" then
  if btnp(4) or btnp(5) then gst="title" end
 end
 upd_particles()
 upd_fireworks()
 check_score_reward()
 if ach_t>0 then ach_t=ach_t-1 end
end

function upd_play()
 upd_basket()
 upd_apples()
 for i=#g.pegs,1,-1 do
  local p=g.pegs[i]
  if p.ttl then p.ttl=p.ttl-1 if p.ttl<=0 then del(g.pegs,p) end end
 end
 -- level cleared: don't force the player to drain/juggle the ball. once the
 -- last apple has settled (caught or fallen off), give a brief beat then go
 -- to the bonus. runs whether aiming or mid-flight. clear_timer is the hard cap.
 if g.cleared then
  if g.clear_timer>0 then g.clear_timer=g.clear_timer-1 end
  if #g.afall==0 and g.clear_timer<120 then after_balls() return end
 end
 if g.aiming then
  if btn(2) then g.aim_v=max(-0.30,g.aim_v-0.008) end
  if btn(3) then g.aim_v=min(0.30,g.aim_v+0.008) end
  if btn(0) then g.base_x=max(16,g.base_x-1.5) end
  if btn(1) then g.base_x=min(112,g.base_x+1.5) end
  if btnp(4) then
   local a=0.25+g.aim_v
   add(g.balls,{x=g.base_x,y=16,dx=cos(a)*2.6,dy=abs(sin(a))*2.6+0.8,
                r=2,straight=10,fire=false,age=0,slowp=false})
   sfx(0)
   g.combo=0 g.balls_left=g.balls_left-1
   g.aiming=false
   g.bigbasket=false g.flippers=nil g.dbl=false
  end
  return
 end
 -- x: detonate a bomb at the (first live) ball's position, costs a charge
 if btnp(5) and g.fires>0 and #g.balls>0 then
  local b=g.balls[1]
  g.fires=g.fires-1
  explode_bomb(b.x,b.y)
  popmsg("bomb!") unlock(7)
 end
 upd_flippers()
 if g.slowmo>0 then g.slowmo=g.slowmo-1 end
 local do_step=g.slowmo<=0 or (g.slowmo%2==0)
 if do_step then
  for i=#g.balls,1,-1 do
   local b=g.balls[i]
   step_pball(b)
   if b.y-b.r>128 then del(g.balls,b) end
  end
 end
 if #g.balls==0 then
  if g.settle>0 or #g.afall>0 then
   if #g.afall>0 then g.settle=45 else g.settle=g.settle-1 end
   if g.settle<=0 and #g.afall==0 then after_balls() end
   return
  end
  after_balls()
 end
end

function upd_bonus()
 upd_fireworks()
 if msg_t>0 then msg_t=msg_t-1 end
 if g.bonus_banner and g.bonus_banner>0 then g.bonus_banner=g.bonus_banner-1 end
 -- result shown: wait, then advance to shop
 if g.bonus_result>0 then
  g.bonus_result=g.bonus_result-1
  if g.bonus_result<=0 or btnp(4) or btnp(5) then
   g.paddle_hidden=false g.slowmo=0 g.cleared=false
   if g.lvl==1 then unlock(1) end
   g.lvl=g.lvl+1
   if g.lvl==10 then unlock(2) end
   if g.lvl>g.maxlvl and not g.endless then unlock(3) save_hi() sfx(9) gst="win"
   else shop_sel=1 gst="shop" end
  end
  return
 end
 -- aim phase: player slides the drop point, presses z/x to drop
 if g.bonus_aim then
  if btn(0) then g.bonus_dropx=max(40,g.bonus_dropx-1.5) end
  if btn(1) then g.bonus_dropx=min(88,g.bonus_dropx+1.5) end
  if btnp(4) or btnp(5) then
   g.bonus_ball={x=g.bonus_dropx,y=18,dx=0,dy=0.5,r=2}
   g.bonus_aim=false
  end
  return
 end
 -- plinko fall
 local b=g.bonus_ball
 b.dy=b.dy+0.10
 if b.dy>1.8 then b.dy=1.8 end
 b.dx=b.dx*0.85               -- strong damping = true random walk
 local sp=sqrt(b.dx*b.dx+b.dy*b.dy)
 local steps=max(1,ceil(sp/2))
 for st=1,steps do
  b.x=b.x+b.dx/steps b.y=b.y+b.dy/steps
  if b.x-b.r<3 then b.x=3+b.r b.dx=abs(b.dx)*0.5 end
  if b.x+b.r>125 then b.x=125-b.r b.dx=-abs(b.dx)*0.5 end
  for p in all(g.plinko) do
   local dx=b.x-p.x local dy=b.y-p.y
   local d=sqrt(dx*dx+dy*dy)
   if d<b.r+2 and d>0 then
    local nx=dx/d local ny=dy/d
    b.x=p.x+nx*(b.r+2) b.y=p.y+ny*(b.r+2)
    local side=(rnd(1)<0.5) and 1 or -1  -- true galton coinflip
    b.dx=side*(0.7+rnd(0.4))
     b.dy=abs(b.dy)*0.3+0.15
     sfx(14)
     spawn_p(p.x,p.y,2,7)
   end
  end
  for pi=1,#pilx do
   local px=pilx[pi]
   if b.y>=piltop-3 and b.y<piltop+2 and abs(b.x-px)<b.r+2 then
    b.x=px+((b.x<px) and -(b.r+3) or (b.r+3))
   end
   if b.y>=piltop and b.y<pilbot and abs(b.x-px)<b.r+2 then
    if b.x<px then b.x=px-(b.r+2) else b.x=px+(b.r+2) end
    b.dx=-b.dx*0.4
   end
  end
 end
  if b.y>pilbot then
  sfx(6)
  local bi=bucket_index(b.x)
  if not bi then bi=1 end
  local prize=g.bonus_prizes[bi]
  if prize=="jack" then
   g.score=min(32767,g.score+1000) g.balls_left=g.balls_left+1
   sfx(7) popmsg("jackpot! 1000 + 1up!") unlock(9)
  elseif prize=="life" then
   g.balls_left=g.balls_left+1 popmsg("bonus: extra ball!")
  elseif prize=="appl" then
   g.apples=g.apples+10 popmsg("bonus: +10 apples!")
  else
   local pts=(prize=="50") and 50 or 250
   g.score=min(32767,g.score+pts) popmsg("bonus: "..pts.." pts!")
  end
  g.bonus_got=bi
  g.bonus_result=90
  for j=1,20 do spawn_p(b.x,pilbot,1,10) end
 end
end

function after_balls()
 g.bigbasket=false g.flippers=nil
 if oranges_left()==0 then
  g.bonus_pending=false
  g.paddle_hidden=true
  g.balls={} g.afall={}
  gst="bonus"
  start_bonus_ball()
  return
 end
 if g.balls_left<=0 then save_hi() sfx(8) gst="gameover"
 else g.aiming=true end
end

function upd_basket()
 local bk=g.basket
 if not bk then return end
 local playing=(#g.balls>0) or g.settle>0 or #g.afall>0
 if playing then
  if btn(0) then bk.x=max(8,bk.x-g.bsk_spd) end
  if btn(1) then bk.x=min(120,bk.x+g.bsk_spd) end
 else
  bk.x=bk.x+bk.dir*1.0
  if bk.x<12 then bk.x=12 bk.dir=1 end
  if bk.x>116 then bk.x=116 bk.dir=-1 end
 end
end

function shop_items()
 local b=g.shop_bumps
 return {
  {nm="+1 ball",  cost=1+b.ball,  k="ball"},
  {nm="+1 bomb",  cost=3+b.fire,  k="fire"},
  {nm="basket speed",cost=5+b.bspd,  k="bspd", mx=g.bsk_spd>=3.6},
  {nm="basket size", cost=5+b.bsize, k="bsize",mx=g.bsk_w>=27},
 }
end

-- speed upgrade ladder: .8 1.1 1.4 1.7 2.0 2.3 2.6 2.9 3.1 3.3 3.6
function upd_shop()
 local items=shop_items()
 if btnp(2) then shop_sel=max(1,shop_sel-1) end
 if btnp(3) then shop_sel=min(#items+1,shop_sel+1) end
 if btnp(4) or btnp(5) then
  if shop_sel>#items then build_level(g.lvl) gst="play"
  else
   local it=items[shop_sel]
   if it.mx then popmsg("maxed out!")
   elseif g.apples>=it.cost then
    g.apples=g.apples-it.cost
    if it.k=="ball" then g.balls_left=g.balls_left+1 end
    if it.k=="fire" then g.fires=g.fires+1 end
    if it.k=="bspd" then g.bsk_spd=min(3.6,g.bsk_spd+0.3) end
    if it.k=="bsize" then g.bsk_w=min(27,g.bsk_w+2) end
    g.shop_bumps[it.k]=g.shop_bumps[it.k]+1
    popmsg("bought "..it.nm)
   else popmsg("need more apples") end
  end
 end
end

function spawn_apple(x,y)
 add(g.afall,{x=x,y=y,vy=0,shake=12,got=false})
end

function upd_apples()
 local bx=g.basket and g.basket.x or -99
 for a in all(g.afall) do
  if a.shake>0 then a.shake=a.shake-1
  else
   a.vy=a.vy+0.04
   if a.vy>2.2 then a.vy=2.2 end
   a.y=a.y+a.vy
  end
  local caught=(a.y>120 and abs(a.x-bx)<cur_bw()/2)
  if caught then
   g.apples=g.apples+1
   if g.apples>=100 then unlock(5) end
   spawn_p(a.x,a.y,6,9)
   sfx(2)
   popmsg("apple! +1")
   del(g.afall,a)
  elseif a.y>134 then
   del(g.afall,a)
  end
 end
end

pilx={4,17,31,44,57,71,84,97,111,124} piltop=104 pilbot=120
function start_bonus_ball()
 g.bonus_ball=nil
 g.bonus_aim=true      -- player positions the drop point first
 g.bonus_dropx=64
 g.bonus_result=0
 g.bonus_banner=90     -- banner shows ~3s then closes
end

function setup_bonus()
 -- fixed plinko payout: rare edges = jackpots, common center = small
 g.bonus_prizes={"jack","life","appl","250","50","250","appl","life","jack"}
 g.bonus_got=nil
 -- plinko peg grid: 7 staggered rows
 g.plinko={}
 for r=0,8 do
  local y=24+r*9
  local off=(r%2==0) and 0 or 7
  local x=8+off
  while x<=120 do add(g.plinko,{x=x,y=y}) x=x+13 end
 end
end

function bucket_index(bx)
 if bx<=pilx[1] then return 1 end
 if bx>=pilx[#pilx] then return #pilx-1 end
 for i=1,#pilx-1 do
  if bx>=pilx[i] and bx<pilx[i+1] then return i end
 end
 return 3
end

function pillar_hit(b,px)
 local dx=b.x-px local dy=b.y-piltop
 if b.y<piltop and sqrt(dx*dx+dy*dy)<b.r+2 then
  local d=max(0.01,sqrt(dx*dx+dy*dy)) local nx=dx/d local ny=dy/d
  b.x=px+nx*(b.r+2) b.y=piltop+ny*(b.r+2)
  local dot=b.dx*nx+b.dy*ny
  b.dx=(b.dx-2*dot*nx)*0.9 b.dy=(b.dy-2*dot*ny)*0.9
  return true
 end
 if b.y>=piltop and b.y<pilbot and abs(b.x-px)<b.r+2 then
  if b.x<px then b.x=px-(b.r+2) else b.x=px+(b.r+2) end
  b.dx=-b.dx*0.9
  return true
 end
 return false
end

function start_fireworks()
 for burst=1,3 do
  local cx=20+rnd(88) local cy=20+rnd(50)
  local col=8+flr(rnd(8))
  for i=1,14 do
   local a=i/14
   add(g.fireworks,{x=cx,y=cy,dx=cos(a)*(1+rnd(1.5)),dy=sin(a)*(1+rnd(1.5)),life=24+flr(rnd(12)),col=col})
  end
 end
end
function upd_fireworks()
 if not g then return end
 for p in all(g.fireworks) do
  p.x=p.x+p.dx p.y=p.y+p.dy p.dy=p.dy+0.06 p.life=p.life-1
  if p.life<=0 then del(g.fireworks,p) end
 end
end

function popmsg(s) msg=s msg_t=60 end
function spawn_p(x,y,n,col)
 for i=1,n do add(g.particles,{x=x,y=y,dx=rnd(3)-1.5,dy=rnd(3)-1.5,life=10+flr(rnd(8)),col=col}) end
end
function upd_particles()
 if not g then return end
 for p in all(g.particles) do
  p.x=p.x+p.dx p.y=p.y+p.dy p.dy=p.dy+0.1 p.life=p.life-1
  if p.life<=0 then del(g.particles,p) end
 end
end
function check_score_reward()
 if not g then return end
 if g.score>=7777 then unlock(10) end
 local milestone=flr(g.score/7777)
 if milestone>g.score_reward then
  g.score_reward=milestone
  g.balls_left=g.balls_left+1
  popmsg("7777! +1 ball!")
  start_fireworks()
 end
end

function has_ach(i) return band(ach_bits,shl(1,i-1))~=0 end
function unlock(i)
 if not has_ach(i) then
  ach_bits=bor(ach_bits,shl(1,i-1))
  dset(1,ach_bits)
  ach_msg=achs[i][1]
  ach_t=120
  if g then start_fireworks() end
 end
end

function continue_run()
 unlock(12)
 g.score=0
 g.score_reward=0
 g.balls_left=10
 g.combo=0
 g.cleared=false
 build_level(g.lvl)
 gst="play"
end

function save_hi()
 if g.apples>hi_apples then hi_apples=g.apples dset(0,hi_apples) end
 if g.endless then
  local done=g.lvl-1 if done>hi_elvl then hi_elvl=done dset(3,hi_elvl) end
 elseif g.score>hi_score then hi_score=g.score dset(2,hi_score) end
end

function _draw()
 if gst=="title" then drw_title()
 elseif gst=="play" then drw_play()
 elseif gst=="shop" then drw_shop()
 elseif gst=="bonus" then drw_bonus()
 elseif gst=="achs" then drw_achs()
 elseif gst=="gameover" then drw_over()
 elseif gst=="win" then drw_win()
 end
 -- achievement unlock banner (over everything)
 if ach_t>0 then
  local w=#ach_msg*4+24
  local x=64-w/2
  rectfill(x,44,x+w,58,0) rect(x,44,x+w,58,10)
  spr(34,x+2,46)
  print("achievement!",x+12,46,10)
  print(ach_msg,x+12,52,7)
 end
end

function draw_paddle(bx,pw)
 local hw=pw/2
 rectfill(bx-hw,122,bx+hw,125,10)
 rectfill(bx-hw,123,bx+hw,124,7)
 for i=-1,1 do pset(bx+i*hw*0.6,125,5) end
end

function drw_play()
 draw_ffbg()
 local a=0.25+g.aim_v
 -- turret: sprite base + barrel that tracks aim (same vector as the ball)
 spr(132,g.base_x-4,8)
 local vx=cos(a)*2.6 local vy=abs(sin(a))*2.6+0.8
 local ml=sqrt(vx*vx+vy*vy)
 local nx=vx/ml local ny=vy/ml
 local ex=g.base_x+nx*9 local ey=13+ny*9
 line(g.base_x,13,ex,ey,6) pset(ex,ey,10)
 if g.aiming then
  local px2,py2=ex,ey
  for i=1,10 do
   px2=px2+vx py2=py2+vy vy=vy+pgrav
   if px2<3 or px2>125 then break end
   if i%2==0 then pset(px2,py2,7) end
  end
 end
 for p in all(g.pegs) do
  local sp=({orange=34,bomb=35,green=36,purple=148})[p.kind]
  if sp and not p.hit then
   spr(sp,p.x-4,p.y-4)
  else
   local pr=p.ttl and max(1,p.r*p.ttl/60) or p.r
   local c1,c2=5,7
   if p.kind=="orange" then pr=2 c1,c2=9,4
   elseif p.kind=="bomb" then pr=2 c1,c2=8,9
   elseif p.kind=="green" then c1,c2=3,11
   elseif p.kind=="purple" then c1,c2=2,13
   else
    c1=(p.ttl and p.ttl<20 and p.ttl%4<2) and 6 or (p.hit and 5 or 12)
    c2=p.hit and 5 or 7
   end
   circfill(p.x,p.y,pr,c1) circ(p.x,p.y,pr,c2)
  end
 end
 for a in all(g.afall) do
  local wx=a.shake>0 and (rnd(2)-1) or 0
  spr(34,a.x-4+wx,a.y-4)
 end
 if g.flippers then
  for f in all(g.flippers) do
   local tx=f.x+cos(f.a)*flen
   local ty=f.y+sin(f.a)*flen
   local swung=abs(f.a-f.active)<0.08
   local col=swung and 10 or 9
   line(f.x,f.y,tx,ty,col)
   line(f.x,f.y+1,tx,ty+1,col)
   circfill(f.x,f.y,2,col)
   circfill(tx,ty,1,col)
  end
 end
 if g.basket and not g.paddle_hidden then draw_paddle(g.basket.x,cur_bw()) end
 for b in all(g.balls) do
  if b.fire then
   -- fire effect drawn behind the sprite
   if b.trail then
    for i=1,#b.trail do
     local tp=b.trail[i]
     circfill(tp.x,tp.y,i*0.3,8+i%3)
    end
   end
   for i=1,3 do pset(b.x+rnd(6)-3,b.y+rnd(6)-3,8+flr(rnd(3))) end
   spr(52,b.x-4,b.y-4)
  else
   spr(147,b.x-4,b.y-4)
  end
 end
 for p in all(g.particles) do pset(p.x,p.y,p.col) end
 for p in all(g.fireworks) do pset(p.x,p.y,p.col) circ(p.x,p.y,1,p.col) end
 rectfill(0,0,128,7,0)
 print("lv"..g.lvl,2,1,7)
 spr(34,16,0) print("x"..oranges_left(),26,1,9)
 print("b:"..g.balls_left,44,1,10)
 spr(34,62,0) print(""..g.apples,71,1,9)
 print("sc:"..g.score,90,1,11)
 if #g.balls>1 then print("x"..#g.balls,2,10,12) end
 if g.combo>1 and #g.balls>0 then print("combo x"..g.combo,44,10,14) end
 if msg_t>0 then
  local w=#msg*4
  rectfill(64-w/2-2,10,64+w/2+2,20,0) rect(64-w/2-2,10,64+w/2+2,20,11)
  print(msg,64-w/2,12,11)
 end
 if g.slowmo>0 then
  if (g.slowmo%6)<3 then rect(2,2,125,125,10) end
  local by=24
  rectfill(14,by,114,by+16,0) rect(14,by,114,by+16,10)
  print("level cleared!",34,by+3,10)
  print("apples: "..g.apples,38,by+9,9)
 end
 spr(35,2,120) print("x"..g.fires,11,121,g.fires>0 and 8 or 5)
 if not g.aiming and g.fires>0 then print("x: bomb ("..g.fires..")",4,114,8) end
end

function drw_bonus()
 cls(1)
 for y=0,127 do
  local col=y<50 and 12 or (y<100 and 13 or 1)
  line(0,y,128,y,col)
 end
 for pi=1,#pilx do
  local px=pilx[pi]
  spr(162,px-4,piltop-8)
  spr(178,px-4,piltop)
 end
 -- plinko pegs
 for p in all(g.plinko) do
  circfill(p.x,p.y,1,6) pset(p.x,p.y,7)
 end
 -- drop indicator during aim
 if g.bonus_aim then
  local dx=g.bonus_dropx
  spr(147,dx-4,14)
  -- dotted guide line
  for yy=22,30,3 do pset(dx,yy,10) end
 end
 for i=1,#pilx-1 do
  local cx=(pilx[i]+pilx[i+1])/2
  local pr=g.bonus_prizes and g.bonus_prizes[i] or "?"
  local lbl=(pr=="life") and "1up" or (pr=="jack") and "1k+" or (pr=="appl") and "10a" or pr
  local col=(pr=="jack") and 10 or (pr=="life") and 11 or (pr=="appl") and 9 or (pr=="250") and 12 or 6
  if g.bonus_got==i then col=10 rectfill(cx-6,pilbot-1,cx+6,pilbot+7,1) end
  print(lbl,cx-#lbl*2+1,pilbot+1,col)
 end
 local b=g.bonus_ball
 if b then spr(147,b.x-4,b.y-4) end
 for p in all(g.fireworks) do pset(p.x,p.y,p.col) circ(p.x,p.y,1,p.col) end
 if g.bonus_result>0 then
  rectfill(14,24,114,40,0) rect(14,24,114,40,10)
  print("level cleared!",34,27,10)
  print(msg,64-#msg*2,33,11)
 elseif g.bonus_banner and g.bonus_banner>0 then
  rectfill(14,24,114,40,0) rect(14,24,114,40,10)
  print("plinko bonus!",34,27,10)
  print("drop into a prize!",26,33,9)
 end
 rectfill(0,0,128,7,0)
 print("lv"..g.lvl,2,1,7) print("sc:"..g.score,90,1,11)
 print("b:"..g.balls_left,44,1,10)
end

function drw_shop()
 cls(1)
 rectfill(6,8,122,120,0) rect(6,8,122,120,11)
 print("shop",52,12,11)
 spr(34,40,20) print("x"..g.apples,50,21,9)
 local items=shop_items()
 local y=34
 for i,it in ipairs(items) do
  local sel=shop_sel==i
  local afford=g.apples>=it.cost and not it.mx
  if sel then rectfill(10,y-1,118,y+7,2) print(">",12,y,11) end
  print(it.nm,20,y,it.mx and 3 or (afford and 7 or 5))
  if it.mx then print("max",96,y,3)
  else spr(34,84,y-1) print("x"..it.cost,94,y,afford and 9 or 5) end
  y=y+11
 end
 if shop_sel>#items then rectfill(10,y-1,118,y+7,2) print(">",12,y,11) end
 print("start level "..g.lvl,20,y,10)
 print("balls:"..g.balls_left.." bomb:"..g.fires,14,98,6)
 print("basket w"..g.bsk_w.." spd"..g.bsk_spd,14,106,6)
 if msg_t>0 then print(msg,64-#msg*2,88,11) end
 print("up/dn pick  z: buy/go",22,113,6)
end

function drw_title()
 cls(1)
 srand(3)
 for i=1,40 do pset(flr(rnd(128)),flr(rnd(120)),flr(rnd(2))==0 and 6 or 5) end
 local by=38+sin(title_t/40)*5
 spr(1,60,by)
 local cols={8,9,10,11,12,14}
 local l1="fox fall"
 for i=1,#l1 do print(sub(l1,i,i),40+(i-1)*6,12,cols[((i+flr(title_t/6))%#cols)+1]) end
 local l2="peg party!"
 for i=1,#l2 do print(sub(l2,i,i),34+(i-1)*6,20,cols[((i+flr(title_t/6))%#cols)+1]) end
 print("hit and catch the apples!",22,52,7)
 -- menu
 local items={"normal run","endless mode","achievements"}
 for i=1,#items do
  local y=66+(i-1)*11
  local sel=(title_sel==i)
  if sel then rectfill(24,y-2,104,y+7,1) print("\132",18,y,10) end
  print(items[i],32,y,sel and 10 or 6)
 end
 if title_t%30<20 then print("\148\131 pick   z: go",28,97,7) end
 print("free on google play:",16,105,11)
  print("foxfall adventures",22,112,11)
   print("support:ko-fi.com/foxfallgames",2,121,6)
end

function drw_achs()
 cls(1)
 rectfill(4,2,124,124,0) rect(4,2,124,124,11)
 local got=0 for i=1,#achs do if has_ach(i) then got=got+1 end end
 print("achievements "..got.."/"..#achs,20,6,11)
 print("high score= "..hi_score,10,14,10)
 print("best endless lvl= "..hi_elvl,10,20,9)
 -- show a window of ~7 around the selection
 local top=mid(1,ach_sel-3,max(1,#achs-6))
 local y=28
 for i=top,min(#achs,top+6) do
  local unlocked=has_ach(i)
  local sel=(i==ach_sel)
  if sel then rectfill(6,y-1,122,y+9,unlocked and 3 or 1) end
  if unlocked then
   print(achs[i][1],10,y,10)
   print(achs[i][2],10,y+5,6)
  else
   print("???",10,y,5)
   print(achs[i][2],10,y+5,5)
  end
  y=y+11
 end
 print("\139\145 scroll   z/x: back",18,117,6)
end

function drw_over()
 cls(0)
 rectfill(2,40,126,90,1) rect(2,40,126,90,8)
 print("run over!",46,44,8)
 print("reached level "..g.lvl,30,54,7)
 print("score: "..g.score,44,63,11)
 print("z: continue (keep lvl+apples)",6,74,10)
 print("x: new run (to title)",24,82,6)
end

function drw_win()
 cls(1)
 srand(7)
 for i=1,30 do
  local x=rnd(128) local y=rnd(128)
  if sin(title_t/60+i/8)>0 then pset(x,y,7) end
 end
 rectfill(8,34,120,92,0) rect(8,34,120,92,10)
 local m="you win!"
 local cols={8,9,10,11,12,14}
 for i=1,#m do print(sub(m,i,i),42+(i-1)*6,44,cols[((i+flr(title_t/5))%#cols)+1]) end
 local ab=g.apples*100 local bb=g.balls_left*100
 local fs="final: "..min(32767,g.score+ab+bb)
 print("score: "..g.score,34,54,7)
 print(g.apples.." apples +"..ab,24,62,9)
 print(g.balls_left.." balls +"..bb,24,70,12)
 print(fs,64-#fs*2,79,10)
 if title_t%30<20 then print("z: title",44,87,7) end
end