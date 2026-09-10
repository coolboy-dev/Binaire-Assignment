--da game

function _init() 
p={x=24,y=72,st=-1} 
pc=5
tds=0
score=0
st=false

p_ani={32,33}
s_ani={0,0,0,0,0,-1,-1,-1,-1,-2}

sharks={{x=-100,y=0,lt=-1}}
wood={} 
bubl={}

tiles={{x=p.x, y=p.y, lt=100, nt=45, nc=1,s=2,pv=true}} 
latl={x=p.x, y=p.y, lt=100, nt=45, nc=1}
r=1
dx={-1,1,0,0}
dy={0, 0,-1,1}
cx=128

seq=
{ 
{{8,0},{8,0},{0,-8},{0,-8},{8,0},{8,0},{0,8},{0,8}}, 
{{8,0},{8,0},{8,0},{0,-8},{8,0},{0,-8},{8,0},{8,0},{0,8},{0,8}},
{{8,0},{8,0},{0,8},{0,8},{8,0},{8,0},{0,-8},{0,-8},{0,-8},{0,-8},{0,-8},{8,0},{8,0},{8,0},{0,8},{0,8},{0,8}},
{{8,0},{8,0},
{0,8},{0,8},{0,8},{0,8},
{8,0},{8,0},{8,0},
{0,-8},{0,-8},{-8,0},
{0,-8},{0,-8},
{8,0},{8,0}},
{{8,0},{8,0},{0,-8},{8,0},{8,0},{0,8},{8,0}},
{{8,0},{8,0},{8,0},{0,8},{0,8},{8,0},{8,0},{0,-8},{8,0},{8,0},{0,8},{8,0},{8,0},{0,-8},{0,-8}},
{{8,0},{8,0},{0,8},{0,8},{0,8},{0,8},{0,8},{8,0},{8,0},{0,-8},{0,-8},{0,-8},{0,-8},{0,-8}},
{{8,0},{8,0},{0,-8},{0,-8},{0,-8},{0,-8},{0,-8},{8,0},{8,0},{0,8},{0,8},{0,8},{0,8},{0,8},{0,8},{8,0},{8,0},{0,-8}}
}

t=0

end

function _update60() 
tds-=1
if st==false then
	if btnp(❘) then
		st=true
		restart()
	end
end

if st==true then
if p.st!=0  or sharks[#sharks].lt!=1 then
	pc=pch()
	if pc==0	or p.x<0 then
		p.st=0
		hrust(p.x,p.y)
--		opilk(p.x,p.y,rnd(3)+10,8)
		sfx(3)
		tds=25
	end
	if t%60==0 then
		score+=1
	end
		if t%15==0 then
			bauble(rnd(128),rnd(128),1)
		end
	for i=1,4 do
	 if btnp(i-1) and p.st!=0 then
	  p.x+=dx[i]*8
	  p.y+=dy[i]*8
	  cx+=dx[i]*8
	 end
	end
	if tiles[#tiles].x < cx-1 then
	 adroad() 
	end
	
	for v in all(bubl) do
		v.x-=0.2
		if v.r<0 then
			del(bubl,v)
		end
		v.tn-=1
		if v.tn<=0 then
			v.r-=1
			v.tn=5
		end
	end
		
	for i=0,16 do
		bauble(0+rnd(2),i*8+rnd(4)-2,rnd(2)+1,6+rnd(2))
	end
		
	for v in all(sharks) do
		v.lt-=1
		if v.lt==0 then
			del(sharks,v)
		end	
	end
	
	p.x-=0.2
	
	t+=1

	end
	
end	
	
end

function _draw() 
cls(12)
	
	for v in all(bubl) do
		circ(v.x,v.y,v.r,v.c)
	end
	
		
	
for v in all(tiles) do
		if p.st!=0 then
			v.x-=0.2
			v.nt-=1
			if v.nt <=0 then
		  v.y+=v.nc
		  v.nc=-v.nc
		  v.nt=45
		 end
		 if near(v.x,p.x) and near(v.y,p.y) then
		  v.lt-=1
		  v.pv=true
		  if t%5==0 then	opilk(v.x,v.y,1) end
		 elseif v.pv==true then
		 	v.lt-=0.5
		 end
		 if v.lt<=0 and v.s<38 then
		  bauble(v.x+4,v.y+4,5)
		  v.s=38+flr(rnd(3)) 
		  opilk(v.x,v.y,rnd(3)+4)
		  sfx(0,1)
		  v.pv=true
		 elseif v.lt<20 and v.s<35 then
		 	v.s=35+flr(rnd(3))
		 	sfx(0,1)
		 end
		 if v.x<0 then
		 	hrust(v.x,v.y)
		 	bauble(v.x,v.y,10)
		 	opilk(v.x,v.y,rnd(3)+2)
		 	del(tiles,v)
		 end
		end
 spr(v.s,v.x,v.y)
end

 for v in all(wood) do
   rect(v.x,v.y,v.x1,v.y1,v.c)
   v.x,v.y=rotation(v.x,v.y,v.cx,v.cy)
   v.x1,v.y1=rotation(v.x1,v.y1,v.cx,v.cy)
   v.cx+=v.sx
   v.cy+=v.sy
   v.lt-=1
   if v.lt<1 then
   	bauble(v.x,v.y,1)
   	del(wood,v)
   end   
 end
	
	

if p.st==1 then
	spr(getframe(p_ani),p.sx,p.sy-4)
else	
	spr(getframe(p_ani),p.x,p.y-4)
end	


	for v in all(sharks) do
		if v.lt>1 then
			spr(3,v.x,v.y)
			spr(4,v.x,v.y+s_ani[v.lt%#s_ani+1])
		else
			spr(5,v.x,v.y)
		end
	end
	
	if p.st!=0 then
		spr(68,0,96,4,4)
		print(score,14,115,7)
	else
		spr(72,0,96,4,4)	
		da_end()
	end

if st==false and tds<=0 then
	rrectfill(25,30,80,20,2,1)
	rrect(26,31,78,18,2,7)	
	print("press ❘ to start",32,36)
end
	
end

-->8
--otter (misc)

function opilk(_x,_y,_im,_c)
 if _c==nil then _c=4-flr(rnd(2))*2 end
 for i=1,_im do
  add(wood, {x=_x, y=_y, 
  x1=_x, y1=_y, 
  cx=_x, cy=_y, 
  c=_c,
  sx=flr(rnd(5))-2,
  sy=flr(rnd(5))-2,
  lt=10})
 end
end

function near(_n, _n1)
 if _n==_n1 or _n+1==_n1 or _n-1==_n1 then
  return true
 else
  return false
 end
end

function adroad()
 latl=tiles[#tiles]
 for i=1,#seq[r] do
   add(tiles, {x=latl.x+seq[r][i][1],
   y=latl.y+seq[r][i][2],
   nt=latl.nt,nc=latl.nc,
   lt=50-rnd(14)*2, s=2,pv=false})
   latl=tiles[#tiles]
 end
 r=flr(rnd(#seq))+1
end

function rotation(x,y,cx,cy)
	local a=(t*2)/40
	 x=cx+cos(a)*rnd(3)+2
	 y=cy+sin(a)*rnd(3)+2
	 return x,y
end

function bauble(_x,_y,_r,_c)
	if _c==nil then _c=7 end
	add(bubl,{x=_x,y=_y,r=_r,c=_c,tn=5})
end

function getframe(ani)
	return ani[flr(t/8)%#ani+1]
end

function hrust(_x,_y)
	add(sharks,{x=_x,y=_y,lt=10,s=1})
	sfx(0,1)
	sfx(1,1)
end

function pch()
	local _n=#tiles
	for v in all(tiles) do
		if p.x==v.x and near(v.y,p.y) and v.s<38 then _n=1 end
	end
	if _n!=1 then
		return pc-1
	else
		return 5
	end
end

function da_end()
	if tds<=0 then
	rrectfill(25,30,80,80,2,1)
	rrect(26,31,78,78,2,7)	
	print("you died!",48,50,8)
	print("you lived "..score.." sec.",32,62,7)
	print("press ❘ to",44,74)
	print("restart",50,84)
	if btnp(❘) then
		restart()
		st=false
	end
	end
end

function restart()
	p.x,p.y,p.st=24,72,-1
	inv=10
	score=0
	r=1
	wood={}
	sharks={{x=-100,y=0,lt=-1}}
	bubl={}
	tiles={{x=p.x, y=p.y, lt=100, nt=45, nc=1,s=2}} 
	latl={x=p.x, y=p.y, lt=100, nt=45, nc=1}
	cx=128
	t=0
end