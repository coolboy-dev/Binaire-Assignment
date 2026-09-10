-- super galactic adventure
-- can you avoid perils of space
ship = {
    x = 64, y = 64,
    ang = 0.0,
    v_x = 0, v_y = 0, v_ang = 0,
    thrust_accel = 0.14,
    rot_accel   = 0.0026,
    linear_damping  = 0.9,
    angular_damping = 0.68,
    max_speed   = 2,
    max_ang_vel = 0.2,
    lever_arm = 6,
    layers = {},
    
    -- collision and survival properties
    r = 18,
    shield = false,
    iframes = 0, 

    -- co-op extension properties
    ld_cd = 0, rd_cd = 0, stun = 0,

    pts_1 = { -- hull (gray 7)
        {-18,-10, 18,-10, 7}, {18,-10, 18,-7, 7}, {18,-7, 23,-7, 7}, {23,-7, 23,-4, 7},
        {23,-4, 26,-4, 7}, {26,-4, 26,4, 7}, {26,4, 23,4, 7}, {23,4, 23,7, 7},
        {23,7, 18,7, 7}, {18,7, 18,10, 7}, {18,10, -18,10, 7}, {-18,10, -18,-10, 7}
    },
    pts_2 = { -- thrusters & camera (11, 10, 12)
        {-18,-16, -6,-16, 11}, {-6,-16, -6,-8, 11}, {-6,-8, -18,-8, 11}, {-18,-8, -18,-16, 11},
        {0,-15, 8,-15, 11}, {8,-15, 8,-9, 11}, {8,-9, 0,-9, 11}, {0,-9, 0,-15, 11},
        {-18,16, -6,16, 10}, {-6,16, -6,8, 10}, {-6,8, -18,8, 10}, {-18,8, -18,16, 10},
        {0,15, 8,15, 10}, {8,15, 8,9, 10}, {8,9, 0,9, 10}, {0,9, 0,15, 10},
        {14,-4, 22,-4, 12}, {22,-4, 22,4, 12}, {22,4, 14,4, 12}, {14,4, 14,-4, 12}
    },
    pts_3 = { -- cannon (red 8)
        {-8,-7, 8,-7, 8}, {8,-7, 8,7, 8}, {8,7, -8,7, 8}, {-8,7, -8,-7, 8},
        {8,0, 16,0, 8}
    }
}

function layer_centroid(layer)
    if #layer == 0 then return 0,0 end
    local min_x, max_x = 32767, -32768
    local min_y, max_y = 32767, -32768

    for i=1,#layer do
        local s = layer[i]
        if s[1] < min_x then min_x = s[1] end
        if s[1] > max_x then max_x = s[1] end
        if s[3] < min_x then min_x = s[3] end
        if s[3] > max_x then max_x = s[3] end

        if s[2] < min_y then min_y = s[2] end
        if s[2] > max_y then max_y = s[2] end
        if s[4] < min_y then min_y = s[4] end
        if s[4] > max_y then max_y = s[4] end
    end
    return (min_x + max_x) / 2, (min_y + max_y) / 2
end

function rotate_point_local(px, py, ang_rad)
  local s = sin(ang_rad)
  local c = cos(ang_rad)
  return (px * c) - (py * s), (px * s) + (py * c)
end

function clamp(x, a, b)
  if x < a then return a end
  if x > b then return b end
  return x
end

function setup_ship_geometry()
  ship.layers = { ship.pts_1, ship.pts_2, ship.pts_3 }
  local cx, cy = layer_centroid(ship.pts_1)
  for li=1,#ship.layers do
    local layer = ship.layers[li]
    for i=1,#layer do
      layer[i][1] -= cx
      layer[i][2] -= cy
      layer[i][3] -= cx
      layer[i][4] -= cy
    end
  end
  ship.lever_arm = ship.lever_arm or 6
end

function debug_setup()
    game_state = 3
    for p=1,4 do player_roles[p].p_id = p-1 end
end

function _init()
    game_state = 1
    assigned_count = 0
    
    wait_release = true
    setup_timer = 30 

    player_roles = {
        {name="p1 thruster", color=11, p_id=-1},
        {name="p2 thruster", color=10, p_id=-1},
        {name="p3 cannon", color=8, p_id=-1},
        {name="p4 camera", color=12, p_id=-1}
    }

    setup_ship_geometry()
    claimed_pads = {[0]=false, [1]=false, [2]=false, [3]=false}

    cannon = {a=0, ammo=3, max=3, reload=0, recoil=0}
    cam = {x=0, y=0, shake=0}
    particles = {} lasers = {}
    objects = {}
    
    for i=1, 20 do 
        local a = rnd(1)
        local d = 160 + rnd(80) 
        local ox = ship.x + cos(a)*d
        local oy = ship.y + sin(a)*d
        
        local is_fuel = (i <= 3) 
        local obj_type = is_fuel and 4 or (rnd(1) > 0.7 and 2 or 1)
        
        local ma = rnd(1)
        local spd = 0.2 + rnd(0.5)
        local obj_r = (obj_type == 2) and 12 or 6
        
        add(objects, {x=ox, y=oy, type=obj_type, scanned=false, vx=cos(ma)*spd, vy=sin(ma)*spd, r=obj_r})
    end
    
    stars = {}
    for i=1, 60 do
        add(stars, {ang=rnd(1), d=rnd(100), spd=0.1+rnd(0.5)})
    end
    game_over_timer = 150 
    
    fuel = 100
    max_fuel = 100
    score = 0
    ship.x = 64 ship.y = 64
    ship.v_x = 0 ship.v_y = 0 ship.v_ang = 0
    
    ship.iframes = 90 
end

function is_any_player_input(player)
    for b=0,5 do if btn(b, player) then return true end end
    return false
end

function update_stars(warp_speed)
    for s in all(stars) do
        s.d += s.spd * warp_speed
        s.spd *= 1.05
        if s.d > 100 then
            s.d = rnd(10)
            s.ang = rnd(1)
            s.spd = 0.1 + rnd(0.5)
        end
    end
end

function _update()
    if game_state == 1 then 
        update_stars(1) 
        update_setup_screen()
    elseif game_state == 3 then 
        update_ship() 
    elseif game_state == 4 then
        update_stars(0.2) 
        if game_over_timer > 0 then
            game_over_timer -= 1
        elseif is_any_player_input(0) then
            _init()
        end
    end
end

function get_thruster_input(p_id)
    if p_id == -1 then return 0 end
    local f = 0
    if btn(2, p_id) then f += 1 end
    if btn(3, p_id) then f -= 1 end
    return f
end

function make_dash_burst(ox, oy, spray_ang)
    local px = ship.x + ox*cos(ship.ang) - oy*sin(ship.ang)
    local py = ship.y + ox*sin(ship.ang) + oy*cos(ship.ang)
    
    for i=2,8 do
        local a = spray_ang + (rnd(0.1) - 0.05)
        local spd = 2 + rnd(2)
        add(particles, {
            x = px, 
            y = py, 
            vx = cos(a) * spd, 
            vy = sin(a) * spd, 
            life = 10 + rnd(6), 
            c = (rnd(1) > 0.5) and 7 or 12,
            dot = false
        })
    end
end

function make_fire(ox, oy)
    local px = ship.x + ox*cos(ship.ang) - oy*sin(ship.ang)
    local py = ship.y + ox*sin(ship.ang) + oy*cos(ship.ang)
    add(particles, {x=px, y=py, vx=-cos(ship.ang)*2+rnd(1)-0.5, vy=-sin(ship.ang)*2+rnd(1)-0.5, life=8, c=9, dot=false})
end

function make_boom(x, y, count, c)
    for i=1, count do
        local a = rnd(1)
        local spd = rnd(3)
        add(particles, {x=x, y=y, vx=cos(a)*spd, vy=sin(a)*spd, life=15+rnd(10), c=c or 9, dot=false})
    end
end

function make_astronaut_boom(x, y)
    make_boom(x, y, 8, 8) 
    for i=1, 20 do
        local a = rnd(1)
        local spd = rnd(0.3) 
        add(particles, {x=x, y=y, vx=cos(a)*spd, vy=sin(a)*spd, life=60+rnd(60), c=7, dot=true})
    end
end

function update_ship()
    local p_left  = player_roles[1].p_id
    local p_right = player_roles[2].p_id
    local p_cannon = player_roles[3].p_id
    local p_cam = player_roles[4].p_id

    score += 0.03
    fuel -= 0.06
    
    if ship.iframes > 0 then ship.iframes -= 1 end

    if p_cam != -1 then
        if btnp(5, p_cam) then
            cam.x, cam.y = ship.x - 64, ship.y - 64
        else
            if btn(0, p_cam) then cam.x -= 4 end
            if btn(1, p_cam) then cam.x += 4 end
            if btn(2, p_cam) then cam.y -= 4 end
            if btn(3, p_cam) then cam.y += 4 end
        end

        local is_pressing_shield = btn(4, p_cam)
        
        if is_pressing_shield and not ship.shield then
            sfx(2, 2)
        elseif not is_pressing_shield and ship.shield then
            sfx(-1, 2)
        end

        ship.shield = is_pressing_shield
        if ship.shield then fuel -= 0.2 end
    end

    local thr_l = get_thruster_input(p_left)
    local thr_r = get_thruster_input(p_right)

    if thr_l != 0 or thr_r != 0 then
        if stat(49) != 1 then sfx(1, 3) end
    else
        if stat(49) == 1 then sfx(-1, 3) end
    end

    local forward_input = (thr_l + thr_r)
    local forward_accel = forward_input * ship.thrust_accel

    ship.v_x += cos(ship.ang) * forward_accel
    ship.v_y += sin(ship.ang) * forward_accel

    local rot_input = (thr_r - thr_l)
    local ang_acc = rot_input * ship.rot_accel
    ship.v_ang += ang_acc

    if ship.ld_cd > 0 then ship.ld_cd -= 1 end
    if ship.rd_cd > 0 then ship.rd_cd -= 1 end

    if p_left != -1 and btnp(5, p_left) and ship.ld_cd <= 0 then
        sfx(3)
        local move_dir = ship.ang - 0.25
        ship.v_x += cos(move_dir) * 4
        ship.v_y += sin(move_dir) * 4
        ship.ld_cd = 45
        make_dash_burst(-18, -8, move_dir + 0.5)
        cam.shake = 4
    end

    if p_right != -1 and btnp(5, p_right) and ship.rd_cd <= 0 then
        sfx(3)
        local move_dir = ship.ang + 0.25
        ship.v_x += cos(move_dir) * 4
        ship.v_y += sin(move_dir) * 4
        ship.rd_cd = 45
        make_dash_burst(-18, 8, move_dir + 0.5)
        cam.shake = 4
    end

    if p_cannon != -1 then
        if btn(0, p_cannon) then cannon.a += 0.012 end
        if btn(1, p_cannon) then cannon.a -= 0.012 end

        if cannon.reload > 0 then
            cannon.reload -= 1
            if cannon.reload == 0 then cannon.ammo = cannon.max end
        elseif btnp(4, p_cannon) and cannon.ammo < cannon.max then
            sfx(4)
            cannon.reload = 60
        end

        if btnp(5, p_cannon) and cannon.ammo > 0 and cannon.reload == 0 then
            sfx(0)
            cannon.ammo -= 1
            local cx = ship.x + -4*cos(cannon.a)
            local cy = ship.y + -4*sin(cannon.a)
            add(lasers, {x=cx, y=cy, vx=cos(cannon.a)*8, vy=sin(cannon.a)*8, life=30})
            
            ship.v_x -= cos(cannon.a) * 1.5
            ship.v_y -= sin(cannon.a) * 1.5
            cam.shake = 6
            cannon.recoil = 4
        end
    end

    local current_fuel = 0
    for o in all(objects) do
        if o.type == 4 then current_fuel += 1 end
    end

    if #objects < 50 then 
        local spawn_ang = rnd(1)
        
        local dist = 160 + rnd(40) 
        local ox = ship.x + cos(spawn_ang) * dist
        local oy = ship.y + sin(spawn_ang) * dist

        local can_spawn = true
        for o in all(objects) do
            if abs(o.x - ox) < 16 and abs(o.y - oy) < 16 then 
                can_spawn = false 
                break 
            end
        end

        if can_spawn then
            local obj_type = 0
            if current_fuel < 4 then
                obj_type = 4
            else
                local rand_val = rnd(1)
                if rand_val > 0.975 then obj_type = 5 -- astronaut (2.5% chance)
                elseif rand_val > 0.85 then obj_type = 4
                elseif rand_val > 0.60 then obj_type = 2
                elseif rand_val > 0.30 then obj_type = 1
                end
            end

            local obj_vx, obj_vy = 0, 0
            if rnd(1) > 0.1 then
                local move_ang = rnd(1) 
                local spd = 0.2 + rnd(0.4)
                if obj_type == 4 or obj_type == 5 then spd *= 0.6 end
                obj_vx = cos(move_ang) * spd
                obj_vy = sin(move_ang) * spd
            end

            local obj_r = (obj_type == 2) and 12 or ((obj_type == 5) and 4 or 6)
            add(objects, {x=ox, y=oy, type=obj_type, scanned=false, vx=obj_vx, vy=obj_vy, r=obj_r})
        end
    end

    local cam_center_x = cam.x + 64
    local cam_center_y = cam.y + 64

    for i=#objects,1,-1 do
        local o = objects[i]
        o.x += o.vx
        o.y += o.vy

        local dx, dy = o.x - ship.x, o.y - ship.y

        if abs(dx) > 240 or abs(dy) > 240 then
            del(objects, o)
        else
            local dcx, dcy = o.x - cam_center_x, o.y - cam_center_y
            if abs(dcx) < 40 and abs(dcy) < 40 then o.scanned = true end

            if abs(dx) < 40 and abs(dy) < 40 then
                local dist_sq = dx*dx + dy*dy
                local col_dist = ship.r + o.r

                if dist_sq < (col_dist * col_dist) then
                    if o.type == 5 then
                        sfx(7)
                        score += 50
                        del(objects, o)
                    elseif o.type == 4 then
                        sfx(6)
                        fuel = min(fuel + 30, max_fuel)
                        for j=1, 10 do make_fire(0, 0) end
                        del(objects, o)
                    elseif ship.iframes <= 0 then
                        if ship.shield then
                            fuel -= (o.type == 2 and 25 or 15)
                            cam.shake = (o.type == 2 and 15 or 10)
                            make_boom(o.x, o.y, 8, 9)
                            del(objects, o)
                            if fuel <= 0 then 
                                sfx(-1, 2) sfx(-1, 3) sfx(5)
                                game_state = 4 
                            end
                        else
                            sfx(-1, 2) sfx(-1, 3) sfx(5)
                            game_state = 4
                        end
                    end
                end
            end
        end
    end

    for l in all(lasers) do
        l.x += l.vx l.y += l.vy l.life -= 1
        if l.life < 0 then del(lasers, l) end

        for o in all(objects) do
            if o.scanned then
                local ldx, ldy = l.x - o.x, l.y - o.y
                if abs(ldx) < 20 and abs(ldy) < 20 then
                    local l_dist_sq = ldx*ldx + ldy*ldy
                    local l_col_dist = 2 + o.r

                    if l_dist_sq < (l_col_dist * l_col_dist) then
                        if o.type == 5 then
                            make_astronaut_boom(o.x, o.y)
                            del(objects, o) del(lasers, l) break
                        elseif o.type == 4 then
                            make_boom(o.x, o.y, 30, 10)
                            make_boom(o.x, o.y, 15, 8)
                            cam.shake = 20
                            
                            for blast_o in all(objects) do
                                if blast_o.type == 5 then
                                    local bd_sq = (blast_o.x - o.x)^2 + (blast_o.y - o.y)^2
                                    if bd_sq < 3600 then 
                                        make_astronaut_boom(blast_o.x, blast_o.y)
                                        del(objects, blast_o)
                                    end
                                end
                            end

                            local dist_x, dist_y = ship.x - o.x, ship.y - o.y
                            if abs(dist_x) < 60 and abs(dist_y) < 60 then
                                if (dist_x * dist_x + dist_y * dist_y) < 2500 then
                                    if ship.shield then
                                        fuel -= 30
                                        if fuel <= 0 then 
                                            sfx(-1, 2) sfx(-1, 3) sfx(5)
                                            game_state = 4 
                                        end
                                    else
                                        sfx(-1, 2) sfx(-1, 3) sfx(5)
                                        game_state = 4
                                    end
                                end
                            end
                            del(objects, o) del(lasers, l) break
                        else
                            make_boom(o.x, o.y, (o.type == 2 and 16 or 8), 9)
                            del(objects, o) del(lasers, l) break
                        end
                    end
                end
            end
        end
    end

    local speed = sqrt(ship.v_x*ship.v_x + ship.v_y*ship.v_y)
    if speed > ship.max_speed then
        local s = ship.max_speed / speed
        ship.v_x *= s
        ship.v_y *= s
    end
    ship.v_ang = clamp(ship.v_ang, -ship.max_ang_vel, ship.max_ang_vel)

    ship.x += ship.v_x
    ship.y += ship.v_y
    ship.ang += ship.v_ang

    ship.v_x *= ship.linear_damping
    ship.v_y *= ship.linear_damping
    ship.v_ang *= ship.angular_damping

    if cannon.recoil > 0 then cannon.recoil *= 0.7 end

    for p in all(particles) do
        p.x += p.vx p.y += p.vy p.life -= 1
        if p.life < 0 then del(particles, p) end
    end

    if thr_l == 1 then make_fire(-18, -12) end
    if thr_l == -1 then make_fire(10, -12) end
    if thr_r == 1 then make_fire(-18, 12) end
    if thr_r == -1 then make_fire(10, 12) end

    if cam.shake > 0 then cam.shake *= 0.8 end
    
    if fuel <= 0 and game_state != 4 then 
        sfx(-1, 2) sfx(-1, 3) sfx(5)
        game_state = 4 
    end
end

function update_setup_screen()
    if game_state ~= 1 then return end

    if setup_timer > 0 then
        setup_timer -= 1
        return
    end

    if wait_release then
        local any_pressed = false
        for p=0,3 do if is_any_player_input(p) then any_pressed = true end end
        if not any_pressed then wait_release = false end
        return
    end

    for p=0,3 do
        if not claimed_pads[p] and is_any_player_input(p) then
            assigned_count += 1
            player_roles[assigned_count].p_id = p
            claimed_pads[p] = true
            wait_release = true
            if assigned_count == 4 then game_state = 3 end
            break
        end
    end
end

function draw_stars()
    for s in all(stars) do
        local c = 5
        if s.spd > 1.5 then c = 6 end
        if s.spd > 3.0 then c = 7 end
        pset(64 + cos(s.ang)*s.d, 64 + sin(s.ang)*s.d, c)
    end
end

function _draw()
    cls(0)
    if game_state == 1 then 
        draw_stars()
        draw_setup_screen()
    elseif game_state == 2 then 
        draw_test_screen()
    elseif game_state == 3 then 
        draw_gameplay() 
    elseif game_state == 4 then 
        draw_stars()
        draw_game_over() 
    end
end

function draw_gameplay()
    local cx = cam.x + (rnd(cam.shake)-cam.shake/2)
    local cy = cam.y + (rnd(cam.shake)-cam.shake/2)
    camera(cx, cy)

    for ix=(cx - cx%16), cx+128, 16 do
        for iy=(cy - cy%16), cy+128, 16 do pset(ix, iy, 1) end
    end
    
    for o in all(objects) do
        if o.scanned then
            if o.type == 2 then
                spr(2, o.x - 8, o.y - 8, 2, 2)
            elseif o.type == 5 then
                spr(5 + flr(t()*2)%2, o.x - 4, o.y - 4)
            else
                spr(o.type, o.x - 4, o.y - 4)
            end
        else
            circfill(o.x, o.y, (o.type == 2 and 3 or (o.type == 5 and 1 or 2)), 5)
        end
    end

    for l in all(lasers) do circfill(l.x, l.y, 2, 8) end
    
    for p in all(particles) do 
        if p.dot then
            pset(p.x, p.y, p.c)
        else
            circfill(p.x, p.y, 1+p.life/5, p.c) 
        end
    end
    
    local cam_center_x = cam.x + 64
    local cam_center_y = cam.y + 64
    circ(cam_center_x, cam_center_y, 40, 1)
    pset(cam_center_x, cam_center_y, 12)

    if ship.shield then
        local r = 26 + sin(t()*2)*2
        circ(ship.x, ship.y, r, 12)
        circ(ship.x, ship.y, r-1, 1)
    end

    draw_ship()

    for i=1, cannon.max do
        local ac = 5
        if i <= cannon.ammo then ac = 8 end
        if cannon.reload > 0 and (t()*8)%2 < 1 then ac = 10 end
        local ax = ship.x + (-6 + (i*3))*cos(cannon.a)
        local ay = ship.y + (-6 + (i*3))*sin(cannon.a)
        pset(ax, ay, ac)
    end

    camera(0, 0)

    local sx, sy = ship.x - cx, ship.y - cy
    if sx < 0 or sx > 128 or sy < 0 or sy > 128 then
        local px, py = mid(4, sx, 124), mid(4, sy, 124)
        local c = 12
        if (t()*4)%2 < 1 then c = 7 end
        circfill(px, py, 3, c) pset(px, py, 0)
    end
    
    rectfill(2, 2, 102, 6, 1)
    rectfill(2, 2, 2 + fuel, 6, 9)
    print("score: "..flr(score), 2, 9, 7)
end

function draw_btn(button, p_id, x, y, label, active_color)
    local color = 5
    local tc = 7
    if btn(button, p_id) then color = active_color; tc = 0 end
    circfill(x, y, 4, color)
    print(label, x-1, y-2, tc)
end

function draw_ship()
  if ship.iframes > 0 and flr(t() * 10) % 2 == 0 then return end

  for li=1,#ship.layers do
    local layer = ship.layers[li]
    local render_ang = ship.ang
    
    if li == 3 then render_ang = cannon.a end

    for i=1,#layer do
      local seg = layer[i]
      local x1,y1,x2,y2,col = seg[1],seg[2],seg[3],seg[4],seg[5]
      
      local rx_offset, ry_offset = 0, 0
      if li == 3 then
          rx_offset = -cannon.recoil * cos(cannon.a)
          ry_offset = -cannon.recoil * sin(cannon.a)
      end

      local rx1, ry1 = rotate_point_local(x1, y1, render_ang)
      local rx2, ry2 = rotate_point_local(x2, y2, render_ang)
      line(ship.x + rx1 + rx_offset, ship.y + ry1 + ry_offset, ship.x + rx2 + rx_offset, ship.y + ry2 + ry_offset, col)
    end
  end
end

function draw_setup_screen()
    rectfill(8, 2, 120, 10, 0)
    print(">>> assign controllers <<<", 12, 4, 7)
    
    for i=1,4 do
        local pr = player_roles[i]
        local y = 20 + (i-1)*24
        
        rectfill(8, y-2, 120, y+16, 0)
        
        print(pr.name, 10, y, pr.color)
        if pr.p_id != -1 then
            print("assigned to hardware port "..(pr.p_id), 10, y+8, 7)
        elseif i == assigned_count + 1 then
            if setup_timer > 0 then
                print("get ready...", 10, y+8, 5)
            else
                local flash = 5
                if (t() * 2) % 2 < 1 then flash = 7 end
                print("> press any button", 10, y+8, flash)
            end
        else
            print("waiting...", 10, y+8, 5)
        end
    end
end

function draw_test_screen()
    print("--- 4 player test ---", 22, 2, 7)
    for i=1,4 do
        local pr = player_roles[i]
        local p_id = pr.p_id
        local ox = ((i-1)%2)*64
        local oy = flr((i-1)/2)*64 + 14
        print(pr.name, ox+2, oy-4, pr.color)
        draw_btn(0, p_id, ox+12, oy+26, "l", pr.color)
        draw_btn(1, p_id, ox+28, oy+26, "r", pr.color)
        draw_btn(2, p_id, ox+20, oy+18, "u", pr.color)
        draw_btn(3, p_id, ox+20, oy+34, "d", pr.color)
        draw_btn(4, p_id, ox+44, oy+34, "o", pr.color)
        draw_btn(5, p_id, ox+56, oy+26, "x", pr.color)
    end
end

function draw_game_over()
    camera(0,0)
    
    rectfill(20, 30, 108, 98, 1)
    rect(20, 30, 108, 98, 12)
    
    print("critical failure", 32, 40, 8)
    print("final score", 42, 55, 6)
    
    local score_str = tostring(flr(score))
    print(score_str, 64 - (#score_str * 2), 65, 7)
    
    if game_over_timer > 0 then
        local w = ((150 - game_over_timer) / 150) * 60
        rectfill(34, 80, 34 + w, 84, 5)
        rect(34, 80, 94, 84, 13)
    else
        if (t()*2)%2 < 1 then
            print("> press any btn <", 30, 80, 10)
        end
    end
end
