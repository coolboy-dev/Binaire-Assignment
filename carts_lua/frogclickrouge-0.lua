--frog click rouge
--by team metroit

function _init()
 poke(0x5f2d, 1)
 
 title=false
 itemstodraw={}
 
 make_peaks()
 make_ui()
 make_clicks()
 make_player()
 make_frog()
 make_round()
 
 make_item()
 make_all_items()
 add_nothing()
end

function _update()
 mouse_posx=stat(32)
 mouse_posy=stat(33)
 
 if(not round_end) then
  add_frog()
  move_frogs()
 end
 
 mouse_click()
 mouse_click_button()
 mouse_click_peak()
 round_tracker()
 
 move_player_anim()
 
 off_screen()
end

function _draw()
 cls()
 
 if(not title) then
  draw_player()
  draw_frogs()
  draw_sell_buttom()
 
  if(button_anim) then
   draw_button_anim()
   button_anim_timer-=button_anim_timeadd
  
   if(button_anim_timer<=0) then
    button_anim=false
   end
  end
 
  for item in all(itemstodraw) do
   draw_item(item)
  end
 
  for item in all(itemstomove) do
   if(not move_player) then
    move_toward(item,player,2)
   end
   draw_item_move(item)
  end
 
  for item in all(itemsequipt) do
   draw_item_equipt(item)
  end
 
  sell_price()
  draw_peaks()
  draw_mouse()
  off_screen()
 
  local x=0
  local y=90
 
  for des in all(peak_des) do
   print(des,x,y)
   y+=#split(des,"\n")*6
   if(y>=120) then
    x+=15
    y=90
   end
  end
 else
  spr(64,0,0)
 end
end
-->8
--player

function make_player()
 player={
 x=65,
 y=49,
 sx=70,
 sy=50,
 image1=1,
 image2=16
 }
 
 move_player=false
end
 
function move_player_anim()
 if(move_player) then
  player.x+=1
 end
 if(player.x==65) then
  move_player=false
 end
end

function draw_player()
 spr(player.image1,player.x,player.y)
 spr(player.image2,player.x,player.y+8)
end
-->8
--frogs

function make_frog()
 spawner={
 x=-8,
 y=32,
 timeset=4,
 timer=4,
 timeadd=0.1,
 item=nil
 }
 
 frogs={}
end

function add_frog()
 spawner.timer-=spawner.timeadd
 if(spawner.timer<=0) then
  local frog={
  x=spawner.x,
  y=32,
  dx=0,
  max_dx=2,
  image1=1,
  image2=16,
  speed=1
  }
  add_to_draw(frog)
  add(frogs,frog)
  spawner.timer=spawner.timeset
 end
end
 
function move_frogs()
 for frogs in all(frogs) do
  frogs.x+=frogs.speed
 end
end

function draw_frogs()
 for frogs in all(frogs) do
  spr(frogs.image1,frogs.x,frogs.y)
  spr(frogs.image2,frogs.x,frogs.y+8)
 end
end
  
-->8
--items

function make_item()
 items={}
 itemsequipt={}
 iteminpart={head=nil,shirt=nil,shoes=nil}
end

function make_all_items()
 make_new_item(2,-2,1,"head",5)
 make_new_item(3,0,1,"shirt",5)
 make_new_item(4,-3,3,"head",4)
 make_new_item(5,0,2,"shoes",4)
 make_new_item(6,0,4,"shirt",3)
 make_new_item(7,0,2,"shoes",5)
 make_new_item(8,-1,5,"head",2)
 make_new_item(9,0,7,"head",2)
 make_new_item(10,0,4,"shirt",3)
 make_new_item(11,0,5,"shoes",3)
 make_new_item(12,0,10,"shirt",1)
 make_new_item(13,-1,3,"shoes",4)
 make_new_item(14,0,1,"shoes",5)
 make_new_item(15,0,10,"head",1)
 make_new_item(15,0,10,"shirt",1)
end

function make_new_item(image,y,price,part,rare)
 local item={
 image=image,
 addy=y,
 x=spawner.x,
 y=spawner.y,
 following,
 frog,
 price=price,
 part=part,
 rare=rare
 }
 
 for i=1,rare do
  add(items,item)
 end
end

function make_item_copy(image,y,price,part,rare)
 local item={
  image=image,
  addy=y,
  x=spawner.x,
  y=spawner.y,
  following,
  frog,
  price=price,
  part=part,
  rare=rare
 }
 
 return item
end

function add_to_draw(frog)
 selit=flr(rnd(#items+1))
 theitem=items[selit]
 if(theitem!=nil) then
  itemcopy=make_item_copy(theitem.image,theitem.addy,theitem.price,theitem.part)
  add(itemstodraw,itemcopy)
  upadte_itemfrog(frog,itemstodraw[#itemstodraw])
 end
end

function add_nothing()
	for i=1,#items/2 do
	 add(items,nil)
	end
end 

function upadte_itemfrog(frog, item)
 item.frog=frog
 frog.item=item
end

function draw_item(item)
 item.x=item.frog.x
 item.y=spawner.y+item.addy
 spr(item.image, item.frog.x, spawner.y+item.addy)
end

function draw_item_move(item)
 spr(item.image, item.x, item.y)
end

function draw_item_equipt(item)
 spr(item.image, player.x,player.y+item.addy)
end

function move_toward(item, target, speed)
 local dx = target.sx - item.x
 local dy = target.sy - item.y+item.addy
    
 local distance = sqrt(dx*dx + dy*dy)
    
 if(distance > 1) then
  item.x += (dx / distance) * speed
  item.y += (dy / distance) * speed
 else
  if(iteminpart[item.part]!=nil) then
   sell_number-=iteminpart[item.part].price
   del(itemsequipt,iteminpart[item.part])
   del(iteminpart, iteminpart[item.part])  
  end
  sell_number+=item.price
  del(itemstomove,item)
  add(itemsequipt,item)
  iteminpart[item.part]=item
 end
end
-->8
--mouse

function make_clicks()
 itemstomove={}
 local stop_click=false
 click_time=5
 click_timer=5
 click_timeadd=0.2
 local button_stop_click=false
 button_click_time=5
 button_click_timer=5
 button_click_timeadd=0.2
 local peak_stop_click=false
 peak_click_time=5
 peak_click_timer=5
 peak_click_timeadd=0.2
end

function draw_mouse()
 spr(0,mouse_posx,mouse_posy)
end

function mouse_click()
 click=stat(34)
 click_timer-=click_timeadd
 if(click_timer<=0) then
  stop_click=false
  click_timer=click_time
 end
 if(click==1 and not stop_click) then
  for frog in all(frogs) do
   if(mouse_posx >= frog.x and mouse_posx <= frog.x+8 and mouse_posy >= frog.y and mouse_posy <= frog.y+8) then
    add(itemstomove,frog.item)
    del(itemstodraw,frog.item)
    stop_click=true
   end
  end
 end
end

function mouse_click_button()
 button_click_timer-=button_click_timeadd
 if(button_click_timer<=0) then
  button_stop_click=false
  button_click_timer=button_click_time
 end
 if(click==1 and not button_stop_click) then
  if(mouse_posx >= button.x1 and mouse_posx <= button.x1+16 and mouse_posy >= button.y and mouse_posy <= button.y+8) then
   button_anim_timer=button_anim_time
   button_anim=true
   money+=sell_number*money_multi
   move_player=true
   sell_number=0
   stop_click=true
  end
 end
end

function mouse_click_peak()
 if(peak_get) then
  peak_click_timer-=peak_click_timeadd
  if(peak_click_timer<=0) then
   peak_stop_click=false
   peak_click_timer=peak_click_time
  end
  if(click==1 and not peak_stop_click) then
   for peak in all(peak_buttons) do
    if(mouse_posx >= peak.x and mouse_posx <= peak.x+8 and mouse_posy >= peak.y and mouse_posy <= peak.y+8) then
     peak_anim_timer=peak_anim_time
     make_round_number()
     money=0
     peak_get=false
     round_end=false
     using=peak.peak
     using.effect()
     add(peak_des,using.description)
     stop_click=true
     peak1=rnd(all_peaks)
 				peak2=rnd(all_peaks)
 				peak3=rnd(all_peaks)
    end
   end
  end
 end
end


-->8
--ui

function make_ui()
 sell_number=0
 money=0
 button_anim=false
 button_anim_timer=3
 button_anim_time=3
 button_anim_timeadd=0.2
 
 button={
 image1=48,
 image2=49,
 x1=75,
 x2,
 xt,
 y=65,
 partical1=18,
 partical2=19,
 partical3=20,
 partical4=21,
 partical5=34,
 partical6=37,
 partical7=50,
 partical8=51,
 partical9=52,
 partical10=53
 }
 button.x2=button.x1+8
 button.xt=(button.x1+button.x2)/2
 
 peak_button1={
  image=17,
  x=3,
  y=50,
  peak=peak1
 }
 
 peak_button2={
  image=32,
  x=27,
  y=50,
  peak=peak2
 }
 
 peak_button3={
  image=33,
  x=50,
  y=50,
  peak=peak3
 }
 
 peak_buttons={
  peak_button1,
  peak_button2,
  peak_button3
 }
 
 peak_des={}
 
 peak_button_texty=10
end

function sell_price()
 print("round "..round)
 print("money:"..money)
 print("goal:"..money_to_get)
 print("sell money:"..sell_number*money_multi,75,50,7)
end

function draw_sell_buttom()
 spr(button.image1,button.x1,button.y)
 spr(button.image2,button.x2,button.y)
end

function draw_button_anim()
 spr(button.partical1,button.x1-8,button.y-8)
 spr(button.partical2,button.x1,button.y-8)
 spr(button.partical3,button.x2,button.y-8)
 spr(button.partical4,button.x2+8,button.y-8)
 spr(button.partical5,button.x1-8,button.y)
 spr(button.partical6,button.x2+8,button.y)
 spr(button.partical7,button.x1-8,button.y+8)
 spr(button.partical8,button.x1,button.y+8)
 spr(button.partical9,button.x2,button.y+8)
 spr(button.partical10,button.x2+8,button.y+8)
end

function draw_peaks()
 if(round_end) then
  spr(peak_button1.image,peak_button1.x,peak_button1.y)
  print(peak1.description,0,peak_button1.y+peak_button_texty)
  spr(peak_button2.image,peak_button2.x,peak_button2.y)
  print(peak2.description,peak_button2.x-4,peak_button2.y+peak_button_texty)
  spr(peak_button3.image,peak_button3.x,peak_button3.y)
  print(peak3.description,peak_button3.x-3,peak_button3.y+peak_button_texty)
 end
end
-->8
--offscreen

function off_screen()
 for frog in all(frogs) do
  if(frog.x>=140) then
   del(frogs,frog)
  end
 end
 for item in all(itemstodraw) do
  if(item.frog.x>=140) then
   del(itemstodraw,item)
  end
 end
 if(player.x>=128) then
  iteminpart={head=nil,shirt=nil,shoes=nil}
  itemsequipt={}
  player.x=-10
 end
end
-->8
--round manager
function make_round()
 round=0
 base_money_to_get=flr(rnd(5)+3)
 money_to_get_multi=1.15
 make_round_number()
 round_end=false
end

function make_round_number()
 round+=1
 money_to_get=flr(base_money_to_get*money_to_get_multi^round)
end

function round_tracker()
 if(money>=money_to_get) then
  peak_get=true
  round_end=true
 end
end
-->8
--peaks

function make_peaks()
 effects={
  mu2=function( self )
   money_multi+=0.2
  end,
  
  lu5=function( self )
   local luckadd={}
 
   for i=0,5 do
    add(luckadd,rnd(items))
   end
   
   for item in all(luckadd) do
    add(items,item)
   end
  end,
  
  su10=function( self )
   spawner.timeadd+=0.1
  end,
  
  plu1=function( self )
   add(effects,rnd(effects))
  end
 }
 all_peaks={}
 types={}
 
 money_multi=1
 peak_get=false
 
 make_new_peaks("+0.2\nmoney\ngain",effects.mu2)
 make_new_peaks("+5%\nluck",effects.lu5)
 make_new_peaks("+10%\nspeed",effects.su10)
 make_new_peaks("+1%\npeak\nluck",effects.plu1)
 
 peak1=rnd(all_peaks)
 peak2=rnd(all_peaks)
 peak3=rnd(all_peaks)
end

function make_new_peaks(des,eff)
 local peak={
  description=des,
  effect=eff,
 }
 
 add(all_peaks,peak)
end

function add_peaks_effects()
end