--picoquest--

function _init()
    -- game states: "menu", "walking", "shopping", "encounter", "gameover"
    state = "menu"
    palt(0,false)
    music(1)
    --pal(6,11)
    --pal(7,11)

    -- player stats
    p_max_hp = 10
    p_hp = 10
    p_atk = 1
    p_gold = 10
    p_potions = 1
    xp = 0
    target_xp = 5
    lvl = 1
    
    -- screen shake variables
    shake_timer = 0
    shake_intensity = 0
    shake_dir = "x" -- "x" for horizontal, "y" for vertical

    -- enemy data definitions
    enemies = {
        { name = "boar",          hp = 5,  atk = 2, spr_start = 0 },
        { name = "goblin",        hp = 6,  atk = 3, spr_start = 4 },
        { name = "skeleton",      hp = 3,  atk = 2, spr_start = 12 },
        { name = "bear",          hp = 7,  atk = 4, spr_start = 8 },
        { name = "stone golem",   hp = 6, atk = 3, spr_start = 0 },
        { name = "thief",         hp = 15, atk = 2, spr_start = 0 },
        { name = "knight",        hp = 20, atk = 3, spr_start = 0 },
        { name = "steam golem",   hp = 10, atk = 4, spr_start = 0 },
        { name = "h.less horseman", hp = 25, atk = 3, spr_start = 0 },
        { name = "sorcerer", hp = 5, atk = 2, spr_start = 0},
        { name = "goblin king", hp = 20, atk = 2, spr_start = 0}
    }
    
    -- active enemy stats
    e_name = ""
    e_max_hp = 0
    e_hp = 0
    e_atk = 0
    e_spr_start = 0
    
    -- ui & navigation
    walk_text = ""
    menu_sel = 1
    paths = {}
    
    -- typewriter engine variables
    tw_full_text = ""
    tw_display_text = ""
    tw_char_idx = 0
    tw_timer = 0
    tw_speed = 1
    
    type_writer("  웃 picoquest 🐱")
end

-- typewriter engine helper
function type_writer(txt)
    tw_full_text = txt
    tw_display_text = ""
    tw_char_idx = 0
    tw_timer = 0
end

-- typewriter engine logic
function update_typewriter()
    if tw_char_idx < #tw_full_text then
        tw_timer += 1
        if tw_timer >= tw_speed then
            tw_timer = 0
            tw_char_idx += 1
            sfx(7)
            tw_display_text = sub(tw_full_text, 1, tw_char_idx)
        end
    end
end

-- helper to trigger screen shake (supports direction "x" or "y")
function trigger_shake(intensity, duration, dir)
    shake_intensity = intensity
    shake_timer = duration
    shake_dir = dir or "x"
end

-- reset state for a new game session
function reset_game()
    p_max_hp = 10
    p_hp = 10
    p_atk = 1
    p_gold = 10
    p_potions = 1
    xp = 0
    target_xp = 5
    lvl = 1
    shake_timer = 0
    shake_intensity = 0
    state = "walking"
    generate_paths()
end

-- location pool definition
location_pool = {
    { text = "ˇ forest path",        type = "encounter" },
    { text = "∧ riverbank road",     type = "encounter" },
    { text = "⌂ quiet town",         type = "encounter" },
    { text = "☉ castle path",        type = "encounter" },
    { text = "⌂ ruined street",      type = "encounter" },
    { text = "⌂ hometown road",      type = "encounter" },
    { text = "░ farmland path",      type = "encounter" },
    { text = "★ merchant shop",      type = "shop" },
    { text = "★ wandering merchant", type = "shop" }
}

-- generate 3 distinct path choices
function generate_paths()
    paths = {}
    local temp_pool = {}
    for loc in all(location_pool) do add(temp_pool, loc) end
    
    for i = 1, 3 do
        local idx = flr(rnd(#temp_pool)) + 1
        add(paths, temp_pool[idx])
        deli(temp_pool, idx)
    end
    
    menu_sel = 1
    type_writer("choose a path to travel:")
end

-- process selected path
function choose_path(idx)
    local chosen_path = paths[idx]
    
    if chosen_path.type == "shop" then
        state = "shopping"
        menu_sel = 1
        type_writer("merchant shop")
    else
        local chosen = enemies[flr(rnd(#enemies)) + 1]
        e_name = chosen.name
        e_max_hp = chosen.hp
        e_hp = chosen.hp
        e_atk = chosen.atk
        e_spr_start = chosen.spr_start
        
        walk_text = chosen_path.text
        state = "encounter"
        music(0)
        menu_sel = 1
        type_writer("traveling down\n"..walk_text.."\na "..e_name.." appears!")
    end
end

-- check one-shot press for buttons
function btnp_once(b)
    return btnp(b)
end

-- ========================================
-- update loop
-- ========================================
function _update()
    update_typewriter()
    
    -- update screen shake timer
    if shake_timer > 0 then
        shake_timer -= 1
    end
    
    if state == "menu" then
        if btnp_once(4) or btnp_once(5) then
            if menu_sel == 1 then
                reset_game()
            end
        end

    elseif state == "walking" then
        if btnp_once(2) then menu_sel = max(1, menu_sel - 1) end
        if btnp_once(3) then menu_sel = min(3, menu_sel + 1) end
        
        if btnp_once(4) or btnp_once(5) then
            choose_path(menu_sel)
        end

    elseif state == "shopping" then
        if btnp_once(2) then menu_sel = max(1, menu_sel - 1) end
        if btnp_once(3) then menu_sel = min(3, menu_sel + 1) end
        
        if btnp_once(4) or btnp_once(5) then
            if menu_sel == 1 then
                if p_gold >= 5 then
                    sfx(8)
                    p_gold -= 5
                    p_potions += 1
                    type_writer("bought health potion!")
                else
                    type_writer("not enough gold!")
                end
            elseif menu_sel == 2 then
                if p_gold >= 10 then
                    sfx(8)
                    p_gold -= 10
                    p_atk += 1
                    type_writer("upgraded weapon! atk: "..p_atk)
                else
                    type_writer("not enough gold!")
                end
            elseif menu_sel == 3 then
                music(1)
                state = "walking"
                generate_paths()
            end
        end

    elseif state == "encounter" then
        if btnp_once(0) then
            if menu_sel == 2 then menu_sel = 1 end
            if menu_sel == 4 then menu_sel = 3 end
        elseif btnp_once(1) then
            if menu_sel == 1 then menu_sel = 2 end
            if menu_sel == 3 then menu_sel = 4 end
        elseif btnp_once(2) then
            if menu_sel == 3 then menu_sel = 1 end
            if menu_sel == 4 then menu_sel = 2 end
        elseif btnp_once(3) then
            if menu_sel == 1 then menu_sel = 3 end
            if menu_sel == 2 then menu_sel = 4 end
        end
        
        if btnp_once(4) or btnp_once(5) then
            resolve_combat_turn(menu_sel)
        end

    elseif state == "gameover" then
        if btnp_once(4) or btnp_once(5) then
            state = "menu"
            menu_sel = 1
            sfx(4)
            music(1)
            type_writer("  웃 picoquest 🐱")
        end
    end
end

-- process combat actions
function resolve_combat_turn(action)
    local p_defending = false
    local temp_log = ""
    
    if action == 1 then
        temp_log = "you attack!\n"
        sfx(3)   
    elseif action == 2 then
        p_defending = true
        temp_log = "you guard!\n"
        sfx(2)
    elseif action == 3 then
        state = "walking"
        music(1)
        generate_paths()
        type_writer("you ran away safely!")
        return
    elseif action == 4 then
        if p_potions > 0 then
            p_potions -= 1
            p_hp = min(p_max_hp, p_hp + 5)
            temp_log = "healed 5 hp!\n"
            sfx(1)
        else
            temp_log = "no potions left!\n"
        end
    end
    
    local e_choice = flr(rnd(4))
    
    if e_choice == 0 then
        if action == 1 then
            e_hp -= p_atk
            temp_log ..= "dealt "..p_atk.." dmg.\n"
            -- horizontal shake on hitting enemy
            trigger_shake(3, 8, "x")
        end
        
        if e_hp <= 0 then
            local g = flr(rnd(5)) + 1
            p_gold += g
            xp += 2
            temp_log ..= "defeated "..e_name.."!\ngot "..g.."g and 2 xp."

            if xp >= target_xp then
                xp = 0
                lvl += 1
                p_atk += 1
                p_max_hp += 1
                target_xp *= 2
                temp_log ..= "\nlevel up! lvl "..lvl
            end
            music(1)
            state = "walking"
            type_writer(temp_log)
            generate_paths()
            return
        else
            local dmg = e_atk
            if p_defending then
                dmg = max(1, flr(e_atk / 2))
                temp_log ..= "blocked! took "..dmg.." dmg."
            else
                temp_log ..= e_name.." hit for "..dmg.." dmg."
            end
            p_hp -= dmg
            -- vertical shake when player takes damage
            trigger_shake(3, 8, "y")
        end
    else
        temp_log ..= e_name.." defends.\n"
        if action == 1 then
            local reduced = max(1, flr(p_atk / 2))
            e_hp -= reduced
            temp_log ..= "hit blocked! dealt "..reduced.." dmg."
            -- horizontal shake on hitting enemy (blocked)
            trigger_shake(2, 6, "x")
            
            if e_hp <= 0 then
                local g = flr(rnd(5)) + 1
                p_gold += g
                xp += 2
                temp_log ..= "\ndefeated "..e_name.."!\ngot "..g.."g & 2 xp."
                
                if xp >= target_xp then
                    xp = 0
                    lvl += 1
                    p_atk += 1
                    p_max_hp += 1
                    target_xp *= 2
                    temp_log ..= "\nlevel up!"
                end
                sfx(12)
            				music(1)
                state = "walking"
                type_writer(temp_log)
                generate_paths()
                return
            end
        end
    end
    
    type_writer(temp_log)
    
    if p_hp <= 0 then
        p_hp = 0
        state = "gameover"
        music(1)
        type_writer("game over\nyou were slain by the\n"..e_name)
    end
end

-- ========================================
-- draw loop
-- ========================================
function _draw()
    -- calculate horizontal or vertical camera offset for screen shake
    local cam_x, cam_y = 0, 0
    if shake_timer > 0 then
        local offset = flr(rnd(shake_intensity * 2 + 1)) - shake_intensity
        if shake_dir == "x" then
            cam_x = offset
        else
            cam_y = offset
        end
    end
    camera(cam_x, cam_y)

    cls(1) -- dark blue background for richer atmosphere
    palt(0,false)
    palt(14,true)

    -- top status bar with distinct stat colors
    if state != "menu" and state != "gameover" then
        rectfill(0, 0, 127, 18, 0)
        -- hp (red/pink), atk (orange), gold (yellow)
        print("웃", 2, 2, 7)
        print("hp:"..p_hp.."/"..p_max_hp, 10, 2, 8)
        print("atk:"..p_atk, 58, 2, 9)
        print("g:"..p_gold, 96, 2, 10)
        
        -- lvl (purple), xp (blue), potions (green)
        print("lvl:"..lvl, 2, 10, 13)
        print("xp:"..xp.."/"..target_xp, 34, 10, 12)
        print("pot:"..p_potions, 88, 10, 11)
        line(0, 19, 127, 19, 14) -- pink border line
    end
    
    if state == "menu" then
        print(tw_display_text, 24, 50, 10) -- yellow title
        print("--------------------", 24, 54, 9)  -- orange underline
        print("🅾️/❘ start game", 32, 80, 7)    -- white prompt
        print(">", 24, 80, 10)                  -- yellow cursor

    elseif state == "walking" then
        print(tw_display_text, 4, 25, 7)
        
        for i = 1, #paths do
            local y_pos = 45 + (i * 14)
            -- highlight selected path in yellow, others in light gray
            local c = (menu_sel == i) and 10 or 6
            print(i.."."..paths[i].text, 12, y_pos, c)
        end
        
        print(">", 4, 45 + (menu_sel * 14), 10) -- yellow cursor
        print("🅾️/❘ to select path", 4, 112, 7)  -- dark gray hint

    elseif state == "shopping" then
        print(tw_display_text, 4, 25, 10) -- yellow header
        
        print("1. health potion (5g)", 12, 50, (menu_sel == 1) and 10 or 11)  -- green accent
        print("2. upgrade weapon (10g)", 12, 62, (menu_sel == 2) and 10 or 9)  -- orange accent
        print("3. leave shop", 12, 74, (menu_sel == 3) and 10 or 6)           -- gray accent
        print(">", 4, 38 + (menu_sel * 12), 10)                             -- yellow cursor

    elseif state == "encounter" then
        -- enemy hp highlighted in red
        print("🐱 hp: "..e_hp.."/"..e_max_hp.." | atk: "..e_atk, 4, 40, 8)
        
        local start_x = 48
        local start_y = 26
        
        for sy = 0, 3 do
            for sx = 0, 3 do
                local spr_id = e_spr_start + sx + (sy * 16)
                -- spr(spr_id, start_x + (sx * 8), start_y + (sy * 8))
            end
        end

        print(tw_display_text, 4, 62, 7)
        
        -- action options with colored highlights when selected
        print("1.attack", 12, 90, (menu_sel == 1) and 10 or 8)   -- red/yellow
        print("2.defend", 68, 90, (menu_sel == 2) and 10 or 12)  -- blue/yellow
        print("3.run",    12, 102, (menu_sel == 3) and 10 or 6)  -- gray/yellow
        print("4.potion", 68, 102, (menu_sel == 4) and 10 or 11) -- green/yellow
        
        local cx = (menu_sel == 2 or menu_sel == 4) and 60 or 4
        local cy = (menu_sel == 3 or menu_sel == 4) and 102 or 90
        print(">", cx, cy, 10)

    elseif state == "gameover" then
        print(tw_display_text, 12, 40, 8)  -- red game over text
        print("press 🅾️/❘ to main menu", 10, 100, 7)
    end

    -- reset camera offset at the end of drawing
    camera()
end