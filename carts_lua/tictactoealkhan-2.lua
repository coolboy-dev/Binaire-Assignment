-- tic tac toe
-- by alkhan

wins={
 {1,2,3},{4,5,6},{7,8,9},
 {1,4,7},{2,5,8},{3,6,9},
 {1,5,9},{3,5,7}
}

bx=15 by=20 cw=33 ch=28
mnu={"easy","normal","hard","2 players"}

function cx(i) return bx+cw*((i-1)%3)+flr(cw/2) end
function cy(i) return by+ch*flr((i-1)/3)+flr(ch/2) end

-- compact 4x7 display font used by the concept art
f4={
 a={6,9,9,15,9,9,9},b={14,9,9,14,9,9,14},
 c={7,8,8,8,8,8,7},d={14,9,9,9,9,9,14},
 e={15,8,8,14,8,8,15},f={15,8,8,14,8,8,8},
 g={7,8,8,11,9,9,7},h={9,9,9,15,9,9,9},
 i={15,6,6,6,6,6,15},j={3,1,1,1,1,9,6},
 k={9,10,12,12,10,9,9},l={8,8,8,8,8,8,15},
 m={9,15,15,9,9,9,9},n={9,13,13,11,11,9,9},
 o={6,9,9,9,9,9,6},p={14,9,9,14,8,8,8},
 q={6,9,9,9,11,10,5},r={14,9,9,14,10,9,9},
 s={7,8,8,6,1,1,14},t={15,6,6,6,6,6,6},
 u={9,9,9,9,9,9,6},v={9,9,9,9,9,6,6},
 w={9,9,9,9,15,15,9},x={9,9,6,6,6,9,9},
 y={9,9,9,6,6,6,6},z={15,1,2,4,8,8,15},
 ["0"]={6,9,11,13,9,9,6},["1"]={2,6,2,2,2,2,7},
 ["2"]={6,9,1,2,4,8,15},["3"]={14,1,1,6,1,1,14},
 ["4"]={2,6,10,10,15,2,2},["5"]={15,8,8,14,1,1,14},
 ["6"]={6,8,8,14,9,9,6},["7"]={15,1,2,2,4,4,4},
 ["8"]={6,9,9,6,9,9,6},["9"]={6,9,9,7,1,1,6},
 ["!"]={2,2,2,2,2,0,2},["."]={0,0,0,0,0,0,2}
}

function btw(s,sc)
 sc=sc or 1
 local w=0
 for i=1,#s do
  w+=(sub(s,i,i)==" " and 3 or 4)*sc+2
 end
 return w-2
end

function btxt(s,x,y,c,sc)
 sc=sc or 1
 for i=1,#s do
  local q=sub(s,i,i)
  local g=f4[q]
  if g then
   for yy=0,6 do
    for xx=0,3 do
     if g[yy+1]&(8>>xx)!=0 then
      rectfill(x+xx*sc,y+yy*sc,
       x+(xx+1)*sc-1,y+(yy+1)*sc-1,c)
     end
    end
   end
  end
  x+=(q==" " and 3 or 4)*sc+2
 end
end

function cbtxt(s,y,c,sc)
 btxt(s,flr((128-btw(s,sc))/2),y,c,sc)
end

function panel(x0,y0,x1,y1,c)
 rectfill(x0+2,y0,x1-2,y1,c)
 rectfill(x0,y0+2,x1,y1-2,c)
 rectfill(x0+1,y0+1,x1-1,y1-1,c)
end

function _init()
 pal(0,129,1)
 pal(8,142,1)
 pal(11,139,1)
 t=0 shake=0 sel=1
 vs=1 blunder=0
 xw=0 ow=0 dw=0 rn=1
 mode="menu"
 newround(1)
end

function newround(first)
 bd={} an={}
 for i=1,9 do bd[i]=0 an[i]=0 end
 turn=first
 cur=5
 wl=nil wa=0
 res=nil
 think=0
end

-- rules

function winner(b)
 for l in all(wins) do
  local a=b[l[1]]
  if a!=0 and a==b[l[2]] and a==b[l[3]] then return a,l end
 end
 return 0
end

function full(b)
 for i=1,9 do
  if b[i]==0 then return false end
 end
 return true
end

function mm(b,p,d)
 local w=winner(b)
 if w==1 then return 10-d end
 if w==2 then return d-10 end
 if full(b) then return 0 end
 local best=(p==1) and -99 or 99
 for i=1,9 do
  if b[i]==0 then
   b[i]=p
   local v=mm(b,3-p,d+1)
   b[i]=0
   if p==1 then best=max(best,v) else best=min(best,v) end
  end
 end
 return best
end

function cpumove()
 local e={}
 for i=1,9 do
  if bd[i]==0 then add(e,i) end
 end
 if rnd(1)<blunder then return rnd(e) end
 -- opening book: full search is too slow on a near-empty board
 if #e>=7 then
  if bd[5]==0 then return 5 end
  local f={}
  for i in all({1,3,7,9}) do
   if bd[i]==0 then add(f,i) end
  end
  if #f>0 then return rnd(f) end
  return rnd(e)
 end
 local best,bi=99,e[1]
 for i in all(e) do
  bd[i]=2
  local v=mm(bd,1,1)
  bd[i]=0
  if v<best then best=v bi=i end
 end
 return bi
end

function place(i)
 bd[i]=turn
 an[i]=0
 sfx(1)
 shake=max(shake,1.2)
 local w,l=winner(bd)
 if w!=0 then
  res=w wl=l wa=0
  if w==1 then xw+=1 else ow+=1 end
  shake=5
  mode="over"
  sfx(3)
 elseif full(bd) then
  res=0 dw+=1
  mode="over"
  sfx(4)
 else
  turn=3-turn
  if bd[cur]!=0 then
   for j=1,9 do
    if bd[j]==0 then cur=j break end
   end
  end
 end
end

-- update

function _update60()
 t+=1
 shake*=0.85
 if mode=="menu" then upmenu()
 elseif mode=="play" then upplay()
 elseif mode=="over" then upover() end
 for i=1,9 do
  if bd[i]!=0 and an[i]<1 then an[i]=min(an[i]+0.09,1) end
 end
 if wl then wa=min(wa+0.06,1) end
end

function upmenu()
 if btnp(2) then sel=(sel+2)%4+1 sfx(0) end
 if btnp(3) then sel=sel%4+1 sfx(0) end
 if btnp(5) then
  vs=(sel<4) and sel or 0
  blunder=({0.55,0.2,0})[sel] or 0
  xw=0 ow=0 dw=0 rn=1
  mode="play"
  newround(1)
  sfx(5)
 end
end

function upplay()
 if btnp(4) then mode="menu" sfx(5) return end
 if think>0 then
  think-=1
  if think==0 then place(cpumove()) end
  return
 end
 if vs!=0 and turn==2 then
  think=20+flr(rnd(16))
  return
 end
 local c=(cur-1)%3
 local r=flr((cur-1)/3)
 local mv=false
 if btnp(0) then c=(c+2)%3 mv=true end
 if btnp(1) then c=(c+1)%3 mv=true end
 if btnp(2) then r=(r+2)%3 mv=true end
 if btnp(3) then r=(r+1)%3 mv=true end
 if mv then cur=r*3+c+1 sfx(0) end
 if btnp(5) then
  if bd[cur]==0 then place(cur) else sfx(2) end
 end
end

function upover()
 if btnp(4) then mode="menu" sfx(5) return end
 if btnp(5) and (res==0 or wa>=1) then
  rn+=1
  newround(res==1 and 2 or 1)
  mode="play"
  sfx(5)
 end
end

-- draw

function thk(x0,y0,x1,y1,c)
 line(x0,y0,x1,y1,c)
 line(x0+1,y0,x1+1,y1,c)
 line(x0,y0+1,x1,y1+1,c)
 line(x0+1,y0+1,x1+1,y1+1,c)
end

function drawx(x,y,a,c,r)
 r=r or 9
 local p=min(a*2,1)
 thk(x-r,y-r,x-r+2*r*p,y-r+2*r*p,c)
 if a>0.5 then
  local q=(a-0.5)*2
  thk(x+r,y-r,x+r-2*r*q,y-r+2*r*q,c)
 end
end

function drawo(x,y,a,c,r,bg)
 r=r or 9
 bg=bg or 0
 local rr=max(1,flr(r*a+0.5))
 -- one clean, symmetric ring: green rim + cyan body
 circfill(x,y,rr,c==12 and 11 or c)
 if rr>1 then circfill(x,y,rr-1,c) end
 if rr>3 then circfill(x,y,rr-3,bg) end
end

function corners(x,y,c)
 local r=12+flr((sin(t/24)+1)/2)
 for sx=-1,1,2 do
  for sy=-1,1,2 do
   local xx=x+sx*r local yy=y+sy*r
   line(xx,yy,xx-sx*4,yy,c)
   line(xx,yy,xx,yy-sy*4,c)
  end
 end
end

function winspark(x,y,a)
 if a>0.15 then pset(x,y+9,10) end
 if a>0.35 then
  line(x,y+10,x,y+13,10)
  line(x-3,y+12,x+3,y+12,10)
 end
 if a>0.6 then
  pset(x-4,y+9,10) pset(x+4,y+9,10)
  pset(x-3,y+15,10) pset(x+3,y+15,10)
 end
end

function _draw()
 cls(1)
 if shake>0.3 then
  camera(rnd(shake)-shake/2,rnd(shake)-shake/2)
 else
  camera()
 end
 if mode=="menu" then drawmenu() else drawboard() end
 camera()
end

function drawmenu()
 -- oversized logo from the concept
 pset(7,8,13) pset(111,8,13)
 pset(12,38,13) pset(43,39,13) pset(95,38,13)
 drawx(17,22,1,8,12)
 drawo(111,25,1,12,11,1)
 btxt("tic tac",34,11,0,2)
 btxt("tic tac",33,10,7,2)
 cbtxt("toe",27,0,2)
 btxt("toe",flr((128-btw("toe",2))/2)-1,26,7,2)

 -- stepped paper ticket and lavender drop shadow
 panel(18,46,112,106,13)
 panel(16,44,110,104,7)
 for x=20,106,4 do
  pset(x,72,13) pset(x,87,13)
 end
 for i=1,4 do
  local y=50+(i-1)*14
  if i==sel then
   rectfill(20,y-2,106,y+8,10)
   local ax=24+flr((sin(t/18)+1)/2)
   pset(ax,y,1) line(ax+1,y+1,ax+3,y+3,1)
   line(ax+3,y+3,ax+1,y+5,1)
  end
  btxt(mnu[i],flr((128-btw(mnu[i],1))/2),y,1,1)
 end
 if t%60<44 then
  cbtxt("x to start",115,7,1)
  btxt("x",flr((128-btw("x to start",1))/2),115,8,1)
 end
end

function drawboard()
 local s="x "..xw
 btxt(s,5,5,8,1)
 s="o "..ow
 btxt(s,123-btw(s,1),5,11,1)
 s="round "..rn
 cbtxt(s,5,7,1)

 -- dark inset cells surrounded by a chunky lavender frame
 rectfill(bx-1,by-1,bx+cw*3,by+ch*3,13)
 for ry=0,2 do
  for rx=0,2 do
   local x=bx+rx*cw local y=by+ry*ch
   rectfill(x+1,y+1,x+cw-2,y+ch-2,0)
  end
 end

 for i=1,9 do
  if bd[i]==1 then drawx(cx(i),cy(i),an[i],8) end
  if bd[i]==2 then drawo(cx(i),cy(i),an[i],12) end
 end

 if mode=="play" and not (vs!=0 and turn==2) then
  corners(cx(cur),cy(cur),(turn==1) and 8 or 12)
 end

 if wl then
  for k=1,3 do
   local a=mid(0,wa*2.2-(k-1)*0.35,1)
   winspark(cx(wl[k]),cy(wl[k]),a)
  end
 end

 local msg,c,mc
 if mode=="over" then
  if res==1 then msg="x wins!" c=7 mc=8
  elseif res==2 then msg="o wins!" c=7 mc=11
  else msg="draw" c=6 end
 elseif vs!=0 then
  msg=(turn==1) and "your turn" or "thinking..."
  c=(turn==1) and 8 or 12
 else
  msg=(turn==1) and "player x" or "player o"
  c=(turn==1) and 8 or 12
 end
 local mx=flr((128-btw(msg,1))/2)
 btxt(msg,mx,110,c,1)
 if mc then btxt(sub(msg,1,1),mx,110,mc,1) end
 if mode=="over" and t%50<34 then
  cbtxt("x next  o menu",121,7,1)
  local px=flr((128-btw("x next  o menu",1))/2)
  btxt("x",px,121,8,1)
  btxt("o",px+btw("x next  ",1)+2,121,11,1)
 end
end