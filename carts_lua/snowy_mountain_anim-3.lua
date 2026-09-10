flakes={}
for i=1,120 do
flakes[i]={rnd(128), rnd(128), rnd(24)+1, rnd(12)+1, rnd(4), rnd(3)}
end

function flake(x,y,t,r)
	local sx=cos(t)*r
	local sy=sin(t)*r
	line(x-sx,y-sy,x+sx,y+sy,7)
	line(x-sy,y-sx,x+sy,y+sx,7)
end

sfx(0)
function _draw()
	poke(0x5f2c, 3)
	cls(0)

	
	local cl1x=(t()*1)
	local cl2x=(t()*1.5)
	spr(9,  (cl1x-10)%256-128, 4, 8, 1)
	spr(25, (cl2x+10)%256-128, 8, 8, 2)
	spr(9,  (cl1x-10-128)%256-128, 4, 8, 1)
	spr(25, (cl2x+10-128)%256-128, 8, 8, 2)
	
	spr(1,0,0,8,8)
	
	for f in all(flakes) do
		local x=f[1]
		local y=f[2]
		local dx=f[3]
		local dy=dx/1.5/(2+f[5]*0.5)
		local r=f[5]
		local sz=f[6]
		local t=t()
		x+=t*dx+cos(t*dx/16)
		y+=t*dy+sin(t*dy/16)*2
		x&=127
		y&=127
		flake(x,y,t*r*0.1+r,sz/1.5)
	end
end