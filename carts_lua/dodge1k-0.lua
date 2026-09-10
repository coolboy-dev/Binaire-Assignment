--dodge1k
--by davemakes

function pscore(ex)
	ex=ex or ""
	print(
		"\^#\^t\^w"
		..tostr(pnt,0x2)
		..ex,4,4,1)
end

function lerp(a,b,t)
	return (1-t)*a+t*b
end

function eline(x1,y1,x2,y2)
	for i=1,6 do
			local ct=(-t()+i/6)%1
			pset(
				lerp(x2,x1,ct),
				lerp(y2,y1,ct),
				11)
		end
end

function en_add()
	enhead=(enhead+1)%enmax
	if enhead==entail then
		entail=(entail+1)%enmax
	end
	if not en[enhead] then
		en[enhead]={}
	end
	local e=en[enhead]
	e.x,e.y,e.dx,e.dy,e.r,e.act=
		rnd(sc_sz)+sc_m,
		rnd(sc_sz)+sc_m,
		rnd(1.5)-0.75,
		rnd(1.5)-0.75,
		5,true
	if col(e,pl,48) then
		enhead-=1
		en_add()
	end
end

function loop(n)
	return n%128
end

function col(me,u,r)
	local dx,dy=
		abs(me.x-u.x),
		abs(me.y-u.y)
	return dx*dx+dy*dy<r*r
end

function _init()
	sc_m,sc_sz=2,124
	en={}
	enhead,entail,enmax=0,0,50
	tim=30
	pl={x=64,y=64}
	pnt=0
	cartdata("davemakes_dodge1k_1")
	high=dget(0) or 0
	_update60=gmup
end

function gmup()
	cls((high>0 and pnt>=high)
		and 9 or 1)
	rrectfill(
		sc_m,sc_m,
		sc_sz,sc_sz,
		0,0)
	pscore()
	tim-=1
	if tim<1 then
		tim=120
		en_add()
	end
	local nx,ny=0,0
	if(btn(⬅️)) nx-=1
	if(btn(➡️)) nx+=1
	if(btn(⬆️)) ny-=1
	if(btn(⬇️)) ny+=1
	pl.x=loop(pl.x+nx)
	pl.y=loop(pl.y+ny)
	local bmb=btn(❘) or btn(🅾️)
	local cut=bmb and 2 or 1
	for i=0,enmax do
		local e=en[i]
		if e and e.act then
			e.x=loop(e.x+e.dx/cut)
			e.y=loop(e.y+e.dy/cut)
			if not bmb
			and col(e,pl,24) then
				eline(
					e.x,e.y,
					pl.x,pl.y
				)
				pnt+=1>>16
				high=max(pnt,high)
				local a=
					atan2(
						pl.x-e.x,pl.y-e.y
					)
				e.dx+=cos(a)*(1>>7)
				e.dy+=sin(a)*(1>>7)
				e.r-=1>>6
				if e.r<1 then
					e.act=false
				end
			end
			
			circfill(e.x,e.y,e.r,
				bmb and 2 or 8)
			
			if col(e,pl,2+e.r) then
				dset(0,high)
				_update60=gmover
				tim=15
			end
		end
	end
	
	circfill(pl.x,pl.y,3,
		bmb and 7 or 12)
end

function gmover()
	if btn(❘) then
		if(tim<1) _init()
	else
		tim=max(0,tim-1)
	end
	
	pscore("\nbest:"
	..tostr(high,0x2))
end

