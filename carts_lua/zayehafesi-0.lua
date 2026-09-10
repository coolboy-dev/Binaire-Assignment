function _draw()
 cls()
 for i=1,8 do
  for j=1,8 do
   vpoly(
    (i-1)*16 + 8,
    (j-1)*16 + 8,
    i+j+3,
    8,
    i-1+j,
    (i+j)/4
   )
  end
 end
end

--this function has 114 tokens. 
--this function operates like:
--if you put this in the draw(),
--it will create a polygon
--in center x,y.
--s is the number of sides.
--r adjusts radius.
--c adjusts color.
--v is what makes it move.
--every frame, each vertex of
--the polygon iterates from
--its original position to
--plus-minus (v).
--hope it works -♥-

function vpoly(x,y,s,r,c,v)
 local aps={}
 for i=1,s do
  local a=1/s*i
 	add(aps, {
 	 x=x+r*cos(a)+v-rnd(2*v),
 	 y=y+r*sin(a)+v-rnd(2*v),
 	})
 end
 for i=1,s-1 do
  local j=i+1
   line(
    aps[i].x,aps[i].y,
    aps[j].x,aps[j].y,
    c)
   line(
    aps[1].x,aps[1].y,
    aps[s].x,aps[s].y,
   c)
 end
end