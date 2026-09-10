----- scoundrel-8 beta -------
---- by: dunwich_child -------
------------------------------

------------------------------
-------- init ----------------
------------------------------
function _init()
    -- estados principales --
    main_menu=true
    instructions=false
    main_game=false
    game_over=false
    end_game=false

    -- instrucciones --
    instructs={
        {"you're a warrior...",
        "you wake inside a series of ", 
        "caverns..."},
        {"travel across all rooms, kill", 
        "all beasts, use the items", 
        "felled adventurers have left"},
        {"you can only get out of a room",
        "when only one item or enemy is",
        "left"},
        {"every enemy will attack-",
        "your attack points (ap) will",
        "determine the damage you'll take"},
        {"your health ponts (hp) max",
        "at 20 points", 
        "-"},
        {"you can forfeit items to advance-",
        "if you equip a new weapon the",
        "old one will be replaced"},
        {"attacking enemies will degrade",
        "your weapon (ap) one point",
        "be sure to replace it often"},
        {"you can escape once every run",
        "this will reshuffle everything",
        "in the room"},
        ["x"]=0,
        ["y"]=35,
        ["counter"]=1
    }

    -- constantes y variables --
    main_screen={
        ["text"]="scoundr-8",
        ["x"]=46,
        ["y"]=32,
        ["sub_text"]="press ❘ to start new run",
        ["x_sub"]=16,
        ["y_sub"]=64
    }

    enter_room={
        ["text"]="press 🅾️ to enter room...",
        ["value"]=false,
        ["x"]=16,
        ["y"]=80
    }

    select={
        ["icon"]={
            ["x"]=32,
            ["y"]=48
        },
        ["pos"]=1,
        ["count"]=false,
        ["counter"]=0,
        ["counter_wait"]=0,
        ["wait"]=true,
        ["up"]=true,
        ["show_select"]=false,
        ["select_check"]=false,
        ["left"]=false,
        ["right"]=false,
        ["options"]={ -- opciones por tipo de carta
            false, -- enemigo
            false, -- arma
            false -- vida
           },
        ["can_escape"]=true, -- s??lo se puede cambiar una vez
        ["options_print"]={
            ["x"]=15,
            ["y"]=85,
            ["x2"]=15,
            ["y2"]=92,
            ["x3"]=80,
            ["y3"]=85
        },
        ["can_select"]=false
    }

    player={
        ["hp"]=20,
        --["weapon"]={
        --    ["ap"]=0,
        --    ["durability"]=0
        --} -- regresar a este formato en caso de implementar vendedores
        ["ap"]=0
    }

    cards={
        ["deck"]={
            {0,0,0,0,0,0,0,0,0,0,0,0}, -- clubs
            {0,0,0,0,0,0,0,0,0,0,0,0}, -- spades
            {0,0,0,0,0,0,0,0,0}, -- hearts
            {0,0,0,0,0,0,0,0,0} -- diamonds
        },
        ["n_total"]=42,
        ["total_enemies"]=24,
        ["n_obj"]=4,
        ["n_current_cards"]=0,
        ["current_cards"]={
            {["fig"]=nil,["suit"]=nil},
            {["fig"]=nil,["suit"]=nil},
            {["fig"]=nil,["suit"]=nil},
            {["fig"]=nil,["suit"]=nil}
        },
        ["types"]={
            "😐", -- enemy
            "🐱", -- enemy
            "✕", -- weapon
            "♥" -- health
        },
        ["type_color"]={
            8,-8,2,3
        },
        ["cards_position"]={
            ["1"]={
                ["x"]=32,
                ["y"]=46
            },
            ["2"]={
                ["x"]=52,
                ["y"]=46
            },
            ["3"]={
                ["x"]=72,
                ["y"]=46
            },
            ["4"]={
                ["x"]=92,
                ["y"]=46
            }
        }
    }

    debug={
        ["show"]=false,
        ["type"]=1,
        ["x"]=0,
        ["y"]=110,
        ["x2"]=0,
        ["y2"]=120,
        ["counter"]=0
    }
end

------------------------------
--------- update -------------
------------------------------
function _update()
    -- manejo de estados --
    if main_menu then
        if btnp(❘) then
            main_menu=false
            main_game=true
        elseif btnp(⬇️) then
            main_menu=false
            instructions=true
        end
    end

    if instructions then
        if btnp(🅾️) then
            instructions=false
            main_menu=true
        elseif btnp(➡️) then
            instructs.counter+=1
            if instructs.counter>8 then
                instructs.counter=1
            end
        elseif btnp(⬅️) then
            instructs.counter-=1
            if instructs.counter<1 then
                instructs.counter=8
            end
        end

    elseif main_game then
        -- logica del juego --
        if cards.n_obj > cards.n_total then
            cards.n_obj=cards.n_total -- manejo para que se puedan sacar todas las cartas
        end

        if not(enter_room.value) then -- manejar c??mo aparece "enter room"
            if select.counter>0 then
                select.counter-=1
            end

            --if select.count then
                if btnp(🅾️) then
                    draw_cards()
                    if cards.n_current_cards == cards.n_obj then -- esto evita que se carguen los valores nil en el print
                        enter_room.value=true
                        select.counter=5
                    end
                end
            --end
        end

        if cards.n_current_cards>1 or cards.n_total==1 then
            -- permitir la selecci??n de cartas --
            select.show_select=true
            card_anim()
            if btn(⬅️) then
                select.left=true
                select_move("left")
            else
                select.left=false
            end
            if btn(➡️) then
                select.right=true
                select_move("right")
            else
                select.right=false
            end
            -- manejo de presi??n de bot??n; permite presionar s??lo una vez y reacciona autom??ticamente el mov --
            if not(select.left) and not(select.right) then
                select.counter_wait=0
            end

            -- mostrar opciones de carta --
            select_options()
            if select.can_select then
                -- delay de presi??n de boton --
                if select.counter>0 then
                    select.counter-=1
                else
                    if btnp(❘) then
                        select_action("select")
                    elseif select.options[2] or select.options[3] then
                        if btnp(🅾️) and not(btn(⬆️)) then
                            select_action("forfeit")
                        end
                    end
                end
            end

            if cards.n_current_cards>1 and enter_room.value then
                if select.can_escape then
                    if btn(🅾️) and btn(⬆️) then
                        escape()
                        select.can_escape=false
                    end
                end
            end
        end

        if cards.n_current_cards==1 and cards.n_total>1 then
            enter_room.value=false
        end

        health_check()
        deck_check()


    ------ CHECAR SI LA ??LTIMA CARTA MATA AL JUGADOR QUE VAYA A GAME OVER ----
    elseif game_over then
        -- logica de game over --
        if btnp(🅾️) then
            _init()
        end   

    ------- CHECAR SI YA NO QUEDAN ENEMIGOS, TERMINAR JUEGO SI NO HAY ----
    elseif end_game then 
        -- logica de end game --
        if btnp(🅾️) then
            _init()
        end
    end

    ----------------
    ----- debug ----
    ----------------
    if btn(🅾️) and btn(⬇️) then
        debug.show=not(debug.show)
    end

    if debug.show then
        if btnp(⬅️) then
            debug.type-=1
        end

        if btnp(➡️) then
            debug.type+=1
        end

        if debug.type<1 then
            debug.type=8
        elseif debug.type>8 then
            debug.type=1
        end
    end

end

------------------------------
--------- draw ---------------
------------------------------
function _draw()
    cls()

    -- main menu --
    if main_menu then
        print(main_screen.text,main_screen.x,main_screen.y,7)
        print(main_screen.sub_text,main_screen.x_sub,main_screen.y_sub,7)
        print("press ⬇️ to see instructions")
    
    elseif instructions then
        print(instructs[instructs.counter][1],instructs.x,instructs.y)
        print(instructs[instructs.counter][2],instructs.x,instructs.y+13)
        print(instructs[instructs.counter][3],instructs.x,instructs.y+25)

        print("➡️ next",80,85)
        print("⬅️ before",80,95)
        print("🅾️ main menu",80,105)

        print("page",10,80)
        print(instructs.counter,29,80)
    
    -- main game --
    elseif main_game then
        -- datos de jugador --
        print("hp",95,15,3)
        print(player.hp,110,15,3)
        print("ap",105,25,2)
        print(player.ap,120,25,2)

        -- datos de cartas --
        print("deck",15,15,9)
        print(cards.n_total,35,15,9)

        -- posicion principal de cartas --
        print("●",cards.cards_position["1"].x,cards.cards_position["1"].y-5,7)
        print("●",cards.cards_position["2"].x,cards.cards_position["2"].y-5,7)
        print("●",cards.cards_position["3"].x,cards.cards_position["3"].y-5,7)
        print("●",cards.cards_position["4"].x,cards.cards_position["4"].y-5,7)

        if cards.n_current_cards > 0 then
            if cards.current_cards[1]["fig"]!=nil then
                print(cards.types[cards.current_cards[1]["fig"]],cards.cards_position["1"].x+2,cards.cards_position["1"].y+8,cards.type_color[cards.current_cards[1]["fig"]])
                print(cards.current_cards[1]["suit"]+1,cards.cards_position["1"].x+2,cards.cards_position["1"].y+15,7)
            end
            if cards.current_cards[2]["fig"]!=nil then
                print(cards.types[cards.current_cards[2]["fig"]],cards.cards_position["2"].x+2,cards.cards_position["2"].y+8,cards.type_color[cards.current_cards[2]["fig"]])
                print(cards.current_cards[2]["suit"]+1,cards.cards_position["2"].x+2,cards.cards_position["2"].y+15,7)
            end
            if cards.current_cards[3]["fig"]!=nil then
                print(cards.types[cards.current_cards[3]["fig"]],cards.cards_position["3"].x+2,cards.cards_position["3"].y+8,cards.type_color[cards.current_cards[3]["fig"]])
                print(cards.current_cards[3]["suit"]+1,cards.cards_position["3"].x+2,cards.cards_position["3"].y+15,7)
            end
            if cards.current_cards[4]["fig"]!=nil then            
                print(cards.types[cards.current_cards[4]["fig"]],cards.cards_position["4"].x+2,cards.cards_position["4"].y+8,cards.type_color[cards.current_cards[4]["fig"]])
                print(cards.current_cards[4]["suit"]+1,cards.cards_position["4"].x+2,cards.cards_position["4"].y+15,7)
            end

            print("type",cards.cards_position["1"].x-20,cards.cards_position["1"].y+8,10)
            print("value",cards.cards_position["1"].x-24,cards.cards_position["1"].y+15,6)
        end

        if not(enter_room.value) then
            print(enter_room.text,enter_room.x,enter_room.y,7)
        end

        -- mostrar info del jugador --
        -- mostrar select --
        if enter_room.value then
            if select.show_select then
                spr(3,select.icon["x"]+1,select.icon["y"])
            end
            -- mostrar opciones de cartas --
            if select.options[1] then
                print("enemy",select.options_print["x"],select.options_print["y"]-10,8)
                print("❘ attack",select.options_print["x"],select.options_print["y"],9)
            elseif select.options[2] then
                print("weapon",select.options_print["x"],select.options_print["y"]-10,2)
                if player.ap>0 then
                    print("❘ exchange",select.options_print["x"],select.options_print["y"],9)
                else
                    print("❘ equip",select.options_print["x"],select.options_print["y"],9)
                end
                print("🅾️ forfeit",select.options_print["x2"],select.options_print["y2"],9)
            elseif select.options[3] then
                print("health",select.options_print["x"],select.options_print["y"]-10,3)
                print("❘ heal",select.options_print["x"],select.options_print["y"],9)
                print("🅾️ forfeit",select.options_print["x2"],select.options_print["y2"],9)
            end

            if select.can_escape then
                print("⬆️+🅾️ escape",select.options_print["x3"],select.options_print["y3"],9)
                print("one time use",select.options_print["x3"],select.options_print["y3"]+8,9)
            end
            print("⬅️➡️ select",15,100)
        end
    
    -- game over --
    elseif game_over then
        print("you died",50,50,7)
        print("press 🅾️ to be reborn",25,70,7)

    -- end game --
    elseif end_game then
        print("you won!",50,50,7)
        print("press 🅾️ to be reborn",25,70,7)
    end

    -- debug --
    if debug.show then
        if debug.type==1 then
            print("main_menu",debug.x,debug.y)
            print(main_menu,debug.x2,debug.y2)
        elseif debug.type==2 then
            print("main_game",debug.x,debug.y)
            print(main_game,debug.x2,debug.y2)
        elseif debug.type==3 then
            print("game_over",debug.x,debug.y)
            print(game_over,debug.x2,debug.y2)
        elseif debug.type==4 then
            print("end_game",debug.x,debug.y)
            print(end_game,debug.x2,debug.y2)
        elseif debug.type==5 then
            print("n_cards_curr",debug.x,debug.y)
            print(cards.n_current_cards,debug.x2,debug.y2)
        elseif debug.type==6 then
            print("n_total",debug.x,debug.y)
            print(cards.n_total,debug.x2,debug.y2)
        elseif debug.type==7 then
            print("instructions",debug.x,debug.y)
            print(instructions,debug.x2,debug.y2)
        elseif debug.type==8 then
            print("enemies",debug.x,debug.y)
            print(cards.total_enemies,debug.x2,debug.y2)
        end
    end
end

------------------------------
--------- funciones ----------
------------------------------
function draw_cards()
    -- funcion para sacar las cartas --
    for i=1,cards.n_obj,1 do
        if cards.current_cards[i]["fig"]==nil then
            -- sacar carta del mazo --
            -- asignar carta a current_cards[i] --
            -- aumentar n_current_cards --
            attempts=0
            card_used=false
            while not(card_used) and attempts<100 do
                attempts+=1
                n_fig=flr(rnd(4))+1
                if n_fig==1 or n_fig==2 then -- cartas para enemigos
                    n_suit=flr(rnd(12))+1
                else -- cartas para jugador
                    n_suit=flr(rnd(9))+1
                end
                
                -- check si se ha usado la carta
                tot_cards_value=cards.deck[n_fig][n_suit]
                if tot_cards_value==0 then
                    cards.deck[n_fig][n_suit]=1
                    cards.current_cards[i]={["fig"]=n_fig,["suit"]=n_suit}
                    cards.n_current_cards+=1
                    --cards.n_total-=1
                    card_used=true
                --else 
                --    card_used=true
                end
            end
        end
    end
end

function card_anim()
    -- funci??n para la animaci??n del select --

end

function select_move(direction)
    -- manejo de movimiento de selecci??n --
    if select.counter_wait%5==0 then
        if direction=="right" then
            select.icon["x"]+=20
            sfx(0)
        end
        if direction=="left" then
            select.icon["x"]-=20
            sfx(0)
        end
    end
    
    if select.counter_wait>5 then
        select.counter_wait=0
    end
    
    if select.icon["x"]>92 then
        select.icon["x"]=32
    end
    if select.icon["x"]<32 then
        select.icon["x"]=92
    end

    select.counter_wait+=1
end

function select_options()
    -- manejo de opciones por selecci??n de carta --
    select_pos=select.icon["x"]
    if select_pos==32 then
        select.pos=1
    elseif select_pos==52 then
        select.pos=2
    elseif select_pos==72 then
        select.pos=3
    elseif select_pos==92 then
        select.pos=4
    end

    -- revisar atributos de carta seleccionada --
    selected_card=cards.current_cards[select.pos]
    card_fig=selected_card.fig

    -- opciones por tipo de carta --
    -- agregar a las opciones "descartar" para armas y vida
    if card_fig==1 or card_fig==2 then -- enemigos
        select.options[1]=true
    else 
        select.options[1]=false
    end

    if card_fig==3 then -- armas
     select.options[2]=true
    else 
        select.options[2]=false
    end

    if card_fig==4 then -- vida
        select.options[3]=true
    else 
        select.options[3]=false
    end

    if card_fig==nil then -- no hay carta
        select.can_select=false
    else 
        select.can_select=true
    end
end

function select_action(type_action)
    -- aplicar la selecci??n de la carta --
    selected_card=cards.current_cards[select.pos]

    if select.options[1] then
        enemy_attack=selected_card.suit+1
        -- ataque neto
        damage=enemy_attack-player.ap
        if damage<0 then
            damage=0
        end
        player.hp-=damage
        player.ap-=1
        if player.ap<0 then
            player.ap=0
        end
        sfx(1)
        cards.total_enemies-=1
    elseif select.options[2] then
        if type_action=="select" then
            player.ap=0 -- es como cambiar de arma
            player.ap+=(selected_card.suit+1)
            sfx(3)
        else 
            sfx(4)
        end
    elseif select.options[3] then
        if type_action=="select" then
            heal_value=selected_card.suit+1
            player.hp+=heal_value
            if player.hp>20 then
                player.hp=20
            end
            sfx(2)
        else 
            sfx(4)
        end
    end

    -- quitar carta y evitar selecci??n de opciones --
    cards.current_cards[select.pos]={["fig"]=nil,["suit"]=nil}
    cards.n_current_cards-=1
    cards.n_total-=1
end

function escape()
    for i=1,4,1 do
        card_i=cards.current_cards[i]

        fig_i=card_i.fig
        suit_i=card_i.suit

        if fig_i!=nil then
            cards.deck[fig_i][suit_i]=0
            cards.current_cards[i]={["fig"]=nil,["suit"]=nil}
            cards.n_current_cards-=1
            enter_room.value=false
        end
    end
end

function health_check()
    if player.hp<=0 then
        music(0)
        main_game=false
        game_over=true
    end
end

function deck_check()
    if cards.n_total<=0 or cards.total_enemies<=0 then
        main_game=false
        end_game=true
    end
end


