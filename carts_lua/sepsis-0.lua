--sepsis
--by adam atomic

px=0 py=0 g=0 l=9 sc=0 e=0
cs={} ps={} ts={}
w={"\^w\^tsepsis","\^wsepsis","\^tsepsis","sepsis"}
cartdata("sepsis")
b=dget(0)
::_::
g+=1
if (g==30000) g=0
nx=0 ny=0
if (btn(0))nx=-1
if (btn(1))nx=1
if (btn(2))ny=-1
if (btn(3))ny=1
if #cs>0 then
	if e==0 then
		if (px+nx<128 and px+nx>=0) px+=nx
		if (py+ny<128 and py+ny>=0) py+=ny
		if (nx!=0 or ny!=0) and g%10==0 then
			add(ts,{px,py,2})
		end
		k=cs[1]
		cd=30000
		f=cs[1]
		fd=30000
		for c in all(cs) do
			d=sqrt((px-c[1])*(px-c[1])+(py-c[2])*(py-c[2]))
			if d<c[3] then
				e=1
				add(ts,{px,py,1})
			elseif d<cd and d<c[3]+l then
				k=c
				cd=d
				f=c
				fd=d
			elseif d<fd then
				f=c
				fd=d
			else
				c[3]+=.05
			end
		end
		q = cd<k[3]+l
		if (q)k[3] -= 1
		if k[3]<=1 then
		 del(cs,k)
		 sc+=1
		 add(ps,{k[1],k[2],1,sc})
		end
		if g%30==0 then
			c = {flr(rnd(128)),
								flr(rnd(128)),
								3}
			add(cs,c)
			add(ts,{c[1],c[2],3})
		end
	else
		for c in all(cs) do
			c[3] -= 1
			if c[3]<=1 then
				del(cs,c)
			 add(ts,{c[1],c[2],1})
			end
		end
	end
elseif nx!=0 or ny!=0 then
	e=0
	if sc>b then
		b=sc
		dset(0,b)
	end
	sc=0
	px=64
	py=64
	ss=20
	while ss>0 do
		cx = flr(rnd(128))
		cy = flr(rnd(128))
		if (cx<=48 or cx>=80) and (cy<=48 or cx>=80) then
			add(cs,{cx,cy,3+rnd(12)})
			ss-=1
		end
	end
	goto _
end
cls()
for t in all(ts) do
	t[3]+=0.5
	if t[3]>=15 then
		del(ts,t)
	else
		circ(t[1],t[2],t[3],1)
	end
end
if #cs==0 then
	m=w[1]
	z = g%90
	if z>=27 and z<=32 then
		m=w[2+(z-27)%3]
	end
	print(m,39,56,7)
	print("⬆️⬇️⬅️➡️",47,70,3)
	print("last: "..sc,47,82,11)
	print("best: "..b,47,90,1)
else
	for c in all(cs) do
		if c[3]<2 then
			circfill(c[1],c[2],2,3)
		else
			circfill(c[1],c[2],c[3],3)
			if c[3]<=12 then
				circ(c[1],c[2],c[3],0)
			end
		end
	end
	if #cs>0 and e==0 then
		circfill(px,py,2,7)
		if q then
			circfill(k[1],k[2],k[3],11)
			line(px,py,k[1],k[2],11)
		else
			fx = max(2,f[3])
			circfill(f[1],f[2],fx,3)
			circ(f[1],f[2],fx,0)
			line(px,py,f[1],f[2],3)
		end
	end
end
for p in all(ps) do
	p[3]+=1
	if p[3]>=30 then
		del(ps,p)
	elseif p[3]<7 then
			circfill(p[1],p[2],p[3],7)
	else
		z=11
		if (p[3]>22)z=3
		circ(p[1],p[2],p[3],z)
		print("\^w\^o0ff"..p[4],p[1]-4,p[2]-p[3]*.5,7)
	end
end
if #cs>0 and e==0 then
	pset(px,py,0)
end
flip()goto _