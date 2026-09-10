game_state = "playing"
debug = false
T=0     --global frame counter
freeze_frames = 0
function _init()
    init_player()
    init_level_spawner()
    init_enemy_spawner()
    score = 0
    parts={}
    update_menu()
    music(0)

    -- Disables btnp auto-repeat globally
    -- Did this so held button doesn't auto-restart
    -- the game when game over
    poke(0x5f5c, -1)
end

function _update60()
    T += 1

    if freeze_frames > 0 then
        freeze_frames -= 1
        return
    end

    if game_state == "game_over" then
        if btnp(4) or btnp(5) then
            game_state = "playing"
            _init()
        end
    else
        update_player()
    end

    update_bullets(player_bullets)
    update_bullets(enemy_bullets)
    update_level_spawner()
    update_enemy_spawner()
    update_enemies()
    update_particles()
end

function _draw()
    cls()

    -- background
    rectfill(0, 0, 127, 127, 12)

    ----- Draw Sprites
    toggle_sprite_transparency(true)

    draw_level_spawner()

    if game_state == "playing" then
        draw_player()
    end

    draw_bullets(player_bullets)
    draw_bullets(enemy_bullets)
    draw_enemies()

    toggle_sprite_transparency(false)

    draw_particles()

    print("\^o05ascore: "..score, 8, 4, 7)

    if game_state == "game_over" then
        print("\^o05agame over", 45, 40, 7)
        print("\^o05apress o/x to restart", 25, 50, 7)
        return
    end
end

function toggle_sprite_transparency(enable)
    if enable then
        -- Set blue as transparent
        palt(0, false)
        palt(1, true)
    else
        -- Set black as transparent
        palt(0, true)
        palt(1, false)
    end
end

function update_menu()
    local label = "debug [off]"
    if debug then label = "debug [on]" end

    menuitem(1, label, function()
            debug = not debug
            update_menu()
            return true -- keeps menu active/updates
        end)
end


p_hw = 8 -- hitbox width
p_hh = 8 -- hitbox height
p_ani = {1,2}
p_anis = 10 -- Overridden in move logic
p_age = 0
p_speed = 1.4
p_current_speed_x = 0
p_current_speed_y = 0
p_last_dir = 0
p_shoot_speed = 3
p_shoot_delay = 10
p_last_shoot_frame = 0
p_flash_frames = 0

function init_player()
    p_x = 30
    p_y = 30
    p_last_dir = 0
    p_health = 3
    invincible_frames = 0
    player_bullets = {}
    my_bool = true
end

function update_player()
    move_player()
    shoot()
    handle_player_collisions()

    if p_flash_frames > 0 then
        p_flash_frames -= 1
    end

    if invincible_frames > 0 then
        invincible_frames -= 1
    end

    if p_health <= 0 then
        death()
    end

    -- Update anim
    p_age+=1
end

function draw_player()
    -- Handle flash frames
    if p_flash_frames > 0 then
        for i=1,15 do
            pal(i, 8)
        end
    end

    draw_sprite(cyc(p_age, p_anis,
        p_ani), p_x, p_y)
    print("\^o05ahealth: "..p_health, 8, 12, 7)

     -- Undo flash frames for next drawn items
    if p_flash_frames > 0 then
        pal()
        toggle_sprite_transparency(true)
    end

    if debug then
        rect(p_x-p_hw/2, p_y-p_hh/2,
            p_x+p_hw/2, p_y+p_hh/2, 7)
        pset(p_x, p_y, 8)
    end
end

function move_player()
    -- Bitwise & to strip out the o/x inputs
    local dir = butarr[btn()&0b1111]

    if p_last_dir!=dir and dir>=5 then
        --Anti-cobblestone on diagonals
        p_x = flr(p_x) + 0.5
        p_y = flr(p_y) + 0.5
    end

    if dir > 0 then
        p_current_speed_x = dirx[dir]*p_speed
        p_current_speed_y = diry[dir]*p_speed
        p_x += p_current_speed_x
        p_y += p_current_speed_y
    end

    -- Up input
    if dir == 3 or dir == 5 or dir == 6 then
       p_anis = 5
    -- Down input
    elseif dir == 4 or dir == 7 or dir == 8 then
        p_anis = .1
        p_age = 0
    else
        p_anis = 10
    end

    -- Clamp player position to screen bounds
    p_x = max(p_hw/2, min(128 - p_hw/2, p_x))
    p_y = max(p_hh/2, min(128 - p_hh/2, p_y))

end

function shoot()
    -- Only shoot if delay has passed since the last shot
    if btn(5) and T - p_last_shoot_frame >= p_shoot_delay then
        add_player_bullet( p_x, p_y + 4, p_shoot_speed, 0, 4, 8)
        p_last_shoot_frame = T
        sfx(0)
     end
end

function handle_player_collisions()
    for b in all(enemy_bullets) do
        local collided = false
        collided = hit(
            b.x - b.hw/2,
            b.y - b.hh/2,
            b.hw,
            b.hh,
            p_x-p_hw/2,
            p_y-p_hh/2,
            p_hw,
            p_hh,
            b.x - b.hw/2 + b.spdx,
            b.y - b.hh/2 + b.spdy
        )
        if collided then
            take_damage()
            del(enemy_bullets, b)
        end
    end

    for e in all(enemies) do
        local collided = false
        collided = hit(
            e.x - e.hw/2,
            e.y - e.hh/2,
            e.hw,
            e.hh,
            p_x-p_hw/2,
            p_y-p_hh/2,
            p_hw,
            p_hh,
            e.x - e.hw/2 + cos(e.ang) * e.spd,
            e.y - e.hh/2 + sin(e.ang) * e.spd
        )
        if collided then
            take_damage()
            del(enemies, e)
        end
    end
end

function take_damage()
    if invincible_frames > 0 then
        return
    end
    p_flash_frames = 6
    p_health -= 1
    if p_health > 0 then
        freeze_frames = 12
        invincible_frames = 60
        sfx(3)
    end
end

function death()
    explode(p_x, p_y)
    sfx(2)
    game_state = "game_over"
end


player_bullets = {}
enemy_bullets = {}

function add_player_bullet(x, y, spdx, spdy, hw, hh)
    add(player_bullets, {
        x=x,
        y=y,
        spdx=spdx,
        spdy=spdy,
        rigidbody=true,
        hw=hw, --hitbox width
        hh=hh, --hitbox height
        ani={4}, --sprite anim keys
        anis=1, --anim speed
        age=0 --Add random offset based on frame
    })
end

function add_enemy_bullet(x, y, spdx, spdy, hw, hh)
    add(enemy_bullets, {
            x=x,
            y=y,
            spdx=spdx,
            spdy=spdy,
            rigidbody=false,
            hw=hw,
            hh=hh,
            ani={6},
            anis=1,
            age=0
        })
end

function update_bullets(table)
    for b in all(table) do
        move_bullet(b)

        -- Update anim
        b.age+=1

        -- Delete bullets offscreen
        if b.x < -16 or b.x > 142 or b.y < -16 or b.y > 142 then
            del(table, b)
        end
    end
end

function move_bullet(b)
    if b.rigidbody==false then
        b.x += b.spdx
        b.y += b.spdy
    else
        b.spdy += .05 -- gravity
        b.y += b.spdy

        b.x += b.spdx
    end
end

function draw_bullets(table)
    for b in all(table) do
        draw_sprite_anim(b)
        if debug then
            pset(b.x, b.y, 8)
            rect(b.x-b.hw/2, b.y-b.hh/2, b.x+b.hw/2, b.y+b.hh/2, 7)
        end
    end
end


----- btn() values for given inputs
-- Note: Must bitwise &001111 to remove the x/o button bits
-- 0 - stop
-- 1 - left
-- 2 - right
-- 3 - l+r = stop
-- 4 - up
-- 5 - diag L/U
-- 6 - diag R/U
-- 7 - l+u+r = up
-- 8 - down
-- 9 - diag L/D
-- 10 - diag R/D
-- 11 - l+d+r = d
-- 12 - u+d = stop
-- 13 - l+u+d = left
-- 14 - r+u+d = r
-- 15 - l+u+r+d = stop

----- Output of our conversion
-- 0 - no buttons pressed
-- 1 - left
-- 2 - right
-- 3 - up
-- 4 - down

-- 5 - left/up
-- 6 - right/up
-- 7 - right/down
-- 8 - left/down

butarr={1,2,0,3,5,6,3,4,8,7,4,0,1,2,0}
butarr[0]=0
dirx={-1,1,0,0,-0.75,0.75,0.75,-0.75}
diry={0,0,-1,1,-0.75,-0.75,0.75,0.75}


--[[
-- Helper to get move input and strip o/x input
function get_move_input()
    -- Bitwise & to strip out the o/x inputs
    local dir = butarr[btn()&0b1111]
    return dir
end

function is_diagonal_input()
    dir = get_move_input()
    return dir >= 5
end
--]]


function hit(x1,y1,w1,h1,x2,y2,w2,h2,goalx,goaly)
  -- minkowsky difference between 2 aabbs, which is another aabb
  local x,y,w,h=x2-x1-w1,y2-y1-h1,w1+w2,h1+h2
  local dx,dy=goalx-x1,goaly-y1
  -- if diff contains point 0,0, there's intersection between first and second aabb
  if x<0 and x+w>0 and y<0 and y+h>0 then return true end
  -- no intersection, or intersection with movement - liang-barsky line-clipping with normals
  local t1,t2=-32768,32767
  for side=1,4 do
    local p,q
    if     side==1 then p,q=-dx,-x
    elseif side==2 then p,q=dx,x+w
    elseif side==3 then p,q=-dy,-y
    else                p,q=dy,y+h
    end
    if p==0 then
      if q<=0 then return false end
    else
      local r=q/p
      if p<0 then
        if r>t2 then return false elseif r>t1 then t1=r end
      else
        if r<t1 then return false elseif r<t2 then t2=r end
      end
    end
  end
  return 0<=t1 and t1<=1
end


-- Keeps track of Sprite table and offers
-- methods to interpret sprites

--[[
sprites = {
    {spritex, spritey, width, height, mirrorx, offsetx, offsety, next_sprite_index, next_sprite},
    ...
}
--]]

sprites = {
    {0, 0, 17, 23, false, 7, 8}, -- 1) Player wings down
    {17, 0, 23, 13, false, 11, 8}, -- 2) Player wings up
    {0, 26, 14, 14, false, 7, 6}, -- 3) Person
    {17, 16, 5, 8, false, 2, 5}, -- 4) Player Poop
    {14, 25, 12, 15, false, 6, 7}, -- 5) Person Walk
    {24, 16, 8, 8, false, 4, 4}, -- 6) Enemy Bullet
    {0, 40, 42, 57, false, 0, 0}, -- 7) Palm Tree
    {26, 26, 16, 8, false, 0, 0}, -- 8) Cloud
    {40, 0, 19, 21, false, 10, 11}, -- 9) Starfish
    {61, 0, 23, 16, false, 11, 8}, -- 10) Starfish Spin
    {0, 26, 14, 14, false, 7, 6, 12}, -- 11) Person w Parachute
    {42, 24, 14, 10, false, 8, 15} -- 12) Parachute
}

function draw_sprite(index, x, y)
    local sprite = sprites[index]

    sspr(
        sprite[1],
        sprite[2],
        sprite[3],
        sprite[4],
        x - sprite[6],
        y - sprite[7],
        sprite[3],
        sprite[4],
        false,
        false
    )

    -- mirrorx
    if sprite[5] then
        sspr(
                sprite[1],
                sprite[2],
                sprite[3],
                sprite[4],
                x  - sprite[6] + sprite[3],
                y - sprite[7],
                sprite[3],
                sprite[4],
                true,
                false
            )
    end

    if sprite[8] then
        draw_sprite(sprite[8], x, y)
    end
end

-- Wrapper to draw sprite that is animated
function draw_sprite_anim(obj)
    draw_sprite(cyc(obj.age, obj.anis, obj.ani), obj.x, obj.y)
end


-- Helper method to cycle animation
---@diagnostic disable: missing-type-argument
function cyc(age, anis, arr)
    local anis = anis or 1 -- default speed to 1 if not passed
    return arr[(age\anis-1) % #arr+1]
end


enemies = {}
brains = {
    { -- 1) Walk left enemy
        "HED", 0.5, 0.5, 0,
        "LOS", 0.35, .005, -1,
        "HED", 0, 0, 0,
        "WAIT", 30, 0, 0,
        "SHOOT", 0.35, 1, 0,
        "WAIT", 60, 0, 0,
    },
    { -- 2) Launch enemy
        "FOLPY", 0.5, 0, -1,
        "ANIM", 2, 1, 0,
        "HED", 0.5, 2, -1
    },
    { -- 3) Parachute enemy
        "HED", 0.65, 0.5, 0,
        "LOS", 0.5, .005, -1,
        "SHOOT", 0.5, 1, 0,
        "WAIT", 60, 0, 0,
    }
}

function add_walk_enemy(health, hw, hh)
    add(enemies, {
        x=128,
        y=108,
        health=health,
        hw=hw, --hitbox width
        hh=hh, --hitbox height
        spd=1,
        ang=0,
        sx=0,
        sy=0,
        ani={3,5},
        anis=10,
        age=0,
        brain = 1, -- index of brain to use
        bri = 1, -- index of brain instruction to use
        wait = 0, -- wait counter for brain instructions
        cmd = nil, -- current command being executed
        cmd_arg1 = 0, -- command args cached
        cmd_arg2 = 0,
        flash_frames=0
    })
end

function add_parachute_enemy(health, hw, hh)
    add(enemies, {
        x=128,
        y=10,
        health=health,
        hw=hw, --hitbox width
        hh=hh, --hitbox height
        spd=1,
        ang=0,
        sx=0,
        sy=0,
        ani={11},
        anis=10,
        age=0,
        brain = 3, -- index of brain to use
        bri = 1, -- index of brain instruction to use
        wait = 0, -- wait counter for brain instructions
        cmd = nil, -- current command being executed
        cmd_arg1 = 0, -- command args cached
        cmd_arg2 = 0,
        flash_frames=0
    })
end

function add_launch_enemy(health, hw, hh)
    add(enemies, {
        x=116,
        y=-10,
        health=health,
        hw=hw, --hitbox width
        hh=hh, --hitbox height
        spd=1,
        ang=0,
        sx=0,
        sy=0,
        ani={9,10},
        anis=0,
        age=0,
        brain = 2, -- index of brain to use
        bri = 1, -- index of brain instruction to use
        wait = 0, -- wait counter for brain instructions
        cmd = nil, -- current command being executed
        cmd_arg1 = 0, -- command args cached
        cmd_arg2 = 0,
        flash_frames=0
    })
end

function update_enemies()
    for e in all(enemies) do
        -- Execute current command every frame
        local should_continue = execute_cmd(e, e.cmd, e.cmd_arg1, e.cmd_arg2)

        -- If command returns false (self-interrupt), force next instruction
        if should_continue == false then
            e.wait = 0
        end

        if e.wait > 0 then
            e.wait -= 1
        else
            do_brain(e, 0)
        end

        -- Move Enemy
        e.sx = cos(e.ang) * e.spd
        e.sy = sin(e.ang) * e.spd

        e.x += e.sx
        e.y += e.sy

        -- Update anim
        e.age+=1

        -- Collisions
        for b in all(player_bullets) do
            local collided = false
            collided = hit(
                b.x - b.hw/2,
                b.y - b.hh/2,
                b.hw,
                b.hh,
                e.x-e.hw/2,
                e.y-e.hh/2,
                e.hw,
                e.hh,
                b.x - b.hw/2 + b.spdx,
                b.y - b.hh/2 + b.spdy
            )
            if collided then
                del(player_bullets, b)
                e.health -= 1
                e.flash_frames = 6
                sfx(1)
            end
        end

        if e.flash_frames > 0 then
            e.flash_frames -= 1
        end

        -- Death
        if e.health <= 0 then
            del(enemies, e)
            score = score + 1
            sfx(2)
            explode(e.x, e.y)
        end

        -- Delete offscreen left
        if e.x < -20 then
            del(enemies, e)
        end
    end
end

function draw_enemies()
    for e in all(enemies) do
        -- Enable flash frames
        if e.flash_frames > 0 then
            for i=1,15 do
                pal(i, 8)
            end
        end

        draw_sprite_anim(e)

        -- Undo flash frames for next drawn items
        if e.flash_frames > 0 then
            pal()
            toggle_sprite_transparency(true)
        end


        if debug then
            -- draw hitbox for debugging
            rect(e.x-e.hw/2, e.y-e.hh/2, e.x+e.hw/2, e.y+e.hh/2, 7)
            pset(e.x, e.y, 8)

            -- draw current command over enemy
            if e.cmd then
                print(e.cmd, e.x-4, e.y-12, 7)

                if e.cmd == "LOS" then
                    local dx = p_x - e.x
                    local dy = p_y - e.y
                    local angle_to_player = atan2(dx, dy)
                    line(e.x, e.y, e.x + cos(angle_to_player) * 20, e.y + sin(angle_to_player) * 20, 8)
                    line(e.x, e.y, e.x + cos(e.cmd_arg1) * 20, e.y + sin(e.cmd_arg1) * 20, 11)
                    -- Print angle to player below enemy
                    local within_range = abs(angle_to_player - e.cmd_arg1) < e.cmd_arg2
                    print(""..(within_range and "true" or "false"), e.x-4, e.y-20, 7)
                end

                -- if cmd is WAIT, print wait time below enemy
                if e.cmd == "WAIT" then
                    print(""..e.wait, e.x-4, e.y-20, 7)
                end
            end
        end
    end
end


x_scroll_speed = 0.25
x_scroll_accum = 0

function init_level_spawner()
    level_objs = {}
    next_palm_spawn_frame = T
    next_cloud_spawn_frame = T
    x_scroll = 0
    x_scroll_accum = 0
end

function add_palm_tree()
    add(level_objs, {
        x = 144,
        y = 59,
        spi = 7
    })
end

function add_cloud()
    add(level_objs, {
        x = 144,
        y = rndrange(10,45),
        spi = 8
    })
end

function update_level_spawner()
    if T >= next_palm_spawn_frame then
        add_palm_tree()
        next_palm_spawn_frame = T + rndrange(150, 250)
    end
    if T >= next_cloud_spawn_frame then
        add_cloud()
        next_cloud_spawn_frame = T + rndrange(60, 120)
    end

    x_scroll_accum += x_scroll_speed

    -- Move all objects in unison
    local scroll_step = flr(x_scroll_accum)
    if scroll_step <= 0 then
        return
    end

    x_scroll_accum -= scroll_step
    x_scroll -= scroll_step
    for p in all(level_objs) do
        p.x -= scroll_step
        if p.x < -48 then
            del(level_objs, p)
        end
    end
end

function draw_level_spawner()
    local ground_x = x_scroll % 128
    local ground_x2 = ground_x - 128

    -- Sand ground
    fillp_local(0b1011111010111111, x_scroll, 0)
    rectfill(0, 115, 127, 128, 154)

    fillp_local(0b1111001111111111, x_scroll, 0)
    rectfill(0, 115, 127, 117, 169)
    fillp()

    for p in all(level_objs) do
        draw_sprite(p.spi, p.x, p.y)
    end
end

-- Method to scroll fillp patterns horizontally and vertically
function fillp_local(p,x,y)
  x &= 3
  local p16 = p&0xffff
  local mask, p32 = split"30583,13107,4369"[x] or -1, p16+(p16>>>16) >>< y*4+x
  fillp(p32&mask  |  p32<<>4 & 0xffff-mask  |  p-p16)
end


function init_enemy_spawner()
    e_spawn_rate = 2 -- seconds between spawns
    last_enemy_spawn_time = time()
    max_enemies = 10
    enemies = {}
    enemy_bullets = {}
end

function update_enemy_spawner()
    -- Check if it's time to spawn a new enemy
    if #enemies < max_enemies and
        time() - last_enemy_spawn_time >= e_spawn_rate then

        -- Randomly spawn enemy
        local enemy_type_count = 3
        local randd = flr(rndrange(1, enemy_type_count+1))
        if randd == 1 then
            add_walk_enemy(
                3,
                7,
                7
            )
        elseif randd == 2 then
            add_launch_enemy(
                3,
                7,
                7
            )
        else
            add_parachute_enemy(
                3,
                7,
                7
            )
        end
        last_enemy_spawn_time = time()
    end
end


function draw_particles()
 for p in all(parts) do
  if p.wait==nil then
   p.draw(p)
  end
 end
end

function update_particles()
    for p in all(parts) do
        dopart(p)
    end
end

function rndrange(low,high)
 return rnd(high-low)+low
end

function blob(p)
 local myr=flr(p.r)

 local thk={
  0,
  myr*0.05,
  myr*0.15,
  myr*0.3
 }
 local pat={
  0b1111111111111111,
  0b1011010010101101,
  0b1000000000000000,
  0,
 }

 --★
 if myr<=2 then
  pat={0b1111111111111111}
  thk={0}
 elseif myr<=5 then
  deli(thk,4)
  deli(thk,2)
  pat={0b1111111111111111,0}
 elseif myr<=8 then
  deli(thk,3 and myr<=6 or 4)
  deli(pat,3)
  pat[2]=0b1010101010101010
 end

 for i=1,#thk do
  fillp(pat[i])
  circfill(flr(p.x),flr(p.y)-thk[i],
           myr-thk[i],p.c)

 end
 fillp()

 --★
 if myr==1 then
  line(p.x,p.y-1,p.x,p.y,p.c)
 elseif myr==2 then
  rectfill(p.x-1,p.y-2,p.x+1,p.y,p.c)
 end

end

function spark(p)
 --47

 for i=0,1 do
  line(p.x+i,p.y,p.x-p.sx*2+i,p.y-p.sy*2,p.c)
 end

end

function explode(ex,ey)
 sfx(0)
 add(parts,{
  draw=blob,
  x=ex,
  y=ey,
  r=17,
  maxage=2,
  c=119,
  ctab={119,167}
 })

 sparkblast(ex,ey,2)
 sparkblast(ex,ey,8)

 grape(ex,ey,2,13,1,
       "return",{119,167,167,154},
       0
       )
 grape(ex-rnd(5),ey-5,10,20,1,
       "return",{167,154,169},
       -0.2
       )
 grape(ex+rnd(5),ey-10,25,25,0.8,
       "fade",{167,167,154,169,141,93},
       -0.3
       )
end

function dopart(p)
 if p.wait then
  -- wait countodwn
  p.wait-=1
  if p.wait<=0 then
   p.wait=nil
  end
 else
  --particle code
  p.age=p.age or 0
  p.spd=p.spd or 1
  if p.age==0 then
   p.ox=p.x
   p.oy=p.y
   p.r=p.r or 1
   p.ctabv=p.ctabv or 0
  end
  p.age+=1

  --animate color
  if p.ctab then
   local i=(p.age+p.ctabv)/p.maxage
   i=mid(1,flr(1+i*#p.ctab),#p.ctab)
   p.c=p.ctab[i]
  end

  --movement
  if p.tox then
   p.x+=(p.tox-p.x)/(4/p.spd)
   p.y+=(p.toy-p.y)/(4/p.spd)
  end
  if p.sx then
   p.x+=p.sx
   p.y+=p.sy
   if p.tox then
    p.tox+=p.sx
    p.toy+=p.sy
   end

   if p.drag then
    p.sx*=p.drag
    p.sy*=p.drag
   end
  end

  --size
  if p.tor then
   p.r+=(p.tor-p.r)/(5/p.spd)
  end
  if p.sr then
   p.r+=p.sr
  end

  if p.age>=p.maxage or p.r<0.5 then
   if p.onend=="return" then
    p.maxage+=32000
    p.tox=p.ox
    p.toy=p.oy
    p.tor=nil
    p.sr=-0.3
   elseif p.onend=="fade" then
    p.maxage+=32000
    p.tor=nil
    p.sr=-0.1-rnd(0.3)
   else
    del(parts,p)
   end
   p.ctab=nil
   p.onend=nil
  end
 end
end

function grape(ex,ey,ewait,
               emaxage,espd,
               eonend,ectab,
               edrift)
 local spokes=6
 local ang=rnd()
 local step=1/spokes


 for i=1,spokes do
  --spawn blobs
  local myang=ang+step*i
  local dist=7+rnd(3)
  local dist2=dist/2

	 add(parts,{
	  draw=blob,
	  x=ex+sin(myang)*dist2,
	  y=ey+cos(myang)*dist2,
	  r=2,
	  tor=rndrange(4,7),
	  tox=ex+sin(myang)*dist,
	  toy=ey+cos(myang)*dist,
	  sx=0,
	  sy=edrift,
	  wait=ewait,
	  maxage=emaxage,
	  onend=eonend,
	  spd=espd,
	  c=ectab[1],
	  ctab=ectab,
	  ctabv=rnd(5)
	 })

 end
 add(parts,{
  draw=blob,
  x=ex,
  y=ey,
  r=2,
  tor=7,
	 sx=0,
	 sy=edrift,
  wait=ewait,
  maxage=emaxage,
  onend=eonend,
  spd=espd,
  c=ectab[1],
  ctab=ectab
 })
end

function sparkblast(ex,ey,ewait)
 local ang=rnd()

 for i=1,6 do
  local ang2=ang+rnd(0.5)
  local spd=rndrange(4,8)
	 add(parts,{
	  draw=spark,
	  x=ex,
	  y=ey,
	  c=10,
	  ctab={7,10},
	  sx=sin(ang2)*spd,
	  sy=cos(ang2)*spd,
	  drag=0.8,
	  wait=ewait,
	  maxage=rndrange(8,13)
	 })
 end
end


function execute_cmd(e, cmd, arg1, arg2)
    if cmd == "HED" then
        e.ang = arg1
        e.spd = arg2
        return true
    elseif cmd == "FOLPY" then
        e.spd = arg1
        if p_y < e.y then
            e.ang = 0.25 -- Move up
        else
            e.ang = 0.75 -- Move down
        end

        -- Self-interrupt: if player is within 3 units, stop
        if abs(p_y - e.y) < 3 then
            return false  -- Interrupt, move to next command
        end
        return true  -- Continue executing
    elseif cmd == "LOS" then
        -- Line of Sight: if player is at certain angle interrupt
        local dx = p_x - e.x
        local dy = p_y - e.y
        local angle_to_player = atan2(dx, dy)
        if abs(angle_to_player - arg1) < arg2 then
            return false  -- Interrupt, move to next command
        end
        return true
    elseif cmd == "SHOOT" then
        -- Shoot bullet towards angle with given speed
        local spdx = cos(arg1) * arg2
        local spdy = sin(arg1) * arg2
        add_enemy_bullet(e.x, e.y, spdx, spdy, 3, 3)
    elseif cmd == "ANIM" then
        -- Change animation index and speed
        -- TODO: Anim change logic is broken, need to implement a proper animation system
        e.age = arg1
        e.anis = arg2
        return true
    end
end


function do_brain(e, depth)
    if depth > 100 then
        print("Infinite loop detected in enemy brain!")
        return
    end

    local my_brain = brains[e.brain]
    if e.bri < #my_brain then
        local cmd = my_brain[e.bri]
        local arg1 = my_brain[e.bri + 1]
        local arg2 = my_brain[e.bri + 2]
        local duration = my_brain[e.bri + 3] or 0

        -- Cache command for repeated execution
        e.cmd = cmd
        e.cmd_arg1 = arg1
        e.cmd_arg2 = arg2

        if cmd == "WAIT" then
            -- WAIT instruction: set wait time
            e.wait = arg1
        elseif duration == -1 then
            -- Infinite duration: do not set wait time, keep executing
            e.wait = 32767
        elseif duration > 0 then
            e.wait = duration
        end

        e.bri += 4 -- Move to the next 4-element instruction

        if e.wait == 0 then
            depth = depth + 1
            execute_cmd(e, cmd, arg1, arg2)
            do_brain(e, depth) -- Immediately process the next instruction if not waiting
        end
    else
        -- If we've reached the end of the brain, loop back to the start
        e.bri = 1
    end
end


