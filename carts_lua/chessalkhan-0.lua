pstr="404040404040404072727272727272724a4a545e5e544a4a45454a59594a45454040405454404040453b364040363b45454a4a2c2c4a4a4540404040404040400e1822222222180e182c404040402c1822404a4f4f4a402222454f54544f452222404f54544f402222454a4f4f4a4522182c404545402c180e1822222222180e2c3636363636362c36404040404040363640454a4a4540363645454a4a45453636404a4a4a4a4036364a4a4a4a4a4a3636454040404045362c3636363636362c4040404040404040454a4a4a4a4a4a453b4040404040403b3b4040404040403b3b4040404040403b3b4040404040403b3b4040404040403b40404045454040402c36363b3b36362c364040404040403636404545454540363b4045454545403b404045454545403b364545454545403636404540404040362c36363b3b36362c2218180e0e1818222218180e0e1818222218180e0e1818222218180e0e1818222c2222181822222c362c2c2c2c2c2c365454404040405454545e4a40404a5e54"
-- chess
-- by alkhan

nofs={-21,-19,-12,-8,8,12,19,21}
kofs={-10,10,-1,1,-11,-9,9,11}   -- first 4 rook dirs, last 4 bishop dirs

crm={}
uf={} ut={} ug={} uc={} ue={} ur={} up={} um={}

function clearb()
 b={}
 for s=21,98 do
  if (s-21)%10<8 then b[s]=0 end
 end
 for s=21,98 do crm[s]=15 end
 crm[91]=13 crm[98]=14 crm[95]=12
 crm[21]=7  crm[28]=11 crm[25]=3
 us=0 msc=0
end

function setup()
 clearb()
 local back={4,2,3,5,6,3,2,4}
 for f=0,7 do
  b[21+f]=-back[f+1]
  b[31+f]=-1
  b[81+f]=1
  b[91+f]=back[f+1]
 end
 side=1 ep=0 cr=15 kw=95 kb=25
 recalc()
end

-- attack detection

function attacked(s,by)
 if b[s+9*by]==by or b[s+11*by]==by then return true end
 for j=1,8 do
  if b[s+nofs[j]]==2*by then return true end
 end
 for j=1,8 do
  if b[s+kofs[j]]==6*by then return true end
 end
 for i=1,8 do
  local o=kofs[i]
  local x=s+o
  local q=b[x]
  while q==0 do
   x+=o q=b[x]
  end
  if q then
   q*=by
   if q==5 or (i<5 and q==4) or (i>4 and q==3) then return true end
  end
 end
 return false
end

function inchk(sd)
 return attacked(sd>0 and kw or kb,-sd)
end

-- move generation (pseudo legal)
-- move packed as two entries: f, t*8+g
-- g: 0 quiet/capture  1 double push  2 en passant  3 castle
--    4..7 promote to n,b,r,q

function addm(ml,f,t,g)
 local n=#ml
 ml[n+1]=f
 ml[n+2]=t*8+g
end

function addp(ml,f,t)
 local r=flr((t-21)/10)
 if r==0 or r==7 then
  for g=4,7 do addm(ml,f,t,g) end
 else
  addm(ml,f,t,0)
 end
end

function genpawn(ml,s)
 local d=-10*side
 local x=s+d
 if b[x]==0 then
  addp(ml,s,x)
  local sr=(side>0) and 81 or 31
  if s>=sr and s<=sr+7 and b[x+d]==0 then addm(ml,s,x+d,1) end
 end
 for c=-1,1,2 do
  local y=x+c
  local q=b[y]
  if q and q*side<0 then addp(ml,s,y) end
  if ep!=0 and y==ep then addm(ml,s,y,2) end
 end
end

function gencastle(ml)
 if side>0 then
  if (cr&1)>0 and b[96]==0 and b[97]==0
   and not attacked(95,-1) and not attacked(96,-1) then addm(ml,95,97,3) end
  if (cr&2)>0 and b[94]==0 and b[93]==0 and b[92]==0
   and not attacked(95,-1) and not attacked(94,-1) then addm(ml,95,93,3) end
 else
  if (cr&4)>0 and b[26]==0 and b[27]==0
   and not attacked(25,1) and not attacked(26,1) then addm(ml,25,27,3) end
  if (cr&8)>0 and b[24]==0 and b[23]==0 and b[22]==0
   and not attacked(25,1) and not attacked(24,1) then addm(ml,25,23,3) end
 end
end

function gen(ml)
 for s=21,98 do
  local p=b[s]
  if p and p*side>0 then
   local a=abs(p)
   if a==1 then
    genpawn(ml,s)
   elseif a==2 or a==6 then
    local of=(a==2) and nofs or kofs
    for j=1,8 do
     local x=s+of[j]
     local q=b[x]
     if q and q*side<=0 then addm(ml,s,x,0) end
    end
   else
    local lo,hi=1,8
    if a==4 then hi=4 elseif a==3 then lo=5 end
    for i=lo,hi do
     local o=kofs[i]
     local x=s+o
     local q=b[x]
     while q==0 do
      addm(ml,s,x,0)
      x+=o q=b[x]
     end
     if q and q*side<0 then addm(ml,s,x,0) end
    end
   end
  end
 end
 gencastle(ml)
end

-- make / unmake

function domove(f,t,g)
 local p=b[f]
 local cap=b[t]
 us+=1
 uf[us]=f ut[us]=t ug[us]=g
 uc[us]=cap ue[us]=ep ur[us]=cr up[us]=p um[us]=msc

 msc-=pval(p,f)
 b[f]=0
 ep=0

 if g==2 then
  local cs=t+10*side
  local vic=b[cs]
  uc[us]=vic
  msc-=pval(vic,cs)
  b[cs]=0
  b[t]=p
  msc+=pval(p,t)
 elseif g>=4 then
  if cap!=0 then msc-=pval(cap,t) end
  local np=(g-2)*side
  b[t]=np
  msc+=pval(np,t)
 else
  if cap!=0 then msc-=pval(cap,t) end
  b[t]=p
  msc+=pval(p,t)
  if g==1 then ep=(f+t)/2 end
  if g==3 then
   local rf,rt
   if t>f then rf=t+1 rt=t-1 else rf=t-2 rt=t+1 end
   local rk=b[rf]
   msc-=pval(rk,rf)
   b[rt]=rk b[rf]=0
   msc+=pval(rk,rt)
  end
 end

 if p==6 then kw=t elseif p==-6 then kb=t end
 cr=cr&crm[f]&crm[t]
 side=-side
end

function undomove()
 side=-side
 local f,t,g=uf[us],ut[us],ug[us]
 local p=up[us]
 b[f]=p
 if g==2 then
  b[t]=0
  b[t+10*side]=uc[us]
 else
  b[t]=uc[us]
  if g==3 then
   if t>f then b[t+1]=b[t-1] b[t-1]=0
   else b[t-2]=b[t+1] b[t+1]=0 end
  end
 end
 if p==6 then kw=f elseif p==-6 then kb=f end
 ep=ue[us] cr=ur[us] msc=um[us]
 us-=1
end

-- captures only, for quiescence search
function gencaps(ml)
 for s=21,98 do
  local p=b[s]
  if p and p*side>0 then
   local a=abs(p)
   if a==1 then
    local d=-10*side
    local x=s+d
    local r=flr((x-21)/10)
    local last=(r==0 or r==7)
    if last and b[x]==0 then addm(ml,s,x,7) end
    for c=-1,1,2 do
     local y=x+c
     local q=b[y]
     if q and q*side<0 then addm(ml,s,y,last and 7 or 0) end
     if ep!=0 and y==ep then addm(ml,s,y,2) end
    end
   elseif a==2 or a==6 then
    local of=(a==2) and nofs or kofs
    for j=1,8 do
     local x=s+of[j]
     local q=b[x]
     if q and q*side<0 then addm(ml,s,x,0) end
    end
   else
    local lo,hi=1,8
    if a==4 then hi=4 elseif a==3 then lo=5 end
    for i=lo,hi do
     local o=kofs[i]
     local x=s+o
     local q=b[x]
     while q==0 do x+=o q=b[x] end
     if q and q*side<0 then addm(ml,s,x,0) end
    end
   end
  end
 end
end

-- legal move list: flat f,tg pairs that survive the check test

function legal(ml)
 local raw={}
 gen(raw)
 local me=side
 for i=1,#raw,2 do
  local f,tg=raw[i],raw[i+1]
  local t,g=tg\8,tg%8
  domove(f,t,g)
  if not inchk(me) then addm(ml,f,t,g) end
  undomove()
 end
end

function perft(d)
 if d==0 then return 1 end
 local ml={}
 gen(ml)
 local n=0
 local me=side
 for i=1,#ml,2 do
  local f,tg=ml[i],ml[i+1]
  domove(f,tg\8,tg%8)
  if not inchk(me) then n+=perft(d-1) end
  undomove()
 end
 return n
end
-- evaluation + search

pv={100,320,330,500,900,0}
pst={}

function initpst()
 for t=1,6 do
  local q={}
  for i=1,64 do
   local k=((t-1)*64+i-1)*2+1
   q[i]=tonum("0x"..sub(pstr,k,k+1))-64
  end
  pst[t]=q
 end
end

-- signed material+placement value of one piece, white positive
function pval(p,s)
 local a=abs(p)
 local r=flr((s-21)/10)
 local f=(s-21)%10
 if p>0 then return pv[a]+pst[a][r*8+f+1] end
 return -(pv[a]+pst[a][(7-r)*8+f+1])
end

-- msc is kept up to date by domove/undomove; this rebuilds it
function recalc()
 msc=0
 for s=21,98 do
  local p=b[s]
  if p and p!=0 then msc+=pval(p,s) end
 end
end

function evalpos()
 return msc*side
end

function qsearch(al,be)
 local st=evalpos()
 if st>=be then return be end
 if st+975<al then return al end
 if st>al then al=st end
 local ml={}
 gencaps(ml)
 local me=side
 for i=1,#ml,2 do
  local f,tg=ml[i],ml[i+1]
  local t,g=tg\8,tg%8
  if true then
   domove(f,t,g)
   if inchk(me) then
    undomove()
   else
    local v=-qsearch(-be,-al)
    undomove()
    if v>=be then return be end
    if v>al then al=v end
   end
  end
 end
 return al
end

function search(d,al,be,ply)
 if d<=0 then return qsearch(al,be) end
 local ml={}
 gen(ml)
 local me=side
 local any=false
 -- ordering: winning captures, then other captures, then quiet
 for pass=1,3 do
  for i=1,#ml,2 do
   local f,tg=ml[i],ml[i+1]
   local t,g=tg\8,tg%8
   local vic=b[t]
   local cl=3
   if vic!=0 then
    cl=(abs(vic)>=abs(b[f])) and 1 or 2
   elseif g==2 or g>=4 then
    cl=2
   end
   if cl==pass then
    domove(f,t,g)
    if inchk(me) then
     undomove()
    else
     any=true
     local v=-search(d-1,-be,-al,ply+1)
     undomove()
     if v>al then al=v end
     if al>=be then return be end
    end
   end
  end
 end
 if not any then
  return inchk(me) and -9000+ply or 0
 end
 return al
end

function npieces()
 local n=0
 for s=21,98 do
  local p=b[s]
  if p and p!=0 then n+=1 end
 end
 return n
end

-- fewer pieces means a narrower tree, so search deeper for free
function pickdepth(base)
 local n=npieces()
 if n<=10 then return base+2 end
 if n<=18 then return base+1 end
 return base
end

-- returns from,tg of the chosen move (nil if no legal move)
function think(d,blund)
 local ml={}
 legal(ml)
 if #ml==0 then return nil end
 if blund and rnd(1)<blund then
  local k=(flr(rnd(#ml/2)))*2+1
  return ml[k],ml[k+1]
 end
 -- shuffle the root list: equal moves then vary between games,
 -- which lets the search use a narrowing window instead of a random tie break
 local k=#ml/2
 for q=k,2,-1 do
  local w=flr(rnd(q))+1
  local a,c=q*2-1,w*2-1
  ml[a],ml[c]=ml[c],ml[a]
  ml[a+1],ml[c+1]=ml[c+1],ml[a+1]
 end
 local bi,bv=1,-32000
 for i=1,#ml,2 do
  local f,tg=ml[i],ml[i+1]
  domove(f,tg\8,tg%8)
  -- beta = -bv, so moves that cannot beat the best so far fail low at once
  local v=-search(d-1,-32000,-bv,1)
  undomove()
  if v>bv then bv=v bi=i end
 end
 return ml[bi],ml[bi+1]
end
-- board ui

bx0=16 by0=16 sq=12
mnu={"cpu: easy","cpu: normal","cpu: hard","2 players"}
fil="abcdefgh"

function sx(s) return bx0+((s-21)%10)*sq end
function sy(s) return by0+flr((s-21)/10)*sq end

function _init()
 initpst()
 t=0 sel=1
 poke(0x5f2d,1)
 md=false
 newgame(1,0)
 mode="splash"
 music(0,500,7)
end

function newgame(dep,bl)
 setup()
 depth=dep blunder=bl
 cur=95 from=0
 lf=0 lt=0
 pend=0
 anim=0 af=0 at=0 ag=0 adur=24 abycpu=false
 res=nil
 shake=0
 refresh()
end

function startgame()
 vs=(sel<4) and 1 or 0
 newgame(({1,2,3})[sel] or 2,({0.5,0.12,0})[sel] or 0)
 mode="play"
 sfx(4)
end

function refresh()
 lm={}
 legal(lm)
 chk=inchk(side)
 if #lm==0 then
  mode="over"
  res=chk and (side>0 and "black mates" or "white mates") or "stalemate"
 end
end

function canmove(f)
 for i=1,#lm,2 do
  if lm[i]==f then return true end
 end
 return false
end

function findmove(f,t)
 for i=1,#lm,2 do
  if lm[i]==f and lm[i+1]\8==t then return lm[i+1]%8 end
 end
 return nil
end

function startanim(f,d,g,cpu)
 af=f at=d ag=g
 abycpu=cpu
 adur=cpu and 24 or 18
 anim=1
 from=0
end

function applymove(f,t,g)
 domove(f,t,g)
 lf=f lt=t
 from=0
 shake=(g==3) and 0.4 or (uc[us]!=0 and 0.8 or 0)
 sfx(g==3 and 3 or (uc[us]!=0 and 1 or 0))
 refresh()
 if mode!="over" and chk then sfx(2) end
end

function _update60()
 t+=1
 shake*=0.85
 local mb=(stat(34)&1)>0
 local click=mb and not md
 md=mb

 if mode=="splash" then
  if btnp()!=0 or stat(30) or click then
   mode="menu" sfx(4)
  end
  return
 end

 if mode=="menu" then
  if btnp(2) then sel=(sel+2)%4+1 sfx(4) end
  if btnp(3) then sel=sel%4+1 sfx(4) end
  local go=btnp(5)
  if click then
   local mx,my=stat(32),stat(33)
   for i=1,4 do
    local y=66+(i-1)*13
    if mx>=20 and mx<=108 and my>=y-5 and my<=y+8 then
     sel=i go=true
    end
   end
  end
  if go then startgame() end
  return
 end

 if mode=="over" then
  if btnp(5) or btnp(4) or click then mode="menu" sfx(4) end
  return
 end

 if mode=="promo" then
  if btnp(0) then psel=(psel+2)%4+1 sfx(4) end
  if btnp(1) then psel=psel%4+1 sfx(4) end
  local go=btnp(5)
  if click and stat(33)>=62 and stat(33)<=79 then
   local i=flr((stat(32)-25)/20)+1
   if i>=1 and i<=4 then psel=i go=true end
  end
  if go then
   mode="play"
   startanim(from,pt,({7,6,5,4})[psel],false)
  end
  if btnp(4) then mode="play" from=0 end
  return
 end

 -- cpu piece travels before the board state changes
 if anim>0 then
  anim+=1
  if anim>=adur then
   local f,d,g=af,at,ag
   anim=0
   applymove(f,d,g)
  end
  return
 end

 -- cpu turn
 if vs==1 and side==-1 then
  if pend>0 then
   pend-=1
   if pend==0 then
    local f,tg=think(pickdepth(depth),blunder)
    if f then
     startanim(f,tg\8,tg%8,true)
    end
   end
  else
   pend=10
  end
  return
 end

 if btnp(4) then
  if from!=0 then from=0 sfx(4) else mode="menu" end
  return
 end

 local c=(cur-21)%10
 local r=flr((cur-21)/10)
 local mv=false
 if btnp(0) then c=(c+7)%8 mv=true end
 if btnp(1) then c=(c+1)%8 mv=true end
 if btnp(2) then r=(r+7)%8 mv=true end
 if btnp(3) then r=(r+1)%8 mv=true end
 if mv then cur=21+r*10+c sfx(4) end

 local go=btnp(5)
 if click then
  local mx,my=stat(32),stat(33)
  if mx>=bx0 and mx<bx0+sq*8 and my>=by0 and my<by0+sq*8 then
   cur=21+flr((my-by0)/sq)*10+flr((mx-bx0)/sq)
   go=true
  end
 end

 if go then
  if from!=0 then
   local g=findmove(from,cur)
   if g then
    if g>=4 then
     mode="promo" psel=1 pt=cur
    else
     startanim(from,cur,g,false)
    end
   elseif b[cur]!=0 and b[cur]*side>0 then
    from=cur sfx(4)
   else
    from=0
   end
  elseif b[cur]!=0 and b[cur]*side>0 and canmove(cur) then
   from=cur sfx(4)
  else
   sfx(5)
  end
 end
end

function drawpiece(p,x,y,z)
 -- 10x10 arcade sprites: outline, shadow, highlight
 z=z or 10
 palt(0,false) palt(3,true)
 if p>0 then
  pal(5,0) pal(6,6) pal(7,7)
 else
  pal(5,0) pal(6,0) pal(7,5)
 end
 sspr((abs(p)-1)*10,0,10,10,x,y,z,z)
 pal() palt()
end

function corners(s,col,n)
 local x,y=sx(s),sy(s)
 line(x,y,x+n,y,col) line(x,y,x,y+n,col)
 line(x+11-n,y,x+11,y,col) line(x+11,y,x+11,y+n,col)
 line(x,y+11-n,x,y+11,col) line(x,y+11,x+n,y+11,col)
 line(x+11-n,y+11,x+11,y+11,col) line(x+11,y+11-n,x+11,y+11,col)
end

function panel(x0,y0,x1,y1,col)
 rectfill(x0+1,y0+1,x1-1,y1-1,0)
 rect(x0,y0,x1,y1,col)
 pset(x0,y0,1) pset(x1,y0,1)
 pset(x0,y1,1) pset(x1,y1,1)
end

function cprint(s,y,col)
 print(s,64-#s*2,y,col)
end

function _draw()
 cls(1)
 if mode=="splash" then drawsplash() return end
 if mode=="menu" then drawmenu() return end
 if shake>0.2 then
  camera(rnd(shake)-shake/2,rnd(shake)-shake/2)
 else
  camera()
 end
 drawgame()
 camera()
end

function drawsplash()
 panel(10,7,118,116,13)
 for i=0,11 do
  local x=(i*29+17)%102+13
  local y=(i*41+11)%100+10
  pset(x,y,(t+i)%30<8 and 12 or 5)
 end
 line(22,20,42,20,12) line(86,20,106,20,14)
 print("chess",55,18,0)
 cprint("chess",16,7)
 drawpiece(6,49,31,30)
 cprint("pixel arena",67,13)
 cprint("one board. one crown.",79,6)
 if t%60<42 then
  cprint("press any button",99,12)
  cprint("or click",108,13)
 end
end

function drawmenu()
 -- tiny starfield + cabinet stripes
 for i=0,7 do
  local x=(i*37+11)%128 local y=(i*23+9)%120
  pset(x,y,(i%2==0) and 13 or 5)
 end
 line(28,13,43,13,12) line(85,13,100,13,14)
 print("chess",55,18,0)
 cprint("chess",16,7)
 cprint("pixel arena",24,13)
 for i=1,6 do
  local x=3+i*16
  drawpiece(i,x,32)
  drawpiece(-i,x,44)
 end
 for i=1,4 do
  local y=66+(i-1)*13
  if i==sel then
   panel(20,y-5,108,y+8,(t%30<15) and 12 or 13)
   print(">",26,y,10)
  end
  cprint(mnu[i],y,i==sel and 7 or 6)
 end
 if t%60<42 then cprint("x  start",120,12) end
end

function drawgame()
 -- arcade cabinet frame
 rectfill(13,13,114,114,0)
 rect(14,14,113,113,13)

 -- squares
 for r=0,7 do
  for c=0,7 do
   local s=21+r*10+c
   local x,y=sx(s),sy(s)
   rectfill(x,y,x+sq-1,y+sq-1,(r+c)%2==0 and 6 or 13)
   if s==lf or s==lt then
    rectfill(x,y,x+sq-1,y+sq-1,2)
    corners(s,14,2)
   end
  end
 end

 -- king in check
 if chk and mode!="over" then
  local ks=(side>0) and kw or kb
  corners(ks,(t%20<10) and 8 or 14,4)
 end

 -- selection + targets
 if from!=0 then
  corners(from,10,4)
  for i=1,#lm,2 do
   if lm[i]==from then
    local d=lm[i+1]\8
    local x,y=sx(d)+5,sy(d)+5
    if b[d]!=0 then
     corners(d,14,3)
    else
     pset(x,y,12) pset(x-1,y,12) pset(x+1,y,12)
     pset(x,y-1,12) pset(x,y+1,12)
    end
   end
  end
 end

 -- pieces
 for s=21,98 do
  local p=b[s]
  if p and p!=0 and not (anim>0 and s==af) then
   if not (anim>16 and s==at and t%4<2) then
    drawpiece(p,sx(s)+1,sy(s)+1)
   end
  end
 end

 -- cpu move: target telegraph, short trail, eased travel
 if anim>0 then
  corners(at,(t%8<4) and 14 or 12,3)
  local u=anim/adur
  u=u*u*(3-2*u)
  local x0,y0=sx(af)+6,sy(af)+6
  local x1,y1=sx(at)+6,sy(at)+6
  for i=1,3 do
   local q=max(0,u-i*0.06)
   pset(x0+(x1-x0)*q,y0+(y1-y0)*q,i==1 and 12 or 13)
  end
  drawpiece(b[af],sx(af)+(sx(at)-sx(af))*u+1,
   sy(af)+(sy(at)-sy(af))*u+1)
 end

 -- cursor
 if mode=="play" and anim==0 and not (vs==1 and side==-1) then
  corners(cur,(t%30<15) and 12 or 7,2)
 end

 -- hud
 local who
 if mode=="over" then
  who=res
 elseif anim>0 then
  who=abycpu and "cpu moving" or
   ((side>0) and "white moving" or "black moving")
 elseif vs==1 and side==-1 then
  who="cpu thinking"
 else
  who=(side>0) and "white to move" or "black to move"
 end
 panel(27,1,101,11,chk and 8 or 13)
 print(who,64-#who*2,4,chk and 8 or 7)
 pset(31,6,side>0 and 7 or 5)
 pset(96,6,side>0 and 7 or 5)

 -- files / ranks
 for i=0,7 do
  print(sub(fil,i+1,i+1),bx0+i*sq+4,117,13)
  print(8-i,8,by0+i*sq+4,13)
 end

 if mode=="over" and t%50<34 then
  print("x  menu",48,122,12)
 end

 if mode=="promo" then
  panel(21,48,107,80,14)
  print("choose upgrade",38,53,12)
  for i=1,4 do
   local x=28+(i-1)*20
   drawpiece(({5,4,3,2})[i]*side,x,65)
   if i==psel then
    rect(x-2,63,x+11,76,10)
    pset(x-2,63,0) pset(x+11,76,0)
   end
  end
 end
end