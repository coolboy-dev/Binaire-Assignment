-- peaklet - menu

function _init()
dcene=1
cplayers=1

end

function _update()
if dcene==1 then
menu_u()
wind_u()
end
if dcene==2 then
player_upt(1)
upplayer(1)
end
if dcene==3 then
player_upt(selec)
upplayer(1)
upplayer(2)
end
if dcene==4 then
load("#peakdema_guid")
load("peaklet - guidebook.p8.png")
end
if dcene==5 then
credits_u()
end
musicplay()
end

function _draw()
if dcene==1 then
cls(1)
menu_d()

end
if dcene==2 then
cls(1)
menuplay(1)
drplayer(1)
end
if dcene==3 then
cls(1)
menuplay(selec)
drplayer(1)
drplayer(2)
end
if dcene==4 then
cls(3)
rrect(8,8,114,114,3,7)
print("\^t\^w wilderness \n  handbook",16,16,7)
print("SPECIAL VOLUME \n   FOR FANS",36,44,6)
print("sCOUT LEADER mYRES",26,114,6)

end
if dcene==5 then
cls(1)
credits_d()
end

transition()
end



function savedata()
cartdata("peaklet")
local p=prs
dset(0,cplayers)
--player 1    
dset(1,prs[1].cl)   
dset(2,prs[1].eyes)   
dset(3,prs[2].cl)
dset(4,prs[2].eyes)
load("#peakdema_gsho")
load("peaklet.p8.png")
end

mplay=0
function musicplay()
if mplay==0 then
if dcene==1 then
mplay=1
music(0,300,12)
end
if dcene==2 or dcene==3 then
mplay=1
music(4,300,12)
end
end
end
-->8
---menu

mtxt={"one player","two players","guide","credits"}
opt=1
pmenu={11,3,8,10}
pekly=0
ppkl=0
function menu_d()
rrectfill(8,8,114,114,3,12)
---
rrectfill(8,8,114,14,3,13)
local sky={6,7,15}
for i=1,3 do
fillp(▒)
rrectfill(8,8,114,14+2,3,13)
rrectfill(8,104-i*8+8-2,114,20+3,3,sky[i])
fillp()
rrectfill(8,104-i*8+8,114,20,3,sky[i])
end
rectfill(8,124,120,128,1)
img(10,50,0,montaintxt)
wind_d()

---
for y=1,4 do
local c=7
local tt=8*#mtxt[y]/1.25
local ty=64+y*8+6+1*y

if opt==y then
c=9
tt=8*#mtxt[y]/1.35
end
pal(11,ssho[pmenu[y]])
rectfill(8,64+y*8+1*y,tt,ty+1,11)
spr(142,tt,ty-5)
pal(11,pmenu[y])
rectfill(8,64+y*8+1*y,tt,ty,11)
spr(142,tt,ty-6)
pal()
cprint(mtxt[y],14,64+y*8+1*y,c)
end
sspr(3,67,92,20,20,10+pekly)
sspr(96,63,12,12,6,112)
end

pss=0
function menu_u()

if pekly<4 then
if  ppkl==0  then
pekly+=0.2
end 
else
ppkl=1
end

if pekly>0 then
if  ppkl==1  then
pekly-=0.2
end
else
ppkl=0
end

if btn(⬆️) and pss==0 then
opt-=1
pss=1
sfx(63,2,0,1)
end
if btn(⬇️) and pss==0 then
opt+=1
pss=1
sfx(63,2,0,1)
end

if btn(❘) and opt==1 then
trans=2
cplayers=1
end

if btn(❘) and opt==2 then
selec=1
trans=3
cplayers=2
end

if btn(❘) and opt==3 then
trans=4
end

if btn(❘) and opt==4 then
trans=5
end

local cps=0
for ps=0,3 do
if btn(ps)==false then
cps+=1
end
end

if cps==4 then
pss=0
end

opt=mid(1,4,opt)
end

fgt=0
set=0
function transition()

if trans!=nil then
rectfill(128-fgt,0,256-fgt,128,1)
rectfill(230-fgt,8,256-fgt,120,7)
fgt+=8
if fgt==128 then
sfx(61,2,0,8) 
for w in all(wind) do
del(wind,w)
end
dcene=trans
if dcene==2 or dcene==3 then
mplay=0
end
end
if fgt>256 then
trans=nil
fgt=0
end 
end
circfill(120-fgt,120,24,3)
circfill(120-fgt,120,23,11)

end


stw=0
wind={}

function make_wind()
add(wind,{
x=0,     
y=rnd(128),     
t=rnd(1),       
spd=1+rnd(1),
amp=3+rnd(4),
freq=0.02,
trail={},
})
end

function wind_u()
if (#wind < 8) make_wind()

  for w in all(wind) do
    w.x += w.spd
    w.t += w.freq
    local cur_y = w.y + sin(w.t) * w.amp
    
    -- adiciona posi????o atual ao rastro
    add(w.trail, {x=w.x, y=cur_y})
    
    -- controla o comprimento da linha (ex: 10 pontos)
    -- aumente o 10 para uma linha ainda mais comprida
    if (#w.trail > 10) del(w.trail, w.trail[1])
    
    if (w.x > 140) del(wind, w)
  end
end

function wind_d()
for w in all(wind) do
    for i=2, #w.trail do
      local p1 = w.trail[i-1]
      local p2 = w.trail[i]
      clip(8,8,114,120)
      line(p1.x, p1.y, p2.x-1, p2.y, 6)
      line(p1.x, p1.y, p2.x, p2.y, 7)
    		clip()
    end
  end
end
-->8
-- players make
--players sistem
--py=252*8,7*8
--x=11*8,y=160*8 x=10*8,y=140*8
dev=true
predit=1
selec=1
prs={
{x=4*8,y=12*8,sp=1,anm="idle",dir=false,gb=false,
gv=0,stm=10,bstm=0,stmx=25,lx=0,ly=0,dx=1,dy=0,
set=1,fmx=0,fmn=0,yy=2,spd=1,gspd=0.5,cl=1,dmg=0,wgt=0,psn=0,burn=0,ivn=0,kn=0,fdmg=0,
ph=0,its=1,use=0,ptn=0,eyes=1,mode="live",
},

{x=6*8,y=12*8,sp=1,anm="run",dir=false,gb=false,
gv=0,stm=25,bstm=0,stmx=25,lx=0,ly=0,dx=1,dy=0,
set=1,fmx=0,fmn=0,yy=2,spd=1,gspd=0.5,cl=2,dmg=0,wgt=0,psn=0,burn=0,ivn=0,kn=0,fdmg=0,
ph=0,its=1,use=0,ptn=0,eyes=1,mode="live",},
}
prsitens={{0,0,0,},{0,0,0}}

---
colors={{11,3},{10,9},{14,2},{12,13},{8,2},{4,2},{9,4},{13,5}}
seyes={8,11,14,17,20,23,26}
btpss={⬅️,➡️,⬆️,⬇️,❘,🅾️}

bprt={
sidle={8,8,9,6},
srun={{0,8,8,6},{0,14,8,6},{0,20,8,6},{0,26,8,6}},
sgrab={{8,14,9,6},{8,20,9,6},{8,26,9,6},{25,20,7,6}},
sbpack={{17,8,7,6},{17,14,7,6},{17,20,8,8}},
sfall={{24,8,9,6},{24,14,9,6}}
}

nameseye={"nORMAL","bORING","mAKEUP",
"sNAKE"," wARY "," NERD "," cUTE "}
local gvv = 0.3
local fpl = -3

function initplayer(ps)
local p=prs[ps]

p.stm=p.stmx-p.dmg-p.wgt-p.burn
end

function drplayer(ps)
 local p=prs[ps]
 local x,y,dir,cl,anm=p.x,p.y,p.dir,p.cl,p.anm
 local h,bh=0,0

 if dir then
  bh=7
  if anm=="idle" or anm=="grab" or anm=="fall" then h=1 end
  if anm=="bpack" or anm=="grabp" then
   h=-1
   if p.use==1 then h=0 end
   cspr(p.sp,x+h,y-5,1,0.9,dir,false,0,0,ps)
  end
 end

 cspr(p.sp,x+h,y-5,1,1,dir,false,0,0,ps)
 csspr(p.dx,p.dy,p.lx,p.ly,x,y+p.yy,p.lx,p.ly,dir,false,0,1,ps)

 pal(11,colors[cl][1])
 pal(3,colors[cl][2])

 if anm=="idle" then
  sspr(41,seyes[p.eyes],7,3,x+1,y-2,7,3,dir)
 end
 if anm=="run" then
  local eyd=dir and 3 or 0
  sspr(41,seyes[p.eyes],3,3,x+4-eyd,y-2,3,3,dir)
 end
 if anm=="bpack" then
  pal(6,0)
  if p.use==0 then
   spr(07,x+3-bh,y,1,1,dir,false,0,0,ps)
  else
   for i in all(itd) do
    csspr(i.sx,i.sy,i.sw,i.sh,x+i.ox,y-5,i.sw,i.sh,false,false,0,2)
   end
  end
 end
 pal()
end

ips=0


function upplayer(ps)

local p=prs[ps]
local pc= ps-1
local ipt=false
local nmd= colpr(p.x,7,p.y+2,0)
local stats=p.dmg+p.wgt+p.psn+p.burn
local bpct=0
local nmp= colpr(p.x,7,p.y,0) -- colis??o lateral


-- movimento lateral
if predit==3 or selec!=ps then
	if p.ph<=20 and p.anm!="bpack" then
	if btn(⬅️,pc) and p.gb==false then
	if not colpr(p.x-p.spd,7,p.y,0) then
	p.x-=p.spd
	p.anm="run"
	p.dir=true
	
	end end
	if btn(➡️,pc) and p.gb==false then
	if not colpr(p.x+p.spd,7,p.y,0) then
	p.x+=p.spd
	p.anm="run"
	p.dir=false
	end end
	
	
	if btn(🅾️, pc) and nmd and p.gb==false and btn(⬇️,pc)==false and p.anm!="bpack" then
	if not colpr(p.x,7,p.y-2,0)  then 
	p.gv = fpl
	end
	end
	else
	if p.ph<21 then
	p.use=0
	end
	p.anm="bpack"
	end
	if btn(⬇️,pc)==true and nmd then
	p.ph+=1
	else
	p.ph=0
	end
	
	--fall dmg
	if not nmd and p.gb==false  then 
	p.fdmg+=0.4
	if p.fdmg>10 then 
	p.anm="fall"
	end
	else
	if p.fdmg>10 then 
	p.anm="fall"
	invi(flr(p.fdmg-10),10,ps,nil)
	end
	p.fdmg=0
	end
	
	local gfl1=colpr(p.x,7,p.y,1)
	local gfl2=colpr(p.x,7,p.y,2)
	if gfl2 then p.gspd=0.25 else p.gspd=0.5 end 
	
	if (gfl1 or gfl2) and btn(❘,pc) and p.stm>0 and p.ph<=20  then
	p.gb=true
	p.gv=0
	if p.bstm>0 then
	p.bstm-=0.2
	else
	if p.stm>0 then
	p.stm-=0.2
	end
	end
	
	p.anm="grab"
	if btn(⬅️,pc) then
	if not colpr(p.x-p.gspd,7,p.y,0)   then
	p.x-=p.gspd
	end
	end
	if btn(➡️,pc) then
	if not colpr(p.x+p.gspd,7,p.y,0) then
	p.x+=p.gspd
	end 
	end
	if btn(⬆️,pc) then
	if not colpr(p.x,7,p.y-1,0) then
	p.y-=p.gspd
	end 
	end
	if btn(⬇️,pc) then
	if not colpr(p.x,7,p.y+2,0) then
	p.y+=p.gspd
	end 
	end
	
	else p.gb=false
	
	if nmd and p.stm<p.stmx-stats then
	p.stm+=0.2
	if p.stm>p.stmx-stats then
	p.stm=p.stmx-stats end 
	end 
	end
end


for i=1,6 do
if btn(btpss[i],pc) then
ipt=true
end end

if not p.gb then
p.gv=p.gv+gvv
if p.gv>4 then p.gv=4 end
end

local ny=p.y+p.gv



if p.gv<0 and colpr(p.x,7,ny-2,0) then
p.gv=0
p.y=flr(p.y/8)*8 + 8 
end

if p.gv>0 and colpr(p.x,7,ny,0) then
p.gv=0
p.y=flr(ny/8)*8+8-8
else

p.y=ny
end

if ipt==false and ips<30 then
ips+=1
else ips=0 end

if ips>18 then
if p.ph<20 and p.fdmg<10 then
if p.ptn==0 then
p.anm="idle"
p.sp=1
end
end
end

midf(ps)

aniplayer(p.anm,ps)

end


function colpr(x,vx,y,flag)
local cx1 = flr(x)/8
local cx2= flr(x+vx)/8
local cy1 = flr(y)/8 
local cy2 = flr(y+7)/8
if
fget(mget(cx1,cy1),flag) or
fget(mget(cx1,cy2),flag) or
fget(mget(cx2,cy1),flag) or
fget(mget(cx2,cy2),flag)
then vl=true else vl= false  end
return vl
end

fr=0
function aniplayer(vl,ps)
local v=prs[ps]
local v=prs[ps]
local a,b,c,d
local bs
local bb


if vl=="idle" then
v.fmx=1
v.fmn=1
bb=2
bs=bprt.sidle
end

if vl=="grabp" then
v.fmx=1
v.fmn=1
bb=2
bs=bprt.sgrab[4]
v.sp=23
end



if vl=="fall" then
v.fmx=2
v.fmn=1
fr+=1
bb=3
end

if vl=="run" then
v.fmx=4
v.fmn=1
fr+=1
bb=2
end

if vl=="bpack" then
if v.use==1 then
v.fmx=3
v.fmn=3
v.set=3
bs=bprt.sbpack[3]
bb=0
v.sp=6
else
v.fmx=2
v.fmn=1
bb=2
fr+=0.5
v.sp=5
end
end




if vl=="grab" then
v.fmx=3
v.fmn=1
bb=2
for i=1,3 do
if btn(btpss[i],ps-1) then
fr+=1
end
end
end


if fr>4 then
v.set+=1
fr=0
end


if v.set>v.fmx then
v.set=v.fmn
end

if vl=="run" then
bs=bprt.srun[v.set]
v.sp=03
if v.burn>0 then
v.burn-=1/30
end
end

if vl=="bpack" and v.use==0 then
bs=bprt.sbpack[v.set]
v.sp=5
end

if vl=="fall" then
bs=bprt.sfall[v.set]
v.sp=22
end

if vl=="grab" then
bs=bprt.sgrab[v.set]
v.sp=02
end


if bs then
a,b,c,d=bs[1],bs[2],bs[3],bs[4]

v.dx=a
v.dy=b
v.lx=c
v.ly=d
v.yy=bb
end
end


function midf(ps)
local p=prs[ps]


p.x=mid(16,98,p.x)
p.its=mid(1,3,p.its)
p.wgt=mid(0,9,p.wgt)
p.psn=mid(0,p.stmx,p.psn)
p.dmg=mid(0,p.stmx,p.dmg)
p.stm=mid(0,p.stmx,p.stm)
p.bstm=mid(0,p.stmx,p.bstm)
p.ivn-=0.6
p.ivn=mid(0,20,p.ivn)

local statusn=p.psn+p.wgt+p.dmg+p.burn
end




function menuplay(ps)
p=prs[ps]
local cl=p.cl

rrectfill(8,8,114,114,3,7)
fillp(-16770.5)
rrectfill(8,8,114,114,3,15)
fillp()
for lll=0,3 do
line(100+lll,8,60,80+lll,12)
end

rectfill(20,14,53,23,7)
rrectfill(12,20,50,48,3,7)

cprint("passport",22,15,12)
cprint("name:",64,23,12)

cprint("player 0"..ps,64,30,5)
spr(68,32,6)
rectfill(62,45,113,66,7)
rect(62,45,113,66,6)

local icon={69,70,85,86}
for i=1,4 do 
local y=1

if i==predit then
y=0
end
spr(icon[i],56+i*8+i,38-y)
end
if predit==1 then
for cc=1,8 do
local yy,xx=0,0
pal(11,colors[cc][1])
pal(3,colors[cc][2])
if p.cl==cc then
pal(7,6)
pal(6,13)
end
if cc>5 then
yy+=9
xx=-45
end
spr(71,56+cc*8+cc+xx,48+yy)
pal()
end
end
if predit==2 then
spr(72,64,48,1,1,true)
cprint(nameseye[p.eyes],75,50,13)
spr(72,104,48)
end
if predit==3 then
cprint("tEST YOU",72,48,9)
cprint("  sCOUT",70,55,9)
end
if predit==4 then
cprint("pRESS ❘ TO",68,48,9)
cprint("  sTART",70,55,9)
end

if cl!=4 then
rrectfill(14,22,46,44,3,12)
else 
rrectfill(14,22,46,44,3,10)
end
rectfill(16,72,112,115,12)
map(15,0,0,0,16,16)
map(30,0,0,0,16,16)

map(0,0,0,0,16,16)
rect(16,72,112,115,1)
playerhead(selec)
end

sseyes={
{16,32},
{16,37},
{16,42},
{16,47},
{16,52},
{16,57},
{4,48},
}

psspl=0
function player_upt(ps)
local p=prs[ps]
local pc=ps-1
if selec==ps then
if psspl==0 then 
if btn(⬆️,pc) then
predit-=1
sfx(63,2,0,1)
end
if btn(⬇️,pc) then
predit+=1
sfx(63,2,0,1)
end
if btn(⬅️,pc) then
if predit==1 then
p.cl-=1
sfx(62,2,0,1)
end 
if predit==2 then
p.eyes-=1
sfx(62,2,0,1)
end 
end
if btn(➡️,pc) then
if predit==1 then
p.cl+=1
sfx(62,2,0,1) 
end
if predit==2 then
p.eyes+=1
sfx(62,2,0,1) 
end 
end
if btn(❘,pc) then
if predit==4 and dcene==2 then
savedata()

end  
if predit==4 and dcene==3 and selec==1 then
predit=1
selec=2
end
if predit==4 and dcene==3 and selec==2 then
savedata()
end
end

end
end

p.cl=mid(1,8,p.cl)
p.eyes=mid(1,7,p.eyes)

local cps=0
for ps=0,3 do
if btn(ps,selec-1)==false then
cps+=1
else
psspl=1
end
end

if cps==4 then
psspl=0
end


predit=mid(1,4,predit)
end

function playerhead(ps)
p=prs[ps]
local cl=p.cl
pal(11,colors[cl][1])
pal(3,colors[cl][2])
sspr(0,32,16,16,21,34,32,32)
local ex=0
if p.eyes==7 then
ex=1
end
sspr(sseyes[p.eyes][1],sseyes[p.eyes][2],12,5+ex,25,46,24,10+ex*2)



pal()
end



-->8
-- extras
-- extras
montaintxt="5d4c0000000000000000000000000000000000000000000000000000000fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f7eef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00f7eef000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffff7eeef000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffff7eeef000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff7feeeef0000000000000000000000000000000000000000000000000000000000000000000000000000000000feff7eeeeef0000000000000000000000000000000000000000000000000000000000000000000000000000000000fef7feefeef000000000000000000000000000000000000000000000000000000000000000000000000000000000feef7fee7eef00000000000000000000000000000000000000000000000000000000000000000000000000000000feef7feee7eee88000000000000000000000000000000000000000000000000000000000000000000000000000000feef7fee7feee22880000000000000000000000000000000000000000000000000000000000000000000000000000fefffeee7feee2222800000000000000000000000000000000000000000000000000000000000000000000000000feefffee7ffeee2222800000000000000000000000000000000000000000000000000000000000000000000000000feffefee7ffeee222280000000000000000000000000000000000000000000000000000000000000000000000000feefefee7fffeee222228000000000000000000000000000000000000000000000000000000000000000000000000fefeefee7ffeeef22222800000000000000000000000000000000000000000000000000000000000000000000000fefeeeee7fffeeef2222280000000000000000000000000000000000000000000000000000000000000000000000feeeeeeee7fffeeff2222280000000000000000000000000000000000000000000000000000000000000000000000feeeeeee7ffffefff222228000000000000000000000000000000000000000000000000000000000000000000000feeeeeee7ffffeffff222222800000000000000000000000000000000000000000000000000000000000000000000feeeeee7ffffffffff22222280000000000000000000000000000000000000000000000000000000000000000000feeeeee7fffff222ff22222228000000000000000000000000000000000000000000000000000000000000000000feeeeee7ffff22222222222222800000000000000000000000000000000000000000000000000000000000000000feeeeee7ffff22222222222222280000000000000000000000000000000000000000000000000000000000000000feeeeeffff2222222222222222222800000000000000000000000000000000000000000000000000000000000000feeeeeffff2222222222222222222280000000000000000000000000000000000000000000000000000000000000feeeeefff22222222222222222222228000000000000000000000000000000000000000000000000000000000000feeeeefff22222222222222222222222800000000000000000000000000000000000000000000000000000000000feeeeef2222222222222ee2222222222280000000000000000000000000000000000000000000000000000000000feeeeeff222222222222eeee2222222222280000000000000000000000000000000000000000000000000000000ffeeeeeff22222227722eeeeee22222222222800000000000000000000000000000000000000000000000000000ffeeeeffff22222277ffeeeeeeee222222222228000000000000000000000000000000000000000000000000000ffeeeefffff2227777feeeeeeeeeee2222222222280000000000000000000000000000000000000000000000000ffeeeeffff222777fffeeeeeeeeeeee2222222222228000000000000000000000000000000000000000000000000feeeeeffff2277fffeeeeeeeeeeeeeee222222222211d00000000000000000000000000000000000000000000000feeeeefff2777ffeeeeeeeeeeeeeeeeee2222222221111d0000000000000000000000000000000000000000000000feeeefff77fffeeeeeeeeeeeeeeeeeee22222222211111d000000000000000000000000000000000000000000000feeefffffffeeeeeeeeeeeeeeeeeeeee2222222221111128000000000000000000000000000000000000000000000feeeeeeeeeeeeeeeeeeeeeeeeeeeeee2222222211111122800000000000000000000000000000000000000000000feeeeeeeeeeeeeeeeeeeeeeeeeee2ee22222221111111222808000000000000000000000000000000000000000000feeeeeeeeeeeeeeeeeeeeeeeee2222222222111111112222282800000000000000000000000000000000000000000feeeeeeeeeeeeeeeeeeeeeeee2222222221111111112222222280000000000000000000000000000000000000000f2eeeeeeeeeeeeeeeeeeeeeeee2222211111111111222222222280000000000000000000000000000000000000000feeeeeeeeeeeeeeeeeeeeeeee2222211111111112222222222222800000000000000000000000000000000000000feeeeeeeeeeeeeeeeeeeeeeee22222211111111222222222222222800000000000000000000000000000000000000feeeeeeeeeeeeeeeeeeeeeee22222222111112222222222222222280000000000000000000000000000000000000feeeeeeeeeeee222ee2eeeee222ee22222222222222222222222211d0000000000000000000000000000000000000feeeeeeeeeee2222222eeeeeeeeeee22222222222222222222221111d000000000000000000000000000000000000feeeeeeeeee2222222eeeeeeeeeeee22222222222222222222221111d00000000000000000000000000000000000feeeeeeeeee2222222eeeeeeeeeeeeee22ee222222222222222221111d00000000000000000000000000000000000feeeeeeeeeee222222eeeeeeeeeeeeeeeeeee22222222222222221111d0000000000000000000000000000000000feeeeeeeeeeeee222222eeeeeeeeeeeeeeeeee222222222222222211111d000660000000000000000000000000000feeeeeeeeeeeeee22222222eeeeeeeeeeeeee2222222222222222211111d006dd6000000000000000000000000000feeeeeeeeeeeeee22222222eeeeeeeeeeeee22222222222222222111111d06ddd600000000000000000000000000feeeeee22eeeeeee22222222eeeeeeeeeeee22222222222222222211111166dddd600000000000000000000000000feeeee22222eeeeee222222eeeeeeeeeeeeeee2222222222222221111111dddddd28800000000000000000000000feeeee212212222eee22221eeeeeeeeeeeeeeeee22222222212221111111ddddddd22280000000000000000000000feeeee2222222222222222eeeeeeeeeeeeeeeeee2222221111222111111ddddddd222228800000000000000000000fe2ee12112222121221111eeeeeeeeeeeeeeeee2222222222222111111dddddddd22222228000000000000000000fee2112221112111221211eeeeeeeeeeeee222222222212212212111111111ddddd22122122800000000000000000fe2222121222111112122eeeeeeeeeeeee22222222221212122111111111111dddd1222221180000000000000000f22222112211121212111eeeeeeeeeeeee221212212112121212211111111111dddd121212212d000000000000000f12122121111111121112eeeeeeeeeeeee221212122221211211111111111111dddd121121111d0000000000ffffff11212111111111111111eeeeeeeeeeee1121122121eee12111111111111111dddd1111111121d000000000fdddddd11111121111111112211eeeeeeeeeeef112212221eeeee11111111111111ddddd11111211112d00000000fddddddddd111121111121121111eeeeeeeeefff111121eeeeeeeee111111111111dddddd111111121111d0000000fddddddddddd1111111111111111eeeeeeffffff12112eeeeeeeeee11111111111ddddddd111111111111d000000f11ddddddddddd11111111112111eeeeefffffff7777777eeeeeeee11111111111ddddddd1111111111111d000000f1111111ddddddd111111111111eeeefff777777fffeeeeeeeeee111111111111dddddddd1111111111111d00000f1111211111dddddddd11111111eef77777fffeffeeeeeeeeee111111111111111ddddddd111111111111111d000f1111111111111dddddddd11111e777ffffffeeeeeeeeeee111111111111111111ddddddd1111111111111111d000f111111111111ddddddddddddd111111111111111111111111111111111111111ddddddd11111111111111111d00f111111111111dddddddddddddddddddd11111111111111111111111111111111ddddddd111111111111111111d0f1111111111111ddddddddddddddddddddddddddddddddd111111111111111dddddddddddddddd11111111111111d111111111111111dddddddddddddddddddddddddddd11111111111111111ddddddddddddddddddddd11111111111d"
ssho={0,1,5,2,1,13,6,2,4,9,3,13,5,2,14}

function cprint(txt,x,y,c1)
print(txt,x,y+1,ssho[c1])
print(txt,x,y,c1)
end

function cspr(nn,x,y,w,h,fx,fy,c1,d,tp)
local _p=pal
local _s=spr
local l={11,3}


if tp!=nil then
local p=prs[tp]
for i=1,2 do
if p.burn>0 then
c1 = (flr(t()*4)%2==0)and 9 or 8
end
if p.psn>0 then
c1 = (flr(t()*4)%2==0)and 1 or 2
end
if p.ivn>0 then
c1 = (flr(t()*4)%2==0)and 7 or 8
end
end
end

for i=0,15 do
_p(i,c1)
end
_s(nn,x+1,y,w,h,fx,fy)
_s(nn,x-1,y,w,h,fx,fy)
_s(nn,x,y-1,w,h,fx,fy)
if d==0 then
_s(nn,x,y+1,w,h,fx,fy)
end
_p()
if tp!=nil then
local p=prs[tp]
for i=1,2 do
pal(l[i],colors[p.cl][i])
end
end
_s(nn,x,y,w,h,fx,fy)
pal()
end


function csspr(dx,dy,lx,ly,x,y,w,h,fx,fy,c1,d,tp)
local _p=pal
local _s=sspr
local l={11,3}


if tp!=nil then
local p=prs[tp]
for i=1,2 do
if p.burn>0 then
c1 = (flr(t()*4)%2==0)and 9 or 8
end
if p.psn>0 then
c1 = (flr(t()*4)%2==0)and 1 or 2
end
if p.ivn>0 then
c1 = (flr(t()*4)%2==0)and 7 or 8
end
end
end

for i=0,15 do
_p(i,c1)
end
_s(dx,dy,lx,ly,x-1,y,w,h,fx,fy)
_s(dx,dy,lx,ly,x+1,y,w,h,fx,fy)
if d==2 then
_s(dx,dy,lx,ly,x,y-1,w,h,fx,fy)
end
if d!=1 then
_s(dx,dy,lx,ly,x,y+1,w,h,fx,fy)
else _s(dx,dy,lx,ly,x,y+1,w,h-1,fx,fy)  end
_p()
if tp!=nil then
local p=prs[tp]
for i=1,2 do
pal(l[i],colors[p.cl][i])
end
end
_s(dx,dy,lx,ly,x,y,w,h,fx,fy)
pal()
end

function img(drawx,drawy,transcol,picdata)
 local width,height=tonum(picdata[1]..picdata[2],0x1),tonum(picdata[3]..picdata[4],0x1)
 for row=0,height-1 do
  for col=0,width-1 do
   local current=tonum(picdata[5+col+(row*width)],0x1)
   if(current!=transcol)pset(drawx+col,drawy+row,current)
  end
 end
end
-->8
--credits
--developer:rraffaelrocha
--art cover:rraffael / davbo
-- music credits:
-- original developers : agrocrab devs
-- 

function credits_d()
local _r= rects
rrectfill(8,8,114,114,3,0)
rrect(8,8,114,114,3,7)
clip(9,8,114,114)
fillp(▒)
circfill(60,114,28,1)
fillp()
circfill(60,114,26,1)
palt(14)
spr(11,40,105,5,2)
palt()
rrect(8,8,114,114,3,7)
_r(1,13,50,19,10)
cprint("developer",12,14,7)
print("rRAFFAEL ROCHA",14,22,7)
spr(192,80,12,2,2)
_r(1,33,50,39,14)
cprint("cover art",12,34,7)
print("dAVBO / rRAFFAEL",14,42,7)
spr(194,82,32,2,2)

_r(1,53,60,59,2)
cprint("music credits",12,54,7)
print("gRUBER FROM PICO-8 tUNES",14,62,7)
spr(196,98,72,2,2)

_r(1,81,84,87,8)
cprint("original developers",12,82,7)
print("aGGRO cRAB DEVS",14,90,7)
clip()
end

function credits_u()
if btn(❘) then
trans=1
end
end
function rects(x,y,x2,y2,c,dir)
rectfill(x,y,x2,y2+1,ssho[c])
rectfill(x,y,x2,y2,c)
pal(11,ssho[c])
if dir==nil then
spr(142,x2,y+1)
pal(11,c)
spr(142,x2,y)
pal()
else
spr(142,x-8,y+1,1,1,true)
pal(11,c)
spr(142,x-8,y,1,1,true)
pal()
end
end