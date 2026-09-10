-- ===================================================
-- PALACE 2.0: LUCK OF THE KINGDOM EDITION
-- Complete Arcade Version with Retro SFX Synthesizers
-- ===================================================

function _init()
  cart_title = "PALACE 2.0"
  cart_subtitle = "LUCK OF THE KINGDOM"
  
  music(-1)
  
  -- States: "intro", "start", "difficulty", "swap", "play", "gameover"
  g_state = "intro"
  
  intro_timer = 0
  intro_pig_y = -35
  intro_pig_target_y = 52
  intro_oink_played = false
  intro_wink_played = false
  sfx_oink = 7
  
  ai_diff = 1
  ai_count = 1
  ai_names = {"THE PRO", "THE GAMBLER", "THE HOARDER"}
  ai_descs = {
    "STRATEGIC MASTER. SAVES 2S AND 10S FOR CRITICAL MOMENTS.",
    "AGGRESSIVE RISKTACKER. PLAYS BIG CARDS EARLY!",
    "CARD COLLECTOR. HOARDS POWER CARDS TILL LATE GAME."
  }
  
  suit_symbols = {"s","h","d","c"}
  suit_names = {"SPADES", "HEARTS", "DIAMONDS", "CLUBS"}
  suit_colors = {0, 8, 9, 0}
  rank_names = {"2","3","4","5","6","7","8","9","10","J","Q","K","A"}
  
  sfx_select = 0
  sfx_play = 1
  sfx_burn = 2
  sfx_reset = 3
  sfx_pickup = 4
  sfx_win = 5
  sfx_lose = 6
  
  stars = {}
  for i = 1, 30 do
    add(stars, {x = flr(rnd(128)), y = flr(rnd(128)), spd = 0.2 + rnd(0.5), c = 6 + flr(rnd(2))})
  end
  
  particles = {}
  shake_amount = 0
  
  reset_game()
end

function reset_game()
  deck = {}
  discard = {}
  
  player = {
    hand = {},
    face_up = {},
    face_down = {},
    sel_idx = 1,
    pending = {},
    pending_val = nil,
    drew = false
  }
  
  ais = {}
  
  turn = "player"
  prev_turn = "swap"
  msg = ""
  msg_timer = 0
  
  effect_text = ""
  effect_color = 7
  effect_timer = 0
  
  ai_speech = ""
  ai_speech_timer = 0
  winner = nil
  ai_think_delay = 0
  
  local num_decks = (ai_count >= 2) and 2 or 1
  for d = 1, num_decks do
    for suit = 1, 4 do
      for rank = 1, 13 do
        add(deck, {
          suit = suit,
          rank = rank,
          val = rank + 1,
          id = suit * 100 + rank
        })
      end
    end
  end
  
  for i = #deck, 2, -1 do
    local j = flr(rnd(i)) + 1
    deck[i], deck[j] = deck[j], deck[i]
  end
  
  for i = 1, 3 do add(player.face_down, pop_deck()) end
  for i = 1, 6 do add(player.hand, pop_deck()) end
  
  for a = 1, ai_count do
    local opp = { hand = {}, face_up = {}, face_down = {}, drew = false }
    for i = 1, 3 do add(opp.face_down, pop_deck()) end
    for i = 1, 9 do add(opp.hand, pop_deck()) end
    add(ais, opp)
  end
  
  sort_hand(player.hand)
  for opp in all(ais) do
    sort_hand(opp.hand)
    ai_choose_faceup_for(opp)
  end
end

function ai_choose_faceup_for(a)
  local hand_copy = {}
  for c in all(a.hand) do add(hand_copy, c) end
  
  for i = 1, #hand_copy do
    for j = i + 1, #hand_copy do
      local score_i = hand_copy[i].val + ((hand_copy[i].val==2 or hand_copy[i].val==10) and 100 or 0)
      local score_j = hand_copy[j].val + ((hand_copy[j].val==2 or hand_copy[j].val==10) and 100 or 0)
      if score_i < score_j then
        hand_copy[i], hand_copy[j] = hand_copy[j], hand_copy[i]
      end
    end
  end
  
  a.face_up = {hand_copy[1], hand_copy[2], hand_copy[3]}
  for c in all(a.face_up) do
    for k = 1, #a.hand do
      if a.hand[k] == c then deli(a.hand, k) break end
    end
  end
  sort_hand(a.hand)
end

function pop_deck()
  if #deck == 0 then return nil end
  local c = deck[#deck]
  deli(deck, #deck)
  return c
end

function sort_hand(h)
  for i = 1, #h do
    for j = i + 1, #h do
      if h[i].val > h[j].val then
        h[i], h[j] = h[j], h[i]
      end
    end
  end
end

function draw_to_hand(p)
  if #p.hand >= 3 or #deck == 0 then return 0 end
  sfx(sfx_pickup)
  local result = 1
  while #p.hand < 3 and #deck > 0 do
    local c = pop_deck()
    add(p.hand, c)
    if #discard > 0 and c.val == discard[#discard].val then result = 2 end
  end
  sort_hand(p.hand)
  return result
end

function draw_one(p)
  if #deck == 0 then return 0 end
  sfx(sfx_pickup)
  local c = pop_deck()
  add(p.hand, c)
  local result = 1
  if #discard > 0 and c.val == discard[#discard].val then result = 2 end
  sort_hand(p.hand)
  return result
end

function draw_player_card()
  if #deck == 0 then
    set_msg("DECK IS EMPTY! CANNOT DRAW", 30)
    sfx(sfx_select)
    return
  end
  if player.drew then
    set_msg("ONLY 1 MANUAL DRAW PER TURN!", 35)
    sfx(sfx_select)
    return
  end
  player.drew = true
  local r = draw_one(player)
  if r == 2 then
    set_effect("DREW A MATCH!", 10, 45)
    set_msg("YOU DREW A MATCHING CARD!", 45)
  else
    set_effect("DREW A CARD!", 10, 35)
    set_msg("YOU DREW A CARD", 30)
  end
end

function player_forced_start_draw()
  if #player.hand == 3 and #deck > 0 then
    player.drew = true
    local r = draw_one(player)
    if r == 2 then
      set_effect("DREW A MATCH!", 10, 45)
      set_msg("FORCED DRAW MATCHED THE PILE!", 45)
    else
      set_effect("FORCED DRAW!", 10, 40)
      set_msg("HAD 3 CARDS! NO MORE DRAWS THIS TURN", 45)
    end
  end
end

function _update()
  if msg_timer > 0 then msg_timer -= 1 end
  if effect_timer > 0 then effect_timer -= 1 end
  if ai_speech_timer > 0 then ai_speech_timer -= 1 end
  if shake_amount > 0 then shake_amount -= 0.5 end
  
  for s in all(stars) do
    s.y += s.spd
    if s.y > 128 then s.y = 0 s.x = flr(rnd(128)) end
  end
  
  for p in all(particles) do
    p.x += p.dx
    p.y += p.dy
    p.life -= 1
    if p.life <= 0 then del(particles, p) end
  end
  
  if g_state == "intro" then
    intro_timer += 1
    
    if intro_pig_y < intro_pig_target_y then
      intro_pig_y += (intro_pig_target_y - intro_pig_y) * 0.15
      if abs(intro_pig_target_y - intro_pig_y) < 0.5 then
        intro_pig_y = intro_pig_target_y
      end
    end
    
    if intro_timer >= 28 and not intro_oink_played then
      intro_oink_played = true
      sfx(sfx_oink)
      shake_screen(3)
    end
    
    if intro_timer >= 52 and not intro_wink_played then
      intro_wink_played = true
      sfx(sfx_select)
      spawn_fireworks(76, intro_pig_y - 6, 8)
    end
    
    if btnp(4) or btnp(5) or intro_timer > 115 then
      g_state = "start"
      sfx(sfx_select)
    end
    return
  elseif g_state == "start" then
    if btnp(4) or btnp(5) then
      g_state = "difficulty"
      sfx(sfx_select)
    end
    return
  elseif g_state == "difficulty" then
    if btnp(0) then
      ai_diff = (ai_diff - 2) % 3 + 1
      sfx(sfx_select)
    elseif btnp(1) then
      ai_diff = ai_diff % 3 + 1
      sfx(sfx_select)
    elseif btnp(2) then
      ai_count = ai_count - 1
      if ai_count < 1 then ai_count = 3 end
      sfx(sfx_select)
    elseif btnp(3) then
      ai_count = ai_count % 3 + 1
      sfx(sfx_select)
    elseif btnp(4) or btnp(5) then
      reset_game()
      g_state = "swap"
      sfx(sfx_select)
    end
    return
  elseif g_state == "swap" then
    update_swap_phase()
    return
  elseif g_state == "gameover" then
    if btnp(4) or btnp(5) then
      g_state = "start"
      sfx(sfx_select)
    end
    return
  end
  
  -- PLAY STATE
  local this_turn = turn
  if this_turn == "player" then
    if prev_turn != "player" then
      player.drew = false
      player_forced_start_draw()
    end
    update_player_turn()
  else
    update_ai_turn()
  end
  prev_turn = this_turn
  
  check_win_conditions()
end

function update_swap_phase()
  local all_cards = {}
  for c in all(player.hand) do add(all_cards, c) end
  for c in all(player.face_up) do add(all_cards, c) end
  
  if #all_cards == 0 then return end
  if player.sel_idx > #all_cards then player.sel_idx = #all_cards end
  
  if btnp(0) then player.sel_idx = max(1, player.sel_idx - 1) sfx(sfx_select) end
  if btnp(1) then player.sel_idx = min(#all_cards, player.sel_idx + 1) sfx(sfx_select) end
  
  if btnp(4) then
    local card = all_cards[player.sel_idx]
    
    local in_faceup_idx = -1
    for k = 1, #player.face_up do
      if player.face_up[k] == card then in_faceup_idx = k break end
    end
    
    if in_faceup_idx > 0 then
      deli(player.face_up, in_faceup_idx)
      add(player.hand, card)
      sort_hand(player.hand)
      sfx(sfx_reset)
    else
      if #player.face_up < 3 then
        for k = 1, #player.hand do
          if player.hand[k] == card then deli(player.hand, k) break end
        end
        add(player.face_up, card)
        sfx(sfx_play)
        set_effect("FACE-UP SET!", 10, 20)
        spawn_fireworks(64, 60, 6)
      else
        set_msg("MAX 3 FACE-UP CARDS!", 30)
        sfx(sfx_select)
      end
    end
  end
  
  if btnp(5) then
    if #player.face_up == 3 then
      g_state = "play"
      
      local starter = nil
      while #deck > 0 do
        local c = pop_deck()
        if c.val != 2 and c.val != 10 then
          starter = c
          break
        end
      end
      if starter != nil then
        add(discard, starter)
        sfx(sfx_play)
        set_effect("STARTER: "..rank_names[starter.rank], 10, 45)
        set_msg("STARTER CARD DRAWN! YOUR TURN", 60)
      else
        set_msg("MATCH STARTED! YOUR TURN", 45)
      end
    else
      set_msg("PLEASE SELECT EXACTLY 3 FACE-UP CARDS!", 45)
      sfx(sfx_select)
    end
  end
end

function update_player_turn()
  local active_cards = get_active_cards(player)
  local source = get_active_source(player)
  if #active_cards == 0 then
    clear_pending()
    return
  end
  
  local pending_active = (#player.pending > 0)
  if pending_active and source != "hand" then
    clear_pending()
    pending_active = false
  end
  
  if btnp(2) then
    draw_player_card()
    return
  end
  
  if player.sel_idx > #active_cards then
    player.sel_idx = #active_cards
  end
  
  if btnp(0) then
    if source == "hand" and pending_active then
      player.sel_idx = prev_same_val(active_cards, player.sel_idx, player.pending_val)
    else
      player.sel_idx = max(1, player.sel_idx - 1)
    end
    sfx(sfx_select)
  end
  if btnp(1) then
    if source == "hand" and pending_active then
      player.sel_idx = next_same_val(active_cards, player.sel_idx, player.pending_val)
    else
      player.sel_idx = min(#active_cards, player.sel_idx + 1)
    end
    sfx(sfx_select)
  end
  
  if btnp(5) then
    if pending_active then
      play_card_set(player, "hand", player.pending)
      clear_pending()
    elseif #discard > 0 then
      pickup_and_play(player, "PICKUP PILE! LAY A CARD")
    else
      set_msg("PILE IS EMPTY! CANNOT PICKUP", 30)
      sfx(sfx_select)
    end
    return
  end
  
  if btnp(4) then
    local card = active_cards[player.sel_idx]
    
    if can_play(card) then
      if source == "hand" then
        if pending_active and card.val == player.pending_val then
          toggle_pending(card)
        elseif pending_active then
          clear_pending()
          add(player.pending, card)
          player.pending_val = card.val
          set_effect("SELECT MATCHES! X=PLAY", 10, 40)
          sfx(sfx_select)
        else
          add(player.pending, card)
          player.pending_val = card.val
          set_effect("SELECT MATCHES! X=PLAY", 10, 40)
          sfx(sfx_play)
        end
      else
        play_card_set(player, source, {card})
      end
    else
      if source == "face_down" then
        add(player.hand, card)
        deli(player.face_down, player.sel_idx)
        clear_pending()
        pickup_and_play(player, "FLIP FAILED! PICKUP & LAY")
      else
        shake_screen(3)
        set_effect("ILLEGAL MOVE!", 8, 35)
        set_msg("CARD TOO LOW! MUST MATCH OR BEAT TOP", 45)
        sfx(sfx_select)
      end
    end
  end
end

function clear_pending()
  player.pending = {}
  player.pending_val = nil
end

function toggle_pending(card)
  for k = 1, #player.pending do
    if player.pending[k] == card then
      deli(player.pending, k)
      if #player.pending == 0 then player.pending_val = nil end
      sfx(sfx_reset)
      return
    end
  end
  add(player.pending, card)
  sfx(sfx_play)
end

function prev_same_val(cards, idx, val)
  for i = idx - 1, 1, -1 do
    if cards[i].val == val then return i end
  end
  return idx
end

function next_same_val(cards, idx, val)
  for i = idx + 1, #cards do
    if cards[i].val == val then return i end
  end
  return idx
end

function is_pending(card)
  for k = 1, #player.pending do
    if player.pending[k] == card then return true end
  end
  return false
end

function pickup_and_play(p, msg_text)
  for c in all(discard) do add(p.hand, c) end
  discard = {}
  sort_hand(p.hand)
  
  draw_to_hand(p)
  
  shake_screen(4)
  sfx(sfx_pickup)
  set_effect("PICKUP & LAY!", 10, 45)
  set_msg(msg_text, 60)
  
  if p == player then
    clear_pending()
    turn = "player"
  else
    local my_idx = 0
    for i = 1, #ais do
      if ais[i] == p then my_idx = i break end
    end
    turn = my_idx
    if turn ~= "player" then ai_think_delay = 30 end
  end
end

function can_play(card)
  if #discard == 0 then return true end
  local top = discard[#discard]
  
  if card.val == 2 or card.val == 10 then return true end
  if top.val == 2 then return true end
  
  return card.val >= top.val
end

function play_card_set(p, source, card_set)
  local first_card = card_set[1]
  
  for card in all(card_set) do
    if source == "hand" then
      for k = 1, #p.hand do if p.hand[k] == card then deli(p.hand, k) break end end
    elseif source == "face_up" then
      for k = 1, #p.face_up do if p.face_up[k] == card then deli(p.face_up, k) break end end
    elseif source == "face_down" then
      for k = 1, #p.face_down do if p.face_down[k] == card then deli(p.face_down, k) break end end
    end
    add(discard, card)
  end
  
  sfx(sfx_play)
  local play_again = false
  
  if first_card.val == 10 then
    discard = {}
    shake_screen(7)
    spawn_fire(60, 46, 45)
    spawn_fireworks(64, 40, 20)
    set_effect("BURN! (10)", 9, 50)
    set_msg("PILE BURNED! PLAY AGAIN", 45)
    sfx(sfx_burn)
    play_again = true
  elseif first_card.val == 2 then
    shake_screen(2)
    spawn_reset(60, 46, 32)
    set_effect("RESET! (2)", 12, 45)
    set_msg("PILE RESET! PLAY AGAIN", 45)
    sfx(sfx_reset)
    play_again = true
  else
    if check_four_of_a_kind() then
      discard = {}
      shake_screen(8)
      spawn_fire(60, 46, 55)
      spawn_fireworks(64, 32, 25)
      set_effect("4 OF A KIND BURN!", 11, 50)
      set_msg("4 MATCHES! PILE BURNED", 45)
      sfx(sfx_burn)
      play_again = true
    else
      if p ~= player and #discard > #card_set and discard[#discard - #card_set].val == first_card.val then
        set_effect("STACK!", 10, 35)
        set_msg("MATCHED CARD! PLAYS AGAIN", 40)
        play_again = true
      end
    end
  end
  
  local drew_match = draw_to_hand(p)
  if p == player and drew_match == 2 then
    set_effect("DREW A MATCH!", 10, 40)
    set_msg("DREW MATCHING CARD! PLAY AGAIN", 45)
    play_again = true
  end
  
  if p == player then clear_pending() end
  
  if not play_again then
    if p == player then
      turn = 1
      ai_think_delay = 35
    else
      local my_idx = 0
      for i = 1, #ais do
        if ais[i] == p then my_idx = i break end
      end
      p.drew = false
      if my_idx >= #ais then
        turn = "player"
      else
        turn = my_idx + 1
      end
      if turn ~= "player" then ai_think_delay = 35 end
    end
  end
end

function check_four_of_a_kind()
  if #discard < 4 then return false end
  local v = discard[#discard].val
  for i = #discard - 3, #discard do
    if discard[i].val != v then return false end
  end
  return true
end

function update_ai_turn()
  if ai_think_delay > 0 then
    ai_think_delay -= 1
    return
  end
  
  local a = ais[turn]
  if not a then return end
  
  local active_cards = get_active_cards(a)
  local source = get_active_source(a)
  
  if #active_cards == 0 then return end
  
  if source == "face_down" then
    local ri = flr(rnd(#active_cards)) + 1
    local card = active_cards[ri]
    if can_play(card) then
      play_card_set(a, "face_down", {card})
    else
      deli(a.face_down, ri)
      add(a.hand, card)
      set_ai_speech("FLIP FAILED!")
      pickup_and_play(a, "AI FLIP FAILED! PICKUP & LAY")
    end
    return
  end
  
  local playable_indices = {}
  for i = 1, #active_cards do
    if can_play(active_cards[i]) then
      add(playable_indices, i)
    end
  end
  
  if #playable_indices > 0 then
    local chosen_idx = 1
    
    if ai_diff == 1 then
      local normal_playable = {}
      for idx in all(playable_indices) do
        local c = active_cards[idx]
        if c.val != 2 and c.val != 10 then add(normal_playable, idx) end
      end
      if #normal_playable > 0 then chosen_idx = normal_playable[1] else chosen_idx = playable_indices[1] end
      set_ai_speech("STRATEGIC MOVE!")
    elseif ai_diff == 2 then
      chosen_idx = playable_indices[#playable_indices]
      set_ai_speech("FEEL THE HEAT!")
    else
      chosen_idx = playable_indices[1]
      set_ai_speech("MY TREASURE...")
    end
    
    local first_card = active_cards[chosen_idx]
    local cards_to_play = {}
    if source == "hand" then
      for c in all(a.hand) do
        if c.val == first_card.val then add(cards_to_play, c) end
      end
    else
      add(cards_to_play, first_card)
    end
    
    play_card_set(a, source, cards_to_play)
  else
    if #a.hand > 3 and #deck > 0 and not a.drew then
      add(a.hand, pop_deck())
      a.drew = true
      sfx(sfx_pickup)
      ai_think_delay = 30
      set_ai_speech("DREW A CARD...")
      return
    end
    set_ai_speech("PICKUP & LAY!")
    pickup_and_play(a, "AI PICKED UP & PLAYED!")
  end
end

function get_active_source(p)
  if #p.hand > 0 then return "hand" end
  if #p.face_up > 0 then return "face_up" end
  return "face_down"
end

function get_active_cards(p)
  local source = get_active_source(p)
  if source == "hand" then return p.hand end
  if source == "face_up" then return p.face_up end
  return p.face_down
end

function ai_total_cards(a)
  return #a.hand + #a.face_up + #a.face_down
end

function check_win_conditions()
  local player_won = (#player.hand == 0 and #player.face_up == 0 and #player.face_down == 0)
  local ai_won_idx = 0
  for i = 1, #ais do
    local a = ais[i]
    if #a.hand == 0 and #a.face_up == 0 and #a.face_down == 0 then
      ai_won_idx = i
      break
    end
  end
  
  if player_won or ai_won_idx > 0 then
    if player_won then
      winner = "PLAYER"
    elseif ai_count > 1 then
      winner = ai_names[ai_diff].." #"..ai_won_idx
    else
      winner = ai_names[ai_diff]
    end
    g_state = "gameover"
    music(-1)
    if player_won then sfx(sfx_win) else sfx(sfx_lose) end
  end
end

function set_msg(txt, duration)
  msg = txt
  msg_timer = duration
end

function set_effect(txt, col, duration)
  effect_text = txt
  effect_color = col
  effect_timer = duration
end

function set_ai_speech(txt)
  ai_speech = txt
  ai_speech_timer = 45
end

function shake_screen(amt)
  shake_amount = amt
end

function spawn_fireworks(cx, cy, count)
  for i = 1, count do
    add(particles, {
      x = cx, y = cy,
      dx = (rnd(4) - 2), dy = (rnd(4) - 2),
      life = 10 + flr(rnd(15)),
      col = (rnd() > 0.5) and 9 or 10
    })
  end
end

function spawn_fire(cx, cy, count)
  for i = 1, count do
    local a = rnd() * 6.28318
    local sp = rnd(1.4) + 0.4
    add(particles, {
      x = cx + rnd(14) - 7,
      y = cy + rnd(14) - 7,
      dx = cos(a) * sp * 0.7,
      dy = sin(a) * sp - 0.5,
      life = 10 + flr(rnd(16)),
      col = ({8, 9, 9, 10})[1 + flr(rnd(4))]
    })
  end
end

function spawn_reset(cx, cy, count)
  for i = 1, count do
    local a = rnd() * 6.28318
    local dist = rnd(16) + 4
    local ox = cos(a) * dist
    local oy = sin(a) * dist * 0.5
    add(particles, {
      x = cx + ox,
      y = cy + oy,
      dx = -ox * 0.09,
      dy = -oy * 0.09,
      life = 12 + flr(rnd(10)),
      col = ({1, 6, 14, 13})[1 + flr(rnd(4))]
    })
  end
end

-- ===================================================
-- VISUAL RENDERING
-- ===================================================

function _draw()
  local sx = (shake_amount > 0) and flr(rnd(shake_amount) - shake_amount/2) or 0
  local sy = (shake_amount > 0) and flr(rnd(shake_amount) - shake_amount/2) or 0
  camera(sx, sy)
  
  cls(1)
  
  for s in all(stars) do
    pset(s.x, s.y, s.c)
  end
  
  if g_state == "intro" then
    draw_intro_screen()
  elseif g_state == "start" then
    draw_start_screen()
  elseif g_state == "difficulty" then
    draw_difficulty_screen()
  elseif g_state == "swap" then
    draw_swap_screen()
  elseif g_state == "play" then
    draw_play_screen()
  elseif g_state == "gameover" then
    draw_gameover_screen()
  end

  for p in all(particles) do
    pset(p.x, p.y, p.col)
  end

  camera(0, 0)
end

function draw_intro_screen()
  local title_y = min(18, -20 + intro_timer * 1.5)
  rectfill(0, title_y - 4, 128, title_y + 12, 12)
  rect(0, title_y - 4, 128, title_y + 12, 7)
  print("A PORX PRODUCTION", 16, title_y, 7)
  print("A PORX PRODUCTION", 15, title_y, 0)
  
  local px = 64
  local py = flr(intro_pig_y)
  
  draw_pig(px, py, intro_timer)
  
  if intro_timer >= 28 and intro_timer <= 75 then
    rectfill(px + 12, py - 22, px + 44, py - 8, 7)
    rect(px + 12, py - 22, px + 44, py - 8, 0)
    pset(px + 10, py - 14, 7)
    print("OINK!", px + 16, py - 18, 8)
  end
  
  if intro_timer > 60 then
    if flr(time() * 3) % 2 == 0 then
      print("PRESS (Z) TO CONTINUE", 18, 108, 10)
    end
  end
end

function draw_pig(cx, cy, timer)
  -- Ears
  rectfill(cx - 14, cy - 18, cx - 6, cy - 10, 14)
  rect(cx - 14, cy - 18, cx - 6, cy - 10, 0)
  pset(cx - 10, cy - 14, 8)
  
  rectfill(cx + 6, cy - 18, cx + 14, cy - 10, 14)
  rect(cx + 6, cy - 18, cx + 14, cy - 10, 0)
  pset(cx + 10, cy - 14, 8)
  
  -- Head
  circfill(cx, cy, 15, 14)
  circ(cx, cy, 15, 0)
  
  -- Rosy Cheeks
  circfill(cx - 10, cy + 4, 2, 8)
  circfill(cx + 10, cy + 4, 2, 8)
  
  -- Snout
  rectfill(cx - 6, cy - 1, cx + 6, cy + 7, 8)
  rect(cx - 6, cy - 1, cx + 6, cy + 7, 0)
  rectfill(cx - 4, cy + 2, cx - 2, cy + 5, 0)
  rectfill(cx + 2, cy + 2, cx + 4, cy + 5, 0)
  
  -- Left Eye (Open)
  circfill(cx - 6, cy - 5, 3, 7)
  circfill(cx - 5, cy - 5, 1, 0)
  pset(cx - 7, cy - 6, 7)
  
  -- Right Eye (Normal vs Winking)
  if timer >= 52 then
    line(cx + 3, cy - 5, cx + 9, cy - 5, 0)
    line(cx + 4, cy - 4, cx + 8, cy - 4, 0)
    pset(cx + 6, cy - 3, 0)
    
    print("*", cx + 11, cy - 10, 10)
    pset(cx + 13, cy - 8, 7)
  else
    circfill(cx + 6, cy - 5, 3, 7)
    circfill(cx + 5, cy - 5, 1, 0)
    pset(cx + 4, cy - 6, 7)
  end
end

function draw_big_letter(char, x, y, col, bg_col)
  bg_col = bg_col or 1
  if char == "P" then
    rectfill(x, y, x + 6, y + 5, col)
    rectfill(x + 2, y + 2, x + 4, y + 3, bg_col)
    rectfill(x, y + 6, x + 1, y + 10, col)
  elseif char == "A" then
    rectfill(x, y + 1, x + 6, y + 10, col)
    rectfill(x + 2, y + 2, x + 4, y + 4, bg_col)
    rectfill(x + 2, y + 7, x + 4, y + 10, bg_col)
    pset(x, y, bg_col) pset(x + 6, y, bg_col)
  elseif char == "L" then
    rectfill(x, y, x + 1, y + 10, col)
    rectfill(x + 2, y + 9, x + 6, y + 10, col)
  elseif char == "C" then
    rectfill(x, y, x + 6, y + 10, col)
    rectfill(x + 2, y + 2, x + 6, y + 8, bg_col)
    pset(x, y, bg_col) pset(x + 6, y, bg_col)
    pset(x, y + 10, bg_col) pset(x + 6, y + 10, bg_col)
  elseif char == "E" then
    rectfill(x, y, x + 6, y + 10, col)
    rectfill(x + 2, y + 2, x + 6, y + 3, bg_col)
    rectfill(x + 2, y + 6, x + 6, y + 8, bg_col)
  end
end

function draw_start_screen()
  local t = time()
  
  -- Castle / Palace Header Bar
  rectfill(0, 0, 128, 13, 3)
  rect(0, 0, 128, 13, 10)
  print("LUCK OF THE KINGDOM", 24, 4, 10)
  
  -- Floating Big 3D "PALACE" Logo
  local letters = {"P","A","L","A","C","E"}
  local start_x = 37
  local base_y = 20
  
  for i = 1, #letters do
    local lx = start_x + (i - 1) * 9
    local ly = base_y + flr(sin(t * 2.5 + i * 0.3) * 3)
    
    -- Drop Shadows
    draw_big_letter(letters[i], lx + 2, ly + 2, 0, 1)
    draw_big_letter(letters[i], lx + 1, ly + 1, 2, 1)
    -- Main Gold Letter
    draw_big_letter(letters[i], lx, ly, 10, 1)
    -- White Shimmer Top-Left Accent
    pset(lx + 1, ly + 1, 7)
  end
  
  -- Subtitle Badge
  rectfill(32, 40, 96, 48, 12)
  rect(32, 40, 96, 48, 7)
  print("2.0 EDITION", 42, 42, 7)
  
  -- 3 Floating Showcase Playing Cards (10???, A???, 2???)
  local c1_y = 56 + flr(sin(t * 2) * 3)
  local c2_y = 52 + flr(cos(t * 2) * 3)
  local c3_y = 56 - flr(sin(t * 2) * 3)
  
  draw_card_single(22, c1_y, {rank=9, suit=2, val=10}, true)  -- 10 of Hearts (BURN)
  draw_card_single(56, c2_y, {rank=13, suit=1, val=14}, true) -- Ace of Spades (HIGH)
  draw_card_single(90, c3_y, {rank=1, suit=3, val=2}, true)   -- 2 of Reset (RESET)
  
  -- Pulsing Press (Z) to Start Banner
  local pulse_col = (flr(t * 4) % 2 == 0) and 10 or 9
  rectfill(14, 95, 114, 109, pulse_col)
  rect(14, 95, 114, 109, 7)
  rect(16, 97, 112, 107, 0)
  print("PRESS (Z) TO START", 24, 100, 7)
  
  -- Footer with Porx Pig Emblem
  print("A PORX PRODUCTION", 28, 118, 6)
  circfill(22, 120, 3, 14)
  pset(22, 120, 8)
end

function print_wrapped(txt, x, y, col, max_w)
  local line = ""
  local cy = y
  for w in all(split(txt, " ")) do
    if #line + #w + 1 <= max_w then
      line = (line == "") and w or (line.." "..w)
    else
      print(line, x, cy, col)
      cy += 6
      line = w
    end
  end
  if line != "" then print(line, x, cy, col) end
end

function draw_difficulty_screen()
  print("SELECT OPPONENT", 32, 2, 7)
  
  rectfill(12, 9, 116, 22, 3)
  rect(12, 9, 116, 22, 10)
  print("<", 20, 13, 10)
  print(">", 100, 13, 10)
  local lbl = "1 VS "..ai_count
  print(lbl, 64 - #lbl * 2, 13, 7)
  print("LEFT/RIGHT: COUNT", 30, 24, 6)
  
  for i = 1, 3 do
    local y = 32 + (i - 1) * 19
    if i == ai_diff then
      rectfill(12, y, 116, y + 16, 12)
      rect(12, y, 116, y + 16, 7)
      print("> "..ai_names[i], 18, y + 5, 10)
    else
      rectfill(16, y, 112, y + 16, 0)
      rect(16, y, 112, y + 16, 5)
      print("  "..ai_names[i], 18, y + 5, 6)
    end
  end
  
  rectfill(8, 90, 120, 122, 0)
  rect(8, 90, 120, 122, 6)
  print_wrapped(ai_descs[ai_diff], 12, 93, 7, 26)
end

function draw_swap_screen()
  rectfill(0, 0, 128, 12, 12)
  print("CHOOSE 3 FACE-UP CARDS!", 10, 3, 7)
  
  local oy = 15
  if ai_count == 1 then
    print("AI DEFENSE (HIDDEN)", 24, oy, 6)
    draw_card_row(ais[1].face_up, 35, oy + 8, false, "face_up")
  else
    print("OPPONENT DEFENSES (HIDDEN)", 20, oy, 6)
    local step = flr(108 / ai_count)
    local ox = 4
    for k = 1, #ais do
      print("AI"..k, ox, oy + 6, 6)
      for j = 1, 3 do
        draw_card_single(ox + (j - 1) * 14, oy + 13, ais[k].face_up[j], false)
      end
      ox = ox + step
    end
  end
  
  print("YOUR 3 FACE-UP DEFENSE:", 16, 50, 10)
  draw_card_row(player.face_up, 35, 58, true, "face_up")
  
  local all_cards = {}
  for c in all(player.hand) do add(all_cards, c) end
  for c in all(player.face_up) do add(all_cards, c) end
  
  print("YOUR HAND (SELECT 3):", 18, 82, 7)
  draw_player_hand_overlapped(all_cards, player.sel_idx)
  
  local start_x = max(2, 64 - (#all_cards * 8))
  local hx = start_x + (player.sel_idx - 1) * 14
  rect(hx - 2, 89, hx + 16, 109, 10)
  
  rectfill(0, 112, 128, 128, 0)
  rect(0, 112, 128, 113, 5)
  local active_card = all_cards[player.sel_idx]
  if active_card then
    local s_name = suit_names[active_card.suit]
    local r_name = rank_names[active_card.rank]
    if active_card.val == 2 then
      print(r_name.." "..s_name..": POWER (RESET)", 2, 114, 12)
    elseif active_card.val == 10 then
      print(r_name.." "..s_name..": POWER (BURN)", 2, 114, 10)
    else
      print(r_name.." "..s_name.." (RANK "..active_card.val..")", 12, 114, 7)
    end
  end
  if #player.face_up == 3 then
    print("(Z)TOGGLE  (X)CONFIRM", 10, 122, 10)
  else
    print("(Z)TOGGLE 3 CARDS ("..#player.face_up.."/3)", 8, 122, 7)
  end
end

function draw_play_screen()
  if ai_count == 1 then
    print(ai_names[ai_diff], 2, 2, 6)
    draw_card_row(ais[1].face_up, 35, 10, false, "face_up")
    print("DOWN: "..#ais[1].face_down, 92, 2, 6)
    if ai_total_cards(ais[1]) <= 6 then
      local flash = (flr(time() * 6) % 2 == 0)
      local fwd_y = (#ais[1].face_up > 0) and 27 or 10
      draw_card_row(ais[1].face_down, 35, fwd_y, false, "face_down")
      if #ais[1].face_down > 0 then
        rect(34, fwd_y - 1, 126, fwd_y + 19, flash and 10 or 8)
      end
      print("LAST 6!", 2, 6, flash and 10 or 8)
    end
  else
    local colw = flr(112 / ai_count)
    local ox = 4
    for k = 1, #ais do
      if k == turn then
        rectfill(ox - 2, 0, ox + 40, 29, 12)
        rect(ox - 2, 0, ox + 40, 29, 7)
      end
      print("AI"..k..": "..#ais[k].face_down.."D", ox, 2, 7)
      if ai_total_cards(ais[k]) <= 6 then
        print("LAST6!", ox, 7, 8)
      end
      for j = 1, #ais[k].face_up do
        draw_card_single(ox + (j - 1) * 14, 8, ais[k].face_up[j], false)
      end
      ox = ox + colw
    end
  end
  
  if ai_speech_timer > 0 then
    if ai_count == 1 then
      rectfill(2, 14, 70, 24, 7)
      rect(2, 14, 70, 24, 0)
      print(ai_speech, 4, 16, 0)
    else
      rectfill(24, 30, 104, 39, 7)
      rect(24, 30, 104, 39, 0)
      print(ai_speech, 28, 32, 0)
    end
  end
  
  rectfill(10, 36, 26, 56, 4)
  rect(10, 36, 26, 56, 7)
  print("DECK", 12, 40, 7)
  print(""..#deck, 16, 48, 10)
  
  rectfill(52, 36, 68, 56, 0)
  rect(52, 36, 68, 56, 5)
  if #discard > 0 then
    local top = discard[#discard]
    draw_card_single(52, 36, top, true)
    print("PILE: "..#discard, 48, 58, 6)
  else
    print("EMPTY", 54, 44, 5)
  end
  
  if turn == "player" then
    print("YOUR TURN", 82, 42, 11)
  else
    print("AI THINKING...", 76, 42, 9)
  end
  
  if effect_timer > 0 then
    rectfill(10, 62, 118, 72, effect_color)
    rect(10, 62, 118, 72, 7)
    print(effect_text, 16, 64, 0)
  end
  
  local source = get_active_source(player)
  local active_cards = get_active_cards(player)

  if source == "hand" then
    draw_player_hand_overlapped(player.hand, player.sel_idx, player.pending)
    if #player.face_down > 0 or #player.face_up > 0 then
      print("DOWN: "..#player.face_down.."   UP: "..#player.face_up, 10, 105, 6)
    end
  else
    if #player.face_down > 0 then
      draw_card_row(player.face_down, 10, 72, false, "face_down")
    end
    if #player.face_up > 0 then
      draw_card_row(player.face_up, 10, 92, true, "face_up")
    end
    if #active_cards > 0 then
      local cx = 10 + (player.sel_idx - 1) * 18
      local top_y = (source == "face_up") and 91 or 71
      rect(cx - 1, top_y, cx + 15, top_y + 20, 10)
    end
  end
  
  rectfill(0, 112, 128, 128, 0)
  rect(0, 112, 128, 113, 5)
  
  local active_card = (#active_cards >= player.sel_idx) and active_cards[player.sel_idx] or nil
  if active_card then
    local s_name = suit_names[active_card.suit]
    local r_name = rank_names[active_card.rank]
    if active_card.val == 2 then
      print(r_name.." "..s_name..": RESETS PILE (ANY)", 2, 114, 12)
    elseif active_card.val == 10 then
      print(r_name.." "..s_name..": BURNS PILE (ANY)", 2, 114, 10)
    else
      print(r_name.." "..s_name.." (RANK "..active_card.val..")", 12, 114, 7)
    end
  end
  
  if #player.pending > 0 then
    print("PLAYING "..#player.pending.." CARDS! (X)=PLAY", 4, 122, 11)
  else
    print("(UP)DRAW (Z)SELECT (X)PICKUP", 6, 122, 7)
  end
end

function draw_card_row(cards, start_x, y, show_face, type_name)
  for i = 1, #cards do
    local x = start_x + (i - 1) * 18
    draw_card_single(x, y, cards[i], show_face)
  end
end

function draw_player_hand_overlapped(hand, sel_idx, pending)
  local start_x = max(2, 64 - (#hand * 8))
  for i = 1, #hand do
    local x = start_x + (i - 1) * 14
    local y = (i == sel_idx) and 90 or 96
    
    draw_card_single(x, y, hand[i], true)
    
    if pending and is_pending(hand[i]) then
      rect(x - 2, y - 2, x + 16, y + 20, 11)
    end
    
    if i == sel_idx then
      rect(x - 1, y - 1, x + 15, y + 19, 10)
    end
  end
end

function draw_suit_icon(cx, cy, suit)
  if suit == 2 then
    pset(cx+1, cy, 8) pset(cx+3, cy, 8)
    rectfill(cx, cy+1, cx+4, cy+2, 8)
    rectfill(cx+1, cy+3, cx+3, cy+3, 8)
    pset(cx+2, cy+4, 8)
  elseif suit == 3 then
    pset(cx+2, cy, 9)
    rectfill(cx+1, cy+1, cx+3, cy+1, 9)
    rectfill(cx, cy+2, cx+4, cy+2, 9)
    rectfill(cx+1, cy+3, cx+3, cy+3, 9)
    pset(cx+2, cy+4, 9)
  elseif suit == 1 then
    pset(cx+2, cy, 0)
    rectfill(cx+1, cy+1, cx+3, cy+1, 0)
    rectfill(cx, cy+2, cx+4, cy+2, 0)
    pset(cx+2, cy+3, 0)
    pset(cx+1, cy+4, 0) pset(cx+2, cy+4, 0) pset(cx+3, cy+4, 0)
  elseif suit == 4 then
    pset(cx+2, cy, 0)
    rectfill(cx+1, cy+1, cx+3, cy+1, 0)
    pset(cx, cy+2, 0) pset(cx+2, cy+2, 0) pset(cx+4, cy+2, 0)
    rectfill(cx+1, cy+3, cx+3, cy+3, 0)
    pset(cx+2, cy+4, 0)
  end
end

rank_glyphs = {
  ["A"] = {
    "011000",
    "100100",
    "100100",
    "100100",
    "111100",
    "100100",
    "100100",
    "100100"
  },
  ["J"] = {
    "000010",
    "000010",
    "000010",
    "000010",
    "000010",
    "000010",
    "010010",
    "001100"
  },
  ["K"] = {
    "100010",
    "100100",
    "101000",
    "110000",
    "110000",
    "101000",
    "100100",
    "100010"
  },
  ["Q"] = {
    "011110",
    "100001",
    "100001",
    "100001",
    "100001",
    "101001",
    "010010",
    "001100"
  },
  ["1"] = {
    "001000",
    "011000",
    "001000",
    "001000",
    "001000",
    "001000",
    "001000",
    "011100"
  },
  ["0"] = {
    "011110",
    "100010",
    "100110",
    "101010",
    "110010",
    "100010",
    "100010",
    "011110"
  },
  ["2"] = {
    "011100",
    "100010",
    "000010",
    "000100",
    "001000",
    "010000",
    "100000",
    "111110"
  },
  ["3"] = {
    "111100",
    "000010",
    "000010",
    "001110",
    "000010",
    "000010",
    "000010",
    "111100"
  },
  ["4"] = {
    "000100",
    "001100",
    "010100",
    "100100",
    "111111",
    "000100",
    "000100",
    "000100"
  },
  ["5"] = {
    "111110",
    "100000",
    "100000",
    "111100",
    "000010",
    "000010",
    "000010",
    "111100"
  },
  ["6"] = {
    "011110",
    "100000",
    "100000",
    "111100",
    "100010",
    "100010",
    "100010",
    "011100"
  },
  ["7"] = {
    "111111",
    "000001",
    "000010",
    "000100",
    "001000",
    "010000",
    "010000",
    "010000"
  },
  ["8"] = {
    "011110",
    "100010",
    "100010",
    "111110",
    "100010",
    "100010",
    "100010",
    "011110"
  },
  ["9"] = {
    "011110",
    "100010",
    "100010",
    "111110",
    "000010",
    "000010",
    "000010",
    "011100"
  }
}

function draw_big_rank(gx, gy, rows, col)
  for r = 1, #rows do
    local line = rows[r]
    for c = 1, #line do
      if sub(line, c, c) == "1" then
        pset(gx + c - 1, gy + r - 1, col)
      end
    end
  end
end

function draw_card_single(x, y, card, show_face)
  if not show_face or card == nil then
    rectfill(x, y, x + 14, y + 18, 8)
    rect(x, y, x + 14, y + 18, 0)
    rect(x + 2, y + 2, x + 12, y + 16, 10)
    rectfill(x + 4, y + 4, x + 10, y + 14, 2)
    print("P", x + 5, y + 6, 10)
  else
    local border_col = 0
    local col = suit_colors[card.suit]
    
    if card.val == 2 then
      border_col = 12
      col = 0
    elseif card.val == 10 then
      border_col = 8
      col = 8
    end
    
    rectfill(x, y, x + 14, y + 18, 7)
    rect(x, y, x + 14, y + 18, border_col)
    
    local gkey = rank_names[card.rank]
    if gkey == "10" then
      draw_big_rank(x + 1, y + 1, rank_glyphs["1"], col)
      draw_big_rank(x + 7, y + 1, rank_glyphs["0"], col)
    else
      draw_big_rank(x + 1, y + 1, rank_glyphs[gkey], col)
    end
    
    draw_suit_icon(x + 8, y + 11, card.suit)
  end
end

function draw_gameover_screen()
  rectfill(16, 30, 112, 98, 0)
  rect(16, 30, 112, 98, (winner == "PLAYER") and 11 or 8)
  
  if winner == "PLAYER" then
    print("VICTORY!", 48, 42, 11)
    print("YOU CONQUERED THE PALACE!", 18, 56, 7)
  else
    print("DEFEAT!", 50, 42, 8)
    print(winner.." WON!", 44, 56, 7)
  end
  
  print("PRESS (Z) FOR MAIN MENU", 18, 82, 10)
end
