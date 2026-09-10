a=21g=21s={}l=nil b=0w=0n2=0D=0nu=0q=1n1=1.5x={}no=0m={}nd=0k=nil nB={}j=0nC=0Q=0z={}ed=.9R=45S=20eB=40T={}n4=0nh=0E=false n3=0e0={14,30,46,62}eC={2,3,2,3}eD={0,1,1,2}_=nil r=nil i=nil n8=0n0=0n6=1nD=0h=0v=0e=0U=0ns=0ei=2V=0A=0W={}nE=true d=false F=15G=0C=0Y=0o={0,0,0,0}n5={0,0,0}nF=nil nG=nil nH=nil eE={7,10,11,3,3,1}eF=2H=0f=nil p=0Z=0I=0J=0K=0L=0nI={12,137,11,138,14,143,9,128,3,140,13,136,10,142,8,139}nJ={1,129,3,131,2,130,5,133,13,141,4,132,12,140,6,134}ef={10,9,10,7,11,3,11,7,12,1,12,7,14,2,14,7}ni=0eG={7,14,12}n7="ribbit to the limit"et=64-#n7*2eH={11,3,7}eI=240n9=0nn={}function eJ(n)add(nn,n)return n end function nK(n)n.dead=true end function eK()for n=#nn,1,-1do if(nn[n].dead)deli(nn,n)
end end function M(d,e,o)for n in all(nn)do if(not n.dead and(e==nil or n[e]~=nil)and(o==nil or n[o]~=nil))d(n)
end end function _init()cartdata"jimbothefrog_v1"poke(24365,1)eL()u=0t=0music(0,0,1)N=1nf=0y={life=0}eM()srand(777)nL={}for n=1,64do nL[n]=rnd()end np()ng()nb()b,w=nt()end function eM()L=dget(7)K=dget(8)end function el()dset(7,L)dset(8,K)end function _update()t+=1local n=stat(30)and stat(31)or""if(n=="r")eN()return
eO()if u==0do if(t%240==0)np()
if(btnp(5))u=3return
if(btnp(4))u=1no=t nM(no)ng()nb()b,w=nt()
return end if u==3do if(btnp(4)or btnp(5))u=0np()
return end if(u==2)eP()return
if r do r.tmr+=1if(r.tmr%8==1and r.tmr<#r.slots*8)sfx(14)
if(r.buyfx>0)r.buyfx-=1
for n in all(r.fx)do n.x+=n.dx n.y+=n.dy n.dy+=.08n.l-=1if(n.l<=0)del(r.fx,n)
end if r.tmr>32and r.buyfx<=0do local n=r.cur if(btnp(0))r.cur-=1
if(btnp(1))r.cur+=1
if(btnp(2))r.cur-=2
if(btnp(3))r.cur+=2
r.cur=mid(1,r.cur,#r.slots)if(r.cur~=n)sfx(12)
if(btnp(4))eQ(r.cur)
if(btnp(5))r=nil e=180
end return end if Q>0or n3>0or n0>0do if(Q>0)Q-=1
if(n3>0)n3-=1
if(n0>0)n0-=1
if(j>0)j-=1
return end if p>0do if(p%30==0)sfx(16)
p-=1if(p==0)sfx(17)p=-20
return end if(p<0)p+=1
Z+=1nD+=1E=eR()if(not _ and not r and e<=0and eS())eT()
if(e>0)e-=1
if(D>0and not E and not d)eU()
if(btn(0))l.wx=-1l.wy=0
if(btn(1))l.wx=1l.wy=0
if(btn(2))l.wy=-1l.wx=0
if(btn(3))l.wy=1l.wx=0
if(btn()&15==0)l.wx=0l.wy=0
if(l.wx==-l.dx and l.wy==-l.dy)l.dx=l.wx l.dy=l.wy
if(U>0and A<=0and(n==" "or btnp(4)))eV()
if(nE and btnp(5))if d do d=false sfx(11)elseif F>0do d=true sfx(11)end
M(eW)local n,e=nt()b+=(n-b)*ea w+=(e-w)*ea if(_ and l.cx==_.cx and l.cy==_.cy)_=nil r={tmr=0,cur=1,fx={},buyfx=0,slots=eX()}
M(function(n)eY(n)if not d and abs(n.px-l.px)<5and abs(n.py-l.py)<5do if n.st==3do if(V<=0)eZ(n)
else on(n)end end if n.st==3do M(function(e)if(abs(n.px-e.px)<5and abs(n.py-e.py)<5)nK(e)nm(e.px+4,e.py+4)sfx(3)
end,"is_auto")end end,"is_ghost")nN(3,6,E)if nf>0do nf-=1elseif N>1do N=1end if G<=0do if(L==0or Z<L)L=Z
if I==0do J+=1if(J>K)K=J
else J=0end for n=1,3do sfx(-1,n)end d=false u=2sfx(7)local n,e=I==0,max(max(o[1],o[2]),max(o[3],o[4]))>4local o=n and e and"perfect massacre"or n and"perfect"or e and"massacre"f={t=0,w=o,cp=n and eG or{7,2,8},c2={7,2,8},sp=n and e and 7or nil,x0=o and 64-#o*3or 43}return end if n8>0do n8-=1elseif not i do oe()n8=er end if(i)i.ttl-=1if i.ttl<=0do nm(i.px+4,i.py+4)sfx(ec)nK(i)i=nil elseif not d and abs(i.px-l.px)<6and abs(i.py-l.py)<6do o1(i)end
if(t%90==0and nd<nO and not k)e2()nP()
if(k)k.tm-=1if(k.tm<=0)k=nil
nN(1,18,k)if(t%60==0)el()
if(j>0)j-=1
if(V>0)V-=1local n=D>0and eu or nl add(W,{x=l.px,y=l.py,f=l.flip,s=n[t\nQ%4+1],l=6})
if(A>0)A-=1
for n in all(W)do n.l-=1if(n.l<=0)del(W,n)
end if d do F-=1if(F<=0)d=false sfx(11)
elseif F<ne do F+=ne/30end nN(2,10,d)if(y.life>0)y.life-=1y.y-=.3
eK()end function eW(n)n.acc+=n.mspd while n.acc>=1do n.acc-=1if(n.px%8==0and n.py%8==0)n.cx=n.px\8n.cy=n.py\8oo(n)od(n)
if(n.dx<0)n.flip=true
if(n.dx>0)n.flip=false
n.px+=n.dx n.py+=n.dy end end function od(n)if n.is_pac do n.mspd=V>0and o0 or n1 if n.wx~=0or n.wy~=0do if(not c(n.cx+n.wx,n.cy+n.wy))n.dx=n.wx n.dy=n.wy
else n.dx=0n.dy=0end if(c(n.cx+n.dx,n.cy+n.dy))n.dx=0n.dy=0
else if n.is_ghost do if n.st==3do n.mspd=2elseif n.st==2do n.mspd=n.gt==4and 2or n1 elseif n.st==1do n.mspd=n.evade and(n.sprint and 2or 1)or 1elseif n.st==4do n.mspd=2else n.mspd=1end if(n.st==1)oi(n)return
if(n.st==2)of(n)return
if((n.st==3or n.st==4)and not d)ot(n)return
else n.mspd=n.is_fruit and ol or n1 end local e={}for o in all(B)do if(not c(n.cx+o[1],n.cy+o[2]))if(not(o[1]==-n.dx and o[2]==-n.dy))add(e,o)
end if n.trail and#e>1do local o={}for e in all(e)do if(not e4(n,(n.cy+e[2])*a+n.cx+e[1]))add(o,e)
end if(#o>0)e=o
end if#e==0do for o in all(B)do if(not c(n.cx+o[1],n.cy+o[2]))add(e,o)
end end if(#e>0)local e=e[flr(rnd(#e))+1]n.dx=e[1]n.dy=e[2]else n.dx=0n.dy=0
end end B={{1,0},{-1,0},{0,1},{0,-1}}nl={1,2,3,2}oa={17,18,19,18}eu={33,34,35,34}oc={49,50,51,50}nQ=2o2=3nR=15nx=12na=23130nS={23130,4680,33825,2114,31727,15420}eh=81ea=.25ou=false e3=4o4=2oh=12e8=3o3=3o8=8e6=e3 nO=e8 o6=300es=12e5=10e7=3nT=165os=60o5=14nk=40o0=4ol=1er=180o7=450o9=8e9=19ec=20nU=21ep={{64,5},{65,10},{66,15}}n_={1,1,1,2,2,3}op={0,-1,-2,-3,-3,-2,-1,0}ne=15nv={{id="spd",n="speed",c=12,rar=5,ic=4,yc=14,rc=6,d="+ move speed"},{id="mth",n="mouth",c=14,rar=5,ic=5,yc=10,rc=5,d="bigger mouth = more pips!"},{id="ato",n="auto-pac",c=9,rar=4,ic=7,yc=16,rc=9,d="+1 auto eater"},{id="dsh",n="dash",c=6,rar=6,ic=6,yc=20,rc=9,d="🅾️/space: dash thru ghosts"},{id="gho",n="ghost",c=13,rar=5,ic=8,yc=18,rc=8,d="+0.5s vanish time"}}function eg(n)return function()return n end end function og(d)local e=0local function n()e+=1return ord(d,e)end local function i()return n()>>>16|n()>>>8|n()|n()<<8end return function()local n,o=n()o,n=n&252~=252and n>>>2&63,n%4if(n==0)return o and o-31or i()
if(n==3)return({true,false})[o]
local n=o or i()<<16e+=n return sub(d,e-n+1,e)end end do local n,d={function()local n=nr()return function()return nV[n]end end},split"1,0,0,2,2,2,2,1,2,1,2,2,3,2,2,1,2,3,2,2,3,0,2,1,2,3,2,3,1,3,3,2,2,2,2,1,2,2,2,2,3,2"function X(e)nV,nr,nw={},og(e),function()nV,nr,nw=nil end return n[nr()]()(nw())()(_ENV)end local function i(a,b,c)local n=nw function nw()a,b,c=a(),b(),c()return n()end return function()return a end,function()end,function(f)return f end,function(...)return a(...)*b(...)end,function(...)return a(...)+b(...)end,function(f)a(f)return b(f)end,function(f)return a(f)(b(f))end,function(f)return(a(f))end,function(f)return a(f),b(f)end,function(f)return#a(f)end,function(f)return a(f)>b(f)end,function(f)return a(f)[b(f)]end,function(f)a(f)[b(f)]=c(f)end,function(...)return a(...)-b(...)end,function(f)return a(f)and b(f)end,function(f)return not a(f)end,function(f)return a(f)==b(f)end,function(f)if(a(f))return b(f)
return c(f)end,function(f)local u={__index=a({},f)}return function(...)return b(setmetatable({...},u))end end,function(f)f[b]=a(f)end,function(t,f)t[b]=f[c]return a(t,f)end,function(f,v)return v end,function(f)return f[a][b]end,function(f)return-a(f)end,function(...)return a(...)..b(...)end,function(t,f)t[a(f)]=b(f)return c(t,f)end,function(f)return a({b(f)},f)end,function(f)f[c]={a(f)}return b(f)end,function(f)return f[a]end,function(f)f[b][c]=a(f)end,function(f)local t,k=a(f),b(f)t[k]=c(f,t[k])end,function(f)return a(f)or b(f)end,function(...)return a(...)^b(...)end,function(f)return a(f)<b(f)end,function(f)return a(f)>=b(f)end,function(f)return{a(f)}end,function(...)return a(...)%b(...)end,function(...)return a(...)\b(...)end,function(f)return a(f)<=b(f)end,function(f)return a(f)[b]end,function(f)a(f)[c]=b(f)end,function(...)return a(...)/b(...)end end for o,f in inext,split"0,0,0,2,2,2,2,1,2,1,2,2,3,2,2,1,2,3,2,1,1,0,0,1,2,3,2,2,0,1,3,2,2,2,2,1,2,2,2,1,2,2"do local function e(e)return e<f and n[nr()]()or eg(e<d[o]and nr())end add(n,function()return eg(add(nV,(select(o,i(e(0),e(1),e(2))))))end)end end X"?☉▤???😐x█▤?⬆️…?█	cy?xa?█	cxt??█!is_fruit????x	eb?█▤??x	ny??x	e9░☉████??█!is_ghost▤??x\radd??█‖trail?t???█?░?▤??x■deli?█?░█???xm█?▤?█?\0\0#\0█?░▤???x	nd█?\0\0 \0x	nd▤??x	ob█?▤??x	nP███████?\0\0002\0?????█」is_pac??xu░|??xd█?\0\0$\0▤█?\0\0&\0▤█?\0\0)\0▤?⬆️?xh░?xh▤?⬆️?xC█?\0\0@\0xC▤?⬆️?xv░…xv▤?⬆️?xY█?\0\0G\0xY▤??xM??██▤?█?\0\0008\0█■frzt???█	st█?▤?█?\0\0008\0█	st████░!is_ghost▤??x\rsfx█?\0\0G\0▤??x	om?⬆️?█	px░😐⬆️?█	py█?\0\0]\0?????xs█?█?\0\0009\0??█?\0\0006\0█?\0\0;\0▤?█?\0\0c\0█?█?\0\0%\0▤???xG█?\0\0 \0xG?█?\0\0006\0??xE▤?⬆️█?\0\0F\0█?\0\0 \0xv▤?⬆️█?\0\0J\0█?\0\0 \0xY▤?█?\0\0Y\0░░▤??x	nm█?\0\0a\0██▤?⬆️█?\0\0?\0?xqxh▤?⬆️█?\0\0C\0█?\0\0z\0xC▤?█??█?\0\0008\0█?\0\0r\0█?\0\0v\0▤█?\0\0|\0▤█?\0\0~\0█████?\0\0⌂\0█	oo▤??█☉▤?█??█?\0\0 \0█?\0\0r\0▤█?\0\0Z\0▤??xSxj▤?█?\0\0?\0x	nC▤???x\rmin?⬆️?xN█?\0\0 \0░?xN▤?░?\0\0?\0x	nf▤?\0\0 \0?xo?█	gt⬆️?█?\0\0 \0????x	eC█?\0\0?\0??x	eD█?\0\0?\0▤??|█t▤??|░p▤?⬆️█?\0\0?\0█?xh▤?⬆️█?\0\0C\0█?xC▤?⬆️█?\0\0F\0?pxv▤?⬆️█?\0\0J\0█?\0\0?\0xY▤???x\rflr…█?\0\0@\0█?\0\0?\0l?█?\0\0m\0▤?…?l?x	eil▤?█?\0\0?\0x	n3▤?█?\0\0 \0h???h█?▤???░\rtxt?░+█?\0\0?\0?░x?█?\0\0\\\0?xb?░y?█?\0\0_\0?xw?░■life░?\0\0(\0█░██xy???xP██▤?█?\0\000?\0d▤?█?\0\0?\0`▤??d█	cx▤??`█	cy▤?…█?\0\0?\0░?█	px▤?…█?\0\0?\0█?\0\0?\0█	py▤?█?\0\0008\0█	dx▤?█?\0\0008\0█	dy▤█?\0\0Q\0▤█?\0\0N\0▤?█?\0\0008\0█■lost██|▤??xO?█?\0\0^\0?█?\0\0`\0????x\rrnd█?░?\0█\0????█?\0\0?\0█?\0\0r\0░?\0█\0\0?█?\0\0?\0?█?\0\0?\0?░▤░▤?⬆️█?\0\0?\0█?\0\0 \0h█?\0\0▮█?\0\0?\0|█	on██"X'?☉▤???😐x█???█	id░\rspd?x	nu??█😐░\rmth?xD??█😐░\rato?x	n2??█😐░\rdsh?xU??█😐░\rgho?x	ns?\0\0!\0??█\rgot░█░|█	nj▤??██?█⬆️░😐?█?░??█?░░?█?░☉?█?█?\0\0#\0█?█	nW▤??█☉▤???x	nj?█t???x\rflr…?█	yc?\0\0"\0░?▥▥\0?t?█?\0\0/\0…?█	rc█?\0\0003\0█	nX▤??█☉?\0\0#\0█?\0\0-\0??x	nW█?\0\0,\0█	nY▤???█░t█???t\rall?t	nv▤???x█??x░?x☉p???p████???t	nY█?\0\0L\0???t	nX█?\0\0L\0▤??|█l▤??|░h???\0\0$\0?th?l?\0\0$\0?tv?h░▤??█?\0\0F\0?█?\0\0G\0█?\0\0L\0p█?\0\0g\0|█?\0\0a\0x█	eS▤???█░p█▤??\0\0%\0██x???p\rall?p	nv▤???t█??t░?t☉l??█?\0\0W\0██▤?█?\0\0m\0`???\0\0#\0??`█?\0\0 \0???x█?▤??█?\0\0}\0⬆️??p\rflr??p\rrnd█?\0\0~\0█?\\▤??p\radd?█?\0\0z\0?\\▤??█?X???X█?▤?█?\0\0~\0T???T█?█?\0\0?\0???█?\0\0}\0█?\0\0➡️\0█?\0\0웃\0▤??p■deli?█?\0\0}\0█?\0\0➡️\0▤?⬆️█?\0\0➡️\0█?\0\0🅾️\0T█?\0\0?\0█?\0\0?\0▤?█?\0\0~\0P??\0\0#\0?P█?█?\0\0?\0???█?\0\0}\0█?\0\0?\0█?\0\0웃\0▤?█?\0\0ˇ\0?█?\0\0}\0█?\0\0?\0▤?⬆️█?\0\0?\0█?\0\0🅾️\0P█?\0\0?\0█?\0\0?\0█?\0\0z\0???p	nY█?\0\0W\0▤??l\rrarh▤?█?d???d█?\0\0Z\0▤??█?\0\0r\0?█?\0\0s\0█?\0\0W\0l█?\0\0?\0▤?█?\0\0☉\0?█?\0\0}\0█?\0\0W\0▤?⬆️█?\0\0?\0█?d█?\0\0?\0█?\0\0?\0t█	eX▤??█☉▤???\0\0)\0?xr‖slots█?\0\0,\0t??\0\0!\0?█?\0\0002\0???x	nY█?\0\0002\0██???x	nX█?\0\0002\0▤?█?\0\0R\0p▤?█?\0\0T\0l???\0\0$\0?xh█?\0\0L\0?\0\0$\0?xv█?\0\0W\0▤??█?\0\0?\0█?\0\0L\0xh▤??█?\0\0?\0█?\0\0W\0xv▤??x	ox█?\0\0002\0▤??x\rsfx█?\0\0 \0▤?\0\0*\0█?\0\0?\0??x	nz?█?\0\0 \0░?‖buyfx▤??x	ok█?\0\0,\0██▤?█?\0\0?\0█?\0\0#\0██|█	eQ▤??█?\0\0B\0▤?█😐x??█?\0\0}\0█…▤?⬆️?t	nu█?t	nu▤?⬆️░?\0█\0…█?\0\0░?\0@\0\0t	n1██??█?\0\0}\0█?▤?⬆️?tD█?tD▤?⬆️█?█?\0\0tq██??█?\0\0}\0█?▤?⬆️?t	n2█?t	n2▤??t	em████??█?\0\0}\0█?▤?⬆️?tU█?tU▤??░?\0\0004\0…█?\0\0、░?t	nk██??█?\0\0}\0█?▤?⬆️?t	ns█?t	ns▤?⬆️░?…█?\0\0\'█?\0\0*t	ne█████	ox▤???█░l█▤?⬆️░?\0\0&\0…?\0\0&\0?█?\0\0,\0█?█?\0\0"\0░?\0\0006\0x▤?⬆️░?\0\0*\0…?\0\0\'\0█?\0\0:█?\0\0"\0░?\0\0(\0t▤?█?p??█?\0\0L\0░?██▤???l\rrnd█?h▤?⬆️?█?\0\0I░?\0█\0░?\0█\0\0d▤??l\radd??\0\0)\0?lr	fx??░x█?\0\0}\0?░y█?\0\0002\0?░	dx…??l\rcos█?\0\0Z\0█?\0\0?\0?░	dy…??l\rsin█?\0\0Z\0█?\0\0?\0?░l⬆️░??█?\0\0I█?\0\0 ?░c?\0\0)\0??\0\0)\0█?\0\0R‖slots█?\0\0,\0c█░██▤?⬆️█?\0\0L\0█?p█?\0\0u█	ok▤??█?\0\0008?██▤?█?\0\0R\0x▤?█?\0\0T\0t▤█?\0\0F??█?\0\0L\0░?▤?⬆️…█?\0\0002\0?la█?\0\0}\0d???ls█?\0\0?\0▤???lG█?lG▤?█?\0\0⬇️█?\0\0?\0░▤???░	cx█?\0\0}\0?░	cy█?\0\0002\0█░██l_▤??l\rsfx█?\0\0*███?\0\0⬆️▤???lP██▤█?\0\0{█?\0\0||▤?⬆️??l\rabs?█?\0\0}\0?\0\0)\0?ll	cx?█?\0\0??█?\0\0002\0?\0\0)\0█?\0\0?	cyh???\0\0$\0█?\0\0Z\0█?\0\0 \0?\0\0(\0█?\0\0Z\0░?█?\0\0❘▤█?\0\0p█?\0\0?|█	eT██'function eU()local o,d=l.dx,l.dy if(o==0and d==0)return
local n,e=l.cx,l.cy for i=1,6do n+=o e+=d if(c(n,e))break
local o=e*a+n if(s[o]and#z<120)s[o]=nil G-=1add(z,{x=n*8+4,y=e*8+4,dx=0,dy=0,hom=true,clr=10})
end end function eV()local n,e=l.dx,l.dy if(n==0and e==0)n=l.wx e=l.wy
if(n==0and e==0)return
l.dx=n l.dy=e l.wx=n l.wy=e V=o5 A=nk sfx(9)end function o_()for n in all(W)do local e=n.l>4and 7or n.l>2and 6or 13for n=1,15do pal(n,e)end spr(n.s,n.x,n.y,1,1,n.f)pal()end end function ex(n,e,o)rectfill(n,122,n+31,127,0)rect(n,122,n+31,127,6)rectfill(n+1,123,n+1+flr(29*min(e,1)),126,o)end X"?☉▤???😐x█▤??x	nM??x\rflr??x\rrnd░?\0\0\0}▤???x	nI⬆️?█…?█⬆️░?░█x	nx▤???x	nJ█?x	n6▤???x	nS⬆️?█…?█⬆️░⬆️█?x	na▤?…?█…?█⬆️░😐█?x	ni███	np▤??█☉▤?░|x	n2▤?█?\0\0)\0xD▤?█?\0\0)\0x	nu▤?█?xq▤?░?\0█\0x	n1▤?█?\0\0)\0x	no▤?█?\0\0)\0xh▤?█?\0\0)\0xv▤?█?\0\0)\0xe▤?█?\0\0)\0xU▤?░?\0\0(\0x	nk▤?░░x	ei▤?█?\0\0)\0xV▤?█?\0\0)\0xA▤??\0\0%\0██xW▤?█?\0\0)\0x	ns▤?░?x	ne▤?░x	nE▤?░xd▤??x	nexF▤?█?\0\0)\0xJ▤?░x_▤?█?\0\0G\0xr▤?█?\0\0G\0xf▤?█?\0\0)\0xH▤?█?\0\0)\0xC▤?█?\0\0)\0xY▤??\0\0%\0?█?\0\0)\0?█?\0\0)\0?█?\0\0)\0█?\0\0)\0xo▤??\0\0%\0█?\0\0O\0x	n5▤??\0\0)\0█?█x	nx▤??\0\0)\0█?█x	n6▤?█?\0\0)\0x	ni▤█????x\rall?x	nv▤???t█??t░?t☉p???p██▤?█?xN▤?█?\0\0)\0x	nf▤???░■life█?\0\0)\0█░██xy▤?█?\0\0)\0xu▤?█?\0\0)\0xt▤??x‖music?█?\0\0)\0?█?\0\0)\0█?▤??x	np██▤??x	ng██▤??x	nb██▤???x	nt██▤??|█xb??|░xw|██▤?█?\0\0B\0p\rgot▤??█?\0\0]\0?█?\0\0^\0█?\0\0c\0p█?\0\0◆\0t█	eN▤??█☉▤?\0\0 \0?xf░t⬆️?█??????\0\0)\0█?\0\0?\0t░??\0\0#\0█?\0\0?\0░?\0\0@\0??\0\0&\0█?\0\0?\0█?\0\0?\0█?\0\0)\0▤??x\rsfx█?\0\0?\0????\0\0$\0█?\0\0?\0█?\0\0?\0?\0\0(\0█?\0\0?\0░?\0\0P\0█?\0\0?\0▤?█?\0\0?\0?x	nU???\0\0)\0█?\0\0?\0w?█?\0\0?\0░?\0\0n\0???\0\0)\0█?\0\0?\0	px▤?\0\0*\0█?\0\0?\0?█?	px▤?█?\0\0?\0░?▤?\0\0 \0█?\0\0?\0░	px⬆️█?\0\0?\0█?\0\0007\0▤??█…?\0\0+\0⬆️?█?\0\0?\0?\0\0)\0█?\0\0?\0	x0░▤█?t????t?\0\0!\0?\0\0)\0█?\0\0?\0	ch█?\0\0)\0?\0\0(\0█?\0\0?\0?█?\0\0?\0▤?\0\0*\0█?\0\0?\0█?\0\0?\0	ch▤?█?\0\0?\0░?▤?█?p??█?\0\0c\0░☉▤?\0\0*\0█?\0\0?\0?\0\0!\0?█?\0\0?\0?\0\0$\0█?\0\0?\0█?\0\0?\0??█?\0\0?\0?█?\0\0?\0░?\0\0Z\0\rrdy???\0\0)\0█?\0\0?\0\rrdy?\0\0!\0??x■btnp█??█?\0\0?\0░…▤??x	ov██████▤??xO?⬆️█?\0\0?\0█?\0\0?\0?░?\0\0<\0???█⬆️█?\0\0007\0█??█?\0\0?░??█?\0\0?█?\0\0G\0?█?\0\0G\0???x	ek█?\0\0?\0⬆️?█…?█⬆️█?\0\0?\0█?▤?⬆️█?\0\0c\0█?p█?\0\0¥█?\0\0\0█?\0\0 █?\0\0\0█?\0\0$█?\0\0&█	eP▤??█☉▤?⬆️?xH█?xH▤??█?⬆️?\0\0&\0█?\0\0,█?█?x	nx▤??█?█?\0\0000x	n6▤?…?\0\0&\0█?\0\0,█?█?x	ni▤█?▤█?\0\0L\0▤█?\0\0M\0▤█?\0\0R\0▤█?\0\0T\0▤█?\0\0H\0▤?█?x	no▤?█😐?x	no▤█?\0\0t\0▤█?\0\0v\0▤█?\0\0~\0▤█?\0\0J\0▤?█?xu▤??x	el█████	ov██"function c(n,e)if(n<=0or n>=a-1or e<=0or e>=g-1)return true
return x[e*a+n]end function ng()s={}G=0for n=0,g-1do for e=0,a-1do if(not c(e,n))s[n*a+e]=true G+=1
end end m={}nd=0nO=min(e8+H\o3,o8)for n=1,nO do e2()end k=nil nP()end function nM(n)srand(n)x={}for n=1,g-2do for e=1,a-2do x[n*a+e]=true end end local n={{1,1}}x[a+1]=nil while#n>0do local e=n[#n]local i,f,e=e[1],e[2],{}for n in all(B)do local o,d=i+n[1]*2,f+n[2]*2if(o>=1and o<a-1and d>=1and d<g-1and x[d*a+o])add(e,{o,d,i+n[1],f+n[2]})
end if(#e>0)local e=e[flr(rnd(#e))+1]x[e[4]*a+e[3]]=nil x[e[2]*a+e[1]]=nil add(n,{e[1],e[2]})else n[#n]=nil
end ow()end function ow()for o=1,g-2,2do for i=1,a-2,2do local d,n=0,{}for e in all(B)do local e,o=i+e[1],o+e[2]if c(e,o)do if(e>0and e<a-1and o>0and o<g-1)add(n,{e,o})
else d+=1end end if(d<=1and#n>0)local n=n[flr(rnd(#n))+1]x[n[2]*a+n[1]]=nil
end end end function P(o)for n=1,40do local n,e=flr(rnd(a)),flr(rnd(g))if(not c(n,e))if(not o or not s[e*a+n])return n,e
end return 3,3end X(chr(peek(8192,2203)))function ob(n)n.st=3n.frzt=o6 end function ot(n)local o,d for e in all(B)do if(not c(n.cx+e[1],n.cy+e[2])and not(e[1]==-n.dx and e[2]==-n.dy))local n=abs(n.cx+e[1]-l.cx)+abs(n.cy+e[2]-l.cy)if(not d or n<d)d=n o=e
end if(o)n.dx=o[1]n.dy=o[2]else n.dx=-n.dx n.dy=-n.dy
end function e4(n,e)for n in all(n.trail)do if(n==e)return true
end end function of(n)local o,i for e in all(B)do local f,t=n.cx+e[1],n.cy+e[2]if not c(f,t)do local d=abs(f-l.cx)+abs(t-l.cy)if(e4(n,t*a+f))d-=100
if(e[1]==-n.dx and e[2]==-n.dy)d-=50
if(not i or d>i)i=d o=e
end end if(o)n.dx=o[1]n.dy=o[2]
end function eb(n)local e,n=n.cx-l.cx,n.cy-l.cy return e*e+n*n<=e5*e5 end function eR()local e=false M(function(n)if(n.st==3)local o,n=n.cx-l.cx,n.cy-l.cy if(o*o+n*n<=e7*e7)e=true
end,"is_ghost")return e end function oj(n,e)if(l.dx~=0)return e==l.cy and(n-l.cx)*l.dx>0and abs(n-l.cx)<=8
if(l.dy~=0)return n==l.cx and(e-l.cy)*l.dy>0and abs(e-l.cy)<=8
end function nZ(n)if n.cy==l.cy do for e=min(n.cx,l.cx)+1,max(n.cx,l.cx)-1do if(c(e,n.cy))return false
end return true end if n.cx==l.cx do for e=min(n.cy,l.cy)+1,max(n.cy,l.cy)-1do if(c(n.cx,e))return false
end return true end end function oz(n,e)if(e[2]==0and l.cy==n.cy and(l.cx-n.cx)*e[1]>0)return nZ(n)
if(e[1]==0and l.cx==n.cx and(l.cy-n.cy)*e[2]>0)return nZ(n)
end function e_(n)for e in pairs(m)do local o,n=n.cx-e%a,n.cy-e\a if(o*o+n*n<=es*es)return true
end end function nP()T={}local n={}for e in pairs(m)do T[e]=0add(n,e)end while#n>0do local o={}for n in all(n)do local d,i=n%a,n\a for e in all(B)do local d,i=d+e[1],i+e[2]local e=i*a+d if(not c(d,i)and not T[e])T[e]=T[n]+1add(o,e)
end end n=o end end function oi(n)local e,i for o in all(B)do local d=T[(n.cy+o[2])*a+n.cx+o[1]]if d do if(oz(n,o))d+=999
if(not i or d<i)i=d e=o
end end if(e)n.dx=e[1]n.dy=e[2]else n.st=0
end function eY(n)if d do n.evade=false if(n.frzt>0)n.frzt-=1n.st=3else n.st=e_(n)and 1or 0
return end if(n.frzt>0)n.frzt-=1n.st=n.frzt>0and 3or 0return
if e_(n)do n.st=1n.evade=nZ(n)if n.evade do n.sprt-=1if(n.sprt<=0)n.sprint=not n.sprint n.sprt=n.sprint and nT or os
else n.sprint=true n.sprt=nT end elseif eb(n)do if n.gt==1do n.st=0elseif n.gt==3do n.st=4else n.st=2end else n.st=0end end function nN(n,e,o)if o do if(stat(46+n)~=e)sfx(e,n)
else if(stat(46+n)==e)sfx(-1,n)
end end function eZ(n)I+=1nD=0n4=flr(h*ed)nh=flr(v*ed)h-=n4 v-=nh N=1nf=0j=R nC=R Q=R sfx(3)z={}for n=1,eB do O(l.px+4,l.py+4,rnd(2)-1,rnd(2)-1,R,nil,10)end n.st=0n.frzt=0n.lost=0local e,o=P()n.cx=e n.cy=o n.px=e*8n.py=o*8n.dx=0n.dy=0end X"?☉▤???😐x█??x\radd??xz??░x?█?░y?░?░	dx?☉?░	dy?😐?░\ract?…?░	ml?⬆️?░\rclr?▤?░	bo???░	pc??█░███O▤??█☉???█…░?\0\0x\0██▤?░█t???t░☉██▤???x\rrnd█?\0\0)\0p▤?⬆️█?\0\0/\0░?ff\0\0l▤??xO?█▤?█??…??x\rcos?p?l????█?\0\0.\0░?\0█\0░??L\0\0?░?\0\0 \0?█?\0\0?\0?░?░▤?⬆️█?\0\0+\0█?\0\0)\0t█?\0\0P\0█	nm▤???█░t█▤?█?\0\0)\0x???x░?██▤???t\rrnd█?\0\0)\0p▤?⬆️?█?\0\0Z\0█?\0\0:\0█?\0\0001\0l▤??tO?█▤?█??…??t\rcos█?\0\0006\0█?\0\0008\0????█?\0\0Z\0░░█?\0\0=\0?░??░?█?\0\0i\0?█?\0\0A\0?\0\0!\0??\0\0#\0█?\0\0W\0░⬆️░?█?\0\0@\0▤?⬆️█?\0\0W\0█?\0\0)\0x█?\0\0~\0█	om██"function eL()nB={}for n in all{0,1,e9}do local e={}for o=0,31do e[o]=band(peek(12800+n*68+o*2),63)end nB[n]=e end R=nz(3,45)S=nz(5,10)oy=nz(nU,20)end function nz(n,o)local d,e=peek(12800+n*68+65),0for o=0,31do if(band(peek(12800+n*68+o*2+1)\2,7)>0)e=o
end local n=(e+1)*d*30\128return n>=10and n or o end function ny(n,e)local d=flr(rnd(e*2+1))-e for e=0,31do local o=12800+n*68+e*2poke(o,bor(band(peek(o),192),mid(0,nB[n][e]+d,63)))end sfx(n)end function nt()return mid(0,l.px+4-64,a*8-128),mid(-8,l.py+4-64,g*8-120)end function _draw()cls(0)if(u==0)oq()return
if(u==2)oA()return
if(u==3)oB()return
local e,o=0,0if(j>0)local n=j/nC*4e=rnd(n)-n/2o=rnd(n)-n/2
clip(0,8,128,112)oC()camera(b+e,w+o)oD()if(k)circfill(k.cx*8+3,k.cy*8+3,2,({0,8,7})[t%3+1])
M(function(n)if(not n.is_pac)ev(n)
end)if(#W>0)o_()
ev(l)en()if(_)oE()
if(p~=0)rectfill(l.px-3,l.py+13,l.px+11,l.py+21,0)?p>0and p\30+1or"go",l.px+2,l.py+15,p>0and 7or 11
camera()clip()oF()if(nE and not r)spr(8,12,120)ex(21,F/ne,d and 7or 12)
if(U>0and not r)spr(6,56,120)ex(65,A<=0and 1or 1-A/nk,A<=0and 11or 8)
if(y.life>0)?y.txt,y.x,y.y,y.c or 7
if r do if(r.buyfx>0)camera(rnd(3)-1.5,rnd(3)-1.5)
oG()camera()end if(ou)oH()
pal(15,nx,1)pal(5,n6,1)end function oH()rectfill(98,121,127,127,0)?flr(stat(7)).." "..flr(stat(1)*100).."%",99,122,11
end function oE()local n,e=_.cx*8+4,_.cy*8+4circ(n,e,2,t%8<4and 10or 7)circfill(n,e,1,t%8<4and 14or 8)end function nA(n,e,o)rectfill(n,e,n+1,e+1,o and(t%4<2and 8or 14)or ef[ni+t\4%4+1])end function oG()local o=r rectfill(6,8,121,112,0)rect(6,8,121,112,7)?"abilities",48,12,7
for i=1,#o.slots do local d,f=o.slots[i],o.tmr-(i-1)*8if f>0do local n,e=14+(i-1)%2*54,24+(i-1)\2*40if f<6do rectfill(n,e,n+48,e+36,7)else local f,i,t,l,a=i==o.cur,nW(d),nj(d),nX(d)local o=f and o.buyfx>0and({7,0,d.c})[o.buyfx%3+1]or 0rectfill(n,e,n+48,e+36,o)rect(n,e,n+48,e+36,f and 7or 13)rectfill(n+1,e+1,n+2,e+36-1,d.c)if(d.ic)spr(d.ic,n+38,e+2)
?d.n,n+5,e+3,7
if(i>1)?"lv"..t.."/"..i,n+5,e+10,6
nA(n+6,e+18)?l,n+9,e+17,10
nA(n+27,e+18,true)?a,n+30,e+17,8
if t>=i do?"max",n+5,e+27,11
else local o=h>=l and v>=a?o and"🅾️ buy"or"locked",n+5,e+27,o and 7or 13
end end end end?o.slots[o.cur].d,10,104,6
if(o.tmr>32and o.buyfx<=0and t%8<5)rectfill(48,116,80,124,0)?"❘ leave",51,118,7
for n in all(o.fx)do circfill(n.x,n.y,1,n.l<4and 7or n.c)end end function eO()local e=false for n in all(z)do if n.hom do local o,d=l.px+4,l.py+4n.dx=(n.dx+(o-n.x)*.09)*.8n.dy=(n.dy+(d-n.y)*.09)*.8n.x+=n.dx n.y+=n.dy n.clr=t%4<2and 10or 7if(abs(o-n.x)<4and abs(d-n.y)<4)h+=q C+=q e=true del(z,n)
else if n.bo do local e=n.x+n.dx if(c(flr(e/8),flr(n.y/8)))n.dx=-n.dx*.6e=n.x
local o=n.y+n.dy if(c(flr(n.x/8),flr(o/8)))n.dy=-n.dy*.5o=n.y
n.x=e n.y=o n.dy+=.12n.dx=n.dx*.99else n.x+=n.dx n.y+=n.dy n.dy+=.05end n.act-=1if(n.hd and n.act<n.hd)n.hom=true
local e=n.act/(n.ml or R)if n.pc do n.clr=n.pc elseif n.bo do n.clr=e>.6and 10or e>.25and 7or 6else n.clr=e>.6and 10or e>.3and 9or e>.1and 8or 2end if(n.act<=0)del(z,n)
end end if(e)ny(0,2)
end function en()for n in all(z)do circfill(n.x,n.y,1,n.clr)end if Q>0do if(n4>0)?"-"..n4,l.px-4,l.py-11,10
if(nh>0)?"-"..nh,l.px-4,l.py-5,8
end end function oC()camera()fillp(23130)local n,e=b*.4,w*.4local i,f,o,d=-n%14,-e%14,flr(n/14),flr(e/14)for n=-1,9do for e=-1,9do local o,d,n,e=e+o,n+d,i+e*14,f+n*14local o=(o*13+d*29+o*d)%64+1if(nL[o]<.5)rectfill(n,e,n+14,e,1)
if(nL[o*3%64+1]<.5)rectfill(n,e,n,e+14,1)
end end fillp()end function ew(o,d,n,e,t,i,l,f)fillp(l)rectfill(n,e,n+7,e+7,t)fillp()if(not f(o,d-1))line(n,e,n+7,e,i)
if(not f(o,d+1))line(n,e+7,n+7,e+7,i)
if(not f(o-1,d))line(n,e,n,e+7,i)
if(not f(o+1,d))line(n+7,e,n+7,e+7,i)
end function oD()local i,e,n=n0>0and({7,10,nR})[t%3+1]or(E and(t%8<4and 8or 2)or nR),flr(b/8),flr(w/8)for n=n,n+16do for e=e,e+16do if e>=0and e<a and n>=0and n<g do local o,d=e*8,n*8if c(e,n)do ew(e,n,o,d,eh,i,na,c)elseif m[n*a+e]do circfill(o+3,d+3,2,8)elseif s[n*a+e]do local i=ef[ni+(e+n+t\4)%4+1]if(E and oj(e,n))i=t%4<2and 8or 14
rectfill(o+3,d+3,o+4,d+4,i)end end end end end function ey(n)for e=1,15do pal(e,n)end end function ev(n)local e,o=n.px,n.py if n.is_pac do if(d)spr(t%8<4and 36or 37,e,o,1,1,n.flip)return
local i,d=n.dx~=0or n.dy~=0if(D>0and u>0)d=i and eu or oc else d=i and nl or oa
if(Q>0and t%4>0)ey(({7,0,8})[t%4])
spr(d[t\nQ%4+1],e,o,1,1,n.flip)pal()elseif n.is_fruit do spr(n.spr,e,o+op[n.px%8+n.py%8+1])elseif n.is_auto do pal(11,9)pal(3,4)spr(nl[t\nQ%4+1],e,o,1,1,n.flip)pal()else if(n.st==3and t%8<4)ey(8)
spr(n.spr+t\o2%2,e,o)pal()end end function ee(e)local n,e=e\30,flr(e%30*100/30)return n\60 ..":"..(n%60<10and"0"..n%60or n%60)..":"..(e<10and"0"..e or e)end function ej()return L>0and ee(L)or"--"end function oF()rectfill(0,0,127,7,0)nA(3,2)?h,6,1,10
local n=max(21,9+#(h.."")*4)nA(n,2,true)?v,n+3,1,8
?ee(Z),50,1,7
local e=J.."/"..K local n=126-#e*4spr(9,n-9,0)?e,n,1,8
local n=n-11-#(I.."")*4?I,n,1,8
spr(20+t\4%10,n-9,0)end X"?☉▤?███X▤???😐x█??\0\0#\0?\0\0)\0?xft?☉██▤??x‖print??█??░?\0\0>\0…?█?░😐??😐?…▤?█???░?░?\0\0B\0█?███	ez▤??█😐?\0\0!\0???\0\0)\0█…	sp?█?█?\0\0 \0?\0\0)\0█…	c2?\0\0)\0█…	cp█	ek▤??█😐▤??x\rcls░|???x	nH▤???x	e1░-stage clearx	nH▤??x	eo?█?\0\0,\0?░??░?░░▤?█???░‖time ???x	ee?xZ?░。  best ??x	ej██?░??░?░▤▤??x\rspr?░??█?\0\0D\0░?\0\0!\0▤?█???░。streak ??xJ?█?\0\0>\0?xK?░??░?\0\0#\0?\0\0!\0???xI█?\0\0*\0█?\0\0003\0█?\0\0004\0▤??x	ez?░■pips??xC?░??░?\0\0,\0░?▤?█?\0\0a\0?░」rubies??xY?█?\0\0W\0?░?\0\0004\0█?\0\0004\0▤?░█t???t█?▤?█?\0\0t\0l???l░☉??█⬆️░?\0\0X\0▤?█??░!powerups?░?\0\0000\0?░?\0\0P\0░⬆️??█?\0\0004\0█?\0\0|\0▤??|█d▤??|░`???x\rall?x	nv▤???\\█??\\░?\\☉X???X██???\0\0)\0█…w?█⬆️░?\0\0Z\0▤??\0\0!\0?\0\0)\0█…	px?█?\0\0004\0P▤???x\rmin??█⬆️█?\0\0❘\0░?L???P░?\0\0█\0▤???x\rmax?█?\0\0*\0??L?\0\0'\0?█?\0\0?\0█?\0\0?\0█?\0\0z\0L??█?\0\0?\0█?\0\0*\0▤??x!rectfill?█?\0\0*\0??░?\0\0@\0█?\0\0?\0?░?\0\0○\0?⬆️█?\0\0?\0█?\0\0?\0█?\0\0*\0???\0\0$\0█?\0\0?\0█?\0\0?\0?\0\0(\0█?\0\0?\0█?\0\0?\0▤???x\rflr?\0\0+\0⬆️?█?\0\0?\0?\0\0)\0█…	x0█?\0\0F\0█?\0\0▒\0H▤?█?\0\0∧\0D▤???D@▤?█?\0\0t\0<???<?@▤?█?\0\0K\0???x	nl⬆️?\0\0&\0?\0\0'\0?xt█?\0\0z\0█?█?\0\0t\0?█?\0\0?\0░?\0\0:\0▤??x	en██???\0\0)\0█…\rrdy?\0\0#\0?\0\0&\0█?\0\0?\0█?\0\0d\0░?▤?█??░)🅾️ continue?░?\0\0*\0?░?\0\0z\0█?\0\0003\0████??█?\0\0?\0?H▤?█????x\rsub?█?\0\0?\0?█?\0\0?\0█?\0\0?\0?⬆️█?\0\0?\0…?█?\0\0?\0█?\0\0t\0█?\0\0▒\0?⬆️░?\0\0<\0…??x\rsin⬆️…█?\0\0?\0░?▥」\0\0…█?\0\0?\0░?f&\0\0░?\0█\0???x	ek█?\0\0?\0⬆️?\0\0&\0█?\0\0?\0█?\0\0z\0█?\0\0t\0▤?⬆️█?\0\0?\0█?\0\0t\0<█?\0\0\n█?\0\0█?\0\0?\0█?\0\0?\0█?\0\0■█?\0\0?\0▤???x	nj█?\0\0⬆️\0T???T█?\0\0*\0??X	ic▤?█?\0\0K\0?█?\0\0、??d??`█?\0\0t\0▤?█???\0\0!\0????x	nW█?\0\0⬆️\0█?\0\0t\0??Xn?░ █?\0\0¥█?\0\0&?⬆️█?\0\0。█?\0\0f\0?█?\0\0゛?Xc▤?⬆️█?\0\0。█?\0\0?\0d??█?\0\0。█?▤?█?\0\0004\0d▤?⬆️█?\0\0゛█?\0\0004\0`▤??█?\0\0🅾️\0?█?\0\0◆\0█?\0\0⬆️\0X█?\0\0E█?\0\0;█?\0\0@█?\0\0;\\|█?\0\0◀??\0\0$\0█⬆️⬆️░?\0\0008\0…█?\0\0y\0█?\0\0004\0▤?⬆️░?\0\0\"\0…?█?\0\0y\0█?\0\0t\0░?h▤?█?\0\0K\0??\0\0)\0??x	ep█?\0\0y\0█??h░?\0\0D\0▤?█????x	n5█?\0\0y\0?⬆️█?\0\0Z█?\0\0L\0?░?\0\0F\0█?\0\0F\0▤?⬆️█?\0\0y\0█?\0\0t\0l█?\0\0n█?\0\0i??\0\0$\0█⬆️⬆️█?\0\0W\0…█?\0\0v\0█?\0\0004\0▤?⬆️█?\0\0W\0…?█?\0\0v\0█?\0\0t\0░?p▤?█?\0\0K\0???x	e0█?\0\0v\0??p█?\0\0?\0▤?█????xo█?\0\0v\0?⬆️█?\0\0z█?\0\0L\0?█?\0\0?\0█?\0\0F\0▤?⬆️█?\0\0v\0█?\0\0t\0t█?\0\0😐█?\0\0♥█?\0\0⧗█	oA██"function eq(n,e)return n<1or n>14or e<1or e>14or c(n,e)end function eA()for n=0,15do for e=0,15do if(eq(e,n))ew(e,n,e*8,n*8,eh,nR,na,eq)
end end end function n(o,n,e,d)rectfill(n-1,e-1,n+#o*4+2,e+5,0)?o,n,e,d
end function e1(n)local e={}cls()?n,0,0,7
for o=0,5do for n=0,#n*4-1do if(pget(n,o)==7)add(e,{n,o,flr(n/4)})
end end cls()return e end function eo(n,e,o,d)local e=64-e*4for n in all(n)do local e,o=e+n[1]*2,o+n[2]*2+flr(sin(t*eF/30-n[3]/22)*d)rectfill(e+2,o+2,e+3,o+3,0)rectfill(e,o,e+1,o+1,eE[n[2]+1])end end function nc(n,e,o)?n,64-#n*2,e,o
end function oI(n,o,i,f)local d=64-#n*2?n,d+1,o+1,1
for e=1,#n do?sub(n,e,e),d+e*4-4,o,(flr(t/3)-e)%6<2and i or f
end end function oJ()local e=t%eI local o,n=7+e*2,e<60if n do local n=flr((o-et+3)/4)if(n>n9 and n<=#n7)n9=n for n=1,3do O(o+3,86,rnd(2)-1,rnd(2)-1,24,24,nil,nil,eH[flr(rnd(3))+1])end
else n9=0end local d=not n and e<84and t%4<2clip(7,37,114,67)for e=1,#n7 do if n and e>n9 or not n and not d do local n,o=sub(n7,e,e),et+e*4-4?n,o+1,85,1
?n,o,84,(flr(t/3)-e)%6<2and 11or 3
end end if(n)spr(nl[t\3%4+1],o,82)
en()clip()end function oB()eA()if(not nG)nG=e1"credits"
eo(nG,7,16,2)rectfill(6,36,121,104,0)rect(6,36,121,104,3)nc("bgm // code // design",40,7)nc("astropelican.itch.io",60,12)nc("(c) 2026",68,12)nc("best time "..ej(),75,10)oJ()nc("thank you for playing!",96,6)if(t%20<14)n(chr(151).." back",52,112,8)
end function oq()eA()if(not nF)nF=e1"jimbo the frog"
eo(nF,14,14,2.5)oI("a pac-roguelite",32,10,9)n("perfect streak "..K,30,58,11)n("eat all pips to clear the maze",4,74,6)n("grab the flashing pip to shop",6,82,6)n("❘ vanish past ghosts",22,90,6)if(t%20<14)n("press 🅾️ to start",31,98,8)
n("❘ credits",44,112,11)end