-- gk aurophobia - cart 2

function colide(x1, y1, w1, h1, x2, y2, w2, h2)
 return x1 < x2 + w2 and
        x2 < x1 + w1 and
        y1 < y2 + h2 and
        y2 < y1 + h1 
end

function tem_parede(px, py)
 if cenario == "castelo" then
  if px < 16 or px > 614 or py < 30 or py > 52 then
   return true
  end
  local esq = flr((px + 1) / 8)
  local dir = flr((px + 6) / 8)
  local cima = flr((py + 2) / 8)
  local baixo = flr((py + 7) / 8)
  if fget(mget(esq, cima), 0) or fget(mget(dir, cima), 0) or
     fget(mget(esq, baixo), 0) or fget(mget(dir, baixo), 0) then
   return true
  end
  return false
 elseif cenario == "riacho" then
  if py < 34 * 8 or py > 40 * 8 or px < 12 * 8 or px > 78 * 8 then
   return true
  end
  return false
 end
 return false
end

function verifica_colisao(px, py)
 return tem_parede(px, py)
end

function _init()
 estado = "jogo"
 t_global = 0
 init_inventario()
 init_jogo()
 menuitem(1, "inventory", function() 
  estado = "inventario" 
 end)
 music(0)
end

function _update()
 t_global += 1
 if (fim_modo != nil or fim_flash > 0) and estado == "inventario" then
  estado = "jogo"
 end
 if (estado == "jogo" or estado == "inventario") and vida <= 0 and fim_modo == nil and fim_flash == 0 then
  estado = "morte"
  if init_morte then init_morte() end 
 end
 if estado == "jogo" then update_jogo()
 elseif estado == "inventario" then update_inventario()
 elseif estado == "morte" then
  if update_morte then update_morte() end 
 end
end

function _draw()
 cls(0)
 if estado == "jogo" then draw_jogo()
 elseif estado == "inventario" then draw_jogo() draw_inventario()
 elseif estado == "morte" then draw_morte()
 end
end

function init_jogo()
 cenario = "castelo"
 x = 3 * 8
 y = 5 * 8
 olhando_x = 1 
 olhando_y = 0 
 flip_x = true
 meu_sprite = 0
 estado_player = "normal"
 tempo = 0
 
 cartdata("goldenknight_save")
 local v_salva = dget(0)
 local vm_salva = dget(1)
 local o_salva = dget(2)
 local om_salva = dget(3)
 
 vida_max = (vm_salva > 0) and vm_salva or 10
 vida = (v_salva > 0) and v_salva or vida_max
 orbes_max = (om_salva > 0) and om_salva or 3
 orbes = (o_salva >= 0) and o_salva or 0

 timer_ataque = 0
 atacando = false
 tipo_ataque = 0
 carga_ataque = 0
 carga_cura = 0
 invuln_timer = 0
 shake_timer = 0
 notif_timer = 0
 
 conversando = false
 npc_atual = nil
 opcao_sel = 1
 diag_fase = "inicio"
 diag_pag = 1
 texto_char = 0
 
 sangues = {}
 npcs = {}
 inimigos = {}
 ondinhas = {}
 
 princesa = {
  x = 76 * 8,
  y = 6 * 8,
  spr = 103,
  tempo = 0,
  etapa = 1
 }
 
 climax_ativo = false
 climax_timer = 0
 flash_branco = 0
 
 deus_etapa = 1
 deus_iniciado = false
 delay_deus = 0
 deus_voltar_e = 1
 
 fim_modo = nil
 fim_tipo = nil
 fim_flash = 0
 creditos_t = 0
 creditos_scroll = 0
 
 -- boss nil ate jogador passar de x51 no riacho
 boss = nil
 boss_vencido = false
 
 escrever_diario("i made it. she guided me.\nmy light. my only love.\nsavior of this world who\nshall cleanse all sin\nfrom wretches like me.\nshe shall feast upon my\nliving flesh, drinking\nthe blood of my foes.\nshe will flay my skin,\ntearing into my ribcage,\nconsuming my warm heart,\ngorging on my entrails.\ni offer every bone, every\nvessel, every drop.\nmy agony is her holy joy.\npurify me in thy maw.")
end

function spawn_boss()
 boss = {
  x = 59 * 8,
  y = 37 * 8,
  vida = 40,
  vida_max = 40,
  estado = "levantando",
  rise_timer = 0,
  timer = 0,
  olhando_x = -1,
  olhando_y = 0,
  flip_x = false,
  flip_y = false,
  spr = 21,
  hit_timer = 0,
  recuo_timer = 0,
  vx = 0,
  vy = 0,
  morto = false,
  ja_atacou = false,
  ativado = false
 }
end

function de(e)
 spr(e.spr, e.x, e.y, 1, 1, e.flip_x, e.flip_y or false)
 if e.estado == "atacando" and e.timer >= 4 and e.timer <= 10 then
  local efx = e.flip_x
  local ess = 28
  if e.olhando_y != 0 then
   ess = 43
   local efy = (e.olhando_y == 1)
   spr(ess, e.x + e.olhando_x * 8, e.y + e.olhando_y * 8, 1, 1, efx, efy)
  else
   efx = not e.flip_x
   spr(ess, e.x + e.olhando_x * 8, e.y + e.olhando_y * 8, 1, 1, efx, false)
  end
 end
end

function iniciar_diag(n, f)
 npc_atual = n
 conversando = true
 opcao_sel = 1
 diag_pag = 1
 texto_char = 0
 diag_fase = f or "inicio"
end

function get_diag_paginas()
 if (npc_atual == nil) return nil
 if (diag_fase == "inicio") return npc_atual.fala_inicial
 if (diag_fase == "inimigos_vivos") return npc_atual.fala_inimigos
 return npc_atual[diag_fase]
end

function tem_item(n)
 for i in all(meus_itens) do if (i==n) return true end
 return false
end

function remove_item(n)
 del(meus_itens, n)
end

function update_dialogo_princesa()
 local e = princesa.etapa
 local d = { nome = "the princess", id = "princesa" }
 
 if e == 1 then
  d.fala_inicial = {"..."}
  d.opcoes1 = {"1. my princess.", "2. my goddess."}
 elseif e == 2 then
  d.fala_inicial = {"..."}
  d.opcoes1 = {"1. let us depart.\n   i came to save thee."}
 elseif e == 3 then
  d.fala_inicial = {"..."}
  d.opcoes1 = {"1. our foes lie slain.", "2. thy devotee kept faith."}
 elseif e == 4 then
  d.fala_inicial = {"... ... ..."}
  d.opcoes1 = {"1. i heard thy voice.", "2. i brought thine amulet."}
 elseif e == 5 then
  d.fala_inicial = {"... ... ... ... ..."}
  d.opcoes1 = {"1. my goddess, i shall kneel\n   before thy holiness."}
 elseif e == 6 then
  d.fala_inicial = {"... ..."}
  d.opcoes1 = {"1. we must take thee to\n   the kingdom of the sun."}
 elseif e == 7 then
  d.fala_inicial = {"... ... ... ... ... ..."}
  d.opcoes1 = {"1. ...", "2. ?"}
 elseif e == 8 then
  d.fala_inicial = {"wherefore comest thou?\nwhy so much misery?"}
  d.opcoes1 = {"1. i came to save thee."}
 elseif e == 9 then
  d.fala_inicial = {"i speak not unto him.\nthou knowest full well\nwhom i address."}
  d.opcoes1 = {"1. princess?"}
 elseif e == 10 then
  d.fala_inicial = {"why bring this disgusting,\nsoulless vessel unto me?"}
  d.opcoes1 = {"1. i understand not."}
 elseif e == 11 then
  d.fala_inicial = {
   "why hast thou done all\nthis? art thou mindful of\nthe harm thou hast wrought?",
   "thinkest thou the lives\nthou hast stolen matter\nnothing?"
  }
  d.opcoes1 = {"1. me? 'twas all for thee."}
 elseif e == 12 then
  d.fala_inicial = {
   "i speak not to him.\ni speak unto thee.\ni know thou art there.",
   "beyond the veil of this\nglass, looking upon us."
  }
  d.opcoes1 = {"1. what?"}
 elseif e == 13 then
  d.fala_inicial = {
   "'cake, vivo, zeq, batata,\nbrunow, mandi, mandy,\njhully, ana, ono, and\nthe others.'",
   "knowest thou these names?\nthinkest thou all of my\nworld mattereth not?",
   "that thou mayst do as\nthou wilt?",
   "thou sawest from the onset\nhow vile his mind was, yet\nthou didst persist in\nguiding him unto me."
  }
  d.opcoes1 = {"1. i am here to save thee."}
 elseif e == 14 then
  d.fala_inicial = {
   "i never sought salvation.\nthe march brought me here,\nmade its house my home,\nits bread my bread,",
   "and its people my people.\nif i dwell here, 'tis by\nmine own desire.",
   "i never besought rescue.\nyet even so, thou camest,\ntrampling upon everyone\nwho opposed thee.",
   "is this some manner of\nentertainment unto thee?"
  }
  d.opcoes1 = {"1. ..."}
 elseif e == 15 then
  d.fala_inicial = {"answer me:\nwhy didst thou do that?"}
  d.opcoes1 = {"1. i did it for thee.", "2. i did it for myself."}
 elseif e == 16 then
  d.fala_inicial = {
   "as expected.",
   "may thy soul be forgotten\nby other mortals, for unto\nme, thou hast never existed."
  }
 end
 return d
end

function update_dialogo_deus()
 local e = deus_etapa
 local d = { nome = "god", id = "deus" }
 
 if e == 1 then
  d.fala_inicial = {"my child, wherefore didst\nthou not answer me?"}
  d.opcoes1 = {"1. who art thou?\n   where am i?"}
 elseif e == 2 then
  d.fala_inicial = {
   "i am thy god. he who\ncalled thee from the start.",
   "thou art in the brook,\nwhose current divideth\nthe just from the unjust,",
   "carrying them unto paradise,\nor to burn in the pit."
  }
  d.opcoes1 = {"1. where is the princess?\n   i need her."}
 elseif e == 3 then
  d.fala_inicial = {
   "didst thou think of her\nwhen committing all those\natrocities?",
   "when thou burnedst my\ntemples, the house of my\ndaughters,",
   "slayedst my men, slaughtered\nthine own comrades, and\nblasphemed against my name?"
  }
  d.opcoes1 = {"1. yea.", "2. nay."}
 elseif e == 4 then
  d.fala_inicial = {
   "i called thee back many\ntimes. i barred the gates\nwith mine own hands",
   "that thou mightest repent.\ni set prophets before thee,\nand righteous men.",
   "i called thee unto me,\nmy child, for i love thee.\nyet the truth is, thou\nhast ever been here."
  }
  d.opcoes1 = {"1. what dost thou mean?"}
 elseif e == 5 then
  d.fala_inicial = {
   "thou strayedst so far from\nmy path that thy soul\ncould not bear thy flesh.",
   "thou didst what no man\nwould do with such fervor\nthat thou becamest a corpse",
   "corrupted by one thing\nalone: obsession.\nto-day thy flesh found its\nsoul once more."
  }
  d.opcoes1 = {"1. this meaneth that..."}
 elseif e == 6 then
  d.fala_inicial = {
   "thou hast been dead for\nlong, my child.",
   "thou diedst, returnedst,\nand diedst anew, yet thine\nobsession held thee fast,",
   "barring the brook from thy\njudgment. thou didst ever\nreturn unto that fire."
  }
  d.opcoes1 = {"1. i had to defeat her\n   enemies..."}
 elseif e == 7 then
  d.fala_inicial = {
   "blind obsession. so blind\nthou never sawest thine\nown greatest enemy.",
   "the foe thou couldst never\ndefeat, yet who hath ever\ndefeated thee.",
   "act differently one last\ntime... ... ..."
  }
 end
 return d
end

function perto_corpo()
 return boss != nil and boss.morto and abs(x - boss.x) < 14 and abs(y - boss.y) < 14
end

function update_dialogo_corpo()
 return {
  nome = "the body",
  id = "corpo",
  fala_inicial = {
   "the knight's body lieth\nstill within the castle.\nthe princess waiteth\nbeside him.",
   "wilt thou return unto\nthy flesh?\nheed this: the choice\ncannot be undone.",
   "thou mayst yet follow\nthe brook, and let the\nwaters bear thee.\nart thou certain?"
  },
  opcoes1 = {
   "1. return unto my body.",
   "2. accept my fate."
  }
 }
end

function update_dialogo_deus_voltar()
 local d = { nome = "god", id = "deus_voltar" }
 if deus_voltar_e == 1 then
  d.fala_inicial = {
   "i called thee by thy name.\nonce more thou wouldst not\nhearken. once more thou\nhast defied me."
  }
  d.opcoes1 = {"1. where lieth the castle?"}
 else
  d.fala_inicial = {
   "thou shalt never return.\nnever again shalt thou\nbring wretchedness upon\nthe world.",
   "thou hast refused the earth,\nthe heavens, and the pit.\ntherefore thou art cursed\nto walk this brook forever,",
   "from which thou shalt not\nleave."
  }
 end
 return d
end

function update_dialogo_deus_rio()
 return {
  nome = "god",
  id = "deus_rio",
  fala_inicial = {
   "thou hast chosen well.\nthou hast hearkened unto\nhim who knoweth all, and\nwhat is best for thee.",
   "after all thou hast done -\nall thou didst repent,\nand all thou didst not -\nshall follow thee",
   "along the brook.",
   "... ... ... ...",
   "may thy soul be judged,\nand thy slaughter end.\nthe brook shall decide."
  }
 }
end

function iniciar_flash_fim(tipo)
 fim_tipo = tipo
 fim_flash = 1
 conversando = false
 npc_atual = nil
end

function aplicar_fim()
 fim_flash = 0
 if fim_tipo == "voltar" then
  boss = nil
  sangues = {}
  x = 42 * 8
  y = 38 * 8
  meu_sprite = 0
  flip_x = false
  olhando_x = -1
  olhando_y = 0
  estado_player = "normal"
  deus_voltar_e = 1
  iniciar_diag(update_dialogo_deus_voltar())
 else
  x = 80 * 8
  y = 40 * 8
  meu_sprite = 14
  flip_x = true
  olhando_x = 1
  olhando_y = 0
  estado_player = "normal"
  atacando = false
  fim_modo = "corrente"
  creditos_t = 0
  creditos_scroll = 0
  iniciar_diag(update_dialogo_deus_rio())
 end
end

function comecar_andar_esq()
 fim_modo = "andar_esq"
 creditos_t = 0
 creditos_scroll = 0
 meu_sprite = 0
 flip_x = false
 olhando_x = -1
 atacando = false
end

function pcen(s, yy, c)
 print(s, 64 - #s * 2, yy, c)
end

function draw_creditos()
 if fim_modo == nil or creditos_t < 210 or conversando then return end
 rectfill(0, 0, 127, 127, 0)
 if cr_linhas == nil then cr_linhas = get_creditos() end
 local y0 = 132 - creditos_scroll
 for i=1, #cr_linhas do
  local e = cr_linhas[i]
  local yy = y0 + (i - 1) * 8
  if yy > -8 and yy < 128 and e[1] != "" then
   pcen(e[1], yy, e[2])
  end
 end
end

function get_creditos()
 return {
  {"POLLEN STUDIOS", 10},
  {"a somber production", 5},
  {"", 0},
  {"CONCEPT & DIRECTION", 10},
  {"Ariel Shalom", 7},
  {"", 0},
  {"STORY, WORLD & CHARACTERS", 10},
  {"Ariel Shalom", 7},
  {"", 0},
  {"CODE ARCHITECTURE", 10},
  {"& SYSTEMS", 10},
  {"Ariel Shalom", 7},
  {"Cake", 7},
  {"(for blind persistence,", 5},
  {"and for shaping the iron", 5},
  {"without knowing the fire)", 5},
  {"", 0},
  {"DESIGN COUNSEL", 10},
  {"Jhully", 7},
  {"(the illusion of control", 5},
  {"in times of uncertainty)", 5},
  {"", 0},
  {"LORE STUDIES & ENEMIES", 10},
  {"Ono", 7},
  {"(for giving form to figures", 5},
  {"that time forgot)", 5},
  {"", 0},
  {"REVIEW & MORAL SUPPORT", 10},
  {"Batata", 7},
  {"(for laughter in the abyss)", 5},
  {"", 0},
  {"LOST MUSIC", 10},
  {"& COMPOSITIONS OF THE DARK", 10},
  {"Vivo", 7},
  {"(for epic melodies that", 5},
  {"remained in silence)", 5},
  {"", 0},
  {"SPECIAL THANKS", 10},
  {"to all who walked this world", 6},
  {"when it was only an idea", 6},
  {"to the Beas server -", 6},
  {"the foundations of our kingdom", 6},
  {"to the first brave souls", 6},
  {"to cross these gates:", 6},
  {"Beas & Friends", 7},
  {"", 0},
  {"SOUND EFFECTS & TOOLS", 10},
  {"built upon the PICO-8 Engine", 6},
  {"& Denote Tool", 6},
  {"", 0},
  {"MUSIC", 10},
  {"j.s. bach", 7},
  {"partita no. 2 in d minor", 6},
  {"\"chaconne\"", 9},
  {"chopin", 7},
  {"prelude in e minor", 6},
  {"(op. 25 no.4)", 5},
  {"", 0},
  {"", 0},
  {"\"the golden knight truly", 9},
  {"existed, even after", 9},
  {"his death.\"", 9},
  {"", 0},
  {"\"this work is a tribute", 9},
  {"to all who believed", 9},
  {"in the ruin.\"", 9}
 }
end

function update_jogo()
 if cenario == "castelo" and princesa != nil then
  princesa.tempo += 1
  if princesa.tempo > 10 then
   princesa.tempo = 0
   princesa.spr = (princesa.spr == 103) and 104 or 103
  end
 end

 if shake_timer > 0 then shake_timer -= 1 end
 if invuln_timer > 0 then invuln_timer -= 1 end
 if notif_timer > 0 then notif_timer -= 1 end

 for o in all(ondinhas) do
  o.t += 1
  if o.t > 24 then del(ondinhas, o) end
 end

 -- flash dos finais
 if fim_flash > 0 then
  fim_flash += 1
  if fim_flash >= 157 then
   aplicar_fim()
  end
  return
 end

 -- andar sozinho / correnteza
 if fim_modo != nil then
  if fim_modo == "andar_esq" then
   x -= 0.28
   tempo += 1
   if tempo > 10 then
    tempo = 0
    meu_sprite = (meu_sprite == 1) and 0 or 1
   end
  elseif fim_modo == "corrente" then
   x += 0.28
   meu_sprite = 14
  end
  creditos_t += 1
  if creditos_t >= 250 and not conversando and creditos_scroll < 580 then
   creditos_scroll += 0.20
  end
 end

 -- climax da princesa
 if climax_ativo then
  climax_timer += 1
  shake_timer = 30
  orbes = 0
  orbes_max = 0
  
  if climax_timer % 8 == 0 then
   add(sangues, {x = x - 12 + rnd(24), y = y - 12 + rnd(24)})
  end
  if vida > 1 and climax_timer % 14 == 0 then
   vida -= 1
  end
  
  if climax_timer > 300 then
   flash_branco += 1
   if flash_branco > 150 then
    cenario = "riacho"
    climax_ativo = false
    flash_branco = 0
    x = 17 * 8
    y = 37 * 8
    olhando_x = 1
    olhando_y = 0
    flip_x = true
    estado_player = "caido"
    meu_sprite = 22
    vida = vida_max
    delay_deus = 90
    sangues = {}
    boss = nil
    boss_vencido = false
   end
  end
  return
 end

 -- dialogo de deus
 if cenario == "riacho" and not deus_iniciado then
  if delay_deus > 0 then
   delay_deus -= 1
   if delay_deus == 0 then
    deus_iniciado = true
    iniciar_diag(update_dialogo_deus())
   end
  end
 end

 -- spawn do boss quando jogador passa de x51 no riacho
 if cenario == "riacho" and boss == nil and not boss_vencido and not conversando and fim_modo == nil and x > 51 * 8 then
  spawn_boss()
 end

 if conversando and npc_atual != nil then
  if diag_fase == "opcoes1" or diag_fase == "opcoes2" or diag_fase == "opcoes3" then
   if (btnp(2)) opcao_sel = 1
   if (btnp(3) and npc_atual[diag_fase] and npc_atual[diag_fase][2]) opcao_sel = 2
   
   if btnp(4) or btnp(5) then
    if npc_atual.id == "princesa" then
     princesa.etapa += 1
     if princesa.etapa <= 16 then
      iniciar_diag(update_dialogo_princesa())
     else
      conversando = false
      climax_ativo = true
      climax_timer = 0
     end
    elseif npc_atual.id == "deus" then
     deus_etapa += 1
     if deus_etapa <= 7 then
      iniciar_diag(update_dialogo_deus())
     else
      conversando = false
      estado_player = "normal"
      meu_sprite = 0
     end
    elseif npc_atual.id == "corpo" then
     iniciar_flash_fim((opcao_sel == 1) and "voltar" or "obedecer")
    elseif npc_atual.id == "deus_voltar" then
     deus_voltar_e += 1
     iniciar_diag(update_dialogo_deus_voltar())
    else
     diag_pag = 1
     texto_char = 0
     conversando = false
    end
   end
  else
   local paginas = get_diag_paginas()
   if paginas != nil then
    local txt_completo = paginas[diag_pag]
    local vel_texto = (npc_atual.id == "princesa" or npc_atual.id == "deus" or npc_atual.id == "deus_voltar" or npc_atual.id == "deus_rio" or npc_atual.id == "deus_fim" or npc_atual.id == "corpo") and 0.45 or 1
    if texto_char < #txt_completo then texto_char += vel_texto end
    
    if btnp(4) or btnp(5) then
     if texto_char < #txt_completo then
      texto_char = #txt_completo
     else
      if diag_pag < #paginas then
       diag_pag += 1
       texto_char = 0
      else
       if diag_fase == "inicio" and npc_atual.opcoes1 != nil then
        diag_fase = "opcoes1"
        opcao_sel = 1
       else
        if npc_atual.id == "princesa" and princesa.etapa == 16 then
         conversando = false
         climax_ativo = true
         climax_timer = 0
        elseif npc_atual.id == "deus" and deus_etapa == 7 then
         conversando = false
         estado_player = "normal"
         meu_sprite = 0
        elseif npc_atual.id == "deus_voltar" then
         conversando = false
         comecar_andar_esq()
        else
         conversando = false
        end
       end
      end
     end
    end
   end
  end

 else
  if fim_modo == nil then
  if estado_player == "caido" then
   meu_sprite = 22
   return
  end

  if atacando then
   meu_sprite = 2
   timer_ataque += 1
   if tipo_ataque == 1 and timer_ataque > 10 then atacando = false end
   if tipo_ataque == 2 and timer_ataque > 25 then atacando = false end
  else
   local perto_interagivel = false
   for n in all(npcs) do if abs(x - n.x) < 12 and abs(y - n.y) < 12 and not n.morto then perto_interagivel = true end end
   if cenario == "castelo" and princesa != nil and abs(x - princesa.x) < 14 and abs(y - princesa.y) < 14 then perto_interagivel = true end
   if perto_corpo() then perto_interagivel = true end

   if btn(4) and not perto_interagivel and vida < vida_max and orbes > 0 then
    carga_cura += 1
    andando = false
    if carga_cura >= 90 then
     vida = min(vida_max, vida + 1)
     orbes -= 1
     carga_cura = 0
    end
   else
    if not btn(4) then carga_cura = 0 end
    if btn(5) then
     carga_ataque += 1
     andando = false
     meu_sprite = 2
    else
     if carga_ataque > 0 then
      atacando = true
      timer_ataque = 0
      if carga_ataque < 15 then tipo_ataque = 1 else tipo_ataque = 2 end
      carga_ataque = 0
     end
    end
    
    if carga_ataque == 0 and not atacando and carga_cura == 0 then
     andando = false
     if btn(0) then if not verifica_colisao(x-1, y) then x -= 1 end andando=true flip_x=false olhando_x=-1 olhando_y=0 end
     if btn(1) then if not verifica_colisao(x+1, y) then x += 1 end andando=true flip_x=true olhando_x=1 olhando_y=0 end
     if btn(2) then if not verifica_colisao(x, y-1) then y -= 1 end andando=true olhando_x=0 olhando_y=-1 end
     if btn(3) then if not verifica_colisao(x, y+1) then y += 1 end andando=true olhando_x=0 olhando_y=1 end

     if andando then
      tempo += 1
      if meu_sprite == 3 then meu_sprite = 0 end 
      if tempo > 5 then tempo = 0 if meu_sprite == 1 then meu_sprite = 0 else meu_sprite = 1 end end
      if cenario == "riacho" and t_global % 8 == 0 then
       add(ondinhas, {x = x, y = y + 5, t = 0})
      end
     else
      meu_sprite = 3
      tempo = 0
     end

     if btnp(4) then
      if cenario == "castelo" and princesa != nil and abs(x - princesa.x) < 14 and abs(y - princesa.y) < 14 then
       iniciar_diag(update_dialogo_princesa())
      elseif perto_corpo() then
       iniciar_diag(update_dialogo_corpo())
      else
       for n in all(npcs) do
        if abs(x - n.x) < 12 and abs(y - n.y) < 12 and not n.morto then
         iniciar_diag(n)
        end
       end
      end
     end
    end
   end
  end
  end
 end

 -- hitbox do jogador
 if atacando and (timer_ataque == 4 or timer_ataque == 12) then
  local hx = x + (olhando_x * 10)
  local hy = y + (olhando_y * 10)
  local hw = (olhando_x != 0) and 12 or 8
  local hh = (olhando_y != 0) and 12 or 8
  if olhando_x == -1 then hx -= 4 end
  if olhando_y == -1 then hy -= 4 end

  if boss != nil and boss.vida > 0 and boss.hit_timer == 0 and boss.estado != "levantando" then
   if colide(hx, hy, hw, hh, boss.x, boss.y, 8, 8) then
    boss.vida -= 1
    boss.hit_timer = 10
    boss.recuo_timer = 35
    local rdx = (boss.x > x) and 1.5 or -1.5
    local rdy = (boss.y > y) and 1.5 or -1.5
    if rnd(2) > 1 then rdy = (rnd(2) > 1) and 1.6 or -1.6 end
    boss.vx = rdx
    boss.vy = rdy
    boss.estado = "hit"
    if orbes < orbes_max then orbes += 1 end
    
    if boss.vida <= 0 and not boss.morto then
     boss.morto = true
     boss.spr = 48
     boss_vencido = true
     for i=1, 16 do add(sangues, {x = boss.x - 8 + rnd(16), y = boss.y - 8 + rnd(16)}) end
     iniciar_diag({
      id = "deus_fim",
      nome = "god",
      fala_inicial = {
       "for once thou hast obeyed\nme.",
       "now 'tis too late.\nbe righteous, and let the\nwaters decide thy path."
      }
     })
    end
   end
  end

  for e in all(inimigos) do
   if e.vida > 0 and e.hit_timer == 0 then
    if colide(hx, hy, hw, hh, e.x, e.y, 8, 8) then
     local dano = (tipo_ataque == 2) and 2 or 1
     e.vida -= dano
     e.hit_timer = 8
     e.estado = "hit"
     local nx = e.x + (olhando_x * 6)
     local ny = e.y + (olhando_y * 6)
     if not verifica_colisao(nx, e.y) then e.x = nx end
     if not verifica_colisao(e.x, ny) then e.y = ny end
     if orbes < orbes_max then orbes += 1 end
    end
   end
  end
 end

 -- IA do golden knight (baseada no general da marcha)
 if cenario == "riacho" and boss != nil and boss.vida > 0 and not boss.morto then
  if boss.hit_timer > 0 then boss.hit_timer -= 1 end

  local dx = x - boss.x
  local dy = y - boss.y
  local dist = flr(sqrt(dx*dx + dy*dy))

  -- orientacao visual
  if abs(dx) > abs(dy) then
   boss.olhando_x = (dx > 0) and 1 or -1
   boss.olhando_y = 0
   boss.flip_x = (boss.olhando_x == 1)
   boss.flip_y = false
  else
   boss.olhando_x = 0
   boss.olhando_y = (dy > 0) and 1 or -1
   boss.flip_x = false
   boss.flip_y = (boss.olhando_y == 1)
  end

  -- animacao de levantar
  if boss.estado == "levantando" then
   boss.ativado = true
   boss.rise_timer += 1
   if boss.rise_timer < 25 then
    boss.spr = 21
   elseif boss.rise_timer < 50 then
    boss.spr = 22
   else
    boss.spr = 0
    boss.estado = "perseguir"
    boss.timer = 0
   end
   return
  end

  if boss.recuo_timer > 0 then
   boss.recuo_timer -= 1
   boss.spr = 0
   boss.x += boss.vx
   boss.y += boss.vy
   if boss.recuo_timer == 0 then boss.estado = "perseguir" end
  elseif boss.estado == "hit" then
   boss.spr = 0
   if boss.hit_timer == 0 then boss.estado = "perseguir" end
  elseif boss.estado == "patrulha" or boss.estado == "perseguir" then
   if dist < 140 then
    boss.estado = "perseguir"
    local vel = 1.4
    local mx = (dx > 0) and vel or -vel
    local my = (dy > 0) and vel or -vel
    if abs(dx) > 6 then boss.x += mx end
    if abs(dy) > 6 then boss.y += my end
    boss.timer += 1
    boss.spr = (flr(boss.timer / 5) % 2 == 0) and 0 or 1
    if dist <= 14 then boss.estado = "preparar" boss.timer = 0 end
   else
    boss.estado = "patrulha"
    boss.spr = 0
   end
  elseif boss.estado == "preparar" then
   boss.spr = 2
   boss.timer += 1
   if boss.timer > 10 then boss.estado = "atacando" boss.timer = 0 boss.ja_atacou = false end
  elseif boss.estado == "atacando" then
   boss.timer += 1
   boss.spr = 2
   if boss.timer >= 4 and boss.timer <= 10 then
    local slash_x = boss.x + (boss.olhando_x * 8)
    local slash_y = boss.y + (boss.olhando_y * 8)
    if not boss.ja_atacou and invuln_timer == 0 and colide(slash_x, slash_y, 8, 8, x, y, 8, 8) then
     vida -= 5
     invuln_timer = 25
     boss.ja_atacou = true
     local nx = x + (boss.olhando_x * 8)
     local ny = y + (boss.olhando_y * 8)
     if not verifica_colisao(nx, y) then x = nx end
     if not verifica_colisao(x, ny) then y = ny end
     shake_timer = 15
    end
   end
   if boss.timer > 15 then boss.estado = "perseguir" boss.timer = 0 end
  end
 end
end

function draw_jogo()
 dcam()
 map()
 
 palt(14, true)
 palt(0, false)
 
 -- sol em paralaxe no riacho (eixo x centralizado, y33 fixo)
 if cenario == "riacho" then
  local sol_x = x - 8
  local sol_y = 33 * 8
  spr(18, sol_x, sol_y)
  spr(19, sol_x + 8, sol_y)
 end
 
 for o in all(ondinhas) do
  local ospr = (o.t <= 12) and 11 or 10
  spr(ospr, o.x, o.y)
 end
 
 for s in all(sangues) do spr(46, s.x, s.y) end

 if cenario == "castelo" and princesa != nil then
  spr(princesa.spr, princesa.x, princesa.y)
  if not conversando and not climax_ativo and abs(x - princesa.x) < 14 and abs(y - princesa.y) < 14 then
   if t_global % 30 < 15 then print("🅾️", princesa.x + 2, princesa.y - 8, 10) end
  end
 end

 if cenario == "riacho" and boss != nil then
  if boss.morto then
   spr(48, boss.x, boss.y)
   print("disgust", boss.x - 6, boss.y + 10, 8)
   if not conversando and fim_flash == 0 and perto_corpo() then
    if t_global % 30 < 15 then print("🅾️", boss.x + 2, boss.y - 8, 10) end
   end
  elseif boss.hit_timer % 2 == 0 then
   de(boss)
  end
 end

 for n in all(npcs) do
  spr(n.spr1, n.x, n.y)
  if not conversando and abs(x - n.x) < 12 and abs(y - n.y) < 12 and not n.morto then
   if t_global % 30 < 15 then print("🅾️", n.x + 2, n.y - 8, 10) end
  end
 end

 for e in all(inimigos) do
  if e.vida > 0 and e.hit_timer % 2 == 0 then de(e) end
 end

 if invuln_timer % 2 == 0 and estado_player != "execucao" then
  spr(meu_sprite, x, y, 1, 1, flip_x)
 end

 if fim_modo == nil and (atacando or estado_player == "execucao") then
  local spr_espada = 25
  local spr_slash = 28 
  local mostrar_slash = false
  local fx = false
  local fy = false
  local espada_x = x + (olhando_x * 8)
  local espada_y = y + (olhando_y * 8)
  
  if tipo_ataque == 1 then
   if timer_ataque < 3 then spr_espada = 25 
   elseif timer_ataque < 7 then spr_espada = 26 mostrar_slash = true
   else spr_espada = 25 end
  else
   if timer_ataque < 8 then spr_espada = 25 
   elseif timer_ataque < 18 then spr_espada = 27 mostrar_slash = true
   else spr_espada = 26 end 
  end

  if olhando_x != 0 then 
   fx = (olhando_x == -1) 
  elseif olhando_y != 0 then 
   fy = (olhando_y == 1) 
   if spr_espada == 25 then spr_espada = 41 end
   if spr_espada == 27 then spr_espada = 42 end
  end
  
  spr(spr_espada, espada_x, espada_y, 1, 1, fx, fy)
  
  if mostrar_slash then
   local slash_x = x + (olhando_x * 12)
   local slash_y = y + (olhando_y * 12)
   local slash_spr_atual = spr_slash
   if olhando_y != 0 then slash_spr_atual = 43 end
   spr(slash_spr_atual, slash_x, slash_y, 1, 1, fx, fy)
  end
 end

 palt()

 if carga_cura > 0 then
  rectfill(x, y - 4, x + 8, y - 3, 0)
  rectfill(x, y - 4, x + (carga_cura / 90 * 8), y - 3, 11)
 end

 camera()

 if conversando and npc_atual != nil then
  rectfill(4, 70, 124, 124, 0)
  rect(3, 69, 125, 125, 9)
  print(npc_atual.nome, 8, 73, 10)
  
  if diag_fase == "opcoes1" then
   print(npc_atual.opcoes1[1], 8, 83, (opcao_sel == 1) and 10 or 5)
   if npc_atual.opcoes1[2] != nil then print(npc_atual.opcoes1[2], 8, 93, (opcao_sel == 2) and 10 or 5) end
  else
   local paginas = get_diag_paginas()
   if paginas != nil then
    local txt_completo = paginas[diag_pag]
    local txt_visivel = sub(txt_completo, 1, flr(texto_char))
    print(txt_visivel, 8, 83, 7)
    if texto_char >= #txt_completo then
     if flr(t_global / 12) % 2 == 0 then print("🅾️", 112, 115, 10) end
    end
   end
  end
 end

 -- HUD vida
 if fim_modo == nil then
 local larg_bar = flr(vida_max * 5)
 rectfill(1, 1, 3 + larg_bar, 7, 0)
 rectfill(2, 2, 2 + larg_bar, 6, 1)
 if vida > 0 then
  rectfill(2, 2, 2 + flr(vida * 5), 6, 10) 
 end
 
 if orbes_max > 0 then
  for i=1, orbes_max do
   local pos_x = (i * 10) - 8
   if i <= orbes then spr(30, pos_x, 10) else spr(29, pos_x, 10) end
  end
 end

 -- barra de boss (aparece assim que o boss spawna e levanta)
 if cenario == "riacho" and boss != nil and boss.vida > 0 and boss.ativado then
  rectfill(28, 2, 100, 8, 0)
  rect(27, 1, 101, 9, 10)
  local b_larg = flr((boss.vida / boss.vida_max) * 70)
  rectfill(29, 3, 29 + b_larg, 7, 9)
  print("golden knight", 40, 11, 10)
 end

 if vida <= 3 then
  for i=1, 8 do
   local rx = rnd(128)
   local ry = rnd(128)
   local rt = 2 + rnd(8)
   rectfill(rx, ry, rx + rt, ry + rt, 0)
  end
  if t_global % 20 < 10 then
   local textos = {"w h o r t h y ?", "i l l u m i n a t e", "p u r i f y", "h e r  v o i c e"}
   local qual_texto = textos[1 + flr((t_global / 30) % 4)]
   local tx = 10 + rnd(80)
   local ty = 20 + rnd(80)
   print(qual_texto, tx+1, ty+1, 0)
   print(qual_texto, tx, ty, 8)
   print(qual_texto, tx+rnd(2), ty+rnd(2), 7)
  end
 end
 end

 if notif_timer > 0 then
  local ny = -20
  if notif_timer > 100 then
   ny = -20 + ((120 - notif_timer) * 1.5)
  elseif notif_timer < 20 then
   ny = 10 - ((20 - notif_timer) * 1.5)
  else
   ny = 10
  end
  rectfill(48, ny, 126, ny + 14, 0)
  rect(48, ny, 126, ny + 14, 9)
  spr(30, 50, ny + 3) 
  print("journal updated", 62, ny + 5, 10)
 end

 if flash_branco > 0 then
  rectfill(0, 0, 128, 128, 7)
 end

 if fim_flash > 0 then
  if fim_flash > 96 or flr((fim_flash - 1) / 8) % 2 == 0 then
   rectfill(0, 0, 127, 127, 7)
  end
 end

 draw_creditos()
end

function dcam()
 local sx = 0
 local sy = 0
 if shake_timer > 0 then
  sx = flr(rnd(7)) - 3
  sy = flr(rnd(7)) - 3
 end
 camera(x + 4 - 63 + sx, y + 4 - 63 + sy)
end

function init_morte()
 morte_timer = 0
 morte_fase = 0
 char_index = 0
 fragmentos = {}
 
 if cenario == "riacho" then
  linhas_morte = {
   "make 1% of thy choices",
   "worthwhile."
  }
 else
  linhas_morte = {
   "wherefore hast thou turned",
   "from me, my child?",
   "",
   "sufficed not the dignity",
   "of my gift?",
   "",
   "may thy memory be forgotten."
  }
 end
end

function update_morte()
 morte_timer += 1
 if morte_fase == 0 and morte_timer > 60 then
  morte_fase = 1
  for i=1, 20 do
   add(fragmentos, {
    x = 64, y = 64, 
    vx = (rnd(4) - 2) * 1.5,
    vy = (rnd(4) - 3) * 1.5,
    vida = 60 + rnd(40)
   })
  end
  morte_timer = 0
 elseif morte_fase == 1 and morte_timer > 100 then
  morte_fase = 2
  morte_timer = 0
 elseif morte_fase == 2 then
  if morte_timer % 3 == 0 then char_index += 1 end
  if cenario == "riacho" then
   if char_index > 60 then
    morte_fase = 3
    morte_timer = 0
   end
  else
   if btnp(4) or btnp(5) then _init() end
  end
 elseif morte_fase == 3 then
  morte_timer += 1
  if morte_timer > 30 then
   vida = vida_max
   if boss != nil then
    boss.x = 59 * 8
    boss.y = 37 * 8
    boss.vida = boss.vida_max
    boss.hit_timer = 0
    boss.recuo_timer = 0
    boss.estado = "perseguir"
   end
   estado = "jogo"
   estado_player = "normal"
   meu_sprite = 0
  end
 end

 for f in all(fragmentos) do
  if morte_fase == 3 then
   f.x += (64 - f.x) * 0.15
   f.y += (64 - f.y) * 0.15
  else
   f.x += f.vx
   f.y += f.vy
   f.vy += 0.05
   f.vida -= 1
   if f.vida <= 0 then del(fragmentos, f) end
  end
 end
end

function draw_morte()
 cls(0)
 if morte_fase == 0 or morte_fase == 3 then
  local pulso = sin(t_global / 20) * 2
  circfill(64, 64, 6 + pulso, 7)
  circ(64, 64, 7 + pulso, 10)
  pset(64, 64, 9)
 elseif morte_fase == 1 or (morte_fase == 2 and cenario != "riacho") then
  for f in all(fragmentos) do
   pset(f.x, f.y, 7)
   pset(f.x + 1, f.y, 10)
  end
 end

 if morte_fase >= 2 then
  local total_chars = char_index
  local y_txt = 32
  for i=1, #linhas_morte do
   local l = linhas_morte[i]
   if total_chars > 0 then
    local pedaco = sub(l, 1, total_chars)
    print(pedaco, 12, y_txt, 7)
    total_chars -= #l
   end
   y_txt += 10
  end
  if cenario != "riacho" and char_index > 150 and flr(t_global / 20) % 2 == 0 then
   print("press 🅾️ to awaken", 24, 110, 5)
  end
 end
end

function init_inventario()
 inv_aba = 1
 pagina_diario = 1
 meus_itens = {
  "castle key",
  "castle gear",
  "pure iron",
  "golden staff",
  "golden idol"
 }
 meu_diario = {
  "i awoke from the ashes.\nthe princess was taken.\nher light calls to me.\ni must breach the gate.",
  "fallen note\nwe found a maze ahead.\nwhat lies at its end,\nnone can say.\nsome men entered and\nnever came back.\ni melted iron idols\nand hid the metal in\nnearby tree branches.",
  "i found pure iron\nhidden in the branches\nof a gnarled tree.\nthe note was right.\nsomeone left it there,\nmelted from old idols.\nthe smith can use this.",
  "i found a broken smith.\nhis family was taken by\nknights for their golden\nhair. he agreed to forge\nthe gear for the gate,\nbut requires pure iron.",
  "they are all dead.\nthe march came through\nthe broken bridge.\nthey were not worthy.\nthe goddess who shall\nsave the world will\npray for their souls.\ni must press on.\ni am closer now.",
  "the princess parted\nthe waters for me.\nshe guides my blade.\nshe calls me back.\ni am coming, my light.",
  "a legend of the well:\nit grants desire only\nto blood of the pure,\ncorrupting light in dark.\ni must bathe the gold\nin innocent blood\nto break the curse and\nsave my goddess.",
  "his words filled me\nwith disgust. he spoke\nher name like a trophy.\nheresy. justice finds\nall heretics. i will\nfind her.",
  "the third trumpet hath\nsounded.\nwhat god sealed to guard\nthe world, man hath\nunsealed.\ni have entered her halls."
 }
end

function escrever_diario(novo_texto)
 add(meu_diario, novo_texto)
 pagina_diario = #meu_diario
 notif_timer = 120
 sfx(1)
end

function update_inventario()
 if (btnp(5)) estado = "jogo"
 if (btnp(4)) inv_aba = (inv_aba % 2) + 1
 if inv_aba == 2 then
  if (btnp(0) and pagina_diario > 1) pagina_diario -= 1
  if (btnp(1) and pagina_diario < #meu_diario) pagina_diario += 1
 end
end

function draw_inventario()
 rectfill(10, 10, 118, 118, 0) 
 rect(10, 10, 118, 118, 7)
 if inv_aba == 1 then
  print("--- thy belongings ---", 14, 14, 10)
  if #meus_itens == 0 then
   print("thy pouch remaineth empty.", 14, 30, 5)
  else
   for i=1, #meus_itens do
    print("- " .. meus_itens[i], 14, 20 + (i*10), 7)
   end
  end
 elseif inv_aba == 2 then
  local max_p = #meu_diario
  if max_p == 0 then max_p = 1 end
  print("--- thy journal (leaf " .. pagina_diario .. "/" .. max_p .. ") ---", 14, 14, 9)
  if #meu_diario == 0 then
   print("thou hast not written yet.", 14, 30, 5)
  else
   print(meu_diario[pagina_diario], 14, 30, 7)
  end
  print("<- and -> to turneth leaf", 14, 100, 5)
 end
 print("[🅾️] switch  [❘] returneth", 14, 110, 6)
end
