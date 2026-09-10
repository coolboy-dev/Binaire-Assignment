function _init()
	x,y,b,a,dx,dy,f=32,64,{},8,0,0,138
end

function _update()	
	if x%8==y%8 then
		j=2*y+x/8
		if (min(x,y)<0 or max(x,y)>127 or b[j]) _init()
		b[j],ddx,ddy=a,btn(⬅️) and -1 or btn(➡️) and 1,btn(⬆️) and -1 or btn(⬇️) and 1
		if dx==0 and ddx then 
			dx,dy=ddx,0
		elseif dy==0 and ddy then
			dy,dx=ddy,0
		end
	end
	for i=0,255 do
		s,z=b[i],f==i and 2
		if s then			
			b[i]=s>0 and s-1
			if z then 
			 a+=fs 
			 fs,f=0,flr(rnd(256))
			end
		else
			spr(z,i%16*8,8*flr(i/16))
			if (z) fs=8
		end
	end	

	x+=dx
	y+=dy
	spr(1,x,y)
end

