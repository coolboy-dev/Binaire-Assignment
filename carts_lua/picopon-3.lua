seq=split"0,0,1,0,0,1,2,1,0,1,3,1,2,3,4,3,2,1,4,3,5,6,5,7,5,6,4,7,2,4,6,4,2,3,6,7,5,7,8,7,5,8,6,8,9,7,9,9"

command_map={[5554]="advance",[4545]="retreat",[4454]="attack",[5454]="defend"}
reward_titles=split"CHOOSE REWARD,CHOOSE UNIT,CHOOSE EVOLUTION"
pico_chr,pon_chr=chr(151),chr(142)



adv_names=split"STRENGTH,ARMOR,MARKSMAN,FIGHTER,VITALITY,ENDURANCE,SECOND,RECOV."
adv_a=split"+75% DMG,-40% DMG,+75% DMG,+75% DMG,+50% HP,RESIST,50% HP,+30% HP"
adv_b=split"PARTY,TAKEN,RANGED,MELEE,MAX,75% DMG,1/ROOM,COMBAT"
adv_icons=split"101,106,103,104,105,102,107,108"
evo_names=split"PESADO,JINETE,MAGO,TROMP.,BERSERK,LUCHADOR"
evo_en={PESADO="HEAVY",JINETE="RIDER",MAGO="MAGE",["TROMP."]="BARD",LUCHADOR="BRAWLER"}
evo_defs={PESADO=split"64,20,projectile,heavy,126,4,1",JINETE=split"48,16,body,none,86,2,0",MAGO=split"36,20,projectile,magic,34,4,0",["TROMP."]=split"44,6,projectile,note,54,2,0",BERSERK=split"48,22,weapon,none,152,3,1",LUCHADOR=split"72,18,body,none,158,2,2"}

enemy_defs={split"24,3,16,3,melee,8,64,",split"30,2,8,4,body,8,66,",split"20,2,16,3,projectile,20,68,arrow",split"62,5,8,4,melee,8,224,",split"52,4,24,2,body,8,226,",split"48,3,16,3,projectile,24,228,magic",split"94,6,8,3,melee,8,234,",split"84,5,24,2,body,8,236,",split"76,4,16,3,projectile,28,238,magic",split"145,8,8,4,melee,8,6,none,9",split"132,8,24,3,body,8,12,none,187",split"125,7,16,2,projectile,32,139,magic,184"}
encounter_x=split"104,160,216,272"


bg_top=split"8,13,6,17,11,8,19,7,14,10,21,8,12,18,7,15,10,20,6,16,9,13,18,7,15,11,20,8,14,6,17,10,8,13,6,17,11,8,19,7,14,10,21"
bg_floor=split"2,5,1,4,7,2,3,6,1,5,3,8,2,4,6,1,3,7,2,5,1,6,4,2,8,3,5,1,4,7,2,5,2,5,1,4,7,2,3,6,1,5,3"
bg_far=split"0,0,5,15,26,31,22,11,3,0,0,0,7,18,29,24,12,3,0,0,0,8,21,30,22,9,2,0,0,4,15,8,0,0,5,15,26,31,22,11,3,0,0,0"
bg_mid=split"0,3,13,24,19,7,1,0,0,5,17,28,20,8,1,0,0,0,9,22,16,5,0,0,3,15,26,15,4,0,0,0,0,3,13,24,19,7,1,0,0,5,17,28"
bg_near=split"0,8,21,13,3,0,0,0,5,19,30,18,6,0,0,0,0,4,16,9,1,0,0,6,20,31,18,5,0,0,0,0,0,8,21,13,3,0,0,0,5,19,30,18"




pico_fx_timer,pon_fx_timer=0,0


function seqat(i)
 return seq[(i-1)%#seq+1]
end

function setpat(p,m)
 local b,a=m*3,0x3100+p*4
 poke(a,(peek(a)&0x80)|b)
 poke(a+1,(peek(a+1)&0x80)|(b+1))
 poke(a+2,(peek(a+2)&0x80)|0x40)
 poke(a+3,(peek(a+3)&0x80)|(b+2))
end

function clear_input()
 input,input_quality,input_index,input_code={},{},1,0
end

function start_music()
 music(-1)
 setpat(0,seqat(1))
 setpat(1,seqat(2))
 song_pos,last_played,last_beat_slot,phase,beat,audio_tick=1,nil,-1,"input",1,0
 begin_input()
 music(0,0,11)
end

function count_beat()
 beat,beat_flash=count_step,4
 sfx(29+count_step,3)
end

function start_countin()
 music(-1)
 count_in,count_step,count_frame=true,1,0
 phase="action"
 count_beat()
end

function update_countin()
 if count_step==4 and not buffered_button then
  local b=btnp(5) and 5 or btnp(4) and 4
  if b then
   show_drum(b)
   buffered_button,buffered_quality=b,"perfect"
  end
 end
 count_frame+=1
 if count_frame<15 then return end
 count_frame=0
 count_step+=1
 if count_step>4 then
  count_in=false
  start_music()
 else
  count_beat()
 end
end

function make_party_unit(name,hp,damage,atype,style,sprite)
 return {
  name=name,x=8,y=60,
  hp=hp,max_hp=hp,alive=true,
  damage=damage,attack_type=atype,
  projectile_style=style,sprite=sprite,attack_beat=3,armor=name=="TIN" and 1 or 0,
  body_timer=0,body_dx=0,
  weapon_timer=0,wind_timer=0
 }
end

function arrange_party(anchor)
 local desired={}
 local order=split"PAN,KON,TIN"
 for name in all(order) do
  for u in all(party) do
   if u.alive and u.name==name then add(desired,u) end
  end
 end
 local n=#desired
 if n<=0 then return end
 anchor=anchor or (front_party_unit() and front_party_unit().x or 8)
 local back=anchor-(n-1)*12
 if back<8 then anchor+=8-back end
 for i=1,n do
  local u=desired[i]
  u.x=anchor-(n-i)*12
  u.y=60
  u.retreat_x=u.x
 end
end

function add_party_member(u)
 local f=front_party_unit()
 add(party,u)
 arrange_party(f and f.x or 8)
end

function boost_vitality(u)
 local old=u.max_hp
 u.max_hp=flr(old*1.5+0.5)
 if u.alive then u.hp=min(u.max_hp,u.hp+u.max_hp-old) end
end

function recruit_unit(name)
 local p=name=="PAN"
 local u=make_party_unit(name,p and 28 or 56,8,p and "projectile" or "weapon",p and "arrow" or "",p and 74 or 76)
 for i=1,vitality_stacks do boost_vitality(u) end
 add_party_member(u)
end

function build_reward_units()
 reward_units={"PAN","TIN"}
 for u in all(party) do del(reward_units,u.name) end
end

function build_reward_evos()
 reward_evos={}
 for u in all(party) do
  if u.alive and not u.evolution then
   local i=u.name=="KON" and 1 or u.name=="PAN" and 3 or 5
   add(reward_evos,{unit=u,name=evo_names[i+flr(rnd(2))]})
  end
 end
end

function apply_evolution(e)
 local u,d=e.unit,evo_defs[e.name]
 u.evolution=e.name
 u.max_hp=d[1]
 for i=1,vitality_stacks do u.max_hp=flr(u.max_hp*1.5+0.5) end
 u.hp=u.max_hp
 u.damage,u.attack_type,u.projectile_style,u.sprite,u.attack_beat,u.armor=d[2],d[3],d[4],d[5],d[6],d[7]
end

function take_adv(pool)
 return deli(pool,flr(rnd(#pool))+1)
end

function build_reward_slots()
 local pool={}
 local ranged,melee=false,false
 for u in all(party) do
  if u.alive then
   if u.attack_type=="projectile" then ranged=true else melee=true end
  end
 end
 if run_damage_mul==1 then add(pool,1) end
 if run_defense_mul==1 then add(pool,2) end
 if run_ranged_mul==1 and ranged then add(pool,3) end
 if run_melee_mul==1 and melee then add(pool,4) end
 if vitality_stacks==0 then add(pool,5) end
 if fortress_stacks==0 then add(pool,6) end
 if not second_wind_owned then add(pool,7) end
 if recovery_stacks==0 then add(pool,8) end
 reward_slots={#reward_units>0 and 0 or take_adv(pool),#reward_evos>0 and -1 or take_adv(pool),take_adv(pool)}
end

function open_reward_menu()
 music(-1)
 reward_menu,reward_view,reward_cursor=true,0,1
 srand(time()*1000)
 build_reward_units()
 build_reward_evos()
 build_reward_slots()
end

function apply_reward_advantage(id)
 if id==1 then run_damage_mul=1.75
 elseif id==2 then run_defense_mul=.6
 elseif id==3 then run_ranged_mul=1.75
 elseif id==4 then run_melee_mul=1.75
 elseif id==5 then
  vitality_stacks=1
  foreach(party,boost_vitality)
 elseif id==6 then fortress_stacks=1
 elseif id==7 then
  second_wind_owned=true
  second_wind_ready=true
 else recovery_stacks=1 end
end

function update_reward_menu()
 local n=reward_view==1 and #reward_units or reward_view==2 and #reward_evos or 3
 if btnp(0) then reward_cursor=max(1,reward_cursor-1)
 elseif btnp(1) then reward_cursor=min(n,reward_cursor+1) end
 if btnp(4) and reward_view!=0 then
  reward_view,reward_cursor=0,1
  return
 end
 if not btnp(5) then return end
 if reward_view==0 then
  local slot=reward_slots[reward_cursor]
  if slot==0 then reward_view=1 reward_cursor=1
  elseif slot==-1 then reward_view=2 reward_cursor=1
  else apply_reward_advantage(slot) finish_reward() end
 elseif reward_view==1 then
  recruit_unit(reward_units[reward_cursor])
  finish_reward()
 else
  apply_evolution(reward_evos[reward_cursor])
  finish_reward()
 end
end

function apply_recovery()
 if recovery_stacks<=0 then return end
 for u in all(party) do
  if u.alive then
   u.hp=min(u.max_hp,u.hp+max(1,flr(u.max_hp*.3+0.5)))
  end
 end
end

function reset_room_rhythm()
 current_command,penalty_action,buffered_button,buffered_quality,warning,timing_streak=nil,false,nil,nil,false,0
 leave_fever()
 advance_blocked,advance_amount=false,16
 clear_input()
end

function start_room()
 camera_x,enemies,encounters,projectiles,encounter_index,encounter_active,door_open,door_anim,room_complete,party_rearrange_pending,party_rearrange_anchor_x=0,{},{},{},1,true,false,0,false,false,nil
 for u in all(party) do
  if u.alive then
   u.body_timer,u.body_dx,u.body_hit,u.weapon_timer,u.weapon_hit,u.wind_timer=0,0,false,0,false,0
  end
 end
 arrange_party(8)
 reset_room_rhythm()
 for i=1,4 do encounters[i]=spawn_encounter(i) end
 enemies=encounters[1]
 start_countin()
end

function finish_reward()
 reward_menu=false
 room+=1
 second_wind_ready=second_wind_owned
 start_room()
end

function living_count(list)
 local n=0
 for u in all(list) do
  if u.alive then n+=1 end
 end
 return n
end

function edge_unit(list,d)
 local best,score=nil,-9999
 for u in all(list) do
  local s=u.x*d
  if u.alive and s>score then best,score=u,s end
 end
 return best
end

function front_party_unit()
 return edge_unit(party,1)
end

function nearest_enemy()
 return edge_unit(enemies,-1)
end

function move_party(dx)
 for u in all(party) do
  if u.alive then u.x+=dx end
 end
end

function enemy_distance(e)
 local f=front_party_unit()
 if not f then return 9999 end
 return e.x-f.x-8
end

function front_offset(u,enemy)
 local f=enemy and nearest_enemy() or front_party_unit()
 if not f then return 0 end
 return max(0,enemy and u.x-f.x or f.x-u.x)
end

function projectile_reach(u,target,enemy)
 return (enemy and 48 or 56)+front_offset(u,enemy)+(target and front_offset(target,not enemy) or 0)
end

function make_enemy(x,id)
 local d=enemy_defs[id]
 local at=d[5]
 return {
  x=x,y=60,
  hp=d[1],alive=true,
  damage=d[2],move_distance=d[3],
  attack_beat=d[4],attack_type=at,
  preferred_range=d[6],sprite=d[7],
  projectile_style=d[8],tele_sprite=d[9],
  t4=id>=10,
  body_timer=0,body_dx=0,
  weapon_timer=0,
  alert=false,alert_timer=0
 }
end

function tier1_count()
 local r=rnd()
 return r<0.6 and 1 or r<0.95 and 2 or 3
end

function encounter_enemy_count(i)
 if room==1 and i<4 then return min(i,2) end
 return tier1_count()
end

function room2_tiers(i)
 if i==1 then return {2} end
 if i<4 then
  return rnd(2)<1 and {2,2} or {2,1,1}
 end
 local r=flr(rnd(3))
 return r==0 and {2,2,2}
  or r==1 and {2,2,1,1}
  or {2,1,1,1}
end

function room3_tiers(i)
 if i==1 then return {3} end
 if i<4 then
  return rnd(2)<1 and {3,3} or {3,2,2}
 end
 return {4}
end

function spawn_encounter(i)
 local g={}
 local x=encounter_x[i]
 local tiers={}
 if room==2 then
  tiers=room2_tiers(i)
 elseif room==3 then
  tiers=room3_tiers(i)
 else
  local count=encounter_enemy_count(i)
  for n=1,count do add(tiers,1) end
 end
 for n=1,#tiers do
  local id=(tiers[n]-1)*3+flr(rnd(3))+1
  add(g,make_enemy(x+(n-1)*12,id))
 end
 enemies=g
 prepare_enemy_formation()
 for e in all(g) do
  e.x=e.formation_target_x
  e.formation_active=false
  e.intent="idle"
 end
 return g
end

function update_encounter()
 if phase=="input" and not encounter_active
 and encounter_index<4 then
  encounter_index+=1
  enemies=encounters[encounter_index]
  encounter_active=true
 end
end

function sort_units_by_x(list)
 for i=2,#list do
  local u=list[i]
  local j=i-1
  while j>=1 and list[j].x>u.x do
   list[j+1]=list[j]
   j-=1
  end
  list[j+1]=u
 end
end

function prepare_enemy_formation()
 local alive={}
 for e in all(enemies) do
  e.formation_active,e.formation_start_x,e.formation_target_x=false,e.x,e.x
  if e.alive then add(alive,e) end
 end
 if #alive<=1 then return end
 sort_units_by_x(alive)
 local slots={}
 for e in all(alive) do add(slots,e.x) end
 local i=1
 for pass=1,2 do
  for e in all(alive) do
   if (pass==1)==(e.attack_type!="projectile") then
    local target=slots[i]
    e.formation_start_x,e.formation_target_x=e.x,target
    if target!=e.x then e.formation_active=true end
    i+=1
   end
  end
 end
end

function update_enemy_formation_step(e,b)
 if not e.formation_active then return end
 e.x=e.formation_start_x+
  (e.formation_target_x-e.formation_start_x)*b/4
 if b>=4 then
  e.x,e.formation_active=e.formation_target_x,false
 end
end

function enemy_future_x(e)
 return e.formation_active and
  e.formation_target_x or e.x
end

function trigger_enemy_alert(e,q)
 if not e.alert then e.alert_timer=q and -1 or 20 end
 e.alert=true
end

function alert_nearby_enemies(source,q)
 for e in all(enemies) do
  if e!=source and e.alive
  and abs(e.x-source.x)<=40 then
   trigger_enemy_alert(e,q)
   if e.intent=="idle" then e.intent="approach" end
  end
 end
end

function update_enemy_detection(e)
 if not e.alive then
  e.alert=false
  e.intent=nil
  return
 end
 if enemy_distance(e)<=40 then
  trigger_enemy_alert(e)
  alert_nearby_enemies(e)
 end
 if not e.alert then e.intent="idle" end
end

function choose_enemy_intent(e)
 if not e.alive then
  e.intent=nil
 elseif living_count(party)<=0 or not e.alert then
  e.intent="idle"
 elseif enemy_distance(e)>e.preferred_range then
  e.intent="approach"
 elseif e.t4 and e.intent!="telegraph" then
  e.intent="telegraph"
 else
  e.intent="attack"
 end
end

function planned_enemy_move(e,party_shift)
 if not e.alive
 or e.intent!="approach"
 or e.formation_active then
  return 0
 end
 local needed=enemy_distance(e)-
  party_shift-e.preferred_range
 if needed<=0 then return 0 end
 return min(needed,e.move_distance)
end

function allowed_enemy_step(e,requested)
 local allowed=requested
 for other in all(enemies) do
  if other!=e and other.alive
  and other.x<e.x then
   allowed=min(
    allowed,
    e.x-other.x-12
   )
  end
 end
 return max(0,allowed)
end

function party_sees_enemy()
 local e=nearest_enemy()
 return e and enemy_distance(e)<=56
end

function reveal_party()
 local e=nearest_enemy()
 if e and not e.alert then
  trigger_enemy_alert(e,true)
  alert_nearby_enemies(e,true)
 end
end

function allowed_advance_distance()
 local front=front_party_unit()
 if not front then return 0 end
 local e=nearest_enemy()
 local fast=not e or not e.alert and enemy_distance(e)>56
 for candidate=fast and 32 or 16,0,-2 do
  local fx=front.x+candidate
  if fx<=318 then
   local nearest=nil
   for e in all(enemies) do
    if e.alive then
     local ex=enemy_future_x(e)
     if not e.formation_active then
      ex-=planned_enemy_move(e,candidate)
     end
     local d=ex-fx-8
     if nearest==nil or d<nearest then nearest=d end
    end
   end
   if nearest==nil or nearest>=(fast and 56 or 8) then
    return candidate
   end
  end
 end
 return 0
end

function quality_from_ticks(d)
 d=abs(d)
 return d<=6 and "perfect" or d<=18 and "bueno" or "desfase"
end

function show_drum(button)
 if button==5 then
  sfx(60,2)
  pico_fx_timer=12
 else
  sfx(61,2)
  pon_fx_timer=12
 end
end

function accept_input(button,d)
 show_drum(button)
 if abs(d)>36 then
  return false
 end
 local q=quality_from_ticks(d)
 add(input,button)
 add(input_quality,q)
 input_code=input_code*10+button
 if #input==4 and command_map[input_code]
 and q=="perfect" and input_quality[1]==q
 and input_quality[2]==q and input_quality[3]==q then sfx(34,3) end
 input_index+=1
 return true
end

function try_input(button)
 if input_index>4 then return end
 accept_input(
  button,
  audio_tick-(input_index-1)*60
 )
end

function buffer_next(button)
 if buffered_button then return end
 local d=max(0,480-audio_tick)
 if d>48 then return end
 show_drum(button)
 buffered_button=button
 buffered_quality=quality_from_ticks(d)
end


function random_target(list)
 local target,count=nil,0
 for u in all(list) do
  if u.alive then
   count+=1
   if rnd(count)<1 then target=u end
  end
 end
 return target
end

function leave_fever()
 fever,fever_chain,fever_all_perfect,fever_bad_streak=false,0,true,0
end

function update_fever(valid)
 if fever then
  if not valid then
   leave_fever()
   return
  end
  if command_timing=="desfase" then
   fever_bad_streak+=1
   if fever_bad_streak>=2 then
    leave_fever()
   end
  else
   fever_bad_streak=0
  end
  return
 end

 if not valid
 or command_timing=="desfase" then
  fever_chain,fever_all_perfect=0,true
  return
 end

 if fever_chain>=6 or fever_all_perfect and fever_chain>=3 then
  fever,fever_chain,fever_all_perfect,fever_bad_streak=true,0,true,0
  return
 end
 fever_chain+=1
 fever_all_perfect=fever_all_perfect and command_timing=="perfect"
end

function party_damage(u)
 local m=run_damage_mul*(u.attack_type=="projectile" and run_ranged_mul or run_melee_mul)
 local d=flr(u.damage*m+0.5)
 return fever and flr(d*1.34+0.5) or d
end

function finish_input()
 current_command=nil
 if #input==4 then current_command=command_map[input_code] end
 local valid=current_command

 command_timing="perfect"
 for q in all(input_quality) do
  if q=="desfase" then command_timing="desfase"
  elseif q=="bueno"
  and command_timing=="perfect" then
   command_timing="bueno"
  end
 end

 update_fever(valid)

 if valid then
  if command_timing=="desfase" then
   timing_streak+=1
  else
   timing_streak=0
  end
 end

 if valid and timing_streak>=3 then
  penalty_action=true
  current_command=nil
  warning=false
  return
 end

 penalty_action=false
 warning=valid and timing_streak==2

end

function prepare_action()
 advance_amount,advance_blocked=0,false
 for u in all(party) do
  if u.alive then
   u.retreat_x=u.x
   if current_command=="attack" and u.attack_type=="projectile" then
    u.aim=random_target(enemies)
    u.aim_x=u.aim and u.aim.x+u.aim.body_dx
   end
  end
 end

 if current_command=="advance" then
  advance_amount=allowed_advance_distance()
  advance_blocked=advance_amount<=0
 end

 local shift=current_command=="advance"
  and not advance_blocked
  and advance_amount or 0
 for e in all(enemies) do
  e.move_remaining=planned_enemy_move(e,shift)
  if e.alive and e.intent=="attack" and e.attack_type=="projectile" then
   e.aim=random_target(party)
   e.aim_x=e.aim and e.aim.x+e.aim.body_dx
  end
 end
end

function start_party_attack(u)
 if not u.alive or living_count(enemies)<=0 then return end
 local e=nearest_enemy()
 local l=min(16,max(0,enemy_distance(e)-8))
 if u.attack_type=="body" then
  u.body_dx=front_offset(u,false)+9+l
  u.body_timer,u.body_hit=6,false
 elseif u.attack_type=="weapon" then
  u.body_dx=l
  u.weapon_reach=8+front_offset(u,false)
  u.weapon_timer,u.weapon_hit=6,false
 else
  spawn_projectile("party",party_damage(u),u.projectile_style,u.aim or random_target(enemies),u)
 end
end

function attack_x(u,reach,d)
 return d==1 and u.x+u.body_dx+8 or u.x-reach-1
end

function enemy_attack(e)
 if not e.alive or not e.alert then return end
 if e.attack_type=="body" then
  e.body_dx=-9
  e.body_timer,e.body_hit=6,false
 elseif e.attack_type=="melee" then
  e.weapon_timer,e.weapon_hit=6,false
 else
  spawn_projectile(
   "enemy",e.damage,
   e.projectile_style,
   e.aim or random_target(party),e
  )
 end
end

function execute_party_beat(b)
 if current_command=="advance" then
  if not advance_blocked then
   move_party(advance_amount/4)
  end
 elseif current_command=="retreat" then
  if b<=2 then move_party(-4) end
 elseif current_command=="attack" then
  if party_sees_enemy() then
   if b==1 then reveal_party() end
   for u in all(party) do
    if u.alive and (b==u.attack_beat or u.evolution=="TROMP." and b>2) then
     start_party_attack(u)
    end
   end
  end
 end
end

function execute_enemy_beat(b)
 local order={}
 for e in all(enemies) do
  if e.alive then add(order,e) end
 end
 sort_units_by_x(order)

 for e in all(order) do
  if e.formation_active then
   update_enemy_formation_step(e,b)
  elseif e.intent=="approach"
  and e.move_remaining>0 then
   local step=min(e.move_distance/4,e.move_remaining)
   step=allowed_enemy_step(e,step)
   e.x-=step
   e.move_remaining-=step
  end
 end

 for e in all(enemies) do
  if e.alive and e.intent=="attack"
  and not e.attack_done
  and b>=e.attack_beat then
   enemy_attack(e)
   e.attack_done=true
  end
 end
end

function execute_action_beat(b)
 execute_party_beat(b)
 execute_enemy_beat(b)
end

function finish_action()
 if current_command=="retreat" then
  for u in all(party) do
   if u.alive then u.x=u.retreat_x end
  end
 end

 if party_rearrange_pending and living_count(party)>0 then
  arrange_party(party_rearrange_anchor_x)
  party_rearrange_pending,party_rearrange_anchor_x=false,nil
 end
 if penalty_action then
  timing_streak,warning,penalty_action=0,false,false
 end
 current_command,advance_amount,advance_blocked=nil,0,false

 for e in all(enemies) do
  if e.alive and e.formation_active then
   e.x=e.formation_target_x
   e.formation_active=false
  end
  update_enemy_detection(e)
  choose_enemy_intent(e)
  e.attack_done,e.move_remaining=false,0
 end
 prepare_enemy_formation()
end

function begin_input()
 clear_input()
 if buffered_button then
  add(input,buffered_button)
  add(input_quality,buffered_quality)
  input_code=buffered_button
  input_index=2
  buffered_button,buffered_quality=nil,nil
 end
end

function spawn_projectile(owner,damage,style,target,source)
 if not target or not source or not source.alive then return end
 local adir=owner=="party" and 1 or -1
 local sx=adir==1 and source.x+8 or source.x-1
 local sy=source.y+(owner=="party" and source.name=="PAN" and 1 or 3)
 if owner=="party" and source.evolution=="MAGO" then sx,sy=source.x+10,source.y-3
 elseif owner=="party" and source.evolution=="TROMP." then sx,sy=source.x+11,source.y+6
 elseif owner=="enemy" and source.sprite==228 then
  sx,sy=source.x-3,source.y-3
 elseif owner=="enemy" and source.sprite==139 then
  sx,sy=source.x+12,source.y-11
 elseif style=="heavy" then sx+=15
 end
 local ax=source.aim_x or target.x+target.body_dx
 local ay=target.y
 local distance=adir*(ax-source.x)-8
 local range=projectile_reach(
  source,target,owner!="party"
 )
 local tx,ty
 if distance<=range then
  tx=ax+(style=="heavy" and -2 or adir==1 and 3 or 4)
  ty=ay+3
 else
  tx=sx+adir*range
  ty=source.y+3
  distance=range
 end
 distance=abs(distance)
 local duration=mid(
  12,
  20,
  12+flr(distance/8)
 )
 local arc=mid(
  10,
  22,
  6+flr(distance/4)
 )
 add(projectiles,{
  owner=owner,damage=damage,style=style,
  sx=sx,sy=sy,x=sx,y=sy,tx=tx,ty=ty,
  t=0,duration=duration,arc_height=arc
 })
end

function rect_overlap(ax,ay,aw,ah,bx,by,bw,bh)
 return ax<bx+bw and bx<ax+aw
 and ay<by+bh and by<ay+ah
end

function damage_enemy(e,amount)
 if not e or not e.alive then return end
 for a in all(enemies) do
  if a.alert_timer<0 then a.alert_timer=20 end
 end
 e.hp-=amount
 if e.hp<=0 then
  e.hp,e.alive,e.intent=0,false,nil
  if living_count(enemies)<=0 then
   encounter_active=false
   apply_recovery()
   if encounter_index>=4 then door_open=true end
  end
 end
end

function damage_party_unit(u,amount)
 if not u or not u.alive then return end
 amount-=u.armor
 amount*=run_defense_mul
 if current_command=="defend" then
  local mult=fever and 0.4 or 0.5
  if fortress_stacks>0 then mult*=.5 end
  amount*=mult
 end
 amount=flr(amount+0.5)
 u.hp-=amount
 if u.hp<=0 then
  if second_wind_ready then
   u.hp=max(1,flr(u.max_hp*.5+0.5))
   u.wind_timer=30
   second_wind_ready=false
   return
  end
  local f=front_party_unit()
  local anchor=f and (current_command=="retreat" and f.retreat_x or f.x) or u.x
  u.hp,u.alive,u.body_timer,u.body_dx,u.weapon_timer=0,false,0,0,0
  if living_count(party)<=0 then
   music(-1)
   game_over,party_rearrange_pending,party_rearrange_anchor_x=true,false,nil
  else
   party_rearrange_pending=true
   if not party_rearrange_anchor_x or anchor>party_rearrange_anchor_x then party_rearrange_anchor_x=anchor end
  end
 end
end

function attack_hit(a,b,enemy)
 if enemy then damage_party_unit(b,a.damage)
 else damage_enemy(b,party_damage(a)) end
end

function update_attackers(list,targets,enemy)
 for a in all(list) do
  local active=enemy or a.alive
  if active and a.body_timer>0 then
   if not a.body_hit then
    local rider=not enemy and a.evolution=="JINETE"
    for b in all(targets) do
     if b.alive and rect_overlap(
      a.x+a.body_dx,a.y,rider and 20 or 8,8,
      b.x+b.body_dx,b.y,8,8
     ) then
      a.body_hit=true
      attack_hit(a,b,enemy)
      if not rider then break end
     end
    end
   end
   a.body_timer-=1
   if a.body_timer<=0 then a.body_dx=0 end
  end

  if active and a.weapon_timer>0 then
   local reach=enemy and 8 or a.weapon_reach
   local wx=attack_x(a,reach,enemy and -1 or 1)
   if not a.weapon_hit then
    for b in all(targets) do
     if b.alive and rect_overlap(
      wx,a.y+2,reach+1,4,
      b.x+b.body_dx,b.y,8,8
     ) then
      a.weapon_hit=true
      attack_hit(a,b,enemy)
      break
     end
    end
   end
   a.weapon_timer-=1
   if a.weapon_timer<=0 then a.body_dx=0 end
  end
 end
end

function update_projectiles()
 for i=#projectiles,1,-1 do
  local p=projectiles[i]
  p.t=min(1,p.t+1/p.duration)
  local t=p.t
  p.x=p.sx+(p.tx-p.sx)*t
  p.y=p.sy+(p.ty-p.sy)*t-
   4*p.arc_height*t*(1-t)
  local party_hit=p.owner=="party"
  local list=party_hit and enemies or party
  local hit=false
  for u in all(list) do
   if u.alive and rect_overlap(
    p.x-2,p.y-1,5,3,
    u.x+u.body_dx,u.y,8,8
   ) then
    if party_hit then damage_enemy(u,p.damage)
    else damage_party_unit(u,p.damage) end
    hit=true
    break
   end
  end
  if hit or t>=1 then deli(projectiles,i) end
 end
end

function update_door()
 if door_open and door_anim<1 then
  door_anim=min(1,door_anim+0.08)
 end
 if door_open and door_anim>=1 and not room_complete and not reward_menu then
  local f=front_party_unit()
  if f and f.x+7>=325 then
   if room<3 then
    open_reward_menu()
   else
    room_complete=true
    music(-1)
   end
  end
 end
end

function sync_music()
 if not stat(57) then return end
 local t=stat(56)
 if t<0 then return end
 t%=480

 local played=stat(55)
 if played>=0 and played!=last_played then
  if last_played then
   song_pos=played%#seq+1
   setpat(1-(played%2),seqat(song_pos+1))
  end
  last_played=played
 end
 if title then return end

 local newphase,newbeat,slot=t<240 and "input" or "action",flr((t%240)/60)+1,flr(t/60)

 if newphase!=phase then
  if newphase=="action" then
   finish_input()
   prepare_action()
  else
   finish_action()
   begin_input()
  end
 end

 audio_tick,phase,beat=t,newphase,newbeat

 if slot!=last_beat_slot then
  beat_flash=4
  if phase=="action" then
   execute_action_beat(beat)
   if warning then sfx(35,3) end
  end
  last_beat_slot=slot
 end
end

function handle_buttons()
 if game_over or room_complete then return end
 if phase=="input" then
  if btnp(5) then try_input(5) end
  if btnp(4) then try_input(4) end
 elseif audio_tick>=480-48 then
  if btnp(5) then buffer_next(5)
  elseif btnp(4) then buffer_next(4) end
 end
end

function draw_ridge(p,col)
 pal(6,col,1)
 for i=1,#p-1 do
  local x=(i-1)*8
  local a=p[i]
  local b=p[i+1]
  for dx=0,7 do
   local h=flr(a+(b-a)*dx/8)
   line(x+dx,67-h,x+dx,67,6)
  end
 end
 pal()
end

function draw_hole(x,y)
 circfill(x,y,15,2)
 circfill(x+1,y,11,13)
 circfill(x+2,y-1,7,14)
 pset(x+1,y-3,7)
 pset(x+3,y-2,7)
end

function draw_background()
 rectfill(0,0,343,67,4)
 draw_ridge(bg_far,13)
 draw_ridge(bg_mid,12)
 draw_ridge(bg_near,8)
 draw_hole(63,37)
 draw_hole(205,34)
 for i=1,#bg_top do
  local x=(i-1)*8
  local h=bg_top[i]
  rectfill(x,0,x+7,h-4,0)
  for j=1,3 do
   rectfill(x+j,h-5+2*j,x+7-j,h-4+2*j,0)
  end
  pset(x+3,h+3,0)
 end
 for i=1,#bg_floor do
  local x=(i-1)*8
  local h=bg_floor[i]
  rectfill(x,68-h,x+7,67,0)
  if h>=5 then
   rectfill(x+2,66-h,x+5,67-h,0)
   pset(x+3,65-h,0)
  end
 end
end

function draw_door()
 pal(1,0)
 if door_anim>0 then pal(4,0) end
 sspr(40,56,20,49,324,19,20,49)
 pal()
end

function draw_units(list,enemy)
 for u in all(list) do
  if u.alive then
   local x=u.x+u.body_dx
   if enemy and u.t4 then
    local tele=u.intent=="telegraph" or u.intent=="attack" and (phase=="input" or phase=="action" and beat<u.attack_beat)
    local s=tele and u.tele_sprite or u.sprite
    local w=u.sprite==12 and 32 or 24
    sspr((s%16)*8,flr(s/16)*8,w,24,x+4-w/2,u.y-16)
    if u.sprite==6 then
     if tele then sspr(64,120,16,8,x-11,u.y-21)
     else sspr(48,120,16,8,x-16,u.y-4) end
    end
   else
    if not enemy and u.evolution=="JINETE" then
     spr(66,x-4,u.y-8,2,2,true)
     spr(86,x-6,u.y-11,2,1)
     spr(94,x-6,u.y-3,2,1)
     sspr(64,24,24,8,x-2,u.y-5,26,8)
    else spr(u.sprite,x-4,u.y-8,2,2) end
   end
   if enemy and u.alert then
    local ay=u.y-12
    if phase=="input" and not u.t4 and u.intent=="attack" then
     if beat_flash>0 then ay-=1 end
     draw_shadow_text("!",u.x+1,ay,8)
    elseif u.alert_timer>0 then
     spr(232,u.x,u.y-(u.t4 and 25 or 17))
    end
   end
  end
 end
end

function spear_active(s)
 for p in all(projectiles) do
  if p.owner=="party" and p.style==s then return true end
 end
 return false
end

function draw_party_held_items()
 for u in all(party) do
  if u.alive and not spear_active(u.projectile_style) then
   if u.projectile_style=="spear" then sspr(104,48,11,5,u.x+u.body_dx-1,u.y,11,5)
   elseif u.projectile_style=="heavy" then sspr(64,24,24,8,u.x+u.body_dx-2,u.y-1)
   end
  end
 end
end

function draw_tin_layer(front)
 for u in all(party) do
  if u.alive and u.name=="TIN" then
   if front then
    spr(u.sprite,u.x+u.body_dx-4,u.y-8,2,2)
    if u.evolution=="BERSERK" then
     local ax=u.x+u.body_dx-1
     local ay=u.y-1
     if u.weapon_timer>0 then ax+=4 ay-=1 end
     sspr(88,24,16,8,ax,ay)
    end
   elseif not u.evolution then
    local a=u.weapon_timer>0
    spr(a and 79 or 78,u.x+u.body_dx+7,u.y+(a and -1 or -4))
   end
  end
 end
end

function draw_weapons(list,enemy)
 for u in all(list) do
  if u.alive and u.weapon_timer>0 and (enemy or u.name!="TIN") and (not enemy or u.sprite!=6) then
   local reach=enemy and 8 or u.weapon_reach
   local x=attack_x(u,reach,enemy and -1 or 1)
   if enemy and u.sprite==64 then
    sspr(0,16,16,16,u.x-15,u.y-7)
   elseif enemy and u.sprite==224 then
    sspr(32,16,16,16,u.x-16,u.y-7)
   elseif enemy and u.sprite==234 then
    sspr(64,56,16,16,u.x-16,u.y-9)
   else
    rectfill(x,u.y+2,x+reach,u.y+5,10)
   end
  end
 end
end

function draw_projectile(p,d)
 if p.style=="arrow" then
  sspr(120,48,7,3,p.x-3,p.y-1,7,3,d<0)
 elseif p.style=="magic" then spr(231,p.x-4,p.y-4)
 elseif p.style=="note" then spr(61,p.x-4,p.y-4)
 elseif p.style=="heavy" then sspr(64,24,24,8,p.x-21,p.y-4,24,8,d<0)
 else sspr(104,56,7,3,p.x-3,p.y-1,7,3,d<0) end
end

function draw_bubble(x,y,r,col)
 rectfill(x+4,y,r-3,y+10,col)
 rectfill(x+1,y+2,r-1,y+8,col)
 rectfill(x+9,y-2,r-8,y+12,col)
end

function draw_count_bubble(cx,y,w,col)
 local x=flr(cx-w/2)
 local r=x+w-1
 rectfill(x+4,y,r-4,y+10,col)
 rectfill(x+1,y+2,r-1,y+8,col)
 rectfill(x,y+4,r,y+6,col)
end

function draw_combo_indicator()
 local combo=fever_chain-1
 if fever or combo<=0 then return end
 local x=6
 local y=27
 local r=x+51
 draw_bubble(x,y,r,0)
 print(combo.." COMBO!",x+8,y+3,7)
end

function draw_fever_indicator()
 if not fever then return end
 local x=6
 local y=27
 local r=x+49
 draw_bubble(x,y,r,8)
 rectfill(x+7,y+1,r-6,y+9,9)
 rectfill(x+11,y-1,r-11,y+11,9)
 if beat_flash>0 then
  pset(x+3,y,10)
  pset(x+6,y-2,10)
  pset(r-2,y+1,10)
  pset(r,y+4,10)
 end
 print("FEVER!",x+9,y+3,10)
end

function draw_shadow_text(t,x,y,c)
 print(t,x-1,y,0)
 print(t,x+1,y,0)
 print(t,x,y-1,0)
 print(t,x,y+1,0)
 print(t,x,y,c)
end

function draw_input_fx_side(timer,x,y,label,s)
 if timer<=0 then return end
 if timer<4 and timer%2==1 then return end
 y-=flr((12-timer)/2)
 draw_shadow_text(
  label,x+12-#label*2,y,7
 )
 spr(s,x,y+7,3,2)
end

function draw_input_fx()
 pal(5,0)
 draw_input_fx_side(
  pico_fx_timer,7,38,"PICO",0
 )
 draw_input_fx_side(
  pon_fx_timer,99,38,"PON",3
 )
 pal()
end

function draw_hp_bar(x,y,w,h,hp,max_hp)
 rectfill(x-1,y-1,x+w,y+h,0)
 rectfill(x,y,x+w-1,y+h-1,1)
 local pct=max_hp>0 and mid(0,hp/max_hp,1) or 0
 local fill=flr(w*pct+0.5)
 local c=pct>=.75 and 11 or pct>.25 and 10 or 8
 if fill>0 then rectfill(x,y,x+fill-1,y+h-1,c) end
 rect(x-1,y-1,x+w,y+h,6)
end


function draw_second_wind_fx()
 for u in all(party) do
  if u.wind_timer>0 then
   spr(107,u.x+u.body_dx-1,u.y-20-flr((30-u.wind_timer)/6))
  end
 end
end

function draw_party_hud()
 local shown=0
 for name in all(split"PAN,KON,TIN") do
  for u in all(party) do
   if u.alive and u.name==name then
    local x=15+shown*22
    local y=15
    draw_hp_bar(x-10,y-11,20,3,u.hp,u.max_hp)
    circfill(x,y,9,7)
    circ(x,y,9,5)
    draw_card_unit_center(x,y,u.evolution or name,true)
    shown+=1
   end
  end
 end
end

function draw_perk_hud()
 local a={run_damage_mul>1,run_defense_mul<1,run_ranged_mul>1,run_melee_mul>1,vitality_stacks>0,fortress_stacks>0,second_wind_owned,recovery_stacks>0}
 for i=1,8 do
  if a[i] then spr(adv_icons[i],94+(i-1)%4*8,5+flr((i-1)/4)*8) end
 end
end

function card_x(i,n)
 return n==1 and 43 or n==2 and 20+(i-1)*46 or 1+(i-1)*42
end

function card_center_text(t,x,y,col)
 print(t,x+21-#t*2,y,col)
end

function draw_card_title(title,x,y)
 local p=split(title,"|",false)
 if #p>1 then
  card_center_text(p[1],x,y+4,7)
  card_center_text(p[2],x,y+11,7)
 else
  card_center_text(title,x,y+7,7)
 end
end

function draw_card_unit_center(cx,cy,name,hud)
 local d=evo_defs[name]
 local s=d and d[5] or name=="PAN" and 74 or name=="TIN" and 76 or 72
 local ax,ay=cx-8,cy-8
 if name=="JINETE" then
  spr(66,cx-8,cy-4,2,2,true)
  spr(86,cx-10,cy-7,2,1)
  spr(94,cx-10,cy+1,2,1)
  sspr(64,24,24,8,cx-6,cy-1,26,8)
  return
 end
 if name=="LUCHADOR" then ax+=1 end
 if hud then
  if name=="PAN" or name=="TROMP." or name=="KON" then ax+=1
  elseif name=="TIN" then ax-=1
  elseif name=="PESADO" then ax-=4
  elseif name=="BERSERK" then ax-=2 end
 end
 spr(s,ax,ay,2,2)
 if name=="TIN" then spr(78,ax+11,ay+4)
 elseif name=="KON" then sspr(104,48,11,5,ax+3,ay+8,11,5)
 elseif name=="PESADO" then sspr(64,24,24,8,ax+2,ay+7)
 elseif name=="BERSERK" then sspr(88,24,16,8,ax+3,ay+7) end
end

function draw_reward_card(x,y,title,a,b,icon,sel)
 sspr(0,48,40,60,x,y,42,68)
 if sel then rect(x,y,x+41,y+67,10) end
 draw_card_title(title,x,y)
 rectfill(x+5,y+20,x+36,y+47,0)
 if icon then spr(icon,x+17,y+30) end
 rectfill(x+3,y+52,x+38,y+65,7)
 card_center_text(a,x,y+53,1)
 card_center_text(b,x,y+60,1)
end

function draw_party_card(x,y,name,title,a,b,sel)
 draw_reward_card(x,y,title,a,b,nil,sel)
 draw_card_unit_center(x+21,y+34,name)
end

function draw_reward_menu()
 camera()
 cls(0)
 local title=reward_titles[reward_view+1]
 print(title,64-#title*2,7,7)
 if reward_view==0 then
  for i=1,3 do
   local x,slot=card_x(i,3),reward_slots[i]
   if slot==0 then
    draw_reward_card(x,20,"UNIT","NEW","ALLY",nil,i==reward_cursor)
    draw_card_unit_center(x+12,54,"PAN")
    draw_card_unit_center(x+27,54,"TIN")
   elseif slot==-1 then
    draw_reward_card(x,20,"EVOLVE","CHANGE","CLASS",nil,i==reward_cursor)
    draw_card_unit_center(x+21,54,"KON")
   else
    local t=adv_names[slot]
    if t=="SECOND" then t="SECOND|WIND" end
    draw_reward_card(x,20,t,adv_a[slot],adv_b[slot],adv_icons[slot],i==reward_cursor)
   end
  end
 elseif reward_view==1 then
  local n=#reward_units
  for i=1,n do
   local name=reward_units[i]
   draw_party_card(card_x(i,n),20,name,name,name=="PAN" and "HP28" or "HP56","DMG8",i==reward_cursor)
  end
 else
  local n=#reward_evos
  for i=1,n do
   local e=reward_evos[i]
   local d=evo_defs[e.name]
   draw_party_card(card_x(i,n),20,e.name,e.unit.name.."|"..(evo_en[e.name] or e.name),"HP"..d[1],"DMG"..d[2]..(e.name=="TROMP." and "X3" or ""),i==reward_cursor)
  end
 end
 local ctl=pico_chr.." SELECT  "..pon_chr.." BACK"
 print(ctl,64-#ctl*2,109,6)
end

function start_run()
 room,reward_menu=1,false
 run_damage_mul,run_defense_mul,run_ranged_mul,run_melee_mul=1,1,1,1
 vitality_stacks,fortress_stacks,recovery_stacks=0,0,0
 second_wind_owned,second_wind_ready,game_over=false,false,false
 party={}
 add_party_member(make_party_unit("KON",40,10,"projectile","spear",72))
 start_room()
end

function _init()
 title=true
 start_delay=0
 start_music()
end

function draw_title()
 camera()
 cls(0)
 print("\^w\^tPICOP",28,20,7)
 pal(5,0)
 spr(3,67,20,3,2)
 pal()
 print("\^w\^tN",93,20,7)
 draw_card_unit_center(24,57,"PAN")
 draw_card_unit_center(64,57,"KON")
 draw_card_unit_center(104,57,"TIN")
 print("PRESS",20,88,7)
 pal(5,0)
 draw_shadow_text("PICO",50,77,7)
 spr(0,45,84,3,2)
 pal()
 print("TO START",74,88,7)
 local t="X=PICO  O=PON"
 print(t,64-#t*2,108,6)
end

function _update()
 if title then
  if start_delay>0 then
   start_delay-=1
   if start_delay==0 then
    title=false
    start_run()
   end
  else
   sync_music()
   if btnp(5) then
    music(-1)
    sfx(60,2)
    start_delay=24
   end
  end
  return
 end
 if reward_menu then
  update_reward_menu()
  return
 end
 if game_over then
  if btnp(5) then start_run() end
  return
 end
 if room_complete then
  if btnp(5) then start_run() end
  return
 end
 if count_in then
  update_countin()
 elseif not room_complete then
  sync_music()
  handle_buttons()
  update_attackers(party,enemies,false)
  update_attackers(enemies,party,true)
  update_projectiles()
  update_encounter()
  update_door()
 end

 for e in all(enemies) do
  if e.alert_timer>0 then e.alert_timer-=1 end
 end
 for u in all(party) do
  if u.wind_timer>0 then u.wind_timer-=1 end
 end

 local f=front_party_unit()
 if f then
  camera_x=flr(
   mid(0,f.x-40,216)/2
  )*2
 end

 if pico_fx_timer>0 then pico_fx_timer-=1 end
 if pon_fx_timer>0 then pon_fx_timer-=1 end
 if beat_flash>0 then beat_flash-=1 end
end

function _draw()
 if title then
  if start_delay>0 then cls(0)
  else draw_title() end
  return
 end
 if reward_menu then
  draw_reward_menu()
  return
 end
 if game_over then
  camera()
  cls(0)
  print("GAME OVER",46,50,8)
  print(pico_chr.." RETRY",45,66,7)
  return
 end
 if room_complete then
  camera()
  cls(0)
  print("THANKS FOR PLAYING",28,46,7)
  print("THE BETA!",48,55,7)
  print(pico_chr.." RETRY",45,72,7)
  return
 end
 cls(1)
 camera(camera_x,0)
 draw_background()
 draw_door()
 rectfill(0,68,343,127,0)
 draw_tin_layer(false)
 draw_units(party,false)
 draw_party_held_items()
 draw_tin_layer(true)
 for g in all(encounters) do
  draw_weapons(g,true)
  draw_units(g,true)
 end
 draw_weapons(party,false)
 for p in all(projectiles) do
  draw_projectile(
   p,p.owner=="enemy" and -1 or 1
  )
 end
 draw_second_wind_fx()

 camera()
 draw_party_hud()
 draw_perk_hud()
 local labels=split"ADVANCE:,RETREAT:,ATTACK:,DEFEND:"
 local p,o=pico_chr,pon_chr
 local seqs={p.." "..p.." "..p.." "..o,o.." "..p.." "..o.." "..p,o.." "..o.." "..p.." "..o,p.." "..o.." "..p.." "..o}
 for i=1,4 do
  print(labels[i],20,65+i*12,7)
  print(seqs[i],64,65+i*12,7)
 end

 if count_in then
  local t=count_step<4 and 4-count_step or "GO!"
  t=tostr(t)
  local cx=64
  local w=#t==1 and 20 or 28
  draw_count_bubble(cx,50,w,0)
  draw_shadow_text(t,cx-flr(#t*2),53,count_step==4 and 10 or 7)
 end

 if beat_flash>0 then
  local c=warning and phase=="action" and 8 or 7
  rectfill(1,1,126,2,c)
  rectfill(1,125,126,126,c)
  rectfill(1,1,2,126,c)
  rectfill(125,1,126,126,c)
 else
  rect(1,1,126,126,5)
 end
 draw_combo_indicator()
 draw_fever_indicator()
 draw_input_fx()
end