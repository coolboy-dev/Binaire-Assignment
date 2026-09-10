-- sapper 2026

-- standart:
-- 9x9    10
-- 16x16  40
-- 30x16  99
-- 30x24  99

function _init()

 tick=0

 mouse_init()
 oldbtn1=false
 oldbtn2=false
 oldbtn3=false
 
 cur={x=1,y=1,-- coordinates
 					s=7,    -- sprite num
 					h=0,    -- hold time
 					f=true, -- first press
 					hide=false
 					}
 old_u=false
 old_d=false
 old_l=false
 old_r=false
 old_x=false
 old_o=false

 palt(0,false)
 palt(14,true)
 
 configs={}
 add(configs,{x=9,y=9,b=10,hs={}})
 add(configs,{x=16,y=16,b=40,hs={}})
 add(configs,{x=21,y=19,b=80,hs={}})
 currentconf=1
 conf=configs[currentconf]
 
 optionmark=true
 
 loadstate()
 
 menuitem(1,"restart",restart)
 menuitem(2,"<"..conf.x.."x"..conf.y..">",changeconf)
 if optionmark then
  menuitem(3,"<use ?: on>",changeoptionmark)
 else
  menuitem(3,"<use ?: off>",changeoptionmark)
 end
 menuitem(4,"high scores",showhighscores)
 
 start()
 --mode="win"
 showhs=false
 --startwin()
 
end

function _update60()

 tick+=1
 
 mouse_update()
 m_x=flr((mouse.x-f_x)/6)+1
 m_y=flr((mouse.y-f_y)/6)+1
 if m_x>=1 and m_x<=f_w and m_y>=1 and m_y<=f_h then
  cell=rows[m_y][m_x]
 else
  cell=nil
 end
 
 cur.s=7+flr(tick/5)%2
 if (btn(⬆️) and btn(⬅️) and cur.h==0) then
  cur.x-=1
  cur.y-=1
  holdcur()
 end
 if (btn(⬆️) and btn(➡️) and cur.h==0) then
  cur.x+=1
  cur.y-=1
  holdcur()
 end
 if (btn(⬇️) and btn(⬅️) and cur.h==0) then
  cur.x-=1
  cur.y+=1
  holdcur()
 end
 if (btn(⬇️) and btn(➡️) and cur.h==0) then
  cur.x+=1
  cur.y+=1
  holdcur()
 end
 if (btn(⬆️) and cur.h==0) or
  (btn(⬆️)==false and old_u and cur.f) then
  cur.y-=1
  holdcur()
 end
 if (btn(⬇️) and cur.h==0) or
  (btn(⬇️)==false and old_d and cur.f) then
  cur.y+=1
  holdcur()
 end
 if (btn(⬅️) and cur.h==0) or
  (btn(⬅️)==false and old_l and cur.f) then
  cur.x-=1
  holdcur()
 end
 if (btn(➡️) and cur.h==0) or
  (btn(➡️)==false and old_r and cur.f) then
  cur.x+=1
  holdcur()
 end
 cur.x=mid(1,cur.x,f_w)
 cur.y=mid(1,cur.y,f_h)
 cur.h=max(cur.h-1,0)
 
 mface=false
 if mouse.x>=56 and mouse.x<72
  and mouse.y>=114 and mouse.y<128 then
	 if mouse.btn1==false and mouse.btn2==false and oldbtn1 then
   mface=true
  end
 end
 
 if mface then
  start()
  cur.hide=true
 elseif mode=="wait" or mode=="game" then
  
  if showhs then
  
   starsupdate()
   
   cur.h=16
   oldbtn1=false
   oldbtn2=false
   oldbtn3=false
 	 if mouse.btn1 or
	     mouse.btn2 or
	     mouse.btn3 or
	     btn(❘) or
	     btn(🅾️) or
	     btn(⬆️) or
	     btn(⬇️) or
	     btn(⬅️) or
	     btn(➡️) then
	   showhs=false
	  end
	  
  end
  
	 -- open cell
	 if mouse.btn1==false 
	  and mouse.btn2==false 
	  and oldbtn1 then
	  
		 btn1update(m_x,m_y,cell)
		 cur.hide=true
		 
	 end
	 if (btn(❘) and cur.h==0) or
	  (btn(❘)==false and old_x and cur.f) then
	  
		 btn1update(cur.x,cur.y,rows[cur.y][cur.x])
	  holdcur()
	  
	 end
	 
	 -- mark cell
	 if mouse.btn1==false 
	  and mouse.btn2==false 
	  and oldbtn2 then
	  
		 btn2update(m_x,m_y,cell)
		 cur.hide=true
		 
	 end
	 if (btn(🅾️) and cur.h==0) or
	  (btn(🅾️)==false and old_o and cur.f) then
	  
		 btn2update(cur.x,cur.y,rows[cur.y][cur.x])
	  holdcur()
	  
	 end
	 
	 endtime=gettime()
	
	elseif mode=="win" then
	 
  starsupdate()
  
	 if mouse.btn1==false 
	  and mouse.btn2==false 
	  and (oldbtn1 or oldbtn2) then
	  showhs=not showhs
	 end
	 if (btn(❘) and cur.h==0) or
	  (btn(❘)==false and old_x and cur.f) then
	  showhs=not showhs
	  holdcur()
	 end
	 if (btn(🅾️) and cur.h==0) or
	  (btn(🅾️)==false and old_o and cur.f) then
	  showhs=not showhs
	  holdcur()
	 end
	 
	end

 old_u=btn(⬆️)
 old_d=btn(⬇️)
 old_l=btn(⬅️)
 old_r=btn(➡️)
 old_x=btn(❘)
 old_o=btn(🅾️)
 if not(old_u or old_d or
        old_l or old_r or
        old_x or old_o) then
  cur.f=true
 end
 
 oldbtn1=mouse.btn1
 oldbtn2=mouse.btn2
 oldbtn3=mouse.btn3
 
end

function _draw()
 
 cls(3)
 
 m_x=flr((mouse.x-f_x)/6)+1
 m_y=flr((mouse.y-f_y)/6)+1
 
 local i,j
 for j=1,f_h do
  cells=rows[j]
  for i=1,f_w do
   cell=cells[i]
   snum=1+cell.mark
   if mode=="over" and cell.mark==1 and cell.isbomb==false then
    snum=6
   elseif cell.opened then
    if cell.isbomb then
     snum=5
    else
     snum=48+cell.value
    end
   elseif mouse.btn1 and cell.mark==0 and m_x==i and m_y==j then
    snum=4
   end
   spr(snum,i*6-6+f_x,j*6-6+f_y)
  end
 end
 
 -- bomb count
 drawnum(max(bcount-markscount,0),0,114)
 
 -- face
 mface=false
 if mouse.x>=56 and mouse.x<72
  and mouse.y>=114 and mouse.y<128 then
  if mouse.btn1 and mouse.btn2==false then
   mface=true
  end
 end
 if mface then
  snum=12
 elseif mode=="wait" or mode=="game" then
  snum=10
 elseif mode=="win" then
  snum=42
 elseif mode=="over" then
  snum=44
 end
 spr(snum,56,114,2,2)
 
 -- timer
 if starttime!=-1 then
  timer=min(endtime-starttime,999)
	 drawnum(timer,104,114)
	else
	 drawnum(0,104,114)
	end
	
	-- win animation
	--if mode=="win" and showhs then
	if showhs then
	 for star in all(stars) do
	  if (star.r>0) spr(star.s,60+star.r*cos(star.a),60+star.r*sin(star.a))
	 end
	 local x,y=2,32
	 
	 for config in all(configs) do
	 
	  y=32
		 for i=1,5 do
		  if #config.hs>=i then
		   sc=config.hs[i]
		  else
		   sc=0
		  end
 		 drawnum(sc,x,y,5)
		  y+=14
		 end
		 
	  y=16
		 drawnum(config.x,x,y,2)
		 x+=16
		 spr(14,x,y,1,2)
		 x+=8
		 drawnum(config.y,x,y,2)
		 x+=16
		 x+=2
		 
	 end
	 
	end
	
	-- ciursor
	if cur.hide==false and showhs==false then
  spr(cur.s,cur.x*6+f_x-6,cur.y*6+f_y-6)
 end
 
 mouse_draw()

end
-->8
--mouse
function mouse_init()
 poke(0x5f2d, 1)
 mouse={}
 mouse.x=0
 mouse.y=0
 mouse.btn1=false
 mouse.btn2=false
 mouse.btn3=false --middle
 mouse.hold=0
 mouse.hide=false
end

function mouse_update()
 if mouse.x!=stat(32)
  or mouse.y!=stat(33)
  or stat(34)>0 then
  mouse.hide=false
 end
 mouse.x=stat(32)
 mouse.y=stat(33)
 btns=stat(34)
 mouse.btn1=(btns&0b0001)>0
 mouse.btn2=(btns&0b0010)>0
 mouse.btn3=(btns&0b0100)>0
 mouse.hold=max(0,mouse.hold-1)
end

function mouse_draw()
 if mouse.hide==false then
  spr(15,stat(32),stat(33),1,2)
 end
end
-->8
-- draws
function drawnum(num,x,y,digits)
	
	if digits==nil then
	 digits=3
	end
	
	if digits>=5 then
	 digit=flr(num/10000)%10
	 spr(digit+16,x,y,1,2)
	 x+=8
	end
	if digits>=4 then
	 digit=flr(num/1000)%10
	 spr(digit+16,x,y,1,2)
	 x+=8
	end
	if digits>=3 then
	 digit=flr(num/100)%10
	 spr(digit+16,x,y,1,2)
	 x+=8
	end
	if digits>=2 then
	 digit=flr(num/10)%10
	 spr(digit+16,x,y,1,2)
	 x+=8
	end
 digit=num%10
 spr(digit+16,x,y,1,2)

end
-->8
-- stuff

function opencell(x,y,first)
 
 if x<1 or x>f_w or y<1 or y>f_h then
  return
 end
 
 cell=rows[y][x]
 
 if cell.opened or cell.mark>0 then
  return
 end
 
 -- boom
 if cell.isbomb then
 	
 	if first==true then
 	 
 	 cell.isbomb=false
 	
 	 local i,j,c
 	 
	  i=flr(rnd(f_w))+1
	  j=flr(rnd(f_h))+1
	  c=rows[j][i]
	  while c.isbomb or (i==x and j==y) do
	   i=flr(rnd(f_w))+1
	   j=flr(rnd(f_h))+1
	   c=rows[j][i]
	  end
	  c.isbomb=true
	  
	  calcvalues()
 	 
 	else
  
	  mode="over"
	  
	  sfx(0)
	  
	  local i,j
	  
	  for j=1,f_h do
	   for i=1,f_w do
	    cell=rows[j][i]
	    if cell.isbomb and cell.mark==0 then
	     cell.opened=true
	    end
	   end
	  end
	  
   savestate()
	  
	  return
	  
	 end
  
 end
 
	cell.opened=true
	
 openedcount+=1
 if (openedcount+bcount)==(f_w*f_h) then
  mode="win"
  addhighscore(timer)
  startwin()
 end
 
 if cell.value==0 then
  
  opencell(x-1,y-1)
  opencell(x,y-1)
  opencell(x+1,y-1)
  opencell(x-1,y)
  opencell(x+1,y)
  opencell(x-1,y+1)
  opencell(x,y+1)
  opencell(x+1,y+1)

 end
 
end

function checkcells(x,y)

 if x<1 or x>f_w or y<1 or y>f_h then
  return
 end
 
 cell=rows[y][x]
 
 if cell.opened==false then
  return
 end
 
 --marks count
 mcount=0
 if y>1 and x>1 then
  c=rows[y-1][x-1]
  if (c.opened==false and c.mark==1) mcount+=1
  if (c.opened and c.isbomb) mcount+=1
 end
 if y>1 then
  c=rows[y-1][x]
  if (c.opened==false and c.mark==1) mcount+=1
  if (c.opened and c.isbomb) mcount+=1
 end
 if y>1 and x<f_w then
  c=rows[y-1][x+1]
  if (c.opened==false and c.mark==1) mcount+=1
  if (c.opened and c.isbomb) mcount+=1
 end
 if x>1 then
  c=rows[y][x-1]
  if (c.opened==false and c.mark==1) mcount+=1
  if (c.opened and c.isbomb) mcount+=1
 end
 if x<f_w then
  c=rows[y][x+1]
  if (c.opened==false and c.mark==1) mcount+=1
  if (c.opened and c.isbomb) mcount+=1
 end
 if y<f_h and x>1 then
  c=rows[y+1][x-1]
  if (c.opened==false and c.mark==1) mcount+=1
  if (c.opened and c.isbomb) mcount+=1
 end
 if y<f_h then
  c=rows[y+1][x]
  if (c.opened==false and c.mark==1) mcount+=1
  if (c.opened and c.isbomb) mcount+=1
 end
 if y<f_h and x<f_w then
  c=rows[y+1][x+1]
  if (c.opened==false and c.mark==1) mcount+=1
  if (c.opened and c.isbomb) mcount+=1
 end
 
 if cell.value==mcount then
  
  opencell(x-1,y-1)
  opencell(x,y-1)
  opencell(x+1,y-1)
  opencell(x-1,y)
  opencell(x+1,y)
  opencell(x-1,y+1)
  opencell(x,y+1)
  opencell(x+1,y+1)

 end
 
  
end

function markcells(x,y)

 if x<1 or x>f_w or y<1 or y>f_h then
  return
 end
 
 cell=rows[y][x]
 
 if cell.opened==false then
  return
 end
 
 --cells count
 ccount=0
 if y>1 and x>1 then
  c=rows[y-1][x-1]
  if (c.opened==false) ccount+=1
 end
 if y>1 then
  c=rows[y-1][x]
  if (c.opened==false) ccount+=1
 end
 if y>1 and x<f_w then
  c=rows[y-1][x+1]
  if (c.opened==false) ccount+=1
 end
 if x>1 then
  c=rows[y][x-1]
  if (c.opened==false) ccount+=1
 end
 if x<f_w then
  c=rows[y][x+1]
  if (c.opened==false) ccount+=1
 end
 if y<f_h and x>1 then
  c=rows[y+1][x-1]
  if (c.opened==false) ccount+=1
 end
 if y<f_h then
  c=rows[y+1][x]
  if (c.opened==false) ccount+=1
 end
 if y<f_h and x<f_w then
  c=rows[y+1][x+1]
  if (c.opened==false) ccount+=1
 end
 
 if cell.value==ccount then
  
  local i,j
  
  for j=max(y-1,1),min(y+1,f_h) do
   for i=max(x-1,1),min(x+1,f_w) do
    cell=rows[j][i]
    if cell.opened==false then
     if (cell.mark!=1) markscount+=1
     cell.mark=1
    end
   end
  end

 end
 
  
end

function gettime()
 return stat(95)+(stat(94)+stat(93)*60)*60
end

function holdcur()
 
 cur.hide=false
 mouse.hide=true
 
 if cur.f then
  --cur.h=16
  cur.h=12
  cur.f=false
 else
  cur.h=4
 end

end
-->8
-- start
function start()

 showhs=false
 mode="wait"
 
 bcount=0
 markscount=0
 openedcount=0
 
 starttime=-1
 endtime=-1

 rows={}
 
	currentconf=mid(1,currentconf,3)
 conf=configs[currentconf]
 
 f_w=conf.x
 f_h=conf.y
 f_x=flr((128-f_w*6)/2)
 f_y=flr((116-f_h*6)/2)
 bcount=conf.b
 
 -- create table
 local i,j,x,y
 for j=1,f_h do
  cells={}
  for i=1,f_w do
   add(cells,{isbomb=false,opened=false,mark=0,value=0})
  end
  add(rows,cells)
 end
 
 -- create bombs
 for i=1,conf.b do
  
  x=flr(rnd(f_w))+1
  y=flr(rnd(f_h))+1
  cell=rows[y][x]
  while cell.isbomb do
   x=flr(rnd(f_w))+1
   y=flr(rnd(f_h))+1
   cell=rows[y][x]
  end
  cell.isbomb=true
  
 end
 
 calcvalues()

end

function calcvalues()

 local i,j,cell,value

 for j=1,f_h do
  for i=1,f_w do
   cell=rows[j][i]
   value=0
   if i>1 and j>1 then
    if (rows[j-1][i-1].isbomb) value+=1
   end
   if j>1 then
    if (rows[j-1][i].isbomb) value+=1
   end
   if i<f_w and j>1 then
    if (rows[j-1][i+1].isbomb) value+=1
   end
   if i>1 then
    if (rows[j][i-1].isbomb) value+=1
   end
   if i<f_w then
    if (rows[j][i+1].isbomb) value+=1
   end
   if i>1 and j<f_h then
    if (rows[j+1][i-1].isbomb) value+=1
   end
   if j<f_h then
    if (rows[j+1][i].isbomb) value+=1
   end
   if i<f_w and j<f_h then
    if (rows[j+1][i+1].isbomb) value+=1
   end
   cell.value=value
  end
 end

end

function restart(buttons)
 start()
end

function changeconf(buttons)

	if buttons&32>0 then
	 start()
	 return false
	end
	if (buttons&1>0) currentconf-=1
	if (buttons&2>0) currentconf+=1
	
	currentconf=mid(1,currentconf,3)
 conf=configs[currentconf]
 menuitem(_,"<"..conf.x.."x"..conf.y..">")

 savestate()
 start()

end

function changeoptionmark(buttons)

	if (buttons&32>0) return false
	if (buttons&1>0) currentconf-=1
	if (buttons&2>0) currentconf+=1
	
	optionmark=not optionmark
 menuitem(_,"<"..conf.x.."x"..conf.y..">")
 if optionmark then
  menuitem(_,"<use ?: on>")
 else
  menuitem(_,"<use ?: off>")
 end
 
 savestate()

end

function showhighscores(buttons)
 --showhs=true
 startwin()
end

function savestate()

 cartdata("1sergey_sapper")
 
 local i,j,adr
 dset(0,currentconf)
 if optionmark then
 	dset(1,1)
 else
 	dset(1,0)
 end
 
 adr=2
 for j=1,3 do
  for i=1,5 do
   if #configs[j].hs>=i then
    dset(adr+(j-1)*5+i-1,configs[j].hs[i])
   end
  end
 end
 
end

function loadstate()
 
 if cartdata("1sergey_sapper") then
 
  currentconf=dget(0)
  conf=configs[currentconf]
 
  if dget(1)==1 then
   optionmark=true
  else
   optionmark=false
  end
 
  local i,j,adr
 
	 adr=2
	 for j=1,3 do
	  for i=1,5 do
	   sc=dget(adr+(j-1)*5+i-1)
	   if sc>0 then
	    configs[j].hs[i]=sc
	   end
	  end
	 end
	 
	end
 
end
-->8
-- buttons update

function btn1update(x,y,cell)
 
 if cell==nil then
  return
 end
 
 sfx(2)

 if cell.opened then
  checkcells(x,y)
 else
 	if mode=="wait" then
   opencell(x,y,true)
 	else
   opencell(x,y)
  end
 end
 
 if mode=="wait" then
  mode="game"
  starttime=gettime()
 end
 
end

function btn2update(x,y,cell)

 if cell==nil then
  return
 end
 
 sfx(1)
 
 if cell.opened==false then
 
  if cell.mark==1 then
   markscount-=1
  end

  cell.mark+=1
  if optionmark then
   maxmark=2
  else
   maxmark=1
  end

  if (cell.mark>maxmark) cell.mark=0
  
  if cell.mark==1 then
   markscount+=1
  end
  
 else
 
  markcells(x,y)
  
 end
 
 --if mode=="wait" then
 -- mode="game"
 -- starttime=gettime()
 --end

end
-->8
-- high scores

function addhighscore(score)
 
 local i=0
 for sc in all(conf.hs) do
  i+=1
  if score<sc then
  	add(conf.hs,score,i)
   if #conf.hs>5 then
    deli(conf.hs)
   end
  	return
  end
 end
 
 if #conf.hs<5 then
 	add(conf.hs,score)
 end
 
end

function startwin()
 
 showhs=true
 stars={}
 
 local i
 for i=1,128 do
  add(stars,{r=-i,a=i/16,s=46})
 end
 
 savestate()
 
end

function starsupdate()

	 for star in all(stars) do
	  star.a+=1/128
	  star.r+=2
	  if (star.r>128) star.r=0
	  star.s=46+flr(star.r/2)%2
	 end

end