-- sqxre
-- by ducc

-- tunables

version="v1.0"
save_id="ducc_sqxre"
fade_frames=20
bigs=3

g=0.45
e_floor=0.7
e_cube=0.8
air_drag=1
floor_fric=0.9
spin_damp=0.8
spin_transfer=0.006
r_mul=0.55

base_size=9
size_step=2
max_size=26

mass_step=0.4

throw_vy_min=4.7
throw_vy_max=8.2
throw_vx=3.6
throw_spin=0.05
throw_mass_damp=0.25
seek_bias=0.7

max_air=3

cost_early={10,25,50}
cost_base=10
cost_step=30
cost_pow=1.6
cost_round=10
cost_prestige_mul=2.5

cap_start=2
sell_min_cubes=2

roll_step=0.05
roll_bonus=0.07
roll_cap=0.7

floor_hit_min=1
cube_hit_min=0.4

flash_frames=2

time_start=100
time_per_tier={30,60,120,240}
time_tier_mul=2
drain_base=0
drain_per_tier=1
drain_period=1
drain_per_score=800
drain_bonus_cap=400

sell_frames=20
sell_mult_per_tier=0.5
sell_points={10,200,3000}
sell_points_mul=10
sell_time_start=10
sell_time_step=1
sell_time_min=1
mult_cap=30000

t1_start=1
t1_step=0.25
t1_min=0.25

float_frames=45
dead_lock_frames=90

draft_early={100,500,1000}
draft_step=1000
draft_lock_frames=30
max_rerolls=3

rar_w={6,3,1.5}
rar_col={6,12,10}

prestige_base=5000
prestige_mult=10
prestige_pow=2

ceil_y=26
house_period=30
spawner_period=900
spawner_min=150
cannon_vx=4
cannon_vy=-6
dog_period=30
dog_amount=10
mush_step=0.06
rainbow_start=100

sfx_floor=0
sfx_hit=1
sfx_merge=2
sfx_buy=3
sfx_sell=4

spr_house=1
spr_cannon=5
spr_dog=7
spr_mush=8
spr_clock=9

cols={8,12,11,10,14}
rain_cols={8,9,10,11,12,14}

big=32000
-->8
function bn(n)
 local b={lo=0,hi=0}
 if n then bn_addn(b,n) end
 return b
end

function bn_addn(b,n)
 n=flr(n)
 if n<=0 then return end
 while n>=big do
  b.hi+=1
  n-=big
 end
 if b.lo>=big-n then
  b.lo=b.lo-(big-n)
  b.hi+=1
 else
  b.lo+=n
 end
end

function bn_addbn(b,o)
 b.hi+=o.hi
 bn_addn(b,o.lo)
end

function bn_subn(b,n)
 n=flr(n)
 while n>=big do
  if b.hi>0 then b.hi-=1 else b.lo=0 return end
  n-=big
 end
 if b.lo>=n then
  b.lo-=n
 elseif b.hi>0 then
  b.hi-=1
  b.lo=b.lo+(big-n)
 else
  b.lo=0
 end
end

function bn_subbn(b,o)
 b.hi-=o.hi
 if b.hi<0 then b.hi=0 b.lo=0 return end
 bn_subn(b,o.lo)
end

function bn_mul(b,m)
 local o={lo=b.lo,hi=b.hi}
 b.lo=0
 b.hi=0
 for i=1,m do bn_addbn(b,o) end
end

function bn_muln(b,m)
 local o={lo=b.lo,hi=b.hi}
 b.lo=0
 b.hi=0
 local w=flr(m)
 for i=1,w do bn_addbn(b,o) end
 local frac=m-w
 if frac>0 then
  local part={lo=flr(o.lo*frac),hi=flr(o.hi*frac)}
  bn_addbn(b,part)
 end
end

function bn_gte(b,n)
 if b.hi>0 then return true end
 return b.lo>=n
end

function bn_cmp(b,o)
 if b.hi!=o.hi then return b.hi-o.hi end
 return b.lo-o.lo
end

function bn_gtebn(b,o)
 return bn_cmp(b,o)>=0
end

function bn_copy(b)
 return {lo=b.lo,hi=b.hi}
end

function dec1(v)
 return flr(v).."."..flr((v%1)*10)
end

function bn_str(b)
 if b.hi==0 then
  local n=flr(b.lo)
  if n<1000 then return tostr(n) end
  return dec1(n/1000).."k"
 end
 if b.hi<1000 then
  local k=b.hi*32+flr(b.lo/1000)
  if k<1000 then return k.."k" end
  return dec1(k/1000).."m"
 end
 local m=b.hi*0.032
 if m<1000 then return dec1(m).."m" end
 return dec1(m/1000).."b"
end

function twid(s,gl)
 return #s*4+(gl or 0)*4
end

function cprint(s,y,c,gl)
 print(s,64-twid(s,gl)/2,y,c)
end
-->8
function _init()
 load_hi()
 prestige=0
 total=bn()
 total_bounce=bn()
 start_run(true)
 start_title()
end

function start_run(fresh)
 cubes={}
 bounces=bn()
 score=bn()
 mult=1+prestige*prestige_mult
 cap=cap_start+prestige
 sell_req=1
 t1_val=t1_start
 sell_time=sell_time_start
 buys=0
 sel=nil
 no_sel=false
 ground_flash=0
 ceil_flash=0
 lw_flash=0
 rw_flash=0
 sell_hold=0
 sell_lock=false
 sell_pop=0
 sell_txt=""
 time_float=0
 time_float_txt=""
 time_left=time_start
 dead=false
 dead_lock=0

 up_floor=0
 has_ceil=false
 up_ceil=0
 has_lw=false
 up_lw=0
 has_rw=false
 up_rw=0
 houses={}
 spawners={}
 dog_lv=0
 dog_t=0
 mush_lv=0
 clocks=0

 rerolls=max_rerolls
 rerolled=false
 draft_n=1
 next_draft=bn(draft_early[1])
 drafting=false
 draft_opts={}
 draft_i=1
 draft_row=1
 draft_lock=0

 roll_next()
 make_cube(64,100,1,next_col)
 roll_next()
 fade=fade_frames
end

function cost()
 local base
 if buys<#cost_early then
  base=cost_early[buys+1]
 else
  base=cost_base+cost_step*(buys^cost_pow)
 end
 base=flr(base/cost_round)*cost_round

 local c=bn(base)
 for i=1,prestige do
  bn_muln(c,cost_prestige_mul)
 end
 return c
end

function prestige_req()
 if prestige==0 then return prestige_base end
 return prestige_base*2*prestige
end

function can_prestige()
 return bn_gte(score,prestige_req())
end

function tier_time(t)
 if t<=#time_per_tier then return time_per_tier[t] end
 local v=time_per_tier[#time_per_tier]
 for i=#time_per_tier+1,t do
  v=min(v*time_tier_mul,30000)
 end
 return v
end

function bounce_e()
 return e_floor+mush_lv*mush_step
end

function score_drain()
 local per=max(1,prestige)
 if score.hi>=100 then return drain_bonus_cap end
 local n=(score.hi*32+flr(score.lo/drain_per_score))*per
 return min(n,drain_bonus_cap)
end

function drain()
 local d=drain_base
 for c in all(cubes) do
  if not c.rain then d+=c.tier*drain_per_tier end
 end
 return d+score_drain()
end

function slots_used()
 local n=0
 for c in all(cubes) do
  if not c.rain then n+=1 end
 end
 return n
end

function count_bounce(n)
 bn_addn(score,n)
 bn_addn(total_bounce,n)
 if bn_cmp(score,next_draft)>=0 and not dead then
  start_draft()
 end
end

function earn(n)
 if n<=0 then return end
 local m=mult
 local per=flr(30000/n)
 if per<1 then per=1 end
 while m>per do
  bn_addn(bounces,n*per)
  m-=per
 end
 bn_addn(bounces,n*m)
end

function add_time(n)
 if n<=0 then return end
 time_left+=n
 time_float=float_frames
 time_float_txt="+"..n
end

function tier_points(t)
 local v=bn()
 if t<=#sell_points then
  bn_addn(v,sell_points[t])
  return v
 end
 bn_addn(v,sell_points[#sell_points])
 for i=#sell_points+1,t do
  bn_mul(v,sell_points_mul)
 end
 return v
end

function gain(c)
 if c.tier<=1 then return t1_val end
 return c.tier*sell_mult_per_tier
end

function roll_next()
 next_col=cols[flr(rnd(#cols))+1]

 local best=sell_req-1
 local t={}
 local total2=0
 for tier=2,best do
  local p=(best-tier+1)*roll_step+roll_bonus
  add(t,{tier=tier,p=p})
  total2+=p
 end

 if total2>roll_cap then
  local k=roll_cap/total2
  for e in all(t) do e.p*=k end
 end

 next_tier=1
 local r=rnd(1)
 local acc=0
 for e in all(t) do
  acc+=e.p
  if r<acc then
   next_tier=e.tier
   break
  end
 end
end

function make_cube(x,y,tier,col)
 tier=tier or 1
 col=col or cols[flr(rnd(#cols))+1]
 local s=min(base_size+(tier-1)*size_step,max_size)
 local c={
  x=x,y=y,
  vx=0,vy=0,
  rot=rnd(1),spin=0,
  tier=tier,
  col=col,
  size=s,
  r=s*r_mul,
  m=1+(tier-1)*mass_step,
  flash=0,
  air=max_air,
  rain=false,
  gone=false
 }
 add(cubes,c)
 return c
end

function make_rainbow()
 local c=make_cube(8+rnd(112),ceil_y+14,1,7)
 c.rain=true
 c.num=rainbow_start
 c.size=11
 c.r=c.size*r_mul
 c.m=1
 return c
end

function find_match(c)
 local best=nil
 local bd=99999
 for o in all(cubes) do
  if o!=c and not o.rain and not c.rain
   and o.tier==c.tier and o.col==c.col then
   local dx=o.x-c.x
   local dy=o.y-c.y
   local d=dx*dx+dy*dy
   if d<bd then bd=d best=o end
  end
 end
 return best
end

function throw(c)
 if c.air<=0 then return end
 c.air-=1
 local d=1/(1+(c.m-1)*throw_mass_damp)
 c.vy=-(throw_vy_min+rnd(throw_vy_max-throw_vy_min))*d

 local base=(rnd(throw_vx*2)-throw_vx)*d
 local t=find_match(c)
 if t then
  local dir=1
  if t.x<c.x then dir=-1 end
  local aim=dir*throw_vx*d
  c.vx=base*(1-seek_bias)+aim*seek_bias
 else
  c.vx=base
 end
 c.spin=(rnd(throw_spin*2)-throw_spin)*d
end

function rain_hit(c)
 earn(c.num)
 count_bounce(1)
 c.num-=1
 c.flash=flash_frames
 if c.num<=0 then c.gone=true end
end

function by_x()
 local t={}
 for c in all(cubes) do add(t,c) end
 for i=2,#t do
  local v=t[i]
  local j=i-1
  while j>=1 and t[j].x>v.x do
   t[j+1]=t[j]
   j-=1
  end
  t[j+1]=v
 end
 return t
end

function move_sel(d)
 local t={}
 for c in all(by_x()) do
  if not c.rain then add(t,c) end
 end
 if #t==0 then sel=nil return end
 no_sel=false
 if not sel then
  sel=t[1]
  return
 end
 local idx=1
 for i=1,#t do
  if t[i]==sel then idx=i break end
 end
 idx+=d
 if idx<1 then idx=#t end
 if idx>#t then idx=1 end
 sel=t[idx]
end

function fix_sel()
 if no_sel then sel=nil return end
 for c in all(cubes) do
  if c==sel then return end
 end
 sel=nil
 for c in all(by_x()) do
  if not c.rain then sel=c return end
 end
end

function can_sell()
 return sel and slots_used()>=sell_min_cubes
end

function do_sell(c)
 local g2=gain(c)
 mult=min(mult+g2,mult_cap)

 local up=false
 if c.tier>=sell_req then
  cap+=1
  sell_req+=1
  up=true
 end
 if c.tier<=1 then
  t1_val=max(t1_val-t1_step,t1_min)
 end

 bn_addbn(bounces,tier_points(c.tier))
 add_time(c.tier*sell_time)
 sell_time=max(sell_time-sell_time_step,sell_time_min)

 sell_txt="+"..g2.."x"
 if up then sell_txt=sell_txt.."  +slot" end

 del(cubes,c)
 sel=nil
 sell_pop=45
 sfx(sfx_sell)
 fix_sel()
end
-->8
function add_house()
 add(houses,{x=88,w=32,h=32,t=0,flash=0})
end

function add_spawner()
 add(spawners,{x=6,w=16,h=16,t=spawner_period,period=spawner_period,
  ncol=cols[flr(rnd(#cols))+1]})
end

function upgrade_pool()
 local p={}
 add(p,{id="floor",name="floor",d="+1 floor",r=1})

 if has_ceil then
  add(p,{id="ceil",name="ceiling+",d="+1 hit",r=1})
 else
  add(p,{id="ceil",name="ceiling",d="new wall",r=1})
 end
 if has_lw then
  add(p,{id="lw",name="left+",d="+1 hit",r=1})
 else
  add(p,{id="lw",name="left",d="new wall",r=1})
 end
 if has_rw then
  add(p,{id="rw",name="right+",d="+1 hit",r=1})
 else
  add(p,{id="rw",name="right",d="new wall",r=1})
 end

 add(p,{id="clock",name="clock",d="+100 hp",r=2})
 if #houses==0 then
  add(p,{id="house",name="house",d="scores inside",r=2})
 end
 if #spawners==0 then
  add(p,{id="spawner",name="cannon",d="free cubes",r=2})
 else
  add(p,{id="spdup",name="cannon+",d="faster",r=2})
 end
 if dog_lv==0 then
  add(p,{id="dog",name="dog",d="+10 / sec",r=2})
 else
  add(p,{id="dog",name="dog+",d="+10 more",r=2})
 end
 if mush_lv==0 then
  add(p,{id="mush",name="mushroom",d="bouncier",r=2})
 else
  add(p,{id="mush",name="mushroom+",d="more bounce",r=2})
 end

 add(p,{id="rain",name="rainbow",d="bonus cube",r=3})
 add(p,{id="bump",name="merge",d="+1 a cube",r=3})

 return p
end

function roll_draft()
 local p=upgrade_pool()
 draft_opts={}
 for i=1,3 do
  if #p==0 then break end
  local tw=0
  for e in all(p) do tw+=rar_w[e.r] end
  local r=rnd(tw)
  local acc=0
  local pick=p[1]
  for e in all(p) do
   acc+=rar_w[e.r]
   if r<acc then pick=e break end
  end
  add(draft_opts,pick)
  del(p,pick)
 end
 draft_i=1
end

function start_draft()
 drafting=true
 draft_lock=draft_lock_frames
 sell_hold=0
 roll_draft()
 draft_row=1
 rerolled=false

 if draft_n<#draft_early then
  bn_addn(next_draft,draft_early[draft_n+1]-draft_early[draft_n])
 else
  bn_addn(next_draft,draft_step)
 end
 draft_n+=1
end

function take_upgrade(u)
 if u.id=="floor" then
  up_floor+=1
 elseif u.id=="ceil" then
  if has_ceil then
   up_ceil+=1
  else
   has_ceil=true
   for c in all(cubes) do
    local h=c.size/2
    if c.y-h<ceil_y then
     c.y=ceil_y+h
     c.vy=abs(c.vy)
    end
   end
  end
 elseif u.id=="lw" then
  if has_lw then up_lw+=1 else has_lw=true end
 elseif u.id=="rw" then
  if has_rw then up_rw+=1 else has_rw=true end
 elseif u.id=="house" then
  add_house()
 elseif u.id=="spawner" then
  add_spawner()
 elseif u.id=="spdup" then
  local s=spawners[1]
  if s then
   s.period=max(s.period-60,spawner_min)
   s.t=min(s.t,s.period)
  end
 elseif u.id=="dog" then
  dog_lv+=1
 elseif u.id=="mush" then
  mush_lv+=1
 elseif u.id=="clock" then
  clocks+=1
  add_time(100)
 elseif u.id=="rain" then
  make_rainbow()
 elseif u.id=="bump" then
  local pool={}
  for c in all(cubes) do
   if not c.rain then add(pool,c) end
  end
  if #pool>0 then
   local c=pool[flr(rnd(#pool))+1]
   c.tier+=1
   c.size=min(base_size+(c.tier-1)*size_step,max_size)
   c.r=c.size*r_mul
   c.m=1+(c.tier-1)*mass_step
   c.flash=flash_frames
   add_time(tier_time(c.tier))
  end
 end
 drafting=false
end

function do_prestige()
 bn_addbn(total,score)
 prestige+=1
 drafting=false
 start_run(false)
end

function update_draft()
 if draft_lock>0 then draft_lock-=1 end

 local rows=2
 if can_prestige() then rows=3 end

 if draft_row==1 then
  if btnp(0) then draft_i=max(draft_i-1,1) end
  if btnp(1) then draft_i=min(draft_i+1,#draft_opts) end
  if btnp(3) then draft_row=2 end
 else
  if btnp(2) then draft_row=max(draft_row-1,1) end
  if btnp(3) then draft_row=min(draft_row+1,rows) end
 end

 if draft_lock<=0 and (btnp(5) or btnp(4)) then
  if draft_row==3 then
   if can_prestige() then do_prestige() end
  elseif draft_row==2 then
   if rerolls>0 and not rerolled then
    rerolls-=1
    rerolled=true
    roll_draft()
    draft_row=1
   end
  else
   take_upgrade(draft_opts[draft_i])
  end
 end
end
-->8
function _update()
 if mode=="title" then
  update_title()
  return
 end

 if fade_dir==-1 then
  fade-=1
  if fade<=0 then
   fade=0
   fade_dir=0
  end
 end

 if dead then
  if dead_lock>0 then
   dead_lock-=1
  elseif btnp(4) or btnp(5) then
   start_title()
  end
  return
 end

 if drafting then
  update_draft()
  return
 end

  time_left-=drain()/(30*drain_period)
 if time_left<=0 then
  time_left=0
  dead=true
  dead_lock=dead_lock_frames
  bn_addbn(total,score)
  local f=bn_copy(total)
  if prestige>0 then bn_mul(f,prestige+1) end
  save_hi(f)
  return
 end

 if ground_flash>0 then ground_flash-=1 end
 if ceil_flash>0 then ceil_flash-=1 end
 if lw_flash>0 then lw_flash-=1 end
 if rw_flash>0 then rw_flash-=1 end
 if sell_pop>0 then sell_pop-=1 end
 if time_float>0 then time_float-=1 end
 for c in all(cubes) do
  if c.flash>0 then c.flash-=1 end
 end

 for h in all(houses) do
  if h.flash>0 then h.flash-=1 end
  h.t+=1
  if h.t>=house_period then
   h.t=0
   local x1=h.x
   local x2=h.x+h.w
   local y1=121-h.h
   for c in all(cubes) do
    if c.x>x1 and c.x<x2 and c.y>y1 and c.y<121 then
     earn(c.tier)
     h.flash=flash_frames
    end
   end
  end
 end

 if dog_lv>0 then
  dog_t+=1
  if dog_t>=dog_period then
   dog_t=0
   earn(dog_lv*dog_amount)
  end
 end

 for s in all(spawners) do
  s.t-=1
  if s.t<=0 then
   s.t=s.period
   if slots_used()<cap then
    local tier=1
    if rnd(1)<0.3 then tier=min(flr(rnd(sell_req)),4)+1 end
    local c=make_cube(s.x+s.w/2,121-s.h-6,tier,s.ncol)
    c.vx=cannon_vx+rnd(1)
    c.vy=cannon_vy-rnd(1)
    c.spin=rnd(0.06)-0.03
    s.ncol=cols[flr(rnd(#cols))+1]
    sfx(sfx_buy)
   end
  end
 end

 fix_sel()

 if btnp(0) then move_sel(-1) end
 if btnp(1) then move_sel(1) end
 if btnp(2) then
  if sel then
   sel=nil
   no_sel=true
   sell_hold=0
  else
   no_sel=false
   fix_sel()
  end
 end

 if btn(3) then
  if not sell_lock and can_sell() then
   sell_hold+=1
   if sell_hold>=sell_frames then
    do_sell(sel)
    sell_hold=0
    sell_lock=true
   end
  end
 else
  sell_hold=0
  sell_lock=false
 end

 if btnp(4) then
  for c in all(cubes) do throw(c) end
 end

 if btnp(5) and slots_used()<cap then
  local cst=cost()
  if bn_gtebn(bounces,cst) then
   bn_subbn(bounces,cst)
   buys+=1
   add_time(tier_time(next_tier))
   make_cube(8+rnd(112),ceil_y+14,next_tier,next_col)
   sfx(sfx_buy)
   roll_next()
  end
 end

 for c in all(cubes) do
  c.vy+=g
  c.vx*=air_drag
  c.x+=c.vx
  c.y+=c.vy
  c.rot+=c.spin
 end

 local born={}
 for i=1,#cubes-1 do
  for j=i+1,#cubes do
   local a,b=cubes[i],cubes[j]
   if not a.gone and not b.gone then
    local dx=b.x-a.x
    local dy=b.y-a.y
    local d=sqrt(dx*dx+dy*dy)
    local md=a.r+b.r

    if d<md then
     if d<0.01 then
      dx=rnd(1)-0.5 dy=-1 d=1
     end
     local nx=dx/d
     local ny=dy/d

     local canmerge=(not a.rain) and (not b.rain)
      and a.tier==b.tier and a.col==b.col

     if canmerge then
      a.gone=true
      b.gone=true
      local tm=a.m+b.m
      add(born,{
       x=(a.x+b.x)/2,
       y=(a.y+b.y)/2,
       vx=(a.vx*a.m+b.vx*b.m)/tm,
       vy=(a.vy*a.m+b.vy*b.m)/tm,
       spin=(a.spin+b.spin)/2,
       tier=a.tier+1,
       col=a.col,
       air=max(a.air,b.air),
       take=(a==sel or b==sel)
      })
      sfx(sfx_merge)
     else
      local ima=1/a.m
      local imb=1/b.m
      local ov=(md-d)/(ima+imb)

      a.x-=nx*ov*ima a.y-=ny*ov*ima
      b.x+=nx*ov*imb b.y+=ny*ov*imb

      local rvn=(b.vx-a.vx)*nx+(b.vy-a.vy)*ny
      if rvn<0 then
       if rvn<-cube_hit_min then
        if a.rain then rain_hit(a) end
        if b.rain then rain_hit(b) end
        if not a.rain and not b.rain then
         count_bounce(max(a.tier,b.tier))
         earn(max(a.tier,b.tier))
         a.flash=flash_frames
         b.flash=flash_frames
        end
        sfx(sfx_hit)
       end

       local p=-(1+e_cube)*rvn/(ima+imb)
       a.vx-=p*nx*ima a.vy-=p*ny*ima
       b.vx+=p*nx*imb b.vy+=p*ny*imb

       local rvt=(b.vx-a.vx)*-ny+(b.vy-a.vy)*nx
       a.spin-=rvt*spin_transfer*ima
       b.spin+=rvt*spin_transfer*imb
      end
     end
    end
   end
  end
 end

 for i=#cubes,1,-1 do
  if cubes[i].gone then del(cubes,cubes[i]) end
 end
 for n in all(born) do
  local c=make_cube(n.x,n.y,n.tier,n.col)
  c.vx=n.vx
  c.vy=n.vy
  c.spin=n.spin
  c.air=n.air
  c.flash=flash_frames
  add_time(tier_time(n.tier))
  if n.take and not no_sel then sel=c end
 end
 fix_sel()

 local eb=bounce_e()
 for c in all(cubes) do
  local h=c.size/2

  if c.y+h>120 then
   c.y=120-h
   if c.vy>floor_hit_min then
    if c.rain then
     rain_hit(c)
    else
     count_bounce(c.tier)
     earn(c.tier+up_floor)
     c.flash=flash_frames
    end
    ground_flash=flash_frames
    sfx(sfx_floor)
   end
   c.air=max_air
   c.vy*=-eb
   c.vx*=floor_fric
   c.spin*=spin_damp
  end

  if has_ceil and c.y-h<ceil_y then
   c.y=ceil_y+h
   if c.vy<-floor_hit_min then
    if c.rain then
     rain_hit(c)
    else
     count_bounce(c.tier)
     earn(c.tier+up_ceil)
     c.flash=flash_frames
    end
    ceil_flash=flash_frames
    sfx(sfx_floor)
   end
   c.vy*=-eb
  end

  if c.x<h then
   c.x=h
   if has_lw and abs(c.vx)>floor_hit_min then
    if c.rain then
     rain_hit(c)
    else
     count_bounce(c.tier)
     earn(c.tier+up_lw)
     c.flash=flash_frames
    end
    lw_flash=flash_frames
    sfx(sfx_hit)
   end
   c.vx*=-1
  end

  if c.x>127-h then
   c.x=127-h
   if has_rw and abs(c.vx)>floor_hit_min then
    if c.rain then
     rain_hit(c)
    else
     count_bounce(c.tier)
     earn(c.tier+up_rw)
     c.flash=flash_frames
    end
    rw_flash=flash_frames
    sfx(sfx_hit)
   end
   c.vx*=-1
  end
 end

 for i=#cubes,1,-1 do
  if cubes[i].gone then del(cubes,cubes[i]) end
 end
 fix_sel()
end
-->8
function draw_cube(c)
 local col=c.col
 if c.rain then
  col=rain_cols[(flr(time()*12)%#rain_cols)+1]
 end
 if c.flash>0 then col=7 end

 local h=c.size/2
 local co=cos(c.rot)
 local si=sin(c.rot)
 local corners={{-h,-h},{h,-h},{h,h},{-h,h}}
 local pts={}

 for i=1,4 do
  local px,py=corners[i][1],corners[i][2]
  add(pts,{x=c.x+px*co-py*si, y=c.y+px*si+py*co})
 end

 for i=1,4 do
  local a=pts[i]
  local b=pts[i%4+1]
  line(a.x,a.y,b.x,b.y,col)
 end

 local t=tostr(c.tier)
 if c.rain then t=tostr(c.num) end
 print(t,c.x-twid(t)/2+1,c.y-2,col)
end

function draw_arrow()
 if not sel then return end
 if slots_used()<sell_min_cubes then return end
 local col=6
 if sel.tier>=sell_req then col=10 end
 local x=sel.x
 local y=sel.y-sel.size/2-4
 line(x,y-5,x,y,col)
 line(x-2,y-2,x,y,col)
 line(x+2,y-2,x,y,col)
end

function fade_pal()
 pal(7,5)
 pal(6,5)
 pal(15,4)
 pal(14,2)
 pal(12,1)
 pal(11,3)
 pal(10,4)
 pal(9,4)
 pal(8,2)
 pal(4,1)
 pal(3,1)
 pal(2,1)
 pal(13,1)
 pal(1,0)
end

function draw_buildings()
 fade_pal()
 for h in all(houses) do
  if h.flash<=0 then
   spr(spr_house,h.x,121-h.h,4,4)
  end
 end
 for s in all(spawners) do
  spr(spr_cannon,s.x,121-s.h,2,2)
 end
 if dog_lv>0 then
  spr(spr_dog,78,113)
 end
 if mush_lv>0 then
  spr(spr_mush,24,113)
 end
 if clocks>0 then
  spr(spr_clock,3,ceil_y+3)
 end
 pal()

 for h in all(houses) do
  if h.flash>0 then
   for i=1,15 do pal(i,7) end
   spr(spr_house,h.x,121-h.h,4,4)
   pal()
  end
 end

 for s in all(spawners) do
  local y=121-s.h
  rect(s.x+5,y-9,s.x+9,y-5,s.ncol)
  local p=1-(s.t/s.period)
  local w=flr(s.w*p)
  if w>0 then rectfill(s.x,y-3,s.x+w,y-2,11) end
 end

 if dog_lv>1 then print(dog_lv,79,107,5) end
 if mush_lv>1 then print(mush_lv,25,107,5) end
 if clocks>1 then print(clocks,12,ceil_y+5,5) end
end

function up_icon(id,x,y)
 if id=="house" then
  spr(spr_house,x+3,y+3,4,4)
 elseif id=="spawner" or id=="spdup" then
  spr(spr_cannon,x+11,y+11,2,2)
 elseif id=="dog" then
  spr(spr_dog,x+15,y+15)
 elseif id=="mush" then
  spr(spr_mush,x+15,y+15)
 elseif id=="clock" then
  spr(spr_clock,x+15,y+15)
 elseif id=="rain" then
  local c=rain_cols[(flr(time()*12)%#rain_cols)+1]
  rect(x+13,y+13,x+24,y+24,c)
 elseif id=="bump" then
  rect(x+13,y+15,x+24,y+24,11)
  line(x+18,y+9,x+18,y+13,11)
  line(x+16,y+11,x+18,y+9,11)
  line(x+20,y+11,x+18,y+9,11)
 elseif id=="floor" then
  line(x+11,y+22,x+26,y+22,12)
 elseif id=="ceil" then
  line(x+11,y+14,x+26,y+14,12)
 elseif id=="lw" then
  line(x+12,y+11,x+12,y+26,12)
 elseif id=="rw" then
  line(x+25,y+11,x+25,y+26,12)
 else
  rect(x+13,y+13,x+24,y+24,12)
 end
end

function draw_draft()
 rectfill(0,0,127,127,0)
 cprint("choose one",4,7)

 local n=#draft_opts
 local bw=38
 local bh=38
 local gap=3
 local total2=n*bw+(n-1)*gap
 local x0=64-total2/2
 local y=16

 for i=1,n do
  local x=x0+(i-1)*(bw+gap)
  local u=draft_opts[i]
  local c=rar_col[u.r]
  if i==draft_i and draft_row==1 then
   c=7
   rect(x-1,y-1,x+bw,y+bh,rar_col[u.r])
  end

  rect(x,y,x+bw-1,y+bh-1,c)
  up_icon(u.id,x,y)

  local nm=u.name
  print(nm,x+bw/2-twid(nm)/2,y+bh+4,c)
  print(u.d,x+bw/2-twid(u.d)/2,y+bh+12,6)
 end

 local ry=80
 local rc=6
 if rerolls<=0 or rerolled then rc=5 end
 if draft_row==2 then rc=7 end
 local rt="rerolls - "..rerolls
 if rerolled then rt="used" end
 local rw=twid(rt)+8
 rect(64-rw/2,ry,64+rw/2,ry+10,rc)
 print(rt,64-twid(rt)/2,ry+3,rc)

 local py=94
 local pc=5
 if can_prestige() then pc=9 end
 if draft_row==3 then pc=7 end
 local pt="prestige"
 if not can_prestige() then
  pt="prestige "..bn_str(score).."/"..flr(prestige_req()/1000).."k"
 end
 local pw=twid(pt)+8
 rect(64-pw/2,py,64+pw/2,py+10,pc)
 print(pt,64-twid(pt)/2,py+3,pc)

 if draft_row==3 then
  local m="x"..flr(1+(prestige+1)*prestige_mult).." mult"
  local s=(cap_start+prestige+1).." slots"
  local d="reset all"
  print(m,64-twid(m)/2,108,9)
  print(s,64-twid(s)/2,114,9)
  print(d,64-twid(d)/2,120,8)
 end
end

function draw_buyline()
 local y=11
 local cst=cost()
 local s1="❘ "..bn_str(cst)
 local s2=slots_used().."/"..cap
 local w1=twid(s1,1)
 local w2=twid(s2)
 local gap=4
 local sq=5

 local cc=6
 if slots_used()>=cap then
  cc=8
 elseif bn_gtebn(bounces,cst) then
  cc=11
 end

 local total2=w1+gap+sq+gap+w2
 local x=64-total2/2

 print(s1,x,y,cc)
 local sx=x+w1+gap
 rect(sx,y,sx+sq-1,y+sq-1,next_col)
 print(s2,sx+sq+gap,y,cc)
end

function draw_dead()
 rectfill(14,36,113,92,0)
 rect(14,36,113,92,8)
 cprint("run over",41,8)

 local f=bn_copy(total)
 if prestige>0 then bn_mul(f,prestige+1) end

 print("bounces",20,52,6)
 local a=bn_str(total_bounce)
 print(a,107-twid(a),52,7)

 print("prestige",20,60,6)
 local b="x"..(prestige+1)
 print(b,107-twid(b),60,9)

 line(20,68,107,68,5)

 print("score",20,73,6)
 local c=bn_str(f)
 print(c,107-twid(c),73,10)

 if dead_lock<=0 then
  cprint("❘ retry",84,5,1)
 end
end

function _draw()
 if mode=="title" then
  draw_title()
  return
 end

 cls(0)

 if drafting then
  draw_draft()
  pal()
  return
 end

 draw_buildings()

 local gc=5
 if ground_flash>0 then gc=7 end
 line(0,121,127,121,gc)

 if has_ceil then
  local cc2=5
  if ceil_flash>0 then cc2=7 end
  line(0,ceil_y,127,ceil_y,cc2)
 end

 if has_lw then
  local wc=5
  if lw_flash>0 then wc=7 end
  local top=0
  if has_ceil then top=ceil_y end
  line(0,top,0,121,wc)
 end
 if has_rw then
  local wc=5
  if rw_flash>0 then wc=7 end
  local top=0
  if has_ceil then top=ceil_y end
  line(127,top,127,121,wc)
 end

 for c in all(cubes) do
  draw_cube(c)
 end
 draw_arrow()

 print(flr(time_left),3,3,8)
 print("-"..drain(),3,10,2)
 if time_float>0 then
  local yo=flr((float_frames-time_float)/12)
  print(time_float_txt,22,11-yo,11)
 end

 local a=bn_str(bounces)
 local b="x"..flr(mult)
 local w=twid(a)+4+twid(b)
 local mx=64-w/2
 print(a,mx,3,7)
 print(b,mx+twid(a)+4,3,12)

 local sc=bn_str(score)
 print(sc,125-twid(sc),3,10)
 if prestige>0 then
  local pp="p"..prestige
  print(pp,125-twid(pp),10,9)
 end

 draw_buyline()

 if sell_hold>0 then
  cprint("selling",52,10)
  local p="+"..gain(sel).."x  +"..bn_str(tier_points(sel.tier)).."  +"..(sel.tier*sell_time).."s"
  if sel.tier>=sell_req then p=p.."  +slot" end
  cprint(p,60,12)
  rect(38,68,89,72,5)
  local w2=flr(50*sell_hold/sell_frames)
  if w2>0 then rectfill(39,69,38+w2,71,10) end
 elseif can_sell() then
  cprint("⬇️ sell",19,10,1)
 end

 if sell_pop>0 then
  cprint(sell_txt,52,12)
 end

  if dead then
  draw_dead()
 end

 fade_pal_lvl(flr(fade/fade_frames*5))
end
-->8
-- letter strokes: {x,y,w,h} in 1-unit cells
big_font={
 s={{0,0,3,1},{0,1,1,1},{0,2,3,1},{2,3,1,1},{0,4,3,1}},
 q={{0,0,3,1},{0,1,1,3},{2,1,1,3},{0,4,3,1},{2,4,2,1}},
 x={{0,0,1,1},{2,0,1,1},{1,1,1,1},{1,2,1,1},{1,3,1,1},{0,4,1,1},{2,4,1,1}},
 r={{0,0,3,1},{0,1,1,1},{2,1,1,1},{0,2,3,1},{0,3,1,2},{2,3,1,2}},
 e={{0,0,3,1},{0,1,1,1},{0,2,3,1},{0,3,1,1},{0,4,3,1}}
}

function big_letter(ch,x,y,s,c)
 local f=big_font[ch]
 if not f then return end
 for r in all(f) do
  rectfill(x+r[1]*s,y+r[2]*s,
   x+(r[1]+r[3])*s-1,y+(r[2]+r[4])*s-1,c)
 end
end

function big_text(t,x,y,s,c)
 local cx=x
 for i=1,#t do
  local ch=sub(t,i,i)
  big_letter(ch,cx,y,s,c)
  cx+=4*s
 end
end

function big_width(t,s)
 return #t*4*s-s
end

function load_hi()
 cartdata(save_id)
 hi_lo=dget(0)
 hi_hi=dget(1)
 hiscore={lo=hi_lo,hi=hi_hi}
end

function save_hi(b)
 if bn_cmp(b,hiscore)>0 then
  hiscore=bn_copy(b)
  dset(0,hiscore.lo)
  dset(1,hiscore.hi)
 end
end

function fade_pal_lvl(n)
 local ramp={
  {0,0,0,0},{1,1,0,0},{2,2,1,0},{3,3,1,0},
  {4,2,1,0},{5,5,1,0},{6,13,5,0},{7,6,13,0},
  {8,2,1,0},{9,4,2,0},{10,9,4,0},{11,3,1,0},
  {12,13,1,0},{13,1,1,0},{14,2,1,0},{15,4,2,0}
 }
 if n<=0 then pal() return end
 if n>=4 then
  for i=0,15 do pal(i,0) end
  return
 end
 for i=0,15 do
  pal(i,ramp[i+1][n+1])
 end
end

function start_title()
 mode="title"
 fade=0
 fade_dir=0
end

function update_title()
 if fade_dir==0 then
  if btnp(4) or btnp(5) then
   fade_dir=1
   sfx(sfx_buy)
  end
 elseif fade_dir==1 then
  fade+=1
  if fade>=fade_frames then
   mode="game"
   prestige=0
   total=bn()
   total_bounce=bn()
   start_run(true)
   fade_dir=-1
  end
 end
end

function draw_title()
 cls(0)

 local t="sqxre"
 local w=big_width(t,bigs)
 big_text(t,64-w/2,26,bigs,7)

 print(version,125-twid(version),4,5)

 cprint("start",70,11)

 local h="high  "..bn_str(hiscore)
 cprint(h,84,10)

 cprint("made by ducc",118,5)

 fade_pal_lvl(flr(fade/fade_frames*5))
end