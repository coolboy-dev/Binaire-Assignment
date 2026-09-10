--?"c !5f1000▒⬇️3⬅️;⌂77⌂;⬅️3⬇️▒"

count=0

btn4=0
btn5=0
trg4=0
trg5=0

stars={}
obj={}

bar1={}
bar2={}
bar3={}

updatefunc=nil
drawfunc=nil
corfunc=nil
switchfunc=nil

clscol=0
wp=16 
wcnt=0
wy=14
uwy=0
wstate=0
wlen=0

scene=0 
sceneend=0
sceneendsoon=false
scenefunc=nil

x=8
y=56
dsx=1
sx=0
stsx=0
fuel=256

function _init()
 for i=1,4 do
  local ss={}
  for j=1,20 do
   local s0={
    x=rnd()*127,
    y=24+rnd()*104,
    c=8+rnd()*5
   }
   ss[j]=s0
  end
  add(stars,ss)
 end
 
 pal(3,12)
 
 makebarrier()

	title()

-- start()
end

function _update()
 if corfunc then
  coresume(corfunc)
  if costatus(corfunc)=="dead" then
   corfunc=nil
  end
 end

 if switchfunc then
  switchfunc()
  switchfunc=nil
 end

 if count%180==0 then
  changepal(flr(count/180)%3)
 end
	
 count+=1

 local t=btn4
 btn4=btn(4)
 trg4=not t and btn4
 t=btn5
 btn5=btn(5)
 trg5=not t and btn5

 updatefunc()
end

function _draw()
 drawfunc()

 log.draw()
end

degtable=
{
 90,
 270,
 -1,
 180,
 135,
 225,
 -1,
 0,
 45,
 315,
}

function update0()
 if sx>=sceneend then
  setscene(scene+1)
 end

 sceneendsoon=(sx>=sceneend-64)
 scenefunc()

 fuel-=0.3

 if scene~=2 then
  if count%5==0 and count%50!=0 then
   sfx(0)
  end
 else
  if count%20==0 then
   sfx(4)
  end
 end  

 local k=0
 local de=-1
 if btn(2) then k+=1 end 
 if btn(3) then k+=2 end 
 if btn(0) then k+=4 end 
 if btn(1) then k+=8 end
 
 if k>=1 and k<=10 then
  de=degtable[k]
  if de>=0 then
   x+=cos(de/360)*2
   y+=sin(de/360)*2
   if x<0 then x=0 
   elseif x>96 then x=96
   end
   if y<14 then y=14 
   elseif y>120 then y=120
   end
  end
 end
 
 if trg4 then 
  local f={x=x+8,y=y+1,ho={2,2},hs={4,4}}
  add(fire, f)
  sfx(2)
--[[ 
--]]  
 end
 
 if trg5 and #bomb<2 then 
  local b={
   x=x+4,
   y=y+4,
   vx=2.5,
   vy=0,
   ho={2,2},
   hs={4,4},
   cnt=4,
   t=0
  }
  add(bomb, b)
  sfx(1)
 end

 for o in all(objs) do
  o:func()
  o.x-=dsx
  if o.x<-8 then
   o.del=true
  end
 end

 local p={x=x,y=y,ho={2,2},hs={12,4}}
 for o in all(objs) do
  if o.hit and ishit(p,o) then
   plyrdied()
   goto endplyrchk
  end
 end
 if sget(p.x+4,p.y+4)>=64 or sget(p.x+12,p.y+4)>=64 then
  plyrdied()
 end
 ::endplyrchk::

 for f in all(fire) do
  f.x+=4
  if f.x>=128 then
   del(fire,f)
   goto continue
  end
  if sget(f.x+4,f.y+4)>=64 then
   explode(f.x,f.y)
   del(fire,f)
   goto continue
  end

  for o in all(objs) do
   if checkhit(f,o) then
    del(fire,f)
    goto continue
   end
  end
  ::continue::
 end

 for b in all(bomb) do
  b.vx=max(b.vx-0.1,0)
  b.x+=b.vx
  b.t+=0.1
  b.vy=min(b.vy+.1,2)
  b.y+=b.vy
  if b.y>=128 then
   del(bomb,b)
   goto continue
  end
  
  if sget(b.x+4,b.y+4)>=64 then
   explode(b.x,b.y)
   del(bomb,b)
   goto continue
  end
 
  for o in all(objs) do
   if checkhit(b,o) then
    del(bomb,b)
    goto continue
   end
  end
  ::continue::
 end

 for o in all(objs) do
  if o.del then
   del(objs,o)
  end
 end

 sx+=dsx
end

function update1()
 if count%7==0 then
  sfx(5)
  sfx(6)
 end

 for o in all(objs) do
  o:func()
 end

 for o in all(objs) do
  if o.del then
   del(objs,o)
  end
 end
end

function update2()
 if count%8==0 then
  pal(13,intrnd2(8,12))
 end

 if count%16==0 then
  sfx(5)
  sfx(6)
  pal(13,intrnd2(8,12))
 end

 for o in all(objs) do
  o:func()
 end

 for o in all(objs) do
  if o.del then
   del(objs,o)
  end
 end
end

press=false

function update3()
 if press then
  return
 end

 if trg4 or trg5 then
  press=true
  corfunc=cocreate(function()
   music(0) 
   for i=0,90 do
    yield()
   end
   
   game()
  end)
 end

 for o in all(objs) do
  o:func()
 end

 for o in all(objs) do
  if o.del then
   del(objs,o)
  end
 end
end

function draw0()
 cls(clscol)

 if scene==2 or scene==5 then
  --
 else
  drawstar()
 end

 if nil then
  spr(1+(flr(count/3)%2)*16,x,y,2,1)
-- spr(3+(count/4)%3,x-5,y+3)
 else
  spr(23+(flr(count/6)%2)*2,x,y,2,2)
  spr(3+(count/4)%3,x-7,y+1)
 end

-- spr(6,x+5,y-4)

 local s=flr(sx)
 s=s%256
 local mx=-s
 if mx<-128 then 
  mx+=256 
 end
 map(0,0,mx,0,16,16)
 mx+=128
 if mx>128 
  then mx-=256 
 end
 map(16,0,mx,0,16,16)

 for f in all(fire) do
  spr(6,f.x,f.y)
 end

 local bp
 if (count%6)>3 then
  bp=7
 else
  bp=10
 end 
 for b in all(bomb) do
  local t0=b.t
  if t0>=2 then t0=2 end
  spr(bp+t0,b.x,b.y)
 end

 for o in all(objs) do
  local ch=o.chr
  if type(ch)=="number" then
   spr(ch,o.x,o.y,o.h,o.v)
  elseif type(ch)=="string" then
   print(ch,o.x,o.y,10)
  end
 end

 rectfill(0,121,128,128,1)
 print("fuel",8,122,10)

 local fx=92*fuel/256

 for i=0,92 do
  local x=26+i
  local c=is(i%2==0,8,9)
  c=is(i<=fx,c,2)
  line(x,122,x,126,c)
 end

 local area={
 "1st","2nd","3rd","4th","5th","base"
 }
 rect(1,0,127,12,10)
 line(1,6,127,6,10)
 for i=0,5 do
  local x=1+21*i
  line(x,0,x,12,10)
  print(area[i+1],3+21*i,1,8)
  local col=is(i+1<=scene,8,2)
  rectfill(x+1,7,x+20,11,col)
 end
end

function draw1()
 for o in all(objs) do
  spr(o.chr,o.x,o.y,o.h,o.v)
 end

 spr(100,56,40,2,2)
 local color={10,12,14}
 local c=color[(count%3)+1]
	local t="congratulations!"
 print(t,33-1,64,1)
 print(t,33+1,64,1)
 print(t,33,64-1,1)
 print(t,33,64+1,1)
 print(t,33,64,c)
end

function draw3()
 cls()
 drawstar()

 if press then
  print("start",52,56,7)
  return
 end

 if count<120 then
  local s 
  if count<30 then
   s=1+(1+sin(count/30*0.25))*4
  else
   s=1
   print("presents",48,68)
  end
 
  local h=64*s
  local v=16*s
  sspr(48,32,64,16,64-h/2,56-v/2,h,v)
 else
  print("play",52,32,10)
  print("- pico-ramble -",32,48,12)
  print("how far can you invade",16,64,8)
  print("our scramble system ?",20,72)   
  if count%30<20 then
   print("press 🅾️ or ❘",34,88,7)
  end
 end 

 for o in all(objs) do


--  spr(o.chr,o.x,o.y,o.h,o.v)
 end
end

-->8
log={
 add=function(t)
  add(log.texts,t)
  if #log.texts>16 then
   del(log.texts,log.texts[1])
  end
 end, 
 draw=function()
  local y=0
  for t in all(log.texts) do
   print(t,1,y+1,1)
   print(t,0,y,7)
   y+=6
  end
 end,
 texts={}
}

function is(c,a,b)
 if c then
  return a
 end
 return b
end

function intrnd(r)
 return flr(rnd(r+1))
end

function intrnd2(a,b)
 return a+flr(rnd(b+1-a))
end

function sign(a,b)
 if b>a then return 1 end
 if b<a then return -1 end
 return 0
end

function switch(func)
 switchfunc=func
end

-->8
function drawstar()
 local c=flr(count/20)%4+1
 for i=1,4 do
  if c~=i then
   for ss in all(stars[i]) do
    pset(ss.x,ss.y,ss.c)
   end
  end
 end
end

function restart(sc)
 clscol=0
 wp=16 
 wcnt=0
 wy=14
 uwy=0
 wstate=0
 wlen=0

 count=0
 x=8
 y=56
 dsx=1
 sx=0
 stsx=0
 fuel=256
 
 fire={}
 bomb={}
 objs={}

	setscene(sc)

 for wp=0,15 do
  local c=0
  for y=0,15 do
   if y==14 then 
    c=65
   elseif y==15 then
    c=81
   end
   mset(wp,y,c)
  end
 end
end

function start()
 restart(1)
end


obj.new=function(x,y,c)
 local o={}
 o.x=x
 o.y=y
 o.h=1
 o.v=1
 o.dur=1
 o.cnt=0
 o.chr=c
 o.func=function() end
 o.delfunc=function() end
 o.hit=false
 o.ho={2,2}
 o.hs={4,4}
 o.del=false
 return o
end

pals={
{12,8,14,10},
{11,12,10,13},
{9,14,7,15},
}

function changepal(p)
 local p=pals[p+1]
 local p0=12
 for pp in all(p) do
  pal(p0,pp)
  p0+=1
 end
end

function ishit(o,p)
 local v0=o.x+o.ho[1] 
 local v1=p.x+p.ho[1] 
 local v2=is(v0<v1,o.hs[1],p.hs[1])
 if abs(v0-v1)>=v2 then
  return false
 end
 v0=o.y+o.ho[2] 
 v1=p.y+p.ho[2] 
 v2=is(v0<v1,o.hs[2],p.hs[2])
 if abs(v0-v1)>=v2 then
  return false
 end
 return true
end

function checkdel(o)
 if o.chr==34 then
  fuel=min(256,fuel+32)
 elseif o.chr==35 then
  local p=obj.new()
  p.x,p.y=o.x-2,o.y+1
  local pt=intrnd2(1,3)
  p.chr=""..pt*100
  p.func=ptsupdate
  add(objs,p)
 end 
end

function checkhit(a,o)
 if not o.del and o.hit and o.dur>0 and ishit(o,a) then
  o.dur-=1
  if o.dur<=0 then
   o.del=true
   checkdel(o)
   explode(o.x,o.y)
   o:delfunc()
  else
   explode(a.x,a.y)
  end
  return true
 end
 return false
end

function sget(x,y)
 local xx=((x+sx)/8)%32
 local yy=(y/8)
 return mget(xx,yy)
end

function makebarrier()
 local x=7
 local y=6
 add(bar1,{x,y})
 y-=1
 add(bar1,{x,y})
 y-=1
 add(bar1,{x,y})
 y-=1
 add(bar1,{x,y})
 y-=1
 add(bar1,{x,y})
 x+=1
 add(bar1,{x,y})
 x+=1
 add(bar1,{x,y})
 x+=1
 add(bar1,{x,y})
 x+=1
 add(bar1,{x,y})
 x+=1
 add(bar1,{x,y})
 x+=1
 add(bar1,{x,y})
 x+=1
 add(bar1,{x,y})
 y+=1
 add(bar1,{x,y})
 y+=1
 add(bar1,{x,y})
 y+=1
 add(bar1,{x,y})
 y+=1
 add(bar1,{x,y})
 
 x=13
 y=6
 add(bar2,{x,y})
 y-=1
 add(bar2,{x,y})
 y-=1
 add(bar2,{x,y})
 y-=1
 add(bar2,{x,y})
 x-=1
 add(bar2,{x,y})
 x-=1
 add(bar2,{x,y})
 x-=1
 add(bar2,{x,y})
 x-=1
 add(bar2,{x,y})
 x-=1
 add(bar2,{x,y})
 y+=1
 add(bar2,{x,y})
 y+=1
 add(bar2,{x,y})
 y+=1
 add(bar2,{x,y})

 x=9
 y=6
 add(bar3,{x,y})
 y-=1
 add(bar3,{x,y})
 y-=1
 add(bar3,{x,y})
 x+=1
 add(bar3,{x,y})
 x+=1
 add(bar3,{x,y})
 x+=1
 add(bar3,{x,y})
 y+=1
 add(bar3,{x,y})
 y+=1
 add(bar3,{x,y})
end

function explode(x,y)
 local e=obj.new()
 e.x=x
 e.y=y
 e.chr=50
 e.func=explodeupdate
 add(objs,e)
 sfx(3)
end

function plyrdied()
 fire={}
 bomb={}
 local e=obj.new()
 e.x=x
 e.y=y
 e.chr=102
 e.h=2
 e.v=1
 e.func=plexplodeupdate
 add(objs,e)

 corfunc=cocreate(function()
  updatefunc=update2
  x,y=128,128
  for i=0,60 do
   yield()
  end
  restart()
  updatefunc=update0
 end)
end

function title()
 switch(function()
 	updatefunc=update3
	 drawfunc=draw3
	end)
end

function game()
 switch(function()
  start()
 	updatefunc=update0
	 drawfunc=draw0
	end)
end
-->8
function setscene(sc)
 if sc~=nil then
  scene=sc 
 end
 
 sceneend=sx+3*128
 sceneendsoon=false
 wstate=0
 wcnt=0
 stsx=sx

 if sc==1 then
  scenefunc=scene1
  clscol=1
 elseif sc==2 then
  scenefunc=scene2
  clscol=0
 elseif sc==3 then
  scenefunc=scene3
  clscol=1
 elseif sc==4 then
  scenefunc=scene4
  clscol=1
 elseif sc==5 then
  scenefunc=scene5
  clscol=0
 elseif sc==6 then
  scenefunc=scene6
  sceneend=32767
  clscol=1
 end
 
end

function scene6()
 if dsx==0 then
  if wcnt%8==0 then 
   local o=obj.new(128,12+rnd(64),58)
   o.hit=true
   o.h=2
   o.dur=0
   o.func=fbupdate
   add(objs,o)
  end
 end

 if not istiming() then
  return
 end

 if dsx==0 then
  return
 end

 if sx>=stsx+128 then
  dsx=0
 end

 if wcnt==1 then
  local o=obj.new(128+80,40,96)
  o.hit=true
  o.ho={2,2}
  o.hs={12,12}
  o.h=2
  o.v=2
  o.func=baseupdate
  o.delfunc=basedel
  add(objs,o)

  for i=0,3 do
   o=obj.new(128+16+i*8,80,34)
   o.hit=true
   add(objs,o)
  end
  
  for i=1,16 do
   local b=bar1[i]
   local o=obj.new(128+b[1]*8,b[2]*8,13)
   o.hit=true
   o.dur=100
   o.index=i
   o.func=bar1update
   add(objs,o)
  end
  for i=1,12 do
   local b=bar2[i]
   local o=obj.new(128+b[1]*8,b[2]*8,13)
   o.hit=true
   o.dur=100
   o.index=i
   o.func=bar2update
   add(objs,o)
  end
  for i=1,8 do
   local b=bar3[i]
   local o=obj.new(128+b[1]*8,b[2]*8,13)
   o.hit=true
   o.dur=100
   o.index=i
   o.func=bar3update
   add(objs,o)
  end
 end
 
 for i=0,15 do
--  mset(wp,i,mget(16+wp,i))
  mset(wp,i,mget(32+wcnt/8,i))
 end
 
 wp=(wp+1)%32
end

function scene5()
 if not istiming() then 
  return
 end

 local wstep=flr((wcnt%16)/8)
 local chr=nil
 local func=nil

 if sceneendsoon then
  uwy=1
  wy=13
  goto label0
 end

 if wstep==0 then
  if wstate==0 then
   wstate=1
   uwy=3
   wy=6
   wlen=3
  elseif wstate==1 then

   wlen-=1
   if wlen==0 then
    local nwy=intrnd2(2,11)
    if uwy<nwy then
     wy=nwy+3
     wlen=2
     wstate=2
    else
     uwy=nwy
     wlen=2
     wstate=3
    end
   end
  elseif wstate==2 then
   wlen-=1
   if wlen==0 then
    uwy=wy-3
    wlen=intrnd2(1,3)
    wstate=1
   end
  elseif wstate==3 then
   wlen-=1
   if wlen==0 then
    wy=uwy+3
    wlen=intrnd2(1,3)
    wstate=1
   end
  end
 end  


 if wstate==1 then
  chr=34
 end

 if chr~=nil then
  local o=obj.new(128,wy*8-8,chr)
  o.hit=true
  if func~=nil then
   o.func=func
  end
  add(objs,o)
 end
 
 ::label0:: 
 
 for i=2,15 do
  if i==uwy or i==wy then
    mset(wp,i,83)
  elseif uwy<i and wy>i then
    mset(wp,i,0)
  else
    mset(wp,i,is(wstep==0,84,85))
  end
 end
 
 wp=(wp+1)%32
end

function scene4()
 if not istiming() then 
  return
 end
 
 local wstep=flr((wcnt%16)/8)

 if wstate==0 then
  if sceneendsoon then
   wstate=1
  end
  if wstep==0 then
   if wlen>0 then
    wlen-=1
   else
    wy=intrnd2(4,9)
    if rnd(1)>0.7 then
     wlen=intrnd2(3,5)
    end
   end
  end
 else 
  wy=8
 end
 
 local chr=nil
 local func=nil

 local r=flr(rnd(6))
 if r==0 then
  chr=34
 elseif r==1 then
  chr=35
 elseif r==2 or r==3 then
  chr=32
  func=missileupdate
 end

 if chr~=nil then
  local o=obj.new(128,wy*8-8,chr)
  o.hit=true
  if func~=nil then
   o.func=func
  end
  add(objs,o)
 end
 
 for i=2,15 do
  if i==wy then
    mset(wp,i,83)
  elseif i<wy then
    mset(wp,i,0)
  else
    mset(wp,i,is(wstep==0,84,85))
  end
 end
 
 wp=(wp+1)%32
end

function scene3()
 if wcnt%10==0 then 
  local o=obj.new(128,12+rnd(64),58)
  o.hit=true
  o.dur=0
  o.h=2
  o.func=fbupdate
  add(objs,o)
 end

 if not istiming() then 
  return
 end
 
 if wstate==0 then
  wm=-1
  if wy==12 then
   wstate=1
  end
 elseif wstate==1 then
  wm=flr(rnd(3))-1
 end

 if wy==11 and wm==-1 then
  wm=0
 elseif wy==14 and wm==1 then
  wm=0
 end

 if wm==1 then
  wc=66
 elseif wm==0 then
  wc=65
 elseif wm==-1 then
  wc=64
  wy-=1
 end
 
 local chr=nil
 local func=nil

 if wm==0 then
  local r=flr(rnd(4))
  if r==0 then
   chr=34
  elseif r==1 then
   chr=35
  else
   chr=32
  end
 end

 if chr~=nil then
  local o=obj.new(128,wy*8-8,chr)
  o.hit=true
  if func~=nil then
   o.func=func
  end
  add(objs,o)
 end
 
 for i=2,15 do
  if i==wy then
    mset(wp,i,wc)
  elseif i<wy then
    mset(wp,i,0)
  else
    mset(wp,i,81)
  end
 end

 wp=(wp+1)%32
 if wm==1 then
  wy+=1
 end

end

function scene2()
 local ufo=wcnt>60 and not sceneendsoon
 if ufo and wcnt%30==0 then 
  local o=obj.new(128,80,36)
  o.hit=true
  o.func=ufoupdate
  add(objs,o)
 end

 if not istiming() then 
  return
 end

 if wstate==0 then
  wm=sign(wy,12)
  uwm=sign(uwy,3)
  if wm==0 and uwm==0 then
   wstate=1
  end
 elseif wstate==1 then
  if sceneendsoon then
   wstate=2
  else
   wm=flr(rnd(3))-1
   uwm=flr(rnd(3))-1
  end
 elseif wstate==2 then
  wm=flr(rnd(3))-1
  uwm=-1
  wm=1
 end

 if wy==11 and wm==-1 then
  wm=0
 elseif wy==14 and wm==1 then
  wm=0
 end

 local uwymin=is(wstate==2,0,2)
 if uwy==uwymin and uwm==-1 then
  uwm=0
 elseif uwy==4 and uwm==1 then
  uwm=0
 end

 if wm==1 then
  wc=66
 elseif wm==0 then
  wc=65
 elseif wm==-1 then
  wc=64
  wy-=1
 end

 if uwm==1 then
  uwc=67
  uwy+=1
 elseif uwm==0 then
  uwc=68
 elseif uwm==-1 then
  uwc=69
 end
 
 local chr=nil
 if wm==0 then
  local r=flr(rnd(4))
  if r==0 then
   chr=34
  elseif r==1 then
   chr=35
  else
   chr=32
  end
 end

 if chr~=nil then
  local o=obj.new(128,wy*8-8,chr)
  o.hit=true
  add(objs,o)
 end
 
 for i=2,15 do
  if i==wy then
    mset(wp,i,wc)
  elseif i==uwy then
    mset(wp,i,uwc)
  elseif i<uwy then
    mset(wp,i,81)
  elseif i>wy then
    mset(wp,i,81)
  else
    mset(wp,i,0)
  end
 end

 wp=(wp+1)%32
 if wm==1 then
  wy+=1
 end
 if uwm==-1 then
  uwy-=1
 end

-- log.add(uwy..","..wy)
end

function istiming()
 local run=wcnt%8==0
 wcnt+=1
 return run
end

function scene1()
 if not istiming() then 
  return 
 end 
 
 if wstate==0 then
  wm=-1
  if wy==10 then
   wstate=1
  end
 elseif wstate==1 then
  wm=flr(rnd(3))-1
 end

 if wy==6 and wm==-1 then
  wm=0
 elseif wy==14 and wm==1 then
  wm=0
 end

 if wm==1 then
  wc=66
 elseif wm==0 then
  wc=65
 elseif wm==-1 then
  wc=64
  wy-=1
 end
 
 local chr=nil
 local func=nil

 if wm==0 then
  local r=flr(rnd(4))
  if r==0 then
   chr=34
  elseif r==1 then
   chr=35
  else
   chr=32
   func=missileupdate
  end
 end

 if chr~=nil then
  local o=obj.new(128,wy*8-8,chr)
  o.hit=true
  if func~=nil then
   o.func=func
  end
  add(objs,o)
 end
 
 for i=2,15 do
  if i==wy then
    mset(wp,i,wc)
  elseif i<wy then
    mset(wp,i,0)
  else
    mset(wp,i,81)
  end
 end

 wp=(wp+1)%32
 if wm==1 then
  wy+=1
 end
end


-->8
function plexplodeupdate(p)
 p.cnt+=1
 if p.cnt<20 then
  local pt=obj.new()
  pt.x,pt.y=p.x+4,p.y-2
  pt.vx=cos(rnd(1))
  pt.vy=sin(rnd(1))
  pt.func=ppartupdate
  add(objs,pt)
 elseif p.cnt>=5*30 then
  p.del=true
 end
 p.chr=102+(flr(p.cnt/5)%2)*2
end

function ppartupdate(p)
 p.cnt+=1
 p.x+=p.vx
 p.y+=p.vy
 p.vy+=0.03
 if p.cnt>=30 then
  p.del=true
 else
  p.chr=intrnd2(118,121)
 end
end

function explodeupdate(e)
 e.cnt+=1
 e.sc=1
 if e.cnt>=20 then
  e.del=true
 else
  e.chr=50+flr(e.cnt/4)
 end
end

function missileupdate(m)
 if m.cnt==0 then
  if m.x-x<32 then
   m.cnt=1
   m.v=2
  end
 elseif m.cnt>0 then
  m.cnt+=1
  m.y-=1+m.cnt/8
  m.chr=32+flr(m.cnt/2)%2
 end
end

function ufoupdate(u)
 u.cnt+=1
 u.y=60+sin(u.cnt/40)*18
 u.x+=sin((u.cnt+15)/20)*1
 u.chr=36+flr(u.cnt/10)%2
end

function ptsupdate(u)
 u.cnt+=1
 if u.cnt>=60 then
  u.del=true
 end
end

function fbupdate(u)
 u.cnt+=1
 u.x-=3
 u.chr=58+(flr(u.cnt/5)%3)*2
end

function baseupdate(u)
 u.cnt+=1
 u.chr=96+(flr(u.cnt/5)%2)*2
end

function basedel(u)
 updatefunc=update1
 drawfunc=draw1
 objs={}
 local o=obj.new(u.x+4,u.y+4,0)
 o.func=theendupdate
 add(objs,o)

 corfunc=cocreate(function()
  for i=0,120 do
   yield()
  end
  restart(1)
  updatefunc=update0
  drawfunc=draw0
 end)
end

function theendupdate(u)
 for i=0,1 do
  local o=obj.new(u.x,u.y,50+rnd(3))
  o.func=exupdate
  local r=rnd(1)
  local s=4+rnd(2)
  o.vx=cos(r)*s
  o.vy=sin(r)*s
  add(objs,o)
 end
end

function exupdate(u)
 u.x+=u.vx
 u.y+=u.vy
 if u.x<-8 or u.x>128 
  or u.y<-8 or u.y>128 then
  u.del=true
 end
end

function bar1update(u)
 u.cnt+=1
 if dsx==0 then
  if u.dur>10 then
   u.dur=2
  end
  local i=((u.index+flr(u.cnt/2))%16)+1
  u.x=bar1[i][1]*8
  u.y=bar1[i][2]*8
 end
 u.chr=19+(flr(u.cnt/3)%4)
end

function bar2update(u)
 u.cnt+=1
 if dsx==0 then
  if u.dur>10 then
   u.dur=2
  end
  local i=((u.index+flr(u.cnt/2))%12)+1
  u.x=bar2[i][1]*8
  u.y=bar2[i][2]*8
 end
 u.chr=19+((flr(u.cnt/3)+1)%4)
end

function bar3update(u)
 u.cnt+=1
 if dsx==0 then
  if u.dur>10 then
   u.dur=2
  end
  local i=((u.index+flr(u.cnt/2))%8)+1
  u.x=bar3[i][1]*8
  u.y=bar3[i][2]*8
 end
 u.chr=19+((flr(u.cnt/3)+2)%4)
end
