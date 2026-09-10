--knutil_0.14.0
--@shiftalow / bitchunk
version='v0.14.0'
--set1:basic
function amid(...)
	return mid(-...,...)
end

--bigendian
function bpack(w,s,b,...)
return b and flr(0x.ffff<<add(w,deli(w,1))&b)<<s|bpack(w,s-w[1],...) or 0
end

function bunpack(b,s,w,...)
if w then
return flr(0x.ffff<<w&b>>>s),bunpack(b,s-(... or 0),...)
end
end

function cat(f,...)
foreach({...},function(s)
for k,v in pairs(s) do
if tonum(k) then
add(f,v)
else
f[k]=v
end
end
end)
return f
end

function comb(k,v)
local a={}
for i=1,#k do
a[k[i]]=v[i]
end
return a
end

function ecpalt(p)
	palt()
	return tmap(p,function(v,i)
		palt(i,v==0)
	end)
end

function htd(b,n)
	local a={}
	foreach(msplit(b,n or 2),function(v)
		add(a,tonum('0x'..v))
	end)
	return a
end

function htbl(s,...)
	local t,k={}
	s,_htblc=split(s,"") or s,_htblc or 1
	while 1 do
		local p=s[_htblc]
		_htblc+=1
		if p=="{" or p=="=" then
			local r=htbl(s,...)
			if not k then
				add(t,r)
			else
				--number key comvert to index
				t[tonum(k) or k],k=p=="{" and r or r[1]
			end
		elseif not p or p=="}" or p==";" or p==" " then
			add(t,k~="false" and (k=="true" or tonum(k) or k=="/0/" and "" or k))
			_htblc,k=p and _htblc or nil
			if p~=" " then
				break
			end
		elseif p~="\n" then
			k=(k or "")..(... and replace(p..'',...) or p)
--			k=(k or "")..(... and replace(p..'',...) or replace(p..'',"\r","\n","\t"," "))
		end
	end
	return t
end

function join(d,s,...)
return not s and '' or not ... and s or s..d..join(d,...)
end

function mkpal(p,s,...)
	if s then
		return comb(htd(p,1) or p,htd(s,1) or s),mkpal(p,...)
	end
end

function msplit(s,d,...)
	local t=split(s,d or ' ',false)
	for i,v in pairs(... and t) do
		t[i]=msplit(v,...)
	end
	return t
end

function inrng(...)
return mid(...)==...
end

function oprint(s,x,y,f,o,p)
	?'\^o'..('0123456789abcdef')[o+1]..(p or 'ff')..s,x,y,f
end

function rceach(p,f)
p=count(p) and p.x and p or _rfmt(p)
for y=p.y,p.ey do
for x=p.x,p.ex do
f(x,y,p)
end
end
end

function replace(s,f,r,...)
local a,i='',1
while i<=#s do
if sub(s,i,i+#f-1)~=f then
a..=sub(s,i,i)
i+=1
else
a..=r or ''
i+=#f
end
end
return ... and replace(a,...) or a
end

function tbfill(v,s,e,...)
local t={}
for i=s,e do
t[i]=... and tbfill(v,...) or v
end
return t
end

function tmap(t,f)
for i,v in pairs(t) do
v=f(v,i)
if v~=nil then
t[i]=v
end
end
return t
end

function tohex(v,d)
v=sub(tostr(tonum(v),1),3,6)
while v[1]=='0' and #v>(d or 0) do
v=sub(v,2)
end
return v
end

function ttable(p)
return count(p) and p
end

--set2:objects
--exrect
_mkrs,_hovk,_mnb=htbl'x y w h ex ey r p'
,htbl'{x y}{x ey}{ex y}{ex ey}'
	,htbl'con hov ud rs rf cs cf os of camx camy'
function _rfmt(p)
local x,y,w,h=unpack(ttable(p) or split(p,' ',true))
return comb(_mkrs,{x,y,w,h,x+w-1,y+h-1,w/2,p})
end

function exrect(p)
local o=_rfmt(p)
return cat(o,comb(_mnb,{
function(p,y)
if y then
local cx,cy=camera()
camera(cx,cy)
return inrng(p+cx,o.x,o.ex) and inrng(y+cy,o.y,o.ey)
else
return o.con(p.x,p.y) and o.con(p.ex,p.ey)
end
end
,function(r,i)
local h
for i,v in pairs(_hovk) do
h=h or o.con(r[v[1]],r[v[2]])
end
return h or i==nil and r.hov(o,true)
end
,function(p,y,w,h)
return cat(
o,_rfmt((tonum(p) or not p) and {p or o.x,y or o.y,w or o.w,h or o.h} or p
))
end
,function(col,r,f)
f=(f or rrect)(o.x-o.camx,o.y-o.camy,o.w,o.h,r or 0,col)
return o
end
,function(col,r)
return o.rs(col,r,rrectfill)
end
,function(col,f)
(f or circ)(o.x+o.r-o.camx,o.y+o.r-o.camy,o.w/2,col)
return o
end
,function(col)
return o.cs(col,circfill)
end
,function(col)
return o.rs(col,oval)
end
,function(col)
return o.rs(col,ovalfill)
end
,0,0 --cam
}))
end

--scenes
_odkey=msplit'_rate _cnt _rm _fst _lst _nm _dur _prm'
function scorder(...)
local o={}
return cat(o,comb(_odkey,{
function(d,r,c)
local f,t=unpack(ttable(d) or msplit(d))
r=max(r or _dur,1)
return min(c or _cnt,r)/max(r,1)*(t-f)+f
end
,0,false,true,false
,...
}))
end

_scal={}
function mkscenes(keys)
return tmap(ttable(keys) or msplit(keys),function(v)
local o={}
_scal[v]=cat(o,comb(msplit'ps st rm cl fi cu us env tra ords nm',{
function(...)
return add(o.ords,scorder(...))
end
,function(...)
o.cl()
return o.ps(...)
end
,function(s)
s=s and o.fi(s) or not s and o.cu()
if s then
del(o.ords,s)._rm=true
end
return s
end
,function()
local s={}
while add(s,o.rm()) do
end
return s
end
,function(key)
for v in all(o.ords) do
if v._nm==key or _nm==key or key==v then
return v end
end
return false
end
,function(n)
return o.ords[n or 1]
end
,function(...)
return add(o.ords,scorder(...),1)
end
,function(c)
foreach(_odkey,function(v)
_ENV[v],c[v]=c[v],_ENV[v]
end)
return c
end
,function(n)
local c=ttable(n) or o.cu(n)
if c then
o.env(c)
_cnt+=1
_cnt,_fst,_lst=_cnt==0x7fff and 1 or _cnt,_cnt==1,inrng(_dur,1,_cnt)
if _rm or _nm and _ENV[_nm] and _ENV[_nm](c) or _lst then
o.rm(o.env(c))
else
o.env(c)
end
end
end
,{},v
}))
return o
end)
end

function scmd(b,p,...)
p=p or {}
return tmap(msplit(join("",unpack(split(b,"\t"))),"\n",' '),function(v)
local s,m,f,d=unpack(v)
return s=='' and 'nac' or _scal[s] and _scal[s][m](f,tonum(d),p) or false
end)
,... and scmd(...)
end

function transition(v)
 v.tra()
end

function transitionp(v)
	foreach(v.ords,v.tra)
end

-->8
--set3:debugging
--dmp
function dmp(v,q,s)
--	poke(0x5f58,0)
	if not s then
	 q,s,_dmpx,_dmpy="\f6","\n",0,-1
	end
	local p,t=s
	tmap(ttable(v) or {v},function(str,i)
		t=type(str)
		if ttable(str) then
			q,p=dmp(str,q..s..i.."{",s.." ")..s.."\f6}",s
		else
		 q..=join('',p,i
		 ,comb(msplit"number string boolean function nil"
		 ,msplit"\ff#\f6:\ff \fc$\f6:\fc \fe%\f6:\fe \fb*\f6:\fb \f2!\f6:\f2"
			)[t],tostr(str),"\f6 ")
			p=""
		end
	end)
	q..=t and "" or s.."\f2!\f6:\f2nil"
	::dmp::
	_update_buttons()
	if s=="\n" and not btnp'5' then
		flip()
		cls()
		?q,_dmpx*4,_dmpy*6
		_dmpx+=_kd'0'-_kd'1'
		_dmpy+=_kd'2'-_kd'3'
		goto dmp
	end
	return q
end

function _kd(d)
return tonum(btn(d))
end

--dbg
function dbg(...)
	local p,d={},{...}
	for i=1,#d do
		if add(p,tostr(d[i]))=='d?' then
			poke(0x5f58,0)
			tmap(_dbgv,function(v,i)
				oprint(join(' ',unpack(v)),0,128-i*8,5,7)
			end)
			_dbgv,p={}
		end
	end
	add(_dbgv,p,1)
end
dbg'd?'
-->8
cat(_ENV,htbl[[
_most{_ml=0;_mr=0;_mm=0;_mlh=0;_mrh=0;_mmh=0;}
_mobtn{{_ml _mlt _mlu _mlh _mld}{_mr _mrt _mru _mrh _mrd}{_mm _mmt _mmu _mmh _mmd}}
_moky{_mx _my _mdx _mdy _mw _msx _msy _mvx _mvy _mv _amb _mvw}
_mo{}
]])

function getmouse()
local _mb=stat'34'
tmap(_mobtn,function(k,i)
local k,t,u,h,db=unpack(k)
local s=_mb&0x.8<<i>0
i=s and _most[k]+1 or 0
_mo[k]=s
_mo[u]=not s and _most[k]>0
_most[k]=i
_mo[h]=i
s,i=i==1,_most[h]
_mo[t]=s
_mo[db]=s and i>0
_most[h]=max(s and 20,i-1)
end)
_mx,_my=stat'32',stat'33'

cat(_ENV,cat(_mo,comb(_moky,
{_mx,_my
,stat'38'/6,stat'39'/6
,stat'36'
,_amb and _mx or _msx
,_amb and _my or _msy
,_mx~=_mo._mx
,_my~=_mo._my
,_mvx or _mvy
,_mlt or _mrt or _mmt
,_mw~=stat'36'
})))
_amb=_mlt or _mrt or _mmt
--as rect
	_mo.x,_mo.y=_mx,_my
	_mo.ex,_mo.ey=_mx,_my
end
-->8
function _init()
cat(_ENV,htbl(stat(6)))
cartdata('kitchenmatchen3_a5')
blocks={peek(0x2fa0,16)}
blids={peek(0x2f20,16)}
usc=mkscenes'ms bu in gm wk'
dsc=mkscenes'bg bd be si so lm ed ch eu tx cu'

ef,eb=unpack(mkscenes'ef eb')
setmode(mindex[mode])

dload()
convertdat()
cn,dat.cartno=dat.cartno,1
useitem=tbfill(0,1,8)
if cn==0 then
cn=initdat()
end
dsave()
srand(dat.seed)
if cn>1 and mode then
	scmd([[
		ef ps e_fout 1
	]],htbl[[pl{0 0}]]
	,'eu st d_et 0',ef
	,'ed st d_et 0',eb
	)
	music(0)
	if isl then
		scmd([[
			bg ps d_rslt 0
			bd ps d_wpin 120
		]])
	else
		returnmenu()
		
		if isr then
		return
		end
	end
	
	score=replace(score or '','$','')
	local h=dat[modehi[mode]]
	if h then
		if strdcomp(score,h) then
		dat[modehi[mode]]=score
		end
	end
	
	dat.totalscore=strdsum(dat.totalscore,score)
	dat.maxcombo=max(dat.maxcombo,maxcombo)
	dat.totalmatch=strdsum(dat.totalmatch,matches)
	dat.totalblock=strdsum(dat.totalblock,mblocks)
	dat.techblocks=strdsum(dat.techblocks,techblocks)
	dat.adstock=max(dat.adstock-adbrush)
	dat.adticnt=max(dat.adticnt-purify)
	if recino then
		dat.recinew=recino|0
		if dat.recifirst==0 then
		dat.recifirst=recino|0
		end
		if dat.recifirst==recino|0 then
		dat.luckcount=mid(dat.luckcount+maxigrd,2,max(maxigrd*8,2))
			if maxigrd>0 then
			dat.noticeb[1]=0
			end
		end
		--recilearn
		dat.recilearnb[recino%256+1]=1
	end
	if isl then
		local p={bunpack(dat.items,12,unpack(tbfill(4,1,8)))}
		tmap(ingst,function(v)
			local i,v=unpack(v)
			p[i]=0x8|mid(p[i]%8+v\4,7) --max 7
		end)
		dat.items=bpack({4},12,unpack(p))
	end

	dsave()
	dload()
	convertdat()
	setmode()
else --start
logo()
end
end

function logo()
music(-1,1000)
scmd([[
bg st d_logo 60
]],htbl'64 0.1'
,[[
bg ps d_logo 60
]],htbl'0 0'
,[[
bg ps d_logo 30
bg ps nil 80
bg ps start 1
cu cl
wk st e_fout 1
ef cl
eu cl
]],htbl'0 96 pl{4.9 0}'
)
end

function start()
music(0)
scmd([[
bg st d_title 3600
bg ps logo 1
wk st e_fout 60
wk ps nil 3420
ef ps e_title 80
cu st nil 1
cu ps d_cu 0
ms st nil 1
ms ps u_title 0
]],htbl[[pl{4.9 0}]]
,[[
wk ps e_fout 60
]],htbl[[pl{0 4.9}]]
,'eu st d_et 0',ef
,'ed st d_et 0',eb

)
end

function _update60()
	pwm()
	poke(0x5f2d,0x1)
	poke(0x5f58,0x81)
	getmouse()
	foreach(usc,transition)
end

function _draw()
	foreach(dsc,transition)
local x,y=camera()
dbg'd?'	
camera(x,y)
end


-->8
function mload()
local items=''
hane=dat.noticeb[9]==1 and 'hane=1;' or ''
bnbn=dat.noticeb[10]==1 and 'bnbn=1;' or ''
incshikomi='spinc='..(dat.noticeb[11]+dat.noticeb[12])..';' or ''
if ist then
tmap(useitem,function(v,i)
purify+=v\3
dat.adstock+=msplit'3 9'[v] or 0
v=itemprm[i][v]
tmap(ttable(v) or {v},function(v,c)
items=join('',items,itemprm[i][4][c],'=',replace(v..'','*s','{0 1 2}'),';')
end)
end)

dat.items=bpack({4},12,unpack(tmap(dat.itemnum,function(v,i)
	return v-useitem[i] or 0 --v>use
end)))
for i=1,4 do
if dat.noticeb[8]==1 and strdcomp(dat.totalscore,(i*4-3)..'000000000000') then
adlvl=i
end
end

elseif isl then
items=join('',spshikomi and 'maxblid=6;' or '',incshikomi)
end
dat.cartno=1
if not isr then
dat[modepc[mode]]+=1
end
dsave()

srand(dat.seed|(dat.playno>>>8)|(dat.weeks>>>16))
memcpy(0xc000,0x0000,0x2000)
load(cart..mcdex[mode],nil,join('',replace(
'mode=😐;seed=★;adstock=█;adlvl=▥;adtx=▤;purify=▒;⧗ bkmbl{◆} ⬇️ ♪ ♥ cart=⌂;'
,'😐',mkey[mode]
,'★',rnd()
,'█',dat.adstock
,'▥',adlvl
,'▤',adtx
,'▒',purify
,'⧗',items
,'⬇️',sesbl
	 and replace('sesbl{✕}shfbl{●}'
	,'✕',join(' ',unpack(sesbl))
	,'●',join(' ',unpack(shfbl))
	)
,'◆',join(' ',unpack(bkmbl))
,'♪',count(useitem,0)<8 and 'muid=20;' or ''
,'♥',isaga and 'agab=2;'
,'⌂',cart
),hane,bnbn))
end

function menusel()
local c,p=unpack(htbl'{2 puzl}{3 reci}{1 give}{1 data}'[_prm.m])
if mode then
mload()
elseif c==1 then
gonote(_prm)
elseif c==2 then
if maxigrd==0 then
setmode(1)
gonote(_prm)
scmd[[
bg st d_menu 0
]]
return
end

_prm.fi='40 0'
_prm.py={-32,0}
scmd([[
cu st d_cu 0
ms st u_puzl 8
ms ps u_puzl 0
tx ps d_guidet 0
gm rm mload
si st nil 1
si ps d_items 20
in st u_items 0
]],_prm
,[[
bg ps d_puzl 0
si ps d_items 0
]])
elseif c==3 then
gonote(_prm)
elseif c==4 then
gonote(_prm)
end
end

function u_notice()

if not notict then
nval=htbl[[
{luckcount 3 1}
{weeks 0 2}
{weeks 212 3}
{playno 2 4}
{recilearn 10 5}
{recilearn 20 6}
{recilearn 30 6}
{recilearn 42 7}
{techblocks 50 8}
{techblocks 120 9}
{techblocks 300 10}
{techblocks 900 10}
{maxcombo 70 11}
{maxcombo 100 11}
]]

for i,v in pairs(nval) do
 local d,v,k=unpack(v)
 if strdcomp(dat[d]..'',(v or dat[d])..'') then
 if dat.noticeb[i]==0 then
	notict,bnotict=notice[k]
	dat.noticeb[i]=1
	scmd[[
	si st d_notice 30
	si ps d_notice 0
	]]
	sfx(51,1,0,16)
	break
 end
 end
end
end
return not notict
end

function u_oiwai()
if _mlt then
scmd([[
wk ps e_fout 180
wk ps run 1
]],htbl[[pl{0 4.9}]]
)
music(-1,3000)
end
end

function u_data()
if _ml or _mr then
local x,y=dragdelta()
if abs(y)>0 then
	sfx(49,3,1,3)
end
local cy=chisr.h-127
if not _amb and not cutpr then
camy=mid(camy-y,0,cy)
elseif _mlt then
	if delcut and cutsr.con(_mo) then
	cutpr=exrect({cutr.ex,cutr.y,1,1})
	elseif clbr.con(_mo) then
	delcut=alignmenu()
	scisr.ud(112)
	spatr.ud(256)
	delcut,cutpr=nil
	clicksfx(false)
	scmd([[
	bg st d_scr 24
	bg ps d_menu 0
	cu us nil 4
	ms st nil 24
	ms ps u_cu 0
	tx st nil 24 
	tx ps d_guidet 0 
	]],htbl[[f=drawmenu;camx{128 0}]])
	elseif iskan and fudar.con(_mo) then
	scmd([[
	ms st u_oiwai 0
	bg st d_oiwai 0
	bd st d_scr 420
	]],htbl([[f=t;camy{! ?}]],'!',camy,'?',owar.y)
	,[[bd ps d_scr 240]]
	,htbl([[f=t;camy{! !}spr=0;]],'!',owar.y)
	,[[bd ps d_scr 1512]]
	,htbl([[f=t;camy{! ?}spr=0;]],'!',owar.y,'?',756)
	)
	music(48,2000)
	elseif scisr.con(_mo) then
	scmd[[
	cu st d_scis 0
	]]
	scisr.ud(256)
	spatr.ud(112)
	delcut=true
	sfx(51,1,24,8)

	elseif spatr.con(_mo) then
	scmd[[
	cu st d_cu 0
	]]
	scisr.ud(112)
	spatr.ud(256)
	delcut,cutpr=nil
	clicksfx(1)
	end
end
end

if _ml and cutpr and cuter.con(_mo) then
local x=min(_mx,cutr.ex)
cutpr.ud(x,nil,cutr.ex-x+1)
if _mlt then
sfx(51,3,26)
end

if cutpr.w>100 then
sfx(50)
sfx(-1,1)
cls()
poke(0x5f55,0x80)
cls()
drawdata(1)
poke(0x5f55,0x60)

initdat()

dsave()
dload()
convertdat()
	scmd[[
	cu st d_cu 0
	]]
	scisr.ud(112)
	spatr.ud(256)
	delcut,cutpr=nil
	
scmd[[
ms us nil 64
cu us nil 64
ed st d_cut 64
]]
end
elseif cutpr then
sfx(-1,1)
cutpr=nil
end

camera(camx,camy)
end

function u_items()
local i=inrect(irects)
local d=inrect(drects)
if _mlt then
if i then
clicksfx(1)
useitem[i]+=
mid(
 min(
	 min(
		 dat.itemnum[i]%8--7
		 ,maxigrd--1
	 )-useitem[i]--1
	 ,leftisum()
	)
 ,1
) --1
elseif d then
useitem[d]-=min(useitem[d],1)
end
end
end

function u_puzl()

local f,t=unpack(_prm.py or {0,0})
if _dur>0 then
puzcam={0,_rate({f,t} or {t,f})/1}
else
if _mlt and not _prm.e then
	local p
	tmap(msplit'coor prer',function(v,i)
		if rects[v].con(_mo) then
		 p=i
		end
	end)
	clicksfx(p)
	if p then
	setmode(p)

	_prm.p=p
	gonote(_prm)

	elseif inrng(_my,40,88) then
	alignmenu()
	clicksfx(false)
	_prm.fi='0 40'
	_prm.py={0,-32}
	scmd([[
	si st d_items 20
	in st u_puzl 8
	bd st d_puzl 8
	]],_prm)
	end
end
end
end

function u_title()
if _amb then
clicksfx(1)
scmd([[
ms st nil 80
ms ps returnmenu 1
ef ps e_clx 50
ef ps e_fout 1
wk cl
]],htbl[[pl{0 0}]])
end
end

function u_menu()
if _fst then
_prm.c=clone(menucam)
end

tmap(menucam,function(v,i)
v=_prm.c[i]
local r=rects[msplit'menu1 menu2 menu3 menu4'[i]]
if _prm.m then
	i=_prm.m==0 and r
		or	_prm.m==i and centr
	 or rects[msplit'meno1 meno2 meno3 meno4'[i]]
	if _prm.s then
		i.y=rects[_prm.s[m]].y
	end
	return {_rate({v[1],r.x-i.x+0.5})/1,_rate({v[2],r.y-i.y+0.5})/1}
end
end)
end

function u_cu()
local m
if _mlt and _dur==0 then
mode=nil
tmap(msplit'menu1 menu2 menu3 menu4',function(v,i)
	if rects[v].con(_mo) and i~=3 then
		m=i
	end
end)
if m==iskan then
	sfx(59,1)
	return
elseif m then
	clicksfx(1)
	_prm={m=m}
	scmd([[
		ms cl
		tx cl
		cu st d_cu 40
		bg st d_menu 24
		gm st u_menu 24
	]],{m=m,'conf'}
	,[[
		gm ps u_menu 24
		bg ps d_menu 24
	]],{m=m}
	,[[
		gm ps menusel 1
	]],{m=m}
	)
else
	clicksfx()
end
end
end

function u_rsbl()
if _fst then
_prm=deli(ingst,1) or {false,0}
_prm[3]=0

scmd([[
	bd ps nil 32
	bd ps d_rsbl 16
	in st nil 96
	in ps u_inum 0
]],{_prm,'56 -32'}
,[[
	bd ps d_rsbl 0
]],{_prm}
)
end
end

function u_inum()
local _prm=_prm[1]
if _cnt%8==0 then
if _prm[2]==0 then
scmd(replace([[
	so st nil 96
	si st d_stock 96
	bd cl
	be ps d_rsbl 96
	bu st nil 64
	*
]],'*',ingst[1] and 
[[
	bu ps u_rsbl 0
]] or
[[
	bu ps returnmenu 1
]]),{{unpack(_prm)}}
,[[
	be ps d_rsbl 16
	so ps d_stock 16
]],{_prm,'-32 -128'}
)
return 1
end
local s=_prm[3]%4
sfx(56,1,8*s,8)

_prm[2]=max(_prm[2]-1,0)
_prm[3]=min(_prm[3]+1,16)
if _prm[3]%4==0 then
scmd(
[[
eb ps e_stock 32
]],{{unpack(_prm)}}
)
sfx(57,3)
return
end
end
end
-->8
function d_logo()
cls()
local r=_rate(_prm)+sin(_rate'0.5 0')*_prm[1]
local c=_rate('0 '.._prm[2])
tmap(msplit'0xf2 0xf1 0xf4',function(v,i)
?'\^!5f5e'..chr(v)
poke(0x5f17,12)
bitpal(4,15,36,cos(i/3+c)*r+36,sin(i/3+c)*r+58,7,2)
end)
?'\^!5f5e?'
return _amb and scmd[[
bg st start 1
]]
end

function d_rslt()
if _fst then
memcpy(0x1000,0xd000,0x1000)
memset(0xa000,0x77,0x2000)
_prm=clone(ingst)
end
memcpy(0x6000,0x8000,0x2000)
tmap(respos,function(p,i)
local x,y=camera(unpack(p))
local v=_prm[i]
if v then
spr(190+v[1]*2,0,0,2,2)
oprint('⁙'..sub('0'..(v[2] or ''),-2),-1,17,9,4)
end
camera(x,y)
end)
end

function d_rsbl()
local p,n,l=unpack(_prm[1])
local s=_dur>0
camera(-24, _rate(_prm[2] or '-32 -32'))
map(16,3,0,0,10,8,2)

if p then
pal(tbfill(2,0,16))
pal(13,10)
spr(190+p*2,22,8,2,2)
?'⁙'..sub('00'..n,-2),38,14,13
pal(0)
l=l or 0
rceach('0 0 4 4',function(x,y)
oprint('•',x*16+14,42-y*6,l>x*4+y and (y<3 and 10 or 7) or 2,y<3 and 10 or 5,'5a')
end)

else
jprint('??? ??',20,25,10,2)
end
camera()
end

function e_stock()
local x=_prm[1][3]\4*16+16
fillp(cat({peek2(0x2740,8)},{peek2(0x27c0,8)})[mid(_cnt-16,1,17)]|0x.8)
local r=_cnt%16
oval(x+7-r,59-r,x+8+r,60+r,0x7)
fillp()
end

function d_stock()
local pn,s=unpack(_prm)
camera(-16,_rate(s or '-32 -32')-25)
local nn=_dur>0
for i=1,4 do
if i<=pn[3]\4 then
local x,y=i*16,min(s and 0 or _rate('-63 256')-i*24)
drawfook(pn[1]+16,x,y)
end
end
camera()
end

function d_wpin()
poke(0x5f55,0xa0)
for i=0,3 do
rrectfill(cos(_rate'3 0'-i*0.016)*-128+64,_rate'5 -1'\1*24+sin(_rate'0 6')*12,16,48,6,0)
end
poke(0x5f54,0xa0,0x60)
spr(0,0,0,16,16)
poke(0x5f54,0x00)
if _lst then
scmd([[
	bu ps u_rsbl 0
]])
end
end

function d_scr()
if _fst then
getmouse()
memcpy(0x8000,0x6000,0x2000)
end
camx=_rate(_prm.camx or '0 0')
camy=_rate(_prm.camy or '0 0')
camera(camx,camy)
if not _prm.spr then
switchscr(_prm.camx and _prm.camx[1] or 0,_prm.camy and _prm.camy[1] or 0)
end
_ENV[_prm.f]()
end

function d_guidet()
camera(camx,camy)
_mtext=_mtext or guidt[moii]
if not _mtext and shunt then
shunt()
else
jprint((_mtext or ''),16,119,5,7)
end

for x=0,-113,-113 do
camera(x,-114)
?"\+lk+",0,0,9
bitpal(msplit('1 1 1 1 1 1 1 1 2 3 3 3 3 3 3 3 3 4')[_cnt\8%18+1]|0,1,6,0,0,2,2)
end
camera()
_mtext=nil
shunt=nil
end

function d_cut()
poke(0x5f54,0x80)
spr(0,_rate'0 -10'*_rate'-12 12',sin(_rate'0 -0.25')*64,16,16)
poke(0x5f54,0x00)
end

function d_notice()

--if notict then
camera(0,bnotict and _rate'0 -128' or _rate'128 0')
exrect'17 19 96 64'.rs'5'
map(34,4,16,18,12,8)
exrect'18 19 92 62'.rs'11'
local s,t,b,p=unpack(notict or bnotict)
if tonum(s) then
bitpal(s<32 and 1,s<32 and 3,s,22,21,2,2)
else
jprint(s,22,21,14,7)
end
jprint(t,40,26,11,7)
jprint('yc'..b,24,42,5,7)
p=p or ''
jprint(p,66-#replace(p,'゛','','゜','')*7/2,66,8,6,'40')
--end
camera()
if _mlt and _dur==0 then
	scmd[[
	si st d_notice 20
	ms us nil 20
	]]
	bnotict,notict=notict
end
end

function d_oiwai()
cls(7)
tmap({owar,crr},function(v)
rect(v.x,v.y+1,v.ex+1,v.ey+1,6)
v.rf(v.p[5])
end)

local cx,cy=camx-owar.x,camy-owar.y
camera(cx,cy)
jprint(join(oiwai,'d','g5y5','gey4','g5y3','gdy2',''),29,26,13,7,'00')
	tmap(htbl([[
{34 45 5}
{6 13 7}
{6 27 5}
{6 64 5}
{6 78 7}
]]),function(v,i)
local s,x,y=unpack(v)
?"\+lk+",x,y,9
	bitpal(min(i-1,1),14,s,x,y,2,2)
	end)
dkarakusa(exrect'5 25 81 25',3)
dkarakusa(exrect'5 73 81 25',3)
d_label(5,24,128)
 camera(cx+4,cy)
tmap(cret,function(v,i)
tmap(v,function(v,j)
sticpad(v,10+i*2+j,j>1 and 3,6)
end)
end)
camera(camx,camy)
drawdata()

end

function d_data()
cls(7)
drawdata()
pal(clsp[1])
spr(102,112,0,2,2)
pal(0)
end

function d_items()

local y=_rate(_prm.fi or '0 0')
if count(dat.itemnum,0)<8 then
--items
camera(camx,camy+y)
map(16,11,0,0,16,5,2)
pal(2,0)
map(16,11,16,0,16,5,2)
_prm.item=nil
local ic=inrect(irects)
local dc=inrect(drects)
tmap(dat.itemnum,function(v,i)
if v>0 then
	local u=useitem[i]>0 and useitem[i]
	local x=i*16-16
	?v%8-useitem[i],x+5,1,i%2==0 and 15 or 10
	local c,f,d=_cnt%15<6
	
	if i==ic or i==dc then
	local mtext=itemt[i]
	_prm.item=mtext[1]
	_mtext=mtext[2]
	f=c and ic
	d=c and dc
	end
	
	pal(13,f and 5 or 13)
	if u then
	oprint('⁙',x+6,8,7,d and 14 or 8,'ff')
	local kom=kompei[maxigrd or 1][u] or ''
	oprint(kom,x+2,15,7,7,'5a')
	else
	oprint('•',x+6,10,7,5,'5a')
	end
	
	if v%8>0 then
	drawfook(16+i,x,u and 14 or 11,f and 14,u and -1)
	else
	pal(tbfill(i%2*2,0,16))
	pal(13,f and 1 or 10)
	spr(190+i*2+32,x,18,2,2)
	pal(0)
	end
end
end)
pal(0)
if y==0 then
	if moii==5 then
	drawcurve(28,42,-11,52)
	jprint('???',10,64,8,7)
	elseif moii==6 then
	drawcurve(102,42,11,-52)
	jprint('???',100,64,8,7)
	end
	if _cnt%60>4 then
	oprint("\^x8\^y8\^.\0\0\0█`088\n\^.|???????\*3\^.\b<??????\^.\0「゜゜??○?\n\^.?????「\0\0\*3\^.?????<▮\0\^.○??゜゜「\0\0",0,32,1,4,'40')
	jprint('??'..sub('0'..leftisum(),-2)..'?',4,44,10,1)
	end
	local w=dat.weeks%4+4
	?jprint(sub('%%%%$$$',-w,3-w),96,44,14,7,'00')
end
end
end

upbl={}
enbl={}
function e_blup()
upbl[_prm]=min(sin(_rate'0.5 1')*16,8)
if _fst then
add(enbl,_prm)
end
if _lst then
del(enbl,_prm)
end
end

function e_clx()
clx=sin(_cnt*0.5+0.25)*_rate'0 128'
end

function e_fout()
	if _prm.pl then
		poke(0x5f10,peek(0x2840+_rate(_prm.pl)\1*128,16))
	end
end

function e_title()
titley=(_rate{(_dur-_cnt)*_rate'24 0',48})%96-48
end

function d_title()
cls(7)
local c=4
local r=join('',unpack(tbfill("\^.?||>>゜゜\0 ",1,20)))
rrectfill(0,24,128,56,0,2)
if _cnt%60==59 then
local v=rnd(32)\1+1
if count(enbl,v)==0 then
scmd([[
ef ps e_blup 180
]],v)
end
end

tmap(cat({},blocks,blocks),function(v,i)
local x=_cnt/4%256
spr(v,x+i*16-272,16+(upbl[i%16+1] or 0),2,2)
spr(v,-x+i*16-144,64-(upbl[i%16+17] or 0),2,2)
end)
for i=0,1 do
camera(3+i,i-1)
for y in all(msplit'16 72') do
rrectfill(0,y,256,7,0,c or 15)
?r,-8,y,c or 14
end
jprint('????\-iDE\-i??゛??!',30+clx,88,9,c or 2)
bitpal(4,c or 12,36,40,112,7,2)
c=nil
end
?'>h 2026',52,106,12

clip(0,24,128,48)
rceach('-1 -1 3 3',function(x,y)
d_label(5,x+40,18+y+titley)
end)
d_label(7,nil,18+titley)
clip()
?ver,1,122,6
camera()
end

function d_label(p,x,y)
for i=1,3 do
	bitpal(i,p,36,(x or 40)+i\3*16,i*12+(y or 10),7-i\3*4,2)
end
end

function d_book()
if _fst then
camera()
	poke(0x5f55,0xa0)
	cls()
	map(0,16,0,0,16,16)
	d_label(2)
	if isaga then
	exrect'52 75 31 13'.rf(8,1)
	jprint('??゛?',58,79,7,8)
	else
	exrect'52 75 14 12'.rf(8,1)
	?'\^x6'..season[dat.month],53,77,7
	?'?`',68,78,8
	end
	jprint(unpack(memoprm[mode] or msplit' 0 0 0 0'))
	for i=1,dat.years do
	spr(34,106,i*16,2,2)
	end
	--notes
	poke(0x5f55,0x80)
	cls(7)
	map(16,16,0,0,16,16)
	if isl then
	exrect'34 32 60 6'.rf(4)
	.ud'32 32 64 6'.rs(4)
	.ud'32 32 64 72'.rs(4)
	jprint('😐♪??▤???-?',29,21,4,9,'c0')
	else
	jprint('[]????-',41,21,4,9,'c0')
	exrect'32 30 64 36'.rf(7)
	.ud'34 32 60 12'.rf(5)
	.ud'20 66 88 14'.rf(4)
	.ud'18 66 92 14'.rs(4)
	.ud'18 66 92 47'.rs(4)
	photor.rf(14)
	?"\^x8\^y8\f1\*2\^.\0?????\0\0\^.\0??\*2\^.\0\0\0\0\0\0??\^.\0?????\^.\0?????\0\0\^.\0\0\0\n \^.\0\0\0\0██??\^.????????\*2\^.????????\^.゜゜??\n\^.????\0\0\0\0\^.゜゜\0\0\0\0   \^.██\0\0\0\0\0\0\^.????\0\0\0\0\^.\0\0\0\0\n",34,44
	if ist then
		jprint('?????゛????',33,84,4,9,'00')
	end
	end	
	camera()
	tmap(htbl([[
{41 16 ! 2 2 false false}
{41 16 ? 2 2 false true}
{41 96 ! 2 2 true false}
{41 96 ? 2 2 true true}
]],'!',isl and '40' or '24','?',isl and '80' or '48'),function(v)
	bitpal(3,4,unpack(v))
	end)
	poke(0x5f55,0x60)
end

camera(camx,camy-128-8)
	if _prm.bk then
		switchscr(0,2,0x80)
		switchscr(-6,0,0xa0)
	else
		whitr.rf(7)
		map(0,16,0,0,16,16)
	end
	camera(camx,camy)
end

function d_puzl()
cls(7)
camera(camx,camy)
drawmenu()
moii=nil
jprint(_prm.item or '?゛??????',42,87
,_prm.item and 3 or 9
,_prm.item and 11 or 10)
tmap(msplit'puz1 puz2',function(v,i)
	v=rects[v]
	local cx,cy=unpack(puzcam)
	camera(camx-v.x+cx,camy-v.y+cy)
	tmap(msplit'puzd puzm puzu',function(r)
	r=rects[r]
	r.rf(r.p[5],r.p[6])
	end)
	local x,y=camera()
	local r=not _prm.p and v.con(_mo)
	camera(x,y)
	moii=moii or r and i+4
	bitpal(i,(r or _prm.p==i and (_prm.e or _cnt%8<3)) and 2 or 9,8,5,0,4,2)
end)

camera(camx,camy)
if spshikomi then
local nm=_cnt%40<20 and '\^x8✕\|f●\|h' or '\^x8\|f✕\|h●'
oprint(replace(nm,'✕',spshikomi[1],'●',spshikomi[2]),106,91,7,14)
end
shunt=function()
	jprint('¥?⬇️✕',16,119,7,14)
	local b=0
	for i=1,bkmbl[1] and useitem[7] or 0 do
	oprint('+',77,117,7,2)
	spr(104,66+i*16,113,2,2)
	b=2
	end
	tmap(sesbl or {0,0},function(v,i)
	spr(blocks[v+0] or 104,29+i*16,113,2,2)
	end)
end
end

function d_menu()
cls(7)
if _fst then
scmd([[ef ps e_fout 1]],htbl[[pl{0 0}]])
end
drawmenu()
end

function d_scis()
pal(0)
if cutpr then
cutpr.rf(0)
else
fillp(0x3333.3333<<>(_cnt\6)|0x.8)
cutr.rf(msplit'8 9 14 15'[mid((sin(t())*4+0.5)\1,1,5)])
fillp()
end
local b,x,y=_mlh\6%2*2,camera()

bitpal(b+2,13,4,_mx,_my,2,2)
bitpal(b+1,8,4,_mx,_my,2,2)
camera(x,y)
end

function d_cu()
pal(2,8)
local a=msplit'1 2 3 4 3 3 3 4 4 4 3 3 3 4 4 4'
local i=a[_rate({1,#a},32,_mlh)\1]\1
if _mlt then
end
x,y=camera()
bitpal(i,2,0,_mx-i\3,_my-i\3+1,2,2)
bitpal(i,4,0,_mx-i\3,_my-i\3,2,2)
camera(x,y)
end


-->8
function inrect(rs)
for i,v in pairs(rs) do
if v.con(_mo) then
return i,v
end
end
end

function setmode(m)
mode=m --time left reci
isl=mode==2
ist=mode==1
isr=mode==3
end

function leftisum()
local c=0
tmap(useitem,function(v,i)
c+=v
end)
return min(maxinum-c,maxigrd*8)
end

function drawcurve(x,y,w,h)
local c=_cnt\2
for i=0,5 do
?'\+fd•',x+(abs(sin(c/120-i/12))*w)/1,y+((-i*h/6+c*h/60)%h),8
end
end

function dkarakusa(r,c)
tmap(htbl('{x y 2 2}{! y 2 2 true}{x ? 2 2 false true}{! ? 2 2 true true}'
,'x',r.x,'!',r.ex
,'y',r.y,'?',r.ey),function(v)
bitpal(3,c,41,unpack(v))
end)
end

function drawfook(p,x,y,c,f)
for i=0,1 do
spr(f or 80,x,y-i,2,3)
if i==0 then
spr(190+p*2,x,y+7,2,2)
end
pal(13,c or 8)
palt(15,true)
end
pal(0)
end

function d_et()
transitionp(_prm)
end

function alignmenu()
scmd([[
gm st u_menu 24
bg st d_menu 24
]],{m=0}
,[[
gm ps u_menu 0
bg ps d_menu 0
cu st d_cu 0
ms st d_cu 24
ms ps u_cu 0
tx st d_guidet 0
]])
end

function switchscr(x,y,t)
poke(0x5f54,t or 0x80)
spr(0,x,y,16,16)
poke(0x5f54,0x00)
end

function gonote(p)
--p.m:menu
if p.m==1 then
music(-1,400)
_prm.py=nil
scmd([[
	ms cl
	tx cl
	cu st d_cu 40
	bg st d_puzl 24
	ms st u_puzl 24
	bd st nil 48
	be st nil 48
]],p
,[[
	bg ps d_puzl 48
	ms ps u_puzl 48
]],cat(htbl[[e=1;]],p)
,[[
in cl
bd ps d_scr 24
be ps d_book 0
]],htbl[[bk{} camy{0 130} f=t; spr=1;]]
,[[
	bd ps mload 1
]],p
)
elseif p.m==2 then
music(-1,400)
scmd([[
bg st d_menu 24
cu cl d_cu 24
bd st d_scr 24
be st d_book 0
]],htbl[[bk{} camy{0 138} f=t; spr=1;]]
,[[
	bd ps mload 1
]],p
)
setmode(3)
elseif p.m==3 then
alignmenu()
elseif p.m==4 then

scmd([[
cu st d_cu 24
ms st u_data 24
bg st d_scr 24
cu ps d_cu 0
ms ps u_data 0
bg ps d_data 0
tx cl
]],htbl[[f=drawdata;camx{-128 0}]])
menucam=htbl[[{0 0}{0 0}{0 0}{0 0}]]
end
end

function returnmenu()
scmd([[
bg st d_scr 24
bg ps d_menu 0
cu st d_cu 0
cu us nil 4
ms st nil 24
ms ps u_notice 0
ms ps u_cu 0
tx st nil 24 
tx ps d_guidet 0
si cl
so cl
be cl
]],htbl[[f=drawmenu;camy{128 0}]])
end

function drawmenu()
rectfill(0,0,127,127,7)

map(16,0,0,0,16,16,1)
moii=nil
tmap(msplit'menu1 menu2 menu3 menu4',function(v,i)
if i~=3 then
v=rects[v]
local cx,cy=unpack(menucam[i])
camera(camx-v.x+cx,camy-v.y+cy)
tmap(msplit'mend menm menu',function(r)
r=rects[r]
r.rf(r.p[5],r.p[6])
?'\^x8\+ia•   •',4,5,2
line(8,2,21.5,-5,9)
line(26,-5)
line(39,2)
end)
	local x,y=camera()
	local r=v.con(_mo)
	camera(x,y)
	moii=moii or r and (iskan and i==1 and 0 or i) 

	tmap(msplit('12,9,4,5,2 43,4,20,5,2',' ',','),function(v)
	bitpal(i,_prm.m==i and (((_prm[1]=='conf'
				and _cnt%8<3) or not _prm[1]) and 2 or 9)
			or r
			and 2 or 9
	,unpack(v))
	end)
end
end)
camera(camx,camy)
end

function sticpad(s,l,m,p)
p=p or 1
s=tostr(s)
local n=tonum(s)
l=l*12+32
if m then
local w=#s*6+(#s-1)\3*2+1
w=n and w or #s*6+1
local x=max(99-w,6)
local t,i='',1
if n then
	while s[-i] do
	t=(i%3==0 and i<#s and '\+fh,\+df' or '')..s[-i]..t
	i+=1
	end
	else
	t=s
end

local c=sticp[m]
if c then
?('?? ')[m],11,l+3,p
rectfill(x-1,l+1,98-min(98-w-6),l+11,c[2])
x,y=?'\^x6'..t..'\f'..tohex(c[1],1)..'\+fj▶',x,l+3,2
sticr.ud(x-5,l+1).rf(c[2])
end
else
local w=#s*7
local x=99-w

?s,x,l+3,p
rect(chifr.x,l,chifr.ex,l)
fillp(s[1]=='/' and 0xffff.8 or 0x6666.8)
rect(chifr.x,l+12,chifr.ex,l+12)
fillp()
end
return x,l
end

function drawdata(tl)
if not tl then
for i=0,895,64 do
map(32,min(8,i),0,i,16,8,1)
end
chisr.rf(14).rs(6)
?"\^x46\+cf-e\+bf-",chisr.ex,chisr.ey
rrect(4,9,106,15,0,14)
rrectfill(1,8,110,15,3,15)
?"\f6\^.@█▤?????\n\^.?????▤██\n\^g\fe\^.8|fbcaaa\n\^.aaacbf|x",104,8
end

chitr.rf(15)
if tl then
chitr.rs(1)
end

dtitr.rf(1,2)
?"???\-⬇️\^x6N□."..sub('00'..dat.playno,-3),14,30,15
numr.rf(15)

chifr.rs(1)
local p,s,f=msplit'6 6 13 8',msplit'6 6 6 4',msplit'6 6 6 4'
for i=(spatr.con(_mo) or scisr.con(_mo)) and 1 or 3,4,1 do
local j=i%2+1
bitpal(j,p[i],2,scisr.x-i\3+2,scisr.y,2,2)
bitpal(1,s[i],0,spatr.x-i\3+2,spatr.y,2,2)
end
if iskan then
fudar.rs(fudar.con(_mo) and 6 or 7)
spr(32,fudar.x,fudar.y,2,2)
end

pal(12,14,1)
local i,x,y=1
tmap(datat,function(v)
tmap(v,function(v,t)
t,v=unpack(v)
sticpad(v and dat[t] or t,i,v)
i+=1
end)
end)

x,y=sticpad('',i,false,1,1)
if adtx[1] then
?'rqx6yc/'..adtx,dtitr.x+3,y+15,14
end
end

function clicksfx(b)
if b==false then
	sfx(52,1,0,16)
elseif b then
	sfx(48,1,0,16)
	sfx(49,3,16,16)
else
	sfx(48,2,8,8)
	sfx(49,3,24,8)
end
end

function bitpal(i,c,...)
pal(ecpalt(tmap(cat({},bitp[i]),function(v,i)
	return v*c
end)))
spr(...)
pal(0)
end

function strdsum(a,b)
a,b=tostr(a),tostr(b)
local s,l,d='',max(#a,#b),''
for i=1,l do
local v=(a[-i] or 0)
+(b[-i] or 0)+#d
d=v>9 and '1' or '' 
s=v%10 ..s
end
return d..s
end

function strdcomp(a,b)
	if #a~=#b then
	return #a>#b
	end
	for i=1,#a do
		local c,d=tonum(a[i]),tonum(b[i])
		if c~=d then
			return c>=d and a
		end
	end
	return a
end

function dragdelta()
local p={_mx,_my}
_drags,x,y=p,unpack(_drags or p)
return _mx-x,_my-y
end

jcache={}
function jprint(t,...)
jcache[t]=jcache[t] or jreplace(tostr(t))

oprint(jcache[t],...)
if #{...}==6 then
?jcache[t],...
end
end

function jreplace(t)
return replace(t
 ,'゛','cd゛dj'
 ,'゜','cc゜dk'
)
end
-->8
function mapt(p)
local s=''
local x,y,w,h=unpack(msplit(p))
for i=0,h-1 do
s..=chr(peek(0x2000+x+y*128+i*128,16))
end
return s
end

function dsave()
tmap(data,function(v,i)
	local d=dat[i]
	pokecd(d,unpack(v))
end)
local d={}
for i=1,256,8 do
add(d,bpack({1},7,unpack(dat.recilearnb or {},i,i+7)))
end
poke(0x5e00,unpack(d))
poke4(0x5e88,bpack({1},15,unpack(dat.noticeb or {})))
end

function dload()
dat=tmap(clone(data),function(v,i)
return peekcd(unpack(v))
end)
dat.recilearnb=cat(unpack(tmap({peek(0x5e00,32)},function(v)
 return {bunpack(v,unpack(msplit'7 1 1 1 1 1 1 1 1'))}
end)))
dat.noticeb={bunpack(dat.notice,15,unpack(tbfill(1,1,32)))}
end

function peekcd(a,l,...)
local f={
peek
,peek2
,{}
,peek4
,function(...)
local d,i='',1
f={peek(...)}
tmap(f,function(v)
d=sub('0'..v,-2)..d
end)
while d[i]=='0' do
i+=1
end
d=sub(d,i,#d)
return d[1] and d or '0'
end
}
if ... then
return tmap({l,...},function(v,i)
return peekcd(a+i*v-v,v)
end)
end
return (f[l] or f[5])(a,l)
end

function pokecd(d,a,l,...)
local f={
poke
,poke2
,{}
,poke4
,function(a,d)
local i,p=1,{}
d=tostr(d or 0)
while d[-i] do
add(p,tonum(sub(d,-i-1,-i)))
i+=2
end
poke(a,unpack(p))
end
}
tmap(... and d or {d},function(v,i)
(f[l] or f[5])(a+i*l-l,v)
end)
end

function initdat()
local db=dat
memset(0x5e00,0,0x100)
dload()
dat.seed=rnd(-1)\1
dat.cartno=1
dat.playno=db.playno+1
convertdat()
return 1
end

function convertdat()
dat.weeks=dat.playcnt_t+dat.playcnt_l
dat.month=(dat.weeks)\4%13+1
--dat.month=13
dat.years=(dat.weeks)\52
dat.recinewn=dat.recinew>0 and menun[dat.recinew] or '?゛???゛???!'
dat.recifirstn=dat.recifirst>0 and menun[dat.recifirst] or '?゛???゛???!'
dat.recilearn=count(dat.recilearnb,1)
dat.itemnum={bunpack(dat.items,12,unpack(tbfill(4,1,8)))}
maxigrd=min(dat.recilearn\10,3)
maxinum=dat.luckcount
momap=0x1fc0+dat.month*128
shfbl={peek(momap,16)}
sesbl={deli(shfbl,1),deli(shfbl,1)}
bkmbl={}
for i=1,16 do
if (dat.markingst[1]|dat.markingst[2])&0x.8<<i~=0 then
add(bkmbl,i)
end
end
iskan=dat.weeks>=kansyoku and 1
isaga=dat.weeks>=agari

spshikomi=dat.month==13 and '<=' or dat.month==8 and ':;'

srand(dat.seed)
adtx={}
for i=1,min(dat.adticnt,12) do
add(adtx,rnd(adts)..rnd(adts)..chr(rnd(24)+65))
end
adtx=join(',',unpack(adtx))
--spshikomi=1
--maxigrd=2
--maxinum=16
--iskan=1
--isaga=0
if isaga or maxigrd==0 then
shfbl,sesbl=nil
end
end

function clone(t)
return tmap(cat({},t),function(v)
return ttable(v) and clone(v) or v
end)
end

sfxa=0x3200+0*68 --sfx 0
sfxb=0x3200+1*68 --sfx 1
function pwm()
poke(sfxa,peek(sfxa+63),peek(sfxa,63))
end

?"\^!5600\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0゜⁙⁙⁙\0\0\0\t\t\0\0\0\0\n\0\n\0\0\0\0\0\0‖\0\0\0\0\0\0\0\0\0\0、\0\0\0\0\0\0\0\0\0\0>+.*.▮\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\n\n\0\0\0\0\0\0\0\0\n\n\n」\0□%!!3゛\0「.<゛\0□‖\t◀\0\0\0\0\0\0\0\0\0\0\n\n\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0゜\0\0\0\0\0\0\0\0\0\0\0\0」」」」」\0゛\0」「゜\0」「「」\0」」」゛「「「\0゜「「\0⁙⁙\0゜」」「「「「\0」」」」\0」」゛「「\0?◀#\0■<‖<*□-\0>」>¥?「\0?゛゛-\0゛!-%-!゛\0•「\0\0゜•‖」\0゜⁙゜⁙⁙⁙\0゜⁙⁙⁙゜\0゛゜゛\0゜⁙⁙⁙⁙\0゛゜゜\0゛゜\0゛゜•⁙⁙\0⁙⁙⁙゜⁙⁙⁙\0\0゛゛「「」」\0•••⁙\0゜\0▶゜゜⁙⁙\0⁙⁙▶▶••⁙\0゜⁙⁙⁙⁙\0゜⁙⁙\0゜⁙⁙▶◀\0゜⁙⁙⁙\0゛゜▮▮\0゜゜\0⁙⁙⁙⁙⁙⁙\0⁙⁙⁙⁙\0⁙⁙゜゜▶\0⁙⁙⁙⁙⁙\0⁙⁙⁙゛\0゜゜「゜\0□-\0゛▮\0008/=/=+$\0゜■■゜■■゜\0, .($□<\0\n\n\r\n゜\0>2>2>29\0、*、⁘、、□\n゜\n゜\n\n\t<\00088▮▮>\0゜(゛、*(‖\r\r‖「<□0「6▮0゛\t゜□⁙□>4(>8&゜゜、゛(<:((゛>0、0、0゜\0<$$$\":\0、\n□‖\0>8⁘< >8&゜\t\0゜、><\0>\0000゜゜▮>▮<8>゜\r゜、□<*6、**゜゜((>(<*((□\n。\0\0\0\0\0‖\0\0\0\0■\0\0■•゜゜゜゜゜\0■•‖■■■゜\0!‖:/*-/\0□)゛゛\n6\0?-33\0\"':\"7:\"\0\"*'*':\"\0\0•゜゜\0\0\n□■⁘□」\0\n\n■■\0■゜•゜■゛\0:*)9▶)\0⁘□;□□□:\0」□▮+*=\0,700 ▮▮▮+▮▮▮\0\0\r\0\0\0\0\t\t\t\0\0\0\t\0\0\0\r\0\0\0\n\0\0\0\0\0\0\0\0\0\t\0\0\0\0\0\0\0¥‖‖⁙\0■■■■‖\0⁙▮▮\0\t」\0□◀⁙‖‖\0□◀⁙□□」\0゜゛\0「\0\t。\t\t\t\t\0▮\0\0\0゛\0、\0■■\0、\n\n\0¥\n、\0¥\0¥」\0゛■▮\0\0■▮▮▮\0「▶「\0■\t゛\0□▶■\t\t◀\0。」\0\t\r•‖‖•「\0」‖▶□¥‖。\0■‖‖‖‖⁙\0\t゜\t\t\r⁙\r\0¥■■■\0\t」‖\0\t\t■▮▮▮\0。\t。\t\r⁙\r\0、、\t▶\0⁙⁘⁘゛‖‖⁙\0□▶□⁙⁙\0\t\r▶‖‖⁙\0□□\0\t\r□⁙□\0\r◀‖‖‖\0、」▶\0■▮▮\0\r⁙■■▮▮\0⁙、□\0□•▶□\n¥\0■▮\0\r⁙■□⁙\n\0¥\t゛\0\t\t」\0\0\0\0\t\0\0\0\t\0\0\0\r◀‖\r\0\0\0\0▮▮⁘\0▮▮▮\0゜■■▮▮\0゛゜\0゜\n\t\0□□□□」\0゜゜\0□■▮▮▮\0゜\t\t\0▮▮▮▮▮゜\0□゜□□▮▮\0▮▶▮▮▮\0▮▮□■\0゛⁙、\0■■□□▮▮\0■■゜■▮\0「゜\0‖‖▮▮▮\0゛\0゜\0■\0゜\0\0゛\0\0\0\0゜\0▮▮□\0▮▮‖\0▮▮▮▮▮\0□□■■■■\0■゛\0▮▮▮▮\0\t▮▮▮\0゜\r‖‖‖\0▮▮▮\t「\0、、、\0■■」▶\0▮□□⁘⁘▶\0、\0。⁙■\t\0゜\0▮▮゛▮▮゜\0゜\0゜▮▮▮\0■■■■▮▮\0」\0■\t\0■■■■■\0■■■▮▮\0▮゜▮▮▮\0⁘▮▮▮\0\0\0‖▮▮\0\0\0\r\0\0\0\0\0\0\0゜■\n\n■゜\0゜■■■\0"
poke(0x5f58,0x81)
cat(_ENV,htbl([[
itemprm{
{0=3600;4800 7777 5555 {extime}}
{0=0;1 2 *s {spinc}}
{0=0.05;0.2 1 0.4 {dlps}}
{0=1;1.4 2 1.1 {scup}}
{0=22;9 3 14 {flips}}
{0=10;20 30 5 {combob}}
{0=7;6 5 8 {maxblid}}
{0=180;240 360 200 {combot}}
}
agari=208;kansyoku=212;
adstock=0;
purify=0;
season{ab cd ef gh ij kl mn op qr st uv wx yz}
mindex{time=1;left=2;reci=3;}
mkey{time left reci}
mcdex{2 2 3}
modehi{hiscore_t hiscore_l}
modepc{playcnt_t playcnt_l}
bgx=0;bgy=0;
clx=0;titley=0;
pals{
bitp{0123456789abcdef$ 0101010101010101$ 0011001100110011$ 0000111100001111$ 0000000011111111$}
sticp{12$ 8c$ 3b$ 9a$}
clsp{379ab$ 78777$ 379ab$}
}
kompei{{/0/}{0+ 1+  }{0+0+ 1+0+ 1+3+}}
menucam{{0 0}{0 0}{0 0}{0 0}}
puzcam{0 -32}
rects{
clbr{112 0 16 16}
coor{16 96 40 16}
prer{72 96 40 16}
puz1{16 96 40 16 15 3}
puz2{72 96 40 16 15 3}
puzu{0 0 41 16 15 3}
puzm{0 0 42 18 14 3}
puzd{0 0 43 19 6 3}

centr{40 41 0 0}
menu{0 0 48 40 15 6}
menm{0 0 50 44 14 6}
mend{0 0 51 45 6 6}
meno1{-52 -50 0 0}
meno2{132 -50 0 0}
meno3{-52 134 0 0}
meno4{132 134 0 0}
menu1{12 16 46 40}
menu2{68 16 46 40}
menu3{12 72 46 40}
menu4{68 72 46 40}
spatr{256 360 16 24 -24}
scisr{112 360 16 24 -24}
fudar{113 336 13 16 -24}
chisr{107 23 5 383 -1}
chitr{4 24 104 383 -21}
chifr{8 44 96 337 -46}
dtitr{8 28 96 12}
numr{63 38 36 1}
cutr{4 25 104 1}
cuter{0 10 120 16}
cutsr{92 10 24 16}
sticr{0 0 3 8}
whitr{112 128 16 112}
photor{34 44 60 20}
owar{12 416 104 128 10}
crr{12 552 104 330 0}
}
respos{
{-40 -32} {-72 -32} {-40 -64} {-72 -64}
}
data{
playno{0x5e20 1}
recinew{0x5e21 1}
recifirst{0x5e22 1}
playcnt_t{0x5e23 2}
playcnt_l{0x5e25 2}
hiscore_t{0x5e27 8}
hiscore_l{0x5e2f 8}
maxcombo{0x5e37 2}
totalscore{0x5e39 16}
totalmatch{0x5e49 8}
totalblock{0x5e51 8}
techblocks{0x5e59 4.1}
adstock{0x5e7c 2}
adticnt{0x5e7e 2}
seed{0x5e80 2}
cartno{0x5e82 1}
items{0x5e83 4}
luckcount{0x5e87 1}
notice{0x5e88 4}
bookmark{0x5e8c 1 1}
markingst{0x5e8e 2 2}
}
adts{?? ?? ?? ?? ?? ?? ??}
camx=0;camy=0;
ver=	1.1A-pre;
cart=#kitchenmatchen3_;
]]
..join(' ',mapt'32 16 16 14',mapt'48 0 16 32'
,mapt'80 0 16 32',mapt'96 0 16 32'
,mapt'112 7 16 25'),'\t',' ','\r','\n'
)
,htbl(mapt'112 0 16 5'))
cat(_ENV,
tmap(irects,exrect)
,tmap(drects,exrect)
,tmap(rects,exrect)
,tmap(pals,
function(v)
return {mkpal(unpack(v))}
end))
