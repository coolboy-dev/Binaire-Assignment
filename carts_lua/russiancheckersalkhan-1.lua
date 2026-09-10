-- russian checkers
-- by alkhan

bx=24 by=27 cs=10
-- players: 1 hot-seat player against the cpu, 2 hot-seat players
players=1
-- share of a 60fps frame the sliced search may take before it yields
ai_budget=.62

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

-- side -1 is a human only in the two-player hot-seat mode
function ishuman(side) return players==2 or side==1 end

function sidename(side)
 if players==2 then return side==1 and "p1" or "p2" end
 return side==1 and "you" or "cpu"
end

function turnlabel(side)
 if players==2 then return sidename(side).." turn" end
 return side==1 and "your turn" or "cpu turn"
end

function movelabel(side)
 if players==2 then return sidename(side).." move" end
 return side==1 and "your move" or "cpu move"
end

function winnertext()
 if players==2 then return result=="win" and "p1 wins!" or "p2 wins!" end
 return result=="win" and "you win!" or "cpu wins"
end

function clearboard()
 board={}
 for i=1,64 do board[i]=0 end
 chain_caps={}
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

-- blockers are stored as board indices so a capture chain allocates nothing
function wascaptured(r,c)
 local k=r*8+c+1
 for q in all(chain_caps or {}) do
  if q==k then return true end
 end
 return false
end

function blocked(r,c)
 return at(r,c)!=0 or wascaptured(r,c)
end

function addmancapture(a,r,c,p,dr,dc)
 local mr,mc=r+dr,c+dc
 local tr,tc=r+dr*2,c+dc*2
 if inside(tr,tc) and not blocked(tr,tc)
 and sideof(at(mr,mc))==-sideof(p) then
  add(a,{r=r,c=c,tr=tr,tc=tc,cr=mr,cc=mc,cap=true})
 end
end

function addkingcaptures(a,r,c,p,dr,dc)
 local rr,cc=r+dr,c+dc
 -- fly over empty squares until the first blocker
 while inside(rr,cc) and not blocked(rr,cc) do
  rr+=dr cc+=dc
 end
 if not inside(rr,cc) or sideof(at(rr,cc))!=-sideof(p) then return end
 local cr,capc=rr,cc
 rr+=dr cc+=dc
 -- every free square beyond the victim is a legal landing square
 while inside(rr,cc) and not blocked(rr,cc) do
  add(a,{r=r,c=c,tr=rr,tc=cc,cr=cr,cc=capc,cap=true})
  rr+=dr cc+=dc
 end
end

function capturesfor(r,c,a)
 a=a or {}
 local p=at(r,c)
 if p==0 then return a end
 if isking(p) then
  addkingcaptures(a,r,c,p,-1,-1) addkingcaptures(a,r,c,p,-1,1)
  addkingcaptures(a,r,c,p,1,-1) addkingcaptures(a,r,c,p,1,1)
 else
  -- russian men may capture both forwards and backwards
  addmancapture(a,r,c,p,-1,-1) addmancapture(a,r,c,p,-1,1)
  addmancapture(a,r,c,p,1,-1) addmancapture(a,r,c,p,1,1)
 end
 return a
end

function addstep(a,r,c,p,dr,dc)
 local tr,tc=r+dr,c+dc
 if inside(tr,tc) and at(tr,tc)==0 then
  add(a,{r=r,c=c,tr=tr,tc=tc,cap=false})
 end
end

function stepsfor(r,c,a)
 a=a or {}
 local p=at(r,c)
 if p==0 then return a end
 if isking(p) then
  for d in all({{-1,-1},{-1,1},{1,-1},{1,1}}) do
   local rr,cc=r+d[1],c+d[2]
   while inside(rr,cc) and not blocked(rr,cc) do
    add(a,{r=r,c=c,tr=rr,tc=cc,cap=false})
    rr+=d[1] cc+=d[2]
   end
  end
 elseif p>0 then
  addstep(a,r,c,p,-1,-1) addstep(a,r,c,p,-1,1)
 else
  addstep(a,r,c,p,1,-1) addstep(a,r,c,p,1,1)
 end
 return a
end

-- the capture scan is global: a normal move is illegal if any capture exists
function legalmoves(side,fr,fc)
 local caps={}
 for i=1,64 do
  local p=board[i]
  if p!=0 and (p>0)==(side>0) then
   capturesfor((i-1)\8,(i-1)%8,caps)
  end
 end
 if #caps>0 then
  if fr==nil then return caps end
  local out={}
  for m in all(caps) do if m.r==fr and m.c==fc then add(out,m) end end
  return out
 end
 local out={}
 for i=1,64 do
  local p=board[i]
  if p!=0 and (p>0)==(side>0) then
   local r,c=(i-1)\8,(i-1)%8
   if fr==nil or (r==fr and c==fc) then stepsfor(r,c,out) end
  end
 end
 return out
end

function countpieces(side)
 local n=0
 for i=1,64 do
  local p=board[i]
  if p!=0 and (p>0)==(side>0) then n+=1 end
 end
 return n
end

function canselect(r,c)
 if sideof(at(r,c))!=turnside then return false end
 return #legalmoves(turnside,r,c)>0
end

function resetgame()
 ai_job=nil
 setupboard()
 mode="game" state="player" turnside=1
 cur_r=5 cur_c=0 selected=nil selmoves={}
 lastmove=nil moving=nil ai_r=nil ai_c=nil aiwait=0
 result=nil no_progress=0 turn_progress=false
 chain_caps={}
 msg=turnlabel(1) msgt=60
 parts={} rings={} trails={}
 flash=0 shake=0
end

function startside(side)
 ai_job=nil
 selected=nil selmoves={} ai_r=nil ai_c=nil
 chain_caps={}
 turnside=side turn_progress=false
 local moves=legalmoves(side)
 if #moves==0 then
  endgame(side==1 and "lose" or "win")
 elseif ishuman(side) then
  state="player" msgt=45
  msg=players==2 and sidename(side).." to move" or "your turn"
  -- hand the cursor to the side that has to answer
  if players==2 then cur_r=moves[1].r cur_c=moves[1].c end
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
 msg=r=="draw" and "draw game" or winnertext()
 msgt=999 flash=7 shake=5
 local col=r=="win" and 11 or (r=="lose" and 8 or 10)
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
  chain_caps=chain_caps or {}
  add(chain_caps,bi(m.cr,m.cc))
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
 -- in russian checkers a man crowned during a capture continues as a king
 if m.cap then
  local next=capturesfor(m.tr,m.tc)
  if #next>0 then
   if ishuman(a.side) then
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
-- search scores are positive for the cpu and preserve russian capture-chain
-- blockers while exploring every legal landing of a flying king.

function copyboard()
 local b={}
 for i=1,64 do b[i]=board[i] end
 return b
end

function copycaps()
 local a={}
 for q in all(chain_caps or {}) do add(a,q) end
 return a
end

function domove(m)
 local p=board[bi(m.r,m.c)]
 local victim=0
 board[bi(m.r,m.c)]=0
 if m.cap then
  victim=board[bi(m.cr,m.cc)]
  board[bi(m.cr,m.cc)]=0
  add(chain_caps,bi(m.cr,m.cc))
 end
 if abs(p)==1 and ((p>0 and m.tr==0) or (p<0 and m.tr==7)) then
  board[bi(m.tr,m.tc)]=p>0 and 2 or -2
 else
  board[bi(m.tr,m.tc)]=p
 end
 return p,victim
end

function undomove(m,p,victim)
 board[bi(m.tr,m.tc)]=0
 board[bi(m.r,m.c)]=p
 if m.cap then
  board[bi(m.cr,m.cc)]=victim
  chain_caps[#chain_caps]=nil
 end
end

function positionvalue()
 local s=0
 for i=1,64 do
  local p=board[i]
  if p!=0 then
   local r,c=(i-1)\8,(i-1)%8
   local v
   if p==2 or p==-2 then
    v=205+max(0,7-abs(3.5-r)-abs(3.5-c))*2
   else
    v=100+(p<0 and r or 7-r)*6
    if (p<0 and r==0) or (p>0 and r==7) then v+=7 end
   end
   if c>0 and c<7 then v+=3 end
   s+=p<0 and v or -v
  end
 end
 return s
end

-- `pre` is the continuation list the caller already generated, so a capture
-- chain never scans the same square twice
function searchpos(side,depth,fr,fc,lo,hi,pre)
 if ai_sliced then
  ai_slice+=1
  if ai_slice>=2 then
   ai_slice=0
   if stat(1)>ai_budget then yield() end
  end
 end
 ai_nodes+=1
 local moves=pre or (fr!=nil and capturesfor(fr,fc) or legalmoves(side))
 if #moves==0 then return side==-1 and -10000-depth or 10000+depth end
 if (depth<=0 and fr==nil) or ai_nodes>=ai_limit then return positionvalue() end
 local best=side==-1 and -32767 or 32767
 for m in all(moves) do
  local p,victim=domove(m)
  local next=m.cap and capturesfor(m.tr,m.tc)
  local v
  if next and #next>0 then
   v=searchpos(side,depth,m.tr,m.tc,lo,hi,next)
  else
   local held=chain_caps
   if #chain_caps>0 then chain_caps={} end
   v=searchpos(-side,depth-1,nil,nil,lo,hi)
   chain_caps=held
  end
  undomove(m,p,victim)
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
  local p,victim=domove(m)
  local next=m.cap and capturesfor(m.tr,m.tc)
  local v
  if next and #next>0 then
   v=searchpos(-1,depth,m.tr,m.tc,-32767,32767,next)
  else
   local held=chain_caps
   if #chain_caps>0 then chain_caps={} end
   v=searchpos(1,depth-1,nil,nil,-32767,32767)
   chain_caps=held
  end
  undomove(m,p,victim)
  if v>best then best=v pick=m end
 end
 return pick
end

function aimove()
 if ai_job then
  -- only the private search position may be suspended mid-combination
  local liveboard=board local livecaps=chain_caps
  board=ai_job.board chain_caps=ai_job.caps
  ai_slice=0 ai_sliced=true
  local ok,pick=coresume(ai_job.co)
  ai_sliced=false
  ai_job.board=board ai_job.caps=chain_caps
  board=liveboard chain_caps=livecaps
  assert(ok,pick)
  if costatus(ai_job.co)=="dead" then
   ai_job=nil ai_r=nil ai_c=nil
   beginmove(pick,-1)
  end
  return
 end
 local moves
 if ai_r!=nil then moves=capturesfor(ai_r,ai_c) else moves=legalmoves(-1) end
 if #moves==0 then endgame("win") return end
 local pick
 if #moves==1 then
  pick=moves[1]
 elseif difficulty==1 then
  pick=rnd(moves)
 else
  ai_job={board=copyboard(),caps=copycaps(),
   co=cocreate(function() return smartpick(moves) end)}
  return
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
 ai_job=nil
 mode="menu" state="idle" msel=1
 usemouse=false menu_lock=6
end

function menuy(i) return 40+i*17 end

function menulabel(i)
 if i==1 then return "start game" end
 if i==2 then return players==2 and "2 players" or "1 player" end
 return "cpu: "..(difficulty==1 and "easy" or "smart")
end

function activatemenu(i)
 if i==1 then
  resetgame() sfx(3)
 elseif i==2 then
  players=3-players
  sfx(0)
 else
  difficulty=3-difficulty
  sfx(0)
 end
end

function menuinput()
 if menu_lock>0 then menu_lock-=1 return end
 if btnp(2) then msel=max(1,msel-1) usemouse=false sfx(0) end
 if btnp(3) then msel=min(3,msel+1) usemouse=false sfx(0) end
 if usemouse then
  for i=1,3 do if hit(22,menuy(i),105,menuy(i)+14) then msel=i end end
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
 -- separate cartridge palette: midnight board, warm wood, ivory vs coral
 pal(1,129,1) pal(2,130,1) pal(4,132,1) pal(5,132,1)
 pal(6,134,1) pal(8,142,1) pal(10,137,1) pal(11,139,1)
 pal(12,135,1) pal(13,141,1) pal(14,143,1) pal(15,134,1)
 makesounds() srand(time())
 t=0 mode="splash" state="idle" difficulty=2 players=1 msel=1 menu_lock=0
 ai_budget=.62
 turnside=1
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
 local s="RUSSIAN CHECKERS"
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
 if isking(p) then drawcrown(x,y) end
end

function drawcrown(x,y)
 -- an ivory crown on a dark inset stays readable on both piece colours
 rectfill(x-3,y-3,x+3,y+2,0)
 line(x-2,y+1,x+2,y+1,7)
 line(x-2,y-1,x-2,y,7) line(x+2,y-1,x+2,y,7)
 line(x,y-2,x,y,7)
 pset(x-1,y,7) pset(x+1,y,7)
end

function drawcrowns()
 for r=0,7 do for c=0,7 do
  if isking(at(r,c)) then drawcrown(sqx(c),sqy(r)) end
 end end
 if moving and isking(moving.p) then
  local u=min(1,moving.f/moving.d) local e=u*u*(3-2*u)
  local m=moving.m
  drawcrown(sqx(m.c)+(sqx(m.tc)-sqx(m.c))*e,
   sqy(m.r)+(sqy(m.tr)-sqy(m.r))*e-sin(u*.5)*5)
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
 neontext(sidename(1),2,3,12,1) print(pc,4,10,7)
 neontext(sidename(-1),108,3,8,1) print(ac,116,10,7)
 -- a lit underline names the side on the move for hot-seat play
 if state!="over" then
  if turnside==1 then line(2,17,13,17,12) else line(108,17,119,17,8) end
 end
 panel(34,2,93,20,1,5)
 if state=="player_chain" then cprint("combo!",7,10)
 elseif state=="ai" then cprint("cpu turn",7,8)
 elseif state=="anim" then cprint(movelabel(turnside),7,7)
 elseif state=="over" then cprint("game over",7,10)
 else cprint(turnlabel(turnside),7,turnside==1 and 12 or 8) end
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
 cprint("russian rules",113,6)
end

function drawmenu()
 drawbg() drawlogo(18)
 drawpiece(44,40,1,false) drawpiece(84,40,-1,false)
 line(51,40,77,40,5)
 for i=1,3 do
  local y=menuy(i) local sel=i==msel
  -- the cpu entry is inert while two humans share the board
  local off=i==3 and players==2
  panel(22,y,105,y+14,sel and 5 or 1,sel and 12 or 13)
  cprint(menulabel(i),y+5,off and 5 or (sel and 7 or 6))
  if sel then print(">",27,y+5,10) print("<",97,y+5,10) end
 end
 cprint("arrows + z / mouse",111,5)
end

function drawover()
 rectfill(18,38,109,108,0)
 rect(18,38,109,108,result=="win" and 11 or (result=="lose" and 8 or 10))
 panel(22,42,105,67,1,5)
 cprint(result=="draw" and "draw" or winnertext(),49,
  result=="win" and 11 or (result=="lose" and 8 or 10))
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
 drawboard() drawfx() drawcrowns()
 camera() drawhud()
 if state=="over" then drawover() end
end