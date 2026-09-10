-- pushy penguins
-- mario party style survival

-- art slots (redraw freely):
--   1 player idle   4 player stride
--   2 penguin step a  3 penguin step b
-- sfx slots:
--   0 shove       1 player splash
--   2 start       3 penguin plop
--   4-7 free
-- music slots (patterns 0-3):
--   8 bass a   9 pad a
--   10/11 melody a   12 bass b
--   13 pad b   14/15 melody b
-- music keeps to 3 channels so sfx
-- always have channel 4 to itself

-- the floe sits in open water on three
-- sides. penguins march in fixed lanes,
-- which lets us reserve a corridor that
-- is guaranteed to stay open every wave.
lanes=11
lane_h=10
lane_y0=14
ice_l=9
ice_t=9
ice_b=118
wall_x=120

function _init()
 cartdata("pushy_penguins")
 best=dget(0)
 -- frozen-in sparkle, drawn every frame
 specks={}
 for i=1,50 do
  add(specks,{
   x=ice_l+2+flr(rnd(112)),
   y=ice_t+2+flr(rnd(105)),
   c=rnd()<.6 and 7 or 5})
 end
 parts={}
 shk=0
 plop_cd=0
 to_title()
 -- runs unbroken from boot onward
 music(0)
end

function to_title()
 mode="title"
 t=0
 pens={}
 parts={}
 diff=.12
 spd=.9
 gc=6
 sp_t=20
end

function start_game()
 mode="play"
 t=0
 score=0
 sc_t=0
 pens={}
 parts={}
 gc=6
 sp_t=45
 shk=0
 p={x=88,y=64,vx=0,vy=0,
    push=0,face=-1,anim=0}
 sfx(2)
end

function _update()
 t+=1
 -- full pressure inside a minute
 if mode=="title" then
  diff=.12
 else
  diff=min(t/1800,1)
 end
 -- every penguin alive shares one speed,
 -- so waves can never merge and seal a
 -- corridor shut
 spd=.9+diff*.9
 lvl=1+flr(diff*9)

 plop_cd-=1
 update_pens()
 update_parts()
 if shk>0 then
  shk*=.85
  if shk<.3 then shk=0 end
 end

 if mode=="title" then
  if btnp(5) then start_game() end
 elseif mode=="play" then
  update_player()
  sc_t+=1
  if sc_t>=30 then
   sc_t=0
   score+=10+lvl*5
  end
 elseif mode=="fall" then
  fall_t+=1
  p.x+=p.vx
  p.y+=p.vy
  p.vy+=.14
  p.vx*=.94
  if fall_t>32 then game_over() end
 elseif mode=="over" then
  over_t+=1
  if over_t>18 and btnp(5) then
   start_game()
  end
 end
end

function game_over()
 mode="over"
 over_t=0
 newbest=false
 if score>best then
  best=score
  dset(0,best)
  newbest=true
 end
end

-->8
-- the crowd

function update_pens()
 sp_t-=1
 if sp_t<=0 then spawn_wave() end
 for pn in all(pens) do
  -- nothing slows a penguin down
  pn.x-=spd
  -- they dive off the far lip. a whole
  -- rank lands at once, so the plop is
  -- rationed rather than machine-gunned
  if pn.x<ice_l-2 then
   splash(pn.x,pn.y,2)
   if plop_cd<=0 then
    sfx(3)
    plop_cd=7
   end
   del(pens,pn)
  end
 end
end

function spawn_wave()
 -- reserve the escape corridor first.
 -- it always shifts 2-3 lanes, so
 -- standing still is never an option,
 -- and never more than 3, so it is
 -- always reachable in time.
 local gs=2-flr(diff*1.5)
 local hi=lanes-gs+1
 -- 2 lanes always, 3 only while there is
 -- still slack in the timing. a solid
 -- crowd pins you until it has passed,
 -- so late waves must stay inside what
 -- is physically reachable.
 local d=2+flr(rnd(2-diff))
 if rnd()<.5 then d=-d end
 -- bounce off the ends instead of
 -- clamping, which would stall the drift
 if gc+d<1 or gc+d>hi then d=-d end
 gc=mid(1,gc+d,hi)

 -- mostly small clusters, sometimes a
 -- near-solid crowd. the opening few
 -- seconds never throw a big one.
 local big=diff>.08 and rnd()<.06+diff*.3

 -- lanes the corridor doesn't own
 local open={}
 for i=1,lanes do
  if i<gc or i>=gc+gs then add(open,i) end
 end

 local picks={}
 if big then
  picks=open
 else
  -- clusters start as pairs and thicken
  -- until they are nearly walls
  local n=2+flr(diff*3)+flr(rnd(2+diff*3))
  local s=flr(rnd(#open))
  for i=0,n-1 do
   add(picks,open[(s+i)%#open+1])
  end
 end

 local bx=132+rnd(6)
 for k in all(picks) do
  add_pen(bx+rnd(8),k)
 end
 -- a big crowd gets a second rank
 if big then
  for k in all(picks) do
   if rnd()<.6 then
    add_pen(bx+11+rnd(6),k)
   end
  end
 end

 sp_t=flr(35-diff*20)+flr(rnd(5))
 if big then sp_t+=10 end
end

function add_pen(x,lane)
 add(pens,{
  x=x,
  y=lane_y0+(lane-1)*lane_h,
  ph=rnd(8)})
end

-->8
-- player

-- half-extent of a body. two of them
-- must be this far apart to not touch.
pw=7

-- the penguin overlapping x,y, if any
function hits(x,y)
 for pn in all(pens) do
  if abs(pn.x-x)<pw
  and abs(pn.y-y)<pw then
   return pn
  end
 end
end

-- would a step to nx,ny wedge us deeper
-- into a body? sliding back out is
-- always allowed, pressing in never is,
-- so the crowd cannot be brute-forced.
function deeper(nx,ny,horiz)
 for pn in all(pens) do
  if abs(pn.x-nx)<pw
  and abs(pn.y-ny)<pw then
   local od,nd
   if horiz then
    od=abs(pn.x-p.x) nd=abs(pn.x-nx)
   else
    od=abs(pn.y-p.y) nd=abs(pn.y-ny)
   end
   if nd<od then return true end
  end
 end
 return false
end

function update_player()
 -- 8-way input
 local ax,ay=0,0
 if btn(0) then ax-=1 end
 if btn(1) then ax+=1 end
 if btn(2) then ay-=1 end
 if btn(3) then ay+=1 end
 if ax!=0 and ay!=0 then
  ax*=.7 ay*=.7
 end
 if ax!=0 then
  p.face=ax<0 and -1 or 1
 end

 -- shoving back barely works: go around
 p.push=hits(p.x,p.y) and spd or 0
 if p.push>0 and ax>0 then ax*=.35 end

 p.vx+=ax*.3
 p.vy+=ay*.3
 p.vx*=.86
 p.vy*=.86

 -- our own movement, one axis at a time,
 -- refused wherever it would press into
 -- a body
 local nx=p.x+p.vx
 if deeper(nx,p.y,true) then
  nx=p.x p.vx=0
 end
 p.x=nx
 local ny=p.y+p.vy
 if deeper(p.x,ny,false) then
  ny=p.y p.vy=0
 end
 p.y=ny

 -- whatever still overlaps us got there
 -- under its own steam, and carries us
 if hits(p.x,p.y) then
  p.x-=spd
  p.push=spd
 end

 if p.push>0 and t%8==0 then sfx(0) end

 -- right edge is a solid ice wall
 if p.x>wall_x then
  p.x=wall_x
  p.vx=0
 end

 if abs(p.vx)+abs(p.vy)>.4 then
  p.anim+=1
 else
  p.anim=0
 end

 -- off the top, bottom or left: gone
 if p.x<ice_l or p.y<ice_t or p.y>ice_b then
  fall_in()
 end
end

function fall_in()
 mode="fall"
 fall_t=0
 shk=5
 sfx(1)
 splash(p.x,p.y,12)
end

function splash(x,y,n)
 for i=1,n do
  add(parts,{
   x=x,y=y,
   vx=rnd(3)-1.5,
   vy=-rnd(2.2)-.3,
   l=14+rnd(12)})
 end
end

function update_parts()
 for q in all(parts) do
  q.x+=q.vx
  q.y+=q.vy
  q.vy+=.18
  q.l-=1
  if q.l<=0 then del(parts,q) end
 end
end

-->8
-- drawing

function _draw()
 cls(6)
 if shk>0 then
  camera(rnd(shk)-shk/2,rnd(shk)-shk/2)
 else
  camera()
 end

 draw_ice()

 for pn in all(pens) do
  spr(2+flr((t/4+pn.ph)%2),pn.x-4,pn.y-4)
 end

 if mode=="play" or mode=="fall" then
  local s=1
  if p.anim>0
  and flr(p.anim/4)%2==1 then s=4 end
  local jx=0
  if mode=="play" and p.push>0 then
   jx=t%2
  end
  spr(s,p.x-4+jx,p.y-4,1,1,p.face>0)
 end

 for q in all(parts) do
  pset(q.x,q.y,q.l>8 and 7 or 12)
 end

 camera()
 if mode=="title" then
  draw_title()
 elseif mode=="over" then
  draw_over()
 else
  draw_hud()
 end
end

function draw_ice()
 -- open sea. drawn across everything,
 -- then the floe is laid on top of it,
 -- so no clipping is needed. rows the
 -- floe will cover only get their left
 -- strip stroked.
 rectfill(-4,-4,131,131,1)
 for y=-4,131,3 do
  local xm=131
  if y>=ice_t and y<=ice_b then
   xm=ice_l-1
  end
  local o=sin((y*8+t*3)/128)*9
  for x=-20,xm,13 do
   line(x+o,y,x+o+4,y,13)
  end
  o=sin((y*5-t*2)/128)*7
  for x=-14,xm,19 do
   pset(x+o,y+1,12)
  end
 end
 -- the floe
 rectfill(ice_l,ice_t,131,ice_b,6)
 for s in all(specks) do
  pset(s.x,s.y,s.c)
 end
 -- sunlit lip on the three open sides
 rectfill(ice_l,ice_t,131,ice_t+1,7)
 rectfill(ice_l,ice_b-1,131,ice_b,7)
 rectfill(ice_l,ice_t,ice_l+1,ice_b,7)
 -- packed snow wall on the right
 rectfill(125,ice_t,131,ice_b,7)
 rectfill(124,ice_t,124,ice_b,5)
end

function pr(s,x,y,c,sc)
 print(s,x+1,y+1,sc or 0)
 print(s,x,y,c)
end

function draw_hud()
 -- rides in the water margin, clear of
 -- the floe
 pr("score "..score,11,2,7)
 local s="lv "..lvl
 -- pr(s,122-#s*4,2,7)
 if mode=="play" and t<45
 and t%16<11 then
  pr("go!",58,60,8,7)
 end
end

function draw_title()
 rectfill(0,28,127,66,1)
 rectfill(0,27,127,27,12)
 rectfill(0,67,127,67,12)
 print("\^w\^tpushy",44,32,7)
 print("\^w\^tpenguins",32,48,12)
 pr("outlast the waddling crowd",13,78,1,7)
 if best>0 then
  local s="best "..best
  pr(s,64-#s*2,92,1,7)
 end
 if t%30<20 then
  pr("press x to start",32,108,1,7)
 end
end

function draw_over()
 rectfill(0,40,127,88,1)
 rectfill(0,39,127,39,12)
 rectfill(0,89,127,89,12)
 print("\^w\^tpushed in!",24,45,7)
 local s="score "..score
 print(s,64-#s*2,64,7)
 if newbest then
  if t%20<14 then
   print("new best!",46,74,10)
  end
 else
  s="best "..best
  print(s,64-#s*2,74,12)
 end
 if over_t>18 and t%30<20 then
  pr("press x to retry",32,104,1,7)
 end
end
