function _init()
    _global_init()
    _title_init()
    _tips_init()
    _shaft_init()
    _foundary_init()
    _player_init()
end
function _update()
    if global.state == 'title' then
        _title_update()
    end
    if global.state == 'tips' then
        _tips_update()
    end
    if global.state == 'shaft' then
        _shaft_update()
        _player_update()
        _explosions_update()
        _steam_update()
    end
    if global.state == 'foundary' then
        _foundary_update()
    end
    if global.state == 'shatter' then
        global.shatter_timer-=1
        if btnp(❘) and global.shatter_timer <0  then
            reset_game()
            global.prestige = 1
            global.state = 'title'
        end
    end
    global.tick = global.tick+1
end
function _draw()
    if global.state == 'title' then
        _title_draw()
    end
    if global.state == 'tips' then
        _tips_draw()
    end
    if global.state == 'shaft' then
        _shaft_draw()
        _get_ores()
        _player_draw()
        _fx_draw()
        _steam_draw()
    end
    if global.state == 'foundary' then
        _foundary_draw()
    end
    if global.state == 'shatter' then
        _shatter_draw()
    end
end
function _global_init()
    global = {
        state = 'title',
        tick = 0,
        prestige=1,
        struggle_count = 0,
        launch_press = 0,
        launch_delay = 15
    }
end
function _shatter_draw()
    cls(0)
    print('', 5, 5, 8)
    for key, value in pairs(explode_string('the missile plunged deep into the planet\'s core before erupting. continental plates crackled and popped apart into smaller and smaller fragments. the local inhabitants were reduced to char. more elements for the empire. you have exceeded all expectations and will return to a hero\'s welcome and a 20% credit bonus. all hail death, destroyer of worlds')) do
        print(value)
    end
end
function explode_string(string)
    _max = 17
    if (#string<26) _max = 8
    local lines ={}
    local letter_count = 1
    while #string>0 do
        if ( (sub(string, letter_count, letter_count)==' ' and letter_count > _max) or letter_count > #string ) then
            add(lines, sub(string, 0, letter_count-1))
            string =  sub(string, letter_count+1)
            letter_count = 0
        end
        letter_count+=1
    end
    return lines
end
function _load_player()
    if cartdata("missile_in_a_mineshaft_player") then
    for key, upgrade in pairs( upgrades ) do
        upgrade.active = dget(key)==1 and true or false
    end
    for key = 1, 8 do
        inventory[ores[key].name] = dget(key+22)
    end
    global.prestige = dget(35)
    end
end
function _save_player()
    cartdata("missile_in_a_mineshaft_player")
    for key, upgrade in pairs( upgrades ) do
        dset(key, upgrade.active and 1 or 0)
    end
    for key = 1, 8 do
        dset(key+22, inventory[ores[key].name])
    end
    dset(35, global.prestige)
end


function _title_init()
    title_menu = {
        'launch',
        'tips',
        'reset'
    }
    menu_selection=1
    menu_y=100
    ship = {
        x=0,
        y=0
    }
    smoke={}
    zap = {}
    for i=0, 12 do
        dir = 5+rnd(15/(i+1))
        if i%2==0 then dir = -dir end
        add(zap, {
            x=dir+ ((64/12)*i),
            y=i*(2+i),
        })
    end
end

function _title_update()
    -- global.tick = global.tick+1
    if (global.tick%3  == 0) then
        ship.x = flr(rnd(3))-1
        ship.y = flr(rnd(3))-1
        add(smoke, {
            x=rnd(4),
            y=rnd(4),
            t=0
        })
    end
    for skey, cloud in pairs(smoke) do
        cloud.t = cloud.t+0.01
        if (cloud.t>1 ) then deli(smoke, skey) end
    end
    if btnp(⬆️) then
       menu_selection = max(menu_selection-1, 1)
       sfx(3)
    end
    if btnp(⬇️) then
       menu_selection = min(menu_selection+1, 3)
       sfx(3)
    end
    if (btn(🅾️)) then
        if (menu_selection == 1) then
            global.state = 'shaft' music(0)
        end
        if (menu_selection == 2) then
            global.state = 'tips'
        end
        if (menu_selection == 3) then
            for key = 1, 34 do
                dset(key, 0)
            end
            dset(35, 1)
            run()
        end
    end
end
function _title_draw()
    cls(0)
    -- rectfill(1, 1, 126, 126, 2)
    for skey, cloud in pairs(smoke) do
        sx=34 + (5*(cloud.x-2)) - sin(0.4+(0.5 * cloud.t))*10
        sy=40+(cloud.y) - (30*cloud.t)
        sr=8-(7*cloud.t)
        col = 1
        if cloud.t<0.6 then col = 13 end
        if cloud.t<0.5 then col = 6 end
        if cloud.t<0.2 then col = 7 end
        circfill(sx, sy, sr, col)
    end
    for key, value in pairs(zap) do
        n=0
        px = 0
        py = 0
        if ( key > 1) then
            py = zap[key-1].y
            px = zap[key-1].x
            offset = -value.x+px
        end
        for i = 1, value.y-py do
            line(128, py+i, 64+px-(i*offset/(value.y-py)), py+i, 2)
        end
    end
    for key, value in pairs(zap) do
        n=0
        px = 0
        py = 0
        if ( key > 1) then
            py = zap[key-1].y
            px = zap[key-1].x
            offset = -value.x+px
        end
        for i = 1, value.y-py do
            line(0, 84+(py+i)/2, px-(i*offset/(value.y-py)), 84+(py+i)/2, 2)
        end
    end
    spr(51, 25+ship.x, 25+ship.y, 5, 5)
    print('missile in a', 40, 76, 2)
    print('mineshaft')
    print('a roguelike')

    for key, value in pairs(title_menu) do
       print(value, 60, 92+key*8, 5)
    end

    menu_y_target = 92+(menu_selection*8)
    if menu_y > menu_y_target then
        menu_y-=2
    elseif menu_y < menu_y_target then
        menu_y+=2
    end

    rectfill(49, menu_y-2, 60+ 4*(#title_menu[menu_selection]), menu_y+6, 1)
    pset(49, menu_y-2, 0)
    pset(60+ 4*(#title_menu[menu_selection]), menu_y-2, 0)
    pset(49, menu_y+6, 0)
    pset(60+ 4*(#title_menu[menu_selection]), menu_y+6, 0)
    print(title_menu[menu_selection], 60, menu_y_target, 7)
    print('🅾️', 51, menu_y, 8)

end

function _tips_init()
    pulse = 0
    text = 0
end

function _tips_update()
    pulse+=0.02
    text+=1
    if pulse >=1 then
        pulse =0
    end

    if (btnp(🅾️) and text > 50) then
        global.state = 'shaft' music(0)
    end
end

function _tips_draw()
    cls(0)
    for key, value in pairs(explode_string('make careful selections with your upgrades. some will help you steer, brake or otherwise avoid collisions. avoid hitting the walls with your missile\'s warhead')) do
        print(sub(value, 0, max(0,text-key)), 10, key*9, 7)
        print(sub(value, 0, max(0,text-key-2)), 10, key*9, 10)
        print(sub(value, 0, max(0,text-key*key/3-8)), 10, key*9, 9)
    end

    rect(110-20, 76, 110, 76+20, 9)
    pal(8, 5)
    pal(2, 5)
    spr(17, 94, 82)
    pal(8, 8)
    pal(2, 2)
    line(97,87, 97, 89, 8)
    spr(35, 101, 85+sin(pulse)*1.5)

    print('🅾️ launch!', 10, 100, 9)
    print('🅾️', 10, 100, 8)

end


function _shaft_init()
    shaft = {
        speed= 0,
        y=0,
        strata ={},
    }
    explosions = {}
    reset_shaft()
    biome = {
        length=8
    }
    get_ores_queue = {}
end
function _shaft_update()
    shaft.y = shaft.y+shaft.speed
    if (flr(shaft.y/shaft.strata_height)>shaft.strata_count) then
        if (shaft.biome == 1) then
            if ( rnd(3) < 1 ) then shaft.point = -shaft.point end
            w = shaft.strata[#shaft.strata]['w'] + rnd(10)-5
            c = shaft.strata[#shaft.strata]['c'] + shaft.point
        elseif (shaft.biome == 2) then
            w = rnd(40)+20
            c = shaft.strata[#shaft.strata]['c'] + rnd(20)-10
        elseif (shaft.biome == 3) then
            w = rnd(40)+20
            if (flr(rnd(14))==1) then
                w=70
                c = shaft.strata[#shaft.strata]['c'] + 30
            elseif (flr(rnd(14))==2) then
                w=70
                c = shaft.strata[#shaft.strata]['c'] - 30
            else
                w = max(12, shaft.strata[#shaft.strata]['w'] + rnd(30)-16)
                c = shaft.strata[#shaft.strata]['c'] + rnd(4)-2
            end
        elseif (shaft.biome == 4) then
            w=75 + rnd(10)
            c=64 + rnd(10)-5
            if (flr(rnd(8-global.prestige)) == 0) then
                add(shaft.objects, {x=flr(rnd(100)+14),y=flr(shaft.y+140), r=flr(5+rnd(10)), c=ores[shaft.biome].c})
            end
        elseif (shaft.biome == 5) then
            if ( rnd(3) < 1 ) then shaft.point = -shaft.point end
            w = shaft.strata[#shaft.strata]['w'] + rnd(10)-5
            c = shaft.strata[#shaft.strata]['c'] + shaft.point
            if (flr(rnd(8-global.prestige)) == 0) then
                add(shaft.objects, {x=flr(rnd(100)+14),y=flr(shaft.y+140), r=flr(5+rnd(10)), c=ores[shaft.biome].c})
            end
        elseif (shaft.biome == 6) then
            w = rnd(40)+20
            c = shaft.strata[#shaft.strata]['c'] + rnd(20)-10
            if (flr(rnd(8-global.prestige)) == 0) then
                add(shaft.objects, {x=flr(rnd(100)+14),y=flr(shaft.y+140), r=flr(5+rnd(10)), c=ores[shaft.biome].c})
            end
        elseif (shaft.biome == 7) then
            w=75 + rnd(10)
            c=64 + rnd(10)-5
            if (flr(rnd(7-global.prestige)) == 0) then
                add(shaft.objects, {x=flr(rnd(100)+14),y=flr(shaft.y+140), r=flr(5+rnd(10)), c=ores[shaft.biome].c})
            end
        else
            w = rnd(40)+20
            c = shaft.strata[#shaft.strata]['c'] + rnd(20)-10
            add(shaft.objects, {x=flr(rnd(100)+14),y=flr(shaft.y+140), r=flr(5+rnd(10)), c=ores[shaft.biome].c})
        end

        if (c < 20 or c > 108) then
            c=(-63 + c)/2+63
            w=50
        end
        w = max(24-global.prestige, w)
        add(shaft.strata, {
            c=c,
            w=w,
            o=ores[shaft.biome].c,
            gem={
                size = rnd(4)+((global.struggle_count+global.prestige)>9 and 1 or 0),
                x = rnd(120)+4
            }
        })
        if(#shaft.strata > (144/shaft.strata_height)) then
            deli(shaft.strata, 1)
        end
        for okey, object in pairs(shaft.objects) do
            if (object.y < shaft.y-50) then
                deli(shaft.objects, okey)
            end
        end
        shaft.strata_count = shaft.strata_count+1
        shaft.biome = min(8,ceil(shaft.y/(128*biome.length)))
        if (player.state == 'live') then
            if (shaft.speed < 1) then
                shaft.speed = min(shaft.speed+1.2,shaft.top_speed)
            else
                shaft.speed = min(shaft.speed+player.drag,shaft.top_speed)
            end
        else
        shaft.speed = 0 -- shaft.speed/2
        end
    end
end
function _shaft_draw()
    cls(0)
    for key,value in pairs(shaft.strata) do
        y=flr(shaft.strata_height*key-(shaft.y%shaft.strata_height)-16)
        l_x = value['c']-(value['w']/2)
        r_x = value['c']+(value['w']/2)
        if(key > 1) then
            pre_y = shaft.strata_height*(key-1)-(shaft.y%shaft.strata_height)-16
            pre_l_x = shaft.strata[key-1]['c']-(shaft.strata[key-1]['w']/2)
            pre_r_x = shaft.strata[key-1]['c']+(shaft.strata[key-1]['w']/2)
        else
            pre_y = 0
            pre_l_x = 0
            pre_r_x = 128
        end
        for i=1, 8 do
            offset = -pre_l_x+l_x
            line(pre_l_x+ceil(offset/7*i)-1, y-7+i, -1, y-7+i, value.o)
        end
        if (pre_l_x > l_x) then
            for i=1, 3 do
                line(l_x, y-(value['w']/12), l_x+i, y, 0)
            end
        end
        for i=1, 8 do
            offset = -pre_r_x+r_x
            line(pre_r_x+ceil(offset/7*i)+1, y-7+i, 128, y-7+i, value.o)
        end
        if (pre_r_x < r_x) then
            for i=1, 3 do
                line(r_x, y-(value['w']/12), r_x-i, y, 0)
            end
        end
        if (player.sonar and value.gem.size > 0) then
            if pget(value.gem.x, y) > 0 and pget(value.gem.x, y-6) > 0 then
                palt(0,false)
                palt(13,true)
                if ores[shaft.biome+1] then
                    pal(8, ores[shaft.biome+1].c)
                    if (value.gem.size >= 3 ) then
                        spr(10, value.gem.x-4, y-6, 1, 2, value.gem.x > value.c)
                    elseif(value.gem.size >= 2 ) then
                        spr(11, value.gem.x-4, y-6, 1, 1, value.gem.x > value.c)
                    end
                    pal(8, 8)
                end
                palt(13,true)
                palt(0,true)
            end
        end
    end
    for key,value in pairs(shaft.objects) do
        sy = value['y']-shaft.y
        local r = value['r']+1
        circfill(value['x'], sy, value['r'], value['c'])
        palt(0,false)
        palt(7, true)
        for i=0, 360, 36 do
            spr((i/36%4)+3, value['x']-4 + cos(i/360)*r, sy-4 + sin(i/360)*r)
        end
        palt(0,true)
        palt(7, false)
    end
end
function reset_shaft()
    shaft = {
        biome = 1,
        y = 0,
        speed = 1+(global.prestige*0.1),
        top_speed=4+global.prestige*0.25,
        strata = {},
        strata_count=0,
        strata_height=8,
        objects = {},
        point = 5
    }
    explosions={}
    for i = 1, (128/shaft.strata_height)+3 do
        add(shaft.strata, {c=63,w=218+rnd(10)-i*8, o=13, gem={size = 0, x=64}})
    end
end
function _get_ores()
    for key, ore in pairs(get_ores_queue) do
        total_ore = 0
        for i=ore.y-ore.r*0.75, ore.y+ore.r*0.75, 1 do
            for j=ore.x-ore.r*0.75, ore.x+ore.r*0.75, 7-global.prestige do
                col = pget(j,i)
                ore_col = col_map[col]
                if not ore_col then ore_col = 0 end
                if ore_col>0 then
                    sack[ore_col] = sack[ore_col]+1
                    total_ore = total_ore+1
                end
            end
        end
        add(shaft.objects, {x=ore.x,y=flr(shaft.y+ore.y), r=ore.r, c=0})
        set_explosion(ore.x,ore.y, flr(total_ore/5))
        deli(get_ores_queue, key)
    end
end


function _player_init()

    explosion = {
        timer = 0
    }
    steam = {}
    upgrades = {
        {
            name='fins',
            description='provides basic aiming',
            active=false,
            cost={
                iron=15
            }
        },
        {
            name='rudder',
            description='provides exceptional steering',
            active=false,
            cost={
                iron=60
            }
        },
        {
            name='yield+',
            description='more destructive power provides more ore extracted',
            active=false,
            cost={
                iron=40
            }
        },
        {
            name='yield++',
            description='enormous amounts of ore extracted',
            active=false,
            cost={
                iron=120,
                radium=15,
            }
        },
        {
            name='chute',
            description='one chute will slow the missile by pressing ⬆️',
            active=false,
            cost={
                iron=20,
                copper=35
            }
        },
        {
            name='chute+',
            description='lead based ballooning provide +2 chutes',
            active=false,
            cost={
                copper=400,
                lead=60
            }
        },
        {
            name='booster',
            description='hold ⬅️ or ➡️ then hit 🅾️ to decelerate burst sideways',
            active=false,
            cost={
                copper=120,
                lead=3
            }
        },
        {
            name='explode',
            description='hold ❘ to detonate prematurely and with more force',
            active=false,
            cost={
                lead=120,
                radium=200
            }
        },
        {
            name='sonar',
            description='detect rare ores in the wall',
            active=false,
            cost={
                iron=30,
                copper = 50,
                radium = 60
            }
        },
        {
            name='flank',
            description='press ⬅️ or ➡️ and ❘ to deploy a sub-charge left or right',
            active=false,
            cost={
                lead=120,
                gold=60
            }
        },
        {
            name='flank+',
            description='adds +3 sub-charges',
            active=false,
            cost={
                gold=200,
                silica=60
            }
        },
        {
            name='flank++',
            description='adds +6 sub-charges',
            active=false,
            cost={
                gold=2000,
                silica=600
            }
        },
        {
            name='charge+',
            description='increases sub-charge power',
            active=false,
            cost={
                radium=700,
                silica=5,
                gold=60
            }
        },
        {
            name='drill',
            description='❘ to use powerful front facing canon with long charge time',
            active=false,
            cost={
                copper=400,
                gold=60
            }
        },
        {
            name='drill+',
            description='front facing canon is bigger',
            active=false,
            cost={
                silica=1200,
                thorium=600
            }
        },
        {
            name='reactor',
            description='front facing canon recharges faster',
            active=false,
            cost={
                silica=120,
                thorium=60,
                bismuth=15
            }
        },
        {
            name='buster',
            description='hold ⬇️ to deploy  bunker buster that travels through rock',
            active=false,
            cost={
                silica=15,
                lead=300,
                thorium=5
            }
        },
        {
            name='buster+',
            description='adds much more power to the bunker buster',
            active=false,
            cost={
                lead=1200,
                copper=600,
                thorium=100
            }
        },
        {
            name='reset',
            description='reset progress for faster cooldowns and denser ores',
            active=false,
            cost={
                silica=600,
                thorium=600,
                bismuth=600,
            }
        },
        {
            name='shatter',
            description='shatters the planet allowing for complete resource gain',
            active=false,
            cost={
                silica=30000,
                thorium=30000,
                bismuth=30000
            }
        },
    }
    _load_player()
    reset_player()
end
function _player_update()
    if (player.state == 'live') then
        if (btn(⬅️)) then player.d_x = player.d_x-player.speed end
        player.d_x = max(player.d_x, player.p_x-player.reach_x)
        if (btn(➡️)) then player.d_x = player.d_x+player.speed end
        player.d_x = min(player.d_x, player.p_x+player.reach_x)

        if btnp(⬆️) and player.vincible then
                chute_deploy()
        end

        if btn(⬅️) and btnp(🅾️) and player.boost_timer <= 0 and player.vincible then
                boost_side(-1)
        elseif btn(➡️) and btnp(🅾️) and player.boost_timer <= 0 and player.vincible then
                boost_side(1)
        end

        if btnp(⬇️) and player.buster > 0 and player.buster_keypress==0 then
            sfx(2, 2)
        end
        if btn(⬇️) and player.buster > 0 then
            player.buster_keypress = player.buster_keypress+1
        else
            sfx(-1,2)
            player.buster_keypress = 0
        end
        if(player.buster_keypress > 20) then
            bust_bunker()
        end
        if(player.buster_timer > 0) then
            busting_bunker()
        end
        if btn(❘) then
            if player.fuse then
                player.fuse_timer = player.fuse_timer -1
                if (player.fuse_timer <= 0) then
                    player.detonate = player.detonate * 2
                    player.vincible = true
                    player.state = 'exploding'
                end
            end
        else
            player.fuse_timer = 18
        end

        if btnp(❘) and btn(⬅️) then
            deploy_charge(-1)
        end
        if btnp(❘) and btn(➡️) then
            deploy_charge(1)
        end
        if (btnp(❘) and player.drill and player.drill_timer <=0) then
            deploy_drill()
        elseif player.drill_timer >= 0 then
            player.drill_timer = player.drill_timer-1
        end

        player.d_x = min(max(player.d_x, 1), 126)
        player.d_y = min(max(player.d_y, 1), 126)
        player.p_x = player.p_x*player.accel+player.d_x*(1-player.accel)
        player.p_y = player.p_y*player.accel+player.d_y*(1-player.accel)

        add_steam(0,0,1)

        if player.booster then
            player.boost_timer = max( 0, player.boost_timer - 1)
        end

    elseif (player.state == 'exploding') then
        if (explosion.timer == 0) then
            sfx(4)
            music(-1)
            get_ore(player.p_x, player.p_y, player.detonate)
        end

        explosion.timer=explosion.timer+1
        if (explosion.timer > 60) then
            reset_shaft()
            reset_player()
            global.state = 'foundary'
        end
    end
end
function _player_draw()
    if (player.state == 'live') then

        if (player.vincible and pget(player.p_x, player.p_y+3) != 0) then
            player.state='exploding'
        else
            if(player.fuse_timer%2 == 1) then
                pal(8, 10)
            end
            spr(player.sprite, player.p_x-3, player.p_y-4)
            pal(8, 8)
            if (active('fins')) then
                spr(19, player.p_x-3, player.p_y-4)
            end
            draw_chute()
            if player.drill_timer>0 then
                pset(player.p_x, player.p_y+3, 5)
            end
        end
    end

end
function reset_player()
    player = {
        state = 'live',
        sprite = 16,
        p_x=64,
        p_y=31,
        d_x=64,
        d_y=31,
        reach_x=15,
        reach_y=5,
        speed=0.3,
        accel=0.9,
        drag=0.02,
        chutes=12,
        chute_timer=0,
        detonate=10,
        booster=false,
        boost_timer=30,
        fuse = false,
        fuse_timer = 18,
        sonar=false,
        flank = 0,
        flank_r = 10,
        drill = false,
        drill_w = 0,
        drill_timer = 0,
        drill_lifetime = 60,
        buster = 0,
        buster_timer = 0,
        buster_lifespan = 0,
        buster_keypress = 0,
        vincible = true
    }
    explosion.timer = 0
    check_upgrades()
end
function check_upgrades()
    if (active('fins')) then
        player.speed = 1
    end
    if (active('rudder')) then
        player.speed = 3
    end
    if (active('yield+')) then
        player.detonate = 15
        player.sprite = 17
    end
    if (active('yield++')) then
        player.detonate = 30
        player.sprite = 18
    end
    player.chutes = 0
    if (active('chute')) then
        player.chutes = player.chutes + 1
        global.launch_delay = 7
    end
    if (active('chute+')) then
        player.chutes = player.chutes + 2
    end
    if active('booster') then
        player.booster = true
    end
    if active('explode') then
        player.fuse = true
    end
    if active('sonar') then
        player.sonar = true
    end
    player.flank = 0
    player.flank_r = 10
    if active('flank') then
        player.flank = player.flank + 1
    end
    if active('flank+') then
        player.flank = player.flank + 3
    end
    if active('flank++') then
        player.flank = player.flank + 6
    end
    if active('charge+') then
        player.flank_r = player.flank_r + 10
    end
    player.drill_w = 15
    if active('drill') then
        player.drill = true
    end
    if active('drill+') then
        player.drill_w = player.drill_w+5
    end
    if active('reactor') then
        player.drill_lifetime = 66 - global.prestige*11
    end
    if active('buster') then
        player.buster = 1
        player.buster_lifespan = 1
    end
    if active('buster+') then
        player.buster_lifespan = player.buster_lifespan+1+global.prestige/3
    end
    if active('reset') then
        reset_game()
    end
end

function reset_game()
    global.prestige = min(global.prestige+1, 6)
    for key, value in pairs(upgrades) do
        value.active = false
    end
    for i=1, 8 do
        inventory[ores[i].name] = 0
    end
    reset_player()
end

function find_upgrade(name)
    for key, value in pairs(upgrades) do
        if (value.name == name) then
            return upgrades[key]
        end
    end
end
function active(name)
    return find_upgrade(name).active
end
function chute_deploy()
   if (player.chutes>0 and player.chute_timer <= 0) then
    shaft.speed = 1.1
    player.chutes = player.chutes-1
    player.chute_timer = 2*30
end
end
function draw_chute()
    if player.chute_timer > 0 then
        if player.chute_timer > 50 then
            spr(12, player.p_x-4, player.p_y-8)
        elseif player.chute_timer > 10 or player.chute_timer/2 == flr(player.chute_timer/2) then
            spr(13, player.p_x-7, player.p_y-11)
            spr(14, player.p_x, player.p_y-11)
        end
        player.chute_timer-=1
    end
end
function boost_side(dir)
    sfx(6)
    if (player.boost_timer <= 0) then
        player.d_x = player.p_x+50*dir
    end
    player.boost_timer = 45-(global.prestige*2)
    shaft.speed = 2.5
    for i=1, 30 do
        add_steam(1,0,3)
    end
end
function deploy_charge(dir)
    if player.flank > 0 then
        player.flank = player.flank-1
        sfx(5)
        get_ore(player.p_x+dir*30, player.p_y, player.flank_r)
    end
end
function deploy_drill()
    sfx(1)
    player.drill_timer = player.drill_timer+player.drill_lifetime
    get_ore(player.p_x, player.p_y+4+player.drill_w, player.drill_w)
    get_ore(player.p_x, player.p_y+player.drill_w*1.5+player.drill_w, player.drill_w)
end
function bust_bunker()
    player.buster = player.buster-1
    player.buster_keypress = 0
    player.buster_timer = shaft.y+128*biome.length*player.buster_lifespan
    player.vincible = false
    shaft.speed = 4
    player.speed = 1
end
function busting_bunker()
    get_ore(player.p_x, player.p_y+12, 12)
    if (player.buster_timer-shaft.y < 120) then
        sfx(5)
    else
        sfx(6)
    end
    if(shaft.y > player.buster_timer) then
        busted_bunker()
        sfx(-1)
    end
end
function busted_bunker()
    player.vincible = true
    player.buster_timer=0
    shaft.speed = 1.8
    player.speed = 0.3
    if (active('fins')) then
        player.speed = 1
    end
    if (active('rudder')) then
        player.speed = 3
    end
end


function _foundary_init()
    ores = {
        {name = 'iron', c = 13},
        {name = 'copper', c = 4},
        {name = 'radium', c = 3},
        {name = 'lead', c = 2},
        {name = 'gold', c = 9},
        {name = 'silica', c = 10},
        {name = 'thorium', c = 12},
        {name = 'bismuth', c = 11},
    }
    selected=1
    col_map = {}
    for key, value in pairs(ores) do
        col_map[value.c] = key
    end
    col_map[0] = 0
    inventory = {}
    for i=1, 8 do
        inventory[ores[i].name] = 0
    end
    reset_sack()
    launch_pressed = false
end
function _foundary_update()
    for key, value in pairs(sack) do
        if (sack[key] > 0) then
            chunk = 1000
            if (sack[key] < 2000) then
                chunk = 100
            end
            if (sack[key] < 200) then
                chunk = 10
            end
            if (sack[key] < 20) then
                chunk = 1
            end
            sack[key] = sack[key]-chunk
            inventory[ores[key].name] = inventory[ores[key].name]+chunk*global.prestige
            if inventory[ores[key].name] < 0 then inventory[ores[key].name] = 32767 end
        end
    end

    if (btnp(⬅️)) then selected = max(selected-1, 1) sfx(3) end
    if (btnp(➡️)) then selected = min(selected+1, #upgrades) sfx(3)end
    if (btnp(⬆️)) then selected = max(selected-3, 1) sfx(3) end
    if (btnp(⬇️)) then selected = min(selected+3, #upgrades) sfx(3) end
    if (btnp(🅾️) and global.launch_press == 0) then
        sfx(7,2)
    end
    if (btn(🅾️)) then
        global.launch_press+=1
        if (global.launch_press > global.launch_delay) then
            sfx(1)
            _save_player()
            reset_player()
            music(0)
            global.struggle_count+=1
            global.state = 'shaft'
        end
    end
    if (btn(🅾️) == false and global.launch_press > 0) then
        sfx(-1,2)
        global.launch_press = 0
    end
    if (btnp(❘)) then
        if (check_cost(upgrades[selected])) then
            sfx(0)
            global.struggle_count = 0
            for key, value in pairs(upgrades[selected].cost) do
                inventory[key] = inventory[key] - value
            end
            upgrades[selected].active = true
            if upgrades[selected].name == 'shatter' then
                global.shatter_timer = 30;
                global.state='shatter'
            end
        else
            sfx(1)
        end
    end
end
function _foundary_draw()
    cls(0)
    rectfill(0,0, 40,8,9)
    if (global.launch_press > 0) then
        rectfill(0,0, (global.launch_press/global.launch_delay*40),8, 10)
        rectfill((global.launch_press/global.launch_delay*40),0, (global.launch_press/global.launch_delay*40),8, 7)
    end
    print('🅾️ launch', 2, 2, 0)
    if global.prestige >= 6 then
        print('prestige: maximum', 60, 2, 8)
    elseif global.prestige > 1 then
        print('prestige: '..global.prestige, 84, 2, 10)
    else
        print('foundary', 96, 2, 10)
    end
-- inventory
color(7)
print('', 2,10)
for i = 1, #ores do
    print(ores[i].name, 1, i*14+2, 5)
    if inventory[ores[i].name] == 32767 then
        print('maximum', 1, i*14+8, 8)
    else
        print(inventory[ores[i].name], 1, i*14+8, ores[i].c)
    end
end
print('', 50,10)
cols=3
gap=2
width=(7*4)+2+gap
height=10
start=128-(width*cols)
--selections
for key, value in pairs(upgrades) do
    col = ((key-1) % cols)+1
    row = flr((key-1) / cols)+1
    x = start+(col*width-width)
    y = 1+(row*height-height)+13

    value.affordable=true

    for ckey, cvalue in pairs(value.cost) do
        if cvalue > inventory[ckey] then
            value.affordable = false
        end
    end


    if (selected == key) then
        c = 10
        x=x-1
        y=y-1
    elseif value.affordable or value.active then
        c = 9
    else
        c = 5
    end
    if (value.active == true) then
        rectfill(
                 x
                 ,y
                 ,x+width-gap
                 ,y+height-gap
                 ,10)
    end
    rect(x ,y ,x+width-gap ,y+height-gap ,c)
    print (value.name, x+2,y+2, value.active and 0 or 7)
end
-- costs
h = 6*3+4
cost ={
    x = 128 - cols*width,
    y = 128 - h - h
}
count= 0
affordable = true
affordable_ore = true
for key, value in pairs(upgrades[selected].cost) do
    count = count+1
    if inventory[key] < value then
        affordable = false
        affordable_ore = false
    else
        affordable_ore = true
    end
    print (key, cost.x+10, cost.y+2+((count-1)*6), 7)
    print (value, cost.x+10 + 30, cost.y+2+((count-1)*6), affordable_ore and 10 or 8)
    rect(
         cost.x
         ,cost.y
         ,cost.x+(cols*width-2)
         ,cost.y+h-2
         , 13 )
end
if upgrades[selected].active then
    rectfill(cost.x-2, cost.y-2, cost.x+8, cost.y+8, 0)
    rectfill(cost.x-1, cost.y-1, cost.x+7, cost.y+7, 3)
    print ('◆', cost.x, cost.y+1, 0)
elseif (affordable) then
    rectfill(cost.x-2, cost.y-2, cost.x+8, cost.y+8, 0)
    rectfill(cost.x-1, cost.y-1, cost.x+7, cost.y+7, 10)
    print ('❘', cost.x, cost.y+1, 0)
end

-- description
h = 6*3+4
desc ={
    x = 128 - cols*width,
    y = 128 - h
}
rect(
     desc.x
     ,desc.y
     ,desc.x+(cols*width-2)
     ,desc.y+h-2
     ,13 )
for key, value in pairs(explode_string(upgrades[selected].description)) do
    print (value, desc.x+2, desc.y+2+((key-1)*6), 7)
end

end
function reset_sack()
    sack={}
    for i=1, 8 do
        add(sack, 0)
    end
end

function get_ore(x,y,r)
    add(get_ores_queue, {x=x, y=y, r=r})
end




function check_cost(upgrade)
    if (upgrade.active==true) then
        return false
    end
    for key, value in pairs(upgrade.cost) do
        if (inventory[key] < value) then
            return false
        end
    end
    return true
end


function _fx_draw()
    _shield_draw()
    if (player.drill_timer > player.drill_lifetime-10 and player.drill_timer%2 == 0) then
        rectfill(player.p_x - player.drill_w/4, player.p_y+6, player.p_x + player.drill_w/4, player.p_y+40, 7)
    end
    _explosions_draw()
end

function _shield_draw()
    if player.vincible == false then
        rad = 15+rnd(2)
        if (player.buster_timer < 15) then
            circfill(player.p_x,player.p_y, rad, 8)
        elseif (player.buster_timer < 30) then
            circfill(player.p_x,player.p_y, rad, 9)
        elseif (player.buster_timer < 60) then
            circfill(player.p_x,player.p_y, rad, 10)
        else
            circfill(player.p_x,player.p_y, rad, 7)
        end
        circfill(player.p_x,player.p_y-3, rad-1, 0)
        spr(34, player.p_x-3, player.p_y-4)
        add_steam(5,8,4)
        add_steam(-5,8,4)
    end
end

function set_explosion(x, y, yield)
    if (#explosions > 100) then return false end
    yield = min(yield,30)
    for i=1, yield do
        add(explosions, {
            x = x-4+rnd(yield)-yield/2,
            y = y+rnd(yield)-yield/2,
            t = 0,
            dir_x = rnd(2)-1,
            dir_y = rnd(2)
        })
    end
end

function _explosions_update()
    for key, value in pairs(explosions) do
        value.t = value.t+1
        if (value.t>60) then
            deli(explosions, key)
        end
    end
end

function _explosions_draw()
    palt(0,false)

    pal(0, shaft.strata[6]['o'])
    palt(7, true)
    for key, value in pairs(explosions) do
        if (value.t < 30 or value.t%2 == 0) then
            spr((key%4)+3, value.x+value.dir_x*value.t/2, value.y+value.dir_y*sin(value.t/120)*10)
            pset(value.x+value.dir_x*value.t/2, value.y-value.dir_y*value.t, shaft.strata[15]['o'])
        end
    end
    palt(0, true)
    pal(0,0)
    palt(7, false)
    if (explosion.timer > 0) then
        circ(player.p_x, player.p_y, explosion.timer-10, 0)
        circ(player.p_x, player.p_y, explosion.timer-9, ores[shaft.biome].c)
        circ(player.p_x, player.p_y, explosion.timer*2-1, 0)
        circ(player.p_x, player.p_y, explosion.timer*2, ores[shaft.biome].c)
    end
end

function add_steam(ax, ay, ar)
    lifetime = 10+rnd(10)
    px= player.p_x+rnd(3)-1
    py= player.p_y+rnd(3)-6
    add(steam,{
        x = px,
        y = py,
        vx = ax,
        vy = ay,
        r = ar,
        lifetime = lifetime,
        timer = lifetime
    })
end

function _steam_update()
    for key, s in pairs(steam) do
        s.timer = s.timer-1
        if s.timer < 0 then
            deli(steam, key)
        else
            s.x = s.x+s.vx*s.timer/30
            s.y = s.y - (s.lifetime - s.timer)/5
            s.r = s.r*(s.timer/s.lifetime)
        end

    end
end

function _steam_draw()
    for key, s in pairs(steam) do
        circfill(s.x,s.y,s.r,7)
    end
end





