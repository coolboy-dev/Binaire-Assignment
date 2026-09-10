-- nim
-- by alkhan
-- neon take-away edition

-- states: splash, menu, player, anim, ai, over
default_rows={1,3,5,7}
menu_items={"start game","difficulty"}

-- tiny sound builder ---------------------------------------------------------

function nt(p,w,v) return p+w*64+v*512 end

function mks(n,sp,ns)
 local a=0x3200+68*n
 for i=0,31 do
  local v=ns[i+1] or 0
  poke(a+i*2,v&255)
  poke(a+i*2+1,(v>>8)&255)
 end
 poke(a+64,0) poke(a+65,sp) poke(a+66,0) poke(a+67,0)
end

function mksounds()
 mks(0,3,{nt(28,3,3),nt(35,3,4)})
 mks(1,5,{nt(36,5,5),nt(31,5,4),nt(24,5,3)})
 mks(2,5,{nt(25,1,5),nt(20,1,4),nt(16,1,3)})
 mks(3,6,{nt(31,3,5),nt(36,3,5),nt(43,3,6)})
 mks(4,6,{nt(19,2,5),nt(15,2,4),nt(12,2,3)})
 mks(5,4,{nt(24,4,4),nt(31,4,5),nt(40,4,6),nt(48,4,6)})
end

-- setup and rules ------------------------------------------------------------

function _init()
 poke(0x5f2d,1) -- mouse input in desktop/browser exports
 mksounds()
 srand(time())
 t=0 state="splash" diff=2 msel=1
 parts={} ghosts={}
 flash=0 shake=0 msg="" msgt=0 winner=nil
 mx=stat(32) my=stat(33) lmx=mx lmy=my oldmb=stat(34)
 usemouse=false hover_r=0 hover_i=0
 newgame(default_rows)
 state="splash"
end

function validcfg(a)
 if not a or #a<2 or #a>8 then return false end
 for v in all(a) do
  if type(v)!="number" or v!=flr(v) or v<1 or v>15 then return false end
 end
 return true
end

function newgame(a)
 if not validcfg(a) then a=default_rows end
 rows={} caps={}
 for v in all(a) do add(rows,v) add(caps,v) end
 state="player" winner=nil
 pturn=1
 ait=0 animt=0 animwho=nil
 currow=1 curi=1
 for i=1,#rows do
  if rows[i]>0 then currow=i curi=1 break end
 end
 parts={} ghosts={}
 flash=0 shake=0 msg=diff==3 and "player 1 turn" or "your move" msgt=45
end

function modename()
 return diff==1 and "easy" or (diff==2 and "perfect" or "2 players")
end

function cyclediff(d)
 diff=(diff-1+d)%3+1
end

function playeractor()
 return diff==3 and (pturn==1 and "p1" or "p2") or "player"
end

function humanactor(who)
 return who!="cpu"
end

function winnername()
 if winner=="p1" then return "player 1 wins!" end
 if winner=="p2" then return "player 2 wins!" end
 return winner=="player" and "you win!" or "computer wins"
end

function total()
 local n=0
 for v in all(rows) do n+=v end
 return n
end

function nimsum()
 local n=0
 for v in all(rows) do n=n^^v end
 return n
end

function validmove(r,n)
 return r>=1 and r<=#rows and rows[r]>0 and n>=1 and n<=rows[r]
end

function rowy(r)
 if #rows==2 then return 53+(r-1)*33 end
 return 40+(r-1)*58/(#rows-1)
end

function stonex(r,i)
 return 64-(caps[r]-1)*4+(i-1)*8
end

function burst(x,y,c,n,pow)
 for i=1,n do
  local a=rnd(1)
  local sp=0.35+rnd(pow)
  add(parts,{x=x,y=y,vx=cos(a)*sp,vy=sin(a)*sp,
   l=9+rnd(14),m=23,c=(rnd(1)<0.25) and 7 or c})
 end
end

function beginmove(r,n,who)
 if state!=(humanactor(who) and "player" or "ai") then return false end
 if not validmove(r,n) then return false end
 local old=rows[r]
 state="anim" animwho=who animt=18
 for i=old-n+1,old do
  local x,y=stonex(r,i),rowy(r)
  local c=who=="cpu" and 8 or (who=="p2" and 14 or 12)
  add(ghosts,{x=x,y=y,vx=rnd(1.4)-0.7,vy=-0.6-rnd(1.1),l=18,m=18,c=c})
  burst(x,y,c,3,1.4)
 end
 rows[r]-=n
 local who_text=who=="cpu" and "cpu" or (who=="p1" and "p1" or (who=="p2" and "p2" or "you"))
 msg=who_text.." took "..n
 msgt=55 flash=3 shake=2.4
 sfx(humanactor(who) and 1 or 2)
 return true
end

function finishmove()
 if total()==0 then
 state="over" winner=animwho
  msg=winnername()
  msgt=999
  shake=6 flash=7
  for i=1,42 do
   local c=winner=="cpu" and 8 or (winner=="p2" and 14 or 10)
   burst(64+rnd(50)-25,55+rnd(45),c,1,2.4)
  end
  sfx(humanactor(winner) and 5 or 4)
 elseif diff==3 and humanactor(animwho) then
  pturn=3-pturn
  state="player"
  findcursor()
  msg="player "..pturn.." turn" msgt=45
 elseif humanactor(animwho) then
  state="ai" ait=42 -- 700ms at 60fps
  msg="computer is thinking..." msgt=50
 else
  state="player"
  findcursor()
  msg="your move" msgt=45
 end
end

function findcursor()
 if rows[currow]>0 then curi=min(curi,rows[currow]) return end
 for d=1,#rows do
  local r=(currow-1+d)%#rows+1
  if rows[r]>0 then currow=r curi=min(curi,rows[r]) return end
 end
end

function randommove()
 local e={}
 for i=1,#rows do if rows[i]>0 then add(e,i) end end
 local r=e[1+flr(rnd(#e))]
 return r,1+flr(rnd(rows[r]))
end

function perfectmove()
 local ns=nimsum()
 if ns!=0 then
  for r=1,#rows do
   local target=rows[r]^^ns
   if target<rows[r] then return r,rows[r]-target end
  end
 end
 return randommove()
end

function aimove()
 if diff==3 or state!="ai" or total()==0 then return false end
 local r,n
 if diff==1 then r,n=randommove() else r,n=perfectmove() end
 return beginmove(r,n,"cpu")
end

-- input ----------------------------------------------------------------------

function mouseupdate()
 mx=stat(32) my=stat(33)
 local mb=stat(34)
 mclick=(mb&1)>0 and (oldmb&1)==0
 if mx!=lmx or my!=lmy then usemouse=true end
 lmx=mx lmy=my oldmb=mb
end

function anypress()
 return btnp()!=0 or mclick
end

function hit(x0,y0,x1,y1)
 return mx>=x0 and mx<=x1 and my>=y0 and my<=y1
end

function move_row(d)
 for k=1,#rows do
  local r=(currow-1+d*k)%#rows+1
  if rows[r]>0 then
   currow=r curi=min(curi,rows[r]) sfx(0) return
  end
 end
end

function playerinput()
 hover_r=0 hover_i=0
 if usemouse then
  for r=1,#rows do
   if rows[r]>0 and abs(my-rowy(r))<=5 then
    for i=1,rows[r] do
     if abs(mx-stonex(r,i))<=4 then hover_r=r hover_i=i end
    end
   end
  end
 end

 if btnp(0) then curi=max(1,curi-1) usemouse=false sfx(0) end
 if btnp(1) then curi=min(rows[currow],curi+1) usemouse=false sfx(0) end
 if btnp(2) then move_row(-1) usemouse=false end
 if btnp(3) then move_row(1) usemouse=false end

 if mclick and hover_r>0 then
  beginmove(hover_r,rows[hover_r]-hover_i+1,playeractor())
 elseif btnp(5) then
  beginmove(currow,rows[currow]-curi+1,playeractor())
 end
end

function menuinput()
 if btnp(2) or btnp(3) then msel=3-msel usemouse=false sfx(0) end
 if msel==2 and btnp(0) then cyclediff(-1) sfx(0) end
 if msel==2 and btnp(1) then cyclediff(1) sfx(0) end
 if usemouse then
  if hit(20,65,107,79) then msel=1 end
  if hit(20,84,107,98) then msel=2 end
 end
 if mclick then
  if hit(20,65,107,79) then newgame(default_rows) sfx(3) end
  if hit(20,84,107,98) then cyclediff(1) sfx(0) end
 elseif btnp(5) then
  if msel==1 then newgame(default_rows) sfx(3)
  else cyclediff(1) sfx(0) end
 end
end

function updatefx()
 shake*=0.84
 if flash>0 then flash-=1 end
 if msgt>0 then msgt-=1 end
 for p in all(parts) do
  p.x+=p.vx p.y+=p.vy p.vx*=0.96 p.vy=p.vy*0.96+0.025
  p.l-=1
  if p.l<=0 then del(parts,p) end
 end
 for g in all(ghosts) do
  g.x+=g.vx g.y+=g.vy g.vy+=0.08 g.l-=1
  if g.l<=0 then del(ghosts,g) end
 end
end

function _update60()
 t+=1 mouseupdate() updatefx()

 if state=="splash" then
  if anypress() then state="menu" sfx(3) end
  return
 end
 if state=="menu" then menuinput() return end

 -- restart is always live during a match
 if btnp(4) or (mclick and hit(4,116,39,126)) then
  newgame(default_rows) sfx(3) return
 end

 if state=="player" then
  playerinput()
 elseif state=="anim" then
  animt-=1
  if animt<=0 then finishmove() end
 elseif state=="ai" then
  ait-=1
  if ait<=0 then aimove() end
 elseif state=="over" then
  if btnp(5) or (mclick and hit(43,101,85,113)) then
   newgame(default_rows) sfx(3)
  elseif mclick and hit(91,116,124,126) then
   state="menu" sfx(0)
  end
 end
end

-- drawing --------------------------------------------------------------------

function center(s,y,c)
 print(s,64-#s*2,y,c)
end

function panel(x0,y0,x1,y1,c,fill)
 rectfill(x0+2,y0,x1-2,y1,fill or 0)
 rectfill(x0,y0+2,x1,y1-2,fill or 0)
 rect(x0+1,y0+1,x1-1,y1-1,c)
 pset(x0+1,y0+1,7) pset(x1-1,y0+1,7)
end

lg={
 n={17,25,29,23,19,17,17},
 i={31,4,4,4,4,4,31},
 m={17,27,21,21,17,17,17}
}

function bigchar(ch,x,y,s,c)
 local g=lg[ch]
 for yy=0,6 do
  for xx=0,4 do
   if (g[yy+1]&(16>>xx))!=0 then
    rectfill(x+xx*s,y+yy*s,x+(xx+1)*s-1,y+(yy+1)*s-1,c)
   end
  end
 end
end

function logo(y,s)
 local w=17*s
 local x=64-flr(w/2)
 for i=1,3 do
  local ch=sub("nim",i,i)
  bigchar(ch,x+1,y+2,s,2)
  bigchar(ch,x,y,s,(i==2) and 10 or 12)
  x+=6*s
 end
end

function drawbg()
 cls(1)
 rectfill(0,0,127,18,0)
 rectfill(0,19,127,20,2)
 for i=1,18 do
  local x=(i*47+flr(t/3))%132-2
  local y=(i*29)%112+4
  pset(x,y,(i%4==0) and 12 or (i%3==0 and 13 or 5))
 end
 for y=24,124,4 do
  if y%8==0 then line(0,y,127,y,0) end
 end
end

function drawgrid()
 local hy=102
 line(0,hy,127,hy,2)
 for y=104,127,5 do line(0,y,127,y,2) end
 for x=-64,192,16 do line(64,hy,x,127,2) end
end

function drawstone(x,y,c,selected)
 if selected then
  circfill(x,y,5,2)
  circ(x,y,4,(t%12<6) and 10 or 9)
 end
 circfill(x+1,y+2,3,0)
 circfill(x,y,3,c)
 circfill(x-1,y-1,1,7)
 pset(x+2,y+1,13)
end

function drawparts()
 for p in all(parts) do
  local c=p.l<5 and 5 or p.c
  line(p.x,p.y,p.x-p.vx*2,p.y-p.vy*2,c)
  pset(p.x,p.y,7)
 end
 for g in all(ghosts) do
  local r=max(1,ceil(3*g.l/g.m))
  circfill(g.x,g.y,r,g.c)
  pset(g.x-1,g.y-1,7)
 end
end

function drawcursor()
 if not usemouse then return end
 line(mx,my,mx+5,my+3,7)
 line(mx,my,mx+1,my+6,7)
 pset(mx+2,my+3,12)
end

function drawsplash()
 drawbg() drawgrid()
 logo(25,4)
 center("neon take-away",62,13)
 for i=1,7 do
  local x=37+(i-1)*9
  drawstone(x,80+sin(t/90+i/9)*2,(i%2==0) and 14 or 12,false)
 end
 if t%60<44 then
  panel(24,99,103,113,12,0)
  center("press any button",104,7)
 end
 center("mouse / arrows + x",120,5)
 drawcursor()
end

function drawmenu()
 drawbg()
 logo(7,3)
 center("choose your opponent",48,6)
 for i=1,2 do
  local y=(i==1) and 65 or 84
  local sel=(msel==i)
  panel(20,y,107,y+14,sel and ((t%24<12) and 12 or 10) or 5,0)
  if i==1 then
   center("start game",y+5,sel and 7 or 6)
  else
   center("<  "..modename().."  >",y+5,sel and 7 or 6)
  end
 end
 local hint=diff==1 and "cpu chooses randomly" or (diff==2 and "cpu knows the nim sum" or "take turns on one screen")
 center(hint,106,13)
 center("remove a stone + all to right",117,5)
 drawcursor()
end

function drawfield()
 local pr,pi=0,0
 if state=="player" then
  if usemouse then pr,pi=hover_r,hover_i else pr,pi=currow,curi end
 end
 for r=1,#rows do
  local y=rowy(r)
  print(r,3,y-2,5)
  line(10,y,18,y,2)
  if rows[r]==0 then
   for x=24,104,8 do pset(x,y,5) end
   print("empty",107,y-2,5)
  else
   for i=1,rows[r] do
    local picked=(r==pr and i>=pi)
    drawstone(stonex(r,i),y,picked and 10 or 12,picked)
   end
  end
 end
end

function drawhud()
 panel(24,3,103,16,state=="over" and (winner=="cpu" and 8 or 10) or 12,0)
 local s
 if state=="player" then s=diff==3 and "player "..pturn.." turn" or "your turn"
 elseif state=="ai" then s="cpu thinking"
 elseif state=="anim" then s=animwho=="cpu" and "cpu move" or (animwho=="p1" and "player 1 move" or (animwho=="p2" and "player 2 move" or "nice move!"))
 else s=winnername() end
 center(s,8,state=="over" and 7 or 6)
 print("stones "..total(),3,22,13)
 local mn=modename()
 print(mn,123-#mn*4,22,13)
 if msgt>0 and state!="over" then center(msg,106,13) end
 rectfill(4,116,39,126,0) rect(4,116,39,126,5)
 print("o restart",6,120,6)
end

function drawover()
 rectfill(17,35,110,96,0)
 panel(17,35,110,96,winner=="cpu" and 8 or 10,0)
 logo(42,2)
 local result=winner=="player" and "you cleared the board!" or (winner=="cpu" and "the machine wins" or winnername())
 center(result,67,winner=="cpu" and 8 or 10)
 center("last stone takes it",79,6)
 if t%50<38 then center("press x to play again",88,7) end
 panel(43,101,85,113,12,0) center("play again",105,7)
 rectfill(91,116,124,126,0) rect(91,116,124,126,5)
 print("menu",100,120,6)
end

function _draw()
 if state=="splash" then drawsplash() return end
 if state=="menu" then drawmenu() return end
 drawbg()
 if shake>0.25 then camera(rnd(shake)-shake/2,rnd(shake)-shake/2) end
 drawfield() drawparts()
 camera()
 drawhud()
 if state=="over" then drawover() end
 if flash>0 then
  rect(0,0,127,127,(flash%2==0) and 7 or (winner=="cpu" and 8 or 12))
  rect(1,1,126,126,flash%2==0 and 10 or 2)
 end
 drawcursor()
end