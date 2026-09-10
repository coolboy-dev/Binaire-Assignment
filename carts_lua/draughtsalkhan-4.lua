-- neon draughts
-- by alkhan

bx=24 by=27 cs=10

-- sound ---------------------------------------------------------------------

function nt(p,w,v) return p+w*64+v*512 end

function mks(n,sp,notes)
 local a=0x3200+68*n
 for i=0,31 do
  local v=notes[i+1] or 0
  poke(a+i*2,v&255)
  poke(a+i*2+1,(v>>8)&255)
 end
 poke(a+64,0) poke(a+65,sp) poke(a+66,0) poke(a+67,0)
end

function makesounds()
 mks(0,3,{nt(30,3,3),nt(37,3,4)})
 mks(1,4,{nt(25,1,4),nt(32,1,4)})
 mks(2,3,{nt(22,6,6),nt(17,6,5),nt(12,6,4)})
 mks(3,4,{nt(31,3,4),nt(38,3,5),nt(43,3,6)})
 mks(4,4,{nt(36,2,5),nt(43,2,6),nt(48,2,6),nt(55,2,7)})
 mks(5,6,{nt(31,5,6),nt(27,5,5),nt(22,5,4),nt(15,5,3)})
 mks(6,5,{nt(24,4,4),nt(31,4,5),nt(36,4,5),nt(43,4,6)})
end

-- rules ---------------------------------------------------------------------
-- pieces: 1 player man, 2 player king, -1 cpu man, -2 cpu king

function bi(r,c) return r*8+c+1 end
function inside(r,c) return r>=0 and r<8 and c>=0 and c<8 end
function at(r,c) return inside(r,c) and board[bi(r,c)] or 0 end
function sideof(p) return p>0 and 1 or (p<0 and -1 or 0) end
function isking(p) return abs(p)==2 end

function clearboard()
 board={}
 for i=1,64 do board[i]=0 end
end

function setupboard()
 clearboard()
 for r=0,2 do
  for c=0,7 do if (r+c)%2==1 then board[bi(r,c)]=-1 end end
 end
 for r=5,7 do
  for c=0,7 do if (r+c)%2==1 then board[bi(r,c)]=1 end end
 end
end

function addcapture(a,r,c,p,dr,dc)
 local mr,mc=r+dr,c+dc
 local tr,tc=r+dr*2,c+dc*2
 if inside(tr,tc) and at(tr,tc)==0
 and sideof(at(mr,mc))==-sideof(p) then
  add(a,{r=r,c=c,tr=tr,tc=tc,cr=mr,cc=mc,cap=true})
 end
end

function capturesfor(r,c)
 local a={} local p=at(r,c)
 if p==0 then return a end
 if isking(p) or p>0 then
  addcapture(a,r,c,p,-1,-1) addcapture(a,r,c,p,-1,1)
 end
 if isking(p) or p<0 then
  addcapture(a,r,c,p,1,-1) addcapture(a,r,c,p,1,1)
 end
 return a
end

function addstep(a,r,c,p,dr,dc)
 local tr,tc=r+dr,c+dc
 if inside(tr,tc) and at(tr,tc)==0 then
  add(a,{r=r,c=c,tr=tr,tc=tc,cap=false})
 end
end

function stepsfor(r,c)
 local a={} local p=at(r,c)
 if p==0 then return a end
 if isking(p) or p>0 then
  addstep(a,r,c,p,-1,-1) addstep(a,r,c,p,-1,1)
 end
 if isking(p) or p<0 then
  addstep(a,r,c,p,1,-1) addstep(a,r,c,p,1,1)
 end
 return a
end

-- the capture scan is global: a normal move is illegal if any capture exists
function legalmoves(side,fr,fc)
 local caps={}
 for r=0,7 do for c=0,7 do
  if sideof(at(r,c))==side then
   for m in all(capturesfor(r,c)) do add(caps,m) end
  end
 end end
 if #caps>0 then
  if fr==nil then return caps end
  local out={}
  for m in all(caps) do if m.r==fr and m.c==fc then add(out,m) end end
  return out
 end
 local out={}
 for r=0,7 do for c=0,7 do
  if sideof(at(r,c))==side and (fr==nil or (r==fr and c==fc)) then
   for m in all(stepsfor(r,c)) do add(out,m) end
  end
 end end
 return out
end

function countpieces(side)
 local n=0
 for p in all(board) do if sideof(p)==side then n+=1 end end
 return n
end

function canselect(r,c)
 if sideof(at(r,c))!=turnside then return false end
 return #legalmoves(turnside,r,c)>0
end

-- labels ---------------------------------------------------------------
-- side 1 is the bottom (blue) player; side -1 is the cpu or the second player.

function turnlabel()
 if twoplayer then return turnside==1 and "p1 turn" or "p2 turn" end
 return turnside==1 and "your turn" or "cpu turn"
end

function resulttext(r)
 if r=="draw" then return "draw game" end
 if twoplayer then return r=="win" and "p1 wins!" or "p2 wins!" end
 return r=="win" and "you win!" or "cpu wins"
end

function resultcolor(r)
 if r=="draw" then return 10 end
 if twoplayer then return r=="win" and 12 or 8 end
 return r=="win" and 11 or 8
end

function resetgame()
 setupboard()
 mode="game" state="player" turnside=1
 cur_r=5 cur_c=0 selected=nil selmoves={}
 lastmove=nil moving=nil ai_r=nil ai_c=nil aiwait=0
 result=nil no_progress=0 turn_progress=false
 msg=turnlabel() msgt=60
 parts={} rings={} trails={}
 flash=0 shake=0
end

function startside(side)
 selected=nil selmoves={} ai_r=nil ai_c=nil
 turnside=side turn_progress=false
 local moves=legalmoves(side)
 if #moves==0 then
  endgame(side==1 and "lose" or "win")
 elseif side==1 or twoplayer then
  state="player" msg=turnlabel() msgt=45
 else
  state="ai" aiwait=8 msg="cpu thinking" msgt=24
 end
end

function endturn(side)
 if turn_progress then no_progress=0 else no_progress+=1 end
 if no_progress>=80 then endgame("draw") else startside(-side) end
end

function endgame(r)
 state="over" result=r selected=nil selmoves={} osel=1
 msg=resulttext(r)
 msgt=999 flash=7 shake=5
 local col=resultcolor(r)
 for i=1,48 do burst(64+rnd(54)-27,60+rnd(50)-25,col,1,2.4) end
 sfx(r=="win" and 4 or (r=="lose" and 5 or 6))
end

-- effects and move execution ------------------------------------------------

function sqx(c) return bx+c*cs+5 end
function sqy(r) return by+r*cs+5 end

function burst(x,y,c,n,pow)
 for i=1,n do
  local a=rnd(1) local sp=.3+rnd(pow)
  add(parts,{x=x,y=y,vx=cos(a)*sp,vy=sin(a)*sp,
   l=8+rnd(14),m=22,c=(rnd(1)<.22 and 7 or c)})
 end
end

function makering(x,y,c)
 add(rings,{x=x,y=y,r=1,l=10,c=c})
end

function beginmove(m,side)
 local p=at(m.r,m.c)
 if sideof(p)!=side then return false end
 board[bi(m.r,m.c)]=0
 if m.cap then
  board[bi(m.cr,m.cc)]=0
  turn_progress=true
  burst(sqx(m.cc),sqy(m.cr),side==1 and 12 or 8,18,2)
  makering(sqx(m.cc),sqy(m.cr),10)
  shake=3.5 flash=2 sfx(2)
 else
  sfx(1)
 end
 moving={m=m,p=p,side=side,f=0,d=m.cap and 15 or 12}
 lastmove={m.r,m.c,m.tr,m.tc}
 state="anim" selected=nil selmoves={}
 return true
end

function finishmove()
 local a=moving local m=a.m local p=a.p local promoted=false
 board[bi(m.tr,m.tc)]=p
 if abs(p)==1 and ((p>0 and m.tr==0) or (p<0 and m.tr==7)) then
  p=p>0 and 2 or -2 board[bi(m.tr,m.tc)]=p
  promoted=true turn_progress=true
  burst(sqx(m.tc),sqy(m.tr),10,30,2.5)
  makering(sqx(m.tc),sqy(m.tr),7)
  flash=5 shake=4 sfx(3)
 end
 moving=nil
 if m.cap and not promoted then
  local next=capturesfor(m.tr,m.tc)
  if #next>0 then
   if a.side==1 or twoplayer then
    state="player_chain" selected={r=m.tr,c=m.tc}
    selmoves=next cur_r=m.tr cur_c=m.tc
    msg="keep jumping!" msgt=70
   else
    state="ai" ai_r=m.tr ai_c=m.tc aiwait=4
    msg="cpu combo!" msgt=55
   end
   return
  end
 end
 endturn(a.side)
end

-- smart cpu ---------------------------------------------------------------
-- search scores are positive for the cpu. capture chains stay on the same
-- ply, so the search always evaluates a complete turn rather than half a jump.

function copyboard()
 local b={}
 for i=1,64 do b[i]=board[i] end
 return b
end

function simmove(m)
 local p=at(m.r,m.c) local promoted=false
 board[bi(m.r,m.c)]=0
 if m.cap then board[bi(m.cr,m.cc)]=0 end
 if abs(p)==1 and ((p>0 and m.tr==0) or (p<0 and m.tr==7)) then
  p=p>0 and 2 or -2 promoted=true
 end
 board[bi(m.tr,m.tc)]=p
 if m.cap and not promoted then return capturesfor(m.tr,m.tc) end
 return {}
end

function positionvalue()
 local s=0
 for r=0,7 do for c=0,7 do
  local p=at(r,c)
  if p!=0 then
   local v=isking(p) and 185 or 100
   if not isking(p) then
    v+=(p<0 and r or 7-r)*6
    if (p<0 and r==0) or (p>0 and r==7) then v+=7 end
   else
    v+=max(0,7-abs(3.5-r)-abs(3.5-c))*2
   end
   if c>0 and c<7 then v+=3 end
   s+=p<0 and v or -v
  end
 end end
 return s
end

function searchpos(side,depth,fr,fc,lo,hi)
 ai_nodes+=1
 local moves=fr!=nil and capturesfor(fr,fc) or legalmoves(side)
 if #moves==0 then return side==-1 and -10000-depth or 10000+depth end
 if (depth<=0 and fr==nil) or ai_nodes>=ai_limit then return positionvalue() end
 local best=side==-1 and -32767 or 32767
 for m in all(moves) do
  local saved=copyboard()
  local next=simmove(m)
  local v
  if #next>0 then
   v=searchpos(side,depth,m.tr,m.tc,lo,hi)
  else
   v=searchpos(-side,depth-1,nil,nil,lo,hi)
  end
  board=saved
  if side==-1 then
   best=max(best,v) lo=max(lo,best)
  else
   best=min(best,v) hi=min(hi,best)
  end
  if hi<=lo then break end
 end
 return best
end

function smartpick(moves)
 local pieces=countpieces(1)+countpieces(-1)
 local depth=3 ai_limit=800
 if pieces<=16 then depth=4 ai_limit=1400 end
 if pieces<=8 then depth=5 ai_limit=1800 end
 ai_nodes=0
 local pick=moves[1] local best=-32767
 for m in all(moves) do
  local saved=copyboard()
  local next=simmove(m)
  local v
  if #next>0 then
   v=searchpos(-1,depth,m.tr,m.tc,-32767,32767)
  else
   v=searchpos(1,depth-1,nil,nil,-32767,32767)
  end
  board=saved
  if v>best then best=v pick=m end
 end
 return pick
end

function aimove()
 local moves
 if ai_r!=nil then moves=capturesfor(ai_r,ai_c) else moves=legalmoves(-1) end
 if #moves==0 then endgame("win") return end
 local pick
 if difficulty==1 then
  pick=rnd(moves)
 else
  pick=smartpick(moves)
 end
 ai_r=nil ai_c=nil
 beginmove(pick,-1)
end

-- input ---------------------------------------------------------------------

function mouseupdate()
 mx=stat(32) my=stat(33)
 local mb=stat(34)
 mclick=(mb&1)>0 and (oldmb&1)==0
 if mx!=oldmx or my!=oldmy then usemouse=true end
 oldmx=mx oldmy=my oldmb=mb
end

function anypress() return btnp()!=0 or mclick end
function hit(x0,y0,x1,y1) return mx>=x0 and mx<=x1 and my>=y0 and my<=y1 end

function trycell(r,c)
 if not inside(r,c) then return end
 if selected then
  for m in all(selmoves) do
   if m.tr==r and m.tc==c then beginmove(m,turnside) return end
  end
  if state=="player_chain" then sfx(0) return end
  if selected.r==r and selected.c==c then
   selected=nil selmoves={} sfx(0) return
  end
 end
 if canselect(r,c) then
  selected={r=r,c=c} selmoves=legalmoves(turnside,r,c)
  cur_r=r cur_c=c sfx(0)
 else
  sfx(0)
 end
end

function playerinput()
 if usemouse and hit(bx,by,bx+79,by+79) then
  cur_c=flr((mx-bx)/cs) cur_r=flr((my-by)/cs)
 end
 if btnp(0) then cur_c=(cur_c+7)%8 usemouse=false sfx(0) end
 if btnp(1) then cur_c=(cur_c+1)%8 usemouse=false sfx(0) end
 if btnp(2) then cur_r=(cur_r+7)%8 usemouse=false sfx(0) end
 if btnp(3) then cur_r=(cur_r+1)%8 usemouse=false sfx(0) end
 if (btnp(4) or (mclick and hit(bx,by,bx+79,by+79))) then
  trycell(cur_r,cur_c)
 elseif btnp(5) and state!="player_chain" then
  if selected then selected=nil selmoves={} else openmenu() end
 end
end

function openmenu()
 mode="menu" state="idle" msel=1
 usemouse=false menu_lock=6
end

function menuy(i) return 44+i*16 end

function menutext(i)
 if i==1 then return "start game" end
 if i==2 then return twoplayer and "mode: 2 players" or "mode: vs cpu" end
 return "cpu: "..(difficulty==1 and "easy" or "smart")
end

function activatemenu(i)
 if i==1 then
  resetgame() sfx(3)
 elseif i==2 then
  twoplayer=not twoplayer sfx(0)
 else
  difficulty=3-difficulty sfx(0)
 end
end

function menuinput()
 if menu_lock>0 then menu_lock-=1 return end
 if btnp(2) then msel=max(1,msel-1) usemouse=false sfx(0) end
 if btnp(3) then msel=min(3,msel+1) usemouse=false sfx(0) end
 if usemouse then
  for i=1,3 do
   if hit(22,menuy(i),105,menuy(i)+14) then msel=i end
  end
 end
 local choose=btnp(4) or btnp(5) or mclick
 if choose and (not mclick or hit(22,menuy(msel),105,menuy(msel)+14)) then
  activatemenu(msel)
 end
end

function moveover(d)
 osel=((osel-1+d)%2)+1
 usemouse=false sfx(0)
end

function activateover(i)
 if i==1 then
  resetgame() sfx(3)
 else
  openmenu() sfx(0)
 end
end

function overinput()
 if btnp(2) then moveover(-1) end
 if btnp(3) then moveover(1) end
 if usemouse then
  if hit(32,76,95,89) then osel=1 end
  if hit(32,93,95,105) then osel=2 end
 end
 if mclick then
  if hit(32,76,95,89) then activateover(1)
  elseif hit(32,93,95,105) then activateover(2) end
 elseif btnp(4) or btnp(5) then
  activateover(osel)
 end
end

-- update --------------------------------------------------------------------

function updatefx()
 shake*=.84
 if flash>0 then flash-=1 end
 for p in all(parts) do
  p.x+=p.vx p.y+=p.vy p.vx*=.94 p.vy=p.vy*.94+.025 p.l-=1
  if p.l<=0 then del(parts,p) end
 end
 for r in all(rings) do
  r.r+=.7 r.l-=1
  if r.l<=0 then del(rings,r) end
 end
 for q in all(trails) do
  q.l-=1
  if q.l<=0 then del(trails,q) end
 end
end

function _init()
 poke(0x5f2d,1)
 makesounds() srand(time())
 t=0 mode="splash" state="idle" difficulty=2 twoplayer=false msel=1 menu_lock=0
 board={} parts={} rings={} trails={}
 flash=0 shake=0 msg="" msgt=0
 usemouse=false oldmx=stat(32) oldmy=stat(33) oldmb=stat(34)
 stars={}
 for i=1,34 do add(stars,{x=rnd(128),y=rnd(128),s=1+flr(rnd(2)),p=rnd(1)}) end
 setupboard()
end

function _update60()
 t+=1 mouseupdate() updatefx()
 if msgt>0 then msgt-=1 end
 if mode=="splash" then
  if anypress() and t>8 then openmenu() sfx(3) end
 elseif mode=="menu" then
  menuinput()
 elseif mode=="game" then
  if state=="player" or state=="player_chain" then
   playerinput()
  elseif state=="ai" then
   aiwait-=1 if aiwait<=0 then aimove() end
  elseif state=="anim" then
   moving.f+=1
   local u=moving.f/moving.d
   local e=u*u*(3-2*u)
   local m=moving.m
   add(trails,{x=sqx(m.c)+(sqx(m.tc)-sqx(m.c))*e,
    y=sqy(m.r)+(sqy(m.tr)-sqy(m.r))*e,l=5,c=moving.side==1 and 12 or 8})
   if moving.f>=moving.d then finishmove() end
  elseif state=="over" then
   overinput()
  end
 end
end

-- drawing -------------------------------------------------------------------

function cprint(s,y,c)
 print(s,64-flr(#s*2),y,c)
end

function panel(x0,y0,x1,y1,c,edge)
 rectfill(x0+2,y0,x1-2,y1,c)
 rectfill(x0,y0+2,x1,y1-2,c)
 rectfill(x0+1,y0+1,x1-1,y1-1,c)
 if edge then line(x0+2,y0,x1-2,y0,edge) line(x0,y0+2,x0,y1-2,edge) end
end

function drawbg()
 cls(flash>2 and 1 or 0)
 for s in all(stars) do
  local y=(s.y+t*s.s*.045)%128
  pset(s.x,y,s.p<.35 and 13 or 1)
 end
 for y=3,127,8 do line(0,y,127,y,0) end
end

function neontext(s,x,y,c,shadow)
 print(s,x+1,y+1,shadow or 1)
 print(s,x,y,c)
end

function drawlogo(y)
 local s="D R A U G H T S"
 local x=64-flr(#s*2)
 neontext(s,x+1,y+1,2,1)
 neontext(s,x,y,12,1)
 line(25,y+8,103,y+8,5)
 line(34,y+10,94,y+10,1)
end

function drawpiece(x,y,p,ghost)
 local c=p>0 and 12 or 8
 local rim=p>0 and 6 or 2
 if ghost then
  circfill(x,y,3,c) pset(x-1,y-1,7) return
 end
 circfill(x+1,y+1,4,0)
 circfill(x,y,4,rim)
 circfill(x,y-1,3,c)
 line(x-2,y-2,x+1,y-3,p>0 and 7 or 14)
 pset(x+2,y,7)
 if isking(p) then
  line(x-2,y+1,x+2,y+1,10)
  pset(x-2,y-1,10) pset(x,y-2,10) pset(x+2,y-1,10)
  pset(x-1,y,10) pset(x+1,y,10)
 end
end

function drawboard()
 rectfill(bx-3,by-3,bx+82,by+82,0)
 rect(bx-2,by-2,bx+81,by+81,12)
 rect(bx-1,by-1,bx+80,by+80,1)
 for r=0,7 do for c=0,7 do
  local x,y=bx+c*cs,by+r*cs
  local dark=(r+c)%2==1
  rectfill(x,y,x+9,y+9,dark and 5 or 1)
  if not dark then pset(x+1,y+1,13) end
  if lastmove and ((r==lastmove[1] and c==lastmove[2])
   or (r==lastmove[3] and c==lastmove[4])) then
   rect(x+1,y+1,x+8,y+8,13)
  end
 end end

 if state=="player" or state=="player_chain" then
  if state!="player_chain" then
   if t%30<20 then
    for m in all(legalmoves(turnside)) do
     if m.cap then
      rect(bx+m.c*cs+1,by+m.r*cs+1,bx+m.c*cs+8,by+m.r*cs+8,10)
     end
    end
   end
  end
  for m in all(selmoves) do
   local x,y=sqx(m.tc),sqy(m.tr)
   if m.cap then
    line(x-2,y-2,x+2,y+2,10) line(x+2,y-2,x-2,y+2,10)
   else
    circfill(x,y,2,11) pset(x,y,7)
   end
  end
 end

 for r=0,7 do for c=0,7 do
  local p=at(r,c)
  if p!=0 then drawpiece(sqx(c),sqy(r),p,false) end
 end end

 if selected then
  local x,y=bx+selected.c*cs,by+selected.r*cs
  rect(x,y,x+9,y+9,t%20<10 and 10 or 7)
 end
 if state=="player" or state=="player_chain" then
  local x,y=bx+cur_c*cs,by+cur_r*cs
  rect(x-1,y-1,x+10,y+10,t%24<12 and 7 or 6)
 end

 for q in all(trails) do circfill(q.x,q.y,1,q.c) end
 if moving then
  local u=min(1,moving.f/moving.d) local e=u*u*(3-2*u) local m=moving.m
  local x=sqx(m.c)+(sqx(m.tc)-sqx(m.c))*e
  local y=sqy(m.r)+(sqy(m.tr)-sqy(m.r))*e-sin(u*.5)*5
  drawpiece(x,y,moving.p,false)
 end
end

function drawfx()
 for r in all(rings) do circ(r.x,r.y,r.r,r.c) end
 for p in all(parts) do
  local c=p.l<4 and 1 or p.c
  pset(p.x,p.y,c)
 end
end

function drawhud()
 local pc=countpieces(1) local ac=countpieces(-1)
 neontext(twoplayer and "p1" or "you",2,3,12,1) print(pc,4,10,7)
 neontext(twoplayer and "p2" or "cpu",twoplayer and 112 or 108,3,8,1) print(ac,116,10,7)
 panel(34,2,93,20,1,5)
 if state=="player_chain" then cprint("combo!",7,10)
 elseif state=="anim" then cprint(turnlabel(),7,7)
 elseif state=="over" then cprint("game over",7,10)
 else cprint(turnlabel(),7,turnside==1 and 12 or 8) end
 if msgt>0 and state!="over" then cprint(msg,112,state=="player_chain" and 10 or 6)
 else cprint("z select  x back",112,5) end
end

function drawsplash()
 drawbg()
 for r=0,5 do for c=0,8 do
  if (r+c)%2==1 then
   local x=20+c*11 local y=17+r*11
   rectfill(x,y,x+8,y+8,(r+c)%4==1 and 1 or 5)
  end
 end end
 drawlogo(31)
 drawpiece(43,58,2,false) drawpiece(85,58,-2,false)
 circ(43,58,7,12) circ(85,58,7,8)
 panel(24,85,103,101,1,5)
 if t%60<44 then cprint("press any button",91,7) end
 cprint("english checkers",113,6)
end

function drawmenu()
 drawbg() drawlogo(18)
 drawpiece(44,45,1,false) drawpiece(84,45,-1,false)
 line(51,45,77,45,5)
 for i=1,3 do
  local y=menuy(i) local sel=i==msel
  panel(22,y,105,y+14,sel and 5 or 1,sel and 12 or 13)
  cprint(menutext(i),y+5,sel and 7 or ((i==3 and twoplayer) and 5 or 6))
  if sel then print(">",27,y+5,10) print("<",97,y+5,10) end
 end
 cprint("arrows + z / mouse",111,5)
end

function drawover()
 rectfill(18,38,109,108,0)
 rect(18,38,109,108,resultcolor(result))
 panel(22,42,105,67,1,5)
 cprint(resulttext(result),49,resultcolor(result))
 cprint("pieces "..countpieces(1).." - "..countpieces(-1),62,6)
 local labels={"play again","main menu"}
 for i=1,2 do
  local y=i==1 and 76 or 93 local sel=i==osel
  panel(32,y,95,y+(i==1 and 13 or 12),sel and 5 or 1,sel and 12 or 13)
  cprint(labels[i],y+5,sel and 7 or 6)
  if sel then print(">",36,y+5,10) print("<",88,y+5,10) end
 end
end

function _draw()
 if mode=="splash" then drawsplash() return end
 if mode=="menu" then drawmenu() return end
 drawbg()
 if shake>.25 then camera(rnd(shake)-shake/2,rnd(shake)-shake/2) else camera() end
 drawboard() drawfx()
 camera() drawhud()
 if state=="over" then drawover() end
end