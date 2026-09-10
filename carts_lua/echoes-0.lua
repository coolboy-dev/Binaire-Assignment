q=":0e1f0e0"function f(j)add(e,{{x%64+32,22+rnd(94),j},i=1,v=0,w=0})end
function r()x=64y=x s=0w=0pp={}e={}p={}d=f()end
r()d=1function _update()z=t()u=btn()cls()rect(3,14,124,124,7)if(s>19)rect(3,60,124,78,0)
if(s>34)rect(55,14,73,124,0)
for g in all(pp)do g[3]+=1n=g[3]fillp(2^n-.5)for i=1,8do pset(g[1]+cos(i/8)*n,g[2]+sin(i/8)*n,g[4])end if(g[5])circ(g[1],g[2],n+3)
if(n>15)del(pp,g)end
fillp()color(7)
for n=1,#p,4do pset(unpack(p[n]))end l=z*4&1h=w-z k=h>0and o m=o==6and h/2+1or h?s,64-#(s.."")*2,4,7
circfill(x,y,2,0)?q..(not d and u%16>0and 8-6*(z*8&1)or"a").."00000000",x-2,y-2,7
if d do?"jfcz"
if(btnp(4))d=s>0and r()
else a=u\2%2-u%2c=u\8%2-u\4%2u,v=unpack(p[#p]or{x,y})n=2/(a*a+c*c)^.5x=s>19and abs(y-69)<7and(x+a*n-3)%121+3or mid(6,x+a*n,121)y=s>34and abs(x-64)<7and(y+c*n-14)%110+14or mid(17,y+c*n,121)if((u-x)^2+(v-y)^2>3)deli(p,#p\240)add(p,{x,y})
end
for i=#e,1,-1do g=e[i]b=g.v if not(d or z*7%1>.6or o==6and z*9%1>-h/2)do g.i+=b
if(g.i%#g<2)g.v=-b
end
u,v,j=unpack(g[g.i])if b==0do
circ(u,v,3+l,j and(l==1and 7or j)or 10)else?q.."a".."00000000",u-2,v-2,m%1/m==1and 7+(-1/m&1)*(o\4*2-1)or k or g.c
for n=1,#g,4do pset(unpack(g[n]))end pset(u,v-1,0)end
if not(d or z<g.w)and(u-x)^2+(v-y)^2<20-b^2*8do
if b==0do
if#p>1do c=j or 9?"i0x5c"..c\3
add(pp,{u,v,0,c+c\6%2,1})if(j)w=z+4.5-j/12o=j
p.v=1p.i=1p.w=z+.5p.c=8+s%3*3\2color(j or k or p.c)for n=1,#p,4do pset(unpack(p[n]))end add(e,p)p={}s+=1del(e,g)f(s%5<1and 12-s%10\5*6)if(s%15<1)f()
end
else
d=k!=12add(pp,{u,v,0,d and 7or 12})if(k==12)del(e,g)
?"i0x5c"..(d and 1or 5)
end
end
end
end