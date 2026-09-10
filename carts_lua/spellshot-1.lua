

grav=0.22 fric=0.8 accel=0.35 jumpf=-3.5

weapons={}
for l in all(split([[
bolt,spd=3,dmg=1,rate=12,col=10,kick=2.2,gsp=48,vsp=160
blade,spd=3,dmg=2,rate=12,col=7,kick=2,wave=1,pierce=1,fuse=14,gsp=32,vsp=166
bombarc,spd=2.6,dmg=2,rate=40,col=11,kick=3,boom=1,grav=1,gsp=52,vsp=164
bombshot,spd=2,dmg=2,rate=45,col=9,boom=1,kick=3.4,gsp=51,vsp=163
lance,spd=6,dmg=3,rate=40,col=12,kick=2.8,pierce=1,beam=1,gsp=50,vsp=162
scatter,spd=2.8,dmg=1,rate=30,col=4,kick=3.2,n=3,gsp=49,vsp=161
skullshot,spd=1.5,dmg=2,rate=70,col=8,kick=3,boom=1,hom=1,bsp=23,fuse=60,gsp=53,vsp=165
]],"\n",false)) do
 local p=split(l,",",false)
 if #p>1 then
  local d={name=p[1]}
  for i=2,#p do
   local kv=split(p[i],"=",false)
   d[kv[1]]=tonum(kv[2]) or kv[2]
  end
  add(weapons,d)
 end
end

entity_types={}
for l in all(split([[
grunt,sp=24,sp2=25,w=6,h=6,ox=1,oy=2,dox=-1,doy=-2,hp=3,spd=0.35,ai=chase,dmg=1,hostile=1
patrol,sp=26,sp2=27,w=6,h=6,ox=1,oy=2,dox=-1,doy=-2,hp=2,spd=0.3,ai=patrol,dmg=1,hostile=1
spike,sp=18,w=8,h=4,oy=4,doy=-4,dmg=1
coin,sp=19,sp2=137,w=8,h=8,touch=coin,uid=1
heart,sp=20,sp2=155,w=8,h=8,touch=heart,uid=1
wpn,sp=32,w=8,h=8,touch=wpn
bounty,sp=22,sp2=138,w=8,h=8,touch=bounty,uid=1
relic,sp=34,w=8,h=8,touch=relic
term,sp=21,sp2=205,w=8,h=8,touch=term
gunner,sp=28,sp2=77,w=8,h=8,hp=4,spd=0,ai=turret,dmg=1,hostile=1,g_rate=90
warper,sp=29,sp2=75,w=6,h=6,ox=1,oy=1,dox=-1,doy=-1,hp=3,ai=warp,dmg=1,hostile=1,g_rate=100
gunner2,sp=30,sp2=76,w=8,h=8,hp=4,spd=0,ai=turret,dmg=1,hostile=1,g_rate=130,g_boom=1
warper2,sp=31,sp2=74,w=6,h=6,ox=1,oy=1,dox=-1,doy=-1,hp=3,ai=warp,dmg=1,hostile=1,g_rate=140,g_boom=1
brute,sp=40,sp2=70,drop=6,big=1,w=14,h=14,ox=1,oy=2,dox=-1,doy=-2,hp=24,spd=0.45,ai=chase,dmg=2,hostile=1,g_rate=100,g_spd=2,g_n=3
hopper,sp=42,sp2=66,drop=4,airanim=1,big=1,w=14,h=14,ox=1,oy=2,dox=-1,doy=-2,hp=18,spd=1.2,ai=hop,dmg=2,hostile=1
sentry,sp=44,sp2=68,drop=7,big=1,w=14,h=14,ox=1,oy=2,dox=-1,doy=-2,hp=30,spd=1.1,ai=patrol,dmg=2,hostile=1,g_rate=110,g_spd=1.2,g_boom=1,g_hom=1,g_bsp=23,g_fuse=60
flyer,sp=38,sp2=64,drop=5,big=1,w=14,h=14,ox=1,oy=1,dox=-1,doy=-1,hp=20,spd=0.8,ai=fly,dmg=2,hostile=1,g_rate=80,g_spd=3,g_beam=1,g_pierce=1
crab,sp=46,sp2=72,drop=3,big=1,w=14,h=14,ox=1,oy=1,dox=-1,doy=-1,hp=26,spd=0.7,ai=crawl,dmg=2,hostile=1,g_rate=100,g_spd=2,g_boom=1,g_grav=1
clone,sp=78,sp2=79,drop=2,boss=1,w=6,h=6,ox=1,oy=1,dox=-1,doy=-1,hp=22,spd=1.2,ai=hop,dmg=2,hostile=1,g_rate=70,g_spd=2.5,g_wave=1,g_pierce=1,g_fuse=14
]],"\n",false)) do
 local p=split(l,",",false)
 if #p>1 then
  local d={}
  for i=2,#p do
   local kv=split(p[i],"=",false)
   local v=tonum(kv[2]) or kv[2]
   if sub(kv[1],1,2)=="g_" then
    d.gun=d.gun or {}
    d.gun[sub(kv[1],3)]=v
   else
    d[kv[1]]=v
   end
  end
  entity_types[p[1]]=d
 end
end

shop_pool={}
for s in all(split([[
50,maxhp,0,heart container,+1 max hp
50,life,0,life,+1 life
5,heal,0,heal,heal all
40,wpn,3,gun: bombarc,explosive arc shot
35,wpn,4,gun: bombshot,explosive shot
35,wpn,5,gun: lance,piercing shots
30,wpn,6,gun: scatter,spread shot
45,wpn,7,gun: skullshot,chasing explosive
30,wpn,2,gun: blade,slash and dash
45,relic,aj,perk: leap,double jump,37
30,relic,rk,perk: recoil,increase recoil,34
50,relic,sh,perk: powershot,increase dmg,35
40,relic,qd,perk: swiftshot,increase fire rate,36
30,relic,th,perk: thorns,inflict dmg on contact,93
45,relic,gd,perk: ward,block 1st hit each floor,90
25,relic,mg,perk: magnet,pull coins to you,91
25,relic,gr,perk: greed,increase coin drop chance,92
]],"\n",false)) do
 local p=split(s)
 if #p>=5 then
  add(shop_pool,{cost=p[1],g=p[2],v=p[3],
   lbl=p[4],desc=p[5],sp=p[6]})
 end
end

legend={}
for s in all(split([[
1,t,16
x,t,9
e,t,10
g,e,grunt
p,e,patrol
^,e,spike
$,e,coin
h,e,heart
2,e,wpn,2
3,e,wpn,3
4,e,wpn,4
5,e,wpn,5
6,e,wpn,6
7,e,wpn,7
t,e,gunner
w,e,warper
T,e,gunner2
W,e,warper2
k,e,bounty
a,e,term,1
b,e,term,2
c,e,term,3
]],"\n",false)) do
 local p=split(s,",",false)
 if #p>=3 then
  legend[p[1]]=p[2]=="t"
   and {t=tonum(p[3])}
   or {e=p[3],v=p[4] and tonum(p[4])}
 end
end

chunkstr=[[
-1 open air
00000000
00000000
00000000
00000000
00000000
00000000
00000000

-2 shelf with loot
0000x000
0000t000
00xxxx00
000xx000
000?0000
00000000
00000000

-3 stair steps + grunt
000g0000
00x11x00
0?0xx000
011xx110
00x00x00
0x0000x0
00000000

-4 pillars + sentinel
000p0000
00111000
00100000
001xx1x0
001x0100
001x0100
0010x100

-5 spiked ledges
xxx00000
00000000
000001^1
00000010
001^1000
xx1111x0
00000000

-6 upper platform
00000000
00000000
00000000
00001111
00000000
00000000
00000000

-7 patrol ledge + loot
00000000
000p0000
01111000
00000000
000?0000
00011000
00000000

-8 floating coin column
0$000000
00000000
0$00xx00
00000000
0$00xx00
00000000
00000000

-9 crate pocket
00w00000
000xxx00
000x?x00
000xxx00
00000000
00000000
00000000

-10 loot shelf
00000000
00xxxxx0
00000000
000?0000
00111110
00xxxxx0
00000000

-11 offset walls
00010000
00010000
x0010000
x0000010
x00?0010
x00x0010
x00x0010

-12 spike pit platform
000W0000
00000000
00000000
00xxxx00
001^^100
01111110
00000000

-13 shop terminal
00000000
00000000
00000000
00111100
00000000
0000a000
11111111

-14 exit door
00000000
00000000
0000?000
00011100
00000000
0000e000
11111111
]]
chunks={}
local cur={}
for s in all(split(chunkstr,"\n",false)) do
 if #s==8 and sub(s,1,1)~="-" then
  add(cur,s)
  if #cur==7 then add(chunks,cur) cur={} end
 end
end
shopc=13 exitc=14

loot=split("$,$,$,$,h,0",",",false)

bosses=split"brute,hopper,sentry,flyer,crab,clone"
story_bosses=split"hopper,brute,crab,flyer,sentry"

themes={
}
for l in all(split([[
woods|1|32|7|1|104|105|107|139,c,131,f,132,f,170,f
forge|2|16|7||108|109|111|12,f,129,c,130,c,151,F,146,A
frostkeep|1|8|8||120|121|123|128,f,133,c
catacombs|1|0|7||16|14|13|144,f,129,c,130,c,131,f,149,f,136,f,33,w
abyss|0|24|9||124|125|127|140,e,136,f,145,f,144,f,153,f,154,f,131,f
]],"\n",false)) do
 local p=split(l,"|",false)
 if #p>3 then
  add(themes,{name=p[1],bg=tonum(p[2]),mus=tonum(p[3]),
   grass=tonum(p[5]),
   wt=tonum(p[6]),tt=tonum(p[7]),mt=tonum(p[8]),
   dec=#p[9]>0 and split(p[9]) or nil})
 end
end

function cur_theme()
 local i=flr((floor-1)/3)
 if story then i=min(i,4) end
 return themes[i%#themes+1]
end

function play_theme()
 local m=cur_theme().mus
 if m~=cur_mus then
  cur_mus=m
  music(m)
 end
end

function _init()
 title=true
 sel=1
 story=false
 sintro=false
 shopping=false
 ending=nil
 t=0
 money=0
 gameover=false
 floor=1
 intro_t=70
 shake=0
 hitstop=0
 last_boss=nil
 relics={}
 beaten={}
 seen={}
 guard_used=false
 msg_t=0
 msg_s=""
 bullets={}
 entities={}
 player={x=24,y=8,dx=0,dy=0,w=6,h=6,facing=1,grounded=false,
  st="fall",t=0,hp=3,hp_max=3,lives=3,inv=0,wpn=1,cd=0,swap_cd=0,
  wdir=0,hitw=0,dash_t=0,dax=1,day=0}
 dash_id=0
 gen_floor()
 load_room()
 drop_spawn()
 music(40) cur_mus=40
end

function safezone()
 for e in all(entities) do
  if e.bp.hostile and not e.bp.big and not e.bp.boss
   and abs(e.x-player.x)<18 and abs(e.y-player.y)<18 then
   del(entities,e)
  end
 end
end

function drop_spawn()
 local p=player
 p.x,p.y=25,18
 for tx in all(split"3,4,5,10,11,12,2,13,6,9") do
  if mget(tx,2)==0 and mget(tx,3)==0 then
   p.x,p.y=tx*8+1,18
   break
  end
 end
 p.dx=0 p.dy=0 p.st="fall" p.inv=45
 spawn={x=p.x,y=p.y}
 safezone()
end

function gk(x,y) return x+y*8 end

function irnd() return flr(rnd(12))+1 end

function tq() return flr(rnd(11))+2 end

function pick4() return {tq(),tq(),irnd(),irnd()} end

function pick3()
 local ids={}
 for i=1,#shop_pool do
  local it=shop_pool[i]
  if not (it.g=="relic" and relics[it.v]) then
   add(ids,i)
  end
 end
 local out={}
 for i=1,3 do
  add(out,shop_pool[del(ids,rnd(ids))])
 end
 return out
end

function show_msg(s)
 msg_s=s
 msg_t=90
end

function gen_floor()
 claimed={}
 rooms_g={}
 cx,cy=4,4
 guard_used=false
 if floor%3==0 or (story and floor==16) then
  local list={}
  local b
  if story then
   b=floor==16 and "clone" or story_bosses[floor/3]
  else
   local un={}
   for k in all(bosses) do
    if not seen[k] then add(un,k) end
   end
   if #un==0 then
    seen={}
    for k in all(bosses) do add(un,k) end
   end
   repeat b=rnd(un) until b~=last_boss or #un==1
   seen[b]=true
   last_boss=b
  end
  add(list,b)
  rooms_g[gk(4,4)]={c={6,1,1,1},kind="boss",bosses=list}
  return
 end
 rooms_g[gk(4,4)]={c=pick4(),kind="start"}
 rooms_g[gk(5,4)]={c=pick4(),kind="fight"}
 local x,y,lx,ly=5,4,5,4
 for i=1,3+min(floor,5) do
  local d=flr(rnd(4))
  x=mid(0,x+(d==0 and 1 or d==1 and -1 or 0),7)
  y=mid(0,y+(d==2 and 1 or d==3 and -1 or 0),7)
  if not rooms_g[gk(x,y)] then
   rooms_g[gk(x,y)]={c=pick4(),kind="fight"}
   lx,ly=x,y
  end
 end
 local er=rooms_g[gk(lx,ly)]
 er.kind="exit" er.c[4]=exitc er.mc=9
 for k,r in pairs(rooms_g) do
  if r.kind=="fight" and rnd()<0.35 then
   r.kind="shop"
   r.c[3]=shopc r.mc=12
   break
  end
 end
 local cap=flr(flr((floor-1)/3)/2)
 local bl={}
 for k in pairs(beaten) do add(bl,k) end
 local fr={}
 for k,r in pairs(rooms_g) do
  if r.kind=="fight" then add(fr,r) end
 end
 for i=1,cap do
  if #fr>0 and #bl>0 and rnd()<0.5 then
   local r=del(fr,rnd(fr))
   r.roamer=rnd(bl)
   r.c={6,1,1,1}
  end
 end
end

function door(dx,dy)
 local nx,ny=cx+dx,cy+dy
 return nx>=0 and nx<8 and ny>=0 and ny<8
  and rooms_g[gk(nx,ny)]
end

function carve(x1,y1,x2,y2)
 for x=x1,x2 do
  for y=y1,y2 do mset(x,y,0) end
 end
end

function wtile()
 local th=cur_theme()
 return rnd()<0.15 and th.mt
  or rnd()<0.06 and th.tt or th.wt
end

function load_room()
 cur_room=rooms_g[gk(cx,cy)]
 cur_room.vis=true
 entities={} bullets={} blocks={} booms={}
 local safe=cur_room.kind=="start" or cur_room.kind=="shop"
 for q=0,3 do
  local cdef=chunks[cur_room.c[q+1]]
  local qx,qy=(q%2)*8,1+flr(q/2)*7
  for r=0,6 do
   local row=cdef[r+1]
   for c=0,7 do
    local tx,ty=qx+c,qy+r
    local ch=sub(row,c+1,c+1)
    if ch=="?" then ch=rnd(loot) end
    local lg=legend[ch]
    mset(tx,ty,0)
    if lg then
     if lg.t then
      mset(tx,ty,lg.t==16 and wtile() or lg.t)
     else
      local bp=entity_types[lg.e]
      local uid=floor.."_"..gk(cx,cy).."_"..tx.."_"..ty
      if not claimed[uid] and not (safe and bp.dmg) then
       local e=spawn_entity(lg.e,tx*8,ty*8,lg.v)
       e.uid=uid
      end
     end
    end
   end
  end
 end
 local gr=cur_theme().grass
 for i=0,15 do
  mset(i,1,gr and 175 or wtile())
  mset(i,14,gr and 174 or wtile())
  if i>1 and i<14 then
   mset(0,i,wtile()) mset(15,i,wtile())
  end
 end
 if door(-1,0) then carve(0,11,2,13) end
 if door(1,0) then carve(13,11,15,13) end
 if door(0,1) then carve(7,13,8,14) end
 if door(0,-1) then carve(7,1,8,3) end
 for e in all(entities) do
  if is_solid(e.x+e.w/2,e.y+e.h/2) then del(entities,e) end
 end
 if cur_room.kind=="boss" then
  if cur_room.done then
   mset(7,13,10)
  else
   spawn_entity(cur_room.bosses[1],92,24)
  end
 end
 if cur_room.roamer then
  local uid=floor.."_"..gk(cx,cy).."_rb"
  if not claimed[uid] then
   local e=spawn_entity(cur_room.roamer,52,24)
   e.uid=uid
   place_open(e)
  end
 end
 if cur_room.big==nil then
  local n=count_hostiles()
  cur_room.big=n>=4
  cur_room.lock=cur_room.roamer~=nil
   or cur_room.big and cur_room.kind~="boss"
   and rnd()<min(0.6+(n-4)*0.15,0.95)
 end
 big_room=cur_room.big
 locked=false doors={} exit_spot=nil
 if cur_room.lock and count_hostiles()>0 then
  locked=true
  seal(0,11,0,13) seal(15,11,15,13)
  seal(7,1,8,1) seal(7,14,8,14)
  for ty=1,14 do
   for tx=0,15 do
    if mget(tx,ty)==10 then
     exit_spot={tx,ty}
     mset(tx,ty,0)
    end
   end
  end
 end
 anims={}
 local th=cur_theme()
 local dc=th.dec
 if dc then
  for i=1,20 do
   local j=1+flr(rnd(#dc/2))*2
   local sp,k=dc[j],dc[j+1]
   local tx,ty=1+flr(rnd(14)),2+flr(rnd(12))
   local c,bl,ab=mget(tx,ty),mget(tx,ty+1),mget(tx,ty-1)
   local sb=fget(bl,0) and bl~=9
   local sa=fget(ab,0) and ab~=9
   if k=="e" then
    if c==th.wt then
     mset(tx,ty,sp)
     add(anims,{tx,ty,sp,sp+16,false,true,1})
    end
   elseif c==0 and not occ(tx,ty) then
    if k=="f" and sb or k=="c" and sa then
     mset(tx,ty,sp)
    elseif k=="F" and sb or k=="A" then
     add(anims,{tx,ty,sp,sp+1})
    elseif k=="w" and sa then
     if fget(mget(tx-1,ty),0) then
      add(anims,{tx,ty,sp,sp})
     elseif fget(mget(tx+1,ty),0) then
      add(anims,{tx,ty,sp,sp,true})
     end
    end
   end
  end
 end
 for x=0,15 do
  for y=1,14 do
   local m=mget(x,y)
   if m==th.tt then add(anims,{x,y,m,m+1,false,false,1}) end
   if m==10 then add(anims,{x,y,10,11}) end
  end
 end
end

function seal(x1,y1,x2,y2)
 for x=x1,x2 do
  for y=y1,y2 do
   if mget(x,y)==0 then
    mset(x,y,17)
    add(doors,{x,y})
   end
  end
 end
end

function occ(tx,ty)
 for e in all(entities) do
  if e.x<tx*8+8 and e.x+e.w>tx*8
   and e.y<ty*8+8 and e.y+e.h>ty*8 then
   return true
  end
 end
end

function place_open(e)
 for i=1,60 do
  local tx,ty=1+flr(rnd(13)),2+flr(rnd(10))
  if not is_solid(tx*8+4,ty*8+4)
   and not is_solid(tx*8+12,ty*8+12) then
   e.x=tx*8+1 e.y=ty*8+1
   return
  end
 end
end

dirs={{1,0},{0,1},{-1,0},{0,-1}}
function crawl(e,spd)
 e.cd=e.cd or 1
 if not (is_solid(e.x+e.w/2,e.y+e.h+1)
  or is_solid(e.x+e.w/2,e.y-1)
  or is_solid(e.x-1,e.y+e.h/2)
  or is_solid(e.x+e.w+1,e.y+e.h/2)) then
  e.y+=1.5
  return
 end
 local dv=dirs[e.cd]
 local sv=dirs[e.cd%4+1]
 local nx,ny=e.x+dv[1]*spd,e.y+dv[2]*spd
 local fx=nx+(dv[1]>0 and e.w or dv[1]<0 and -1 or e.w/2)
 local fy=ny+(dv[2]>0 and e.h or dv[2]<0 and -1 or e.h/2)
 if is_solid(fx,fy) then
  e.cd=(e.cd+2)%4+1
 else
  e.x,e.y=nx,ny
  local sx=e.x+(sv[1]>0 and e.w or sv[1]<0 and -1 or e.w/2)
  local sy=e.y+(sv[2]>0 and e.h or sv[2]<0 and -1 or e.h/2)
  if not is_solid(sx,sy) then
   e.cd=e.cd%4+1
   e.x+=sv[1]*2 e.y+=sv[2]*2
  end
 end
 if dv[1]~=0 then e.dir=dv[1] end
end

function break_block(tx,ty)
 mset(tx,ty,0)
 sfx(10)
 if rnd()<(relics.gr and 0.3 or 0.15) then
  local lg=legend[rnd(loot)]
  if lg and lg.e then
   spawn_entity(lg.e,tx*8,ty*8,lg.v)
  end
 end
end

function drop_special(x,y)
 local r=flr(rnd(3))
 if r==0 then
  spawn_entity("heart",x,y)
 elseif r==1 then
  spawn_entity("bounty",x,y)
 else
  local rl={}
  for it in all(shop_pool) do
   if it.g=="relic" and not relics[it.v] then add(rl,it) end
  end
  if #rl>0 then
   local it=rnd(rl)
   local e=spawn_entity("relic",x,y)
   e.v=it.v e.lbl=it.lbl e.sp=it.sp
  else
   spawn_entity("bounty",x,y)
  end
 end
end

function spawn_entity(name,px,py,v)
 local bp=entity_types[name]
 local e={
  bp=bp,v=v,kind=name,dir=1,dx=0,dy=0,hitw=0,flash=0,
  hp=bp.hp,w=bp.w,h=bp.h,
  x=px+(bp.ox or 0),y=py+(bp.oy or 0),
  sp=bp.sp,
 }
 if name=="wpn" then e.sp=weapons[v].gsp end
 if bp.hostile then
  e.hp+=flr((floor-1)/3)*((bp.big or bp.boss) and 4 or 1)
 end
 if bp.big or bp.boss then e.idle=60 end
 add(entities,e)
 return e
end

function count_hostiles()
 local n=0
 for e in all(entities) do
  if e.bp.hostile then n+=1 end
 end
 return n
end

function kill(e)
 if e.uid then claimed[e.uid]=true end
 del(entities,e)
end

touches={
 coin=function(e) money+=1 sfx(5) kill(e) end,
 heart=function(e)
  if player.hp<player.hp_max then
   player.hp+=1 sfx(6) kill(e)
  end
 end,
 wpn=function(e)
  if player.swap_cd>0 then return end
  local old=player.wpn
  player.wpn=e.v
  player.swap_cd=45
  player.cd=0
  spawn_entity("wpn",e.x,e.y,old)
  show_msg(weapons[player.wpn].name)
  kill(e)
  sfx(6)
 end,
 bounty=function(e) money+=50 sfx(6) kill(e) end,
 relic=function(e)
  relics[e.v]=true
  show_msg("got "..e.lbl)
  sfx(6)
  kill(e)
 end,
 term=function(e)
  if btnp(2) then
   shopping=true
   ssel=0
   cur_room.items=cur_room.items or pick3()
  end
 end,
}

function can_buy(it)
 return it.cost<=money
  and not (it.g=="relic" and relics[it.v])
  and not (it.g=="wpn" and player.wpn==it.v)
  and not (it.g=="heal" and player.hp>=player.hp_max)
  and (it.g~="maxhp" or player.hp_max<8)
end

function buy(it)
 if not can_buy(it) then sfx(9) return end
 money-=it.cost
 if it.g=="maxhp" then player.hp_max+=1 player.hp=player.hp_max
 elseif it.g=="life" then player.lives+=1
 elseif it.g=="heal" then player.hp=player.hp_max
 elseif it.g=="wpn" then player.wpn=it.v
 elseif it.g=="relic" then
  relics[it.v]=true
  show_msg("got "..it.lbl)
 end
 sfx(8)
end

function _update60()
 t+=1
 if title then
  if btnp(2) or btnp(3) then sel=3-sel end
  if btnp(4) or btnp(5) then
   title=false
   story=sel==1
   sintro=story
   if not story then play_theme() end
  end
  return
 end
 if sintro then
  if btnp(4) or btnp(5) then sintro=false play_theme() end
  return
 end
 if ending then
  ending+=1
  if ending>240 and btnp(5) then _init() end
  return
 end
 if intro_t>0 then
  intro_t-=1
  return
 end
 if gameover then
  if btnp(5) then _init() end
  return
 end
 if shopping then
  if btnp(2) then ssel=(ssel+2)%3 end
  if btnp(3) then ssel=(ssel+1)%3 end
  if btnp(4) then buy(cur_room.items[ssel+1]) end
  if btnp(5) then shopping=false end
  return
 end
 if hitstop>0 then
  hitstop-=1
  return
 end
 shake*=0.85
 if shake<0.3 then shake=0 end
 if msg_t>0 then msg_t-=1 end
 update_player()
 update_bullets()
 update_entities()
 check_transition()
 if cur_room.kind=="boss" and not cur_room.done
  and count_hostiles()==0 then
  cur_room.done=true
  if story and floor==16 then
   ending=-60
   music(40) cur_mus=40
  else
   mset(7,13,10)
   add(anims,{7,13,10,11})
  end
  sfx(7)
 end
 if locked and count_hostiles()==0 then
  locked=false
  for d in all(doors) do mset(d[1],d[2],0) end
  if exit_spot then
   mset(exit_spot[1],exit_spot[2],10)
   add(anims,{exit_spot[1],exit_spot[2],10,11})
  end
  sfx(7)
 end
end

function update_player()
 local p=player
 p.t+=1
 if p.inv>0 then p.inv-=1 end
 if p.cd>0 then p.cd-=1 end
 if p.swap_cd>0 then p.swap_cd-=1 end

 if btn(0) then p.dx-=accel p.facing=-1 end
 if btn(1) then p.dx+=accel p.facing=1 end

 if btnp(5) then
  if p.grounded then
   p.dy=jumpf
   sfx(0)
  elseif p.st=="cling" then
   p.dy=jumpf
   p.dx=-p.wdir*1.9
   p.facing=-p.wdir
   p.st="jump"
   sfx(0)
  elseif relics.aj and p.airj then
   p.dy=jumpf
   p.airj=false
   sfx(0)
  end
 end

 p.dy=min(p.dy+grav,4)
 p.dx*=fric
 if abs(p.dx)<0.05 then p.dx=0 end
 if p.dash_t>0 then
  p.dash_t-=1
  p.dx=p.dax*3.2
  p.dy=p.day*3.2
  local cx,cy=p.x+3+p.dax*5,p.y+3+p.day*5
  if mget(flr(cx/8),flr(cy/8))==9 then
   break_block(flr(cx/8),flr(cy/8))
  end
 end
 p.grounded=false
 p.hitw=0
 move_obj(p)

 if p.grounded then
  p.airj=true
  p.st=abs(p.dx)>0.2 and "walk" or "idle"
 else
  local push=(p.hitw==1 and btn(1)) or (p.hitw==-1 and btn(0))
  if p.hitw~=0 and p.dy>0 and push then
   p.st="cling" p.wdir=p.hitw p.dy=min(p.dy,0.4)
  elseif p.dy<0 then p.st="jump"
  else p.st="fall" end
 end

 local w=weapons[p.wpn]
 if w.wave then
  if btn(4) then
   p.hold=(p.hold or 0)+1
  elseif p.hold then
   if p.cd<=0 then
    if p.hold>=15 then dash() else fire() end
   end
   p.hold=nil
  end
 elseif btn(4) and p.cd<=0 then
  fire()
 end
end

function dash()
 local p=player
 local ax,ay=get_aim()
 p.dax,p.day=ax,ay
 if ax~=0 then p.facing=ax end
 p.dash_t=12
 p.inv=max(p.inv,20)
 dash_id+=1
 p.cd=20
 sfx(0)
end

function get_aim()
 if btn(2) then return 0,-1 end
 if btn(3) then return 0,1 end
 if btn(0) then return -1,0 end
 if btn(1) then return 1,0 end
 return player.facing,0
end

function fire()
 local w=weapons[player.wpn]
 local ax,ay=get_aim()
 local dmg=w.dmg+(relics.sh and 1 or 0)
 local k=w.kick*(relics.rk and 1.3 or 1)
 local n=w.n or 1
 local px,py=player.x+3,player.y+2
 local bx,by=px+ax*6,py+ay*6
 if is_solid(bx,by) then bx,by=px,py end
 for i=1,n do
  local o=(i-(n+1)/2)*0.8
  add(bullets,{x=bx,y=by,ox=bx,oy=by,
   dx=ax*w.spd-ay*o,dy=ay*w.spd+ax*o,
   dmg=dmg,col=w.col,boom=w.boom,pierce=w.pierce,
   beam=w.beam,hom=w.hom,sp=w.bsp,fuse=w.fuse,
   wave=w.wave,grav=w.grav})
 end
 player.dx-=ax*k*0.6
 if ay>0 then player.dy=-k
 elseif ay<0 then player.dy+=k*0.3 end
 player.cd=w.rate*(relics.qd and 0.8 or 1)
 sfx(1)
end

function hurt_player(d,src)
 local p=player
 if p.inv>0 or gameover then return end
 if relics.gd and not guard_used then
  guard_used=true
  p.inv=90
  show_msg("ward!")
  sfx(4)
  return
 end
 if relics.th and src.bp and src.bp.hostile then
  hit_ent(src,2)
 end
 p.hp-=d
 p.inv=90
 hitstop=6
 p.dx=sgn(p.x+3-(src.x+src.w/2))*2
 p.dy=-1.8
 sfx(4)
 if p.hp<=0 then die() end
end

function die()
 local p=player
 p.lives-=1
 if p.lives<0 then
  gameover=true
  return
 end
 p.hp=p.hp_max
 load_room()
 p.x=spawn.x p.y=spawn.y
 p.dx=0 p.dy=0 p.inv=90 p.st="idle"
 safezone()
end

function next_floor()
 floor+=1
 intro_t=70
 gen_floor()
 load_room()
 drop_spawn()
 play_theme()
end

function enter(px,py)
 load_room()
 if px then player.x=px end
 if py then player.y=py end
 player.inv=45
 spawn={x=player.x,y=player.y}
 safezone()
end

function check_transition()
 local p=player
 if btnp(2) and mget(flr((p.x+3)/8),flr((p.y+3)/8))==10 then
  next_floor()
  return
 end
 if p.x>122 then
  cx+=1 enter(8,nil)
 elseif p.x<0 then
  cx-=1 enter(114,nil)
 elseif p.y>112 then
  cy+=1 enter(nil,10)
 elseif p.y<8 then
  cy-=1 enter(nil,104)
  p.dy=jumpf
 end
end

function update_bullets()
 for b in all(bullets) do
  if b.hom then
   local tx,ty=hom_target(b)
   if tx then
    local a=atan2(tx-b.x,ty-b.y)
    b.dx+=(cos(a)*1.5-b.dx)*0.1
    b.dy+=(sin(a)*1.5-b.dy)*0.1
   end
  end
  if b.grav then b.dy+=0.15 end
  b.x+=b.dx b.y+=b.dy
  local dead=false
  if b.fuse then
   b.fuse-=1
   if b.fuse<=0 then
    if b.boom then explode(b) end
    dead=true
   end
  end
  if b.wave and not dead then
   for o in all(bullets) do
    if o.foe~=b.foe and not o.wave
     and abs(o.x-b.x)<7 and abs(o.y-b.y)<7 then
     o.foe=b.foe
     o.dx=-o.dx o.dy=-o.dy
     o.col=7
     o.ox=o.x o.oy=o.y
    end
   end
  end
  if dead then
  elseif b.x<-4 or b.x>132 or b.y<-4 or b.y>132 then
   dead=true
  elseif is_solid(b.x,b.y) then
   local tx,ty=flr(b.x/8),flr(b.y/8)
   if mget(tx,ty)==9 and b.pierce then
    break_block(tx,ty)
   else
    if mget(tx,ty)==9 and not b.boom then
     local k=tx+ty*16
     blocks[k]=(blocks[k] or 2)-b.dmg
     if blocks[k]<=0 then
      break_block(tx,ty)
     else
      sfx(2)
     end
    end
    if b.boom then explode(b) end
    dead=true
   end
  elseif hit_skull(b) then
   if b.boom then explode(b) end
   dead=not b.pierce
  elseif b.foe then
   if player.inv<=0
    and b.x>player.x-1 and b.x<player.x+player.w+1
    and b.y>player.y-1 and b.y<player.y+player.h+1 then
    if b.boom then
     explode(b)
     dead=true
    else
     hurt_player(b.dmg,{x=b.x-3,w=6})
     dead=not b.pierce
    end
   end
  else
   for e in all(entities) do
    if e.bp.hostile and e.hb~=b
     and b.x>e.x-1 and b.x<e.x+e.w+1
     and b.y>e.y-1 and b.y<e.y+e.h+1 then
     if b.boom then
      explode(b)
      dead=true
      break
     end
     hit_ent(e,b.dmg)
     e.hb=b
     if not b.pierce then
      dead=true
      break
     end
    end
   end
  end
  if dead then del(bullets,b) end
 end
 for b in all(booms) do
  b.t+=1
  if b.t>10 then del(booms,b) end
 end
end

function hit_ent(e,d)
 e.hp-=d
 e.flash=6
 hitstop=4
 if e.hp<=0 then
  if e.bp.big or e.bp.boss then
   spawn_entity("bounty",e.x+4,e.y+4)
   if e.bp.drop then
    spawn_entity("wpn",e.x-4,e.y+4,e.bp.drop)
   end
   beaten[e.kind]=true
  elseif relics.gr or rnd()<0.3 then
   spawn_entity("coin",e.x-1,e.y-1)
  end
  kill(e)
  sfx(3)
  if big_room and count_hostiles()==0 and e.y<120 then
   drop_special(e.x,e.y)
  end
 else
  sfx(2)
 end
end

function explode(b)
 local bx,by,src=b.x,b.y,b.src
 add(booms,{x=bx,y=by,t=0})
 shake=max(shake,5)
 sfx(11)
 for tx=flr(bx/8)-1,flr(bx/8)+1 do
  for ty=flr(by/8)-1,flr(by/8)+1 do
   if mget(tx,ty)==9 then break_block(tx,ty) end
  end
 end
 for e in all(entities) do
  if e.bp.hostile and e~=src
   and abs(e.x+e.w/2-bx)<14 and abs(e.y+e.h/2-by)<14 then
   hit_ent(e,3)
  end
 end
 if src and abs(player.x+3-bx)<12 and abs(player.y+3-by)<12 then
  hurt_player(1,{x=bx-3,w=6})
 end
end

function enemy_fire(e)
 local g=e.gun or e.bp.gun
 local s=g.spd or 1.5
 local ax,ay=cos(e.aim),sin(e.aim)
 local bx,by=e.x+e.w/2,e.y+e.h/2
 local n=g.n or 1
 for i=1,n do
  local o=(i-(n+1)/2)*0.8
  add(bullets,{x=bx,y=by,ox=bx,oy=by,
   dx=ax*s-ay*o,
   dy=ay*s+ax*o-(g.grav and 1.5 or 0),
   dmg=1,col=g.boom and 9 or 14,foe=true,src=e,
   boom=g.boom,beam=g.beam,pierce=g.pierce,
   hom=g.hom,sp=g.bsp,fuse=g.fuse,
   wave=g.wave,grav=g.grav})
 end
 sfx(12,3)
end

function hit_skull(b)
 for o in all(bullets) do
  if o.sp and o.foe~=b.foe
   and abs(o.x-b.x)<5 and abs(o.y-b.y)<5 then
   explode(o)
   del(bullets,o)
   return true
  end
 end
end

function hom_target(b)
 if b.foe then return player.x+3,player.y+3 end
 local bd,tx,ty=32767
 for e in all(entities) do
  if e.bp.hostile then
   local d=abs(e.x-b.x)+abs(e.y-b.y)
   if d<bd then bd,tx,ty=d,e.x+e.w/2,e.y+e.h/2 end
  end
 end
 return tx,ty
end

function warp(e)
 for i=1,30 do
  local tx,ty=1+flr(rnd(14)),2+flr(rnd(12))
  if not is_solid(tx*8+4,ty*8+4) then
   e.wx,e.wy=tx*8+1,ty*8+1
   e.warp_t=30
   return
  end
 end
end

function update_entities()
 for e in all(entities) do
  local bp=e.bp
  if e.flash>0 then e.flash-=1 end
  if relics.mg and bp.touch=="coin" then
   e.x+=(player.x-e.x)*0.05
   e.y+=(player.y-e.y)*0.05
  end
  if bp.ai=="fly" then
   e.dir=player.x>e.x and 1 or -1
   if not (e.chg and e.chg<30) then
    e.ft=(e.ft or 0)-1
    if e.ft<=0 then
     local a=rnd()
     e.tx=mid(10,player.x+cos(a)*55,104)
     e.ty=mid(10,player.y+sin(a)*55,100)
     e.ft=50
    end
    if abs(e.tx-e.x)+abs(e.ty-e.y)>2 then
     local a=atan2(e.tx-e.x,e.ty-e.y)
     local nx,ny=e.x+cos(a)*bp.spd,e.y+sin(a)*bp.spd
     if is_solid(nx+e.w/2,ny+e.h/2) then
      e.ft=0
     else
      e.x,e.y=nx,ny
     end
    end
   end
  elseif bp.ai=="crawl" then
   crawl(e,bp.spd)
  elseif bp.ai and bp.ai~="warp" then
   local pdx=player.x+3-e.x-e.w/2
   if bp.ai=="chase" then
    if abs(pdx)>4 then e.dir=sgn(pdx) end
   end
   if e.kind=="clone" then
    e.ph=(e.ph or 240)-1
    if e.ph<=0 then e.ph=240 end
    if e.ph>=90 then
     if not e.rgun then
      local w=weapons[player.wpn]
      if w.wave then w=weapons[1] end
      e.rgun={rate=80,spd=w.spd,n=w.n,boom=w.boom,
       beam=w.beam,pierce=w.pierce,hom=w.hom,
       bsp=w.bsp,fuse=w.fuse,grav=w.grav}
     end
     e.gun=e.rgun
    else
     e.gun=nil
    end
   end
   local spd=bp.spd
   if e.idle and e.idle>0 then
    e.idle-=1
    spd=0
    e.hop=30
   end
   if bp.ai=="hop" then
    e.hop=(e.hop or 30)-1
    if e.grounded then
     spd=0
     if e.hop<=0 then
      e.dy=-3.4
      e.dir=player.x>e.x and 1 or -1
      if e.gun then e.dir=-e.dir end
      e.hop=75
     end
    end
   end
   e.dx=spd*e.dir
   e.dy=min(e.dy+grav,4)
   if e.dsh_t and e.dsh_t>0 then
    e.dsh_t-=1
    e.dx=cos(e.aim)*3.4
    e.dy=sin(e.aim)*3.4
   end
   e.hitw=0
   e.grounded=false
   move_obj(e)
   if e.hitw~=0 then e.dir=-e.hitw end
   if bp.ai=="patrol" and e.grounded then
    local ahead=e.dir>0 and e.x+e.w+1 or e.x-2
    if not is_solid(ahead,e.y+e.h+2) then e.dir=-e.dir end
   end
   if e.x<2 then e.x=2 e.dir=1
   elseif e.x+e.w>126 then e.x=126-e.w e.dir=-1 end
   if e.y>112 then kill(e) end
  end
  if bp.gun then
   local g=e.gun or bp.gun
   e.chg=(e.chg or g.rate)-1
   if e.chg==24 then
    e.aim=atan2(player.x+3-e.x-e.w/2,player.y+3-e.y-e.h/2)
   end
   if e.chg<=0 then
    if e.kind=="clone" and not e.gun and rnd()<0.5 then
     e.dsh_t=14
     sfx(0)
    else
     enemy_fire(e)
    end
    e.chg=g.rate
    if bp.ai=="warp" then warp(e) end
   end
  end
  if e.warp_t then
   e.warp_t-=1
   if e.warp_t<=0 then
    e.x,e.y=e.wx,e.wy
    e.warp_t=nil
   end
  end
  if e.kind=="spike" then
   for o in all(entities) do
    if o.bp.hostile and overlap(e,o) then
     o.stick=(o.stick or 0)-1
     if o.stick<=0 then
      o.stick=30
      hit_ent(o,1)
     end
    end
   end
  end
  if overlap(e,player) then
   if player.dash_t>0 and bp.hostile then
    if e.dsh~=dash_id then
     e.dsh=dash_id
     hit_ent(e,3)
    end
   elseif bp.dmg then
    hurt_player(bp.dmg,e)
   end
   if bp.touch then touches[bp.touch](e) end
  end
 end
end

function move_obj(o)
 o.x+=o.dx
 if o.dx>0 and (is_solid(o.x+o.w,o.y) or is_solid(o.x+o.w,o.y+o.h-1)) then
  o.x=flr((o.x+o.w)/8)*8-o.w o.dx=0 o.hitw=1
 elseif o.dx<0 and (is_solid(o.x,o.y) or is_solid(o.x,o.y+o.h-1)) then
  o.x=flr(o.x/8)*8+8 o.dx=0 o.hitw=-1
 end
 o.y+=o.dy
 if o.dy>0 and (is_solid(o.x,o.y+o.h) or is_solid(o.x+o.w-1,o.y+o.h)) then
  o.y=flr((o.y+o.h)/8)*8-o.h o.dy=0 o.grounded=true
 elseif o.dy<0 and (is_solid(o.x,o.y) or is_solid(o.x+o.w-1,o.y)) then
  o.y=flr(o.y/8)*8+8 o.dy=0
 end
end

function is_solid(px,py)
 return fget(mget(flr(px/8),flr(py/8)),0)
end

function overlap(a,b)
 return a.x<b.x+b.w and a.x+a.w>b.x
  and a.y<b.y+b.h and a.y+a.h>b.y
end

function _draw()
 if title then
  cls(0)
  sspr(0,48,64,16,0,20,128,32)
  print("story",54,70,sel==1 and 7 or 5)
  print("endless",50,80,sel==2 and 7 or 5)
  return
 end
 if sintro then
  cls(0)
  sspr(16,96,32,32,32,24,64,64)
  print("press x to descend",30,104,6)
  return
 end
 if ending and ending>=0 then
  cls(0)
  local wt=themes[max(1,5-flr(ending/120))].wt
  for x in all(split"0,1,2,13,14,15") do
   for y=-1,16 do
    spr(wt,x*8,y*8+(ending*2)%8)
   end
  end
  for x=6,9 do spr(wt,x*8,80) end
  spr(1,54,72)
  spr(198,66,72)
  if ending>240 and t%30<20 then
   print("thanks for playing\n     press x",28,106,7)
  end
  return
 end
 local th=cur_theme()
 if intro_t>0 then
  cls(0)
  print("floor "..floor,52,54,7)
  print(th.name,64-#th.name*2,64,6)
  if floor%3==0 then
   print("boss floor!",44,74,8)
  end
  return
 end
 cls(th.bg)
 camera(rnd(2*shake)-shake,rnd(2*shake)-shake)
 map(0,1,0,8,16,14)
 if story and floor==16 then
  spr(192,56,88,2,2)
 end
 for a in all(anims) do
  if a[7] then palt(0,false) end
  spr((a[6] and t%120<100 or t%16<8) and a[3] or a[4],
   a[1]*8,a[2]*8,1,1,a[5])
  palt()
 end
 for e in all(entities) do
  local bp=e.bp
  local sp=e.sp
  if bp.sp2 then
   if bp.airanim then
    if not e.grounded then sp=bp.sp2 end
   elseif flr(t/8)%2==1 then
    sp=bp.sp2
   end
  end
  if e.flash>0 then
   for c=1,15 do pal(c,7) end
  end
  local sz=bp.big and 2 or 1
  spr(sp,e.x+(bp.dox or 0),e.y+(bp.doy or 0),sz,sz,e.dir==-1)
  pal()
  if e.chg and e.chg<24 then
   circ(e.x+e.w/2,e.y-4,(24-e.chg)/8,
    e.chg%4<2 and 7 or ((e.gun or bp.gun).boom and 9 or 8))
  end
  if e.warp_t then
   rect(e.wx-1,e.wy-1,e.wx+e.w,e.wy+e.h,
    t%4<2 and 7 or e.sp==31 and 9 or 14)
  end
  if bp.touch=="term" then
   if overlap(e,player) and t%16<8 then print(chr(148),e.x,e.y-9,7) end
  end
 end
 for b in all(bullets) do
  if b.beam then
   line(b.ox,b.oy,b.x,b.y,b.col)
  end
  if b.wave then
   if b.dx~=0 then
    local s=sgn(b.dx)
    line(b.x-s,b.y-4,b.x+s*2,b.y-1,7)
    line(b.x+s*2,b.y-1,b.x+s*2,b.y+1,7)
    line(b.x+s*2,b.y+1,b.x-s,b.y+4,7)
   else
    local s=sgn(b.dy)
    line(b.x-4,b.y-s,b.x-1,b.y+s*2,7)
    line(b.x-1,b.y+s*2,b.x+1,b.y+s*2,7)
    line(b.x+1,b.y+s*2,b.x+4,b.y-s,7)
   end
  end
  if b.sp then
   spr(b.sp,b.x-4,b.y-4,1,1,b.dx<0)
  else
   circfill(b.x,b.y,b.boom and 2 or 1,b.col)
  end
 end
 for b in all(booms) do
  circfill(b.x,b.y,b.t+2,({7,10,9,8,2})[min(b.t\2+1,5)])
 end
 draw_player()
 camera()
 draw_hud()
 if floor==1 and not gameover then
  print("aim down + shoot to fly up",13,120,7)
 end
 if shopping then
  rectfill(4,40,123,89,0)
  rect(4,40,123,89,7)
  print("shop",10,43,7)
  for i=1,3 do
   local it=cur_room.items[i]
   print((i==ssel+1 and ">" or " ")..it.lbl.." $"..it.cost,
    10,43+i*9,can_buy(it) and 7 or 5)
  end
  print(cur_room.items[ssel+1].desc,10,80,6)
 end
 if gameover then
  rectfill(20,48,107,78,0)
  print("game over",46,53,8)
  print("you reached floor "..floor,28,61,7)
  print("press x to restart",28,69,6)
 end
end

function draw_player()
 local p=player
 if p.inv>0 and p.inv%6>=3 then return end
 local sp,flip=1,p.facing==-1
 if p.st=="walk" then sp=1+flr(p.t/6)%2
 elseif p.st=="jump" then sp=3
 elseif p.st=="fall" then sp=4
 elseif p.st=="cling" then sp=5 flip=p.wdir==-1
 end
 if p.dash_t>0 then sp=7+flr(p.t/2)%2 end
 spr(sp,p.x-1,p.y-2,1,1,flip)
 local ax,ay=get_aim()
 local w=weapons[p.wpn]
 if ay==0 then
  spr(w.gsp,p.x-1+ax*6,p.y-1,1,1,ax<0)
 else
  spr(w.vsp,p.x-1,p.y-2+ay*7,1,1,false,ay>0)
 end
 if p.hold and p.hold>=15 then
  circ(p.x+3,p.y-5,1,7)
 end
 if mget((p.x+3)\8,(p.y+3)\8)==10 and t%16<8 then
  print(chr(148),p.x,p.y-10,7)
 end
end

function draw_hud()
 rectfill(0,0,127,7,0)
 rectfill(0,120,127,127,0)
 for i=1,player.hp_max do
  if i>player.hp then pal(8,2) end
  spr(20,(i-1)*7,0)
  pal()
 end
 print("x"..player.lives,player.hp_max*7+2,1,7)
 print("$"..money,97,1,7)
 for k,r in pairs(rooms_g) do
  pset(119+k%8,k\8,r.vis and (r.mc or 2) or 5)
 end
 pset(119+cx,cy,t%8<4 and 7 or 5)
 local rx=1
 for it in all(shop_pool) do
  if it.g=="relic" and relics[it.v] then
   spr(it.sp,rx,120)
   rx+=8
  end
 end
 if msg_t>0 then
  print(msg_s,64-#msg_s*2,14,7)
 end
end