?'!0000\0…	\0\0▮'
?'!0040\0▤?\0\0「?'
?'!0080\0▤?\0\0「?'
?'!00c0\0▥▥\0\0■■'
?'!0100\0▥▥\0\0■■'
?'!0140\0y❘\0\0q▶'
?'!0180\0y❘\0\0q▶'
?'!01c0\0vg\0\0vg'
?'!02003?33█∧i'
?'!0240333;█??'
?'!0280?333█▤웃'
?'!02c03333p▤웃'
?'!030033;3`☉☉'
?'!0340333?\0█h'
?'!03803?33pp'
?'!03c0?333\0'
?'!04003?33pg'
?'!0440<33;\0p'
?'!0480??33\0p\0'
?'!04c0?<33p\0'
?'!0500|?3;`p\0'
?'!0540??<3\0`'
?'!0580???;\0`'
?'!05c0?|?<'
?'!0600????3???'
?'!0640????????'
?'!0680????3???'
?'!06c0??|?3?|?'
?'!0700????3???'
?'!0740????????'
?'!0780?|??3|??'
?'!07c0????3???'

function _init()
boost = 1
winner = 0
	dist=0
	--finish_y=nil
	scroll = 0
	speed = 1
	boat_x = 60
	boat_y = 96
	river={
  32,32,32,40,40,48,48,
  40,40,32,32,24,24,32,
  32,32,32,32
 }
 river_dir=8
 turn_timer=3
 
 rival_y=72
	rival_x=60
	rival_speed=2.4
 
	end

function _update()
--if finish_y then
 --finish_y+=speed
--end
--scrolling water 
scroll+=speed

if scroll>=8 then
 scroll-=8
 dist +=1
 --if dist==1000 then
 --finish_y=-8+scroll
--end

 for i=#river,2,-1 do
  river[i]=river[i-1]
 end

 turn_timer-=1

if turn_timer>0 then
 river[1]=river[2]
else
 river[1]=river[2]+river_dir
 turn_timer=flr(rnd(4))+1
end

 if river[1]>64 then river_dir=-8 end
if river[1]<8 then river_dir=8 end
end
--scrolling boat
if btn(2) and speed<3 then
 speed+=0.1
end

--if btn(3) and speed>0.5 then
 --speed-=0.2
--end
boat_y+=(96-(max(speed,1)-1)*12-boat_y)*.1

if btn(5) and boost>0 and speed<3.5 then
 speed+=.1
 boost-=1
end
--rival
if rnd()<.01 then rival_speed=2+rnd(1.5) end
rival_y=mid(8,rival_y+speed-rival_speed,104)
if dist>=1000 then
 fy=(dist-1001)*8+scroll
 if winner==0 and fy>=min(boat_y,rival_y) then
  winner=boat_y<rival_y and 1 or 2
 end
end
rpos=(rival_y-scroll+8)/8+1
rrow=flr(rpos)
frac=rpos-rrow
rival_x=river[rrow]+(river[rrow+1]-river[rrow])*frac+28
--collision test
row=flr((boat_y+12-scroll+8)/8)+1
left=river[row]
right=left+56
next=river[row+1]
margin=0

if next~=left then
 margin=4
end

boat_center=boat_x+4

--steering
if btn(0) and boat_center>left+8-margin then
 boat_x-=1
end

if btn(1) and boat_center<right+margin then
 boat_x+=1
end

boat_center=boat_x+4

if boat_center<left+8-margin or boat_center>right+margin then
 speed=0
end
end
function _draw()
 cls()


 for row=1,#river-1 do
  local y=(row-1)*8-8+scroll
  local left=river[row]
  local right=left+56
  local next=river[row+1]
 -- local next_right=next+56

--grass background
for x=0,120,8 do
 spr(16,x,y)
end

--water
for x=left,right,8 do
 spr(48,x,y)
end

--left shore
if next==left then
 spr(49,left,y)
elseif next>left then
 spr(32,left,y,1,1,true,true)
else
 spr(32,next,y,1,1,true)
end

--right shore
if next==left then
 spr(49,right,y,1,1,true)
elseif next>left then
 spr(32,right+8,y)
else
 spr(32,right,y,1,1,false,true)
end

end

--finish line
if dist>=1000 and dist<1017 then
 frow=dist-999
 fl=river[frow]

 for j=0,1 do
  for i=0,15 do
   rectfill(fl+i*4,fy+j*4,fl+i*4+3,fy+j*4+3,(i+j)%2*7)
  end
 end
end
--rival
spr(0,rival_x,rival_y)
spr(17,rival_x,rival_y+8)
spr(33,rival_x,rival_y+16)

--boat
 spr(1,boat_x,boat_y,1,3)
 if winner>0 then
 print(winner==1 and"win"or"lose",56,60,7)

end
print("boost:"..boost,2,4,7)
	end