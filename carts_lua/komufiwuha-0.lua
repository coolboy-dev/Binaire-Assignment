-- space-break (retro breakout)

function _init()
    state = "title"
    score = 0
    lives = 3
    level = 1
    
    pad_x = 52
    pad_w = 24
    
    ball_x = 64
    ball_y = 100
    ball_vx = 1.5
    ball_vy = -1.5
    ball_attached = true
    
    bricks = {}
    lasers = {}
    powerups = {}
    particles = {}
    
    laser_upgrade = false
    build_level()
end

function build_level()
    bricks = {}
    lasers = {}
    powerups = {}
    ball_attached = true
    ball_x = pad_x + pad_w / 2
    ball_y = 108
    
    local rows = 3 + min(level, 4)
    for r=1, rows do
        for c=1, 8 do
            add(bricks, {
                x = (c-1)*15 + 5,
                y = r*8 + 12,
                w = 13,
                h = 6,
                col = 8 + (r % 6),
                hp = (r == 1) and 2 or 1
            })
        end
    end
end

function add_boom(x, y, col)
    for i=1, 6 do
        add(particles, {
            x=x, y=y,
            dx=(rnd(2)-1)*1.2, dy=(rnd(2)-1)*1.2,
            life=6+flr(rnd(4)), col=col
        })
    end
end

function _update()
    if state == "title" then
        if btnp(4) or btnp(5) then state = "game"; sfx(0) end
        return
    end

    if state == "gameover" then
        if btnp(4) or btnp(5) then _init(); state = "game" end
        return
    end

    -- pedal hareket??
    if (btn(0)) pad_x -= 2.5
    if (btn(1)) pad_x += 2.5
    pad_x = mid(2, pad_x, 126 - pad_w)

    -- topun pedalda durmasi / firtlatilmasi
    if ball_attached then
        ball_x = pad_x + pad_w / 2
        ball_y = 107
        if btnp(4) or btnp(5) then
            ball_attached = false
            ball_vx = (rnd(1) > 0.5) and 1.8 or -1.8
            ball_vy = -2
            sfx(1)
        end
    else
        -- top hareket??
        ball_x += ball_vx
        ball_y += ball_vy

        -- duvar ?♥arpi??malari
        if ball_x <= 2 or ball_x >= 124 then ball_vx *= -1; sfx(2) end
        if ball_y <= 12 then ball_vy *= -1; sfx(2) end

        -- pedal ?♥arpi??masi
        if ball_y >= 110 and ball_y <= 114 and ball_x >= pad_x and ball_x <= pad_x + pad_w and ball_vy > 0 then
            ball_vy *= -1
            -- vurdu??un yere g??re a???? ver
            local hit_pos = (ball_x - pad_x) / pad_w
            ball_vx = (hit_pos - 0.5) * 4
            sfx(1)
        end

        -- d????me
        if ball_y > 128 then
            lives -= 1
            sfx(3)
            laser_upgrade = false
            pad_w = 24
            if lives <= 0 then
                state = "gameover"
            else
                ball_attached = true
            end
        end
    end

    -- lazer ate????
    if laser_upgrade and btnp(5) and not ball_attached then
        add(lasers, {x=pad_x+2, y=108})
        add(lasers, {x=pad_x+pad_w-4, y=108})
        sfx(0)
    end

    for l in all(lasers) do
        l.y -= 4
        if (l.y < 10) del(lasers, l)
    end

    -- tu??la ?♥arpi??masi (top)
    for b in all(bricks) do
        if ball_x+2 >= b.x and ball_x-2 <= b.x+b.w and ball_y+2 >= b.y and ball_y-2 <= b.y+b.h then
            ball_vy *= -1
            b.hp -= 1
            sfx(2)
            add_boom(ball_x, ball_y, b.col)

            if b.hp <= 0 then
                score += 10
                if rnd(1) > 0.75 then
                    add(powerups, {x=b.x+b.w/2, y=b.y, type=flr(rnd(2))+1})
                end
                del(bricks, b)
            end
            break
        end

        -- lazer-tu??la
        for l in all(lasers) do
            if l.x >= b.x and l.x <= b.x+b.w and l.y >= b.y and l.y <= b.y+b.h then
                del(lasers, l)
                b.hp -= 1
                add_boom(l.x, l.y, b.col)
                if b.hp <= 0 then
                    score += 10
                    del(bricks, b)
                end
                break
            end
        end
    end

    -- powerup toplama
    for p in all(powerups) do
        p.y += 1
        if p.y >= 110 and p.y <= 116 and p.x >= pad_x and p.x <= pad_x + pad_w then
            sfx(4)
            if (p.type == 1) pad_w = min(40, pad_w + 6) -- geni?? pedal
            if (p.type == 2) laser_upgrade = true       -- lazer g??c??
            del(powerups, p)
        elseif p.y > 128 then
            del(powerups, p)
        end
    end

    -- b?∧l??m ge?♥me
    if #bricks == 0 then
        level += 1
        sfx(4)
        build_level()
    end

    for p in all(particles) do
        p.x += p.dx; p.y += p.dy; p.life -= 1
        if (p.life <= 0) del(particles, p)
    end
end

function _draw()
    cls(0)

    if state == "title" then
        print("s p a c e - b r e a k", 22, 45, 12)
        print("press a / z to start", 24, 75, (flr(time()*3)%2==0) and 10 or 7)
        return
    end

    if state == "gameover" then
        print("g a m e  o v e r", 32, 45, 8)
        print("score: "..score, 45, 62, 10)
        print("press a to restart", 26, 85, (flr(time()*4)%2==0) and 7 or 6)
        return
    end

    -- tu??lalar
    for b in all(bricks) do
        rectfill(b.x, b.y, b.x+b.w, b.y+b.h, b.col)
        rect(b.x, b.y, b.x+b.w, b.y+b.h, 7)
    end

    -- pedal
    rectfill(pad_x, 110, pad_x+pad_w, 114, laser_upgrade and 11 or 12)
    rect(pad_x, 110, pad_x+pad_w, 114, 7)

    -- top
    circfill(ball_x, ball_y, 2, 10)

    -- lazerler
    for l in all(lasers) do rectfill(l.x, l.y, l.x+1, l.y+3, 8) end

    -- poweruplar
    for p in all(powerups) do
        rectfill(p.x-2, p.y-2, p.x+2, p.y+2, p.type == 1 and 11 or 8)
    end

    for p in all(particles) do pset(p.x, p.y, p.col) end

    -- hud (??st bar)
    rectfill(0, 0, 128, 8, 1)
    print("scr:"..score, 2, 1, 10)
    print("lvl:"..level, 55, 1, 7)
    print("hp:"..lives, 100, 1, 8)
    line(0, 9, 128, 9, 6)
end