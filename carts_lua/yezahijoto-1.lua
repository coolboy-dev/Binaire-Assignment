-- ============================================
-- FLAIL RAIL: COMPLETE PHYSICS ROGUELIKE
-- ============================================

function _init()
    poke(0x5f2d,1)
    hi_score,sel_class,title_opt=0,1,1
    classes={
        {"FLAIL",100,1.5,26,5.5,4,8,1,"BALANCED KINETIC CORE"},
        {"TWIN",90,1.65,16,3.5,3.8,7,2,"DUAL HIGH-RPM TETHERS"},
        {"TITAN",110,1.4,22,4.5,5.8,11,1,"HEAVY CLEAVE WRECKING BALL"},
        {"MAGNET",95,1.8,18,4,4,8,1,"SUPERCONDUCTING GEM VACUUM"}
    }
    u_names=split("LONG CORD,HEAVY FLAIL,EXTRA CORD,LIGHTNING,FIRE TRAIL,SAWBLADE,BEAM TETHER,VORTEX,DASH PIERCE,SLOW-MO,SHIELD ORB,PLATING,SHOCKWAVE,BOMB CLUSTER,FROST CHILL,LIFE LEECH,GEM MAGNET,CRIT BOOST",",")
    u_descs=split("+3 REACH & LENGTH,+50% MASS & DAMAGE,+1 DUAL FLAIL CORD,CHAIN ZAPS FOES,LAVA BURNS GROUND,SAWBLADE BLEED TICKS,LASER BEAM ROPE LINE,PULLS ENEMIES IN,WHIP SHOOTS AMMO,PULSE SLOWS TIME,ORBITAL FARADAY ORB,-40% DAMAGE TAKEN,SPEED RELEASES WAVES,KILLS SPAWN 3 BOMBS,FROST CHILLS MOBS,CRITS RESTORE HP,+35 MAGNET RADIUS,+25% CRIT CHANCE",",")
    init_sfx()
    cart_init()
end

function init_sfx()
    for s in all(split("0,1,42,36,30,24,18,12;1,2,22,18,14,10,6;2,2,48,55;3,3,36,40,43,48;4,3,18,16,14,12,10,8;5,2,50,56,48;6,2,44,52;7,2,58,62",";")) do
        local p=split(s,",") local b=0x3200+p[1]*68
        poke(b+65,p[2])
        for i=3,#p do poke(b+(i-3)*2,p[i],48) end
    end
end

function cart_init()
    mode,shake,freeze,t,score,gems_bank,wave,wave_t,mobs_spawned,cur_boss,combo,combo_t="title",0,0,0,0,0,1,0,0,nil,0,0
    tut_step,tut_timer,prev_mb,cur_mb,mx,my=1,0,0,0,64,64
    init_player()
    bumpers={{32,36,6.5,0},{96,36,6.5,0},{64,64,7.5,0},{32,92,6.5,0},{96,92,6.5,0}}
    enemies,gems,particles,floaters,fire_pools,lightnings,shockwaves,bullets,cards,shop_items={},{},{},{},{},{},{},{},{},{}
    selected_card=1
end

function init_player()
    local c=classes[sel_class] or classes[1]
    p={
        x=64,y=64,vx=0,vy=0,spd=c[3],fric=0.86,
        hp=c[2],max_hp=c[2],lives=0,xp=0,max_xp=8,lvl=1,tension_chg=0,
        spec_chg=0,spec_max=100,invul=0,ropes={},rope_segs=c[7],rope_len=c[6],tip_dmg=c[4],flail_size=c[5],
        dmg_mult=1,crit_rate=0.15,shield_ang=0,time_slow_t=0,
        magnet_r=sel_class==4 and 75 or 45,pulse_r=38,num_ropes=c[8],
        mods={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
    }
    init_ropes()
end

function init_ropes()
    p.ropes={}
    for r=1,p.num_ropes do
        local r_obj={segs={},seg_len=p.rope_len,tip_dmg=p.tip_dmg,color=r==1 and 9 or (r==2 and 10 or 11),ang=(r-1)*(1/p.num_ropes)}
        for i=1,p.rope_segs do
            local a=r_obj.ang+i*0.04
            add(r_obj.segs,{x=p.x+cos(a)*(i*p.rope_len),y=p.y+sin(a)*(i*p.rope_len),ox=p.x+cos(a)*(i*p.rope_len),oy=p.y+sin(a)*(i*p.rope_len),vx=0,vy=0})
        end
        add(p.ropes,r_obj)
    end
end

function _update60()
    t+=1
    local raw_mx,raw_my,raw_mb=stat(32),stat(33),stat(34)
    if raw_mx>0 or raw_my>0 or raw_mb>0 then mx,my=mid(2,raw_mx,125),mid(2,raw_my,125) end
    cur_mb=raw_mb
    local l_click=(cur_mb&1!=0) and (prev_mb&1==0)
    local r_click=(cur_mb&2!=0) and (prev_mb&2==0)

    if shake>0 then shake-=0.5 end
    if freeze>0 then freeze-=1 prev_mb=cur_mb return end

    if mode=="title" then
        for i=1,3 do
            local cy=66+(i-1)*15
            if mx>=12 and mx<=116 and my>=cy and my<=cy+13 then
                if title_opt!=i then title_opt=i sfx(0) end
                if l_click then do_title_opt() return end
            end
        end
        if btnp(2) then title_opt=max(1,title_opt-1) sfx(0) end
        if btnp(3) then title_opt=min(3,title_opt+1) sfx(0) end
        if btnp(4) or btnp(5) then do_title_opt() end
    elseif mode=="class_select" then
        update_class_select(l_click)
    elseif mode=="play" or mode=="tutorial" then
        update_bg_music()
        update_play(l_click,r_click)
    elseif mode=="levelup" then
        update_levelup(l_click)
    elseif mode=="shop" then
        update_shop(l_click)
    elseif mode=="gameover" then
        if (l_click or r_click or btnp(4) or btnp(5)) and t>30 then cart_init() mode="title" end
    end
    prev_mb=cur_mb
end

function do_title_opt()
    if title_opt==1 then init_player() mode="play" start_wave(1) sfx(3)
    elseif title_opt==2 then start_live_tutorial()
    else mode="class_select" sfx(0) end
end

function start_live_tutorial()
    cart_init() mode="tutorial" tut_step=1 init_player()
    spawn_dummy(35,45) spawn_dummy(92,45) spawn_dummy(64,88) sfx(3)
end

function spawn_dummy(x,y,hp)
    add(enemies,{x=x,y=y,vx=0,vy=0,hp=hp or 25,max_hp=hp or 25,spd=0,r=5,col=10,no_dmg=true,xp_val=2,hit_cd=0,burn_t=0,bleed_t=0,cryo_t=0,flash=0})
end

function update_tutorial_logic(l_click,r_click)
    tut_timer+=1
    if tut_step==1 and #enemies==0 and #gems==0 then
        tut_step=2 tut_timer=0 spawn_floater(64,50,"TARGETS CLEARED!",10) sfx(3)
        spawn_dummy(40,50,40) spawn_dummy(88,50,40)
    elseif tut_step==2 and p.tension_chg>=12 and (cur_mb&1==0 or btnp(4)) then
        tut_step=3 tut_timer=0 spawn_floater(64,50,"PERFECT SNAP!",11) sfx(3)
        spawn_dummy(64,25,999) local e=enemies[1] e.is_turret=true e.col=12 e.shoot_t=0
    elseif tut_step==3 then
        for e in all(enemies) do if e.is_turret then e.shoot_t+=1 if e.shoot_t%50==0 then fire_bullet(e.x,e.y,0,1.5,2.5,8,10,80) end end end
        for b in all(bullets) do
            if b.is_player then
                enemies,bullets={},{} tut_step=4 tut_timer=0 p.spec_chg=p.spec_max
                spawn_floater(64,50,"BULLET DEFLECTED!",10) sfx(3)
                for i=1,4 do local a=i*0.25 spawn_dummy(64+cos(a)*28,64+sin(a)*28,20) end
                break
            end
        end
    elseif tut_step==4 and (r_click or btnp(5)) then
        tut_step=5 tut_timer=0 spawn_floater(64,50,"SYSTEM CALIBRATED!",10) sfx(3)
    elseif tut_step==5 and tut_timer>60 then
        mode="play" start_wave(1) sfx(3)
    end
end

function update_class_select(l_click)
    for i=1,#classes do
        local cy=24+(i-1)*20
        if mx>=8 and mx<=120 and my>=cy and my<=cy+18 and l_click then
            if sel_class!=i then sel_class=i sfx(0) end
        end
    end
    if btnp(2) then sel_class=max(1,sel_class-1) sfx(0) end
    if btnp(3) then sel_class=min(#classes,sel_class+1) sfx(0) end
    
    if (mx>=12 and mx<=60 and my>=106 and my<=119 and l_click) or btnp(4) then
        init_player() mode="play" start_wave(1) sfx(3)
    elseif (mx>=68 and mx<=116 and my>=106 and my<=119 and l_click) or btnp(5) then
        mode="title" sfx(0)
    end
end

function update_bg_music()
    local interval=combo>4 and 6 or 8
    if t%interval==0 then
        local s={24,24,27,24,31,29,27,24,24,27,29,31,36,31,29,27}
        poke(0x3200+15*68,flr(s[(flr(t/interval)%16)+1]))
        poke(0x3200+15*68+1,25)
        poke(0x3200+15*68+65,4)
        sfx(15,3)
    end
end

function start_wave(w,from_shop)
    wave,wave_t,mobs_spawned=w,0,0
    wave_mobs=6+wave*4
    cur_boss=nil
    if not from_shop and wave>1 and (wave-1)%5==0 then open_shop() return end
    if wave%5==0 then
        wave_mobs=flr(wave_mobs/2)+1
        spawn_boss(wave>=15 and "DREADNOUGHT" or (wave>=10 and "HYDRA" or "GOLEM"))
    else
        spawn_floater(64,40,"WAVE "..wave,10)
    end
end

function fire_bullet(x,y,vx,vy,r,col,dmg,life,is_p)
    add(bullets,{x=x,y=y,vx=vx,vy=vy,r=r,col=col,dmg=dmg,life=life,is_player=is_p})
end

function update_play(l_click,r_click)
    if combo_t>0 then combo_t-=1 if combo_t<=0 then combo=0 end end
    local sim_rate=p.time_slow_t>0 and 0.3 or 1
    if p.time_slow_t>0 then p.time_slow_t-=1 end

    local px,py=p.x,p.y
    local d_mx,d_my=mx-px,my-py
    local m_dist=sqrt(d_mx*d_mx+d_my*d_my)
    if m_dist>1.5 then p.vx,p.vy=d_mx*0.88,d_my*0.88
    else p.vx+=((btn(1) and 1 or 0)-(btn(0) and 1 or 0))*p.spd*0.45 p.vy+=((btn(3) and 1 or 0)-(btn(2) and 1 or 0))*p.spd*0.45 end

    local is_hold=(cur_mb&1!=0) or btn(4)
    if is_hold then
        p.tension_chg=min(25,p.tension_chg+1)
        for r in all(p.ropes) do r.seg_len=max(1.8,p.rope_len*0.45) end
        if t%2==0 then for r in all(p.ropes) do spawn_part(r.segs[#r.segs].x,r.segs[#r.segs].y,rnd(2)-1,rnd(2)-1,3,10) end end
    else
        for r in all(p.ropes) do r.seg_len=p.rope_len end
    end

    local pm,pmult=p.mods,p.dmg_mult
    if not is_hold and p.tension_chg>0 then
        local chg=p.tension_chg
        p.tension_chg=0
        shake=min(8,shake+chg*0.25)
        sfx(0)
        for r in all(p.ropes) do
            local tip=r.segs[#r.segs]
            local s_ang=atan2(tip.x-px,tip.y-py)
            tip.ox,tip.oy=tip.x-cos(s_ang)*(10+chg*0.35),tip.y-sin(s_ang)*(10+chg*0.35)
            add(shockwaves,{x=tip.x,y=tip.y,r=2,max_r=18+chg*0.5,dmg=35*pmult,life=8})
            spawn_floater(tip.x,tip.y-6,"SNAP!",10)
            if pm[9]>0 then fire_bullet(px,py,cos(s_ang)*8,sin(s_ang)*8,2.5,11,50*pmult,30,true) end
        end
    end

    p.x,p.y=mid(3,px+p.vx,124),mid(3,py+p.vy,124)
    if p.invul>0 then p.invul-=1 end

    if (r_click or btnp(5)) and p.spec_chg>=p.spec_max then trigger_pulse() end

    if pm[11]>0 then
        p.shield_ang+=0.04*(1+pm[11]*0.2)
        local sx,sy=px+cos(p.shield_ang)*18,py+sin(p.shield_ang)*18
        circfill(sx,sy,3,11)
        if p.evo_s and t%18==0 then
            for e in all(enemies) do
                if ((e.x-sx)^2+(e.y-sy)^2)<1600 then add(lightnings,{x1=sx,y1=sy,x2=e.x,y2=e.y,life=6}) hit_enemy(e,25*p.dmg_mult,0,0,false) break end
            end
        end
        for e in all(enemies) do
            local dx,dy=e.x-sx,e.y-sy
            local d=sqrt(dx*dx+dy*dy)
            if d<(e.r+6) and e.hit_cd<=0 then hit_enemy(e,35*pmult,(dx/max(1,d))*6,(dy/max(1,d))*6,true) e.hit_cd=8 shake=3 sfx(0) end
        end
    end

    update_ropes()
    update_bumpers()
    update_enemies(sim_rate)
    update_bullets(sim_rate)
    update_gems()
    update_fire_pools()
    update_shockwaves()
    update_lightnings()
    update_particles()
    update_floaters()

    if mode=="play" then
        wave_t+=1
        if mobs_spawned<wave_mobs and wave_t%max(16,48-wave*2)==0 then spawn_enemy() mobs_spawned+=1 end
        if mobs_spawned>=wave_mobs and #enemies==0 then start_wave(wave+1) end

        if p.hp<=0 then
            if p.lives>0 then
                p.lives-=1 p.hp=p.max_hp p.invul=45 shake=10 sfx(3) spawn_floater(p.x,p.y-10,"REVIVED!",11)
            else
                mode="gameover" hi_score=max(hi_score,score) shake=18 freeze=15 t=0
                for i=1,30 do spawn_part(p.x,p.y,rnd(6)-3,rnd(6)-3,12,rnd({8,9,7,10})) end
                sfx(4)
            end
        end
    else
        update_tutorial_logic(l_click,r_click)
    end
end

function trigger_pulse()
    p.spec_chg,shake,freeze=0,10,2
    sfx(4)
    if p.mods[10]>0 then p.time_slow_t=120 spawn_floater(p.x,p.y-14,"SLOW-MO!",12) end
    for i=1,32 do local a=i/32 spawn_part(p.x,p.y,cos(a)*5,sin(a)*5,14,rnd({7,10,11,12})) end
    for e in all(enemies) do
        local dx,dy=e.x-p.x,e.y-p.y
        local d=sqrt(dx*dx+dy*dy)
        if d<p.pulse_r then hit_enemy(e,80*p.dmg_mult,(dx/max(1,d))*8,(dy/max(1,d))*8,true) end
    end
    spawn_floater(p.x,p.y-8,"PULSE!",7)
end

function update_bumpers()
    for bp in all(bumpers) do
        local bx,by,br=bp[1],bp[2],bp[3]
        if bp[4]>0 then bp[4]-=1 end
        for r in all(p.ropes) do
            local tip=r.segs[#r.segs]
            local dx,dy=tip.x-bx,tip.y-by
            local d=sqrt(dx*dx+dy*dy)
            local min_d=br+p.flail_size
            if d<min_d and d>0 then
                local nx,ny=dx/d,dy/d
                tip.x,tip.y=bx+nx*(min_d+1),by+ny*(min_d+1)
                tip.ox,tip.oy=tip.x-nx*9,tip.y-ny*9
                bp[4],shake=12,max(shake,4) score+=15 sfx(5)
                spawn_floater(bx,by-6,"BOUNCE!",10)
                for i=1,6 do spawn_part(bx,by,rnd(4)-2,rnd(4)-2,6,10) end
            end
        end
        for e in all(enemies) do
            local dx,dy=e.x-bx,e.y-by
            local d=sqrt(dx*dx+dy*dy)
            if d<(br+e.r) and d>0 then
                local nx,ny=dx/d,dy/d
                e.x,e.y=bx+nx*(br+e.r+2),by+ny*(br+e.r+2)
                e.vx,e.vy=nx*8.5,ny*8.5
                bp[4]=12
                if e.hit_cd<=0 then hit_enemy(e,35*p.dmg_mult,nx*4,ny*4,true) e.hit_cd=8 score+=25 sfx(5) end
            end
        end
    end
end

function dist_seg_point(x1,y1,x2,y2,px,py)
    local dx,dy=x2-x1,y2-y1
    local l2=dx*dx+dy*dy
    if l2==0 then return sqrt((px-x1)^2+(py-y1)^2),x1,y1 end
    local u=mid(0,((px-x1)*dx+(py-y1)*dy)/l2,1)
    local rx,ry=x1+u*dx,y1+u*dy
    return sqrt((px-rx)^2+(py-ry)^2),rx,ry
end

function update_ropes()
    local px,py,pm,pmult=p.x,p.y,p.mods,p.dmg_mult
    for r in all(p.ropes) do
        local segs=r.segs
        local count=#segs
        segs[1].x,segs[1].y=px,py

        for i=2,count do
            local s=segs[i]
            local vx,vy=(s.x-s.ox)*0.94,(s.y-s.oy)*0.94+0.03
            s.ox,s.oy,s.x,s.y,s.vx,s.vy=s.x,s.y,s.x+vx,s.y+vy,vx,vy
        end

        for iter=1,5 do
            segs[1].x,segs[1].y=px,py
            for i=1,count-1 do
                local s1,s2=segs[i],segs[i+1]
                local dx,dy=s2.x-s1.x,s2.y-s1.y
                local dist=sqrt(dx*dx+dy*dy)
                if dist>0.0001 then
                    local diff=(dist-r.seg_len)/dist
                    if i==1 then s2.x-=dx*diff s2.y-=dy*diff
                    else s1.x+=dx*diff*0.5 s1.y+=dy*diff*0.5 s2.x-=dx*diff*0.5 s2.y-=dy*diff*0.5 end
                end
            end
        end

        local tip=segs[count]
        local tx,ty,tvx,tvy=tip.x,tip.y,tip.vx,tip.vy
        local tip_speed=sqrt(tvx*tvx+tvy*tvy)
        if tip_speed>1.8 and t%2==0 then spawn_part(tx,ty,-tvx*0.3,-tvy*0.3,6,pm[5]>0 and rnd({8,9,10}) or (pm[4]>0 and rnd({7,11,12}) or r.color)) end
        if pm[5]>0 and tip_speed>2.0 and t%7==0 then add(fire_pools,{x=tx+rnd(4)-2,y=ty+rnd(4)-2,r=5+pm[5],life=60+pm[5]*15}) end
        if pm[13]>0 and tip_speed>3.4 and t%10==0 then add(shockwaves,{x=tx,y=ty,r=2,max_r=24+pm[13]*6,dmg=18*pmult,life=8}) shake=min(7,shake+3) sfx(1) end
        if pm[8]>0 and t%50==0 then
            add(shockwaves,{x=tx,y=ty,r=32,max_r=2,dmg=35*pmult,life=10})
            for e in all(enemies) do local dx,dy=tx-e.x,ty-e.y local d=sqrt(dx*dx+dy*dy) if d<60 then e.vx+=(dx/max(1,d))*4.5 e.vy+=(dy/max(1,d))*4.5 end end
        end

        if pm[7]>0 and t%2==0 then
            for e in all(enemies) do
                local dist,lx,ly=dist_seg_point(px,py,tx,ty,e.x,e.y)
                if dist<(e.r+3) and e.hit_cd<=0 then hit_enemy(e,10*pmult*pm[7],0,0,false) e.burn_t=30 e.hit_cd=5 spawn_part(lx,ly,rnd(2)-1,rnd(2)-1,4,8) end
            end
        end

        for b in all(bullets) do
            if not b.is_player and dist_seg_point(segs[1].x,segs[1].y,tx,ty,b.x,b.y)<(b.r+p.flail_size) then
                b.is_player,b.vx,b.vy,b.dmg,b.col=true,-b.vx*1.5+tvx*0.5,-b.vy*1.5+tvy*0.5,b.dmg*3,11
                shake=min(6,shake+2) spawn_floater(b.x,b.y-4,"PARRY! 3X",10) sfx(7)
            end
        end

        for e in all(enemies) do
            local t_dx,t_dy=e.x-tx,e.y-ty
            local t_dist=sqrt(t_dx*t_dx+t_dy*t_dy)
            if t_dist<(p.flail_size+e.r+2) and e.hit_cd<=0 then
                local impact=max(1.5,tip_speed*1.8)
                local base_dmg=r.tip_dmg*pmult*(impact/2)
                if pm[6]>0 then base_dmg*=1.4 e.bleed_t=60 end
                if p.evo_t and e.cryo_t>0 then base_dmg*=2.5 spawn_floater(e.x,e.y-8,"THERMAL SHOCK!",9) end
                local is_crit=(rnd(1)<p.crit_rate or impact>4.2)
                if is_crit then base_dmg*=2 if pm[16]>0 then p.hp=min(p.max_hp,p.hp+5) spawn_floater(px,py-6,"+HP",11) end end
                hit_enemy(e,base_dmg,(t_dist>0 and t_dx/t_dist or 1)*impact*1.2+tvx*0.6,(t_dist>0 and t_dy/t_dist or 1)*impact*1.2+tvy*0.6,is_crit)
                e.hit_cd=5
                if pm[4]>0 then trigger_chain_lightning(e,18*pmult,pm[4]) end
                shake=min(9,shake+impact*0.9)
                if impact>3.8 then freeze=1 end
                sfx(0)
            end

            for s_i=1,count-1 do
                local s1,s2=segs[s_i],segs[s_i+1]
                local dist=dist_seg_point(s1.x,s1.y,s2.x,s2.y,e.x,e.y)
                if dist<(2.5+e.r) and e.hit_cd<=0 then
                    local s_spd=sqrt(s2.vx*s2.vx+s2.vy*s2.vy)
                    if s_spd>0.8 then
                        hit_enemy(e,8*pmult*max(1,s_spd),s2.vx*0.6,s2.vy*0.6,false)
                        e.hit_cd=6 sfx(1)
                        if pm[4]>0 and rnd(1)<0.4 then trigger_chain_lightning(e,12*pmult,1) end
                    end
                end
            end
        end
    end
end

function trigger_chain_lightning(src_e,dmg,jumps)
    local targets={}
    for e in all(enemies) do if e!=src_e and ((e.x-src_e.x)^2+(e.y-src_e.y)^2)<2304 then add(targets,e) end end
    for j=1,min(jumps,#targets) do
        local tgt=targets[j]
        add(lightnings,{x1=src_e.x,y1=src_e.y,x2=tgt.x,y2=tgt.y,life=6})
        hit_enemy(tgt,dmg,rnd(2)-1,rnd(2)-1,false) tgt.hit_cd=6
    end
end

function spawn_boss(bn)
    local hp=300+wave*80
    cur_boss={x=64,y=-10,vx=0,vy=0,hp=hp,max_hp=hp,spd=0.45,r=9,col=8,type="boss",boss_kind=bn,name=bn,xp_val=25,hit_cd=0,burn_t=0,bleed_t=0,cryo_t=0,flash=0,attack_t=0}
    add(enemies,cur_boss)
    spawn_floater(64,50,"WARNING: "..bn,8)
    shake=10
end

function spawn_enemy()
    local s=flr(rnd(4))
    local ex,ey=(s&1==0 and rnd(128) or (s==1 and 132 or -4)),(s&1==1 and rnd(128) or (s==2 and 132 or -4))
    local etype,hp,spd,r,col,xp="swarmer",18+wave*5,0.75+rnd(0.3),3.5,8,1
    local roll=rnd(100)
    if roll<25 and wave>1 then etype,hp,spd,r,col,xp="brute",55+wave*12,0.45,5.5,9,3
    elseif roll<50 and wave>2 then etype,hp,spd,r,col,xp="sprinter",12+wave*3,1.4,2.5,10,2
    elseif roll<70 and wave>3 then etype,hp,spd,r,col,xp="spitter",24+wave*6,0.55,4,12,4 end
    add(enemies,{x=ex,y=ey,vx=0,vy=0,hp=hp,max_hp=hp,spd=spd,r=r,col=col,type=etype,xp_val=xp,hit_cd=0,burn_t=0,bleed_t=0,cryo_t=0,flash=0,shoot_t=flr(rnd(40))})
end

function update_enemies(sim_rate)
    local px,py,pm=p.x,p.y,p.mods
    for e in all(enemies) do
        local ex,ey=e.x,e.y
        if e.hit_cd>0 then e.hit_cd-=1 end
        if e.flash>0 then e.flash-=1 end
        if e.burn_t>0 then e.burn_t-=1 if e.burn_t%8==0 then e.hp-=6*p.dmg_mult e.flash=2 end end
        if e.bleed_t>0 then e.bleed_t-=1 if e.bleed_t%10==0 then e.hp-=8*p.dmg_mult e.flash=2 end end
        local cur_spd=e.spd*sim_rate
        if e.cryo_t>0 then e.cryo_t-=1 cur_spd*=0.45 end
        local dx,dy=px-ex,py-ey
        local d=sqrt(dx*dx+dy*dy)

        if e.boss_kind then
            e.attack_t+=1
            if e.boss_kind=="GOLEM" and e.attack_t%45==0 then for b=0,7 do fire_bullet(ex,ey,cos(b/8)*2,sin(b/8)*2,2,10,14,70) end sfx(4)
            elseif e.boss_kind=="HYDRA" and e.attack_t%30==0 then local a=atan2(dx,dy) for n=-1,1 do fire_bullet(ex,ey,cos(a+n*0.05)*3,sin(a+n*0.05)*3,1.5,11,16,60) end
            elseif e.boss_kind=="DREADNOUGHT" and e.attack_t%20==0 then local a=e.attack_t*0.06 fire_bullet(ex,ey,cos(a)*2.5,sin(a)*2.5,2,8,18,65) end
        elseif e.type=="spitter" and d<80 then
            e.shoot_t+=1
            if e.shoot_t%70==0 then fire_bullet(ex,ey,(dx/d)*1.8,(dy/d)*1.8,2,9,12,60) end
        end

        if d>0.1 then e.vx+=(dx/d)*cur_spd*0.22 e.vy+=(dy/d)*cur_spd*0.22 end
        e.vx,e.vy,e.x,e.y=e.vx*0.86,e.vy*0.86,ex+e.vx,ey+e.vy

        if d<(e.r+3) and p.invul<=0 and not e.no_dmg then
            local dmg=(e.type=="boss" and 25 or (e.type=="brute" and 18 or 10))
            if pm[12]>0 then dmg=flr(dmg*0.6) end
            p.hp-=dmg p.invul=18 p.vx-=dx/d*4 p.vy-=dy/d*4
            shake=6 sfx(4) spawn_floater(px,py-6,"-"..dmg.." HP",8)
        end
        if e.hp<=0 then kill_enemy(e) end
    end
end

function hit_enemy(e,dmg,kx,ky,is_crit)
    combo+=1 combo_t=50
    dmg*=min(3.0,1.0+combo*0.05)
    e.hp-=dmg e.vx+=kx e.vy+=ky e.flash=4
    if p.mods[5]>0 then e.burn_t=45 end
    if p.mods[15]>0 then e.cryo_t=50 end
    p.spec_chg=min(p.spec_max,p.spec_chg+dmg*0.18)
    spawn_floater(e.x,e.y-4,flr(dmg)..(is_crit and "!" or ""),is_crit and 10 or 7)
    if combo>4 and combo%5==0 then spawn_floater(p.x,p.y-10,combo.."X COMBO!",10) end
    for i=1,4 do spawn_part(e.x,e.y,rnd(2)-1,rnd(2)-1,3,e.col) end
end

function kill_enemy(e)
    score+=(e.type=="boss" and 600 or (e.type=="brute" and 100 or 30))*(1+flr(combo*0.1))
    if e==cur_boss then cur_boss=nil shake=14 spawn_floater(64,50,"BOSS DEFEATED",10) end
    del(enemies,e)
    if p.mods[14]>0 then
        for b=1,3 do local ba=b*0.33+rnd(0.1) add(shockwaves,{x=e.x+cos(ba)*8,y=e.y+sin(ba)*8,r=1,max_r=12,dmg=22*p.dmg_mult,life=6}) end
    end
    for i=1,(e.type=="boss" and 10 or (e.type=="brute" and 3 or 1)) do
        add(gems,{x=e.x+rnd(6)-3,y=e.y+rnd(6)-3,vx=rnd(2)-1,vy=rnd(2)-1,val=e.xp_val or 1})
    end
    for i=1,8 do spawn_part(e.x,e.y,rnd(4)-2,rnd(4)-2,flr(rnd(8))+4,rnd({7,8,9,10})) end
end

function update_bullets(sim_rate)
    local px,py,pm=p.x,p.y,p.mods
    for b in all(bullets) do
        local bx,by=b.x+b.vx*(b.is_player and 1 or sim_rate),b.y+b.vy*(b.is_player and 1 or sim_rate)
        b.x,b.y=bx,by
        b.life-=1
        if b.is_player then
            for e in all(enemies) do
                if ((e.x-bx)^2+(e.y-by)^2)<((b.r+e.r)^2) and e.hit_cd<=0 then hit_enemy(e,b.dmg,b.vx*0.5,b.vy*0.5,true) del(bullets,b) break end
            end
        else
            if ((px-bx)^2+(py-by)^2)<((b.r+3)^2) and p.invul<=0 then
                local dmg=pm[12]>0 and flr(b.dmg*0.6) or b.dmg
                p.hp-=dmg p.invul=14 shake=4 sfx(4) spawn_floater(px,py-6,"-"..dmg.." HP",8) del(bullets,b)
            end
        end
        if b.life<=0 then del(bullets,b) end
    end
end

function update_gems()
    local px,py=p.x,p.y
    for g in all(gems) do
        g.vx,g.vy,g.x,g.y=g.vx*0.9,g.vy*0.9,g.x+g.vx,g.y+g.vy
        local dx,dy=px-g.x,py-g.y
        local d=sqrt(dx*dx+dy*dy)
        if d<p.magnet_r then g.vx+=(dx/d)*2.2 g.vy+=(dy/d)*2.2 end
        if d<6 then
            p.xp+=g.val gems_bank+=g.val del(gems,g) sfx(2)
            if mode=="play" and p.xp>=p.max_xp then level_up() end
        end
    end
end

function update_fire_pools()
    for fp in all(fire_pools) do
        fp.life-=1
        if fp.life%6==0 then spawn_part(fp.x+rnd(fp.r*2)-fp.r,fp.y+rnd(fp.r*2)-fp.r,0,-0.4,5,rnd({8,9,10})) end
        for e in all(enemies) do
            if ((e.x-fp.x)^2+(e.y-fp.y)^2)<(fp.r^2) and e.hit_cd<=0 then hit_enemy(e,9*p.dmg_mult,0,0,false) e.burn_t=30 e.hit_cd=8 end
        end
        if fp.life<=0 then del(fire_pools,fp) end
    end
end

function update_shockwaves()
    for sw in all(shockwaves) do
        sw.r+=(sw.max_r-sw.r)*0.3 sw.life-=1
        for e in all(enemies) do
            local dx,dy=e.x-sw.x,e.y-sw.y
            local d=sqrt(dx*dx+dy*dy)
            if abs(d-sw.r)<4 and e.hit_cd<=0 then hit_enemy(e,sw.dmg,(dx/max(1,d))*4,(dy/max(1,d))*4,false) e.hit_cd=6 end
        end
        if sw.life<=0 then del(shockwaves,sw) end
    end
end

function update_lightnings()
    for l in all(lightnings) do l.life-=1 if l.life<=0 then del(lightnings,l) end end
end

function level_up()
    p.lvl+=1 p.xp-=p.max_xp p.max_xp=flr(p.max_xp*1.4)+4 p.hp=min(p.max_hp,p.hp+35)
    mode="levelup" sfx(3) generate_upgrade_cards()
end

function generate_upgrade_cards()
    cards,selected_card={},1
    local pool={} for i=1,18 do pool[i]=i end
    for i=1,3 do
        local r_idx=flr(rnd(#pool))+1
        add(cards,pool[r_idx]) deli(pool,r_idx)
    end
end

function update_levelup(l_click)
    for i=1,#cards do
        local cy=20+(i-1)*32
        if mx>=4 and mx<=124 and my>=cy and my<=cy+30 then
            if selected_card!=i then selected_card=i sfx(0) end
            if l_click then apply_upgrade(cards[selected_card]) mode="play" sfx(3) return end
        end
    end
    if btnp(2) then selected_card=max(1,selected_card-1) sfx(0) end
    if btnp(3) then selected_card=min(#cards,selected_card+1) sfx(0) end
    if btnp(4) or btnp(5) then apply_upgrade(cards[selected_card]) mode="play" sfx(3) end
end

function apply_upgrade(u)
    local pm=p.mods
    pm[u]+=1
    if u==1 then
        p.rope_len+=1 p.rope_segs+=3
        for r in all(p.ropes) do r.seg_len=p.rope_len for s=1,3 do add(r.segs,{x=p.x,y=p.y,ox=p.x,oy=p.y,vx=0,vy=0}) end end
    elseif u==2 then p.flail_size+=1.5 p.dmg_mult+=0.5 p.tip_dmg+=10 for r in all(p.ropes) do r.tip_dmg=p.tip_dmg end
    elseif u==3 then p.num_ropes=min(4,p.num_ropes+1) init_ropes()
    elseif u==6 then p.flail_size+=1
    elseif u==17 then p.magnet_r+=35
    elseif u==18 then p.crit_rate+=0.25 end

    if pm[5]>0 and pm[15]>0 and not p.evo_t then p.evo_t=true spawn_floater(64,50,"EVOLVED: THERMAL SHOCK",10) end
    if pm[4]>0 and pm[11]>0 and not p.evo_s then p.evo_s=true spawn_floater(64,50,"EVOLVED: STORM SHIELD",11) end
    if pm[6]>0 and pm[8]>0 and not p.evo_v then p.evo_v=true spawn_floater(64,50,"EVOLVED: VORTEX SAW",9) end
end

function open_shop()
    mode="shop" sfx(3)
    shop_items={{"HEAL +50 HP",10,"heal","RESTORES +50 CORE HEALTH"},{"EXTRA LIFE",25,"life","REVIVE ON LETHAL DAMAGE"},{"CORD AGILITY",15,"spd","BOOSTS SWING SPEED & SPEED"},{"BLOOD SHRINE",0,"shrine","SACRIFICE 15 HP FOR +35% DMG"}}
end

function update_shop(l_click)
    for i=1,#shop_items do
        local it=shop_items[i]
        local cy=20+(i-1)*19
        if mx>=6 and mx<=122 and my>=cy and my<=cy+17 and l_click then
            if it[3]=="shrine" then
                p.hp=max(1,p.hp-15) p.dmg_mult+=0.35 spawn_floater(64,50,"SHRINE BLESSING!",10) deli(shop_items,i) sfx(6)
            elseif gems_bank>=it[2] then
                gems_bank-=it[2]
                if it[3]=="heal" then p.hp=min(p.max_hp,p.hp+50) elseif it[3]=="life" then p.lives+=1 elseif it[3]=="spd" then p.spd+=0.35 end
                spawn_floater(64,50,"PURCHASED!",11) deli(shop_items,i) sfx(6)
            else sfx(0) end
            return
        end
    end
    if ((mx>=34 and mx<=94 and my>=98 and my<=114 and l_click) or btnp(4) or btnp(5)) then mode="play" start_wave(wave,true) sfx(0) end
end

function spawn_part(x,y,vx,vy,life,col) add(particles,{x=x,y=y,vx=vx,vy=vy,life=life,col=col}) end
function update_particles() for pt in all(particles) do pt.x+=pt.vx pt.y+=pt.vy pt.vx*=0.9 pt.vy*=0.9 pt.life-=1 if pt.life<=0 then del(particles,pt) end end end
function spawn_floater(x,y,txt,col) add(floaters,{x=x,y=y,txt=""..txt,col=col,life=25}) end
function update_floaters() for f in all(floaters) do f.y-=0.4 f.life-=1 if f.life<=0 then del(floaters,f) end end end

function _draw()
    if shake>0 then camera(rnd(shake*2)-shake,rnd(shake*2)-shake) else camera(0,0) end
    cls(0)
    draw_arena()
    if mode=="title" then draw_title()
    elseif mode=="class_select" then draw_class_select()
    elseif mode=="shop" then draw_shop_modal()
    else
        draw_game()
        if mode=="tutorial" then draw_tutorial_hud()
        elseif mode=="levelup" then draw_levelup_modal()
        elseif mode=="gameover" then draw_gameover_modal() end
    end
    draw_cursor(mx,my)
end

function draw_arena()
    rect(1,1,126,126,5)
    for bp in all(bumpers) do circfill(bp[1],bp[2],bp[3],bp[4]>0 and 7 or 1) end
end

function draw_game()
    for fp in all(fire_pools) do circfill(fp.x,fp.y,fp.r,8) end
    for sw in all(shockwaves) do circ(sw.x,sw.y,sw.r,7) end
    for l in all(lightnings) do line(l.x1,l.y1,l.x2,l.y2,11) end
    for g in all(gems) do circfill(g.x,g.y,1.5,10) end
    for b in all(bullets) do circfill(b.x,b.y,b.r,b.col) end

    local px,py,pm=p.x,p.y,p.mods
    for r in all(p.ropes) do
        local segs=r.segs
        local tip=segs[#segs]
        if pm[7]>0 then line(px,py,tip.x,tip.y,8) end
        for i=1,#segs-1 do
            local s1,s2=segs[i],segs[i+1]
            local w_col=r.color
            if (pm[4]>0 or pm[5]>0) and (t+i)%3==0 then w_col=pm[4]>0 and 11 or 9 end
            line(s1.x,s1.y,s2.x,s2.y,w_col)
        end
        if pm[6]>0 then
            local sang=t*0.15
            for a=0,3 do local ba=sang+a*0.25 line(tip.x,tip.y,tip.x+cos(ba)*(p.flail_size+3),tip.y+sin(ba)*(p.flail_size+3),7) end
            circfill(tip.x,tip.y,p.flail_size-1,8)
        else
            circfill(tip.x,tip.y,p.flail_size,pm[5]>0 and 9 or (pm[4]>0 and 11 or (pm[15]>0 and 12 or 7)))
            circ(tip.x,tip.y,p.flail_size,0) pset(tip.x,tip.y,10)
        end
    end

    if pm[11]>0 then circfill(px+cos(p.shield_ang)*18,py+sin(p.shield_ang)*18,3,11) end

    for e in all(enemies) do
        local c=e.flash>0 and 7 or (e.cryo_t>0 and 12 or e.col)
        if e.is_turret or e.type=="boss" or e.type=="brute" then rectfill(e.x-e.r,e.y-e.r,e.x+e.r,e.y+e.r,c) rect(e.x-e.r,e.y-e.r,e.x+e.r,e.y+e.r,7)
        elseif e.type=="spitter" then circfill(e.x,e.y,e.r,c) circ(e.x,e.y,e.r,7)
        elseif e.type=="sprinter" then line(e.x-e.vx*1.5,e.y-e.vy*1.5,e.x,e.y,10) circfill(e.x,e.y,e.r,c)
        else circfill(e.x,e.y,e.r,c) if e.no_dmg then circ(e.x,e.y,e.r,7) end end
    end

    for pt in all(particles) do pset(pt.x,pt.y,pt.col) end
    for f in all(floaters) do print(f.txt,f.x-flr(#f.txt*2),f.y,f.col) end

    camera(0,0)
    draw_hud()
end

function draw_tutorial_hud()
    local tut_txt={
        "[DRILL 1] SWING FLAIL INTO TARGET BOTS!",
        "[DRILL 2] HOLD & RELEASE L-CLICK: WHIP SNAP!",
        "[DRILL 3] PARRY INCOMING BULLET WITH FLAIL!",
        "[DRILL 4] RIGHT-CLICK: FULL SCREEN PULSE!",
        "CALIBRATION COMPLETE! COMMENCING..."
    }
    local msg=tut_txt[tut_step] or ""
    rectfill(2,118,126,126,0) rect(2,118,126,126,10)
    print(msg,64-flr(#msg*2),120,t%8<4 and 10 or 7)
end

function draw_cursor(cx,cy)
    line(cx,cy,cx,cy+6,7) line(cx,cy,cx+5,cy+5,7) line(cx,cy+6,cx+5,cy+8,7) pset(cx+1,cy+2,0)
end

function draw_bar(x,y,w,h,val,max_val,bg,fg)
    rectfill(x,y,x+w,y+h,0) rect(x,y,x+w,y+h,bg) rectfill(x+1,y+1,x+1+(val/max_val)*(w-2),y+h-1,fg)
end

function draw_hud()
    draw_bar(2,2,40,4,p.hp,p.max_hp,5,p.hp<30 and 8 or 11)
    draw_bar(46,2,40,4,p.xp,p.max_xp,1,10)
    draw_bar(90,2,35,4,p.spec_chg,p.spec_max,12,p.spec_chg>=p.spec_max and 9 or 12)
    print("LV"..p.lvl.." W:"..wave.." G:"..gems_bank.." SC:"..score,3,9,7)
    if p.lives>0 then print("+"..p.lives.."L",112,9,11) end
    if combo>1 then print(combo.."X",102,16,10) end
    if cur_boss then draw_bar(20,16,88,6,cur_boss.hp,cur_boss.max_hp,8,8) print(cur_boss.name,22,11,7) end
end

function draw_box(x,y,w,h,c1,c2)
    rectfill(x,y,x+w,y+h,0) rect(x,y,x+w,y+h,c1)
    if c2 then rect(x+2,y+2,x+w-2,y+h-2,c2) end
end

function draw_levelup_modal()
    draw_box(2,4,124,120,7,10)
    print("== CHOOSE AN UPGRADE ==",16,9,10)
    for i=1,#cards do
        local id=cards[i] local cy=18+(i-1)*32 local is_sel=i==selected_card
        rectfill(6,cy,122,cy+30,is_sel and 12 or 1) rect(6,cy,122,cy+30,is_sel and 7 or 5)
        print(u_names[id],10,cy+4,is_sel and 10 or 7)
        print(u_descs[id],10,cy+15,is_sel and 11 or 6)
    end
    print("CLICK TO SELECT",34,116,t%6<3 and 7 or 6)
end

function draw_shop_modal()
    draw_box(4,4,120,118,10,9)
    print("== MID-RUN SHOP ==",24,9,10) print("GEMS: "..gems_bank,80,9,7)
    for i=1,#shop_items do
        local it=shop_items[i]
        local cy=18+(i-1)*20
        local can_buy=it[3]=="shrine" or gems_bank>=it[2]
        rectfill(8,cy,120,cy+18,can_buy and 1 or 0) rect(8,cy,120,cy+18,can_buy and 7 or 5)
        print(it[1],12,cy+3,can_buy and 10 or 5)
        print(it[3]=="shrine" and "SACRIFICE" or it[2].." GEMS",70,cy+3,can_buy and 7 or 5)
        print(it[4],12,cy+11,can_buy and 6 or 5)
    end
    rectfill(34,99,94,114,12) rect(34,99,94,114,7) print("CONTINUE [Z]",38,104,7)
end

function draw_title()
    camera(0,0)
    draw_box(4,4,120,120,7,1)
    print("FLAIL RAIL",44,12,10)
    print("PHYSICS ROGUELIKE",30,21,7)

    -- Lore Box
    rectfill(8,29,120,62,0) rect(8,29,120,62,5)
    print("> SECTOR-32 CORRUPTED\n> VOLTAGE SURGES DETECTED\n> OVERCLOCK TETHER\n> PURGE BEFORE MAGIC SMOKE",12,32,6)

    -- Menu Buttons
    local menu_lbls={"START MISSION","LIVE COMBAT DRILL","WEAPON CLASS"}
    for i=1,3 do
        local cy=66+(i-1)*15
        local is_sel=i==title_opt
        rectfill(12,cy,116,cy+13,is_sel and 12 or 1)
        rect(12,cy,116,cy+13,is_sel and 10 or 5)
        print(menu_lbls[i],20,cy+4,is_sel and 10 or 7)
    end

    if hi_score>0 then print("HI-SCORE: "..hi_score,40,113,9)
    else print("CLICK OR PRESS [Z] TO SELECT",10,113,t%8<4 and 7 or 10) end
end

function draw_class_select()
    camera(0,0)
    draw_box(4,4,120,120,10,7)
    print("== WEAPON LOADOUT ==",24,10,10)
    for i=1,#classes do
        local c=classes[i]
        local cy=24+(i-1)*20
        local is_sel=i==sel_class
        rectfill(8,cy,120,cy+18,is_sel and 12 or 1)
        rect(8,cy,120,cy+18,is_sel and 10 or 5)
        print(c[1],12,cy+3,is_sel and 10 or 7)
        if is_sel then print("[EQUIPPED]",72,cy+3,11) end
        print(c[9],12,cy+11,is_sel and 7 or 6)
    end
    rectfill(12,106,60,119,10) rect(12,106,60,119,7) print("DEPLOY [Z]",16,110,0)
    rectfill(68,106,116,119,1) rect(68,106,116,119,5) print("< BACK [X]",74,110,7)
end

function draw_gameover_modal()
    draw_box(16,32,96,64,8,0)
    print("GAME OVER\n\nWAVE: "..wave.." SCORE: "..score.."\n\n\nCLICK TO RETRY",26,42,8)
end