function U()f=10*n6 p,C,D,E,z,n0,P,i,c,n,I=10*O,1,1,0,0,0,0,0,1,1,1nt()if(Q~=-1and o<=5)music(8,2000,1)
if(Q~=-1and o>5and o<=6)music(1,2000,1)
end function nh()if I==1do n3()n9()n5()no()n4()n7()n8()ns()nr()nl()nu()nc()ng()nm()nk()if(r==2)Y=false
nb()ny()np()nv()nw()nx()nj()nz()if(i>=1)i=i-1
nq()if(p<=0and Z~=true)Z,B=true,60
if B<=0and Z==true do I,d=0,6if(o~=0)g={a=flr(rnd(u+9)+1),b=flr(rnd(u+9)+1),c=flr(rnd(u+9)+1)}
Z=false end if(f<=0)I,d,B,Z=0,7,20,false
end end function nA()for n in all(a)do while(n==g.a)g.a=flr(rnd(u+3)+1)
while(n==g.b)g.b=flr(rnd(u+3)+1)
while(n==g.c)g.c=flr(rnd(u+3)+1)
end while(g.b==g.a)g.b=flr(rnd(u+3)+1)
while(g.c==g.b or g.c==g.a)g.c=flr(rnd(u+3)+1)
if d==6and B<=0do if g.a*g.b*g.c>=0do if(btnp(⬅️))sfx(18,0)add(a,g.a)g={a=-1,b=-2,c=-3}
if(btnp(⬆️))sfx(18,0)add(a,g.b)g={a=-1,b=-2,c=-3}
if(btnp(➡️))sfx(18,0)add(a,g.c)g={a=-1,b=-2,c=-3}
end if(btnp(❘))d=2sfx(1,0)if(o~=0)u=u+1
end end function nB()if(d==7and B<=0)if(btnp(❘))_init()
end function nt()l,R,w,x,G,ni,nf=30,10,3.4,.22,1,0,0nC=rnd(l*w-l)*(l*w-l)+l nD=rnd(l*w-l)*(l*w-l)+l nE=rnd(l*w-l)*(l*w-l)+l J=(nD-37.2)/57.6K=(nE-37.2)/57.6t,H,X=(nC-37.2)/57.6,15,1S,r,M,v=rnd(.9)*(l*w-l)+l,0,0,0end function nq()if(v==0)nt()
if v==1do H,nn=H+1*X,.1if(btnp(❘)and r==0and H>=S and H<=S+nn*(l*w-l))r=1sfx(18,0)
if(btnp(❘)and r==0and H<S or btnp(❘)and r==0and H>S+nn*(l*w-l))r=2
if(H>l*w and r==0)r=2
end if v==2do if(u~=6and N<=.03)N+=.0001
if(u==6and N<=.04)N+=.0002
nn=.1ni=60+cos(x)*w*5nf=20+sin(x)*w*5x+=N*G if(G==2)G=-1
if(G==0)G=1
if(x>=1and G==1)x-=1
if(x<=0and G==-1)x+=1
if u~=6do if(btnp(❘)and r==0)if(x>=t-flr(t)-.1and x<=t-flr(t)+.1)M+=1sfx(18,0)G,N=G+1,.018else r,M=2,0
if(btnp(❘)and r==0and x>=t-flr(t)-.1and x<=t-flr(t)+.1and M>=V)r=1sfx(18,0)M=0
end if u==6do if(btnp(❘)and r==0)if(x>=J-flr(J)-.1and x<=J-flr(J)+.1or x>=K-flr(K)-.1and x<=K-flr(K)+.1)M+=1sfx(18,0)G,N=G+1,.025else r,M=2,0
if(btnp(❘)and r==0and x>=J-flr(J)-.1and x<=J-flr(J)+.1and M>=V or btnp(❘)and r==0and x>=K-flr(K)-.1and x<=K-flr(K)+.1and M>=V)r=1sfx(18,0)M=0
end end end function nb()if(btnp(⬅️)and n==1and c>=1)c=c-1sfx(14,-1)
if(btnp(➡️)and n==1and c<=4)c=c+1sfx(14,-1)
if(c==5)c=1
if(c==0)c=4
end function n3()if(c==b.sltsta and btnp(⬆️)and n==1and i<=0)p=p-ceil(3*C)f,E,i,n=f-1,1,60,2
end function n9()if(c==b.sltjab and btnp(⬆️)and n==1and i<=0)p=p-ceil(1*C)f,E,i,n=f-0,1,60,2
end function n5()if(c==b.slthok and btnp(⬆️)and n==1and i<=0)p=p-ceil(5*C)f,E,i,n=f-3,1,60,2
end function no()if(n==1and i<=0and ne==true)p,E,i,n,ne=p-ceil(6*C),1,60,2,false
if(c==b.sltupe and btnp(⬆️)and n==1and i<=0and ne~=true)ne=true f,i,n=f-1,60,2
end function n7()if(c==b.sltfot and btnp(⬆️)and n==1and i<=0)f=f-1C,i,n=C+.2,60,2
end function n4()if(c==b.sltclo and btnp(⬆️)and n==1and i<=0)f=f-1C=C+.5D,i,n=D*1.2,60,2
end function n8()if(c==b.sltliv and btnp(⬆️)and n==1and i<=0)p=p-ceil(4*C)D=D*.7f,E,i,n=f-2,1,60,2
end function ns()if(c==b.sltfei and btnp(⬆️)and n==1and i<=0)f=f-1D,i,n=D*.6,60,2
end function nr()if(c==b.sltove and btnp(⬆️)and n==1and i<=0)p=p-ceil(6*C)f,E,i,n=f-4,1,60,2
end function nl()if(n==1and i<=0and Y==true)p,E,i,Y=p-ceil(3*C),1,60,false
if(c==b.sltcou and btnp(⬆️)and n==1and i<=0and Y~=true)Y,i,n=true,60,2
end function nu()if(c==b.sltcro and btnp(⬆️)and n==1and i<=0)p=p-ceil(4*C)f,E,i,n=f-1,1,60,2
end function nc()if(c==b.sltfli and btnp(⬆️)and n==1and i<=0)p,E,i,n=p-ceil(2*C),1,60,2
end function ng()if(c==b.sltsma and btnp(⬆️)and n==1and i<=0)p=p-ceil(8*C)f,n1,E,i,n=f-3,true,1,60,2
if(n1==true and n==1and i<=0)n1,n=false,2
end function nm()if(c==b.sltelb and btnp(⬆️)and n==1and i<=0)p=p-ceil(1*C)D=D*.6f,E,i,n=f-1,1,60,2
end function nk()if(c==b.sltgaz and btnp(⬆️)and n==1and i<=0)n2,n=true,2
if(n==1and i<=0and n2==true)n2=false p=p-ceil(8*C)f,E,i,n=f-2,1,60,2
end function ny()if(n==2and i<=0and o==0)v,X=1,1
if(n==2and i<=0and r==1and o==0)z,i,n,v=2,20,1,0
if(n==2and i<=0and r==2and o==0)f,z,i,n,v=f-ceil(1*D),1,20,1,0
end function np()if(n==2and i<=0and o==1)v,X=1,1.5
if(n==2and i<=0and r==1and o==1)z,i,n,v=2,20,1,0
if(n==2and i<=0and r==2and o==1)f,z,i,n,v=f-ceil(3*D),1,20,1,0
end function nv()if(n==2and i<=0and o==2)v,X=1,1.8
if(n==2and i<=0and r==1and o==2and L<=1)L,H=L+1,15S,r=rnd(.9)*(l*w-l)+l,0
if(n==2and i<=0and r==1and o==2and L>=2)z,i,n,v,L=2,20,1,0,0
if(n==2and i<=0and r==2and o==2)f,z,i,n,v=f-ceil(3*D),1,20,1,0
end function nw()if(n==2and i<=0and o==3)v,X=1,1.5
if(n==2and i<=0and r==1and o==3and L<=1)L,H=L+1,15S,r=rnd(.9)*(l*w-l)+l,0
if(n==2and i<=0and r==1and o==3and L>=2)z,i,n,v,L=2,20,1,0,0
if(n==2and i<=0and r==2and o==3)f,z,i,n,v=f-ceil(3*D),1,20,1,0
end function nx()if(n==1and o==4)N,V=.018,3
if(n==2and i<=0and o==4)v=2
if(n==2and i<=0and r==1and o==4)z,i,n,v=2,20,1,0
if(n==2and i<=0and r==2and o==4)f,z,i,n,v=f-ceil(3*D),1,20,1,0
end function nj()if(n==1and o==5)N,V=.018,5
if(n==2and i<=0and o==5)v=2
if(n==2and i<=0and r==1and o==5)z,i,n,v=2,20,1,0
if(n==2and i<=0and r==2and o==5)f,z,i,n,v=f-ceil(3*D),1,20,1,0
end function nz()if(n==1and o==6)N,V=.025,5
if(n==2and i<=0and o==6)v=2
if(n==2and i<=0and r==1and o==6)z,i,n,v=2,20,1,0
if(n==2and i<=0and r==2and o==6)f,z,i,n,v=f-ceil(3*D),1,20,1,0
end function nF()if d==-1do cls(13)spr(128,60,65,8,8)rect(0,0,127,127,5)rect(1,1,126,126,5)?"boxing brawl",23,20,11
?"boxing brawl",24,21,14
?"press ❘ to play",30,100,5
?"press ❘ to play",31,101,6+(120-s)\10%2
rectfill(0,3,200,10,2)?"made by ivoryp",19,4,11
?"made by ivoryp",20,5,14
?"v1.0",20,120,11
rectfill(0,0,17,200,2)end end function nG()cls(1)map(0,0,0,0,16,7)rect(0,0,127,127,15)spr(1,80,32,2,2,true,false)if(m[1]~=0)spr(m[1],30,100)
if(m[2]~=0)spr(m[2],50,100)
if(m[3]~=0)spr(m[3],70,100)
if(m[4]~=0)spr(m[4],90,100)
if(c==1and k[1]~=0)spr(k[1],30,100,2,2)
if(c==1)spr(172,30,118,2,2)
if(c==2and k[2]~=0)spr(k[2],50,100,2,2)
if(c==2)spr(172,50,118,2,2)
if(c==3and k[3]~=0)spr(k[3],70,100,2,2)
if(c==3)spr(172,70,118,2,2)
if(c==4and k[4]~=0)spr(k[4],90,100,2,2)
if(c==4)spr(172,90,118,2,2)
if ne==true and I==1do?"charging..",13,23,5
?"charging..",14,24,6
end if Y==true and I==1do?"charging..",13,23,5
?"charging..",14,24,6
end if n1==true and I==1do?"recharging..",13,23,5
?"recharging..",14,24,6
end if n2==true and I==1do?"charging..",13,23,5
?"charging..",14,24,6
end na=10?f,5,70,14
rectfill(5,60,45,65,15)rect(5,60,45,65,11)local n=flr(mid(0,f,na)/na*39)if(n>0)rectfill(6,61,6+n-1,64,14)
?p,65,70,14
rectfill(65,60,105,65,15)rect(65,60,105,65,11)local n=flr(mid(0,p,T)/T*39)if(n>0)rectfill(66,61,66+n-1,64,14)
if v==1do?"press x",l,R-5,6
rect(l,R,l*w,R+14,6)rectfill(S,R,S+nn*(l*w-l)*.7,R+14,3)line(H,R-3,H,R+17,8)end if v==2do?"press x",l+17,R+30,6
circfill(60,20,w*5,5)circ(60,20,w*5,6)if(u~=6)circfill(60+cos(t)*17,20+sin(t)*17,w*.8,3)
if(u==6)circfill(60+cos(J)*17,20+sin(J)*17,w*.8,3)circfill(60+cos(K)*17,20+sin(K)*17,w*.8,3)
line(60,20,ni,nf,8)end end function nH()if(E==1)spr(33,25,32,2,2,false,false)spr(7,79,32,2,2,true,false)n0=n0+1
if(E==1and n0>=40)spr(1,24,32,2,2,false,false)sfx(0,1)n0,E=0,0
end function nI()if(z==1)spr(33,79,32,2,2,true,false)spr(7,25,32,2,2,false,false)P=P+1
if(z==1and P>=40)spr(1,79,32,2,2,true,false)sfx(0,1)P,z=0,0
if z==2do spr(33,79,32,2,2,true,false)spr(136,25,32,2,2,false,false)?"miss!",5,29,5
?"miss!",6,30,6
P=P+1end if(z==2and P>=40)spr(1,79,32,2,2,true,false)P,z=0,0
end function nJ()if d==1do cls(13)spr(128,60,65,8,8)rect(0,0,127,127,5)?"fight",20,60,2
?"moves",20,70,2
?"config",20,80,2
?"credits",20,90,2
?"boxing brawl",24,19,11
?"boxing brawl",25,20,14
if(q==1)rectfill(0,0,18,58,2)?"fight",20,60,7
if(q==2)rectfill(0,0,18,68,2)?"moves",20,70,7
if(q==3)rectfill(0,0,18,78,2)?"config",20,80,7
if(q==4)rectfill(0,0,18,88,2)?"credits",20,90,7
rectfill(20,107,100,117,11)rect(20,107,100,117,15)?"⬅️ ➡️ ⬆️ ⬇️   ❘ 🅾️",23,110,7
end end function nK()if d==2do cls(1)?"tlevel selection",11,21,5
?"tlevel selection",12,22,6
line(0,60,500,60,8)rect(0,0,500,127,5)circfill(20,60,15,2)?"tutorial",5,58,6
circfill(60,60,15,2)if(y~=2)?"level 1",47,58,6
circfill(100,60,15,2)if(y~=3)?"level 2",87,58,6
circfill(140,60,15,2)if(y~=4)?"level 3",127,58,6
circfill(180,60,15,2)if(y~=5)?"level 4",167,58,6
circfill(220,60,15,2)if(y~=6)?"level 5",207,58,6
circfill(260,60,15,2)if(y~=7)?"boss",253,58,6
if(y==1)circ(20,60,15,8)?"tutorial",5,58,7
if y==2do circ(60,60,15,8)if(u==1)?"level 1",47,58,7
if(u~=1)?"locked",49,58,7
end if y==3do circ(100,60,15,8)if(u==2)?"level 2",87,58,7
if(u~=2)?"locked",89,58,7
end if y==4do circ(140,60,15,8)if(u==3)?"level 3",127,58,7
if(u~=3)?"locked",129,58,7
end if y==5do circ(180,60,15,8)if(u==4)?"level 4",167,58,7
if(u~=4)?"locked",169,58,7
end if y==6do circ(220,60,15,8)if(u==5)?"level 5",207,58,7
if(u~=5)?"locked",209,58,7
end if y==7do circ(260,60,15,8)if(u==6)?"boss ",253,58,7
if(u~=6)?"locked",249,58,7
end?"use ⬅️ and ➡️ to select level",4,119,5
?"use ⬅️ and ➡️ to select level",5,120,6
camera(_,0)end end function nL()if d==3do cls(13)if(e.y>=4)camera(0,0+(e.y-3)*20)
spr(3,10,60,2,2)if(e.x==1and e.y==1)rect(9,59,26,76,7)
spr(35,30,60,2,2)if(e.x==2and e.y==1)rect(29,59,46,76,7)
for n in all(a)do if(n==1)spr(9,50,60,2,2)
end if(e.x==3and e.y==1)rect(49,59,66,76,7)
for n in all(a)do if(n==2)spr(11,70,60,2,2)
end if(e.x==4and e.y==1)rect(69,59,86,76,7)
for n in all(a)do if(n==3)spr(13,90,60,2,2)
end if(e.x==5and e.y==1)rect(89,59,106,76,7)
for n in all(a)do if(n==4)spr(39,10,80,2,2)
end if(e.x==1and e.y==2)rect(9,79,26,96,7)
for n in all(a)do if(n==5)spr(41,30,80,2,2)
end if(e.x==2and e.y==2)rect(29,79,46,96,7)
for n in all(a)do if(n==6)spr(43,50,80,2,2)
end if(e.x==3and e.y==2)rect(49,79,66,96,7)
for n in all(a)do if(n==7)spr(45,70,80,2,2)
end if(e.x==4and e.y==2)rect(69,79,86,96,7)
for n in all(a)do if(n==8)spr(170,90,80,2,2)
end if(e.x==5and e.y==2)rect(89,79,106,96,7)
for n in all(a)do if(n==9)spr(168,10,100,2,2)
end if(e.x==1and e.y==3)rect(9,99,26,116,7)
for n in all(a)do if(n==10)spr(140,30,100,2,2)
end if(e.x==2and e.y==3)rect(29,99,46,116,7)
for n in all(a)do if(n==11)spr(200,50,100,2,2)
end if(e.x==3and e.y==3)rect(49,99,66,116,7)
for n in all(a)do if(n==12)spr(202,70,100,2,2)
end if(e.x==4and e.y==3)rect(69,99,86,116,7)
for n in all(a)do if(n==13)spr(204,90,100,2,2)
end if(e.x==5and e.y==3)rect(89,99,106,116,7)
rectfill(3,60,6,120,11)camera(0,0)rectfill(0,0,127,57,6)rect(0,0,127,127,2)rect(0,0,127,57,5)if e.x==1and e.y==1do?"straight\natk: 3\ncost: 1",73,3,5
?"a powerful punch realized by\ntwisting your body and using\nthe momentum for a strike.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end if e.x==2and e.y==1do?"jab\natk:: 1\ncost: 0",73,3,5
?"a fast punch realized by\nrelaxing your fist and using\nit like a whip.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end for n in all(a)do if n==1do if e.x==3and e.y==1do?"hook\natk: 5\ncost: 3",73,3,5
?"a powerful punch that targets\nthe chin of your adversary,\ndraws power from the hip.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==2do if e.x==4and e.y==1do?"uppercut\natk: 6\ncost: 1",73,3,5
?"* this is a 2-turn move\na punch from below that\ntargets the chin.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==3do if e.x==5and e.y==1do?"footwork\natk: 0\ncost: 1",73,3,5
?"* this move buffs your str\nswift and fluid movements\nare the foundation of boxing.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==4do if e.x==1and e.y==2do?"close-in\natk: 0\ncost: 1",73,3,5
?"* this move greatly buffs both\n* of your str and your foes.\nget close and personal. ",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==5do if e.x==2and e.y==2do?"liver blow\natk: 4\ncost: 2",73,3,5
?"a powerful punch aimed at\nthe liver causes staggering\namounts of damage. ",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==6do if e.x==3and e.y==2do?"feint\natk: 0\ncost: 1",73,3,5
?"* this move debuffs your foe.\nthreaten an attack and\nconfuse your opponents.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==7do if e.x==4and e.y==2do?"overhand\natk: 6\ncost: 4",73,3,5
?"a haymaker of a punch made\nfrom an unconventional angle.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==8do if e.x==5and e.y==2do?"counter\natk: 3\ncost: 0",73,3,5
?"* this move fails if you\n* fail the minigame.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==9do if e.x==1and e.y==3do?"cross\natk: 4\ncost: 1",73,3,5
?"similar to a straight\nbut in trajectory. ",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==10do if e.x==2and e.y==3do?"flicker jab\natk: 2\ncost: 0",73,3,5
?"a jab made from an\nunorthodox stance.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==11do if e.x==3and e.y==3do?"smash\natk: 8\ncost: 3",73,3,5
?"an unorthodox move,\nmade from the mix\nof an uppercut and a cross.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==12do if e.x==4and e.y==3do?"elbow block\natk: 1\ncost: 1",73,3,5
?"a blocking technique\nmade with your elbows,\ncauses damage to the foes fist.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end for n in all(a)do if n==13do if e.x==5and e.y==3do?"gazelle punch\natk: 8\ncost: 2",73,3,5
?"a flashy punch made\nwith the muscles from\nyour lower body.",2,39,5
rect(4,4,69,37,2)spr(64,5,5,8,4)end end end end end function nM()if d==4do cls(13)rect(0,0,127,127,2)line(0,20,200,20,2)line(0,50,200,50,2)line(0,80,200,80,2)line(0,110,200,110,2)rectfill(20,10,60,30,9)rectfill(20,40,60,60,9)rectfill(20,70,60,90,9)rectfill(20,100,60,120,9)rect(20,10,60,30,2)rect(20,40,60,60,2)rect(20,70,60,90,2)rect(20,100,60,120,2)?"slot 1",28,18,15
?"slot 2",28,48,15
?"slot 3",28,78,15
?"slot 4",28,108,15
if(m[1]~=0)spr(k[1],80,13,2,2)
if(m[2]~=0)spr(k[2],80,43,2,2)
if(m[3]~=0)spr(k[3],80,73,2,2)
if(m[4]~=0)spr(k[4],80,103,2,2)
if(A==1)rect(20,10,60,30,7)?"slot 1",28,18,7
if(A==2)rect(20,40,60,60,7)?"slot 2",28,48,7
if(A==3)rect(20,70,60,90,7)?"slot 3",28,78,7
if(A==4)rect(20,100,60,120,7)?"slot 4",28,108,7
end end function nN()if d==5do cls(15)circfill(36,62,45,11)circfill(31,122,48,13)circfill(28,12,40,13)rect(0,0,127,127,2)rect(1,1,126,126,2)?"back",34,21,15
?"music",31,61,15
?"ranoutoftokenslol",37,101,15
?"back",35,22,14
?"music",32,62,14
?"ranoutoftokenslol",38,102,14
if F==1do?"back",35,22,7
elseif F==2do?"music",32,62,7
elseif F==3do?"ranoutoftokenslol",38,102,7
end?"wconfigurations",8,4,15
?"wconfigurations",9,5,7
circfill(69,72,8,13)if(Q==0)spr(16,65,68)
if(Q==-1)spr(32,65,68)
spr(174,2,18,2,2)end end function nO()if d==6do rectfill(15,15,112,112,15)rect(15,15,112,112,11)?"you won",50,50,7
if g.a>=1or g.b>=1or g.c>=1do spr(nd[g.a],20,80,2,2)spr(nd[g.b],55,80,2,2)spr(nd[g.c],90,80,2,2)?"choose your reward",25,70,7
?"⬅️",20,100
?"⬆️",55,100
?"➡️",90,100
end if(g.a*g.b*g.c<0)?"press x to continue",25,70,7
end end function nP()if d==7do rectfill(15,15,112,112,15)rect(15,15,112,112,11)?"you lost",47,50,7
?"press x to continue",25,70,7
end end function nQ()if(d==8)cls(13)spr(206,100,80,2,2)?"thank you for playing my game!\nthis is my first game so sorry\nif it feels scuffed, i hope you have fun\nbut im running out of tokens now so bye s2\n\npress 🅾️ to exit.",0,10,14
end function _init()d,Q=-1,0music(8,2000,1)q,y,O,n6,Z,a,g,nd,L,_,W,F,B,s,j,V,u,A,b,m,k=1,0,1,1,false,{},{a=-1,b=-2,c=-3},{9,11,13,39,41,43,45,170,168,140,200,202,204},0,0,0,1,0,0,0,3,1,1,{sltsta=1,sltjab=2},{},{}m[1]=37m[2]=38m[3]=0m[4]=0k[1]=3k[2]=35k[3]=0k[4]=0end function _update()if d==-1do nR()elseif d==1do nS()music(-1,1000)elseif d==2do nT()elseif d==3do nU()elseif d==4do nV()elseif d==5do nW()elseif d==6do nA()elseif d==7do nB()elseif d==8do nX()elseif I==1do nh()end if(I==0)music(-1,1000)
if(B>=1)B=B-1
nY()end function _draw()if I==1do nG()nI()nH()elseif d==-1do nF()elseif d==1do nJ()elseif d==2do nK()elseif d==3do nL()elseif d==4do nM()elseif d==5do nN()elseif d==6do nO()elseif d==7do nP()elseif d==8do nQ()end poke(22016,unpack(split"8,8,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,63,63,63,63,63,63,0,0,0,63,63,63,0,0,0,0,0,63,51,63,0,0,0,0,0,51,12,51,0,0,0,0,0,51,0,51,0,0,0,0,0,51,51,51,0,0,0,0,48,60,63,60,48,0,0,0,3,15,63,15,3,0,0,62,6,6,6,6,0,0,0,0,0,48,48,48,48,62,0,99,54,28,62,8,62,8,0,0,0,0,24,0,0,0,0,0,0,0,0,0,12,24,0,0,0,0,0,0,12,12,0,0,0,10,10,0,0,0,0,0,4,10,4,0,0,0,0,0,0,0,0,0,0,0,0,12,12,12,12,12,0,12,0,0,54,54,0,0,0,0,0,0,54,127,54,54,127,54,0,8,62,11,62,104,62,8,0,0,51,24,12,6,51,0,0,14,27,27,110,59,59,110,0,12,12,0,0,0,0,0,0,24,12,6,6,6,12,24,0,12,24,48,48,48,24,12,0,0,54,28,127,28,54,0,0,0,12,12,63,12,12,0,0,0,0,0,0,0,12,12,6,0,0,0,62,0,0,0,0,0,0,0,0,0,12,12,0,32,48,24,12,6,3,1,0,62,99,115,107,103,99,62,0,24,28,24,24,24,24,60,0,63,96,96,62,3,3,127,0,63,96,96,60,96,96,63,0,51,51,51,126,48,48,48,0,127,3,3,63,96,96,63,0,62,3,3,63,99,99,62,0,127,96,48,24,12,12,12,0,62,99,99,62,99,99,62,0,62,99,99,126,96,96,62,0,0,0,12,0,0,12,0,0,0,0,12,0,0,12,6,0,48,24,12,6,12,24,48,0,0,0,30,0,30,0,0,0,6,12,24,48,24,12,6,0,30,51,48,24,12,0,12,0,0,30,51,59,59,3,30,0,0,0,62,96,126,99,126,0,3,3,63,99,99,99,63,0,0,0,62,99,3,99,62,0,96,96,126,99,99,99,126,0,0,0,62,99,127,3,62,0,124,6,6,63,6,6,6,0,0,0,126,99,99,126,96,62,3,3,63,99,99,99,99,0,0,24,0,28,24,24,60,0,48,0,56,48,48,48,51,30,3,3,51,27,15,27,51,0,12,12,12,12,12,12,56,0,0,0,99,119,127,107,99,0,0,0,63,99,99,99,99,0,0,0,62,99,99,99,62,0,0,0,63,99,99,63,3,3,0,0,126,99,99,126,96,96,0,0,62,99,3,3,3,0,0,0,62,3,62,96,62,0,12,12,62,12,12,12,56,0,0,0,99,99,99,99,126,0,0,0,99,99,34,54,28,0,0,0,99,99,107,127,54,0,0,0,99,54,28,54,99,0,0,0,99,99,99,126,96,62,0,0,127,112,28,7,127,0,62,6,6,6,6,6,62,0,1,3,6,12,24,48,32,0,62,48,48,48,48,48,62,0,12,30,18,0,0,0,0,0,0,0,0,0,0,0,30,0,12,24,0,0,0,0,0,0,8,28,20,50,50,127,65,0,63,71,71,63,71,71,63,0,62,99,3,3,3,99,62,0,31,51,99,99,99,51,31,0,127,3,3,63,3,3,127,0,127,3,3,63,3,3,3,0,126,7,7,119,71,71,126,0,99,99,99,127,99,99,99,0,127,28,28,28,28,28,127,0,127,24,24,24,24,24,15,0,99,51,27,15,27,51,99,0,7,7,7,7,7,7,127,0,99,119,127,107,99,99,99,0,67,71,79,95,125,121,113,0,28,46,103,99,115,58,28,0,63,99,99,63,3,3,3,0,62,99,99,99,99,51,110,0,63,103,103,63,31,55,103,0,62,99,3,62,96,99,62,0,63,12,12,12,12,12,12,0,99,99,99,99,99,99,62,0,99,99,99,99,54,28,8,0,99,99,99,107,127,119,99,0,67,39,30,28,60,114,97,0,99,99,99,126,96,96,63,0,127,96,48,28,6,3,127,0,56,12,12,7,12,12,56,0,8,8,8,0,8,8,8,0,14,24,24,112,24,24,14,0,0,0,110,59,0,0,0,0,0,0,0,0,0,0,0,0,127,127,127,127,127,127,127,0,85,42,85,42,85,42,85,0,65,99,127,93,93,119,62,0,62,99,99,119,62,65,62,0,17,68,17,68,17,68,17,0,4,12,124,62,31,24,16,0,28,38,95,95,127,62,28,0,34,119,127,127,62,28,8,0,42,28,54,119,54,28,42,0,28,28,62,93,28,20,20,0,8,28,62,127,62,42,58,0,62,103,99,103,62,65,62,0,62,127,93,93,127,99,62,0,24,120,8,8,8,15,7,0,62,99,107,99,62,65,62,0,8,20,42,93,42,20,8,0,0,0,0,85,0,0,0,0,62,115,99,115,62,65,62,0,8,28,127,28,54,34,0,0,127,34,20,8,20,34,127,0,62,119,99,99,62,65,62,0,0,10,4,0,80,32,0,0,17,42,68,0,17,42,68,0,62,107,119,107,62,65,62,0,127,0,127,0,127,0,127,0,85,85,85,85,85,85,85,0"))poke(24366,1)pal({[0]=0,1,2,3,4,5,6,7,8,-3,-10,-11,12,13,-8,-14},1)if(s>=20)rectfill(0,0,900,-2.33333*s+129,0)rectfill(0,127,900,2.1*s+1,0)
if(s<=20and s>=1)rectfill(0,0,900,3.36841*s-2.36841,0)rectfill(0,127,900,-3.31579*s+130.31579,0)
end function nR()if(d==-1and btnp(❘)and s==0)s=111sfx(19,1)
if(d==-1and s>=1and s<=20)d=1
end function nS()if d==1do if(btnp(⬇️)and q>=1)q=q+1sfx(1,0)
if(btnp(⬆️)and q<=4)q=q-1sfx(1,0)
if(q>=5)q=1
if(q<=0)q=4
end if(d==1and btnp(❘)and q==1)d,y=2,0sfx(1,0)
if(d==1and btnp(❘)and q==2)nZ()d=3sfx(1,0)B=20
if(d==1and btnp(❘)and q==3)sfx(1,0)d,B=5,20
if(d==1and btnp(❘)and q==4)sfx(1,0)d,B=8,20
end function nT()if d==2do _=(W-_)*.1+_ if(btnp(➡️)and y<=6)y=y+1sfx(1,0)if(y>=3)W=W+40
if(btnp(⬅️)and y>=2)y=y-1sfx(1,0)if(y>=2)W=W-40
if(btnp(🅾️)and d==2)d=1sfx(1,0)camera(0,0)_,W=0,0
if(btnp(❘)and y==1and s<=0)s,j=60,1sfx(1,0)
if(j==1and s<=20)d,j,O,T,o=0,0,1,10,0U()
if(btnp(❘)and y==2and u==1and s<=0)s,j=60,2sfx(1,0)
if(j==2and s<=20)d,j,O,T,o=0,0,1,10,1U()
if(btnp(❘)and y==3and u==2and s<=0)s,j=60,3sfx(1,0)
if(j==3and s<=20)d,j,O,T,o=0,0,1,10,2U()camera(0,0)
if(btnp(❘)and y==4and u==3and s<=0)s,j=60,4sfx(1,0)
if(j==4and s<=20)d,j,O,T,o=0,0,2,20,3U()camera(0,0)
if(btnp(❘)and y==5and u==4and s<=0)s,j=60,5sfx(1,0)
if(j==5and s<=20)d,j,O,T,o=0,0,1,10,4U()camera(0,0)
if(btnp(❘)and y==6and u==5and s<=0)s,j=60,6sfx(1,0)
if(j==6and s<=20)d,j,O,T,o=0,0,1.5,15,5U()camera(0,0)
if(btnp(❘)and y==7and u==6and s<=0)s,j=60,7sfx(1,0)
if(j==7and s<=20)d,j,O,T,o=0,0,2,20,6U()camera(0,0)
end end function nZ()e={x=1,y=1}end function nU()if d==3do if(btnp(➡️)and e.x<=4)e.x=e.x+1sfx(1,0)
if(btnp(⬅️)and e.x>=2)e.x=e.x-1sfx(1,0)
if(btnp(⬆️)and e.y>=2)e.y=e.y-1sfx(1,0)
if(btnp(⬇️)and e.y<=2)e.y=e.y+1sfx(1,0)
if(btnp(🅾️))d=1sfx(1,0)
if(e.x==1and e.y==1and btnp(❘)and B<=10)d=4sfx(1,0)h={s="sltsta",hand1=37,hand2=3}
if(e.x==2and e.y==1and btnp(❘))d=4sfx(1,0)h={s="sltjab",hand1=38,hand2=35}
for n in all(a)do if(n==1)if(e.x==3and e.y==1and btnp(❘))d=4sfx(1,0)h={s="slthok",hand1=53,hand2=9}
end for n in all(a)do if(n==2)if(e.x==4and e.y==1and btnp(❘))d=4sfx(1,0)h={s="sltupe",hand1=54,hand2=11}
end for n in all(a)do if(n==3)if(e.x==5and e.y==1and btnp(❘))d=4sfx(1,0)h={s="sltfot",hand1=48,hand2=13}
end for n in all(a)do if(n==4)if(e.x==1and e.y==2and btnp(❘))d=4sfx(1,0)h={s="sltclo",hand1=15,hand2=39}
end for n in all(a)do if(n==5)if(e.x==2and e.y==2and btnp(❘))d=4sfx(1,0)h={s="sltliv",hand1=31,hand2=41}
end for n in all(a)do if(n==6)if(e.x==3and e.y==2and btnp(❘))d=4sfx(1,0)h={s="sltfei",hand1=47,hand2=43}
end for n in all(a)do if(n==7)if(e.x==4and e.y==2and btnp(❘))d=4sfx(1,0)h={s="sltove",hand1=63,hand2=45}
end for n in all(a)do if(n==8)if(e.x==5and e.y==2and btnp(❘))d=4sfx(1,0)h={s="sltcou",hand1=22,hand2=170}
end for n in all(a)do if(n==9)if(e.x==1and e.y==3and btnp(❘))d=4sfx(1,0)h={s="sltcro",hand1=159,hand2=168}
end for n in all(a)do if(n==10)if(e.x==2and e.y==3and btnp(❘))d=4sfx(1,0)h={s="sltfli",hand1=142,hand2=140}
end for n in all(a)do if(n==11)if(e.x==3and e.y==3and btnp(❘))d=4sfx(1,0)h={s="sltsma",hand1=143,hand2=200}
end for n in all(a)do if(n==12)if(e.x==4and e.y==3and btnp(❘))d=4sfx(1,0)h={s="sltelb",hand1=232,hand2=202}
end for n in all(a)do if(n==13)if(e.x==5and e.y==3and btnp(❘))d=4sfx(1,0)h={s="sltgaz",hand1=233,hand2=204}
end end end function nV()if d==4do if(btnp(⬇️)and A<=3)A=A+1sfx(1,0)
if(btnp(⬆️)and A>=2)A=A-1sfx(1,0)
if(btnp(🅾️))d=3sfx(1,0)
if A==1and btnp(❘)and h~=nil and b~=nil do for n,e in pairs(b)do if(e==1)b[n]=0
end b[h.s]=1for n=1,#m do if(m[n]==h.hand1)m[n]=0
end for n=1,#k do if(k[n]==h.hand2)k[n]=0
end m[1]=h.hand1 k[1],d=h.hand2,3sfx(1,0)A=1end if A==2and btnp(❘)and h~=nil and b~=nil do for n,e in pairs(b)do if(e==2)b[n]=0
end b[h.s]=2for n=1,#m do if(m[n]==h.hand1)m[n]=0
end for n=1,#k do if(k[n]==h.hand2)k[n]=0
end m[2]=h.hand1 k[2],d=h.hand2,3sfx(1,0)A=1end if A==3and btnp(❘)and h~=nil and b~=nil do for n,e in pairs(b)do if(e==3)b[n]=0
end b[h.s]=3for n=1,#m do if(m[n]==h.hand1)m[n]=0
end for n=1,#k do if(k[n]==h.hand2)k[n]=0
end m[3]=h.hand1 k[3],d=h.hand2,3sfx(1,0)A=1end if A==4and btnp(❘)and h~=nil and b~=nil do for n,e in pairs(b)do if(e==4)b[n]=0
end b[h.s]=4for n=1,#m do if(m[n]==h.hand1)m[n]=0
end for n=1,#k do if(k[n]==h.hand2)k[n]=0
end m[4]=h.hand1 k[4],d=h.hand2,3sfx(1,0)A=1end end end function nY()if(s>=1)s=s-1
end function nW()if d==5do if(btnp(🅾️))d=1sfx(1,0)
if(btnp(⬇️)and F<=2)F=F+1sfx(1,0)
if(btnp(⬆️)and F>=2)F=F-1sfx(1,0)
if(F==1and btnp(❘)and B<=0)d=1sfx(1,0)
if(F==2and btnp(❘)and Q==0)Q=-1sfx(1,0)B=20
if(F==2and btnp(❘)and Q==-1and B<=0)Q=0sfx(1,0)
end end function nX()if(d==8and btnp(🅾️)and B<=0)sfx(1,0)d,B=1,60
end