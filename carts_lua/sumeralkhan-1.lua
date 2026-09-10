-- sumer
-- by alkhan

bal={}

function balance_doc()
 return {
  name="doc",
  start_pop=50, start_grain=120, start_land=18,
  max_land=48, worker_share=0.6,
  base_yield=5, seed_cost=2, fields_per_farmer=1,
  -- ration: grain per head, population effect low/high, stability step
  rations={
   {name="starve", rate=0.75, lo=-0.30, hi=-0.15, stab=-2},
   {name="low",    rate=1.5,  lo=-0.08, hi=-0.03, stab=-1},
   {name="normal", rate=2,    lo=0,     hi=0.04,  stab=0},
   {name="feast",  rate=2.5,  lo=0.03,  hi=0.08,  stab=1}
  },
  spoilage=0.02,
  clear_enabled=false, clear_max=0, clear_grain=0, clear_workers=0,
  artisan_year=5,
  tech_cost={15,35,60,90},
  event_chance=0.35,
  stability_drift=0,
  good_harvest=1.2,   -- harvest per head above which stability rises
  famine_stability=-1,
  rebel_years=2,
  years=12,
  score={pop=2,grain=1,land=5,tech=50,stability=20},
  grain_cap=32000,
  ranks={{250,"the forgotten king"},{500,"the survivor"},{750,"the builder"},
         {1000,"the great king"},{32000,"king of sumer"}}
 }
end

-- One number differs from the document, and it is forced by arithmetic rather
-- than taste: a field returning 5 nets 3 after seed, so 0.6*pop farmers can
-- never net the 2*pop a normal ration eats, at any population and any amount of
-- land. Raising the yield to 10 lifts that ceiling while leaving the opening
-- year short of grain, which is where the choice between eating and sowing
-- actually lives.
--
-- Clearing land is added because the MVP excludes trade and land purchase, so
-- without it the city has no way to grow and the game is a managed decline.
-- Stability drift is added because the document gives it no way back to calm.
function balance_tuned()
 local b=balance_doc()
 b.name="tuned"
 b.base_yield=10
 b.clear_enabled=true
 b.clear_max=3
 b.clear_grain=10
 b.clear_workers=3
 b.stability_drift=1
 -- The document scores a reign mostly on the grain left in the store, which
 -- pays the player to hoard and punishes the one strategy that grows the city.
 -- Measured: under the document's weights the hoarding line scored 1136 against
 -- 1013 for the growing one; with these weights, and no economic constant
 -- touched, that order reverses. See BALANCE.md.
 b.score={pop=6,grain=1,land=8,tech=50,stability=20}
 b.grain_cap=200
 -- Ranks calibrated against tools/balance.py rather than guessed.
 b.ranks={{350,"the forgotten king"},{600,"the survivor"},{850,"the builder"},
          {1100,"the great king"},{32000,"king of sumer"}}
 return b
end

weather_kinds={
 {name="excellent", mod=1.4},
 {name="good",      mod=1.2},
 {name="normal",    mod=1},
 {name="poor",      mod=0.8},
 {name="drought",   mod=0.55},
 {name="flood",     mod=0.65}
}

-- An omen is shown before planning and shifts the weather draw without fixing
-- it, so the warning is information rather than a promise (design doc s15/s45).
-- Weights index weather_kinds.
omens={
 {name="none",     risk="",       weights={1,3,6,3,1,1}},
 {name="low_river",risk="drought", weights={0,1,4,4,6,1}},
 {name="high_river",risk="flood",  weights={1,2,4,3,1,5}},
 {name="mild",     risk="calm",   weights={3,5,6,1,0,1}}
}

techs={
 {name="granary",   note="stores stop spoiling"},
 {name="plough",    note="every field yields more"},
 {name="irrigation",note="drought bites less"},
 {name="labor",     note="a farmer works two fields"}
}
-- SUMER rules. no drawing, no input, no globals beyond g and the balance table,
-- so tools/test.py and tools/balance.py can run the whole game headless.

function ceil(x) return -flr(-x) end

function new_game(seed,b)
 bal=b or balance_tuned()
 srand(seed or 1)
 g={
  seed=seed or 1,
  year=1,
  pop=bal.start_pop,
  grain=bal.start_grain,
  land=bal.start_land,
  craft=0,
  tech=0,
  stability=0,
  angry_years=0,
  cleared=0,
  over=false,
  ending="",
  ledger={},
  plan={ration=3,fields=0,clear=0,artisans=0}
 }
 roll_omen()
 clamp_plan()
 return g
end

function workers() return flr(g.pop*bal.worker_share) end
function fields_per_farmer() return g.tech>=4 and 2 or bal.fields_per_farmer end
function has_tech(n) return g.tech>=n end

function ration() return bal.rations[g.plan.ration] end
function food_cost() return flr(g.pop*ration().rate) end
-- A city can be too poor even for the starving ration. The design document does
-- not cover that case; the store simply empties and the shortfall is felt in the
-- population, so every downstream sum stays non-negative.
function food_spend() return min(food_cost(),g.grain) end
function seed_cost() return g.plan.fields*bal.seed_cost end
function clear_cost() return g.plan.clear*bal.clear_grain end
function reserve() return g.grain-food_spend()-seed_cost()-clear_cost() end

function farmers_needed() return ceil(g.plan.fields/fields_per_farmer()) end
function workers_used() return farmers_needed()+g.plan.clear*bal.clear_workers+g.plan.artisans end

-- Limits are computed in the order the planning screen presents them, so each
-- knob is bounded by what the ones above it already spent. The UI can never
-- offer an impossible distribution (design doc s12/s18).
function limit_fields()
 local grain_left=g.grain-food_spend()
 return max(0,min(min(g.land,workers()*fields_per_farmer()),flr(grain_left/bal.seed_cost)))
end

function limit_clear()
 if not bal.clear_enabled or g.land>=bal.max_land then return 0 end
 local grain_left=g.grain-food_spend()-seed_cost()
 local hands=workers()-farmers_needed()
 return max(0,min(min(bal.clear_max,bal.max_land-g.land),
  min(flr(grain_left/bal.clear_grain),flr(hands/bal.clear_workers))))
end

function limit_artisans()
 if g.year<bal.artisan_year then return 0 end
 return max(0,workers()-farmers_needed()-g.plan.clear*bal.clear_workers)
end

function clamp_plan()
 local p=g.plan
 p.ration=mid(1,p.ration,#bal.rations)
 -- drop to the richest ration the store can actually pay for
 while p.ration>1 and flr(g.pop*bal.rations[p.ration].rate)>g.grain do p.ration-=1 end
 p.fields=mid(0,p.fields,limit_fields())
 p.clear=mid(0,p.clear,limit_clear())
 p.artisans=mid(0,p.artisans,limit_artisans())
end

-- omens and weather --------------------------------------------------------

function roll_omen()
 g.omen=omens[1+flr(rnd(#omens))]
end

function roll_weather()
 local w=g.omen.weights
 local total=0
 for i=1,#w do total+=w[i] end
 local pick=rnd(total)
 local acc=0
 for i=1,#w do
  acc+=w[i]
  if pick<acc then return weather_kinds[i] end
 end
 return weather_kinds[3]
end

function weather_mult(kind)
 if kind.name=="drought" and has_tech(3) then return 0.8 end
 return kind.mod
end

-- events -------------------------------------------------------------------

function event_table()
 return {
  {id="rats",     phase="grain", text="rats in the granary",   ok=function() return not has_tech(1) end},
  {id="fire",     phase="grain", text="fire takes the store"},
  {id="merchants",phase="grain", text="merchants come upriver"},
  {id="locusts",  phase="crop",  text="locusts cross the fields"},
  {id="goodflood",phase="crop",  text="the flood comes kindly"},
  {id="disease",  phase="pop",   text="sickness in the city"},
  {id="migrants", phase="pop",   text="strangers ask to settle", ok=function() return g.stability>=1 end},
  {id="leavers",  phase="pop",   text="families leave the city", ok=function() return g.plan.ration<=2 end},
  {id="discovery",phase="craft", text="a craftsman finds a way"}
 }
end

function roll_event()
 if rnd(1)>=bal.event_chance then return nil end
 local pool={}
 for e in all(event_table()) do
  if not e.ok or e.ok() then add(pool,e) end
 end
 if #pool==0 then return nil end
 return pool[1+flr(rnd(#pool))]
end

function note(label,delta)
 add(g.ledger,{label=label,delta=delta})
end

-- the year ------------------------------------------------------------------

function end_year()
 g.ledger={}
 local before_stab=g.stability
 local ev=roll_event()
 g.event=ev

 -- 1. what the plan spends
 local food,seed,clear=food_spend(),seed_cost(),clear_cost()
 local store=g.grain-food-seed-clear
 note("food",-food)
 if seed>0 then note("seeds",-seed) end
 if clear>0 then note("clearing",-clear) end

 -- 2-3. weather, then any event that changes the crop before it is counted
 local kind=roll_weather()
 local mult=weather_mult(kind)
 g.weather=kind
 if ev and ev.phase=="crop" then
  mult*=(ev.id=="locusts" and 0.75 or 1.25)
 end

 -- 4-5. harvest
 local tech_mult=has_tech(2) and 1.2 or 1
 local harvest=flr(g.plan.fields*bal.base_yield*mult*tech_mult)
 g.grain=store+harvest
 note("harvest",harvest)

 -- 6. events that move grain
 if ev and ev.phase=="grain" then
  local d=0
  if ev.id=="rats" then d=-flr(g.grain*0.15)
  elseif ev.id=="fire" then d=-flr(g.grain*0.10)
  else d=20 end
  g.grain+=d
  note(ev.id,d)
 end

 -- 7. spoilage
 if not has_tech(1) then
  local lost=flr(g.grain*bal.spoilage)
  if lost>0 then g.grain-=lost note("spoilage",-lost) end
 end
 g.grain=max(0,g.grain)

 -- 8. population follows the ration, then any event that moves it
 local r=ration()
 local pct=r.lo+rnd(r.hi-r.lo)
 local dpop=flr(g.pop*pct+0.5)
 g.pop+=dpop
 note("people",dpop)
 if ev and ev.phase=="pop" then
  local d=0
  if ev.id=="disease" then d=-flr(g.pop*(0.05+rnd(0.07))+0.5)
  elseif ev.id=="migrants" then d=4+flr(rnd(5))
  else d=-5 end
  g.pop=max(0,g.pop+d)
  note(ev.id,d)
 end

 -- 9. craft and the technologies it unlocks
 local craft=g.plan.artisans
 if ev and ev.phase=="craft" then craft+=8 end
 if craft>0 then g.craft+=craft note("craft",craft) end
 while g.tech<#bal.tech_cost and g.craft>=bal.tech_cost[g.tech+1] do
  g.tech+=1
  note("tech:"..techs[g.tech].name,0)
 end

 -- 10. stability
 local ds=r.stab
 if g.pop>0 and harvest>=g.pop*bal.good_harvest then ds+=1 end
 if g.plan.ration==1 then ds+=bal.famine_stability end
 if ds==0 and g.stability~=0 then
  ds=g.stability>0 and -bal.stability_drift or bal.stability_drift
 end
 g.stability=mid(-5,g.stability+ds,5)
 if g.stability~=before_stab then note("mood",g.stability-before_stab) end

 -- 11. cleared land only opens the year after the work
 if g.plan.clear>0 then
  g.land=min(bal.max_land,g.land+g.plan.clear)
  note("land",g.plan.clear)
 end

 -- 12. endings
 g.angry_years=g.stability<=-5 and g.angry_years+1 or 0
 if g.pop<=0 then
  g.over=true g.ending="empty"
 elseif g.angry_years>=bal.rebel_years then
  g.over=true g.ending="rebellion"
 elseif g.year>=bal.years then
  g.over=true g.ending="reign"
 else
  g.year+=1
  g.plan.fields=0 g.plan.clear=0 g.plan.artisans=0
  roll_omen()
  clamp_plan()
 end
 return g.ledger
end

-- scoring -------------------------------------------------------------------

function score()
 if g.pop<=0 then return 0 end
 local s=bal.score
 return max(0,g.pop*s.pop+min(g.grain,bal.grain_cap)*s.grain+g.land*s.land
  +g.tech*s.tech+g.stability*s.stability)
end

function rank()
 local v=score()
 for r in all(bal.ranks) do
  if v<r[1] then return r[2] end
 end
 return bal.ranks[#bal.ranks][2]
end

mood_names={"angry","uneasy","calm","calm","happy","devoted"}
function mood()
 return mood_names[mid(1,4+flr(g.stability/2),6)]
end
-- generated by tools/make_atlas.py. do not edit.
-- each panel keeps the palette its pixels were reduced against.
atlas_pal={
 ending={132,128,4,9,134,129,130,15,5,137,0,133,1,135,143,131},
 game={5,4,128,13,134,3,129,9,131,0,132,15,1,133,143,6},
 splash={132,128,4,15,129,9,5,130,137,134,0,135,133,1,142,3},
}
atlas_ink={
 ending={dark=10,deep=12,mid=8,light=7,gold=3,red=9,green=13,blue=15,sand=7},
 game={dark=9,deep=12,mid=0,light=15,gold=7,red=1,green=5,blue=3,sand=11},
 splash={dark=10,deep=13,mid=6,light=3,gold=5,red=14,green=15,blue=13,sand=3},
}
atlas_rect={
 title={0,0,120,25},
 city={0,25,128,48},
 crown={0,73,72,28},
}
-- presentation helpers. the reference pieces in the sprite sheet are drawn with
-- sspr and never redrawn with primitives; everything else on screen is drawn
-- work, not a claim that it reproduces the concept sheet.

ink=nil

function use_pal(name)
 local p=atlas_pal[name]
 for i=0,15 do pal(i,p[i+1],1) end
 ink=atlas_ink[name]
end

function art(name,x,y)
 local r=atlas_rect[name]
 sspr(r[1],r[2],r[3],r[4],x,y)
end

function art_w(name)
 return atlas_rect[name][3]
end

-- text ----------------------------------------------------------------------

function ctext(s,y,c)
 print(s,64-#s*2,y,c)
end

function rtext(s,x,y,c)
 print(s,x-#s*4,y,c)
end

function shadow(s,x,y,c)
 print(s,x,y+1,ink.dark)
 print(s,x,y,c)
end

function cshadow(s,y,c)
 shadow(s,64-#s*2,y,c)
end

-- frames --------------------------------------------------------------------

function panel(x0,y0,x1,y1)
 rectfill(x0,y0,x1,y1,ink.dark)
 rect(x0,y0,x1,y1,ink.mid)
end

function bar(x0,y0,x1,y1,c)
 rectfill(x0,y0,x1,y1,c)
end

-- a slow two-tone sky so the drawn screens sit in the same palette as the art
function sky(y0,y1,a,b)
 for y=y0,y1 do
  line(0,y,127,y,(y-y0)/(y1-y0)<0.55 and a or b)
 end
end

-- effects -------------------------------------------------------------------

fx={}

function fx_add(x,y,dx,dy,c,life)
 add(fx,{x=x,y=y,dx=dx,dy=dy,c=c,t=life})
end

function fx_burst(x,y,c,n)
 for i=1,n do
  local a=rnd(1)
  fx_add(x,y,cos(a)*(0.4+rnd(1)),sin(a)*(0.4+rnd(1))-0.4,c,14+rnd(10))
 end
end

function fx_update()
 for p in all(fx) do
  p.x+=p.dx p.y+=p.dy p.dy+=0.04 p.t-=1
  if p.t<=0 then del(fx,p) end
 end
end

function fx_draw()
 for p in all(fx) do
  pset(p.x,p.y,p.c)
 end
end

shake=0
function shake_apply()
 if shake>0 then
  camera(2-rnd(4),2-rnd(4))
  shake-=1
 else
  camera()
 end
end
-- one function per screen. rules live in sim.lua and are never touched here.

-- The advisor says what he sees; the tag beside him says what it means. Section
-- 45 asks for a named risk rather than a probability, so the player can weigh it
-- without being told the odds.
omen_line={none="the year begins.",low_river="the river is low.",
 high_river="the river is high.",mild="the air is mild."}
risk_tag={drought="dry risk",flood="flood risk",calm="kind year"}

function ration_name()
 return bal.rations[g.plan.ration].name
end

function plan_rows()
 local r={{id="ration",name="food"},{id="fields",name="fields"}}
 if bal.clear_enabled then add(r,{id="clear",name="clear land"}) end
 if g.year>=bal.artisan_year then add(r,{id="artisans",name="artisans"}) end
 add(r,{id="end",name="end year"})
 return r
end

function row_limit(id)
 if id=="ration" then return #bal.rations end
 if id=="fields" then return limit_fields() end
 if id=="clear" then return limit_clear() end
 if id=="artisans" then return limit_artisans() end
 return 0
end

function row_value(id)
 if id=="ration" then return g.plan.ration end
 return g.plan[id] or 0
end

function row_set(id,v)
 if id=="ration" then
  g.plan.ration=mid(1,v,#bal.rations)
 else
  g.plan[id]=max(0,v)
 end
 clamp_plan()
end

-- splash ---------------------------------------------------------------------

-- splash palette indices: night at the top, then the sun going down. The title
-- keeps the dark band it was cut from, so the sky above stays that same navy.
splash_bands={{34,4},{44,13},{52,12},{58,7},{63,0},{67,2},{70,8},{72,5}}

function draw_splash(t)
 use_pal("splash")
 local top=0
 for b in all(splash_bands) do
  rectfill(0,top,127,b[1],b[2])
  top=b[1]+1
 end
 -- one dithered row per seam so eight bands do not read as eight steps
 top=0
 for b in all(splash_bands) do
  if top>0 then
   for x=0,127 do
    if (x+top)%2==0 then pset(x,top,b[2]) end
   end
  end
  top=b[1]+1
 end
 for i=0,13 do
  pset((i*29)%126+1,(i*17)%30+2,i%3==0 and 3 or 6)
 end
 circfill(64,74,11,11)
 circfill(64,75,9,5)
 -- the river takes the light back
 rectfill(0,75,127,127,13)
 for y=75,127 do
  if (y+flr(t/30))%7<1 then line(0,y,127,y,4) end
 end
 for y=76,120 do
  local i=y-76
  local w=max(0,4-flr(i/11))
  local x=64+sin(t/300+i/23)*2
  rectfill(x-w,y,x+w,y,(y+flr(t/16))%3==0 and 8 or 5)
 end
 art("title",4,6)
 cshadow("a city of grain",36,ink.gold)
 if t%60<40 then
  cshadow("press any button",110,ink.light)
 end
end

-- menu -----------------------------------------------------------------------

menu_items={"begin reign","how to play","credits"}

function draw_menu(sel)
 use_pal("splash")
 sky(0,79,ink.deep,ink.dark)
 rectfill(0,80,127,127,ink.dark)
 art("title",4,10)
 for i=1,#menu_items do
  local y=52+i*11
  local c=i==sel and ink.gold or ink.light
  if i==sel then print(">",22,y,ink.gold) end
  shadow(menu_items[i],30,y,c)
 end
 cshadow("12 years. one city.",112,ink.mid)
end

function draw_help()
 use_pal("splash")
 rectfill(0,0,127,127,ink.dark)
 cshadow("how to play",4,ink.gold)
 local lines={
  "you rule sumer for 12 years.",
  "",
  "each year you choose how much",
  "grain feeds the city and how",
  "much is sown. what is left",
  "stays in the store.",
  "",
  "a field needs seed and hands.",
  "hands come from your people.",
  "",
  "spend everything and one bad",
  "harvest ends your reign.",
  "",
  "arrows pick and change.",
  "z back   x confirm"
 }
 for i=1,#lines do
  print(lines[i],4,16+i*7,ink.light)
 end
end

function draw_credits()
 use_pal("splash")
 rectfill(0,0,127,127,ink.dark)
 art("title",4,20)
 cshadow("after the sumerian game",56,ink.light)
 cshadow("mabel addis, 1964",64,ink.mid)
 cshadow("pico-8 adaptation",80,ink.light)
 cshadow("made by alkhan",88,ink.gold)
 cshadow("z to go back",112,ink.mid)
end

-- the year -------------------------------------------------------------------

function draw_hud()
 rectfill(0,0,127,31,ink.dark)
 rect(0,0,127,23,ink.mid)
 print("year "..g.year.."/"..bal.years,3,3,ink.light)
 rtext(mood(),124,3,ink.green)
 print("pop",3,11,ink.mid)   print(g.pop,22,11,ink.light)
 print("grain",56,11,ink.mid) print(min(g.grain,999)..(g.grain>999 and "+" or ""),84,11,ink.gold)
 print("land",3,18,ink.mid)  print(g.land,22,18,ink.light)
 print("craft",56,18,ink.mid) print(g.craft,84,18,ink.light)
end

function draw_city(t)
 art("city",0,32)
 -- drawn, not reference: a little life over the imported band
 for i=0,2 do
  local x=70+i*3+sin(t/180+i/3)*2
  pset(x,44-i*3-(t/8+i*5)%9,ink.mid)
 end
 for i=0,1 do
  local x=(t/3+i*61)%140-6
  pset(x,38+i*3,ink.dark) pset(x+1,38+i*3,ink.dark)
 end
end

function draw_plan(sel)
 local rows=plan_rows()
 rectfill(0,80,127,127,ink.dark)
 rect(0,80,127,127,ink.mid)
 print("reserve",4,83,ink.mid)
 rtext(""..reserve(),124,83,reserve()>0 and ink.gold or ink.red)
 for i=1,#rows do
  local r=rows[i]
  local y=82+i*8
  local on=i==sel
  if on then
   rectfill(2,y-1,125,y+5,ink.deep)
   print(">",3,y,ink.gold)
  end
  if r.id=="end" then
   print(r.name,9,y,on and ink.gold or ink.light)
  else
   local lim=row_limit(r.id)
   print(r.name,9,y,lim>0 and ink.light or ink.mid)
   if r.id=="ration" then
    rtext(ration_name(),124,y,ink.green)
   else
    rtext(row_value(r.id).."/"..lim,124,y,lim>0 and ink.light or ink.mid)
   end
  end
 end
end

function draw_year(sel,t)
 use_pal("game")
 draw_hud()
 print(omen_line[g.omen.name],3,25,ink.sand)
 local tag=risk_tag[g.omen.risk]
 if tag then rtext(tag,124,25,g.omen.risk=="calm" and ink.green or ink.red) end
 draw_city(t)
 draw_plan(sel)
end

-- event card ------------------------------------------------------------------

event_unit={grain="grain",pop="people",crop="harvest",craft="craft"}

function draw_event(ev,delta,t)
 draw_year(1,t)
 rectfill(8,40,119,88,ink.dark)
 rect(8,40,119,88,ink.gold)
 cshadow(ev.id,46,ink.gold)
 cshadow(ev.text,58,ink.light)
 local unit=event_unit[ev.phase]
 if ev.phase=="crop" then
  cshadow((ev.id=="locusts" and "-25%" or "+25%").." harvest",68,
   ev.id=="locusts" and ink.red or ink.green)
 elseif delta~=0 then
  cshadow((delta>0 and "+" or "")..delta.." "..unit,68,delta>0 and ink.green or ink.red)
 end
 if t%60<40 then cshadow("x",78,ink.mid) end
end

-- ledger ----------------------------------------------------------------------

-- what a ledger line is counted in, so a number is never bare
ledger_unit={food="grain",seeds="grain",clearing="grain",harvest="grain",
 spoilage="grain",rats="grain",fire="grain",merchants="grain",people="pop",
 disease="pop",migrants="pop",leavers="pop",craft="craft",discovery="craft",
 land="land",mood="mood"}

function ledger_shown()
 local out={}
 for e in all(g.ledger) do
  if e.delta~=0 or sub(e.label,1,5)=="tech:" then add(out,e) end
 end
 return out
end

function draw_ledger(shown,top,year)
 use_pal("game")
 rectfill(0,0,127,127,ink.dark)
 rect(0,0,127,127,ink.mid)
 cshadow("year "..year.." ends",4,ink.gold)
 cshadow("a "..g.weather.name.." year",13,ink.sand)
 local y=26
 for i=1,min(top,#shown) do
  local e=shown[i]
  local unit=ledger_unit[e.label]
  if unit==nil then
   print(sub(e.label,6).." built",8,y,ink.gold)
  else
   local c=e.delta<0 and ink.red or ink.green
   print(e.label,8,y,ink.light)
   rtext(unit,88,y,ink.mid)
   rtext((e.delta>0 and "+" or "")..e.delta,120,y,c)
  end
  y+=8
 end
 if top>=#shown then
  line(8,y+2,120,y+2,ink.mid)
  print("store",8,y+6,ink.light)
  rtext(""..g.grain,120,y+6,ink.gold)
  if flr(time()*2)%2==0 then cshadow("x",119,ink.mid) end
 end
end

-- ending ------------------------------------------------------------------------

function draw_ending()
 use_pal("ending")
 sky(0,90,ink.deep,ink.dark)
 rectfill(0,91,127,127,ink.dark)
 art("crown",28,6)
 local title=g.ending=="reign" and rank() or
  (g.ending=="rebellion" and "the city rebels" or "the city is empty")
 cshadow(title,40,ink.gold)
 cshadow("score "..score(),52,ink.light)
 line(20,62,107,62,ink.mid)
 cshadow("pop "..g.pop.."  land "..g.land,70,ink.light)
 cshadow("tech "..g.tech.."  year "..g.year,78,ink.light)
 if g.ending~="reign" then
  cshadow("your reign is over",92,ink.red)
 else
  cshadow("thank you for playing",92,ink.light)
 end
 cshadow("x to begin again",112,ink.mid)
end
-- screen flow, input and cues. no rule is decided here.

bad_events={rats=1,fire=1,locusts=1,disease=1,leavers=1}

function _init()
 poke(0x5f2d,1)
 app={screen="splash",sel=1,t=0,top=0,shown=1,mdown=false,hit=false}
 start_game()
 music(0)
end

function start_game()
 new_game(flr(rnd(9999))+1)
 app.sel=1
end

-- input ------------------------------------------------------------------------

function any_button()
 for i=0,5 do if btnp(i) then return true end end
 return app.hit
end

-- read once a frame: a short-circuited call would leave app.mdown stale and
-- turn a press made elsewhere into a click as soon as the pointer arrives
function read_click()
 local down=stat(34)&1==1
 app.hit=down and not app.mdown
 app.mdown=down
end

function click()
 return app.hit
end

function mrow(y0,h,n)
 local my=stat(33)
 if my<y0 then return 0 end
 local i=flr((my-y0)/h)+1
 return i>=1 and i<=n and i or 0
end

-- menus ---------------------------------------------------------------------

function step_sel(n)
 if btnp(2) then app.sel=(app.sel-2)%n+1 sfx(0) end
 if btnp(3) then app.sel=app.sel%n+1 sfx(0) end
end

function update_menu()
 step_sel(#menu_items)
 local over=mrow(63,11,#menu_items)
 if over>0 and over~=app.sel then app.sel=over sfx(0) end
 if btnp(5) or (over>0 and click()) then
  sfx(2)
  if app.sel==1 then start_game() app.screen="plan"
  elseif app.sel==2 then app.screen="help"
  else app.screen="credits" end
 end
end

-- the planning screen ---------------------------------------------------------

function update_plan()
 local rows=plan_rows()
 step_sel(#rows)
 local over=mrow(91,8,#rows)
 if over>0 and over~=app.sel then app.sel=over sfx(0) end
 local r=rows[mid(1,app.sel,#rows)]

 if r.id=="end" then
  if btnp(5) or (over==app.sel and click()) then finish_year() end
  return
 end

 local step=0
 if btnp(0) then step=-1 end
 if btnp(1) then step=1 end
 if btnp(5) then step=1 end
 if btnp(4) then step=-1 end
 if over==app.sel and click() then step=stat(32)<64 and -1 or 1 end
 if step~=0 then
  local was=row_value(r.id)
  row_set(r.id,was+step)
  if row_value(r.id)~=was then sfx(1) else sfx(3) end
 end
end

function finish_year()
 app.shown=g.year
 sfx(2)
 end_year()
 app.top=0
 for e in all(g.ledger) do
  if sub(e.label,1,5)=="tech:" then sfx(5) fx_burst(64,60,ink.gold,24) end
 end
 if g.event then
  if bad_events[g.event.id] then shake=10 sfx(3)
  else sfx(4) fx_burst(64,60,ink.gold,20) end
  app.screen="event"
 else
  app.screen="ledger"
 end
end

function event_delta()
 for e in all(g.ledger) do
  if e.label==g.event.id then return e.delta end
 end
 return 0
end

-- flow ------------------------------------------------------------------------

function _update60()
 app.t+=1
 read_click()
 fx_update()
 local s=app.screen
 if s=="splash" then
  if any_button() then sfx(2) app.screen="menu" app.sel=1 end
 elseif s=="menu" then
  update_menu()
 elseif s=="help" or s=="credits" then
  if btnp(4) or btnp(5) or click() then sfx(0) app.screen="menu" end
 elseif s=="plan" then
  update_plan()
 elseif s=="event" then
  if btnp(5) or click() then sfx(0) app.screen="ledger" end
 elseif s=="ledger" then
  local n=#ledger_shown()
  if app.t%8==0 and app.top<n then app.top+=1 sfx(1) end
  if btnp(5) or click() then
   if app.top<n then
    app.top=n
   elseif g.over then
    music(-1)
    sfx(g.ending=="reign" and 6 or 7)
    app.screen="ending"
   else
    app.screen="plan"
    app.sel=1
   end
  end
 elseif s=="ending" then
  if btnp(5) or click() then
   music(0)
   start_game()
   app.screen="menu"
   app.sel=1
  end
 end
end

function _draw()
 cls(0)
 shake_apply()
 local s=app.screen
 if s=="splash" then draw_splash(app.t)
 elseif s=="menu" then draw_menu(app.sel)
 elseif s=="help" then draw_help()
 elseif s=="credits" then draw_credits()
 elseif s=="plan" then draw_year(app.sel,app.t)
 elseif s=="event" then draw_event(g.event,event_delta(),app.t)
 elseif s=="ledger" then draw_ledger(ledger_shown(),app.top,app.shown)
 elseif s=="ending" then draw_ending() end
 fx_draw()
 camera()
end