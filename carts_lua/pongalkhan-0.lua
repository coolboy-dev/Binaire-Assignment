--pong
--by alkhan

fnt={
".###.#...##..###.#.###..##...#.###.",
"..#...##....#....#....#....#...###.",
".###.#...#....#...#...#...#...#####",
"####.....#....#.###.....#....#####.",
"...#...##..#.#.#..#.#####...#....#.",
"######....####.....#....##...#.###.",
"..##..#...#....####.#...##...#.###.",
"#####....#...#...#...#....#....#...",
".###.#...##...#.###.#...##...#.###.",
".###.#...##...#.####....#...#..##..",
"####.#...##...#####.#....#....#....",
".###.#...##...##...##...##...#.###.",
"#...###..###..##.#.##..###..###...#",
".###.#...##....#..###...##...#.###."
}

function gl(g,x,y,s,c)
 local f=fnt[g+1]
 for r=0,6 do
  local o=r*5
  for i=0,4 do
   if sub(f,o+i+1,o+i+1)=="#" then
    rectfill(x+i*s,y+r*s,x+i*s+s-1,y+r*s+s-1,c)
   end
  end
 end
end

function txt(s,x,y,c,sh)
 if sh then print(s,x+1,y+1,sh) end
 print(s,x,y,c)
end

-- sound: written straight into sfx memory
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
 mks(0,3,{nt(40,3,5),nt(50,3,4)})
 mks(1,4,{nt(26,0,4),nt(21,0,3)})
 mks(2,8,{nt(38,4,5),nt(33,4,5),nt(28,4,4),nt(21,4,3)})
 mks(3,6,{nt(24,5,3),nt(36,5,4)})
 mks(4,7,{nt(28,5,5),nt(35,5,5),nt(40,5,5),nt(47,5,6)})
end

function _init()
 mksounds()
 t=0 shake=0 flash=0
 parts={}
 demo=true
 mode="menu"
 newgame()
end

function newgame()
 sl=0 sr=0
 pl={x=5,y=57,h=14,v=0,c=12}
 pr={x=120,y=57,h=14,v=0,c=8}
 serve(1)
end

function serve(d)
 b={x=63,y=62,vx=0,vy=0,s=1.7,d=d}
 trail={}
 wait=(mode=="menu") and 20 or 50
 aierr=rnd(9)-4.5
end

function _update60()
 t+=1
 shake*=0.86
 for p in all(parts) do
  p.x+=p.vx p.y+=p.vy
  p.vx*=0.92 p.vy*=0.92
  p.l-=1
  if p.l<=0 then del(parts,p) end
 end

 if mode=="menu" then
  demo=true
  pads() ball()
  if btnp(4) or btnp(5) then
   mode="play" demo=false
   newgame() sfx(3)
  end
 elseif mode=="play" then
  pads() ball()
 elseif mode=="over" then
  if btnp(4) or btnp(5) then
   mode="menu" newgame()
  end
 end
end

function pads()
 if demo then
  ai(pl,-1)
 else
  local a=0
  if btn(2) then a-=1 end
  if btn(3) then a+=1 end
  pl.v=(pl.v+a*0.95)*0.78
  pl.y+=pl.v
 end
 ai(pr,1)
 cl(pl) cl(pr)
end

function cl(p)
 if p.y<2 then p.y=2 p.v=0 end
 if p.y>126-p.h then p.y=126-p.h p.v=0 end
end

function ai(p,side)
 local tg=62
 if b.vx*side>0 then tg=b.y+1+aierr end
 local sp=1.9+min(sl+sr,12)*0.075
 if demo then sp=2.3 end
 local mv=mid(-sp,tg-(p.y+p.h/2),sp)
 p.v=mv p.y+=mv
end

function ball()
 if wait>0 then
  wait-=1
  if wait==0 then
   b.vx=b.d*b.s
   b.vy=rnd(1.6)-0.8
  end
  return
 end
 add(trail,{b.x,b.y})
 if #trail>9 then deli(trail,1) end
 local n=1+flr(abs(b.vx))
 for i=1,n do mv(1/n) end
end

function mv(f)
 b.x+=b.vx*f
 b.y+=b.vy*f
 if b.y<2 then b.y=2 b.vy=abs(b.vy) wallhit() end
 if b.y>124 then b.y=124 b.vy=-abs(b.vy) wallhit() end
 pad(pl,1) pad(pr,-1)
 if b.x<-8 then point(1) end
 if b.x>134 then point(-1) end
end

function pad(p,dir)
 if b.vx*dir<0
 and b.x+2>p.x and b.x<p.x+3
 and b.y+2>p.y and b.y<p.y+p.h then
  local rel=mid(-1,((b.y+1)-(p.y+p.h/2))/(p.h/2),1)
  b.s=min(b.s+0.17,4.2)
  b.vy=mid(-b.s*0.8,rel*b.s*0.72+p.v*0.18,b.s*0.8)
  b.vx=dir*sqrt(max(b.s*b.s-b.vy*b.vy,0.3))
  b.x=dir>0 and p.x+3 or p.x-2
  shake=max(shake,2.5)
  sfx(0)
  for i=1,7 do
   add(parts,{x=b.x,y=b.y+1,vx=dir*rnd(2),vy=rnd(2.4)-1.2,l=8+rnd(10),c=p.c})
  end
 end
end

function wallhit()
 shake=max(shake,1.5)
 sfx(1)
 for i=1,4 do
  add(parts,{x=b.x,y=b.y,vx=rnd(2)-1,vy=(b.vy>0 and -1 or 1)*rnd(1.2),l=10+rnd(8),c=6})
 end
end

function point(w)
 shake=6 flash=5
 sfx(2)
 local ex=w>0 and 2 or 126
 local dx=w>0 and 1 or -1
 for i=1,24 do
  add(parts,{x=ex,y=mid(2,b.y,124),vx=dx*rnd(2.5),vy=rnd(4)-2,
             l=18+rnd(16),c=rnd(1)<0.5 and 7 or 10})
 end
 if mode=="play" then
  if w>0 then sr+=1 else sl+=1 end
  if sl>=7 or sr>=7 then
   mode="over"
   win=(sl>=7) and "p" or "c"
   sfx(4)
   return
  end
 end
 serve(w>0 and -1 or 1)
end

function _draw()
 local bg=0
 if flash>0 then
  flash-=1
  bg=(flash>2) and 7 or 1
 end
 cls(bg)

 if shake>0.3 then
  camera(rnd(shake)-shake/2,rnd(shake)-shake/2)
 else
  camera()
 end

 for y=2,124,7 do rectfill(63,y,64,y+3,1) end
 gl(min(sl,9),33,12,3,1)
 gl(min(sr,9),79,12,3,1)

 for i=1,#trail do
  local q=trail[i]
  rectfill(q[1],q[2],q[1]+1,q[2]+1,i<4 and 1 or (i<7 and 5 or 6))
 end

 for p in all(parts) do pset(p.x,p.y,p.c) end

 rectfill(pl.x,pl.y,pl.x+2,pl.y+pl.h-1,pl.c)
 rectfill(pr.x,pr.y,pr.x+2,pr.y+pr.h-1,pr.c)
 if wait<=0 then rectfill(b.x,b.y,b.x+1,b.y+1,7) end

 camera()

 if mode=="menu" then
  local x=28
  for i=10,13 do
   gl(i,x+1,27,3,1)
   gl(i,x,26,3,7)
   x+=19
  end
  txt("first to 7",44,52,6)
  if t%60<42 then txt("press x to start",32,84,7,1) end
  txt("up / down : move paddle",18,110,5)
 elseif mode=="over" then
  rectfill(30,46,97,74,0)
  rect(30,46,97,74,1)
  txt(win=="p" and "you win!" or "cpu wins",48,53,win=="p" and 11 or 8,1)
  if t%60<42 then txt("press x",50,65,7,1) end
 end
end