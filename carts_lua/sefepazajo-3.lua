--routedbg=true

tgpts={
 10,30,50,70,100,200,300,500
}

tginx={
 1,2,3,3,4,4,5,5,6,6,7,7,8
}

rdparams={
 {1.5,1.0,10}, --1
 {1.5,1.1,10}, --2
 {1.4,1.1,9}, --3
 {1.4,1.2,8}, --4
 {1.3,1.2,7}, --5
 {1.3,1.2,6}, --6
 {1.2,1.3,5}, --7
 {1.2,1.3,5}, --8
 {1.1,1.2,5}, --9
 {1.1,1.2,5}, --10
 {1.2,1.3,5}, --11
 {1.2,1.3,3}, --12
 {1.1,1.2,3}, --13
 {1.1,1.2,3}, --14
 {1.1,1.3,3}, --15
 {1.1,1.3,1}, --16
}

hi=500
sc=0
rd=0
remain=0
fruitat=0
halt=0
extend=0

powdotpos={}
objs={}

plyr=nil
mnsts={}
powdots={}
mnstpt=0
mnstspd=1.2
plyrspd=1.1
powmax=0

function gettginx(rd)
 return tginx[min(13,rd)]
end

obj={}

obj.new=function(x,y,u)
 local o={}
 o.x=x
 o.y=y
 o.state=nil
 o.cnt=0
 o.update=nullupdate
 o.chr=0
 o.str=nil
 o.col=nil
 o.unlink=false
 o.visible=true
 return o
end

function nullupdate(o)
end

state=nil
nextstate=nil
dotsttl=0
dots=0
n=0
pow=0

function setstate(ns)
 nextstate=ns
end

function updatestate()
 if state!=nextstate then
  state=nextstate
  n=0
 end
 
 if state=="title" then
  if btn(4) or btn(5) then
   gameinit1()
  end
 elseif state=="begin" then
  if n>2*30 then
   setstate("game")
   bgm(0)
  end
 elseif state=="game" then
  if halt>0 then
   halt-=1
   if halt==0 then
    plyr.visible=true
   end
   return
  end
  if dots==0 then
   bgm(2)
   setstate("clear")
  end
  if pow>0 then
   -- decrease power
   pow-=1
   if pow==0 then
    -- time's up
    for m in all(mnsts) do
     if m.state=="weak" then
      -- switch to normal
      m.state="normal"
     end
    end
    bgm(0)
   end
  end
  if extend>0 and sc>=extend then
   remain+=1
   extend=0
   sfx(6)
  end
 elseif state=="clear" then
  if n==1*30 then
   local x=plyr.x
   local y=plyr.y
   objs={}
   local p=obj.new()
   p.x=x
   p.y=y
   p.chr=42
   add(objs,p)
  elseif n>6*30 then
   -- next round
   rd+=1
   gameinit2(true)
  end
  
  --flash
  if n>=1*30 then
   if n%15==0 then
    local t=n-2*30
    local f=0

    if t%30==0 then
     f=1
    else
     f=2
    end

    for y=0,15 do
     for x=0,14 do
      local c=mget(32+x,y)
      if c>=96 and c<=112 then
       if f==2 then
        c+=16
       end
       mset(x,y,c)
      end
     end
    end   

   end
  end
 elseif state=="dead" then
  if n==30 then
   -- dead effect
   local px=plyr.x  
   local py=plyr.y
  
   objs={}
   local e=obj.new()
   e.x=px
   e.y=py
   e.update=deadupdate
   add(objs,e)
  elseif n==58 then
   sfx(4)
  elseif n>5*30 then
   remain-=1
   if remain==0 then
    objs={}
    bgm(3)
    setstate("gameover")
   else
    gameinit2(false)
   end
  end
 elseif state=="gameover" then
  if n>5*30 then
   if hi<sc then
    hi=sc
   end
   setstate("title")
  end
 end 
end

function isstate(st)
 return state==st
end

bgmno=nil
function bgm(n)
 if bgmno!=n then
  music(n)
  bgmno=n
 end
end 

function isthru(x,y,isdoor)
 if isdoor then
   -- oneway
   if x==7 and y==6 then
    return true
   end
 end

 if x>=0 and x<=14 then
  local c=mget(x,y)
  return not (c>=96 and c<=128)
 end

 if y==7 then 
  -- tunnel
  return true 
 else
  return false
 end
end

function reversedir(d)
 if d==1 then 
  return 2
 elseif d==2 then 
  return 1
 elseif d==3 then 
  return 4
 else 
  return 3
 end  
end

--p=8,9
function plyrupdate(p)
 if not isstate("game") then 
  return 
 end

 if halt>0 then
  return
 end

 plyrfwd(p)
 plyrchk(p)
 
 for m in all(mnsts) do
  if m.state=="normal" or m.state=="weak" then
   local ax=abs(p.x-m.x)
   local ay=abs(p.y-m.y)
   if ax<3 and ay<3 then
    if m.state=="normal" then
     setstate("dead")
     bgm(-1)
    else
     m.state="dead"
     m.cnt=0
     m.pass={{7*8,7*8}}
     sfx(2)
     sc+=mnstpt
     addpoint(p.x,p.y,mnstpt*10,12)
     mnstpt*=2
     halt=60
     p.visible=false
     break
    end  
   end
  end
 end
end

function plyrfwd(p)
 local move=false
	local rem=0

 if p.fwd then
  local nn=(n/2)%2
 
  if p.dir==1 then
   p.chr=32+nn
   p.y-=plyrspd
   if p.y<=p.ny then
    rem=p.ny-p.y
    move=true
   end
  elseif p.dir==2 then
   p.chr=34+nn
   p.y+=plyrspd
   if p.y>=p.ny then
    rem=p.y-p.ny
    move=true
   end
  elseif p.dir==3 then
   p.chr=36+nn
   p.x-=plyrspd
 	 if p.x<=-8 then
	 		-- warp to right
	   p.x+=16*8
	   p.nx=16*8
   end
   if p.x<=p.nx then
    rem=p.nx-p.x
    move=true
   end
  elseif p.dir==4 then
   p.chr=38+nn
   p.x+=plyrspd
   if p.x>=15*8 then
	 		-- warp to right
	   p.x-=16*8
	   p.nx=0
   end

   if p.x>=p.nx then
    rem=p.x-p.nx
    move=true
   end
  end
 else
  move=true
 end
 
 if move then
  p.x=p.nx
  p.y=p.ny

  local cx=p.x/8
  local cy=p.y/8

  local thru={
   isthru(cx,cy-1), 
   isthru(cx,cy+1),
   isthru(cx-1,cy), 
   isthru(cx+1,cy)
  }

  local newdir=p.dir
  if btn(2) then
   if thru[1] then
    newdir=1
   end
  elseif btn(3) then
   if thru[2] then
    newdir=2
   end
  elseif btn(0) then
   if thru[3] then
    newdir=3
   end
  elseif btn(1) then
   if thru[4] then 
    newdir=4
   end
  end

  p.fwd=false
  if newdir==1 then
   if thru[1] then
    p.y-=rem
    p.ny-=8
    p.dir=1
    p.fwd=true
   end
  elseif newdir==2 then
   if thru[2] then
    p.y+=rem
    p.ny+=8
    p.dir=2
    p.fwd=true
   end
  elseif newdir==3 then
   if thru[3] then
    p.x-=rem
    p.nx-=8
    p.dir=3
    p.fwd=true
   end
  elseif newdir==4 then
   if thru[4] then
    p.x+=rem
    p.nx+=8
    p.dir=4
    p.fwd=true
   end
  end
 end
end

function plyrchk(p)
 local cx=flr((p.x+4)/8)
 local cy=flr((p.y+4)/8)

 local eat=0
 local ch=mget(cx,cy)
 if ch==16 then
  eat=1
  sc+=1
 elseif ch==17 then
  eat=2
  sc+=5
  pow=powmax
  mnstpt=20
  bgm(1)

  -- switch monster state
  for m in all(mnsts) do
   if m.state=="normal" or m.state=="weak" then
    if m.norev then
     --
    else
     m.dir=reversedir(m.dir)
     if m.dir==1 then
      m.ny-=8
     elseif m.dir==2 then
      m.ny+=8
     elseif m.dir==3 then
      m.nx-=8
     else
      m.nx+=8     
     end     
    end
    m.state="weak"
   end
  end

  local key=cx+cy*100
  local pd=powdots[key]
  pd.unlink=true
  powdots[key]=nil
 end

 if eat>0 then
  mset(cx,cy,0)
  sfx(1)
  dots-=1
  if fruitat>0 and fruitat>=dots then
   -- fruit target
   local f=obj.new()
   f.x=7*8
   f.y=9*8
   f.chr=19+gettginx(rd)	
   f.update=fruitupdate
   fruitat-=30
   add(objs,f)
  end
 end
end

function judge(m,di,d,thru,ds)
 pt={0,0,0,0}

 -- can't move reverse 
 local rv=reversedir(di)
 thru[rv]=false

 local ax=abs(d.x)
 local ay=abs(d.y)

 local expry=nil
 local exprx=nil
 
 -- runaway at weak mode
 if m.state!="weak" then
  --normal
  condy=d.y<0
  condx=d.x<0
 else
  -- weak
  condy=d.y>0
  condx=d.x>0
 end 

 if d.y==0 then 
  --
 elseif condy then
  pt[1]=ay
 else
  pt[2]=ay
 end

 if d.x==0 then 
  --
 elseif condx then
  pt[3]=ax
 else
  pt[4]=ax
 end

 -- choice route by distance
 local p=-1
 local ix=0
 for i=1,4 do
  if thru[i] then
   if pt[i]>p then
    p=pt[i]
    ix=i
   end
  end
 end

 return ix
end

function mnstcalc(m)
 m.x=m.nx
 m.y=m.ny

 local downdoor=false
 if m.state=="dead" then
  downdoor=true
 end
 
 local cx=flr(m.x/8)
 local cy=flr(m.y/8)
 local thru={
  isthru(cx,cy-1,true), 
  isthru(cx,cy+1,downdoor),
  isthru(cx-1,cy), 
  isthru(cx+1,cy)
 }
 
 local tx,ty
 if #m.pass==0 then
  tx=plyr.x
  ty=plyr.y
 else
  tx=m.pass[1][1]
  ty=m.pass[1][2]
 end
 
 local d={
  x=tx-m.x,
  y=ty-m.y
 }
 m.dir=judge(m,m.dir,d,thru)
 if m.dir==1 then
  m.ny-=8
 elseif m.dir==2 then
  m.ny+=8
 elseif m.dir==3 then
  m.nx-=8
 elseif m.dir==4 then
  m.nx+=8
 end

 if #m.pass>0 then
  local p=m.pass[1]
  if m.nx==p[1] and m.ny==p[2] then
   del(m.pass,p)
   
   if p[3] then
    -- cancel reverse cancel
    m.norev=false
   end
  end
 end    
end

function mnstsetchr(m,nn)
	if m.state=="normal" then
	 m.chr=m.bchr+nn
	elseif m.state=="weak" then
  if pow>60 then
   m.chr=56+nn
  else
   if pow%30<15 then
    m.chr=56+nn
   else
    m.chr=58+nn
   end
  end
	end
end

function mnstupdate(m)
 if not isstate("game") then 
  return 
 end

 local nn=0
 if halt==0 then
	 nn=flr(n/4)%2
	end

 if m.wait>0 then
  m.wait-=1
  mnstsetchr(m,nn)
  return
 end

 local spd=mnstspd
 local docalc=false
 local rem=0

 if m.state=="dead" then
  m.chr=62+nn
  spd=3

  if #m.pass==0 then
   -- back to lair
   if halt>0 then
    -- toriaezu kesu...
    m.chr=1
    return
   end

   m.x=7*8
   m.y=7*8
   m.nx=m.x
   m.ny=m.y-8
   m.pass={}
   add(m.pass,{7*8,5*8,true})
   m.norev=true
   m.dir=1
   m.chr=m.bchr
   m.state="normal"
   m.wait=5*30
   m.cnt=0
   return
  end
 else 
  if halt>0 then
   return
  end
 end

 if m.y==7*8 then
  if m.x<24 or m.x>120-24 then
   spd*=0.7
  end
 end
 
 if m.dir==1 then
	 m.y-=spd
	 if m.ny>=m.y then
   rem=m.ny-m.y
	  docalc=true
	 end
	elseif m.dir==2 then
	 m.y+=spd
	 if m.ny<=m.y then
   rem=m.y-m.ny
	  docalc=true
	 end
	elseif m.dir==3 then
	 m.x-=spd
	 if m.x<=-8 then
	  m.x+=16*8
	  m.nx=16*8
	 end
	 if m.nx>=m.x then
   rem=m.nx-m.x
	  docalc=true
	 end
	elseif m.dir==4 then
	 m.x+=spd
	 if m.x>=15*8 then
	  m.x-=16*8
	  m.nx=0
	 end
	 if m.nx<=m.x then
   rem=m.x-m.nx
	  docalc=true
	 end
	end

 if docalc then
  mnstcalc(m)
  
  if m.dir==1 then
   m.y-=rem
  elseif m.dir==2 then
   m.y+=rem
  elseif m.dir==3 then
   m.x-=rem
  elseif m.dir==4 then
   m.x+=rem
  end
 end

 mnstsetchr(m,nn)
end

deadptn={
 33,35,37,39,
 33,35,37,39,
 33,35,37,39,
 33,35,37,39,
 40,40,41,41
} 
 
function deadupdate(p)
 local c=1+flr(p.cnt/2)
 p.chr=deadptn[c]
 p.cnt+=1
 if p.cnt==1 then
  sfx(3)
 elseif p.cnt>=40 then
  p.unlink=true
 end
end  

function fruitupdate(f)
 if abs(plyr.x-f.x)<2 and abs(plyr.y-f.y)<2 then
  f.unlink=true
  local p=tgpts[gettginx(rd)]
  sc+=p
  addpoint(plyr.x,plyr.y,p*10)
  sfx(5)
  return
 end

 f.cnt+=1
 if f.cnt>=30*10 then
  f.unlink=true
 end
end

function addpoint(x,y,v,col)
 local p=obj.new()
 p.chr=nil
 p.str=""..v
 p.x=x+4-#p.str*2
 p.y=y+2
 p.col=col
 p.update=pointupdate
 add(objs,p)
end

function pointupdate(p)
 p.cnt+=1
 if p.cnt>=60 then
  p.unlink=true
 end
end

powdottbl={17,18,19,18}

function powdotupdate(p)
 p.cnt=(p.cnt+1)%12
 p.chr=powdottbl[1+flr(p.cnt/3)]
end 

function _update()
 updatestate()

 if isstate("title") then
  if btn(5) or btn(6) then
   gameinit1()
  end
 end

 dels={}

 for o in all(objs) do
  o:update()
  if o.unlink then
   -- add to delete list
   add(dels,o)
  end  
 end

 -- do delete
 for d in all(dels) do
  del(objs,d)
 end

 n=(n+1)%(30*60)
end

function titledraw()
 color(8)
 cursor(0,0)
 print "1p"
 cursor(64,0)
 print "high score"
 drawscore(0,8,sc,{8,0})
 drawscore(64,8,hi,{8,0})

 color(10)
 cursor(40,32)
 print("patch-mon") 

 color(7)
 cursor(32,80)
 if n%30>5 then
  print("press 🅾️ button") 
 end

 color(12)
 cursor(20,112)  
 print("programmed by @shulgee") 
end

function _draw()
 cls()
 
 if isstate("title") then
  titledraw()
  return
 end
 
 map(0,0,0,0,16,16)

 if routedbg then
  local y=0
  for o in all(mnsts) do
   rectfill(o.nx,o.ny,o.nx+7,o.ny+7,8)

   cursor(0,y)
   color(7)
   print(o.norev)
   y+=8
  end
  rectfill(plyr.nx,plyr.ny,plyr.nx+7,plyr.ny+7,8)

 end

	-- sprites
 for o in all(objs) do
  if o.visible then
   if o.chr!=nil then
    spr(o.chr,o.x,o.y)
   end
   if o.str!=nil then
    cursor(o.x,o.y)
    local col=7
    if o.col!=nil then
     col=o.col
    end
    color(col)
    print(o.str)
   end
  end
 end
 rectfill(120,56,128,64,0)

 if state=="begin" then
  -- ready
  for i=0,5 do
   spr(80+i,36+i*8,88)
  end
 elseif state=="gameover" then 
  -- gameover
  for i=0,8 do
   spr(86+i,24+i*8,72)
  end
 end

 -- score- 
 if n%30>15 then 
  color(8)
  cursor(120,0)
  print("1p")
 end

 drawscore(120,8,sc,{0,8})

 -- round
 local r=0
 local len=0
 if rd<=6 then
  -- round 1-6
  r=1
  len=rd-1
 else
  -- round 7-
  r=rd-5
  len=5
 end

 for i=0,len do 
  spr(19+gettginx(r+i),120,56+i*8)
 end
 
 -- remain
 for i=1,remain-1 do
  spr(37,120,128-i*8)
 end
 
end

function drawscore(x,y,s0,d)
 local s="----"..s0..0
 local head=#s-6
 for i=0,6 do
  local l=head+i+1
  local c=sub(s,l,l)
  if c>="0" and c<="9" then	
   spr(64+c,x+i*d[1],y+i*d[2])
  end
 end
end

function gameinit1()
 sc=0
 remain=3
 rd=1
 extend=1000
 
 gameinit2(true)
end

mnstdata={
 {t=0,x=7,y=5,d=3,fp={1,1}},
 {t=60,x=6,y=7,d=4,fp={13,1}},
 {t=120,x=7,y=7,d=1,fp={1,14}},
 {t=180,x=8,y=7,d=3,fp={13,14}}
}

function mnstinit()
 mnsts={}
 for i=0,3 do
  local d=mnstdata[i+1]
  local m=obj.new()
  m.update=mnstupdate
  m.x=d.x*8
  m.y=d.y*8
  m.nx=m.x
  m.ny=m.y
  m.chr=48+i*2
  m.bchr=m.chr
  m.dir=d.d
  m.wait=d.t
  m.state="normal"
  m.pass={}
		-- to go first
  if i>=1 then
   add(m.pass,{7*8,5*8,true})
   m.norev=true
   else
   m.norev=false
  end
  add(m.pass,{d.fp[1]*8,d.fp[2]*8})

  add(objs,m)
  add(mnsts,m)
 end
end

function gameinit2(set)
 objs={}

	--copy ura to omote
 if set then
  for y=0,15 do
   for x=0,15 do
    mset(x,y,mget(32+x,y))
   end
  end
  dots=dotsttl
  fruitat=dotsttl-30
  local para=rdparams[min(16,rd)]
  plyrspd=para[1]
  mnstspd=para[2]
  powmax=para[3]*30
 end

 -- power dot
	powdots={}
 for p in all(powdotpos) do
  local x=p[1]
  local y=p[2]
  if mget(x,y)==17 then
   -- powdot exists
   local pd=obj.new()
   pd.update=powdotupdate
   pd.x=x*8
   pd.y=y*8
   add(objs,pd)
   powdots[x+y*100]=pd
  end  
 end 

 -- player
 local p=obj.new()
 p.update=plyrupdate
 p.x=7*8
 p.y=9*8
 p.nx=p.x
 p.ny=p.y
 p.dir=3
 p.fwd=true
 p.chr=37
 add(objs,p)
 plyr=p

 --monster
 mnstinit()
 
 setstate("begin")
end

function _init()
 --copy omote to ura 
 for y=0,15 do
  for x=0,15 do
   local c=mget(x,y)
   mset(32+x,y,c)
   if c==16 then
    dotsttl+=1
   elseif c==17 then 
    dotsttl+=1
    add(powdotpos,{x,y})    
   end
  end
 end

 setstate("title")
end